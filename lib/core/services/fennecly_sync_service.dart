import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/app_store.dart';
import 'fennecly_supabase.dart';

/// Pulls delivery companies and shipping tariffs from the Fennecly Supabase DB
/// into the local AppStore (offline-first cache).
class FenneclySyncService {
  static SupabaseClient get _db => FenneclySupabase.client;

  static Future<({int companies, int tariffs, String? error})> syncShipping(
      AppStore store) async {
    var companies = 0;
    var tariffs = 0;
    try {
      // 1) Delivery companies (active/public)
      try {
        final rows = await _db
            .from('delivery_companies')
            .select('name')
            .eq('is_active', true)
            .order('name');
        for (final r in (rows as List)) {
          final name = (r['name'] ?? '').toString().trim();
          if (name.isNotEmpty) {
            store.addDeliveryCompany(name);
            companies++;
          }
        }
      } catch (_) {
        // try without filter
        try {
          final rows = await _db.from('delivery_companies').select('name').order('name');
          for (final r in (rows as List)) {
            final name = (r['name'] ?? '').toString().trim();
            if (name.isNotEmpty) {
              store.addDeliveryCompany(name);
              companies++;
            }
          }
        } catch (_) {}
      }

      // 2) Delivery tariffs (owner-scoped in fennecly; try common owner columns)
      final uid = _db.auth.currentUser?.id;
      List<dynamic> trows = const [];
      if (uid != null) {
        for (final ownerCol in const ['owner_id', 'store_id', 'user_id']) {
          try {
            final res = await _db.from('delivery_tariffs').select('*').eq(ownerCol, uid);
            if (res is List && res.isNotEmpty) {
              trows = res;
              break;
            }
          } catch (_) {}
        }
      }
      // Fallback: try readable rows (RLS may allow) - limit to avoid huge pulls
      if (trows.isEmpty) {
        try {
          trows = await _db.from('delivery_tariffs').select('*').limit(5000);
        } catch (_) {}
      }

      for (final r in trows) {
        if (r is! Map) continue;
        final wilayaRaw = (r['wilaya'] ?? r['wilaya_code'] ?? r['wilayaCode'] ?? '').toString();
        final code = _resolveWilayaCode(wilayaRaw);
        if (code == null) continue;
        final typeRaw = (r['delivery_type'] ?? r['type'] ?? r['deliveryType'] ?? 'home').toString().toLowerCase();
        final isOffice = typeRaw.contains('stop') || typeRaw.contains('desk') || typeRaw.contains('office') || typeRaw.contains('bureau');
        final price = _toDouble(r['price'] ?? r['tarif'] ?? r['fee']);
        if (price == null) continue;
        store.setShippingPrice(code, home: isOffice ? null : price, office: isOffice ? price : null);
        tariffs++;
      }

      return (companies: companies, tariffs: tariffs, error: null);
    } catch (e) {
      return (companies: companies, tariffs: tariffs, error: e.toString());
    }
  }

  static String? _resolveWilayaCode(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    final asInt = int.tryParse(t.replaceAll(RegExp(r'[^0-9]'), ''));
    if (asInt != null && asInt >= 1 && asInt <= 58) return asInt.toString().padLeft(2, '0');
    // try match by name prefix/code in "01 - Adrar" style
    final m = RegExp(r'^(\d{1,2})\b').firstMatch(t);
    if (m != null) {
      final n = int.tryParse(m.group(1)!);
      if (n != null && n >= 1 && n <= 58) return n.toString().padLeft(2, '0');
    }
    return null;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '.'));
  }
}
