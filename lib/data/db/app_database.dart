import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Products, DeliveryPrices, Orders, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    // v3: schema aligned with core models (string IDs, full order fields)
    return driftDatabase(name: 'orderbox_dz_v3');
  }

  // Products
  Future<List<Product>> getAllProducts() =>
      (select(products)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Stream<List<Product>> watchAllProducts() =>
      (select(products)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<Product?> getProductById(String id) =>
      (select(products)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertProduct(ProductsCompanion entry) =>
      into(products).insertOnConflictUpdate(entry);

  Future<bool> updateProductRow(Product row) => update(products).replace(row);

  Future<int> deleteProductById(String id) =>
      (delete(products)..where((t) => t.id.equals(id))).go();

  Future<void> replaceAllProducts(List<ProductsCompanion> entries) async {
    await transaction(() async {
      await delete(products).go();
      if (entries.isEmpty) return;
      await batch((b) => b.insertAll(products, entries));
    });
  }

  // Delivery prices
  Future<List<DeliveryPrice>> getAllDeliveryPrices() =>
      (select(deliveryPrices)
            ..orderBy([(t) => OrderingTerm.asc(t.wilayaCode)]))
          .get();

  Future<DeliveryPrice?> getDeliveryPrice(int wilayaCode) =>
      (select(deliveryPrices)
            ..where((t) => t.wilayaCode.equals(wilayaCode)))
          .getSingleOrNull();

  Future<void> upsertDeliveryPrice(DeliveryPricesCompanion entry) async {
    await into(deliveryPrices).insertOnConflictUpdate(entry);
  }

  Future<void> setAllDeliveryPrices({
    required int homeFeeDzd,
    required int officeFeeDzd,
  }) async {
    await batch((b) {
      for (var code = 1; code <= 58; code++) {
        b.insert(
          deliveryPrices,
          DeliveryPricesCompanion(
            wilayaCode: Value(code),
            homeFeeDzd: Value(homeFeeDzd),
            officeFeeDzd: Value(officeFeeDzd),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> ensureDefaultDeliveryPrices() async {
    final existing = await getAllDeliveryPrices();
    if (existing.length >= 58) return;
    await setAllDeliveryPrices(homeFeeDzd: 600, officeFeeDzd: 400);
  }

  // Orders
  Future<List<Order>> getAllOrders() =>
      (select(orders)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

  Stream<List<Order>> watchAllOrders() =>
      (select(orders)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Future<Order?> getOrderById(String id) =>
      (select(orders)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertOrder(OrdersCompanion entry) =>
      into(orders).insertOnConflictUpdate(entry);

  Future<bool> updateOrderRow(Order row) => update(orders).replace(row);

  Future<int> deleteOrderById(String id) =>
      (delete(orders)..where((t) => t.id.equals(id))).go();

  Future<void> replaceAllOrders(List<OrdersCompanion> entries) async {
    await transaction(() async {
      await delete(orders).go();
      if (entries.isEmpty) return;
      await batch((b) => b.insertAll(orders, entries));
    });
  }

  // Settings
  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: Value(value)),
    );
  }

  Stream<String?> watchSetting(String key) {
    return (select(appSettings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((r) => r?.value);
  }
}
