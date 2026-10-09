import 'package:drift/native.dart';
import 'package:finora/core/database/app_database.dart';
import 'package:finora/features/accounts/data/account_repository.dart';
import 'package:finora/features/transactions/data/transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late AccountRepository accounts;
  late TransactionRepository transactions;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    accounts = AccountRepository(db);
    transactions = TransactionRepository(db);
  });

  tearDown(() => db.close());

  Future<int> cash({int initial = 0, String currency = 'UZS'}) {
    return accounts.create(
      name: 'Naqd',
      type: AccountType.cash,
      currency: currency,
      initialBalance: initial,
      iconKey: 'cash',
      colorValue: 0xFF1C6758,
    );
  }

  Future<int> card({int initial = 0, String currency = 'UZS'}) {
    return accounts.create(
      name: 'Uzcard',
      type: AccountType.card,
      currency: currency,
      initialBalance: initial,
      iconKey: 'card',
      colorValue: 0xFF1B5FBF,
    );
  }

  Future<int> addTx({
    required TransactionType type,
    required int amount,
    required int accountId,
    int? toAccountId,
    double? transferRate,
    DateTime? date,
  }) {
    return transactions.create(
      TxDraft(
        type: type,
        amount: amount,
        accountId: accountId,
        toAccountId: toAccountId,
        transferRate: transferRate,
        date: date ?? DateTime(2026, 10, 7, 12),
      ),
    );
  }

  group('balans faqat yozuvlardan hisoblanadi', () {
    test('boshlang\'ich qoldiq o\'zi balansni beradi', () async {
      final id = await cash(initial: 50000000);
      expect(await accounts.balanceOf(id), 50000000);
    });

    test('kirim qo\'shiladi, chiqim ayiriladi', () async {
      final id = await cash(initial: 10000000);
      await addTx(
        type: TransactionType.income,
        amount: 5000000,
        accountId: id,
      );
      await addTx(
        type: TransactionType.expense,
        amount: 2000000,
        accountId: id,
      );

      expect(await accounts.balanceOf(id), 13000000);
    });

    test('o\'tkazma bir hisobdan chiqib ikkinchisiga kiradi', () async {
      final from = await cash(initial: 10000000);
      final to = await card();

      await addTx(
        type: TransactionType.transfer,
        amount: 4000000,
        accountId: from,
        toAccountId: to,
      );

      expect(await accounts.balanceOf(from), 6000000);
      expect(await accounts.balanceOf(to), 4000000);
    });

    test('valyutalar orasidagi o\'tkazma kurs bo\'yicha tushadi', () async {
      final usd = await cash(initial: 100000, currency: 'USD');
      final uzs = await card(currency: 'UZS');

      // 100 USD → 12 500 kurs bo'yicha 1 250 000 so'm.
      await addTx(
        type: TransactionType.transfer,
        amount: 10000,
        accountId: usd,
        toAccountId: uzs,
        transferRate: 12500,
      );

      expect(await accounts.balanceOf(usd), 90000);
      expect(await accounts.balanceOf(uzs), 125000000);
    });

    test('yozuv o\'chirilganda balans qayta to\'g\'ri hisoblanadi', () async {
      final id = await cash(initial: 10000000);
      final txId = await addTx(
        type: TransactionType.expense,
        amount: 3000000,
        accountId: id,
      );
      expect(await accounts.balanceOf(id), 7000000);

      await transactions.delete(txId);
      expect(await accounts.balanceOf(id), 10000000);
    });

    test('yozuv tahrirlanganda balans yangilanadi', () async {
      final id = await cash(initial: 10000000);
      final txId = await addTx(
        type: TransactionType.expense,
        amount: 3000000,
        accountId: id,
      );

      await transactions.updateDraft(
        txId,
        TxDraft(
          type: TransactionType.expense,
          amount: 8000000,
          accountId: id,
          date: DateTime(2026, 10, 7, 12),
        ),
      );
      expect(await accounts.balanceOf(id), 2000000);

      // Turi kirimga o'zgarsa, belgisi ham o'zgaradi.
      await transactions.updateDraft(
        txId,
        TxDraft(
          type: TransactionType.income,
          amount: 8000000,
          accountId: id,
          date: DateTime(2026, 10, 7, 12),
        ),
      );
      expect(await accounts.balanceOf(id), 18000000);
    });

    test('o\'chirilgan yozuvni tiklash balansni qaytaradi', () async {
      final id = await cash(initial: 10000000);
      final txId = await addTx(
        type: TransactionType.expense,
        amount: 3000000,
        accountId: id,
      );

      final removed = await transactions.delete(txId);
      expect(removed, isNotNull);
      expect(await accounts.balanceOf(id), 10000000);

      await transactions.restore(removed!);
      expect(await accounts.balanceOf(id), 7000000);
    });

    test('manfiy balansga ruxsat beriladi', () async {
      final id = await card();
      await addTx(
        type: TransactionType.expense,
        amount: 5000000,
        accountId: id,
      );
      expect(await accounts.balanceOf(id), -5000000);
    });
  });

  group('watchAccounts', () {
    test('qoldiq hisob bilan birga keladi', () async {
      final id = await cash(initial: 20000000);
      await addTx(
        type: TransactionType.income,
        amount: 5000000,
        accountId: id,
      );

      final list = await accounts.watchAccounts().first;
      expect(list, hasLength(1));
      expect(list.single.id, id);
      expect(list.single.balance, 25000000);
    });

    test('arxivlangan hisob standart ro\'yxatga kirmaydi', () async {
      final id = await cash(initial: 1000);
      await accounts.setArchived(id, archived: true);

      expect(await accounts.watchAccounts().first, isEmpty);
      expect(
        await accounts.watchAccounts(includeArchived: true).first,
        hasLength(1),
      );
    });

    test('tartib sort_order bo\'yicha va reorder bilan o\'zgaradi', () async {
      final first = await cash();
      final second = await card();

      var list = await accounts.watchAccounts().first;
      expect(list.map((a) => a.id), [first, second]);

      await accounts.reorder([second, first]);
      list = await accounts.watchAccounts().first;
      expect(list.map((a) => a.id), [second, first]);
    });
  });

  group('reconcile', () {
    test('farqni tuzatish yozuvi sifatida yozadi', () async {
      final id = await cash(initial: 10000000);

      final diff = await accounts.reconcile(
        accountId: id,
        realBalance: 12000000,
        note: 'Balansni to\'g\'rilash',
      );

      expect(diff, 2000000);
      expect(await accounts.balanceOf(id), 12000000);
      expect(await transactions.countAll(), 1);
    });

    test('haqiqiy qoldiq kamroq bo\'lsa chiqim yoziladi', () async {
      final id = await cash(initial: 10000000);

      final diff = await accounts.reconcile(
        accountId: id,
        realBalance: 7000000,
        note: 'tuzatish',
      );

      expect(diff, -3000000);
      expect(await accounts.balanceOf(id), 7000000);

      final tx = await transactions.watchRecent().first;
      expect(tx.single.tx.type, TransactionType.expense);
      expect(tx.single.tx.amount, 3000000);
    });

    test('farq yo\'q bo\'lsa yozuv qo\'shilmaydi', () async {
      final id = await cash(initial: 10000000);

      final diff = await accounts.reconcile(
        accountId: id,
        realBalance: 10000000,
        note: 'tuzatish',
      );

      expect(diff, 0);
      expect(await transactions.countAll(), 0);
    });
  });

  group('hisobni o\'chirish', () {
    test('yozuvi bor hisob o\'chirilmaydi', () async {
      final id = await cash();
      await addTx(
        type: TransactionType.expense,
        amount: 1000,
        accountId: id,
      );

      await expectLater(
        accounts.delete(id),
        throwsA(isA<AccountInUse>()),
      );
    });

    test('bo\'sh hisob o\'chiriladi', () async {
      final id = await cash();
      await accounts.delete(id);
      expect(await accounts.watchAccounts(includeArchived: true).first, isEmpty);
    });

    test('o\'tkazmaning qabul qiluvchisi ham hisoblanadi', () async {
      final from = await cash(initial: 5000);
      final to = await card();
      await addTx(
        type: TransactionType.transfer,
        amount: 1000,
        accountId: from,
        toAccountId: to,
      );

      expect(await accounts.transactionCount(to), 1);
      await expectLater(
        accounts.delete(to),
        throwsA(isA<AccountInUse>()),
      );
    });
  });

  group('indekslar', () {
    test('yaratilganda tranzaksiya indekslari qo\'shiladi', () async {
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'index' "
            "AND name LIKE 'idx_tx_%'",
          )
          .get();
      final names = rows.map((r) => r.read<String>('name')).toSet();

      expect(
        names,
        containsAll(<String>[
          'idx_tx_date',
          'idx_tx_account',
          'idx_tx_category',
        ]),
      );
    });
  });

  test('wipeEverything hamma jadvalni bo\'shatadi', () async {
    final id = await cash(initial: 1000);
    await addTx(
      type: TransactionType.income,
      amount: 500,
      accountId: id,
    );

    await db.wipeEverything();

    expect(await transactions.countAll(), 0);
    expect(await accounts.watchAccounts(includeArchived: true).first, isEmpty);
  });
}
