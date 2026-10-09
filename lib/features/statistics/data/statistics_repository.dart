import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/balance_sql.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/date_range.dart';
import 'currency_converter.dart';

/// Agregatsiya uchun minimal yozuv. Guruhlash Dart tomonida bajariladi —
/// shunda vaqt zonasi va moliyaviy oy boshlanishi to'g'ri hisoblanadi.
@immutable
class StatEntry {
  const StatEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.currency,
    required this.accountId,
    this.categoryId,
    this.note,
  });

  final int id;
  final DateTime date;
  final TransactionType type;
  final int amount;
  final String currency;
  final int accountId;
  final int? categoryId;
  final String? note;
}

const String _entriesSql = '''
SELECT t.id AS id,
       t.date_time AS d,
       t.type AS type,
       t.amount AS amount,
       t.category_id AS category_id,
       t.account_id AS account_id,
       t.note AS note,
       a.currency AS currency
FROM transactions t
JOIN accounts a ON a.id = t.account_id
WHERE t.date_time >= ?1 AND t.date_time < ?2
''';

class StatisticsRepository {
  StatisticsRepository(this._db);

  final AppDatabase _db;

  Stream<List<StatEntry>> watchEntries(DateRange range) {
    return _db
        .customSelect(
          _entriesSql,
          variables: [
            Variable.withDateTime(range.start),
            Variable.withDateTime(range.end),
          ],
          readsFrom: {_db.transactions, _db.accounts},
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              StatEntry(
                id: row.read<int>('id'),
                date: row.read<DateTime>('d'),
                type: TransactionType.values.byName(row.read<String>('type')),
                amount: row.read<int>('amount'),
                currency: row.read<String>('currency'),
                accountId: row.read<int>('account_id'),
                categoryId: row.readNullable<int>('category_id'),
                note: row.readNullable<String>('note'),
              ),
          ],
        );
  }

  /// Umumiy balans — valyutalar kesimida, `until` sanasigacha.
  Stream<Map<String, int>> watchTotalByCurrency({DateTime? until}) {
    return _db
        .customSelect(
          kTotalBalanceByCurrencyUntilSql,
          variables: [
            Variable.withDateTime(
              until ?? DateTime.now().add(const Duration(days: 36500)),
            ),
          ],
          readsFrom: {_db.accounts, _db.transactions},
        )
        .watch()
        .map(
          (rows) => {
            for (final row in rows)
              row.read<String>('currency'): row.read<int>('balance'),
          },
        );
  }
}

final statisticsRepositoryProvider = Provider<StatisticsRepository>(
  (ref) => StatisticsRepository(ref.watch(databaseProvider)),
);

final statEntriesProvider = StreamProvider.family<List<StatEntry>, DateRange>(
  (ref, range) =>
      ref.watch(statisticsRepositoryProvider).watchEntries(range),
  isAutoDispose: true,
);

/// Umumiy balans asosiy valyutada (kurslar bilan o'girilgan).
final totalBalanceProvider = StreamProvider<int>((ref) {
  final repo = ref.watch(statisticsRepositoryProvider);
  final converter = ref.watch(currencyConverterProvider).value;
  return repo.watchTotalByCurrency().map((byCurrency) {
    final conv = converter ?? CurrencyConverter.identity('UZS');
    var total = 0;
    byCurrency.forEach((currency, amount) {
      total += conv.toMain(amount, currency);
    });
    return total;
  });
});
