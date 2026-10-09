import 'package:drift/drift.dart';

import '../enums.dart';
import 'accounts.dart';
import 'categories.dart';

/// Takroriy tranzaksiya qoidasi: ijara, internet, obuna, maosh...
@DataClassName('RecurringRule')
class RecurringRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => textEnum<TransactionType>()();
  IntColumn get amount => integer()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get toAccountId =>
      integer().nullable().references(Accounts, #id)();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  TextColumn get note => text().nullable()();

  TextColumn get frequency => textEnum<RecurringFrequency>()();

  /// Har `interval` chastotada: masalan `monthly` + 2 = ikki oyda bir.
  IntColumn get interval => integer().withDefault(const Constant(1))();

  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get nextRun => dateTime()();
  TextColumn get mode => textEnum<RecurringMode>()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
