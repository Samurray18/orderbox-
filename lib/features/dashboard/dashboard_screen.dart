import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/order.dart';
import '../../core/theme/status_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/order_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/skeletons.dart';
import '../../core/widgets/soft_card.dart';
import '../../core/utils/context_ext.dart';
import '../orders/order_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onViewOrders});

  final VoidCallback? onViewOrders;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardPeriod _period = DashboardPeriod.days7;
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 620), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    AppHaptics.select();
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l10n = AppLocalizations.of(context);
    final orders = store.ordersInPeriod(_period);
    final revenue = store.revenueOf(orders);
    final profit = store.profitOf(orders);
    final returnRate = store.returnRateOf(orders);
    final margin = store.marginOf(orders);
    final averageOrder = store.averageOrderOf(orders);
    final deliveredCount = store.deliveredCountOf(orders);
    final returnedCount = store.returnedCountOf(orders);
    final growth = store.growthPercent(_period);
    final series = store.dailyRevenue(7);
    final maxRevenue = series.fold<double>(0, (m, item) => math.max(m, item.value));
    final recent = store.recent(limit: 3);
    final allOrders = store.orders;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l10n.greetingForHour(DateTime.now().hour)}, '
                                  '${store.storeNameOr(l10n.storeDefault)}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.dashboardTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(fontSize: 28),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsetsDirectional.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              formatDateMedium(context, DateTime.now()),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.dashboardSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _PeriodSelector(
                        value: _period,
                        onChanged: (value) {
                          AppHaptics.select();
                          setState(() => _period = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_loading)
              SliverPadding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(child: const DashboardSkeleton()),
              )
            else if (allOrders.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.dashboard_rounded,
                  title: l10n.dashboardEmptyTitle,
                  body: l10n.dashboardEmptyBody,
                  actionLabel: l10n.addOrder,
                  onAction: () {},
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: _RevenueHero(
                    revenue: revenue,
                    growth: growth,
                    period: _period,
                    deliveredCount: deliveredCount,
                    averageOrder: averageOrder,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 390;
                      final profitCard = _ProfitCard(
                        profit: profit,
                        margin: margin,
                      );
                      final returnCard = _ReturnRateCard(
                        returnRate: returnRate,
                        returnedCount: returnedCount,
                        deliveredCount: deliveredCount,
                      );
                      if (compact) {
                        return Column(
                          children: [
                            profitCard,
                            const SizedBox(height: AppSpacing.sm),
                            returnCard,
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: profitCard),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: returnCard),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: SoftCard(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: l10n.revenueChartTitle,
                          subtitle: l10n.last7Days,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: 210,
                          child: maxRevenue <= 0
                              ? _NoSalesState()
                              : _RevenueBarChart(
                                  series: series,
                                  maxRevenue: maxRevenue,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: SoftCard(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: l10n.statusChartTitle),
                        const SizedBox(height: AppSpacing.md),
                        _StatusBreakdown(orders: allOrders),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xs,
                  ),
                  child: SectionHeader(
                    title: l10n.recentOrders,
                    actionLabel: l10n.seeAll,
                    onAction: widget.onViewOrders,
                    actionIcon: Icons.arrow_forward_rounded,
                  ),
                ),
              ),
              if (recent.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: EmptyState(
                      compact: true,
                      icon: Icons.receipt_long_rounded,
                      title: l10n.noRecentOrders,
                      body: l10n.noOrdersBody,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.bottomNavClearance,
                  ),
                  sliver: SliverList.builder(
                    itemCount: recent.length,
                    itemBuilder: (context, index) {
                      final order = recent[index];
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(
                          bottom: AppSpacing.sm,
                        ),
                        child: OrderCard(
                          order: order,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailsScreen(orderId: order.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.value, required this.onChanged});

  final DashboardPeriod value;
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

    return Container(
      padding: const EdgeInsetsDirectional.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: options.map((option) {
          final selected = option.$1 == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: AppSpacing.xs + 1,
                ),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.primaryGradient : null,
                  color: selected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  option.$2,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: selected
                        ? AppColors.lightSurface
                        : scheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RevenueHero extends StatelessWidget {
  const _RevenueHero({
    required this.revenue,
    required this.growth,
    required this.period,
    required this.deliveredCount,
    required this.averageOrder,
  });

  final double revenue;
  final double growth;
  final DashboardPeriod period;
  final int deliveredCount;
  final double averageOrder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final texts = Theme.of(context).textTheme;
    final showGrowth = period != DashboardPeriod.all;

    return SoftCard(
      gradient: AppColors.primaryGradient,
      border: false,
      shadow: false,
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            top: -30,
            end: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: -40,
            start: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(alpha: 0.12),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.revenue,
                    style: texts.labelLarge?.copyWith(
                      color: AppColors.lightSurface.withValues(alpha: 0.82),
                    ),
                  ),
                  const Spacer(),
                  if (showGrowth)
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
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
                            color: AppColors.lightSurface,
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text(
                            '${growth >= 0 ? '+' : ''}${formatPercent(context, growth.abs())}',
                            style: texts.labelSmall?.copyWith(
                              color: AppColors.lightSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  formatCurrency(context, revenue),
                  style: texts.displaySmall?.copyWith(
                    color: AppColors.lightSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 34,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: AppSizes.iconSm,
                    color: AppColors.lightSurface.withValues(alpha: 0.78),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '$deliveredCount ${l10n.deliveredOrders}',
                    style: texts.bodySmall?.copyWith(
                      color: AppColors.lightSurface.withValues(alpha: 0.78),
                    ),
                  ),
                  if (deliveredCount > 0) ...[
                    const SizedBox(width: AppSpacing.md),
                    Icon(
                      Icons.show_chart_rounded,
                      size: AppSizes.iconSm,
                      color: AppColors.lightSurface.withValues(alpha: 0.78),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Flexible(
                      child: Text(
                        '${formatCurrency(context, averageOrder)} ${l10n.averageOrder.toLowerCase()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: texts.bodySmall?.copyWith(
                          color: AppColors.lightSurface.withValues(alpha: 0.78),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfitCard extends StatelessWidget {
  const _ProfitCard({required this.profit, required this.margin});

  final double profit;
  final double margin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final texts = Theme.of(context).textTheme;
    return SoftCard(
      gradient: AppColors.mintGradient,
      border: false,
      shadow: false,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            top: -18,
            end: -14,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.lightSurface,
                      size: AppSizes.iconMd,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${formatPercent(context, margin)}',
                    style: texts.labelMedium?.copyWith(
                      color: AppColors.lightSurface.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.profitLabel,
                style: texts.labelMedium?.copyWith(
                  color: AppColors.lightSurface.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  formatCurrency(context, profit),
                  style: texts.titleLarge?.copyWith(
                    color: AppColors.lightSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.profitSub,
                style: texts.bodySmall?.copyWith(
                  color: AppColors.lightSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReturnRateCard extends StatelessWidget {
  const _ReturnRateCard({
    required this.returnRate,
    required this.returnedCount,
    required this.deliveredCount,
  });

  final double returnRate;
  final int returnedCount;
  final int deliveredCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final color = returnRate < 10
        ? AppColors.mintDeep
        : (returnRate < 20 ? AppColors.amber : scheme.error);

    return SoftCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 70,
            child: CustomPaint(
              painter: _RingPainter(
                value: (returnRate / 100).clamp(0.0, 1.0),
                color: color,
                trackColor: scheme.surfaceContainerHigh,
              ),
              child: Center(
                child: Text(
                  formatPercent(context, returnRate),
                  style: texts.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.returnRate,
                  style: texts.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$returnedCount / ${deliveredCount + returnedCount}',
                  style: texts.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.returnRateSub,
                  style: texts.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
  });

  final double value;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 4;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value, false, valuePaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}

class _RevenueBarChart extends StatelessWidget {
  const _RevenueBarChart({
    required this.series,
    required this.maxRevenue,
  });

  final List<DailyRevenue> series;
  final double maxRevenue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final maxY = maxRevenue <= 0 ? 1.0 : maxRevenue * 1.25;
    final step = maxY / 4;

    return BarChart(
      BarChartData(
        maxY: maxY,
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: step <= 0 ? 1 : step,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: const [4, 4],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: step <= 0 ? 1 : step,
              getTitlesWidget: (value, meta) {
                if (value == meta.max || value == meta.min) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6),
                  child: Text(
                    formatNumber(context, value, compact: true),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 9,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= series.length) {
                  return const SizedBox.shrink();
                }
                final day = series[index].day;
                return Padding(
                  padding: const EdgeInsetsDirectional.only(top: 6),
                  child: Text(
                    _dateFormatDay(context, day),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            tooltipMargin: 8,
            getTooltipColor: (_) =>
                Theme.of(context).colorScheme.inverseSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final value = series[group.x].value;
              final day = series[group.x].day;
              return BarTooltipItem(
                '${formatDateShort(context, day)}\n',
                Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: formatCurrency(context, value),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        barGroups: List.generate(series.length, (index) {
          final item = series[index];
          final isMax = item.value == maxRevenue && maxRevenue > 0;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.value <= 0 ? 0.01 : item.value,
                width: context.isCompact ? 12 : 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                gradient: LinearGradient(
                  colors: isMax
                      ? [AppColors.mint, AppColors.mintDeep]
                      : [AppColors.primaryBright, AppColors.primary],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: scheme.surfaceContainerHigh.withValues(alpha: 0.45),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

String _dateFormatDay(BuildContext context, DateTime day) {
  return DateFormat('EEE', intlLocaleOf(context)).format(day);
}

class _NoSalesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: AppSizes.iconXl,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.noSalesInPeriod,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.noSalesInPeriodBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBreakdown extends StatelessWidget {
  const _StatusBreakdown({required this.orders});

  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final counts = <OrderStatus, int>{};
    for (final status in OrderStatus.values) {
      counts[status] = 0;
    }
    for (final order in orders) {
      counts[order.status] = (counts[order.status] ?? 0) + 1;
    }
    final total = orders.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: SizedBox(
            height: 12,
            child: Row(
              children: OrderStatus.values.map((status) {
                final count = counts[status] ?? 0;
                if (count == 0 || total == 0) {
                  return const SizedBox.shrink();
                }
                final flex = (count * 1000 / total).round();
                return Flexible(
                  flex: flex < 1 ? 1 : flex,
                  child: Container(
                    color: StatusColors.foreground(context, status),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: OrderStatus.values.map((status) {
            final count = counts[status] ?? 0;
            if (count == 0) return const SizedBox.shrink();
            final color = StatusColors.foreground(context, status);
            return Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: AppSizes.dot,
                    height: AppSizes.dot,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxs + 2),
                  Text(
                    '${l10n.statusLabel(status)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    formatNumber(context, count),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
