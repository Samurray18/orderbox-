import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/product.dart';

/// Low-stock alerts (Phase 1 parity with the web stock warnings).
///
/// Local notifications only — no network. The merchant hears a single
/// nudge per app run listing the products that need a restock.
abstract final class StockAlertService {
  static const lowStockThreshold = 5;

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _notifiedThisRun = false;

  static List<Product> lowStockProducts(List<Product> products) =>
      products.where((p) => p.stock >= 0 && p.stock <= lowStockThreshold).toList();

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        settings: const InitializationSettings(android: android, iOS: ios),
      );
      _initialized = true;
    } catch (_) {
      // Notifications unavailable (e.g. platform mismatch): silently skip.
    }
  }

  static Future<void> checkAndNotify({
    required List<Product> products,
    bool isArabic = false,
  }) async {
    if (_notifiedThisRun) return;
    final low = lowStockProducts(products);
    if (low.isEmpty) return;
    await _ensureInitialized();
    if (!_initialized) return;

    final first = low.take(3).map((p) => p.name).join(', ');
    final more = low.length - math.min(3, low.length);
    final title = isArabic
        ? 'تنبيه: مخزون منخفض'
        : 'Alerte : stock faible';
    final body = isArabic
        ? '$first${more > 0 ? ' +$more' : ''} — أضف كمية'
        : '$first${more > 0 ? ' +$more' : ''} — pensez à réapprovisionner';

    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        // Ask permission the first time we actually have something to show.
        final granted =
            await _plugin
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(alert: true, badge: true, sound: true);
        if (granted != true) return;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final granted =
            await _plugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.requestNotificationsPermission();
        if (granted == false) return;
      }
      await _plugin.show(
        id: DateTime.now().millisecondsSinceEpoch % 0x7fffffff,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'stock_alerts',
            'Stock alerts',
            channelDescription: 'Low stock reminders',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
      _notifiedThisRun = true;
    } catch (_) {
      // Never block the UI on notifications.
    }
  }
}
