import 'package:drift/drift.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get buyingCostDzd => integer().withDefault(const Constant(0))();
  IntColumn get sellingPriceDzd => integer().withDefault(const Constant(0))();
  IntColumn get stockQty => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
}

class DeliveryPrices extends Table {
  IntColumn get wilayaCode => integer()();
  IntColumn get homeFeeDzd => integer().withDefault(const Constant(500))();
  IntColumn get officeFeeDzd => integer().withDefault(const Constant(350))();

  @override
  Set<Column> get primaryKey => {wilayaCode};
}

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get customerName => text()();
  TextColumn get phone => text()();
  IntColumn get wilayaCode => integer()();
  TextColumn get commune => text().withDefault(const Constant(''))();
  TextColumn get addressNote => text().withDefault(const Constant(''))();
  IntColumn get productId => integer().nullable()();
  TextColumn get productName => text()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  IntColumn get unitPriceDzd => integer().withDefault(const Constant(0))();
  IntColumn get buyingCostDzd => integer().withDefault(const Constant(0))();
  TextColumn get deliveryMode => text().withDefault(const Constant('home'))();
  IntColumn get deliveryFeeDzd => integer().withDefault(const Constant(0))();
  IntColumn get totalDzd => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('new'))();
  TextColumn get deliveryCompany => text().withDefault(const Constant(''))();
  TextColumn get trackingNumber => text().withDefault(const Constant(''))();
  BoolColumn get codPaidByCompany =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {key};
}
