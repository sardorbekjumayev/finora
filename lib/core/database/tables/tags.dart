import 'package:drift/drift.dart';

import 'transactions.dart';

@DataClassName('Tag')
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  IntColumn get colorValue => integer()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {name},
      ];
}

@DataClassName('TransactionTag')
class TransactionTags extends Table {
  IntColumn get transactionId =>
      integer().references(Transactions, #id, onDelete: KeyAction.cascade)();
  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {transactionId, tagId};
}
