import 'package:drift/drift.dart';

import '../enums.dart';

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get kind => textEnum<CategoryKind>()();
  TextColumn get iconKey => text()();
  IntColumn get colorValue => integer()();

  /// Sub-kategoriya uchun ota kategoriya.
  IntColumn get parentId =>
      integer().nullable().references(Categories, #id)();

  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
