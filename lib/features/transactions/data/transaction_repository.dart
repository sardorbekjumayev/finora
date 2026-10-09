import 'package:drift/drift.dart';
// `Category` nomi flutter/foundation'dagi annotatsiya bilan to'qnashadi.
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/utils/money.dart';
import 'transaction_filter.dart';

/// Ro'yxatda ko'rsatish uchun to'liq yozuv: hisob va kategoriya bilan.
@immutable
class TxWithRefs {
  const TxWithRefs({
    required this.tx,
    required this.account,
    this.toAccount,
    this.category,
  });

  final TxEntry tx;
  final Account account;
  final Account? toAccount;
  final Category? category;

  Currency get currency => Currency.byCode(account.currency);

  Currency get toCurrency =>
      Currency.byCode(toAccount?.currency ?? account.currency);

  /// O'tkazmada qabul qiluvchi hisobga tushadigan summa.
  int get receivedAmount =>
      Money.convert(tx.amount, tx.transferRate ?? 1.0);

  bool get isCrossCurrency =>
      toAccount != null && toAccount!.currency != account.currency;

  @override
  bool operator ==(Object other) =>
      other is TxWithRefs &&
      other.tx == tx &&
      other.account == account &&
      other.toAccount == toAccount &&
      other.category == category;

  @override
  int get hashCode => Object.hash(tx, account, toAccount, category);
}

/// Yangi yozuv / tahrirlash uchun kiruvchi ma'lumot.
@immutable
class TxDraft {
  const TxDraft({
    required this.type,
    required this.amount,
    required this.accountId,
    required this.date,
    this.toAccountId,
    this.categoryId,
    this.note,
    this.transferRate,
  });

  final TransactionType type;
  final int amount;
  final int accountId;
  final int? toAccountId;
  final int? categoryId;
  final DateTime date;
  final String? note;
  final double? transferRate;
}

class TransactionRepository {
  TransactionRepository(this._db);

  final AppDatabase _db;

  Stream<List<TxWithRefs>> watchFiltered(
    TransactionFilter filter, {
    int? limit,
  }) {
    final toAccounts = _db.alias(_db.accounts, 'to_acc');

    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.accounts,
        _db.accounts.id.equalsExp(_db.transactions.accountId),
      ),
      leftOuterJoin(
        toAccounts,
        toAccounts.id.equalsExp(_db.transactions.toAccountId),
      ),
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ]);

    final range = filter.range;
    if (range != null) {
      query.where(
        _db.transactions.date.isBiggerOrEqualValue(range.start) &
            _db.transactions.date.isSmallerThanValue(range.end),
      );
    }
    if (filter.types.isNotEmpty) {
      query.where(
        _db.transactions.type
            .isIn(filter.types.map((t) => t.name).toList(growable: false)),
      );
    }
    if (filter.accountIds.isNotEmpty) {
      final ids = filter.accountIds.toList(growable: false);
      query.where(
        _db.transactions.accountId.isIn(ids) |
            _db.transactions.toAccountId.isIn(ids),
      );
    }
    if (filter.categoryIds.isNotEmpty) {
      query.where(
        _db.transactions.categoryId
            .isIn(filter.categoryIds.toList(growable: false)),
      );
    }
    if (filter.minAmount != null) {
      query.where(_db.transactions.amount
          .isBiggerOrEqualValue(filter.minAmount!));
    }
    if (filter.maxAmount != null) {
      query.where(
        _db.transactions.amount.isSmallerOrEqualValue(filter.maxAmount!),
      );
    }
    final text = filter.query.trim();
    if (text.isNotEmpty) {
      final pattern = '%${text.toLowerCase()}%';
      query.where(
        _db.transactions.note.lower().like(pattern) |
            _db.categories.name.lower().like(pattern) |
            _db.accounts.name.lower().like(pattern),
      );
    }

    query.orderBy(switch (filter.sort) {
      TxSort.dateDesc => [
          OrderingTerm.desc(_db.transactions.date),
          OrderingTerm.desc(_db.transactions.id),
        ],
      TxSort.dateAsc => [
          OrderingTerm.asc(_db.transactions.date),
          OrderingTerm.asc(_db.transactions.id),
        ],
      TxSort.amountDesc => [OrderingTerm.desc(_db.transactions.amount)],
      TxSort.amountAsc => [OrderingTerm.asc(_db.transactions.amount)],
    });

    if (limit != null) query.limit(limit);

    return query.watch().map(
          (rows) => [
            for (final row in rows)
              TxWithRefs(
                tx: row.readTable(_db.transactions),
                account: row.readTable(_db.accounts),
                toAccount: row.readTableOrNull(toAccounts),
                category: row.readTableOrNull(_db.categories),
              ),
          ],
        );
  }

  Stream<List<TxWithRefs>> watchRecent({int limit = 10}) =>
      watchFiltered(const TransactionFilter(), limit: limit);

  Stream<TxWithRefs?> watchById(int id) {
    final toAccounts = _db.alias(_db.accounts, 'to_acc');
    final query = _db.select(_db.transactions).join([
      innerJoin(
        _db.accounts,
        _db.accounts.id.equalsExp(_db.transactions.accountId),
      ),
      leftOuterJoin(
        toAccounts,
        toAccounts.id.equalsExp(_db.transactions.toAccountId),
      ),
      leftOuterJoin(
        _db.categories,
        _db.categories.id.equalsExp(_db.transactions.categoryId),
      ),
    ])
      ..where(_db.transactions.id.equals(id));

    return query.watchSingleOrNull().map(
          (row) => row == null
              ? null
              : TxWithRefs(
                  tx: row.readTable(_db.transactions),
                  account: row.readTable(_db.accounts),
                  toAccount: row.readTableOrNull(toAccounts),
                  category: row.readTableOrNull(_db.categories),
                ),
        );
  }

  Future<TxWithRefs?> getById(int id) => watchById(id).first;

  Future<int> create(TxDraft draft) {
    final now = DateTime.now();
    return _db.into(_db.transactions).insert(
          TransactionsCompanion.insert(
            type: draft.type,
            amount: draft.amount,
            accountId: draft.accountId,
            toAccountId: Value(draft.toAccountId),
            categoryId: Value(draft.categoryId),
            date: draft.date,
            note: Value(draft.note),
            transferRate: Value(draft.transferRate),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> updateDraft(int id, TxDraft draft) {
    return (_db.update(_db.transactions)..where((t) => t.id.equals(id)))
        .write(
      TransactionsCompanion(
        type: Value(draft.type),
        amount: Value(draft.amount),
        accountId: Value(draft.accountId),
        toAccountId: Value(draft.toAccountId),
        categoryId: Value(draft.categoryId),
        date: Value(draft.date),
        note: Value(draft.note),
        transferRate: Value(draft.transferRate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// O'chirilgan yozuvni qaytaradi — Snackbar "Bekor qilish" uchun.
  Future<TxEntry?> delete(int id) async {
    final existing = await (_db.select(_db.transactions)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) return null;
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
    return existing;
  }

  /// "Bekor qilish" — o'chirilgan yozuvni aynan o'sha `id` bilan tiklaydi.
  Future<void> restore(TxEntry entry) =>
      _db.into(_db.transactions).insert(entry, mode: InsertMode.insertOrReplace);

  Future<int> countAll() async {
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS c FROM transactions',
          readsFrom: {_db.transactions},
        )
        .getSingle();
    return row.read<int>('c');
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(ref.watch(databaseProvider)),
);

final recentTransactionsProvider = StreamProvider<List<TxWithRefs>>(
  (ref) => ref.watch(transactionRepositoryProvider).watchRecent(),
);

final filteredTransactionsProvider =
    StreamProvider.family<List<TxWithRefs>, TransactionFilter>(
  (ref, filter) =>
      ref.watch(transactionRepositoryProvider).watchFiltered(filter),
  isAutoDispose: true,
);

final transactionCountProvider = FutureProvider<int>(
  (ref) => ref.watch(transactionRepositoryProvider).countAll(),
);

final transactionByIdProvider = StreamProvider.family<TxWithRefs?, int>(
  (ref, id) => ref.watch(transactionRepositoryProvider).watchById(id),
  isAutoDispose: true,
);
