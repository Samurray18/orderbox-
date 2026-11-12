import 'dart:convert';
import 'dart:ui';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/db/app_database.dart' as db;
import '../../domain/models/algeria_geo.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/fennecly_data_service.dart';
import '../services/fennecly_supabase.dart';
import 'demo_data.dart';

enum DashboardPeriod { days7, days30, all }

class DailyRevenue {
  const DailyRevenue(this.day, this.value);

  final DateTime day;
  final double value;
}

/// Operating expense (web parity: private `expenses` table —
/// categories ads | packaging | salary | rent | software | other).
class Expense {
  const Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
    this.note = '',
    this.remoteId,
  });

  final String id;
  final DateTime date;
  final String category;
  final double amount;
  final String note;
  final String? remoteId;

  Expense copyWith({DateTime? date, String? category, double? amount, String? note}) =>
      Expense(
        id: id,
        date: date ?? this.date,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        remoteId: remoteId,
      );

  Expense withRemoteId(String remoteId) => Expense(
        id: id,
        date: date,
        category: category,
        amount: amount,
        note: note,
        remoteId: remoteId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'category': category,
        'amount': amount,
        'note': note,
        if (remoteId != null) 'remoteId': remoteId,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: (json['id'] ?? '').toString(),
        date: DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
        category: (json['category'] ?? 'other').toString(),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        note: (json['note'] ?? '').toString(),
        remoteId: json['remoteId']?.toString(),
      );
}

class AppStore extends ChangeNotifier {
  AppStore(this._prefs, this._db);

  final SharedPreferences _prefs;
  final db.AppDatabase _db;

  static const _kOrders = 'orderbox.orders.v1';
  static const _kProducts = 'orderbox.products.v1';
  static const _kTheme = 'orderbox.theme';
  static const _kLocale = 'orderbox.locale';
  static const _kOnboarding = 'orderbox.onboarding';
  static const _kStoreName = 'orderbox.storeName';
  static const _kShipping = 'orderbox.shipping.v1';
  static const _kDeliveryCompanies = 'orderbox.delivery_companies.v1';
  static const _kDefaultCompany = 'orderbox.default_company.v1';
  static const _kFenneclyStoreName = 'orderbox.fennecly.storeName';
  static const _kFenneclyStoreId = 'orderbox.fennecly.storeId';
  static const _kFenneclyStoreLogoUrl = 'orderbox.fennecly.storeLogoUrl';
  static const _kFenneclyProfileName = 'orderbox.fennecly.profileName';
  static const _kFenneclyProfileEmail = 'orderbox.fennecly.profileEmail';
  static const _kFenneclyAvatarUrl = 'orderbox.fennecly.avatarUrl';
  static const _kFenneclyLastSync = 'orderbox.fennecly.lastSync';
  static const _kDataSource = 'orderbox.dataSource'; // local | fennecly
  static const _kMigratedToDrift = 'orderbox.migrated.drift.v3';
  static const _kExpenses = 'orderbox.expenses.v1';

  List<Order> _orders = [];
  List<Product> _products = [];
  List<Expense> _expenses = [];
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _onboardingDone = false;
  bool _ready = false;
  String _customStoreName = '';
  String _fenneclyStoreName = '';
  String _fenneclyStoreId = '';
  String _fenneclyStoreLogoUrl = '';
  String _fenneclyProfileName = '';
  String _fenneclyProfileEmail = '';
  String _fenneclyAvatarUrl = '';
  DateTime? _fenneclyLastSync;
  String _dataSource = 'local';
  // Fennecly-inspired shipping options: delivery companies + wilaya home/office tariffs
  List<String> _deliveryCompanies = List<String>.from(AlgeriaGeo.deliveryCompanies);
  String _defaultDeliveryCompany = 'Yalidine';
  Map<String, Map<String, double>> _shippingPrices = {}; // wilayaCode -> {home, office}

  // ---------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------
  bool get isReady => _ready;

  ThemeMode get themeMode => _themeMode;

  Locale get locale => _locale;

  bool get onboardingDone => _onboardingDone;

  String get customStoreName => _customStoreName;
  String get fenneclyStoreName => _fenneclyStoreName;
  String get fenneclyStoreId => _fenneclyStoreId;
  String get fenneclyStoreLogoUrl => _fenneclyStoreLogoUrl;
  String get fenneclyProfileName => _fenneclyProfileName;
  String get fenneclyProfileEmail => _fenneclyProfileEmail;
  String get fenneclyAvatarUrl => _fenneclyAvatarUrl;
  DateTime? get fenneclyLastSync => _fenneclyLastSync;
  bool get isFenneclyData => _dataSource == 'fennecly';
  String get dataSource => _dataSource;

  String storeNameOr(String fallback) {
    if (_fenneclyStoreName.trim().isNotEmpty) return _fenneclyStoreName.trim();
    return _customStoreName.trim().isEmpty ? fallback : _customStoreName.trim();
  }

  void setFenneclyStore({
    required String name,
    required String id,
    String? logoUrl,
  }) {
    _fenneclyStoreName = name.trim();
    _fenneclyStoreId = id;
    if (logoUrl != null && logoUrl.trim().isNotEmpty) {
      _fenneclyStoreLogoUrl = logoUrl.trim();
      _prefs.setString(_kFenneclyStoreLogoUrl, _fenneclyStoreLogoUrl);
    }
    _dataSource = 'fennecly';
    _prefs.setString(_kFenneclyStoreName, _fenneclyStoreName);
    _prefs.setString(_kFenneclyStoreId, _fenneclyStoreId);
    _prefs.setString(_kDataSource, _dataSource);
    notifyListeners();
  }

  void setFenneclyProfile({String? name, String? email, String? avatarUrl}) {
    final nextName = name?.trim() ?? '';
    final nextEmail = email?.trim() ?? '';
    final nextAvatar = avatarUrl?.trim() ?? '';
    _fenneclyProfileName = nextName;
    _fenneclyProfileEmail = nextEmail;
    _fenneclyAvatarUrl = nextAvatar;
    _prefs.setString(_kFenneclyProfileName, nextName);
    _prefs.setString(_kFenneclyProfileEmail, nextEmail);
    _prefs.setString(_kFenneclyAvatarUrl, nextAvatar);
    notifyListeners();
  }

  void markFenneclySynced() {
    _dataSource = 'fennecly';
    _fenneclyLastSync = DateTime.now();
    _prefs.setString(_kDataSource, _dataSource);
    _prefs.setString(_kFenneclyLastSync, _fenneclyLastSync!.toIso8601String());
    notifyListeners();
  }

  void clearFenneclySource() {
    _dataSource = 'local';
    _fenneclyStoreName = '';
    _fenneclyStoreId = '';
    _fenneclyStoreLogoUrl = '';
    _fenneclyProfileName = '';
    _fenneclyProfileEmail = '';
    _fenneclyAvatarUrl = '';
    _fenneclyLastSync = null;
    _prefs.setString(_kDataSource, _dataSource);
    _prefs.remove(_kFenneclyStoreName);
    _prefs.remove(_kFenneclyStoreId);
    _prefs.remove(_kFenneclyStoreLogoUrl);
    _prefs.remove(_kFenneclyProfileName);
    _prefs.remove(_kFenneclyProfileEmail);
    _prefs.remove(_kFenneclyAvatarUrl);
    _prefs.remove(_kFenneclyLastSync);
    notifyListeners();
  }

  void replaceOrders(List<Order> list) {
    _orders = [...list];
    _persistOrders();
    notifyListeners();
  }

  void replaceProducts(List<Product> list) {
    _products = [...list];
    _persistProducts();
    notifyListeners();
  }

  // Shipping options (fennecly: delivery companies + wilaya home/office tariffs)
  List<String> get deliveryCompanies => List.unmodifiable(_deliveryCompanies);
  String get defaultDeliveryCompany => _defaultDeliveryCompany;

  double shippingFee(String wilayaCode, String deliveryType) {
    final row = _shippingPrices[wilayaCode];
    if (row == null) return deliveryType == 'office' ? 350 : 600;
    final v = row[deliveryType == 'office' ? 'office' : 'home'];
    return (v ?? (deliveryType == 'office' ? 350 : 600));
  }

  Map<String, double> shippingRow(String wilayaCode) {
    final row = _shippingPrices[wilayaCode];
    return {
      'home': row?['home'] ?? 600,
      'office': row?['office'] ?? 350,
    };
  }

  Map<String, Map<String, double>> get shippingPrices => {
        for (final e in _shippingPrices.entries)
          e.key: {'home': e.value['home'] ?? 600, 'office': e.value['office'] ?? 350},
      };

  List<Order> get orders {
    final list = [..._orders];
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<Product> get products {
    final list = [..._products];
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  Product? productById(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Loading / persistence (drift SQLite for orders/products/customers)
  // ---------------------------------------------------------------------
  Future<void> load() async {
    final savedLocale = _prefs.getString(_kLocale);
    if (savedLocale == 'ar' || savedLocale == 'fr' || savedLocale == 'en') {
      _locale = Locale(savedLocale!);
    } else {
      final systemLanguage =
          PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      _locale = (systemLanguage == 'ar' || systemLanguage == 'fr')
          ? Locale(systemLanguage == 'ar' ? 'ar' : 'fr')
          : const Locale('en');
    }

    final savedTheme = _prefs.getString(_kTheme);
    _themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == savedTheme,
      orElse: () => ThemeMode.system,
    );
    _onboardingDone = _prefs.getBool(_kOnboarding) ?? false;
    _customStoreName = _prefs.getString(_kStoreName) ?? '';
    _fenneclyStoreName = _prefs.getString(_kFenneclyStoreName) ?? '';
    _fenneclyStoreId = _prefs.getString(_kFenneclyStoreId) ?? '';
    _fenneclyStoreLogoUrl = _prefs.getString(_kFenneclyStoreLogoUrl) ?? '';
    _fenneclyProfileName = _prefs.getString(_kFenneclyProfileName) ?? '';
    _fenneclyProfileEmail = _prefs.getString(_kFenneclyProfileEmail) ?? '';
    _fenneclyAvatarUrl = _prefs.getString(_kFenneclyAvatarUrl) ?? '';
    _dataSource = _prefs.getString(_kDataSource) ?? 'local';
    final lastSyncRaw = _prefs.getString(_kFenneclyLastSync);
    _fenneclyLastSync = lastSyncRaw == null ? null : DateTime.tryParse(lastSyncRaw);
    _loadShippingOptions();
    _loadExpenses();

    await _migrateLegacyPrefsToDriftIfNeeded();

    _orders = (await _db.getAllOrders()).map(_orderFromDb).toList();
    _products = (await _db.getAllProducts()).map(_productFromDb).toList();

    // First run (no legacy, empty drift): seed demo data locally.
    if (_orders.isEmpty && _products.isEmpty && !_prefs.containsKey(_kMigratedToDrift)) {
      _orders = DemoData.orders();
      _products = DemoData.products();
      await _persistOrders();
      await _persistProducts();
      await _prefs.setBool(_kMigratedToDrift, true);
      await _prefs.remove(_kOrders);
      await _prefs.remove(_kProducts);
    }

    _ready = true;
    notifyListeners();
  }

  Future<void> _migrateLegacyPrefsToDriftIfNeeded() async {
    if (_prefs.getBool(_kMigratedToDrift) == true) return;
    final ordersRaw = _prefs.getString(_kOrders);
    final productsRaw = _prefs.getString(_kProducts);
    if (ordersRaw == null && productsRaw == null) {
      // nothing to migrate (either fresh install or already clean)
      // mark migrated only if drift already has data; otherwise let load() seed demo
      final existingOrders = await _db.getAllOrders();
      final existingProducts = await _db.getAllProducts();
      if (existingOrders.isNotEmpty || existingProducts.isNotEmpty) {
        await _prefs.setBool(_kMigratedToDrift, true);
      }
      return;
    }
    final legacyOrders = _decodeOrders(ordersRaw);
    final legacyProducts = _decodeProducts(productsRaw);
    if (legacyOrders.isNotEmpty) {
      await _db.replaceAllOrders(legacyOrders.map(_orderToCompanion).toList());
    }
    if (legacyProducts.isNotEmpty) {
      await _db.replaceAllProducts(legacyProducts.map(_productToCompanion).toList());
    }
    await _prefs.setBool(_kMigratedToDrift, true);
    await _prefs.remove(_kOrders);
    await _prefs.remove(_kProducts);
  }

  List<Order> _decodeOrders(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  List<Product> _decodeProducts(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _persistOrders() async {
    await _db.replaceAllOrders(_orders.map(_orderToCompanion).toList());
  }

  Future<void> _persistProducts() async {
    await _db.replaceAllProducts(_products.map(_productToCompanion).toList());
  }

  // Drift mapping
  Order _orderFromDb(db.Order r) => Order(
        id: r.id,
        reference: r.reference,
        customerName: r.customerName,
        phone: r.phone,
        wilayaCode: r.wilayaCode,
        wilayaName: r.wilayaName,
        wilayaNameAr: r.wilayaNameAr,
        commune: r.commune,
        address: r.address,
        productId: r.productId,
        productName: r.productName,
        quantity: r.quantity,
        unitPrice: r.unitPrice,
        costPrice: r.costPrice,
        deliveryPrice: r.deliveryPrice,
        status: OrderStatusX.fromId(r.status),
        createdAt: r.createdAt,
        notes: r.notes,
        deliveryCompany: r.deliveryCompany,
        deliveryType: r.deliveryType,
        trackingNumber: r.trackingNumber,
        codPaidByCompany: r.codPaidByCompany,
      );

  db.OrdersCompanion _orderToCompanion(Order o) => db.OrdersCompanion.insert(
        id: o.id,
        reference: Value(o.reference),
        customerName: o.customerName,
        phone: o.phone,
        wilayaCode: Value(o.wilayaCode),
        wilayaName: Value(o.wilayaName),
        wilayaNameAr: Value(o.wilayaNameAr),
        commune: Value(o.commune),
        address: Value(o.address),
        productId: Value(o.productId),
        productName: o.productName,
        quantity: Value(o.quantity),
        unitPrice: Value(o.unitPrice),
        costPrice: Value(o.costPrice),
        deliveryPrice: Value(o.deliveryPrice),
        deliveryType: Value(o.deliveryType),
        status: Value(o.status.id),
        deliveryCompany: Value(o.deliveryCompany),
        trackingNumber: Value(o.trackingNumber),
        codPaidByCompany: Value(o.codPaidByCompany),
        notes: Value(o.notes),
        createdAt: o.createdAt,
        updatedAt: Value(DateTime.now()),
      );

  Product _productFromDb(db.Product r) => Product(
        id: r.id,
        name: r.name,
        price: r.price,
        cost: r.cost,
        stock: r.stock,
        createdAt: r.createdAt,
      );

  db.ProductsCompanion _productToCompanion(Product p) => db.ProductsCompanion.insert(
        id: p.id,
        name: p.name,
        price: Value(p.price),
        cost: Value(p.cost),
        stock: Value(p.stock),
        createdAt: p.createdAt,
      );

  void _loadShippingOptions() {
    final companiesRaw = _prefs.getString(_kDeliveryCompanies);
    if (companiesRaw != null && companiesRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(companiesRaw) as List<dynamic>;
        final list = decoded.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
        if (list.isNotEmpty) _deliveryCompanies = list;
      } catch (_) {}
    }
    _defaultDeliveryCompany = _prefs.getString(_kDefaultCompany) ?? _defaultDeliveryCompany;
    if (!_deliveryCompanies.contains(_defaultDeliveryCompany) && _deliveryCompanies.isNotEmpty) {
      _defaultDeliveryCompany = _deliveryCompanies.first;
    }
    final shippingRaw = _prefs.getString(_kShipping);
    _shippingPrices = {};
    if (shippingRaw != null && shippingRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(shippingRaw) as Map<String, dynamic>;
        for (final e in decoded.entries) {
          final v = e.value as Map<String, dynamic>?;
          if (v == null) continue;
          _shippingPrices[e.key] = {
            'home': (v['home'] as num?)?.toDouble() ?? 600,
            'office': (v['office'] as num?)?.toDouble() ?? 350,
          };
        }
      } catch (_) {}
    }
    _ensureAllWilayaPrices();
  }

  void _ensureAllWilayaPrices() {
    for (var i = 1; i <= 58; i++) {
      final code = i.toString().padLeft(2, '0');
      _shippingPrices.putIfAbsent(code, () => {'home': 600.0, 'office': 350.0});
    }
  }

  void _persistShippingOptions() {
    _prefs.setString(_kDeliveryCompanies, jsonEncode(_deliveryCompanies));
    _prefs.setString(_kDefaultCompany, _defaultDeliveryCompany);
    _prefs.setString(_kShipping, jsonEncode(_shippingPrices));
  }

  void setDefaultDeliveryCompany(String name) {
    if (name.trim().isEmpty) return;
    _defaultDeliveryCompany = name.trim();
    _persistShippingOptions();
    notifyListeners();
  }

  void setShippingPrice(String wilayaCode, {double? home, double? office}) {
    final row = Map<String, double>.from(_shippingPrices[wilayaCode] ?? {'home': 600.0, 'office': 350.0});
    if (home != null) row['home'] = home;
    if (office != null) row['office'] = office;
    _shippingPrices[wilayaCode] = row;
    _persistShippingOptions();
    notifyListeners();
  }

  void setAllShippingPrices({required double home, required double office}) {
    for (var i = 1; i <= 58; i++) {
      final code = i.toString().padLeft(2, '0');
      _shippingPrices[code] = {'home': home, 'office': office};
    }
    _persistShippingOptions();
    notifyListeners();
  }

  void addDeliveryCompany(String name) {
    final n = name.trim();
    if (n.isEmpty || _deliveryCompanies.contains(n)) return;
    _deliveryCompanies.add(n);
    _persistShippingOptions();
    notifyListeners();
  }

  void removeDeliveryCompany(String name) {
    _deliveryCompanies.remove(name);
    if (_defaultDeliveryCompany == name && _deliveryCompanies.isNotEmpty) {
      _defaultDeliveryCompany = _deliveryCompanies.first;
    }
    _persistShippingOptions();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------
  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    _prefs.setString(_kTheme, mode.name);
    notifyListeners();
  }

  void setLocale(Locale locale) {
    if (locale.languageCode == _locale.languageCode) return;
    _locale = Locale(locale.languageCode);
    _prefs.setString(_kLocale, locale.languageCode);
    notifyListeners();
  }

  void setStoreName(String name) {
    _customStoreName = name.trim();
    _prefs.setString(_kStoreName, _customStoreName);
    notifyListeners();
  }

  void completeOnboarding() {
    if (_onboardingDone) return;
    _onboardingDone = true;
    _prefs.setBool(_kOnboarding, true);
    notifyListeners();
  }

  void resetOnboarding() {
    _onboardingDone = false;
    _prefs.setBool(_kOnboarding, false);
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Orders CRUD
  // ---------------------------------------------------------------------
  String nextReference() {
    var max = 1000;
    for (final order in _orders) {
      final digits = int.tryParse(
        order.reference.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (digits != null && digits > max) max = digits;
    }
    return 'OB-${max + 1}';
  }

  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  void addOrder(Order order) {
    _orders.add(order);
    _persistOrders();
    notifyListeners();
  }

  void updateOrder(Order order) {
    final index = _orders.indexWhere((item) => item.id == order.id);
    if (index == -1) return;
    _orders[index] = order;
    _persistOrders();
    notifyListeners();
  }

  void updateOrderStatus(Order order, OrderStatus status) {
    if (order.status == status) return;
    final prev = order.status;
    // v2 stock rules (idempotent by transition): reduce on Shipped, restore if Returned.
    final wasOut = prev == OrderStatus.shipped || prev == OrderStatus.delivered;
    final becomesOut = status == OrderStatus.shipped || status == OrderStatus.delivered;
    if (!wasOut && becomesOut) {
      _adjustProductStock(order.productId, -order.quantity);
    } else if (wasOut && status == OrderStatus.returned) {
      _adjustProductStock(order.productId, order.quantity);
    } else if (wasOut && status == OrderStatus.cancelled) {
      // cancelled after shipment: restore stock (safe default)
      _adjustProductStock(order.productId, order.quantity);
    }
    updateOrder(order.copyWith(status: status));
    // Same DB: push status to Fennecly when synced from Fennecly (UUID ids)
    if (_dataSource == 'fennecly' && _isUuid(order.id)) {
      FenneclyDataService.updateOrderStatus(order.id, status);
    }
  }

  bool _isUuid(String s) =>
      RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(s);

  void _adjustProductStock(String productId, int delta) {
    if (productId.isEmpty || delta == 0) return;
    final i = _products.indexWhere((p) => p.id == productId);
    if (i == -1) return;
    final next = _products[i].stock + delta;
    _products[i] = _products[i].copyWith(stock: next < 0 ? 0 : next);
    _persistProducts();
  }

  // COD owed: delivered orders not yet paid by delivery company
  double codOwedToSeller([Iterable<Order>? list]) {
    final src = list ?? _orders;
    return src
        .where((o) => o.status == OrderStatus.delivered && !o.codPaidByCompany)
        .fold(0.0, (s, o) => s + o.total);
  }

  // ---------------------------------------------------------------------------
  // Expenses (profit page) — local-first with remote write-through to the
  // webapp `expenses` table when signed in.
  // ---------------------------------------------------------------------------
  List<Expense> get expenses {
    final list = [..._expenses];
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double get expensesTotal =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  void _loadExpenses() {
    final raw = _prefs.getString(_kExpenses);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _expenses = decoded
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  void _persistExpenses() {
    _prefs.setString(
      _kExpenses,
      jsonEncode(_expenses.map((e) => e.toJson()).toList()),
    );
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    _persistExpenses();
    notifyListeners();
    _syncExpense(expense, deleting: false);
  }

  void updateExpense(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index == -1) return;
    _expenses[index] = expense;
    _persistExpenses();
    notifyListeners();
    _syncExpense(_expenses[index], deleting: false);
  }

  void deleteExpense(Expense expense) {
    _expenses.removeWhere((e) => e.id == expense.id);
    _persistExpenses();
    notifyListeners();
    _syncExpense(expense, deleting: true);
  }

  void _syncExpense(Expense expense, {required bool deleting}) {
    if (!FenneclySupabase.isLoggedIn) return;
    // Fire and forget: never block the UI on the shared DB.
    Future<void>(() async {
      try {
        final storeInfo = await FenneclyDataService.resolveCurrentStore();
        final ownerId =
            storeInfo?.ownerId ?? FenneclySupabase.client.auth.currentUser?.id ?? '';
        final storeId = storeInfo?.id ?? '';
        if (deleting) {
          final remoteId = expense.remoteId;
          if (remoteId != null && remoteId.isNotEmpty) {
            await FenneclyDataService.deleteExpense(expenseId: remoteId);
          }
          return;
        }
        final date = expense.date;
        final remoteId = await FenneclyDataService.upsertExpense(
          expenseId: expense.remoteId,
          ownerId: ownerId,
          storeId: storeId,
          expenseDate:
              '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          category: expense.category,
          amount: expense.amount,
          note: expense.note.isEmpty ? null : expense.note,
        );
        if (remoteId != null && remoteId.isNotEmpty) {
          final index = _expenses.indexWhere((e) => e.id == expense.id);
          if (index != -1) {
            _expenses[index] = _expenses[index].withRemoteId(remoteId);
            _persistExpenses();
          }
        }
      } catch (_) {}
    });
  }

  void deleteOrder(String id) {
    _orders.removeWhere((order) => order.id == id);
    _persistOrders();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Phase 1: remote (Fennecly Supabase) write-through for orders.
  // Mirrors the webapp createOrder/updateOrder server actions so the mobile
  // app can create/edit orders in the shared DB, not only locally.
  // ---------------------------------------------------------------------
  Future<void> createOrderInFennecly(Order order) async {
    if (!FenneclySupabase.isLoggedIn) return;
    try {
      final storeInfo = await FenneclyDataService.resolveCurrentStore();
      final ownerId = storeInfo?.ownerId ?? FenneclySupabase.client.auth.currentUser?.id ?? '';
      final slug = storeInfo?.slug ?? 'store-${ownerId.substring(0, 8)}';
      final deliveryType = order.deliveryType == 'office' ? 'stopdesk' : 'domicile';
      final orderId = await FenneclyDataService.createOrder(
        storeOwnerId: ownerId,
        storeSlug: slug,
        customerName: order.customerName,
        customerEmail: '',
        customerPhone: order.phone,
        shippingAddress: order.address,
        shippingCity: order.commune,
        shippingPostalCode: order.wilayaCode,
        shippingCountry: 'Algeria',
        subtotal: order.subtotal,
        total: order.total,
        status: order.status.fenneclyId,
        deliveryType: deliveryType,
        notes: order.notes,
        source: _dataSource == 'fennecly' ? 'fennecly' : 'mobile',
        items: <Map<String, dynamic>>[
          <String, dynamic>{
            'product_id': order.productId,
            'product_name': order.productName,
            'unit_price': order.unitPrice,
            'quantity': order.quantity,
            'image_url': null,
          },
        ],
      );
      if (orderId != null && orderId != order.id) {
        updateOrder(Order(
          id: orderId,
          reference: order.reference,
          customerName: order.customerName,
          phone: order.phone,
          wilayaCode: order.wilayaCode,
          wilayaName: order.wilayaName,
          wilayaNameAr: order.wilayaNameAr,
          commune: order.commune,
          address: order.address,
          productId: order.productId,
          productName: order.productName,
          quantity: order.quantity,
          unitPrice: order.unitPrice,
          costPrice: order.costPrice,
          deliveryPrice: order.deliveryPrice,
          status: order.status,
          createdAt: order.createdAt,
          notes: order.notes,
          deliveryCompany: order.deliveryCompany,
          deliveryType: order.deliveryType,
          trackingNumber: order.trackingNumber,
          codPaidByCompany: order.codPaidByCompany,
        ));
      }
    } catch (_) {}
  }

  Future<void> updateOrderInFennecly(Order order) async {
    if (!FenneclySupabase.isLoggedIn) return;
    try {
      final storeInfo = await FenneclyDataService.resolveCurrentStore();
      final ownerId = storeInfo?.ownerId ?? FenneclySupabase.client.auth.currentUser?.id ?? '';
      await FenneclyDataService.updateOrder(
        orderId: order.id,
        storeOwnerId: ownerId,
        customerName: order.customerName,
        customerPhone: order.phone,
        shippingAddress: order.address,
        shippingCity: order.commune,
        shippingPostalCode: order.wilayaCode,
        notes: order.notes,
        subtotal: order.subtotal,
        total: order.total,
        status: order.status.fenneclyId,
        deliveryType: order.deliveryType == 'office' ? 'stopdesk' : 'domicile',
        deliveryCompany: order.deliveryCompany,
        trackingNumber: order.trackingNumber,
      );
    } catch (_) {}
  }

  Future<void> deleteOrderInFennecly(Order order) async {
    if (!FenneclySupabase.isLoggedIn) return;
    try {
      final storeInfo = await FenneclyDataService.resolveCurrentStore();
      final ownerId = storeInfo?.ownerId ?? FenneclySupabase.client.auth.currentUser?.id ?? '';
      await FenneclyDataService.deleteOrder(orderId: order.id, storeOwnerId: ownerId);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------
  // Products CRUD
  // ---------------------------------------------------------------------
  void addProduct(Product product) {
    _products.add(product);
    _persistProducts();
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index == -1) return;
    _products[index] = product;
    _persistProducts();
    notifyListeners();
  }

  void deleteProduct(String id) {
    _products.removeWhere((product) => product.id == id);
    _persistProducts();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Phase 1: remote (Fennecly Supabase) product write-through — create /
  // update incl. product_costs + stock, delete (products + product_costs).
  // ---------------------------------------------------------------------
  Future<void> createProductInFennecly(Product product) async {
    if (!FenneclySupabase.isLoggedIn) return;
    try {
      final ownerId = FenneclySupabase.client.auth.currentUser?.id ?? '';
      final created = await FenneclyDataService.upsertProduct(
        ownerId: ownerId,
        name: product.name,
        price: product.price,
        cost: product.cost > 0 ? product.cost : null,
        stock: product.stock,
      );
      if (created) addProduct(product);
    } catch (_) {}
  }

  Future<void> updateProductInFennecly(Product product) async {
    if (!FenneclySupabase.isLoggedIn) return;
    try {
      final ownerId = FenneclySupabase.client.auth.currentUser?.id ?? '';
      final updated = await FenneclyDataService.updateProduct(
        productId: product.id,
        ownerId: ownerId,
        name: product.name,
        price: product.price,
        cost: product.cost > 0 ? product.cost : null,
        stock: product.stock,
      );
      if (updated) updateProduct(product);
    } catch (_) {}
  }

  Future<void> deleteProductInFennecly(Product product) async {
    if (!FenneclySupabase.isLoggedIn) return;
    try {
      final ownerId = FenneclySupabase.client.auth.currentUser?.id ?? '';
      final deleted = await FenneclyDataService.deleteProduct(
        productId: product.id,
        ownerId: ownerId,
      );
      if (deleted) deleteProduct(product.id);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------
  // Data management
  // ---------------------------------------------------------------------
  void clearAllData() {
    _orders = [];
    _products = [];
    _persistOrders();
    _persistProducts();
    notifyListeners();
  }

  void restoreDemoData() {
    _orders = DemoData.orders();
    _products = DemoData.products();
    _persistOrders();
    _persistProducts();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Stats
  // ---------------------------------------------------------------------
  List<Order> ordersInPeriod(DashboardPeriod period) {
    if (period == DashboardPeriod.all) return orders;
    final days = period == DashboardPeriod.days7 ? 7 : 30;
    final now = DateTime.now();
    final start = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));
    return orders.where((order) => !order.createdAt.isBefore(start)).toList();
  }

  double revenueOf(Iterable<Order> list) {
    return list
        .where((order) => order.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.total);
  }

  double profitOf(Iterable<Order> list) {
    return list
        .where((order) => order.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.profit);
  }

  int deliveredCountOf(Iterable<Order> list) =>
      list.where((order) => order.status == OrderStatus.delivered).length;

  int returnedCountOf(Iterable<Order> list) =>
      list.where((order) => order.status == OrderStatus.returned).length;

  int awaitingConfirmationOf(Iterable<Order> list) => list
      .where(
        (order) =>
            order.status == OrderStatus.newOrder ||
            order.status == OrderStatus.noAnswer,
      )
      .length;

  double returnRateOf(Iterable<Order> list) {
    final delivered = deliveredCountOf(list);
    final returned = returnedCountOf(list);
    final denominator = delivered + returned;
    if (denominator == 0) return 0;
    return returned / denominator * 100;
  }

  double marginOf(Iterable<Order> list) {
    final revenue = revenueOf(list);
    if (revenue == 0) return 0;
    return profitOf(list) / revenue * 100;
  }

  double averageOrderOf(Iterable<Order> list) {
    final delivered = deliveredCountOf(list);
    if (delivered == 0) return 0;
    return revenueOf(list) / delivered;
  }

  double growthPercent(DashboardPeriod period) {
    if (period == DashboardPeriod.all) return 0;
    final days = period == DashboardPeriod.days7 ? 7 : 30;
    final now = DateTime.now();
    final currentStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));
    final previousStart = currentStart.subtract(Duration(days: days));
    final current = revenueOf(
      _orders.where((order) => !order.createdAt.isBefore(currentStart)),
    );
    final previous = revenueOf(
      _orders.where(
        (order) =>
            !order.createdAt.isBefore(previousStart) &&
            order.createdAt.isBefore(currentStart),
      ),
    );
    if (previous == 0) return current > 0 ? 100 : 0;
    return (current - previous) / previous * 100;
  }

  List<DailyRevenue> dailyRevenue(int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <DailyRevenue>[];
    for (var index = days - 1; index >= 0; index--) {
      final day = today.subtract(Duration(days: index));
      final next = day.add(const Duration(days: 1));
      final value = revenueOf(
        _orders.where(
          (order) =>
              order.status == OrderStatus.delivered &&
              !order.createdAt.isBefore(day) &&
              order.createdAt.isBefore(next),
        ),
      );
      result.add(DailyRevenue(day, value));
    }
    return result;
  }

  Map<OrderStatus, int> statusCountsOf(Iterable<Order> list) {
    final counts = {for (final status in OrderStatus.values) status: 0};
    for (final order in list) {
      counts[order.status] = (counts[order.status] ?? 0) + 1;
    }
    return counts;
  }

  int countToday(Iterable<Order> list) {
    final now = DateTime.now();
    return list
        .where(
          (order) =>
              order.createdAt.year == now.year &&
              order.createdAt.month == now.month &&
              order.createdAt.day == now.day,
        )
        .length;
  }

  List<Order> recent({int limit = 4}) {
    final sorted = orders;
    if (sorted.length <= limit) return sorted;
    return sorted.sublist(0, limit);
  }
}
