import 'dart:convert';

import 'package:drift/native.dart';
import 'package:finora/core/database/app_database.dart';
import 'package:finora/core/utils/date_range.dart';
import 'package:finora/features/accounts/data/account_repository.dart';
import 'package:finora/features/backup/data/backup_service.dart';
import 'package:finora/features/categories/data/category_repository.dart';
import 'package:finora/features/transactions/data/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BackupService backup;
  late AccountRepository accounts;
  late CategoryRepository categories;
  late TransactionRepository transactions;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    backup = BackupService(db);
    accounts = AccountRepository(db);
    categories = CategoryRepository(db);
    transactions = TransactionRepository(db);
  });

  tearDown(() => db.close());

  /// Ikki hisob, bitta kategoriya va uch xil yozuv — zaxira uchun namuna.
  Future<void> seed() async {
    final cash = await accounts.create(
      name: 'Naqd',
      type: AccountType.cash,
      currency: 'UZS',
      initialBalance: 50000000,
      iconKey: 'cash',
      colorValue: 0xFF1C6758,
    );
    final card = await accounts.create(
      name: 'Uzcard',
      type: AccountType.card,
      currency: 'UZS',
      initialBalance: 0,
      iconKey: 'card',
      colorValue: 0xFF1B5FBF,
    );
    final food = await categories.create(
      name: 'Oziq-ovqat',
      kind: CategoryKind.expense,
      iconKey: 'grocery',
      colorValue: 0xFF2E7D32,
    );

    await transactions.create(
      TxDraft(
        type: TransactionType.income,
        amount: 300000000,
        accountId: cash,
        date: DateTime(2026, 10, 1, 9),
        note: 'Maosh',
      ),
    );
    await transactions.create(
      TxDraft(
        type: TransactionType.expense,
        amount: 4500000,
        accountId: cash,
        categoryId: food,
        date: DateTime(2026, 10, 2, 18, 30),
        note: 'Bozor, "kechqurun"',
      ),
    );
    await transactions.create(
      TxDraft(
        type: TransactionType.transfer,
        amount: 10000000,
        accountId: cash,
        toAccountId: card,
        date: DateTime(2026, 10, 3, 12),
      ),
    );
  }

  group('JSON zaxira', () {
    test('sarlavhada ilova va versiya belgilari bo\'ladi', () async {
      await seed();
      final decoded = jsonDecode(await backup.buildJson()) as Map<String, Object?>;

      expect(decoded['app'], 'finora');
      expect(decoded['formatVersion'], BackupService.formatVersion);
      expect(decoded['schemaVersion'], db.schemaVersion);
      expect(decoded['exportedAt'], isA<String>());
      expect(decoded['tables'], isA<Map<String, Object?>>());
    });

    test('barcha jadvallar yoziladi', () async {
      final decoded = jsonDecode(await backup.buildJson()) as Map<String, Object?>;
      final tables = decoded['tables']! as Map<String, Object?>;

      for (final table in db.allTables) {
        expect(
          tables.containsKey(table.actualTableName),
          isTrue,
          reason: '${table.actualTableName} zaxiraga tushmagan',
        );
      }
    });

    test('tiklashdan keyin balans va yozuvlar aynan saqlanadi', () async {
      await seed();

      final json = await backup.buildJson();
      final before = await accounts.watchAccounts().first;
      final beforeCount = await transactions.countAll();

      await db.wipeEverything();
      expect(await transactions.countAll(), 0);

      final stats = await backup.restoreFromJson(json);
      expect(stats.accounts, 2);
      expect(stats.transactions, 3);

      final after = await accounts.watchAccounts().first;
      expect(after.map((a) => a.id), before.map((a) => a.id));
      expect(after.map((a) => a.name), before.map((a) => a.name));
      expect(after.map((a) => a.balance), before.map((a) => a.balance));
      expect(await transactions.countAll(), beforeCount);
    });

    test('sana, izoh va kategoriya havolasi buzilmaydi', () async {
      await seed();
      final json = await backup.buildJson();
      await backup.restoreFromJson(json);

      final list = await transactions.watchRecent().first;
      final expense = list.firstWhere(
        (item) => item.tx.type == TransactionType.expense,
      );

      expect(expense.tx.date, DateTime(2026, 10, 2, 18, 30));
      expect(expense.tx.note, 'Bozor, "kechqurun"');
      expect(expense.category?.name, 'Oziq-ovqat');
    });

    test('o\'tkazmaning qabul qiluvchi hisobi saqlanadi', () async {
      await seed();
      await backup.restoreFromJson(await backup.buildJson());

      final list = await transactions.watchRecent().first;
      final transfer = list.firstWhere(
        (item) => item.tx.type == TransactionType.transfer,
      );
      expect(transfer.toAccount?.name, 'Uzcard');
    });

    test('tiklash hozirgi ma\'lumotni almashtiradi, qo\'shmaydi', () async {
      await seed();
      final json = await backup.buildJson();

      // Zaxiradan keyin yana bitta yozuv qo'shamiz.
      final list = await accounts.watchAccounts().first;
      await transactions.create(
        TxDraft(
          type: TransactionType.expense,
          amount: 1000,
          accountId: list.first.id,
          date: DateTime(2026, 10, 5),
        ),
      );
      expect(await transactions.countAll(), 4);

      await backup.restoreFromJson(json);
      expect(await transactions.countAll(), 3);
    });

    test('bo\'sh bazani zaxiralash va tiklash ishlaydi', () async {
      final stats = await backup.restoreFromJson(await backup.buildJson());
      expect(stats.accounts, 0);
      expect(stats.transactions, 0);
    });
  });

  group('noto\'g\'ri fayl', () {
    test('JSON bo\'lmagan matn rad etiladi', () async {
      await expectLater(
        backup.restoreFromJson('bu json emas'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('boshqa ilovaning JSON\'i rad etiladi', () async {
      await expectLater(
        backup.restoreFromJson('{"app":"other","formatVersion":1,"tables":{}}'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('formatVersion yo\'q bo\'lsa rad etiladi', () async {
      await expectLater(
        backup.restoreFromJson('{"app":"finora","tables":{}}'),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('kelgusi versiya tushunarli xato beradi', () async {
      await expectLater(
        backup.restoreFromJson(
          '{"app":"finora","formatVersion":99,"tables":{}}',
        ),
        throwsA(isA<BackupVersionException>()),
      );
    });

    test('rad etilgan fayl hozirgi ma\'lumotni buzmaydi', () async {
      await seed();
      try {
        await backup.restoreFromJson('{"app":"other"}');
      } on BackupFormatException {
        // Kutilgan.
      }
      expect(await transactions.countAll(), 3);
    });
  });

  group('CSV eksport', () {
    List<String> linesOf(String csv) =>
        csv.trim().split('\n').map((line) => line.trimRight()).toList();

    test('sarlavha va har bir yozuv uchun bitta qator', () async {
      await seed();
      final lines = linesOf(await backup.buildCsv());

      expect(
        lines.first,
        'date,time,type,amount,currency,account,to_account,category,note',
      );
      expect(lines, hasLength(4));
    });

    test('vergul va qo\'shtirnoq qalqonlanadi', () async {
      await seed();
      // `Bozor, "kechqurun"` → qo'shtirnoqqa olinadi, ichkisi ikkilanadi.
      expect(await backup.buildCsv(), contains('"Bozor, ""kechqurun"""'));
    });

    test('davr filtri qo\'llanadi', () async {
      await seed();
      final lines = linesOf(
        await backup.buildCsv(
          range: DateRange.custom(DateTime(2026, 10, 2), DateTime(2026, 10, 2)),
        ),
      );

      // Sarlavha + 2-oktabrdagi yolg'iz yozuv.
      expect(lines, hasLength(2));
      expect(lines[1], contains('2026-10-02'));
      expect(lines[1], contains('18:30'));
    });

    test('summa asosiy birlikda yoziladi', () async {
      await seed();
      // 4 500 000 tiyin = 45 000 so'm.
      expect(await backup.buildCsv(), contains(',45000,UZS,'));
    });

    test('yozuvsiz bazada faqat sarlavha qoladi', () async {
      expect(linesOf(await backup.buildCsv()), hasLength(1));
    });
  });
}
