import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/order.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/status_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/soft_card.dart';

/// Revenus â€” line chart with gradient fill + pinned tooltip on the last
/// point, donut of order statuses, and a weekly-change rocket card.
class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  DashboardPeriod _period = DashboardPeriod.days7;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l10n = AppLocalizations.of(context);
    final ar = isArabicContext(context);
    final scheme = Theme.of(context).colorScheme;
    final series = store.dailyRevenue(14);
    final thisWeek = series
        .sublist(series.length - 7)
        .fold<double>(0, (sum, item) => sum + item.value);
    final lastWeek = series
        .sublist(0, math.max(0, series.length - 7))
        .fold<double>(0, (sum, item) => sum + item.value);
    final weeklyChange = lastWeek <= 0
        ? (thisWeek > 0 ? 100.0 : 0.0)
        : ((thisWeek - lastWeek) / lastWeek) * 100;
    final orders = store.ordersInPeriod(_period);
    final revenue = store.revenueOf(orders);
    final maxY = math.max(1.0, series.fold<double>(0, (m, item) => math.max(m, item.value))) * 1.2;

    // Status distribution within the selected period
    final counts = <OrderStatus, int>{};
    for (final order in orders) {
      counts[order.status] = (counts[order.status] ?? 0) + 1;
    }
    final total = orders.length;
    final distribution = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ar ? 'Ø§Ù„Ù…Ø¯Ø§Ø®ÙŠÙ„' : 'Revenus'),
            Text(
              _periodLabel(_period, ar),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.lg + 72,
          ),
          children: [
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                for (final period in DashboardPeriod.values)
                  ChoiceChip(
                    label: Text(_periodLabel(period, ar)),
                    selected: _period == period,
                    onSelected: (_) {
                      AppHaptics.select();
                      setState(() => _period = period);
                    },
                  ),
              ],
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
                          ar ? 'ØªØ·ÙˆØ± Ø§Ù„Ù…Ø¨ÙŠØ¹Ø§Øª' : 'Ã‰volution des ventes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      Text(
                        formatCurrency(context, revenue, compact: true),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: scheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 190,
                    child: _LineRevenueChart(
                      series: series.sublist(math.max(0, series.length - 14)),
                      maxY: maxY,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SoftCard(
              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ar ? 'ØªÙˆØ²ÙŠØ¹ Ø§Ù„Ø­Ø§Ù„Ø§Øª' : 'RÃ©partition des statuts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (total == 0)
                    Text(
                      ar ? 'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø·Ù„Ø¨Ø§Øª Ù„Ù‡Ø°Ù‡ Ø§Ù„ÙØªØ±Ø©' : 'Aucune commande sur cette pÃ©riode',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    )
                  else
                    Row(
                      children: [
                        SizedBox(
                          width: 132,
                          height: 132,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 42,
                                  sections: [
                                    for (final entry in distribution)
                                      PieChartSectionData(
                                        value: entry.value.toDouble(),
                                        color: StatusColors.foreground(context, entry.key),
                                        radius: 22,
                                        showTitle: false,
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    formatNumber(context, total),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 26,
                                        ),
                                  ),
                                  Text(
                                    ar ? 'Ø·Ù„Ø¨' : 'commandes',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            children: [
                              for (final entry in distribution)
                                Padding(
                                  padding: const EdgeInsetsDirectional.symmetric(
                                    vertical: 3,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: StatusColors.foreground(context, entry.key),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Text(
                                          l10n.statusLabel(entry.key),
                                          style: Theme.of(context).textTheme.bodySmall,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        formatNumber(context, entry.value),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        '${((entry.value / total) * 100).toStringAsFixed(0)}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _MotivationCard(
              weeklyChange: weeklyChange,
              thisWeek: thisWeek,
              isArabic: ar,
            ),
          ],
        ),
      ),
    );
  }

  String _periodLabel(DashboardPeriod period, bool ar) {
    switch (period) {
      case DashboardPeriod.days7:
        return ar ? 'Ø¢Ø®Ø± Ù§ Ø£ÙŠØ§Ù…' : '7 derniers jours';
      case DashboardPeriod.days30:
        return ar ? 'Ø¢Ø®Ø± Ù£Ù  ÙŠÙˆÙ…' : '30 derniers jours';
      case DashboardPeriod.all:
        return ar ? 'Ø§Ù„ÙƒÙ„' : 'Tout';
    }
  }
}

class _LineRevenueChart extends StatelessWidget {
  const _LineRevenueChart({required this.series, required this.maxY});

  final List<DailyRevenue> series;
  final double maxY;

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
      barWidth: 2.6,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final last = index == spots.length - 1;
          return FlDotCirclePainter(
            radius: last ? 4.6 : 2.6,
            color: last ? AppColors.primary : scheme.surfaceContainerLowest,
            strokeWidth: last ? 1.6 : 1.2,
            strokeColor: AppColors.primary,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.32),
            AppColors.primary.withValues(alpha: 0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        showingTooltipIndicators: spots.isEmpty
            ? const []
            : [ShowingTooltipIndicators([LineBarSpot(bar, 0, spots.last)])],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
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
          enabled: spots.isNotEmpty,
          handleBuiltInTouches: false,
          touchTooltipData: LineTouchTooltipData(
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            getTooltipItems: (spots) => spots.map((spot) {
              final index = spot.x.toInt().clamp(0, series.length - 1);
              final day = series[index].day;
              return LineTooltipItem(
                '${formatDateShort(context, day)}\n',
                Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: scheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                    ),
                children: [
                  TextSpan(
                    text: formatCurrency(context, series[index].value),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: scheme.onInverseSurface,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _MotivationCard extends StatelessWidget {
  const _MotivationCard({
    required this.weeklyChange,
    required this.thisWeek,
    required this.isArabic,
  });

  final double weeklyChange;
  final double thisWeek;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final positive = weeklyChange >= 0;
    return SoftCard(
      gradient: positive ? AppColors.mintGradient : AppColors.primaryGradient,
      border: false,
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      child: Row(
        children: [
          Text('ðŸš€', style: const TextStyle(fontSize: 42)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  positive
                      ? (isArabic ? 'Ø£Ø³Ø¨ÙˆØ¹ Ù…Ù…ØªØ§Ø²!' : 'Excellente semaine !')
                      : (isArabic ? 'Ø§Ù„Ø£Ø³Ø¨ÙˆØ¹ Ø§Ù„Ø¬Ø§ÙŠ Ø£Ø­Ø³Ù† Ø¥Ù† Ø´Ø§Ø¡ Ø§Ù„Ù„Ù‡' : 'On remonte la pente !'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.lightSurface,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  positive
                      ? (isArabic
                          ? 'Ù…Ø¯Ø§Ø®Ù„Ùƒ Ø§Ø±ØªÙØ¹Øª Ø¨Ù†Ø³Ø¨Ø© ${formatPercent(context, weeklyChange.abs())} Ù‡Ø°Ù‡ Ø§Ù„Ø£Ø³Ø¨ÙˆØ¹'
                          : 'Votre CA a augmentÃ© de ${formatPercent(context, weeklyChange.abs())} cette semaine')
                      : (isArabic
                          ? 'Ù…Ø¯Ø§Ø®Ù„Ùƒ Ù†Ø²Ù„Øª ${formatPercent(context, weeklyChange.abs())} Ù…Ù‚Ø§Ø±Ù†Ø© Ø¨Ø£Ø³Ø¨ÙˆØ¹ Ø§Ù„Ù…Ø§Ø¶ÙŠ'
                          : 'Votre CA a baissÃ© de ${formatPercent(context, weeklyChange.abs())} vs la semaine derniÃ¨re'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.lightSurface.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
