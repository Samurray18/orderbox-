import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/expanding_fab.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/orders/order_form_screen.dart';
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

  Future<void> _openNewOrder() async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, __, ___) => const OrderFormScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
    if (mounted) _select(0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
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
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard_rounded,
        label: l10n.navDashboard,
      ),
      NavDestination(
        icon: Icons.tune_rounded,
        selectedIcon: Icons.tune_rounded,
        label: l10n.navSettings,
      ),
    ];

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              OrdersScreen(onOpenSettings: () => _select(3)),
              ProductsScreen(onViewOrders: () => _select(0)),
              DashboardScreen(onViewOrders: () => _select(0)),
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
          PositionedDirectional(
            end: AppSpacing.md,
            bottom: bottomPadding +
                AppSizes.navHeight +
                AppSpacing.md +
                AppSpacing.sm,
            child: ExpandingFab(
              label: l10n.addOrder,
              onPressed: _openNewOrder,
            ),
          ),
        ],
      ),
    );
  }
}
