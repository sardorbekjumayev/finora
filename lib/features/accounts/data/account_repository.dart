import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/balance_sql.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/money.dart';

/// Hisob + joriy qoldiq. Qoldiq saqlanmaydi, SQL'da hisoblanadi.
@immutable
class AccountWithBalance {
  const AccountWithBalance({required this.account, required this.balance});

  final Account account;
  final int balance;

  int get id => account.id;
  String get name => account.name;
  Currency get currency => Currency.byCode(account.currency);

  @override
  bool operator ==(Object other) =>
      other is AccountWithBalance &&
      other.account == account &&
      other.balance == balance;

  @override
  int get hashCode => Object.hash(account, balance);
}

class AccountRepository {
  AccountRepository(this._db);

  final AppDatabase _db;

  /// Bitta so'rov: hisoblar va qoldiqlar birga keladi, shuning uchun
  /// tranzaksiya o'zgarsa ham stream qayta chiqadi.
  Stream<List<AccountWithBalance>> watchAccounts({
    bool includeArchived = false,
  }) {
    return _db
        .customSelect(
          kAccountsWithBalanceSql,
          variables: [Variable.withInt(includeArchived ? 1 : 0)],
          readsFrom: {_db.accounts, _db.transactions},
        )
        .watch()
        .map(
          (rows) => [
            for (final row in rows)
              AccountWithBalance(
                account: _db.accounts.map(row.data),
                balance: row.read<int>('balance'),
              ),
          ],
        );
  }

  Stream<AccountWithBalance?> watchAccount(int id) {
    return watchAccounts(includeArchived: true).map((list) {
      for (final item in list) {
        if (item.account.id == id) return item;
      }
      return null;
    });
  }

  Future<int> balanceOf(int accountId) async {
    final rows = await _db.customSelect(
      kAccountsWithBalanceSql,
      variables: [Variable.withInt(1)],
      readsFrom: {_db.accounts, _db.transactions},
    ).get();
    for (final row in rows) {
      if (row.read<int>('id') == accountId) return row.read<int>('balance');
    }
    return 0;
  }

  Future<int> create({
    required String name,
    required AccountType type,
    required String currency,
    required int initialBalance,
    required String iconKey,
    required int colorValue,
    bool includeInTotal = true,
  }) async {
    final maxOrder = await _db
        .customSelect(
          'SELECT COALESCE(MAX(sort_order), -1) AS m FROM accounts',
          readsFrom: {_db.accounts},
        )
        .getSingle();

    return _db.into(_db.accounts).insert(
          AccountsCompanion.insert(
            name: name,
            type: type,
            currency: currency,
            initialBalance: Value(initialBalance),
            iconKey: Value(iconKey),
            colorValue: colorValue,
            includeInTotal: Value(includeInTotal),
            sortOrder: Value(maxOrder.read<int>('m') + 1),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> update(Account account) =>
      _db.update(_db.accounts).replace(account);

  Future<void> setArchived(int id, {required bool archived}) {
    return (_db.update(_db.accounts)..where((t) => t.id.equals(id)))
        .write(AccountsCompanion(isArchived: Value(archived)));
  }

  /// Hisobni butunlay o'chirish. Tranzaksiyalari bo'lsa [AccountInUse]
  /// uloqtiradi — bu holatda arxivlash taklif qilinadi.
  Future<void> delete(int id) async {
    final used = await transactionCount(id);
    if (used > 0) throw AccountInUse(used);
    await (_db.delete(_db.accounts)..where((t) => t.id.equals(id))).go();
  }

  Future<int> transactionCount(int accountId) async {
    final row = await _db.customSelect(
      'SELECT COUNT(*) AS c FROM transactions '
      'WHERE account_id = ?1 OR to_account_id = ?1',
      variables: [Variable.withInt(accountId)],
      readsFrom: {_db.transactions},
    ).getSingle();
    return row.read<int>('c');
  }

  /// Drag-drop natijasini saqlash.
  Future<void> reorder(List<int> orderedIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.accounts)
              ..where((t) => t.id.equals(orderedIds[i])))
            .write(AccountsCompanion(sortOrder: Value(i)));
      }
    });
  }

  /// Balansni to'g'rilash: farqni "Tuzatish" tranzaksiyasi sifatida yozadi.
  /// Qaytaradi: yozilgan farq (minor unit); 0 — farq yo'q, yozuv qo'shilmadi.
  Future<int> reconcile({
    required int accountId,
    required int realBalance,
    required String note,
  }) async {
    final current = await balanceOf(accountId);
    final diff = realBalance - current;
    if (diff == 0) return 0;

    final now = DateTime.now();
    await _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            type: diff > 0 ? TransactionType.income : TransactionType.expense,
            amount: diff.abs(),
            accountId: accountId,
            date: now,
            note: Value(note),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return diff;
  }
}

/// Hisobda yozuvlar bor — o'chirish o'rniga arxivlash kerak.
class AccountInUse implements Exception {
  const AccountInUse(this.transactionCount);

  final int transactionCount;
}

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(ref.watch(databaseProvider)),
);

final accountsProvider = StreamProvider<List<AccountWithBalance>>(
  (ref) => ref.watch(accountRepositoryProvider).watchAccounts(),
);

final allAccountsProvider = StreamProvider<List<AccountWithBalance>>(
  (ref) =>
      ref.watch(accountRepositoryProvider).watchAccounts(includeArchived: true),
);

final accountByIdProvider = StreamProvider.family<AccountWithBalance?, int>(
  (ref, id) => ref.watch(accountRepositoryProvider).watchAccount(id),
  isAutoDispose: true,
);
