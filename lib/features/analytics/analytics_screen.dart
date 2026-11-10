import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/order.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_backdrop.dart';
import '../../core/widgets/soft_card.dart';

/// Analytics — parity with the web dashboard.analytics page.
/// Computed entirely from the local store (works offline).
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

enum _ChartDays { days30, days90 }

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  _ChartDays _chartDays = _ChartDays.days30;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l10n = AppLocalizations.of(context);
    final ar = isArabicContext(context);
    final colors = Theme.of(context).colorScheme;
    final orders = store.orders;
    final products = store.products;

    final totalOrders = orders.length;
    final deliveredOrders =
        orders.where((o) => o.status == OrderStatus.delivered).length;
    final pendingOrders = store.awaitingConfirmationOf(orders);
    final revenue = store.revenueOf(orders);
    final avgOrder = totalOrders == 0 ? 0.0 : revenue / totalOrders;
    final customerKeys = <String>{
      for (final o in orders)
        if (o.phone.trim().isNotEmpty) o.phone
        else o.customerName.trim(),
    };
    final series = store.dailyRevenue(_chartDays == _ChartDays.days90 ? 90 : 30);
    final chartDays = _chartDays == _ChartDays.days90 ? 90 : 30;
    final now = DateTime.now();
    final chartSince = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: chartDays - 1));
    final totalChartOrders =
        orders.where((o) => !o.createdAt.isBefore(chartSince)).length;
    final totalChartRevenue = series.fold<double>(0, (s, d) => s + d.value);
    final bestDay = series.fold<DailyRevenue?>(null, (best, item) {
      if (best == null || item.value > best.value) return item;
      return best;
    });

    final last7 = orders
        .where((o) => o.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7))))
        .toList();
    final revenue7d = store.revenueOf(last7);
    final delivered7d =
        last7.where((o) => o.status == OrderStatus.delivered).length;
    final deliveryRate =
        last7.isEmpty ? 0.0 : delivered7d / last7.length * 100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.analyticsTitle),
            Text(
              ar ? 'تحليلات المتجر' : 'Vue analytique de votre boutique',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
      body: AppBackdrop(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.lg + 64,
          ),
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 400;
                const spacing = AppSpacing.sm;
                final cards = [
                  _KpiCard(
                    label: ar ? 'الطلبات' : 'Commandes',
                    value: formatNumber(context, totalOrders),
                    icon: Icons.shopping_cart_rounded,
                    gradient: AppColors.primaryGradient,
                  ),
                  _KpiCard(
                    label: ar ? 'المداخيل' : 'Chiffre d’affaires',
                    value: formatCurrency(context, revenue, compact: true),
                    icon: Icons.payments_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF17D3B2), Color(0xFF079E86)],
                    ),
                  ),
                  _KpiCard(
                    label: ar ? 'متوسط السلة' : 'Panier moyen',
                    value: formatCurrency(context, avgOrder, compact: true),
                    icon: Icons.trending_up_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6AA9FF), Color(0xFF2F80ED)],
                    ),
                  ),
                  _KpiCard(
                    label: ar ? 'العملاء' : 'Clients',
                    value: formatNumber(context, customerKeys.length),
                    icon: Icons.people_alt_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB65C), Color(0xFFF08C1F)],
                    ),
                  ),
                  _KpiCard(
                    label: ar ? 'المنتجات' : 'Produits',
                    value: formatNumber(context, products.length),
                    icon: Icons.inventory_2_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8BA3), Color(0xFFE5484D)],
                    ),
                  ),
                  _KpiCard(
                    label: ar ? 'مُوصلات' : 'Livrées',
                    value: formatNumber(context, deliveredOrders),
                    icon: Icons.check_circle_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF47D98B), Color(0xFF16A34A)],
                    ),
                  ),
                  _KpiCard(
                    label: ar ? 'قيد الانتظار' : 'En attente',
                    value: formatNumber(context, pendingOrders),
                    icon: Icons.hourglass_top_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFC35B), Color(0xFFF08C1F)],
                    ),
                  ),
                  _KpiCard(
                    label: ar ? 'CA ٧ أيام' : 'CA 7 jours',
                    value: formatCurrency(context, revenue7d, compact: true),
                    icon: Icons.calendar_month_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB08BFF), Color(0xFF6B3DF5)],
                    ),
                  ),
                ];
                final cross = compact ? 2 : 4;
                final tileW = (constraints.maxWidth - spacing * (cross - 1)) / cross;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final card in cards)
                      SizedBox(width: tileW, child: card),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SoftCard(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ar ? 'تطور المبيعات مع الوقت' : 'Revenus dans le temps',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      SegmentedButton<_ChartDays>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: _ChartDays.days30,
                            label: const Text('30j'),
                          ),
                          ButtonSegment(
                            value: _ChartDays.days90,
                            label: const Text('90j'),
                          ),
                        ],
                        selected: {_chartDays},
                        onSelectionChanged: (value) {
                          AppHaptics.select();
                          setState(() => _chartDays = value.first);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          label: ar
                              ? 'إجمالي المداخيل (${_chartDays == _ChartDays.days90 ? '٩٠' : '٣٠'}d)'
                              : 'CA total (${_chartDays == _ChartDays.days90 ? '90' : '30'}j)',
                          value: formatCurrency(context, totalChartRevenue, compact: true),
                        ),
                      ),
                      Expanded(
                        child: _MiniStat(
                          label: ar ? 'الطلبات' : 'Commandes',
                          value: formatNumber(context, totalChartOrders),
                        ),
                      ),
                      Expanded(
                        child: _MiniStat(
                          label: ar ? 'أفضل يوم' : 'Meilleur jour',
                          value: bestDay == null
                              ? '—'
                              : formatDateShort(context, bestDay.day),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 200,
                    child: _AreaRevenueChart(series: series),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SoftCard(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ar ? 'لقطة 7 أيام' : 'Instantané 7 jours',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          label: ar ? 'الطلبات' : 'Commandes',
                          value: formatNumber(context, last7.length),
                        ),
                      ),
                      Expanded(
                        child: _MiniStat(
                          label: ar ? 'المداخيل' : 'CA',
                          value: formatCurrency(context, revenue7d, compact: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          label: ar ? 'نسبة التوصيل' : 'Taux de livraison',
                          value: formatPercent(context, deliveryRate),
                        ),
                      ),
                      Expanded(
                        child: _MiniStat(
                          label: ar ? 'سفارش / منتج' : 'Commandes / produit',
                          value: products.isEmpty
                              ? '0'
                              : (totalOrders / math.max(1, products.length))
                                  .toStringAsFixed(1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.lightSurface.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: AppSizes.iconSm,
                  color: AppColors.lightSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.lightSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.2,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _AreaRevenueChart extends StatelessWidget {
  const _AreaRevenueChart({required this.series});

  final List<DailyRevenue> series;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final spots = <FlSpot>[
      for (var i = 0; i < series.length; i++) FlSpot(i.toDouble(), series[i].value),
    ];
    final bar = LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.35,
      color: AppColors.primary,
      barWidth: 2.4,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.28),
            AppColors.primary.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
    final maxY = series.fold<double>(
          1,
          (m, item) => item.value > m ? item.value : m,
        ) *
        1.25;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
            strokeWidth: 1,
            dashArray: const [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [bar],
        lineTouchData: LineTouchData(
          enabled: series.isNotEmpty,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((spot) {
              final index = spot.x.toInt().clamp(0, series.length - 1);
              return LineTooltipItem(
                formatCurrency(context, series[index].value),
                Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: scheme.onInverseSurface,
                      fontWeight: FontWeight.w700,
                    ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
