import 'dart:convert';
import 'dart:io';

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
    this.logoUrl,
  });
  final String id;
  final String ownerId;
  final String name;
  final String? slug;
  final String currency;
  final bool isDefault;
  final String? logoUrl;

  factory FenneclyStoreInfo.fromMap(Map<String, dynamic> m) => FenneclyStoreInfo(
        id: (m['id'] ?? '').toString(),
        ownerId: (m['owner_id'] ?? '').toString(),
        name: (m['name'] ?? 'Store').toString(),
        slug: m['slug']?.toString(),
        currency: (m['currency'] ?? 'DZD').toString(),
        isDefault: m['is_default'] == true,
        logoUrl: m['logo_url']?.toString(),
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
          .select('id,owner_id,name,slug,currency,is_default,is_active,created_at,logo_url')
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
          .select('id,owner_id,name,slug,currency,is_default,is_active,created_at,logo_url')
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

  /// Pulls the shared-accounts profile row (name, email, avatar_url).
  /// The web stores profile fields there; the mobile app gets them after
  /// login/sync and shows the avatar in-app.
  static Future<Map<String, dynamic>?> fetchProfile() async {
  final user = _db.auth.currentUser;
  if (user == null) return null;
  try {
    final res = await _db
        .from('profiles')
        .select('id,name,email,avatar_url')
        .eq('id', user.id)
        .maybeSingle();
    if (res == null) return null;
    return Map<String, dynamic>.from(res as Map);
  } catch (_) {
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
        store.setFenneclyStore(
          name: currentStore.name,
          id: currentStore.id,
          logoUrl: currentStore.logoUrl,
        );
      }

      // Profile (shared accounts: same profile as the web dashboard).
      try {
        final profile = await fetchProfile();
        if (profile != null) {
          store.setFenneclyProfile(
            name: profile['name']?.toString(),
            email: profile['email']?.toString(),
            avatarUrl: profile['avatar_url']?.toString(),
          );
        }
      } catch (_) {}

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
    // tariffs - only rows for the signed-in user (owner/store-scoped)
    List<dynamic> trows = const [];
    for (final ownerCol in ['owner_id', 'user_id']) {
      try {
        final res = await _db.from('delivery_tariffs').select('*').eq(ownerCol, userId);
        if (res is List && res.isNotEmpty) { trows = res; break; }
      } catch (_) {}
    }
    if (trows.isEmpty && storeId != null && storeId.isNotEmpty) {
      try {
        final res = await _db.from('delivery_tariffs').select('*').eq('store_id', storeId);
        if (res is List) trows = res;
      } catch (_) {}
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

  // ---------------------------------------------------------------------
  // Phase 1 write paths — mirror the Fennecly webapp server actions:
  // orders + order_items, products + product_costs, call_logs, cod_*,
  // expenses. Every query is scoped to the signed-in user/store.
  // ---------------------------------------------------------------------

  /// Insert an order (orders row + order_items) exactly like the webapp's
  /// createOrder server action, scoped to the signed-in store owner.
  static Future<String?> createOrder({
    required String storeOwnerId,
    required String storeSlug,
    required String customerName,
    String customerEmail = '',
    String? customerPhone,
    required String shippingAddress,
    required String shippingCity,
    required String shippingPostalCode,
    String shippingCountry = 'Algeria',
    required double subtotal,
    required double total,
    String status = 'pending',
    String deliveryType = 'domicile',
    String? notes,
    String paymentMethod = 'cod',
    String? source,
    List<Map<String, dynamic>> items = const <Map<String, dynamic>>[],
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) return null;
    try {
      final res = await _db
          .from('orders')
          .insert(<String, dynamic>{
            'store_owner_id': storeOwnerId,
            'store_slug': storeSlug,
            'customer_name': customerName,
            'customer_email': customerEmail,
            'customer_phone': customerPhone,
            'shipping_address': shippingAddress,
            'shipping_city': shippingCity,
            'shipping_postal_code': shippingPostalCode,
            'shipping_country': shippingCountry,
            'notes': notes,
            'subtotal': subtotal,
            'total': total,
            'status': status,
            'payment_method': paymentMethod,
            'payment_status': 'pending',
            'delivery_type': deliveryType,
            if (source != null && source.isNotEmpty) 'source': source,
          })
          .select('id, created_at')
          .single();
      if (res is Map) {
        final orderId = (res['id'] ?? '').toString();
        if (orderId.isNotEmpty && items.isNotEmpty) {
          await _db.from('order_items').insert(items);
        }
        return orderId;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Update an existing order row (same scope as the webapp owner check).
  static Future<bool> updateOrder({
    required String orderId,
    required String storeOwnerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? shippingAddress,
    String? shippingCity,
    String? shippingPostalCode,
    String? shippingCountry,
    String? notes,
    double? subtotal,
    double? total,
    String? status,
    String? deliveryType,
    String? deliveryCompany,
    String? trackingNumber,
  }) async {
    try {
      final values = <String, dynamic>{};
      if (customerName != null) values['customer_name'] = customerName;
      if (customerEmail != null) values['customer_email'] = customerEmail;
      if (customerPhone != null) values['customer_phone'] = customerPhone;
      if (shippingAddress != null) values['shipping_address'] = shippingAddress;
      if (shippingCity != null) values['shipping_city'] = shippingCity;
      if (shippingPostalCode != null) values['shipping_postal_code'] = shippingPostalCode;
      if (shippingCountry != null) values['shipping_country'] = shippingCountry;
      if (notes != null) values['notes'] = notes;
      if (subtotal != null) values['subtotal'] = subtotal;
      if (total != null) values['total'] = total;
      if (status != null) values['status'] = status;
      if (deliveryType != null) values['delivery_type'] = deliveryType;
      if (deliveryCompany != null) values['delivery_company'] = deliveryCompany;
      if (trackingNumber != null) values['tracking_number'] = trackingNumber;
      values['updated_at'] = DateTime.now().toIso8601String();
      await _db
          .from('orders')
          .update(values)
          .eq('id', orderId)
          .eq('store_owner_id', storeOwnerId);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteOrder({
    required String orderId,
    required String storeOwnerId,
  }) async {
    try {
      await _db
          .from('orders')
          .delete()
          .eq('id', orderId)
          .eq('store_owner_id', storeOwnerId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Create a call log entry (webapp: CallOutcomeModal → useCallLog.logCall).
  /// Returns the new call_logs row id (for follow-up outcome updates), or null.
  static Future<String?> logCall({
    required String orderId,
    required String customerPhone,
    required String customerName,
    required String channel,
    String outcome = 'pending',
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) return null;
    try {
      final res = await _db
          .from('call_logs')
          .insert(<String, dynamic>{
            'merchant_id': user.id,
            'order_id': orderId,
            'customer_phone': customerPhone,
            'customer_name': customerName,
            'channel': channel,
            'outcome': outcome,
          })
          .select('id')
          .single();
      if (res is Map) {
        return (res['id'] ?? '').toString();
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> updateCallOutcome({
    required String callLogId,
    required String outcome,
    String? note,
  }) async {
    try {
      await _db
          .from('call_logs')
          .update(<String, dynamic>{
            'outcome': outcome,
            'note': note,
          })
          .eq('id', callLogId);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> listCallLogs({String? orderId}) async {
    final user = _db.auth.currentUser;
    if (user == null) return const <Map<String, dynamic>>[];
    try {
      var query = _db
          .from('call_logs')
          .select('id, order_id, customer_phone, customer_name, channel, outcome, note, called_at')
          .eq('merchant_id', user.id);
      if (orderId != null && orderId.isNotEmpty) {
        query = query.eq('order_id', orderId);
      }
      final res = await query.order('called_at', ascending: false);
      if (res is List) {
        return res
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return const <Map<String, dynamic>>[];
  }

  // ---------------------------------------------------------------------
  // Shipments — createShipment + fetchBordereau (webapp: delivery/push-order
  // functions + supabase edge function get-bordereau).
  // ---------------------------------------------------------------------

  /// Create a shipment for an order and push the delivery flow
  /// (webapp: delivery/push-order.functions → adapter createShipment).
  /// Resolves the ZR Express company for the store, creates the shipment row
  /// and marks the order confirmed (tracking + colis id).
  static Future<bool> createShipment({
    required String storeId,
    required String orderId,
    required String trackingNumber,
    String deliveryType = 'home',
  }) async {
    try {
      String? companyId;
      try {
        final companies = await _db
            .from('delivery_companies')
            .select('id, name')
            .eq('is_active', true);
        if (companies is List) {
          for (final c in companies.whereType<Map>()) {
            final name = (c['name'] ?? '').toString().toLowerCase();
            if (name.contains('zr') || name.contains('procolis')) {
              companyId = (c['id'] ?? '').toString();
              break;
            }
          }
        }
      } catch (_) {}
      if (companyId == null || companyId.isEmpty) {
        return false;
      }
      await _db.from('shipments').insert(<String, dynamic>{
        'store_id': storeId,
        'order_id': orderId,
        'company_id': companyId,
        'tracking_number': trackingNumber,
        'status': 'pending',
        'delivery_type': deliveryType,
      });
      // Mirror the webapp push: mark the order confirmed and carry the colis id.
      await _db.from('orders').update(<String, dynamic>{
        'tracking_number': trackingNumber,
        'status': 'confirmed',
        'zr_colis_id': trackingNumber,
      }).eq('id', orderId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Fetch the ZR Express bordereau (shipping label PDF) for a colis id.
  /// The web app proxies through a server fn (no CORS on server); from a native
  /// client we can call the provider directly with the same attempt sequence.
  /// Returns the PDF as base64, or null on failure.
  static Future<String?> fetchBordereauPdf({
    required String storeId,
    required String colisId,
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) return null;
    try {
      String? token;
      final links = await _db
          .from('store_delivery_companies')
          .select('company_id, api_key')
          .eq('store_id', storeId);
      if (links is List) {
        for (final l in links.whereType<Map>()) {
          final apiKey = (l['api_key'] ?? '').toString();
          if (apiKey.isNotEmpty) {
            token = apiKey;
            break;
          }
        }
      }
      if (token == null || token.isEmpty) return null;
      final client = HttpClient();
      const zrBase = 'https://api.zrexpress.app/api/v1';
      String? pdfBase64;

      Future<void> runGet(String url) async {
        final req = await client.getUrl(Uri.parse(url));
        req.headers.contentType = ContentType.json;
        final res = await req.close();
        final bytes = <int>[];
        await for (final chunk in res) {
          bytes.addAll(chunk);
        }
        final mime = res.headers.contentType?.mimeType ?? '';
        if (mime.contains('pdf') && bytes.isNotEmpty) {
          pdfBase64 = base64Encode(bytes);
          return;
        }
        final text = String.fromCharCodes(bytes);
        if (text.isNotEmpty) {
          try {
            final body = jsonDecode(text) as Map<String, dynamic>;
            final b64 = body['pdf'] as String?;
            if (b64 != null && b64.isNotEmpty) {
              pdfBase64 = b64;
              return;
            }
            final remoteUrl = body['url'] as String?;
            if (remoteUrl != null && remoteUrl.isNotEmpty) {
              final r2 = await client.getUrl(Uri.parse(remoteUrl));
              final res2 = await r2.close();
              final bytes2 = <int>[];
              await for (final c in res2) {
                bytes2.addAll(c);
              }
              if ((res2.headers.contentType?.mimeType ?? '').contains('pdf')) {
                pdfBase64 = base64Encode(bytes2);
                return;
              }
            }
          } catch (_) {}
        }
      }

      await runGet(
        '$zrBase/get_bordereaux?token=${Uri.encodeComponent(token)}&id=${Uri.encodeComponent(colisId)}',
      );
      if (pdfBase64 == null) {
        await runGet(
          '$zrBase/get_bordereaux?token=${Uri.encodeComponent(token)}&ids=${Uri.encodeComponent(colisId)}',
        );
      }
      if (pdfBase64 == null) {
        final req = await client.postUrl(Uri.parse('$zrBase/get_bordereaux'));
        req.headers.contentType = ContentType.json;
        req.write(
          jsonEncode(<String, dynamic>{'token': token, 'ids': <String>[colisId]}),
        );
        final res = await req.close();
        final bytes = <int>[];
        await for (final chunk in res) {
          bytes.addAll(chunk);
        }
        final text = String.fromCharCodes(bytes);
        if (text.isNotEmpty) {
          try {
            final body = jsonDecode(text) as Map<String, dynamic>;
            final b64 = body['pdf'] as String?;
            if (b64 != null && b64.isNotEmpty) pdfBase64 = b64;
          } catch (_) {}
        }
      }
      client.close();
      return pdfBase64;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------
  // Returns & refunds — public.returns table (webapp dashboard.returns).
  // statuses: requested | approved | rejected | received | refunded.
  // ---------------------------------------------------------------------

  static Future<List<Map<String, dynamic>>> listReturns() async {
    final user = _db.auth.currentUser;
    if (user == null) return const <Map<String, dynamic>>[];
    try {
      final res = await _db
          .from('returns')
          .select(
            'id, order_id, store_owner_id, customer_name, customer_email, reason, details, status, refund_amount, created_at',
          )
          .eq('store_owner_id', user.id)
          .order('created_at', ascending: false);
      if (res is List) {
        return res
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return const <Map<String, dynamic>>[];
  }

  /// Create a return request for an order (webapp storefront parity).
  static Future<bool> createReturn({
    required String orderId,
    required String storeOwnerId,
    required String customerName,
    String customerEmail = '',
    required String reason,
    String details = '',
  }) async {
    try {
      await _db.from('returns').insert(<String, dynamic>{
        'order_id': orderId,
        'store_owner_id': storeOwnerId,
        'customer_name': customerName,
        'customer_email': customerEmail,
        'reason': reason,
        'details': details,
        'status': 'requested',
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Approve / reject / mark received / refund a return (webapp parity).
  static Future<bool> updateReturnStatus(
    String returnId,
    String status, {
    double? refundAmount,
  }) async {
    try {
      final values = <String, dynamic>{'status': status};
      if (refundAmount != null) values['refund_amount'] = refundAmount;
      await _db.from('returns').update(values).eq('id', returnId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------
  // Store settings parity (web dashboard.store-settings page).
  // stores: name/category/description/currency/tiktok_pixel_id ·
  // store_settings: chargily_enabled (Payments tab).
  // ---------------------------------------------------------------------

  static Future<Map<String, dynamic>?> getStoreSettings(String storeId) async {
    if (storeId.isEmpty) return null;
    try {
      final res = await _db
          .from('stores')
          .select('id, name, slug, category, description, currency, logo_url, tiktok_pixel_id')
          .eq('id', storeId)
          .maybeSingle();
      if (res == null) return null;
      return Map<String, dynamic>.from(res as Map);
    } catch (_) {}
    return null;
  }

  static Future<bool> updateStoreSettings({
    required String storeId,
    String? name,
    String? category,
    String? description,
    String? currency,
    String? tiktokPixelId,
  }) async {
    if (storeId.isEmpty) return false;
    try {
      final values = <String, dynamic>{};
      if (name != null) values['name'] = name;
      if (category != null) values['category'] = category;
      if (description != null) values['description'] = description;
      if (currency != null) values['currency'] = currency;
      if (tiktokPixelId != null) values['tiktok_pixel_id'] = tiktokPixelId;
      if (values.isEmpty) return true;
      await _db.from('stores').update(values).eq('id', storeId);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool?> getChargilyEnabled() async {
    final user = _db.auth.currentUser;
    if (user == null) return null;
    try {
      final res = await _db
          .from('store_settings')
          .select('chargily_enabled')
          .eq('user_id', user.id)
          .maybeSingle();
      if (res == null) return null;
      return (res as Map)['chargily_enabled'] == true;
    } catch (_) {}
    return null;
  }

  static Future<bool> updateChargilyEnabled(bool enabled) async {
    final user = _db.auth.currentUser;
    if (user == null) return false;
    try {
      await _db
          .from('store_settings')
          .update(<String, dynamic>{'chargily_enabled': enabled})
          .eq('user_id', user.id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------
  // COD manager — cod_collections / cod_transfers (owner scoped).
  // ---------------------------------------------------------------------

  static Future<List<Map<String, dynamic>>> listCodCollections() async {
    final user = _db.auth.currentUser;
    if (user == null) return const <Map<String, dynamic>>[];
    try {
      final res = await _db
          .from('cod_collections')
          .select('*')
          .eq('merchant_id', user.id)
          .order('created_at', ascending: false);
      if (res is List) {
        return res
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return const <Map<String, dynamic>>[];
  }

  static Future<List<Map<String, dynamic>>> listCodTransfers() async {
    final user = _db.auth.currentUser;
    if (user == null) return const <Map<String, dynamic>>[];
    try {
      final res = await _db
          .from('cod_transfers')
          .select('*')
          .eq('merchant_id', user.id)
          .order('transfer_date', ascending: false);
      if (res is List) {
        return res
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return const <Map<String, dynamic>>[];
  }

  /// Insert (or update when expenseId is provided) an operating expense.
  /// Returns the remote row id, or null on failure.
  static Future<String?> upsertExpense({
    String? expenseId,
    required String ownerId,
    required String storeId,
    required String expenseDate,
    required String category,
    required double amount,
    String? note,
  }) async {
    try {
      final res = await _db.from('expenses').upsert(<String, dynamic>{
        if (expenseId != null && expenseId.isNotEmpty) 'id': expenseId,
        'owner_id': ownerId,
        'store_id': storeId,
        'expense_date': expenseDate,
        'category': category,
        'amount': amount,
        'note': note,
      }).select('id').single();
      if (res is Map) {
        return (res['id'] ?? '').toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> deleteExpense({required String expenseId}) async {
    try {
      await _db.from('expenses').delete().eq('id', expenseId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------
  // Products — create/update/delete incl. product_costs + stock.
  // ---------------------------------------------------------------------

  static Future<bool> upsertProduct({
    required String ownerId,
    required String name,
    required double price,
    double? cost,
    required int stock,
    String status = 'active',
  }) async {
    try {
      final res = await _db
          .from('products')
          .insert(<String, dynamic>{
            'user_id': ownerId,
            'name': name,
            'price': price,
            'stock': stock,
            'status': status,
          })
          .select('id, name, price, stock, status')
          .single();
      if (res is Map) {
        final id = (res['id'] ?? '').toString();
        if (id.isNotEmpty && cost != null) {
          await _db.from('product_costs').upsert(<String, dynamic>{
            'product_id': id,
            'owner_id': ownerId,
            'cost_price': cost,
          });
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateProduct({
    required String productId,
    required String ownerId,
    required String name,
    required double price,
    double? cost,
    required int stock,
    String status = 'active',
  }) async {
    try {
      await _db.from('products').update(<String, dynamic>{
        'user_id': ownerId,
        'name': name,
        'price': price,
        'stock': stock,
        'status': status,
      }).eq('id', productId);
      if (cost != null) {
        await _db.from('product_costs').upsert(<String, dynamic>{
          'product_id': productId,
          'owner_id': ownerId,
          'cost_price': cost,
        });
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteProduct({
    required String productId,
    required String ownerId,
  }) async {
    try {
      await _db.from('products').delete().eq('id', productId).eq('user_id', ownerId);
      try {
        await _db.from('product_costs').delete().eq('product_id', productId);
      } catch (_) {}
      return true;
    } catch (_) {
      return false;
    }
  }
}
