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
    return driftDatabase(name: 'orderbox_dz_v2');
  }

  // Products
  Future<List<Product>> getAllProducts() =>
      (select(products)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Stream<List<Product>> watchAllProducts() =>
      (select(products)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<Product?> getProductById(int id) =>
      (select(products)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertProduct(ProductsCompanion entry) =>
      into(products).insert(entry);

  Future<bool> updateProductRow(Product row) => update(products).replace(row);

  Future<int> deleteProductById(int id) =>
      (delete(products)..where((t) => t.id.equals(id))).go();

  Future<void> adjustStock(int productId, int delta) async {
    final p = await getProductById(productId);
    if (p == null) return;
    final next = p.stockQty + delta;
    await (update(products)..where((t) => t.id.equals(productId))).write(
      ProductsCompanion(stockQty: Value(next < 0 ? 0 : next)),
    );
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

  Future<Order?> getOrderById(int id) =>
      (select(orders)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertOrder(OrdersCompanion entry) => into(orders).insert(entry);

  Future<bool> updateOrderRow(Order row) => update(orders).replace(row);

  Future<int> updateOrder(int id, OrdersCompanion entry) =>
      (update(orders)..where((t) => t.id.equals(id))).write(entry);

  Future<int> deleteOrderById(int id) =>
      (delete(orders)..where((t) => t.id.equals(id))).go();

  Future<List<Order>> ordersByPhone(String phone) {
    final normalized = phone.replaceAll(RegExp(r'\D'), '');
    // simple match on digits contained; SQLite LIKE helps
    return (select(orders)
          ..where((t) => t.phone.like('%$normalized%'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
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
