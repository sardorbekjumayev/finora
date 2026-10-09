import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../l10n/generated/app_localizations.dart';
import 'date_range.dart';

/// Sana sarlavhalari. `intl` locale'i `MaterialApp`dagi til bilan mos keladi.
class DateLabels {
  const DateLabels._();

  static String _locale(BuildContext context) =>
      Localizations.localeOf(context).toLanguageTag();

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Yozuvlar ro'yxatidagi kun sarlavhasi: "Bugun", "Kecha" yoki
  /// "12 oktabr, dushanba".
  static String dayHeader(BuildContext context, DateTime date) {
    final l10n = AppL10n.of(context);
    final now = DateTime.now();
    if (isSameDay(date, now)) return l10n.labelToday;
    if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return l10n.labelYesterday;
    }
    final pattern = date.year == now.year ? 'd MMMM, EEEE' : 'd MMMM y, EEEE';
    return _capitalize(DateFormat(pattern, _locale(context)).format(date));
  }

  static String shortDate(BuildContext context, DateTime date) =>
      DateFormat('d MMM y', _locale(context)).format(date);

  static String dayMonth(BuildContext context, DateTime date) =>
      DateFormat('d MMM', _locale(context)).format(date);

  static String time(BuildContext context, DateTime date) =>
      DateFormat.Hm(_locale(context)).format(date);

  static String dateTime(BuildContext context, DateTime date) =>
      '${shortDate(context, date)}, ${time(context, date)}';

  static String monthYear(BuildContext context, DateTime date) =>
      _capitalize(DateFormat('LLLL y', _locale(context)).format(date));

  static String monthShort(BuildContext context, DateTime date) =>
      _capitalize(DateFormat('LLL', _locale(context)).format(date));

  static String weekdayShort(BuildContext context, DateTime date) =>
      _capitalize(DateFormat('E', _locale(context)).format(date));

  /// Davr sarlavhasi: "Oktabr 2026", "5–11 okt", "Bugun"...
  static String rangeLabel(BuildContext context, DateRange range) {
    final l10n = AppL10n.of(context);
    final lastDay = range.end.subtract(const Duration(days: 1));

    switch (range.type) {
      case PeriodType.day:
        if (isSameDay(range.start, DateTime.now())) return l10n.labelToday;
        return shortDate(context, range.start);
      case PeriodType.week:
        return '${dayMonth(context, range.start)} – '
            '${dayMonth(context, lastDay)}';
      case PeriodType.month:
        if (range.start.day == 1) return monthYear(context, range.start);
        return '${dayMonth(context, range.start)} – '
            '${dayMonth(context, lastDay)}';
      case PeriodType.year:
        return DateFormat('y', _locale(context)).format(range.start);
      case PeriodType.custom:
        return '${shortDate(context, range.start)} – '
            '${shortDate(context, lastDay)}';
    }
  }

  static String _capitalize(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}
