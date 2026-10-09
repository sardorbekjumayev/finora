import 'package:flutter/material.dart';

enum PeriodType { day, week, month, year, custom }

/// Statistika va ro'yxatlar uchun davr. `end` — **eksklyuziv**.
@immutable
class DateRange {
  const DateRange({
    required this.start,
    required this.end,
    required this.type,
  });

  final DateTime start;
  final DateTime end;
  final PeriodType type;

  bool contains(DateTime moment) =>
      !moment.isBefore(start) && moment.isBefore(end);

  Duration get length => end.difference(start);

  int get dayCount => (end.difference(start).inHours / 24).round().clamp(1, 1 << 30);

  /// Oldingi davr — solishtirish uchun (↑12% / ↓5%).
  DateRange get previous => shift(-1);

  DateRange get next => shift(1);

  DateRange shift(int steps) {
    switch (type) {
      case PeriodType.day:
        final s = start.add(Duration(days: steps));
        return DateRange(start: s, end: s.add(const Duration(days: 1)), type: type);
      case PeriodType.week:
        final s = start.add(Duration(days: 7 * steps));
        return DateRange(start: s, end: s.add(const Duration(days: 7)), type: type);
      case PeriodType.month:
        final s = DateTime(start.year, start.month + steps, start.day);
        final e = DateTime(end.year, end.month + steps, end.day);
        return DateRange(start: s, end: e, type: type);
      case PeriodType.year:
        final s = DateTime(start.year + steps, start.month, start.day);
        final e = DateTime(end.year + steps, end.month, end.day);
        return DateRange(start: s, end: e, type: type);
      case PeriodType.custom:
        final delta = Duration(days: dayCount * steps);
        return DateRange(start: start.add(delta), end: end.add(delta), type: type);
    }
  }

  static DateRange day(DateTime anchor) {
    final s = DateTime(anchor.year, anchor.month, anchor.day);
    return DateRange(
      start: s,
      end: s.add(const Duration(days: 1)),
      type: PeriodType.day,
    );
  }

  /// `weekStartsOn` — `DateTime.monday` (1) yoki `DateTime.sunday` (7).
  static DateRange week(DateTime anchor, {int weekStartsOn = DateTime.monday}) {
    final day = DateTime(anchor.year, anchor.month, anchor.day);
    final diff = (day.weekday - weekStartsOn + 7) % 7;
    final s = day.subtract(Duration(days: diff));
    return DateRange(
      start: s,
      end: s.add(const Duration(days: 7)),
      type: PeriodType.week,
    );
  }

  /// `monthStartDay` — moliyaviy oyning boshlanish kuni (1–28).
  /// Masalan maosh 5-sanada bo'lsa, oy 5-dan boshlanadi.
  static DateRange month(DateTime anchor, {int monthStartDay = 1}) {
    final startDay = monthStartDay.clamp(1, 28);
    final DateTime s;
    if (anchor.day >= startDay) {
      s = DateTime(anchor.year, anchor.month, startDay);
    } else {
      s = DateTime(anchor.year, anchor.month - 1, startDay);
    }
    return DateRange(
      start: s,
      end: DateTime(s.year, s.month + 1, s.day),
      type: PeriodType.month,
    );
  }

  static DateRange year(DateTime anchor, {int monthStartDay = 1}) {
    final startDay = monthStartDay.clamp(1, 28);
    final s = DateTime(anchor.year, 1, startDay);
    return DateRange(
      start: s,
      end: DateTime(s.year + 1, 1, startDay),
      type: PeriodType.year,
    );
  }

  static DateRange custom(DateTime from, DateTime to) {
    final s = DateTime(from.year, from.month, from.day);
    final e = DateTime(to.year, to.month, to.day).add(const Duration(days: 1));
    return DateRange(start: s, end: e, type: PeriodType.custom);
  }

  @override
  bool operator ==(Object other) =>
      other is DateRange &&
      other.start == start &&
      other.end == end &&
      other.type == type;

  @override
  int get hashCode => Object.hash(start, end, type);

  @override
  String toString() => 'DateRange(${type.name}, $start → $end)';
}
