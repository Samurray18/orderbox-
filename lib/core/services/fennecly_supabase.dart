import 'package:supabase_flutter/supabase_flutter.dart';

/// Fennecly (webapp) Supabase project — same auth/DB for shared login.
/// Uses the public anon/publishable key (client-safe with RLS). Do NOT use service_role.
class FenneclySupabase {
  static const String url = 'https://gyfcaoscsjazazhfozig.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5ZmNhb3Njc2phemF6aGZvemlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0NDQzNDAsImV4cCI6MjA5MjAyMDM0MH0.Kf8erT0qs-kgZSBeFsYZmYEskNYFLyhhNc1Nh5-SgWQ';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static bool get isLoggedIn => client.auth.currentSession != null;
}
