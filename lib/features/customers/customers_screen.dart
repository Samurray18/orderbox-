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
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/soft_card.dart';

class _CustomerRow {
  _CustomerRow({required this.key, required this.name, required this.phone});
  final String key;
  final String name;
  final String phone;
  int orders = 0;
  double spent = 0;
  DateTime? lastAt;
  String wilaya = '';
  final List<Order> recent = [];

  void add(Order o) {
    orders++;
    if (o.status == OrderStatus.delivered) spent += o.total;
    if (lastAt == null || o.createdAt.isAfter(lastAt!)) lastAt = o.createdAt;
    if (wilaya.isEmpty && o.wilayaName.isNotEmpty) wilaya = o.wilayaName;
    recent.add(o);
    recent.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (recent.length > 3) recent.removeRange(3, recent.length);
  }
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          name: o.customerName.trim().isEmpty
              ? (o.phone.isNotEmpty ? o.phone : '—')
              : o.customerName.trim(),
          phone: o.phone.trim(),
        ),
      );
      row.add(o);
      if (row.name == row.phone && o.customerName.trim().isNotEmpty) {
        // phone-only key: keep — orders name wins next time we build
      }
    }
    final list = map.values.toList();
    list.sort((a, b) => b.spent.compareTo(a.spent));
    return list;
  }

  List<_CustomerRow> _filtered(List<_CustomerRow> rows) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return rows;
    return rows.where((c) {
      final haystack =
          '${c.name} ${c.phone} ${c.wilaya} ${formatPhone(c.phone)}'
              .toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  String _normPhone(String p) {
    final d = p.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length < 8) return '';
    // keep last 9-10 digits for DZ numbers
    return d.length > 9 ? d.substring(d.length - 9) : d;
  }

  void _openCustomer(BuildContext context, _CustomerRow customer) {
    AppHaptics.select();
    final ar = isArabicContext(context);
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.lg,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      InitialsAvatar(name: customer.name),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: Theme.of(sheetContext)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            if (customer.phone.isNotEmpty)
                              Text(
                                formatPhone(customer.phone),
                                textDirection: TextDirection.ltr,
                                style: Theme.of(sheetContext)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _TagChip(
                        icon: Icons.location_on_rounded,
                        label: customer.wilaya.isEmpty
                            ? (ar ? '—' : 'Wilaya')
                            : customer.wilaya,
                      ),
                      _TagChip(
                        icon: Icons.receipt_long_rounded,
                        label:
                            '${formatNumber(context, customer.orders)} ${l10n.ordersWord}',
                      ),
                      _TagChip(
                        icon: Icons.payments_rounded,
                        label: formatCurrency(context, customer.spent, compact: true),
                      ),
                      if (customer.lastAt != null)
                        _TagChip(
                          icon: Icons.calendar_today_rounded,
                          label: relativeDay(context, customer.lastAt!, l10n),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    ar ? 'آخر الطلبات' : 'Dernières commandes',
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  for (final order in customer.recent)
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(vertical: 3),
                      child: SoftCard(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.sm + 2),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: StatusColors.background(context, order.status),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.inventory_2_rounded,
                                size: AppSizes.iconSm,
                                color: StatusColors.foreground(context, order.status),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.productName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    relativeDay(context, order.createdAt, l10n),
                                    style: Theme.of(sheetContext)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatCurrency(context, order.total, compact: true),
                              style: Theme.of(sheetContext)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: scheme.primary,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l10n = AppLocalizations.of(context);
    final ar = isArabicContext(context);
    final texts = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final customers = _build(store.orders);
    final filtered = _filtered(customers);

    // Web parity stats
    final totalCustomers = customers.length;
    final totalRevenue =
        customers.fold<double>(0, (sum, c) => sum + c.spent);
    final totalOrderCount =
        customers.fold<int>(0, (sum, c) => sum + c.orders);
    final avgBasket =
        totalOrderCount == 0 ? 0.0 : totalRevenue / totalOrderCount;
    final repeatRate = totalCustomers == 0
        ? 0.0
        : customers.where((c) => c.orders > 1).length / totalCustomers * 100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                              Text(
                                l10n.customersTitle.toUpperCase(),
                                style: texts.labelSmall?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.6,
                                ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${customers.length}',
                                      style: texts.displaySmall?.copyWith(
                                          fontWeight: FontWeight.w800, height: 0.9),
                                    ),
                                    TextSpan(
                                      text: ' ${l10n.customersTitle.toLowerCase()}',
                                      style: texts.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: scheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
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
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _CustomerStatCard(
                            icon: Icons.groups_rounded,
                            label: ar ? 'العملاء' : 'Clients',
                            value: formatNumber(context, totalCustomers),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _CustomerStatCard(
                            icon: Icons.payments_rounded,
                            label: ar ? 'المبيعات' : 'CA',
                            value: formatCurrency(context, totalRevenue, compact: true),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _CustomerStatCard(
                            icon: Icons.shopping_bag_rounded,
                            label: ar ? 'متوسط السلة' : 'Panier',
                            value: formatCurrency(context, avgBasket, compact: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _CustomerStatCard(
                      icon: Icons.loyalty_rounded,
                      label: ar ? 'نسبة العملاء العائدين' : 'Taux de fidélisation',
                      value: formatPercent(context, repeatRate),
                      compact: true,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.searchOrdersHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: l10n.clearSearch,
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SectionHeader(
                      title: ar ? 'القائمة' : 'Classement',
                      subtitle:
                          '${formatNumber(context, filtered.length)} ${ar ? 'نتيجة' : 'résultats'}',
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
          else if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                compact: true,
                icon: Icons.search_off_rounded,
                title: l10n.noResultsTitle,
                body: l10n.noResultsBody,
                actionLabel: l10n.clearSearch,
                onAction: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.bottomNavClearance),
              sliver: SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final c = filtered[i];
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
                    child: SoftCard(
                      onTap: () => _openCustomer(context, c),
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
                                    style: texts.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(
                                  [
                                    if (c.phone.isNotEmpty) formatPhone(c.phone),
                                    '${formatNumber(context, c.orders)} ${l10n.ordersWord}',
                                  ].join(' · '),
                                  style: texts.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(formatCurrency(context, c.spent, compact: true),
                                  style: texts.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700, color: AppColors.mintDeep)),
                              Text(l10n.totalSpent,
                                  style: texts.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant)),
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

class _CustomerStatCard extends StatelessWidget {
  const _CustomerStatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.sm + 2),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: AppSizes.iconSm, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!compact)
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (compact)
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
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

class _TagChip extends StatelessWidget {
  const _TagChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.onSurfaceVariant),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }
}
