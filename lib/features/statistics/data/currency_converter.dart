import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/settings_service.dart';

/// Turli valyutadagi summalarni asosiy valyutaga o'giradi.
///
/// Kurslar **qo'lda** kiritiladi (`exchange_rates`) — internet kerak emas.
/// Kurs topilmasa 1:1 deb olinadi va [hasMissingRate] bilan belgilanadi,
/// shunda UI foydalanuvchini ogohlantira oladi.
@immutable
class CurrencyConverter {
  const CurrencyConverter({
    required this.mainCurrency,
    required this.rates,
  });

  factory CurrencyConverter.identity(String mainCurrency) =>
      CurrencyConverter(mainCurrency: mainCurrency, rates: const {});

  final String mainCurrency;

  /// `valyuta kodi → asosiy valyutaga kurs`.
  final Map<String, double> rates;

  double rateFrom(String currency) {
    if (currency == mainCurrency) return 1;
    return rates[currency] ?? 1;
  }

  int toMain(int amount, String currency) {
    if (currency == mainCurrency) return amount;
    return (amount * rateFrom(currency)).round();
  }

  bool hasMissingRate(Iterable<String> currencies) => currencies.any(
        (c) => c != mainCurrency && !rates.containsKey(c),
      );
}

final currencyConverterProvider = StreamProvider<CurrencyConverter>((ref) {
  final db = ref.watch(databaseProvider);
  final main = ref.watch(settingsProvider).mainCurrencyCode;

  return db.select(db.exchangeRates).watch().map((rows) {
    final rates = <String, double>{};
    for (final row in rows) {
      if (row.target == main) {
        rates[row.base] = row.rate;
      } else if (row.base == main && row.rate != 0) {
        rates.putIfAbsent(row.target, () => 1 / row.rate);
      }
    }
    return CurrencyConverter(mainCurrency: main, rates: rates);
  });
});

/// Kurs qo'shish / yangilash.
class ExchangeRateRepository {
  ExchangeRateRepository(this._db);

  final AppDatabase _db;

  Future<void> upsert({
    required String base,
    required String target,
    required double rate,
  }) {
    return _db.into(_db.exchangeRates).insertOnConflictUpdate(
          ExchangeRatesCompanion.insert(
            base: base,
            target: target,
            rate: rate,
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<void> remove(String base, String target) {
    return (_db.delete(_db.exchangeRates)
          ..where((t) => t.base.equals(base) & t.target.equals(target)))
        .go();
  }

  Stream<List<ExchangeRate>> watchAll() =>
      _db.select(_db.exchangeRates).watch();
}

final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>(
  (ref) => ExchangeRateRepository(ref.watch(databaseProvider)),
);
