import 'package:finora/core/database/enums.dart';
import 'package:finora/core/utils/date_range.dart';
import 'package:finora/features/statistics/data/currency_converter.dart';
import 'package:finora/features/statistics/data/statistics_repository.dart';
import 'package:finora/features/statistics/domain/period_summary.dart';
import 'package:flutter_test/flutter_test.dart';

/// Oktabr 2026 — barcha testlar uchun umumiy davr.
final _october = DateRange.month(DateTime(2026, 10, 15));

StatEntry _entry({
  required TransactionType type,
  required int amount,
  required DateTime date,
  int? categoryId,
  int accountId = 1,
  String currency = 'UZS',
  int id = 0,
}) {
  return StatEntry(
    id: id,
    date: date,
    type: type,
    amount: amount,
    currency: currency,
    accountId: accountId,
    categoryId: categoryId,
  );
}

PeriodSummary _build(
  List<StatEntry> entries, {
  DateRange? range,
  CurrencyConverter? converter,
}) {
  return PeriodSummary.build(
    range: range ?? _october,
    entries: entries,
    converter: converter ?? CurrencyConverter.identity('UZS'),
  );
}

void main() {
  test('yozuvsiz davr bo\'sh deb belgilanadi', () {
    final summary = _build([]);
    expect(summary.isEmpty, isTrue);
    expect(summary.income, 0);
    expect(summary.expense, 0);
    expect(summary.net, 0);
    expect(summary.savingsRate, isNull);
    expect(summary.topExpenseCategoryId, isNull);
  });

  test('kirim va chiqim alohida yig\'iladi', () {
    final summary = _build([
      _entry(
        type: TransactionType.income,
        amount: 500000000,
        date: DateTime(2026, 10, 5),
        categoryId: 10,
      ),
      _entry(
        type: TransactionType.expense,
        amount: 120000000,
        date: DateTime(2026, 10, 6),
        categoryId: 1,
      ),
      _entry(
        type: TransactionType.expense,
        amount: 30000000,
        date: DateTime(2026, 10, 7),
        categoryId: 2,
      ),
    ]);

    expect(summary.income, 500000000);
    expect(summary.expense, 150000000);
    expect(summary.net, 350000000);
    expect(summary.transactionCount, 3);
  });

  test('o\'tkazma kirim ham, chiqim ham emas', () {
    final summary = _build([
      _entry(
        type: TransactionType.transfer,
        amount: 100000000,
        date: DateTime(2026, 10, 5),
      ),
    ]);

    expect(summary.income, 0);
    expect(summary.expense, 0);
    // Yozuv bor — davr bo'sh emas, lekin summalarga ta'sir qilmaydi.
    expect(summary.transactionCount, 1);
    expect(summary.isEmpty, isFalse);
  });

  test('kategoriya ulushlari kamayish tartibida va foizi to\'g\'ri', () {
    final summary = _build([
      _entry(
        type: TransactionType.expense,
        amount: 25000000,
        date: DateTime(2026, 10, 5),
        categoryId: 1,
      ),
      _entry(
        type: TransactionType.expense,
        amount: 75000000,
        date: DateTime(2026, 10, 6),
        categoryId: 2,
      ),
    ]);

    final slices = summary.expenseByCategory;
    expect(slices.map((s) => s.categoryId), [2, 1]);
    expect(slices.first.share, closeTo(0.75, 1e-9));
    expect(slices.last.share, closeTo(0.25, 1e-9));
    expect(summary.topExpenseCategoryId, 2);
  });

  test('kategoriyasiz chiqim null kalit bilan guruhlanadi', () {
    final summary = _build([
      _entry(
        type: TransactionType.expense,
        amount: 10000000,
        date: DateTime(2026, 10, 5),
      ),
    ]);

    expect(summary.expenseByCategory.single.categoryId, isNull);
  });

  test('hisoblar bo\'yicha faqat chiqim hisoblanadi', () {
    final summary = _build([
      _entry(
        type: TransactionType.expense,
        amount: 40000000,
        date: DateTime(2026, 10, 5),
        accountId: 1,
      ),
      _entry(
        type: TransactionType.expense,
        amount: 10000000,
        date: DateTime(2026, 10, 6),
        accountId: 2,
      ),
      _entry(
        type: TransactionType.income,
        amount: 90000000,
        date: DateTime(2026, 10, 6),
        accountId: 2,
      ),
    ]);

    expect(summary.byAccount, {1: 40000000, 2: 10000000});
  });

  test('o\'rtacha kunlik chiqim davr kunlariga bo\'linadi', () {
    final range = DateRange.custom(
      DateTime(2026, 10),
      DateTime(2026, 10, 10),
    );
    final summary = _build(
      [
        _entry(
          type: TransactionType.expense,
          amount: 100000000,
          date: DateTime(2026, 10, 3),
        ),
      ],
      range: range,
    );

    expect(range.dayCount, 10);
    expect(summary.averageDailyExpense, 10000000);
  });

  test('jamg\'arma foizi (kirim − chiqim) / kirim', () {
    final summary = _build([
      _entry(
        type: TransactionType.income,
        amount: 100000000,
        date: DateTime(2026, 10, 5),
      ),
      _entry(
        type: TransactionType.expense,
        amount: 25000000,
        date: DateTime(2026, 10, 6),
      ),
    ]);

    expect(summary.savingsRate, closeTo(0.75, 1e-9));
  });

  test('eng katta kirim va chiqim topiladi', () {
    final summary = _build([
      _entry(
        type: TransactionType.expense,
        amount: 10000000,
        date: DateTime(2026, 10, 5),
        id: 1,
      ),
      _entry(
        type: TransactionType.expense,
        amount: 90000000,
        date: DateTime(2026, 10, 6),
        id: 2,
      ),
      _entry(
        type: TransactionType.income,
        amount: 50000000,
        date: DateTime(2026, 10, 7),
        id: 3,
      ),
    ]);

    expect(summary.biggestExpense?.id, 2);
    expect(summary.biggestIncome?.id, 3);
  });

  test('boshqa valyuta kurs bo\'yicha asosiy valyutaga o\'giriladi', () {
    final summary = _build(
      [
        _entry(
          type: TransactionType.expense,
          amount: 10000, // 100.00 USD
          date: DateTime(2026, 10, 5),
          currency: 'USD',
        ),
      ],
      converter: const CurrencyConverter(
        mainCurrency: 'UZS',
        rates: {'USD': 12500.0},
      ),
    );

    // 100 USD × 12 500 = 1 250 000 so'm (minor unit'da).
    expect(summary.expense, 125000000);
    expect(summary.currencies, {'USD'});
  });

  group('seriya (granularity)', () {
    test('kunlik davr 24 soatga bo\'linadi', () {
      final summary = _build(
        [
          _entry(
            type: TransactionType.expense,
            amount: 5000000,
            date: DateTime(2026, 10, 7, 13, 20),
          ),
        ],
        range: DateRange.day(DateTime(2026, 10, 7)),
      );

      expect(summary.granularity, SeriesGranularity.hour);
      expect(summary.series.length, 24);
      expect(summary.series[13].expense, 5000000);
      expect(summary.series[12].expense, 0);
    });

    test('oylik davr kunlarga bo\'linadi', () {
      final summary = _build(
        [
          _entry(
            type: TransactionType.income,
            amount: 7000000,
            date: DateTime(2026, 10, 3, 9),
          ),
        ],
        range: DateRange.month(DateTime(2026, 10, 15)),
      );

      expect(summary.granularity, SeriesGranularity.day);
      expect(summary.series.length, 31);
      expect(summary.series[2].income, 7000000);
    });

    test('yillik davr oylarga bo\'linadi', () {
      final summary = _build(
        [
          _entry(
            type: TransactionType.expense,
            amount: 4000000,
            date: DateTime(2026, 3, 18),
          ),
        ],
        range: DateRange.year(DateTime(2026, 6)),
      );

      expect(summary.granularity, SeriesGranularity.month);
      expect(summary.series.length, 12);
      expect(summary.series[2].expense, 4000000);
    });

    test('seriya jamlanmasi umumiy summaga teng', () {
      final summary = _build([
        _entry(
          type: TransactionType.income,
          amount: 30000000,
          date: DateTime(2026, 10, 2),
        ),
        _entry(
          type: TransactionType.expense,
          amount: 11000000,
          date: DateTime(2026, 10, 20),
        ),
      ]);

      final income =
          summary.series.fold(0, (sum, point) => sum + point.income);
      final expense =
          summary.series.fold(0, (sum, point) => sum + point.expense);
      expect(income, summary.income);
      expect(expense, summary.expense);
    });
  });

  group('PeriodComparison', () {
    test('o\'sish va kamayish foizi', () {
      final previous = _build([
        _entry(
          type: TransactionType.expense,
          amount: 100000000,
          date: DateTime(2026, 9, 10),
        ),
      ], range: _october.previous);
      final current = _build([
        _entry(
          type: TransactionType.expense,
          amount: 125000000,
          date: DateTime(2026, 10, 10),
        ),
      ]);

      final comparison =
          PeriodComparison(current: current, previous: previous);
      expect(comparison.expenseChange, closeTo(0.25, 1e-9));
      expect(comparison.incomeChange, isNull);
    });

    test('oldingi davrda nol bo\'lsa foiz hisoblanmaydi', () {
      final comparison = PeriodComparison(
        current: _build([
          _entry(
            type: TransactionType.expense,
            amount: 5000000,
            date: DateTime(2026, 10, 2),
          ),
        ]),
        previous: _build([], range: _october.previous),
      );
      expect(comparison.expenseChange, isNull);
    });
  });
}
