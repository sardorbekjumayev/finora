import 'package:drift/drift.dart';

import '../enums.dart';
import 'categories.dart';

@DataClassName('Budget')
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// null bo'lsa — umumiy byudjet.
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  /// Limit, minor unit.
  IntColumn get amount => integer()();
  TextColumn get period => textEnum<BudgetPeriod>()();

  /// Oylik davr uchun boshlanish kuni (1–28), haftalik uchun 1–7.
  IntColumn get startDay => integer().withDefault(const Constant(1))();

  /// Qolgan summani keyingi davrga o'tkazish.
  BoolColumn get rollover => boolean().withDefault(const Constant(false))();
  IntColumn get alertPercent => integer().withDefault(const Constant(80))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}
