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

  /// True when the app was built with the Supabase dart-defines present.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// Kept after [initialize] so callers can report a clear message instead
  /// of crashing with "Client has not been initialized".
  static bool _initialized = false;
  static String? initializationError;

  static bool get isInitialized => _initialized;
  static String? get friendlyInitializationError {
    if (!isConfigured) {
      return 'FENNECLY_SUPABASE_URL / FENNECLY_SUPABASE_ANON_KEY are not '
          'defined at build time. The app runs offline until built with '
          '--dart-define=FENNECLY_SUPABASE_URL=… '
          '--dart-define=FENNECLY_SUPABASE_ANON_KEY=…';
    }
    return initializationError;
  }

  static Future<void> initialize() async {
    if (!isConfigured) {
      initializationError = 'missing dart-defines';
      return;
    }
    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
      _initialized = true;
      initializationError = null;
    } catch (e) {
      initializationError = e.toString();
      _initialized = false;
    }
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
