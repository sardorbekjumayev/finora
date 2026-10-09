import 'package:intl/intl.dart';

/// Pul miqdori **doim `int`** sifatida, minor unit (1/100) da saqlanadi.
/// `double` ishlatilmaydi — yaxlitlash xatolari moliyaviy hisobni buzadi.
const int kMinorUnits = 100;

/// Ilova qo'llab-quvvatlaydigan valyutalar.
class Currency {
  const Currency({
    required this.code,
    required this.symbol,
    required this.fractionDigits,
  });

  final String code;
  final String symbol;

  /// Ko'rsatish va kiritishdagi kasr xonalari soni.
  /// UZS uchun 0 — tiyin amalda ishlatilmaydi, lekin baza 1/100 da saqlaydi.
  final int fractionDigits;

  static const uzs = Currency(code: 'UZS', symbol: "so'm", fractionDigits: 0);
  static const usd = Currency(code: 'USD', symbol: r'$', fractionDigits: 2);
  static const eur = Currency(code: 'EUR', symbol: '€', fractionDigits: 2);
  static const rub = Currency(code: 'RUB', symbol: '₽', fractionDigits: 2);
  static const kzt = Currency(code: 'KZT', symbol: '₸', fractionDigits: 0);

  static const all = <Currency>[uzs, usd, eur, rub, kzt];

  static Currency byCode(String code) =>
      all.firstWhere((c) => c.code == code, orElse: () => uzs);
}

/// Minor unit'dagi `int`ni o'qilishi oson matnga aylantiradi.
class Money {
  const Money._();

  /// `125000000` + UZS → `1 250 000 so'm`
  static String format(
    int minor, {
    required Currency currency,
    bool withSymbol = true,
    bool compact = false,
    String? forcedSign,
  }) {
    final value = minor / kMinorUnits;
    final abs = value.abs();

    final String body;
    if (compact) {
      body = _compact(abs, currency);
    } else {
      body = _plain(abs, currency);
    }

    final sign = forcedSign ?? (minor < 0 ? '−' : '');
    return withSymbol ? '$sign$body ${currency.symbol}' : '$sign$body';
  }

  /// Faqat raqam — kiritish maydonlari uchun (ajratgichsiz).
  static String raw(int minor, {required Currency currency}) {
    final value = minor / kMinorUnits;
    if (currency.fractionDigits == 0) {
      return value.round().toString();
    }
    return value.toStringAsFixed(currency.fractionDigits);
  }

  static String _plain(double abs, Currency currency) {
    final pattern = currency.fractionDigits == 0
        ? '#,##0'
        : '#,##0.${'0' * currency.fractionDigits}';
    // Ming ajratgich — bo'sh joy (NBSP), o'zbek/rus formatiga mos.
    return NumberFormat(pattern, 'en_US')
        .format(abs)
        .replaceAll(',', ' ');
  }

  static String _compact(double abs, Currency currency) {
    const units = [
      (1000000000, 'mlrd'),
      (1000000, 'mln'),
      (1000, 'ming'),
    ];
    for (final (threshold, suffix) in units) {
      if (abs >= threshold) {
        final scaled = abs / threshold;
        final text = scaled >= 100
            ? scaled.round().toString()
            : scaled.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
        return '$text $suffix';
      }
    }
    return _plain(abs, currency);
  }

  /// Foydalanuvchi kiritgan matnni minor unit'ga o'giradi.
  /// Bo'sh joy va ajratgichlarni tashlab yuboradi, `,` ni `.` deb qabul qiladi.
  static int? parse(String input) {
    final cleaned = input
        .replaceAll(' ', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .trim();
    if (cleaned.isEmpty) return null;
    final value = double.tryParse(cleaned);
    if (value == null) return null;
    return (value * kMinorUnits).round();
  }

  /// Boshqa valyutaga kurs bo'yicha o'girish (yaxlitlash minor unitda).
  static int convert(int minor, double rate) => (minor * rate).round();
}
