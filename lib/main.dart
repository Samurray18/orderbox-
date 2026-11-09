import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/data/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final preferences = await SharedPreferences.getInstance();
  final store = AppStore(preferences);
  await store.load();
  runApp(
    ChangeNotifierProvider.value(
      value: store,
      child: const OrderBoxApp(),
    ),
  );
}
