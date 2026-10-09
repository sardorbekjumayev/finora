import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/settings_service.dart';
import '../../../core/utils/date_range.dart';
import '../data/currency_converter.dart';
import '../data/statistics_repository.dart';
import '../domain/period_summary.dart';

/// Tanlangan davr. Sozlamalardagi "oyning boshlanish kuni" o'zgarsa,
/// davr avtomatik qayta hisoblanadi.
class PeriodController extends Notifier<DateRange> {
  @override
  DateRange build() {
    final settings = ref.watch(settingsProvider);
    return DateRange.month(
      DateTime.now(),
      monthStartDay: settings.monthStartDay,
    );
  }

  void setType(PeriodType type) {
    final settings = ref.read(settingsProvider);
    final anchor = state.start;
    state = switch (type) {
      PeriodType.day => DateRange.day(DateTime.now()),
      PeriodType.week => DateRange.week(
          DateTime.now(),
          weekStartsOn: settings.weekStartsOn,
        ),
      PeriodType.month => DateRange.month(
          DateTime.now(),
          monthStartDay: settings.monthStartDay,
        ),
      PeriodType.year => DateRange.year(
          DateTime.now(),
          monthStartDay: settings.monthStartDay,
        ),
      PeriodType.custom => DateRange.custom(anchor, state.end),
    };
  }

  void setCustom(DateTime from, DateTime to) =>
      state = DateRange.custom(from, to);

  void previous() => state = state.previous;

  void next() => state = state.next;

  /// Keyingi davrga o'tish mumkinmi (kelajakka chiqmaslik uchun).
  bool get canGoNext => state.end.isBefore(DateTime.now());
}

final periodProvider =
    NotifierProvider<PeriodController, DateRange>(PeriodController.new);

/// Davr bo'yicha xulosa. `null` — hali yuklanmoqda.
final periodSummaryProvider = Provider.family<PeriodSummary?, DateRange>(
  (ref, range) {
    final entries = ref.watch(statEntriesProvider(range)).value;
    if (entries == null) return null;
    final converter = ref.watch(currencyConverterProvider).value ??
        CurrencyConverter.identity(
          ref.watch(settingsProvider).mainCurrencyCode,
        );
    return PeriodSummary.build(
      range: range,
      entries: entries,
      converter: converter,
    );
  },
  isAutoDispose: true,
);

/// Joriy davr + oldingi davr (↑12% / ↓5% ko'rsatish uchun).
final periodComparisonProvider = Provider<PeriodComparison?>((ref) {
  final range = ref.watch(periodProvider);
  final current = ref.watch(periodSummaryProvider(range));
  final previous = ref.watch(periodSummaryProvider(range.previous));
  if (current == null || previous == null) return null;
  return PeriodComparison(current: current, previous: previous);
});

/// Davr boshidagi umumiy qoldiq — balans dinamikasi grafigi shu nuqtadan
/// boshlanadi. Asosiy valyutada.
final openingBalanceProvider = StreamProvider.family<int, DateTime>(
  (ref, until) {
    final repo = ref.watch(statisticsRepositoryProvider);
    final converter = ref.watch(currencyConverterProvider).value;
    final main = ref.watch(settingsProvider).mainCurrencyCode;

    return repo.watchTotalByCurrency(until: until).map((byCurrency) {
      final conv = converter ?? CurrencyConverter.identity(main);
      var total = 0;
      byCurrency.forEach((currency, amount) {
        total += conv.toMain(amount, currency);
      });
      return total;
    });
  },
  isAutoDispose: true,
);

/// Bosh sahifadagi "joriy oy" xulosasi — davr filtridan mustaqil.
final currentMonthSummaryProvider = Provider<PeriodSummary?>((ref) {
  final settings = ref.watch(settingsProvider);
  final range = DateRange.month(
    DateTime.now(),
    monthStartDay: settings.monthStartDay,
  );
  return ref.watch(periodSummaryProvider(range));
});
