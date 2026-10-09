import 'package:drift/drift.dart';

import 'accounts.dart';
import 'transactions.dart';

@DataClassName('Goal')
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  IntColumn get targetAmount => integer()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  TextColumn get iconKey => text().withDefault(const Constant('savings'))();
  IntColumn get colorValue => integer()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Maqsadga qo'shilgan / olingan summalar. `savedAmount` shu jadvaldan
/// hisoblanadi — hech qachon saqlanmaydi.
@DataClassName('GoalContribution')
class GoalContributions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId =>
      integer().references(Goals, #id, onDelete: KeyAction.cascade)();

  /// Musbat — qo'shildi, manfiy — olindi.
  IntColumn get amount => integer()();
  DateTimeColumn get date => dateTime()();
  IntColumn get transactionId =>
      integer().nullable().references(Transactions, #id)();
}
