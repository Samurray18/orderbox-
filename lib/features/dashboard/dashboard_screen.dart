import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/order.dart';
import '../../core/services/fennecly_data_service.dart';
import '../../core/services/fennecly_supabase.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/status_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_backdrop.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/soft_card.dart';
import '../analytics/analytics_screen.dart';
import '../cod/cod_manager_screen.dart';
import '../delivery_map/delivery_map_screen.dart';
import '../orders/order_details_screen.dart';
import '../profit/profit_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onViewOrders});

  final VoidCallback? onViewOrders;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardPeriod _period = DashboardPeriod.days30;
  int _selectedDay = 0;

  Future<void> _refresh() async {
    AppHaptics.select();
    if (FenneclySupabase.isLoggedIn) {
      try {
        await FenneclyDataService.syncAll(context.read<AppStore>());
      } catch (_) {}
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 620));
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final orders = store.ordersInPeriod(_period);
    final series = store.dailyRevenue(7);
    final revenue = store.revenueOf(orders);
    final profit = store.profitOf(orders);
    final margin = store.marginOf(orders);
    final returnRate = store.returnRateOf(orders);
    final returned = store.returnedCountOf(orders);
    final delivered = store.deliveredCountOf(orders);
    final averageOrder = store.averageOrderOf(orders);
    final growth = store.growthPercent(_period);
    final maxBar = math.max<double>(
      1,
      series.fold<double>(0, (m, d) => math.max(m, d.value)) * 1.25,
    );
    final recent = store.recent(limit: 3);
    final selected = _selectedDay.clamp(0, series.length - 1);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: scheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // --- Brand row ------------------------------------------
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _StoreAvatar(name: store.storeNameOr(l10n.storeDefault), logoUrl: store.fenneclyStoreLogoUrl),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                l10n.storeName.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.6,
                                    ),
                              ),
                            ),
                            PopupMenuButton<DashboardPeriod>(
                              tooltip: l10n.last7Days,
                              onSelected: (value) {
                                AppHaptics.select();
                                setState(() => _period = value);
                              },
                              itemBuilder: (context) => [
                                _menuItem(DashboardPeriod.days7, '7 d'),
                                _menuItem(DashboardPeriod.days30, '30 d'),
                                _menuItem(DashboardPeriod.all, l10n.allTime),
                              ],
                              child: Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerLowest.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(
                                    color: scheme.outlineVariant.withValues(alpha: 0.8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.calendar_today_rounded,
                                        size: 14, color: scheme.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      formatDateMedium(context, DateTime.now()),
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Icon(Icons.expand_more_rounded,
                                        size: 18, color: scheme.onSurfaceVariant),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${l10n.greetingForHour(DateTime.now().hour)}, ',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      height: 1.05,
                                    ),
                              ),
                              TextSpan(
                                text: '\n${store.storeNameOr(l10n.storeDefault)}',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      height: 1.05,
                                      color: scheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.dashboardSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Period chips -----------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    0,
                  ),
                  child: _PeriodChips(
                    value: _period,
                    kindIsArabic: isArabicContext(context),
                    onChanged: (value) {
                      AppHaptics.select();
                      setState(() => _period = value);
                    },
                  ),
                ),
              ),

              // --- Revenue hero card ----------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: SoftCard(
                    gradient: AppColors.revenueHeroV2,
                    border: false,
                    radius: 26,
                    padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.payments_rounded,
                                size: AppSizes.iconSm,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              l10n.revenue.toUpperCase(),
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                  ),
                            ),
                            const Spacer(),
                            if (_period != DashboardPeriod.all)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: AppSpacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      growth >= 0
                                          ? Icons.trending_up_rounded
                                          : Icons.trending_down_rounded,
                                      size: AppSizes.iconSm,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: AppSpacing.xxs),
                                    Text(
                                      '${growth >= 0 ? '+' : ''}${formatPercent(context, growth.abs())}',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            formatCurrency(context, revenue),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 40,
                                  height: 1,
                                  letterSpacing: -0.5,
                                ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Icon(Icons.local_shipping_rounded,
                                size: AppSizes.iconSm,
                                color: Colors.white.withValues(alpha: 0.9)),
                            const SizedBox(width: 6),
                            Text(
                              '$delivered ${l10n.ordersWord}',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Icon(Icons.shopping_basket_outlined,
                                size: AppSizes.iconSm,
                                color: Colors.white.withValues(alpha: 0.9)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                formatCurrency(context, averageOrder, compact: true),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.75),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Profit + Return rate row ------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SoftCard(
                          gradient: AppColors.mintDeepGradient,
                          border: false,
                          radius: 22,
                          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    size: AppSizes.iconSm,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: AppSpacing.xxs),
                                  Text(
                                    l10n.profitLabel.toUpperCase(),
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.1,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                formatCurrency(context, profit, compact: true),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 19,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${formatPercent(context, margin)} ${l10n.marginShort}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: SoftCard(
                          radius: 22,
                          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.returnRate.toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.0,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                formatPercent(context, returnRate),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 19,
                                      color: returnRate < 10
                                          ? AppColors.mintDeep
                                          : (returnRate < 20 ? AppColors.amber : scheme.error),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$returned / ${delivered + returned} ${l10n.ordersWord}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Quick actions -----------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: _QuickActionsRow(
                    onOpenAnalytics: () => _openPushed(const AnalyticsScreen()),
                    onOpenMap: () => _openPushed(const DeliveryMapScreen()),
                    onOpenCod: () => _openPushed(const CodManagerScreen()),
                    onOpenProfit: () => _openPushed(const ProfitScreen()),
                  ),
                ),
              ),

              // --- Week performance chart --------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: SoftCard(
                    radius: 24,
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.revenueChartTitle,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => widget.onViewOrders?.call(),
                              icon: const Icon(
                                Icons.chevron_right_rounded,
                                size: AppSizes.iconSm,
                              ),
                              label: Text(l10n.seeAll),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          height: 150,
                          child: _RevenueBars(
                            series: series,
                            selectedIndex: selected,
                            maxY: maxBar,
                            onSelected: (i) => setState(() => _selectedDay = i),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Most recent orders -----------------------------------
              if (recent.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.xs,
                    AppSpacing.lg,
                    AppSpacing.bottomNavClearance,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: l10n.recentOrders,
                          actionLabel: l10n.seeAll,
                          actionIcon: Icons.arrow_forward_rounded,
                          onAction: () => widget.onViewOrders?.call(),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final order in recent) _RecentOrderTile(order: order),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<DashboardPeriod> _menuItem(DashboardPeriod value, String label) =>
      PopupMenuItem<DashboardPeriod>(value: value, child: Text(label));

  void _openPushed(Widget screen) {
    AppHaptics.select();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _StoreAvatar extends StatelessWidget {
  const _StoreAvatar({required this.name, this.logoUrl});

  final String name;
  final String? logoUrl;

  Widget _monogram(BuildContext context, String initials) => Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: Center(
            child: Text(
              initials,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty ? '?' : initialsOf(name);
    final url = logoUrl?.trim() ?? 
''
;

    if (url.isEmpty) return _monogram(context, initials);

    return ClipOval(
      child: SizedBox(
        width: 44,
        height: 44,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _monogram(context, initials),
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : _monogram(context, initials),
        ),
      ),
    );
  }
}

class _PeriodChips extends StatelessWidget {
  const _PeriodChips({
    required this.value,
    required this.kindIsArabic,
    required this.onChanged,
  });

  final DashboardPeriod value;
  final bool kindIsArabic;
  final ValueChanged<DashboardPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final options = [
      (DashboardPeriod.days7, l10n.last7Days),
      (DashboardPeriod.days30, l10n.last30Days),
      (DashboardPeriod.all, l10n.allTime),
    ];
    return SizedBox(
      height: 36,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.xs),
              _PeriodPill(
                label: options[i].$2,
                selected: options[i].$1 == value,
                onTap: () => onChanged(options[i].$1),
                scheme: scheme,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PeriodPill extends StatelessWidget {
  const _PeriodPill({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scheme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.primaryGradient : null,
            color: selected ? null : scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: selected ? null : Border.all(color: scheme.outlineVariant),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? Colors.white : scheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }
}

class _RevenueBars extends StatelessWidget {
  const _RevenueBars({
    required this.series,
    required this.selectedIndex,
    required this.maxY,
    required this.onSelected,
  });

  final List<DailyRevenue> series;
  final int selectedIndex;
  final double maxY;
  final ValueChanged<int> onSelected;

  static const _en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _ar = ['ثن', 'ثث', 'أر', 'خم', 'جم', 'سب', 'أحد'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ar = isArabicContext(context);
    final maxVal = math.max<double>(1, maxY);

    return Row(
      children: [
        for (var i = 0; i < series.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelected(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      i == selectedIndex
                          ? formatCurrency(context, series[i].value, compact: true)
                          : '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: math.max(6, (series[i].value / maxVal) * 92),
                      decoration: BoxDecoration(
                        gradient: selectedIndex == i ? AppColors.revenueHeroV2 : null,
                        color: selectedIndex == i ? null : scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      (ar ? _ar : _en)[series[i].day.weekday % 7],
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight:
                                selectedIndex == i ? FontWeight.w800 : FontWeight.w500,
                            color: selectedIndex == i
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final statusColor = StatusColors.foreground(context, order.status);

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
      child: SoftCard(
        padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
        radius: 18,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(orderId: order.id),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _statusIcon(order.status),
                color: statusColor,
                size: AppSizes.iconMd,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: texts.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.productName} · x${order.quantity}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: texts.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Text(
              formatCurrency(context, order.total, compact: true),
              style: texts.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(OrderStatus status) => switch (status) {
        OrderStatus.newOrder => Icons.new_releases_rounded,
        OrderStatus.confirmed => Icons.check_circle_outline_rounded,
        OrderStatus.shipped => Icons.local_shipping_rounded,
        OrderStatus.delivered => Icons.task_alt_rounded,
        OrderStatus.returned => Icons.assignment_return_rounded,
        OrderStatus.cancelled => Icons.cancel_rounded,
        OrderStatus.noAnswer => Icons.phone_disabled_rounded,
      };
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.onOpenAnalytics,
    required this.onOpenMap,
    required this.onOpenCod,
    required this.onOpenProfit,
  });

  final VoidCallback onOpenAnalytics;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenCod;
  final VoidCallback onOpenProfit;

  @override
  Widget build(BuildContext context) {
    final items = <({String label, IconData icon, Color color, VoidCallback onTap})>[
      (label: 'Analytics', icon: Icons.query_stats_rounded, color: AppColors.blue, onTap: onOpenAnalytics),
      (label: 'Map', icon: Icons.map_rounded, color: AppColors.green, onTap: onOpenMap),
      (label: 'COD', icon: Icons.local_shipping_rounded, color: AppColors.amber, onTap: onOpenCod),
      (label: 'Profit', icon: Icons.savings_rounded, color: AppColors.mintDeep, onTap: onOpenProfit),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(child: _QuickActionTile(item: items[i])),
        ],
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.item});

  final ({String label, IconData icon, Color color, VoidCallback onTap}) item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.color, size: 19),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
