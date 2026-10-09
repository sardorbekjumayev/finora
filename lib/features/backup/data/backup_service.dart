import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
// `Category` nomi flutter/foundation'dagi annotatsiya bilan to'qnashadi.
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/date_range.dart';
import '../../../core/utils/money.dart';

/// Fayl Finora zaxirasi emas yoki buzilgan.
class BackupFormatException implements Exception {
  const BackupFormatException();
}

/// Fayl yangiroq ilovada yaratilgan — o'qib bo'lmaydi.
class BackupVersionException implements Exception {
  const BackupVersionException(this.fileVersion);

  final int fileVersion;
}

/// Tiklashdan keyin foydalanuvchiga ko'rsatiladigan natija.
@immutable
class RestoreStats {
  const RestoreStats({required this.accounts, required this.transactions});

  final int accounts;
  final int transactions;
}

/// Butun bazani bitta JSON faylga yozadi va qaytib o'qiydi.
///
/// Jadval tuzilmasi qo'lda takrorlanmaydi: har bir jadval `SELECT *` bilan
/// xom ko'rinishda olinadi va aynan shu ko'rinishda qaytariladi. Shunda
/// sxemaga yangi ustun qo'shilsa ham bu kod o'zgarishsiz ishlaydi.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  /// Fayl formati versiyasi (baza sxemasidan alohida).
  static const int formatVersion = 1;

  static const String _appTag = 'finora';

  Future<String> buildJson() async {
    final tables = <String, List<Map<String, Object?>>>{};
    for (final table in _db.allTables) {
      final rows = await _db
          .customSelect('SELECT * FROM "${table.actualTableName}"')
          .get();
      tables[table.actualTableName] = [for (final row in rows) row.data];
    }

    return const JsonEncoder.withIndent('  ').convert({
      'app': _appTag,
      'formatVersion': formatVersion,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tables': tables,
    });
  }

  /// Zaxira faylini vaqtinchalik papkaga yozadi — keyin `share_plus` orqali
  /// foydalanuvchi uni o'zi xohlagan joyga yuboradi.
  Future<File> writeBackupFile() async {
    final json = await buildJson();
    final stamp = DateFormat('yyyy-MM-dd-HHmm').format(DateTime.now());
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/finora-backup-$stamp.json');
    return file.writeAsString(json);
  }

  /// Fayldan tiklash. Hozirgi ma'lumot butunlay almashtiriladi.
  Future<RestoreStats> restoreFromJson(String content) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException {
      throw const BackupFormatException();
    }

    if (decoded is! Map<String, Object?>) throw const BackupFormatException();
    if (decoded['app'] != _appTag) throw const BackupFormatException();

    final fileVersion = decoded['formatVersion'];
    if (fileVersion is! int) throw const BackupFormatException();
    if (fileVersion > formatVersion) {
      throw BackupVersionException(fileVersion);
    }

    final payload = decoded['tables'];
    if (payload is! Map<String, Object?>) throw const BackupFormatException();

    final byTable = <String, List<Map<String, Object?>>>{};
    for (final table in _db.allTables) {
      final rows = payload[table.actualTableName];
      if (rows == null) continue;
      if (rows is! List) throw const BackupFormatException();
      byTable[table.actualTableName] = [
        for (final row in rows)
          if (row is Map<String, Object?>)
            row
          else
            throw const BackupFormatException(),
      ];
    }

    await _db.transaction(() async {
      // Yozuvlar takroriy qoida va qarzga ham havola qiladi, ya'ni jadval
      // tartibi bilan FK'ni qondirib bo'lmaydi. `defer_foreign_keys` tekshiruvni
      // tranzaksiya oxiriga suradi va commit'da avtomatik o'chadi.
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');

      for (final table in _db.allTables.toList().reversed) {
        await _db.delete(table).go();
      }

      for (final table in _db.allTables) {
        final rows = byTable[table.actualTableName];
        if (rows == null || rows.isEmpty) continue;

        for (final row in rows) {
          final columns = row.keys.toList(growable: false);
          if (columns.isEmpty) continue;
          final names = columns.map((c) => '"$c"').join(', ');
          final marks = List.filled(columns.length, '?').join(', ');
          await _db.customStatement(
            'INSERT INTO "${table.actualTableName}" ($names) VALUES ($marks)',
            [for (final column in columns) row[column]],
          );
        }
      }
    });

    // `customStatement` stream'larni o'zi xabardor qilmaydi.
    _db.markTablesUpdated(_db.allTables);

    return RestoreStats(
      accounts: byTable[_db.accounts.actualTableName]?.length ?? 0,
      transactions: byTable[_db.transactions.actualTableName]?.length ?? 0,
    );
  }

  /// Yozuvlarni jadval sifatida saqlash. [range] berilmasa — hamma yozuvlar.
  Future<File> writeCsvFile({DateRange? range}) async {
    final rows = await buildCsv(range: range);
    final stamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/finora-$stamp.csv');
    // BOM — Excel UTF-8'ni to'g'ri o'qishi uchun (kirill va o'zbek harflari).
    return file.writeAsString('$csvBom$rows');
  }

  /// Excel va Google Sheets UTF-8'ni BOM orqali aniqlaydi.
  static const String csvBom = '\u{FEFF}';

  /// CSV matni. Fayl yozishdan alohida — shunda testlar va boshqa
  /// chiqarish yo'llari platforma plaginiga bog'lanmaydi.
  Future<String> buildCsv({DateRange? range}) async {
    final where = range == null
        ? ''
        : 'WHERE t.date_time >= ?1 AND t.date_time < ?2';
    final result = await _db.customSelect(
      '''
SELECT t.date_time AS d,
       t.type AS type,
       t.amount AS amount,
       t.note AS note,
       a.currency AS currency,
       a.name AS account_name,
       ta.name AS to_account_name,
       c.name AS category_name
FROM transactions t
JOIN accounts a ON a.id = t.account_id
LEFT JOIN accounts ta ON ta.id = t.to_account_id
LEFT JOIN categories c ON c.id = t.category_id
$where
ORDER BY t.date_time DESC
''',
      variables: range == null
          ? const []
          : [
              Variable.withDateTime(range.start),
              Variable.withDateTime(range.end),
            ],
      readsFrom: {_db.transactions, _db.accounts, _db.categories},
    ).get();

    final date = DateFormat('yyyy-MM-dd');
    final time = DateFormat('HH:mm');
    final buffer = StringBuffer()
      ..writeln(
        _csvLine([
          'date',
          'time',
          'type',
          'amount',
          'currency',
          'account',
          'to_account',
          'category',
          'note',
        ]),
      );

    for (final row in result) {
      final moment = row.read<DateTime>('d');
      final currency = Currency.byCode(row.read<String>('currency'));
      buffer.writeln(
        _csvLine([
          date.format(moment),
          time.format(moment),
          row.read<String>('type'),
          Money.raw(row.read<int>('amount'), currency: currency),
          currency.code,
          row.read<String>('account_name'),
          row.readNullable<String>('to_account_name') ?? '',
          row.readNullable<String>('category_name') ?? '',
          row.readNullable<String>('note') ?? '',
        ]),
      );
    }

    return buffer.toString();
  }

  /// RFC 4180: qo'shtirnoq ikkilantiriladi, ajratgich/yangi qator bo'lsa
  /// qiymat qo'shtirnoqqa olinadi.
  static String _csvLine(List<String> values) {
    return values.map((value) {
      final needsQuotes = value.contains(',') ||
          value.contains('"') ||
          value.contains('\n') ||
          value.contains('\r');
      final escaped = value.replaceAll('"', '""');
      return needsQuotes ? '"$escaped"' : escaped;
    }).join(',');
  }
}

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(databaseProvider)),
);
