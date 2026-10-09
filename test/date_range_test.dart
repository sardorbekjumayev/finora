import 'package:finora/core/utils/date_range.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateRange.day', () {
    test('kun yarim kechadan boshlanadi va bir kun davom etadi', () {
      final range = DateRange.day(DateTime(2026, 10, 7, 14, 30));
      expect(range.start, DateTime(2026, 10, 7));
      expect(range.end, DateTime(2026, 10, 8));
      expect(range.dayCount, 1);
    });

    test('contains chegaralari: boshi kiradi, oxiri kirmaydi', () {
      final range = DateRange.day(DateTime(2026, 10, 7));
      expect(range.contains(DateTime(2026, 10, 7)), isTrue);
      expect(range.contains(DateTime(2026, 10, 7, 23, 59, 59)), isTrue);
      expect(range.contains(DateTime(2026, 10, 8)), isFalse);
      expect(range.contains(DateTime(2026, 10, 6, 23, 59)), isFalse);
    });
  });

  group('DateRange.week', () {
    test('dushanbadan boshlanadi', () {
      // 2026-10-07 — chorshanba.
      final range = DateRange.week(DateTime(2026, 10, 7));
      expect(range.start, DateTime(2026, 10, 5));
      expect(range.end, DateTime(2026, 10, 12));
      expect(range.dayCount, 7);
    });

    test('yakshanbadan boshlanadi', () {
      final range = DateRange.week(
        DateTime(2026, 10, 7),
        weekStartsOn: DateTime.sunday,
      );
      expect(range.start, DateTime(2026, 10, 4));
      expect(range.end, DateTime(2026, 10, 11));
    });

    test('hafta boshining o\'zida turgan kun o\'zini boshlanish deb oladi', () {
      final range = DateRange.week(DateTime(2026, 10, 5));
      expect(range.start, DateTime(2026, 10, 5));
    });
  });

  group('DateRange.month', () {
    test('standart oy 1-sanadan boshlanadi', () {
      final range = DateRange.month(DateTime(2026, 10, 7));
      expect(range.start, DateTime(2026, 10));
      expect(range.end, DateTime(2026, 11));
    });

    test('maosh kuni 5 bo\'lsa, moliyaviy oy 5-dan boshlanadi', () {
      final range = DateRange.month(DateTime(2026, 10, 7), monthStartDay: 5);
      expect(range.start, DateTime(2026, 10, 5));
      expect(range.end, DateTime(2026, 11, 5));
    });

    test('boshlanish kunidan oldin bo\'lsa oldingi oyga tushadi', () {
      final range = DateRange.month(DateTime(2026, 10, 3), monthStartDay: 5);
      expect(range.start, DateTime(2026, 9, 5));
      expect(range.end, DateTime(2026, 10, 5));
    });

    test('boshlanish kuni 1–28 oralig\'iga siqiladi', () {
      final range = DateRange.month(DateTime(2026, 10, 7), monthStartDay: 31);
      expect(range.start.day, 28);
    });
  });

  group('DateRange.year', () {
    test('yil yanvardan boshlanadi', () {
      final range = DateRange.year(DateTime(2026, 10, 7));
      expect(range.start, DateTime(2026));
      expect(range.end, DateTime(2027));
    });
  });

  group('DateRange.custom', () {
    test('oxirgi kun to\'liq kiradi', () {
      final range = DateRange.custom(
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 10),
      );
      expect(range.start, DateTime(2026, 10));
      expect(range.end, DateTime(2026, 10, 11));
      expect(range.dayCount, 10);
      expect(range.contains(DateTime(2026, 10, 10, 23, 0)), isTrue);
    });
  });

  group('shift', () {
    test('oy orqaga surilganda kun saqlanadi', () {
      final range = DateRange.month(DateTime(2026, 10, 7), monthStartDay: 5);
      final previous = range.previous;
      expect(previous.start, DateTime(2026, 9, 5));
      expect(previous.end, DateTime(2026, 10, 5));
      expect(previous.type, PeriodType.month);
    });

    test('next → previous boshlang\'ich holatga qaytaradi', () {
      final range = DateRange.month(DateTime(2026, 10, 7));
      expect(range.next.previous, range);
    });

    test('yil surilganda yil o\'zgaradi', () {
      final range = DateRange.year(DateTime(2026, 5));
      expect(range.previous.start, DateTime(2025));
    });

    test('maxsus oraliq o\'z uzunligiga suriladi', () {
      final range = DateRange.custom(
        DateTime(2026, 10, 11),
        DateTime(2026, 10, 20),
      );
      expect(range.dayCount, 10);
      expect(range.previous.start, DateTime(2026, 10));
    });

    test('hafta 7 kunga suriladi', () {
      final range = DateRange.week(DateTime(2026, 10, 7));
      expect(range.previous.start, DateTime(2026, 9, 28));
      expect(range.next.start, DateTime(2026, 10, 12));
    });
  });

  test('bir xil oraliqlar teng hisoblanadi', () {
    final a = DateRange.month(DateTime(2026, 10, 7));
    final b = DateRange.month(DateTime(2026, 10, 20));
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}
