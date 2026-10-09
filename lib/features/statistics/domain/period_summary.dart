import 'package:flutter/foundation.dart';

import '../../../core/database/enums.dart';
import '../../../core/utils/date_range.dart';
import '../data/currency_converter.dart';
import '../data/statistics_repository.dart';

enum SeriesGranularity { hour, day, month }

@immutable
class CategorySlice {
  const CategorySlice({
    required this.categoryId,
    required this.amount,
    required this.share,
  });

  /// `null` — "Kategoriyasiz".
  final int? categoryId;
  final int amount;

  /// 0.0–1.0
  final double share;
}

@immutable
class SeriesPoint {
  const SeriesPoint({
    required this.start,
    required this.income,
    required this.expense,
  });

  final DateTime start;
  final int income;
  final int expense;

  int get net => income - expense;
}

/// Davr bo'yicha barcha ko'rsatkichlar. Hammasi asosiy valyutada.
@immutable
class PeriodSummary {
  const PeriodSummary({
    required this.range,
    required this.income,
    required this.expense,
    required this.transactionCount,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.byAccount,
    required this.series,
    required this.granularity,
    required this.currencies,
    this.biggestExpense,
    this.biggestIncome,
  });

  final DateRange range;
  final int income;
  final int expense;
  final int transactionCount;
  final List<CategorySlice> expenseByCategory;
  final List<CategorySlice> incomeByCategory;
  final Map<int, int> byAccount;
  final List<SeriesPoint> series;
  final SeriesGranularity granularity;

  /// Davrda uchragan valyutalar — kurs yetishmasa ogohlantirish uchun.
  final Set<String> currencies;

  final StatEntry? biggestExpense;
  final StatEntry? biggestIncome;

  int get net => income - expense;

  bool get isEmpty => transactionCount == 0;

  /// O'rtacha kunlik chiqim.
  int get averageDailyExpense =>
      range.dayCount == 0 ? 0 : (expense / range.dayCount).round();

  /// Jamg'arma foizi: (kirim − chiqim) / kirim.
  double? get savingsRate => income == 0 ? null : net / income;

  int? get topExpenseCategoryId =>
      expenseByCategory.isEmpty ? null : expenseByCategory.first.categoryId;

  static PeriodSummary build({
    required DateRange range,
    required List<StatEntry> entries,
    required CurrencyConverter converter,
    SeriesGranularity? granularity,
  }) {
    final gran = granularity ?? _granularityFor(range);

    var income = 0;
    var expense = 0;
    final expenseByCat = <int?, int>{};
    final incomeByCat = <int?, int>{};
    final byAccount = <int, int>{};
    final currencies = <String>{};
    StatEntry? biggestExpense;
    StatEntry? biggestIncome;
    var biggestExpenseValue = 0;
    var biggestIncomeValue = 0;

    final buckets = _buildBuckets(range, gran);
    final bucketIncome = List<int>.filled(buckets.length, 0);
    final bucketExpense = List<int>.filled(buckets.length, 0);

    for (final entry in entries) {
      currencies.add(entry.currency);
      // O'tkazma kirim ham, chiqim ham emas — faqat pul joyini o'zgartiradi.
      if (entry.type == TransactionType.transfer) continue;

      final value = converter.toMain(entry.amount, entry.currency);
      final index = _bucketIndex(buckets, entry.date);

      if (entry.type == TransactionType.income) {
        income += value;
        incomeByCat.update(entry.categoryId, (v) => v + value,
            ifAbsent: () => value);
        if (index >= 0) bucketIncome[index] += value;
        if (value > biggestIncomeValue) {
          biggestIncomeValue = value;
          biggestIncome = entry;
        }
      } else {
        expense += value;
        expenseByCat.update(entry.categoryId, (v) => v + value,
            ifAbsent: () => value);
        byAccount.update(entry.accountId, (v) => v + value,
            ifAbsent: () => value);
        if (index >= 0) bucketExpense[index] += value;
        if (value > biggestExpenseValue) {
          biggestExpenseValue = value;
          biggestExpense = entry;
        }
      }
    }

    return PeriodSummary(
      range: range,
      income: income,
      expense: expense,
      transactionCount: entries.length,
      expenseByCategory: _toSlices(expenseByCat, expense),
      incomeByCategory: _toSlices(incomeByCat, income),
      byAccount: byAccount,
      granularity: gran,
      currencies: currencies,
      biggestExpense: biggestExpense,
      biggestIncome: biggestIncome,
      series: [
        for (var i = 0; i < buckets.length; i++)
          SeriesPoint(
            start: buckets[i],
            income: bucketIncome[i],
            expense: bucketExpense[i],
          ),
      ],
    );
  }

  static List<CategorySlice> _toSlices(Map<int?, int> map, int total) {
    final slices = [
      for (final e in map.entries)
        CategorySlice(
          categoryId: e.key,
          amount: e.value,
          share: total == 0 ? 0 : e.value / total,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));
    return slices;
  }

  static SeriesGranularity _granularityFor(DateRange range) {
    switch (range.type) {
      case PeriodType.day:
        return SeriesGranularity.hour;
      case PeriodType.week:
      case PeriodType.month:
        return SeriesGranularity.day;
      case PeriodType.year:
        return SeriesGranularity.month;
      case PeriodType.custom:
        return range.dayCount > 62
            ? SeriesGranularity.month
            : SeriesGranularity.day;
    }
  }

  static List<DateTime> _buildBuckets(
    DateRange range,
    SeriesGranularity gran,
  ) {
    final buckets = <DateTime>[];
    switch (gran) {
      case SeriesGranularity.hour:
        for (var h = 0; h < 24; h++) {
          buckets.add(range.start.add(Duration(hours: h)));
        }
      case SeriesGranularity.day:
        var cursor = DateTime(
          range.start.year,
          range.start.month,
          range.start.day,
        );
        while (cursor.isBefore(range.end)) {
          buckets.add(cursor);
          cursor = DateTime(cursor.year, cursor.month, cursor.day + 1);
        }
      case SeriesGranularity.month:
        var cursor = DateTime(range.start.year, range.start.month);
        while (cursor.isBefore(range.end)) {
          buckets.add(cursor);
          cursor = DateTime(cursor.year, cursor.month + 1);
        }
    }
    return buckets;
  }

  static int _bucketIndex(List<DateTime> buckets, DateTime moment) {
    if (buckets.isEmpty) return -1;
    var low = 0;
    var high = buckets.length - 1;
    var result = -1;
    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (!buckets[mid].isAfter(moment)) {
        result = mid;
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }
    return result;
  }
}

/// Oldingi davr bilan solishtirish natijasi.
@immutable
class PeriodComparison {
  const PeriodComparison({required this.current, required this.previous});

  final PeriodSummary current;
  final PeriodSummary previous;

  /// Chiqimning o'zgarish foizi. `null` — oldingi davrda chiqim bo'lmagan.
  double? get expenseChange => _change(previous.expense, current.expense);

  double? get incomeChange => _change(previous.income, current.income);

  static double? _change(int before, int after) {
    if (before == 0) return null;
    return (after - before) / before;
  }
}
