import 'package:finora/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ming ajratgich — uzilmas bo'sh joy: raqam qator oxirida bo'linmaydi.
const nbsp = '\u{00A0}';

/// Haqiqiy minus belgisi (U+2212), ASCII defis emas — tabular raqamlarda
/// `+` bilan bir xil kenglikda turadi.
const minus = '\u{2212}';

void main() {
  group('Money.format', () {
    test('UZS kasrsiz va uzilmas bo\'sh joy ajratgich bilan', () {
      expect(
        Money.format(125000000, currency: Currency.uzs),
        "1${nbsp}250${nbsp}000 so'm",
      );
    });

    test('UZS tiyinni yaxlitlab ko\'rsatadi', () {
      expect(
        Money.format(12345, currency: Currency.uzs, withSymbol: false),
        '123',
      );
    });

    test('USD ikki kasr xona bilan', () {
      expect(
        Money.format(123456, currency: Currency.usd),
        '1${nbsp}234.56 \$',
      );
    });

    test('manfiy summada minus ishorasi', () {
      expect(
        Money.format(-500000, currency: Currency.uzs, withSymbol: false),
        '${minus}5${nbsp}000',
      );
    });

    test('majburiy ishora manfiylikdan ustun turadi', () {
      expect(
        Money.format(
          500000,
          currency: Currency.uzs,
          withSymbol: false,
          forcedSign: '+',
        ),
        '+5${nbsp}000',
      );
    });

    test('nol summada ishora bo\'lmaydi', () {
      expect(
        Money.format(0, currency: Currency.uzs, withSymbol: false),
        '0',
      );
    });

    group('compact', () {
      String compact(int minor) => Money.format(
            minor,
            currency: Currency.uzs,
            withSymbol: false,
            compact: true,
          );

      test('ming', () => expect(compact(1250000), '12.5 ming'));
      test('mln', () => expect(compact(125000000), '1.3 mln'));
      test('mlrd', () => expect(compact(100000000000), '1 mlrd'));

      test('butun songa tushsa kasr tashlanadi', () {
        expect(compact(200000000), '2 mln');
      });

      test('mingdan kichik summa qisqartirilmaydi', () {
        expect(compact(50000), '500');
      });
    });
  });

  group('Money.parse', () {
    test('oddiy va uzilmas bo\'sh joyni tushunadi', () {
      expect(Money.parse('1 250 000'), 125000000);
      expect(Money.parse('1${nbsp}250${nbsp}000'), 125000000);
    });

    test('vergul kasr ajratgich sifatida qabul qilinadi', () {
      expect(Money.parse('12,5'), 1250);
      expect(Money.parse('12.5'), 1250);
    });

    test('bo\'sh yoki noto\'g\'ri matn uchun null', () {
      expect(Money.parse(''), isNull);
      expect(Money.parse('   '), isNull);
      expect(Money.parse('abc'), isNull);
    });

    test('format → parse aylanishi qiymatni saqlaydi', () {
      const original = 98765400;
      final text = Money.format(
        original,
        currency: Currency.uzs,
        withSymbol: false,
      );
      expect(Money.parse(text), original);
    });
  });

  group('Money.raw', () {
    test('UZS uchun butun son, ajratgichsiz', () {
      expect(Money.raw(125000000, currency: Currency.uzs), '1250000');
    });

    test('USD uchun ikki kasr xona', () {
      expect(Money.raw(123456, currency: Currency.usd), '1234.56');
    });

    test('raw → parse aylanishi qiymatni saqlaydi', () {
      expect(Money.parse(Money.raw(123456, currency: Currency.usd)), 123456);
    });
  });

  group('Money.convert', () {
    test('kurs bo\'yicha o\'giradi', () {
      expect(Money.convert(100, 12.5), 1250);
    });

    test('yaxlitlash minor unitda bajariladi — tiyin yo\'qolmaydi', () {
      expect(Money.convert(3, 1.5), 5);
    });
  });

  group('Currency', () {
    test('byCode mavjud valyutani topadi', () {
      expect(Currency.byCode('USD'), same(Currency.usd));
    });

    test('byCode noma\'lum kod uchun UZS qaytaradi', () {
      expect(Currency.byCode('XXX'), same(Currency.uzs));
    });

    test('UZS kasr xonasi yo\'q, USD ikkita', () {
      expect(Currency.uzs.fractionDigits, 0);
      expect(Currency.usd.fractionDigits, 2);
    });
  });

  test('minor unit 1/100', () => expect(kMinorUnits, 100));
}
