import 'package:drift/drift.dart';

import '../enums.dart';
import 'accounts.dart';
import 'categories.dart';
import 'debts.dart';
import 'recurring_rules.dart';

/// Kirim / chiqim / o'tkazma yozuvi.
///
/// `drift` o'zining `Transaction` klassini eksport qilgani uchun data-class
/// nomi `TxEntry` deb atalgan.
@DataClassName('TxEntry')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => textEnum<TransactionType>()();

  /// Doim musbat, minor unit (1/100).
  IntColumn get amount => integer()();

  IntColumn get accountId => integer().references(Accounts, #id)();

  /// Faqat `transfer` uchun — pul tushgan hisob.
  IntColumn get toAccountId =>
      integer().nullable().references(Accounts, #id)();

  /// `transfer`da null.
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  /// Foydalanuvchi tanlagan sana-vaqt (DB ustuni: `date_time`).
  DateTimeColumn get date => dateTime().named('date_time')();
  TextColumn get note => text().nullable()();

  /// Valyutalar orasidagi o'tkazma kursi (to/from).
  RealColumn get transferRate => real().nullable()();

  IntColumn get recurringId =>
      integer().nullable().references(RecurringRules, #id)();
  IntColumn get debtId => integer().nullable().references(Debts, #id)();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
