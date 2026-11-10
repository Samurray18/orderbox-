import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/algeria_geo.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/fennecly_data_service.dart';
import 'demo_data.dart';

enum DashboardPeriod { days7, days30, all }

class DailyRevenue {
  const DailyRevenue(this.day, this.value);

  final DateTime day;
  final double value;
}

class AppStore extends ChangeNotifier {
  AppStore(this._prefs);

  final SharedPreferences _prefs;

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
  static const _kFenneclyLastSync = 'orderbox.fennecly.lastSync';
  static const _kDataSource = 'orderbox.dataSource'; // local | fennecly

  List<Order> _orders = [];
  List<Product> _products = [];
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('ar');
  bool _onboardingDone = false;
  bool _ready = false;
  String _customStoreName = '';
  String _fenneclyStoreName = '';
  String _fenneclyStoreId = '';
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
  DateTime? get fenneclyLastSync => _fenneclyLastSync;
  bool get isFenneclyData => _dataSource == 'fennecly';
  String get dataSource => _dataSource;

  String storeNameOr(String fallback) {
    if (_fenneclyStoreName.trim().isNotEmpty) return _fenneclyStoreName.trim();
    return _customStoreName.trim().isEmpty ? fallback : _customStoreName.trim();
  }

  void setFenneclyStore({required String name, required String id}) {
    _fenneclyStoreName = name.trim();
    _fenneclyStoreId = id;
    _dataSource = 'fennecly';
    _prefs.setString(_kFenneclyStoreName, _fenneclyStoreName);
    _prefs.setString(_kFenneclyStoreId, _fenneclyStoreId);
    _prefs.setString(_kDataSource, _dataSource);
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
    _fenneclyLastSync = null;
    _prefs.setString(_kDataSource, _dataSource);
    _prefs.remove(_kFenneclyStoreName);
    _prefs.remove(_kFenneclyStoreId);
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
  // Loading / persistence
  // ---------------------------------------------------------------------
  Future<void> load() async {
    final savedLocale = _prefs.getString(_kLocale);
    if (savedLocale == 'ar' || savedLocale == 'fr') {
      _locale = Locale(savedLocale!);
    } else {
      final systemLanguage =
          PlatformDispatcher.instance.locale.languageCode.toLowerCase();
      _locale = systemLanguage == 'fr'
          ? const Locale('fr')
          : const Locale('ar');
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
    _dataSource = _prefs.getString(_kDataSource) ?? 'local';
    final lastSyncRaw = _prefs.getString(_kFenneclyLastSync);
    _fenneclyLastSync = lastSyncRaw == null ? null : DateTime.tryParse(lastSyncRaw);
    _loadShippingOptions();

    final ordersRaw = _prefs.getString(_kOrders);
    if (ordersRaw == null) {
      _orders = DemoData.orders();
      _products = DemoData.products();
      _dataSource = 'local';
      _persistOrders();
      _persistProducts();
    } else {
      _orders = _decodeOrders(ordersRaw);
      _products = _decodeProducts(_prefs.getString(_kProducts));
    }

    _ready = true;
    notifyListeners();
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

  void _persistOrders() {
    _prefs.setString(
      _kOrders,
      jsonEncode(_orders.map((order) => order.toJson()).toList()),
    );
  }

  void _persistProducts() {
    _prefs.setString(
      _kProducts,
      jsonEncode(_products.map((product) => product.toJson()).toList()),
    );
  }

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

  void deleteOrder(String id) {
    _orders.removeWhere((order) => order.id == id);
    _persistOrders();
    notifyListeners();
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
