import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/order.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../core/widgets/soft_card.dart';

class _CustomerRow {
  _CustomerRow({required this.key, required this.name, required this.phone});
  final String key;
  final String name;
  final String phone;
  int orders = 0;
  double spent = 0;
  DateTime? lastAt;
  final List<Order> recent = [];

  void add(Order o) {
    orders++;
    if (o.status == OrderStatus.delivered) spent += o.total;
    if (lastAt == null || o.createdAt.isAfter(lastAt!)) lastAt = o.createdAt;
    if (recent.length < 3) recent.add(o);
  }
}

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  List<_CustomerRow> _build(List<Order> orders) {
    final map = <String, _CustomerRow>{};
    for (final o in orders) {
      final phoneKey = _normPhone(o.phone);
      final nameKey = o.customerName.trim().toLowerCase();
      final key = phoneKey.isNotEmpty ? phoneKey : (nameKey.isNotEmpty ? nameKey : o.id);
      final row = map.putIfAbsent(
        key,
        () => _CustomerRow(
          key: key,
          name: o.customerName.trim().isEmpty ? (o.phone.isNotEmpty ? o.phone : '—') : o.customerName.trim(),
          phone: o.phone.trim(),
        ),
      );
      row.add(o);
      // prefer a real name if we first saw a phone-only key
      if (row.name == row.phone && o.customerName.trim().isNotEmpty) {
        // can't mutate final; handled by keying - acceptable
      }
    }
    final list = map.values.toList();
    list.sort((a, b) => b.spent.compareTo(a.spent));
    return list;
  }

  String _normPhone(String p) {
    final d = p.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length < 8) return '';
    // keep last 9-10 digits for DZ numbers
    return d.length > 9 ? d.substring(d.length - 9) : d;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l10n = AppLocalizations.of(context);
    final texts = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final ar = isArabicContext(context);
    final customers = _build(store.orders);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.lavenderPillDark
                                : AppColors.lavenderPill,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.people_alt_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.customersTitle,
                                  style: texts.headlineLarge?.copyWith(fontSize: 28)),
                              const SizedBox(height: 2),
                              Text(
                                '${formatNumber(context, customers.length)} · ${ar ? 'عميل' : 'clients'}',
                                style: texts.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (store.isFenneclyData)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 4),
                        child: Text(l10n.fenneclySameDb,
                            style: texts.bodySmall?.copyWith(color: AppColors.mintDeep)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (customers.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.people_alt_rounded,
                title: l10n.noCustomersTitle,
                body: l10n.noCustomersBody,
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.bottomNavClearance),
              sliver: SliverList.builder(
                itemCount: customers.length,
                itemBuilder: (context, i) {
                  final c = customers[i];
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
                    child: SoftCard(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                      child: Row(
                        children: [
                          InitialsAvatar(name: c.name, size: 46),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: texts.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(
                                  [
                                    if (c.phone.isNotEmpty) c.phone,
                                    '${formatNumber(context, c.orders)} ${l10n.ordersWord}',
                                  ].join(' · '),
                                  style: texts.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(formatCurrency(context, c.spent),
                                  style: texts.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700, color: AppColors.mintDeep)),
                              Text(l10n.totalSpent,
                                  style: texts.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
