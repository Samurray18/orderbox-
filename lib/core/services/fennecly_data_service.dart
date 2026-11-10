import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/algeria_geo.dart';
import '../data/app_store.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'fennecly_supabase.dart';

class FenneclyStoreInfo {
  const FenneclyStoreInfo({
    required this.id,
    required this.ownerId,
    required this.name,
    this.slug,
    this.currency = 'DZD',
    this.isDefault = false,
  });
  final String id;
  final String ownerId;
  final String name;
  final String? slug;
  final String currency;
  final bool isDefault;

  factory FenneclyStoreInfo.fromMap(Map<String, dynamic> m) => FenneclyStoreInfo(
        id: (m['id'] ?? '').toString(),
        ownerId: (m['owner_id'] ?? '').toString(),
        name: (m['name'] ?? 'Store').toString(),
        slug: m['slug']?.toString(),
        currency: (m['currency'] ?? 'DZD').toString(),
        isDefault: m['is_default'] == true,
      );
}

class FenneclySyncResult {
  const FenneclySyncResult({
    this.store,
    this.orders = 0,
    this.products = 0,
    this.customers = 0,
    this.companies = 0,
    this.tariffs = 0,
    this.error,
  });
  final FenneclyStoreInfo? store;
  final int orders;
  final int products;
  final int customers;
  final int companies;
  final int tariffs;
  final String? error;
  bool get ok => error == null;
}

/// Reads the same Fennecly/Supabase data the webapp (fennecly.online) shows,
/// scoped like the webapp: profile.current_store_id -> stores(owner_id),
/// then orders/products by store_owner_id + store_id (with fallbacks).
class FenneclyDataService {
  static SupabaseClient get _db => FenneclySupabase.client;

  static Future<List<FenneclyStoreInfo>> listStores() async {
    final user = _db.auth.currentUser;
    if (user == null) return const [];
    try {
      final res = await _db
          .from('stores')
          .select('id,owner_id,name,slug,currency,is_default,is_active,created_at')
          .eq('owner_id', user.id)
          .order('created_at', ascending: true);
      if (res is! List) return const [];
      return res
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((s) => s['is_active'] != false)
          .map(FenneclyStoreInfo.fromMap)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> switchStore(String storeId) async {
    final user = _db.auth.currentUser;
    if (user == null) return;
    try {
      await _db.from('profiles').update({'current_store_id': storeId}).eq('id', user.id);
    } catch (_) {}
  }

  /// Resolve current store the same way the webapp does.
  static Future<FenneclyStoreInfo?> resolveCurrentStore() async {
    final user = _db.auth.currentUser;
    if (user == null) return null;
    try {
      final storesRes = await _db
          .from('stores')
          .select('id,owner_id,name,slug,currency,is_default,is_active,created_at')
          .eq('owner_id', user.id)
          .order('created_at', ascending: true);
      final stores = (storesRes as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .where((s) => s['is_active'] != false)
          .map(FenneclyStoreInfo.fromMap)
          .toList();
      if (stores.isEmpty) return null;

      String? currentId;
      try {
        final prof = await _db
            .from('profiles')
            .select('current_store_id')
            .eq('id', user.id)
            .maybeSingle();
        if (prof != null) currentId = (prof as Map)['current_store_id']?.toString();
      } catch (_) {}
      if (currentId != null) {
        for (final s in stores) {
          if (s.id == currentId) return s;
        }
      }
      for (final s in stores) {
        if (s.isDefault) return s;
      }
      return stores.first;
    } catch (_) {
      // fallback: try a simple stores query
      try {
        final res = await _db.from('stores').select('*').eq('owner_id', user.id).limit(1);
        if (res is List && res.isNotEmpty && res.first is Map) {
          return FenneclyStoreInfo.fromMap(Map<String, dynamic>.from(res.first as Map));
        }
      } catch (_) {}
      return null;
    }
  }

  /// Full sync: store info, products, orders+items, shipping. Replaces AppStore data.
  static Future<FenneclySyncResult> syncAll(AppStore store) async {
    final user = _db.auth.currentUser;
    if (user == null) {
      return const FenneclySyncResult(error: 'not_authenticated');
    }
    FenneclyStoreInfo? currentStore;
    var ordersCount = 0;
    var productsCount = 0;
    var companiesCount = 0;
    var tariffsCount = 0;
    String? firstError;
    try {
      currentStore = await resolveCurrentStore();
      if (currentStore != null) {
        store.setFenneclyStore(name: currentStore.name, id: currentStore.id);
      }

      // Products (same scoping as webapp)
      try {
        final products = await _fetchProducts(user.id, currentStore?.id);
        store.replaceProducts(products);
        productsCount = products.length;
      } catch (e) {
        firstError ??= 'products: $e';
      }

      // Orders + order_items
      try {
        final orders = await _fetchOrders(user.id, currentStore?.id);
        store.replaceOrders(orders);
        ordersCount = orders.length;
      } catch (e) {
        firstError ??= 'orders: $e';
      }

      // Shipping (companies + tariffs) — reuse/extend existing behavior
      try {
        final ship = await _syncShipping(store, user.id, currentStore?.id);
        companiesCount = ship.$1;
        tariffsCount = ship.$2;
      } catch (_) {}

      store.markFenneclySynced();
      final customers = _distinctCustomers(store.orders);
      return FenneclySyncResult(
        store: currentStore,
        orders: ordersCount,
        products: productsCount,
        customers: customers,
        companies: companiesCount,
        tariffs: tariffsCount,
        error: firstError,
      );
    } catch (e) {
      return FenneclySyncResult(store: currentStore, error: e.toString());
    }
  }

  static int _distinctCustomers(List<Order> orders) {
    final keys = <String>{};
    for (final o in orders) {
      final k = (o.phone.isNotEmpty ? o.phone : o.customerName).toLowerCase().trim();
      if (k.isNotEmpty) keys.add(k);
    }
    return keys.length;
  }

  static Future<List<Product>> _fetchProducts(String userId, String? storeId) async {
    List<dynamic> rows = const [];
    // Prefer store-scoped, then fall back to user-scoped (matches webapp)
    if (storeId != null && storeId.isNotEmpty) {
      try {
        final res = await _db
            .from('products')
            .select('id,name,price,sale_price,stock,user_id,store_id,created_at,status')
            .eq('store_id', storeId)
            .order('created_at', ascending: false);
        if (res is List) rows = res;
      } catch (_) {}
    }
    if (rows.isEmpty) {
      try {
        final res = await _db
            .from('products')
            .select('id,name,price,sale_price,stock,user_id,store_id,created_at,status')
            .eq('user_id', userId)
            .order('created_at', ascending: false);
        if (res is List) rows = res;
      } catch (_) {
        // minimal select fallback
        try {
          final res = await _db.from('products').select('*').eq('user_id', userId).order('created_at', ascending: false);
          if (res is List) rows = res;
        } catch (_) {}
      }
    }
    return rows.whereType<Map>().map((r) => _mapProduct(Map<String, dynamic>.from(r))).toList();
  }

  static Product _mapProduct(Map<String, dynamic> r) {
    final price = _num(r['sale_price']) ?? _num(r['price']) ?? 0;
    final created = DateTime.tryParse((r['created_at'] ?? '').toString()) ?? DateTime.now();
    return Product(
      id: (r['id'] ?? '').toString(),
      name: (r['name'] ?? '').toString(),
      price: price.toDouble(),
      cost: 0, // not exposed by Fennecly products table
      stock: (_num(r['stock']) ?? 0).toInt(),
      createdAt: created,
    );
  }

  static Future<List<Order>> _fetchOrders(String userId, String? storeId) async {
    dynamic q = _db.from('orders').select('*').eq('store_owner_id', userId);
    if (storeId != null && storeId.isNotEmpty) {
      q = q.eq('store_id', storeId);
    }
    List<dynamic> rows = const [];
    try {
      final res = await q.order('created_at', ascending: false);
      if (res is List) rows = res;
    } catch (_) {
      // fallback without store_id
      try {
        final res = await _db
            .from('orders')
            .select('*')
            .eq('store_owner_id', userId)
            .order('created_at', ascending: false);
        if (res is List) rows = res;
      } catch (_) {}
    }
    if (rows.isEmpty) return const [];

    final ids = rows.whereType<Map>().map((r) => (r['id'] ?? '').toString()).where((s) => s.isNotEmpty).toList();
    final itemsByOrder = <String, List<Map<String, dynamic>>>{};
    final shipByOrder = <String, Map<String, dynamic>>{};
    final companyNames = await _fetchCompanyNames();

    for (var i = 0; i < ids.length; i += 100) {
      final chunk = ids.sublist(i, i + 100 > ids.length ? ids.length : i + 100);
      try {
        final res = await _db.from('order_items').select('*').inFilter('order_id', chunk);
        if (res is List) {
          for (final it in res.whereType<Map>()) {
            final m = Map<String, dynamic>.from(it);
            final oid = (m['order_id'] ?? '').toString();
            (itemsByOrder[oid] ??= []).add(m);
          }
        }
      } catch (_) {}
      try {
        final res = await _db.from('shipments').select('*').inFilter('order_id', chunk);
        if (res is List) {
          for (final sh in res.whereType<Map>()) {
            final m = Map<String, dynamic>.from(sh);
            final oid = (m['order_id'] ?? '').toString();
            // keep latest/first if multiple
            shipByOrder.putIfAbsent(oid, () => m);
          }
        }
      } catch (_) {}
    }

    return rows
        .whereType<Map>()
        .map((r) => _mapOrder(
              Map<String, dynamic>.from(r),
              itemsByOrder[(r['id'] ?? '').toString()] ?? const [],
              shipByOrder[(r['id'] ?? '').toString()],
              companyNames,
            ))
        .toList();
  }

  static Future<Map<String, String>> _fetchCompanyNames() async {
    final map = <String, String>{};
    try {
      final res = await _db.from('delivery_companies').select('id,name');
      if (res is List) {
        for (final r in res.whereType<Map>()) {
          final id = (r['id'] ?? '').toString();
          final name = (r['name'] ?? '').toString();
          if (id.isNotEmpty && name.isNotEmpty) map[id] = name;
        }
      }
    } catch (_) {}
    return map;
  }

  static Order _mapOrder(
    Map<String, dynamic> r,
    List<Map<String, dynamic>> items,
    Map<String, dynamic>? shipment,
    Map<String, String> companyNames,
  ) {
    final created = DateTime.tryParse((r['created_at'] ?? '').toString()) ?? DateTime.now();
    final wilayaRaw = (r['shipping_wilaya'] ?? '').toString();
    final w = _resolveWilaya(wilayaRaw);
    final subtotal = (_num(r['subtotal']) ?? 0).toDouble();
    final total = (_num(r['total']) ?? 0).toDouble();
    var delivery = total - subtotal;
    if (delivery < 0 || delivery > 50000) delivery = 0;
    final rawType = (shipment?['delivery_type'] ?? r['delivery_type'] ?? 'home').toString().toLowerCase();
    final deliveryType = (rawType.contains('stop') || rawType.contains('desk') || rawType.contains('office') || rawType.contains('bureau')) ? 'office' : 'home';
    String productName = '';
    String productId = '';
    int quantity = 0;
    double unitSum = 0;
    if (items.isNotEmpty) {
      final names = items.map((it) => (it['product_name'] ?? '').toString()).where((s) => s.isNotEmpty).toList();
      productName = names.length <= 2 ? names.join(', ') : '${names.take(2).join(', ')} +${names.length - 2}';
      productId = (items.first['product_id'] ?? '').toString();
      for (final it in items) {
        final q = (_num(it['quantity']) ?? 1).toInt();
        quantity += q;
        unitSum += (_num(it['unit_price']) ?? 0).toDouble() * q;
      }
      if (quantity > 0) {
        unitSum = unitSum / quantity;
      } else {
        quantity = 1;
        unitSum = subtotal;
      }
    } else {
      productName = (r['notes'] ?? '—').toString();
      if (productName.length > 60) productName = '${productName.substring(0, 57)}...';
      quantity = 1;
      unitSum = subtotal;
    }
    final status = OrderStatusX.fromId(r['status']?.toString());
    final id = (r['id'] ?? '').toString();
    final shortRef = id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
    final tracking = (shipment?['tracking_number'] ?? r['tracking_number'] ?? '').toString();
    final companyId = (shipment?['company_id'] ?? '').toString();
    final deliveryCompany = companyNames[companyId] ?? '';
    final payStatus = (r['payment_status'] ?? '').toString().toLowerCase();
    return Order(
      id: id,
      reference: 'FN-$shortRef',
      customerName: (r['customer_name'] ?? '').toString(),
      phone: (r['customer_phone'] ?? '').toString(),
      wilayaCode: w.$1,
      wilayaName: w.$2,
      wilayaNameAr: w.$3,
      commune: (r['shipping_city'] ?? '').toString(),
      address: (r['shipping_address'] ?? '').toString(),
      productId: productId,
      productName: productName.isEmpty ? '—' : productName,
      quantity: quantity <= 0 ? 1 : quantity,
      unitPrice: unitSum,
      costPrice: 0,
      deliveryPrice: delivery,
      status: status,
      createdAt: created,
      notes: (r['notes'] ?? '').toString(),
      deliveryCompany: deliveryCompany,
      deliveryType: deliveryType,
      trackingNumber: tracking,
      codPaidByCompany: payStatus == 'paid' || payStatus == 'collected',
    );
  }

  static (String, String, String) _resolveWilaya(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return ('', t, t);
    final m = RegExp(r'^(\d{1,2})').firstMatch(t);
    if (m != null) {
      final n = int.tryParse(m.group(1)!);
      if (n != null && n >= 1 && n <= 58) {
        final w = AlgeriaGeo.byCode(n);
        return (w.codeStr, w.nameFr, w.nameAr);
      }
    }
    for (final w in AlgeriaGeo.all) {
      if (w.nameFr.toLowerCase() == t.toLowerCase() || w.nameAr == t) {
        return (w.codeStr, w.nameFr, w.nameAr);
      }
    }
    return ('', t, t);
  }

  /// Push a status change back to Fennecly when the order comes from Fennecly.
  static Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    final user = _db.auth.currentUser;
    if (user == null) return false;
    try {
      await _db
          .from('orders')
          .update({'status': status.fenneclyId})
          .eq('id', orderId)
          .eq('store_owner_id', user.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<(int, int)> _syncShipping(AppStore store, String userId, String? storeId) async {
    var companies = 0;
    var tariffs = 0;
    // companies
    try {
      final rows = await _db.from('delivery_companies').select('name').eq('is_active', true).order('name');
      for (final r in (rows as List)) {
        final name = ((r as Map)['name'] ?? '').toString().trim();
        if (name.isNotEmpty) { store.addDeliveryCompany(name); companies++; }
      }
    } catch (_) {
      try {
        final rows = await _db.from('delivery_companies').select('name').order('name');
        for (final r in (rows as List)) {
          final name = ((r as Map)['name'] ?? '').toString().trim();
          if (name.isNotEmpty) { store.addDeliveryCompany(name); companies++; }
        }
      } catch (_) {}
    }
    // tariffs - try owner-scoped
    List<dynamic> trows = const [];
    for (final ownerCol in ['owner_id', 'store_id', 'user_id']) {
      try {
        final res = await _db.from('delivery_tariffs').select('*').eq(ownerCol, ownerCol == 'store_id' ? (storeId ?? userId) : userId);
        if (res is List && res.isNotEmpty) { trows = res; break; }
      } catch (_) {}
    }
    if (trows.isEmpty) {
      try { trows = await _db.from('delivery_tariffs').select('*').limit(5000); } catch (_) {}
    }
    for (final r in trows.whereType<Map>()) {
      final m = Map<String, dynamic>.from(r);
      final code = _resolveWilayaCode((m['wilaya'] ?? m['wilaya_code'] ?? m['wilayaCode'] ?? m['city'] ?? '').toString());
      if (code == null) continue;
      final typeRaw = (m['delivery_type'] ?? m['type'] ?? m['deliveryType'] ?? 'home').toString().toLowerCase();
      final isOffice = typeRaw.contains('stop') || typeRaw.contains('desk') || typeRaw.contains('office') || typeRaw.contains('bureau');
      final price = _num(m['price'] ?? m['tarif'] ?? m['fee']);
      if (price == null) continue;
      store.setShippingPrice(code, home: isOffice ? null : price.toDouble(), office: isOffice ? price.toDouble() : null);
      tariffs++;
    }
    return (companies, tariffs);
  }

  static String? _resolveWilayaCode(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    final asInt = int.tryParse(t.replaceAll(RegExp(r'[^0-9]'), ''));
    if (asInt != null && asInt >= 1 && asInt <= 58) return asInt.toString().padLeft(2, '0');
    final m = RegExp(r'^(\d{1,2})\b').firstMatch(t);
    if (m != null) {
      final n = int.tryParse(m.group(1)!);
      if (n != null && n >= 1 && n <= 58) return n.toString().padLeft(2, '0');
    }
    return null;
  }

  static num? _num(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString().replaceAll(',', '.'));
  }
}
