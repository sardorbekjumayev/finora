import 'package:drift/drift.dart';

/// Qo'lda kiritiladigan valyuta kurslari (internet talab qilinmaydi).
@DataClassName('ExchangeRate')
class ExchangeRates extends Table {
  TextColumn get base => text().withLength(min: 3, max: 3)();
  TextColumn get target => text().withLength(min: 3, max: 3)();
  RealColumn get rate => real()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {base, target};
}

/// Kalit-qiymat sozlamalar (til, tema, valyuta, oy boshlanishi, PIN holati).
@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
