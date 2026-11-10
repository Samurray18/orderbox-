import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/data/app_store.dart';
import 'core/services/fennecly_supabase.dart';
import 'data/db/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  try {
    await FenneclySupabase.initialize();
  } catch (_) {
    // Offline / init failure: app can still run locally without account.
  }
  final preferences = await SharedPreferences.getInstance();
  final db = AppDatabase();
  final store = AppStore(preferences, db);
  await store.load();
  runApp(
    ChangeNotifierProvider.value(
      value: store,
      child: const OrderBoxApp(),
    ),
  );
}
