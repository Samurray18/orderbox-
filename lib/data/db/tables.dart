import 'package:drift/drift.dart';

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  RealColumn get price => real().withDefault(const Constant(0.0))();
  RealColumn get cost => real().withDefault(const Constant(0.0))();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DeliveryPrices extends Table {
  IntColumn get wilayaCode => integer()();
  IntColumn get homeFeeDzd => integer().withDefault(const Constant(500))();
  IntColumn get officeFeeDzd => integer().withDefault(const Constant(350))();

  @override
  Set<Column> get primaryKey => {wilayaCode};
}

class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get reference => text().withDefault(const Constant(''))();
  TextColumn get customerName => text()();
  TextColumn get phone => text()();
  TextColumn get wilayaCode => text().withDefault(const Constant(''))();
  TextColumn get wilayaName => text().withDefault(const Constant(''))();
  TextColumn get wilayaNameAr => text().withDefault(const Constant(''))();
  TextColumn get commune => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get productId => text().withDefault(const Constant(''))();
  TextColumn get productName => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  RealColumn get unitPrice => real().withDefault(const Constant(0.0))();
  RealColumn get costPrice => real().withDefault(const Constant(0.0))();
  RealColumn get deliveryPrice => real().withDefault(const Constant(0.0))();
  TextColumn get deliveryType => text().withDefault(const Constant('home'))();
  TextColumn get status => text().withDefault(const Constant('new'))();
  TextColumn get deliveryCompany => text().withDefault(const Constant(''))();
  TextColumn get trackingNumber => text().withDefault(const Constant(''))();
  BoolColumn get codPaidByCompany => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {key};
}
