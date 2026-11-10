import 'package:supabase_flutter/supabase_flutter.dart';

/// Fennecly (webapp) Supabase project — same auth/DB for shared login.
/// Uses the public anon/publishable key (client-safe with RLS). Do NOT use service_role.
/// Values are injected via --dart-define (see CI workflow/secrets); defaults allow local dev.
class FenneclySupabase {
  static const String url = String.fromEnvironment(
    'FENNECLY_SUPABASE_URL',
    defaultValue: '',
  );
  static const String anonKey = String.fromEnvironment(
    'FENNECLY_SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static SupabaseClient get client => Supabase.instance.client;

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) return;
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static bool get isLoggedIn {
    if (!isConfigured) return false;
    try {
      return Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }
}
