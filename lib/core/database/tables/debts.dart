import 'package:drift/drift.dart';

import '../enums.dart';
import 'accounts.dart';

@DataClassName('Debt')
class Debts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get personName => text().withLength(min: 1, max: 80)();
  TextColumn get direction => textEnum<DebtDirection>()();
  IntColumn get totalAmount => integer()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get status => textEnum<DebtStatus>()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('DebtPayment')
class DebtPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get debtId =>
      integer().references(Debts, #id, onDelete: KeyAction.cascade)();
  IntColumn get amount => integer()();
  DateTimeColumn get date => dateTime()();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
}
