import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// Generatsiya qilingan `part` fayl enum turlarini kutadi — ular shu
// kutubxona ko'lamida bo'lishi uchun import ham, eksport ham kerak.
import 'enums.dart';
import 'tables/accounts.dart';
import 'tables/budgets.dart';
import 'tables/categories.dart';
import 'tables/debts.dart';
import 'tables/goals.dart';
import 'tables/misc.dart';
import 'tables/recurring_rules.dart';
import 'tables/tags.dart';
import 'tables/transactions.dart';

export 'enums.dart';
export 'tables/accounts.dart';
export 'tables/budgets.dart';
export 'tables/categories.dart';
export 'tables/debts.dart';
export 'tables/goals.dart';
export 'tables/misc.dart';
export 'tables/recurring_rules.dart';
export 'tables/tags.dart';
export 'tables/transactions.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Transactions,
    Tags,
    TransactionTags,
    Budgets,
    Goals,
    GoalContributions,
    Debts,
    DebtPayments,
    RecurringRules,
    ExchangeRates,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'finora'));

  /// Testlar uchun (in-memory yoki boshqa executor).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // Cascade/`references` ishlashi uchun har ulanishda yoqiladi.
          await customStatement('PRAGMA foreign_keys = ON');
          if (details.wasCreated) {
            await _createIndexes();
          }
        },
        onCreate: (m) async {
          await m.createAll();
        },
      );

  Future<void> _createIndexes() async {
    // 10 000+ tranzaksiyada ro'yxat va statistika tez ishlashi uchun.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tx_date ON transactions (date_time)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tx_account ON transactions (account_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tx_to_account '
      'ON transactions (to_account_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tx_category ON transactions (category_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tx_type_date '
      'ON transactions (type, date_time)',
    );
  }

  /// Hamma ma'lumotni o'chirish (Sozlamalar → "Barcha ma'lumotni o'chirish").
  Future<void> wipeEverything() async {
    await transaction(() async {
      for (final table in allTables.toList().reversed) {
        await delete(table).go();
      }
    });
  }
}
