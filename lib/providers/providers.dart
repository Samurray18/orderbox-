import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(databaseProvider).watchAllProducts();
});

final ordersStreamProvider = StreamProvider<List<Order>>((ref) {
  return ref.watch(databaseProvider).watchAllOrders();
});

final deliveryPricesFutureProvider = FutureProvider<List<DeliveryPrice>>((ref) {
  return ref.watch(databaseProvider).getAllDeliveryPrices();
});
