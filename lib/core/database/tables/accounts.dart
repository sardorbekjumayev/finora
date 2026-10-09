import 'package:drift/drift.dart';

import '../enums.dart';

/// Hamyonlar / hisoblar: naqd, karta, bank, omonat, elektron hamyon.
@DataClassName('Account')
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get type => textEnum<AccountType>()();
  TextColumn get currency => text().withLength(min: 3, max: 3)();

  /// Boshlang'ich qoldiq, minor unit (1/100).
  IntColumn get initialBalance => integer().withDefault(const Constant(0))();

  TextColumn get iconKey => text().withDefault(const Constant('wallet'))();
  IntColumn get colorValue => integer()();

  /// O'chirish o'rniga arxivlash — tarix saqlanib qoladi.
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get includeInTotal =>
      boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}
