import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/fennecly_data_service.dart';
import '../../core/services/fennecly_supabase.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_backdrop.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../features/customers/customers_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/products/products_screen.dart';
import '../../features/settings/settings_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final PageController _pageController = PageController();
  int _index = 0;
  bool _autoSynced = false;

  // Tab order (reference spec): Tableau · Commandes · Produits · Clients · Réglages
  static const ordersIndex = 1;
  static const settingsIndex = 4;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSync());
  }

  Future<void> _autoSync() async {
    if (_autoSynced || !mounted) return;
    _autoSynced = true;
    if (!FenneclySupabase.isLoggedIn) return;
    final store = context.read<AppStore>();
    try {
      await FenneclyDataService.syncAll(store);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      NavDestination(
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: l10n.navDashboard,
      ),
      NavDestination(
        icon: Icons.receipt_long_outlined,
        selectedIcon: Icons.receipt_long_rounded,
        label: l10n.navOrders,
      ),
      NavDestination(
        icon: Icons.inventory_2_outlined,
        selectedIcon: Icons.inventory_2_rounded,
        label: l10n.navProducts,
      ),
      NavDestination(
        icon: Icons.people_alt_outlined,
        selectedIcon: Icons.people_alt_rounded,
        label: l10n.navCustomers,
      ),
      NavDestination(
        icon: Icons.tune_rounded,
        selectedIcon: Icons.tune_rounded,
        label: l10n.navSettings,
      ),
    ];

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: AppBackdrop(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DashboardScreen(onViewOrders: () => _select(ordersIndex)),
                OrdersScreen(onOpenSettings: () => _select(settingsIndex)),
                ProductsScreen(onViewOrders: () => _select(ordersIndex)),
                const CustomersScreen(),
                const SettingsScreen(),
              ],
            ),
            PositionedDirectional(
              start: AppSpacing.md,
              end: AppSpacing.md,
              bottom: bottomPadding + 10,
              child: AppBottomNav(
                currentIndex: _index,
                onSelected: _select,
                destinations: destinations,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
