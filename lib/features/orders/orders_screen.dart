import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/order.dart';
import '../../core/services/whatsapp_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/filter_pill.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../core/widgets/order_card.dart';
import '../../core/widgets/skeletons.dart';
import '../../core/widgets/soft_card.dart';
import 'order_details_screen.dart';
import 'order_form_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, this.onOpenSettings});

  final VoidCallback? onOpenSettings;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  OrderStatus? _filter;
  bool _loading = true;
  Timer? _timer;
  final Set<String> _selectedIds = <String>{};
  bool _multiSelect = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 560), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    AppHaptics.select();
    await Future<void>.delayed(const Duration(milliseconds: 620));
    if (mounted) setState(() {});
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _bulkUpdateStatus(OrderStatus status) async {
    final store = context.read<AppStore>();
    final targets = store.orders.where((o) => _selectedIds.contains(o.id)).toList();
    if (targets.isEmpty) return;
    for (final order in targets) {
      store.updateOrderStatus(order, status);
    }
    if (mounted) {
      setState(() => _selectedIds.clear());
    }
  }

  Future<void> _exportCsv(List<Order> rows) async {
    if (rows.isEmpty) return;
    final buffer = StringBuffer();
    buffer.writeln('ID,Customer,Phone,Wilaya,City,Status,Total,Date');
    for (final order in rows) {
      final cells = <String>[
        order.id,
        order.customerName,
        order.phone,
        order.wilayaCode,
        order.commune,
        order.status.id,
        order.total.toStringAsFixed(2),
        order.createdAt.toIso8601String(),
      ];
      buffer.writeln(cells.map((c) => '"${c.replaceAll('"', '""')}"').join(','));
    }
    final file = File(
      '${Directory.systemTemp.path}/orderbox_orders_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    file.writeAsStringSync(buffer.toString());
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: 'orders'),
      );
    } catch (_) {}
  }

  List<Order> _filteredOrders(AppStore store) {
    final query = _searchController.text.trim().toLowerCase();
    return store.orders.where((order) {
      if (_filter != null && order.status != _filter) return false;
      if (query.isEmpty) return true;
      final haystack = [
        order.customerName,
        order.phone,
        order.reference,
        order.productName,
        order.wilayaName,
        order.wilayaNameAr,
        order.commune,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l10n = AppLocalizations.of(context);
    final arabic = l10n.isArabic;
    final orders = store.orders;
    final filtered = _filteredOrders(store);
    final todayCount = store.countToday(orders);
    final pendingCount = store.awaitingConfirmationOf(orders);
    final deliveredCount = store.deliveredCountOf(orders);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        edgeOffset: 0,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                  l10n.ordersTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(fontSize: 28),
                                ),
                              ],
                            ),
                          ),
                          InitialsAvatar(
                            name: store.storeNameOr(l10n.storeDefault),
                            size: 46,
                            onTap: widget.onOpenSettings,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.ordersCount(
                          formatNumber(context, orders.length),
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SoftCard(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _MiniStat(
                                icon: Icons.today_rounded,
                                color: Theme.of(context).colorScheme.primary,
                                label: l10n.summaryToday,
                                value: formatNumber(context, todayCount),
                              ),
                            ),
                            _StatDivider(),
                            Expanded(
                              child: _MiniStat(
                                icon: Icons.notifications_active_rounded,
                                color: AppColors.amber,
                                label: l10n.summaryToConfirm,
                                value: formatNumber(context, pendingCount),
                              ),
                            ),
                            _StatDivider(),
                            Expanded(
                              child: _MiniStat(
                                icon: Icons.check_circle_rounded,
                                color: AppColors.green,
                                label: l10n.summaryDelivered,
                                value: formatNumber(context, deliveredCount),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _searchController,
                        focusNode: _searchFocus,
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
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: () => setState(() => _multiSelect = true),
                          icon: const Icon(Icons.checklist_rounded),
                          label: Text(l10n.selectOrders),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            FilterPill(
                              label: l10n.all,
                              selected: _filter == null,
                              count: orders.length,
                              onTap: () => setState(() => _filter = null),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            for (final status in OrderStatus.values) ...[
                              FilterPill(
                                label: l10n.statusLabel(status),
                                selected: _filter == status,
                                count: orders
                                    .where((order) => order.status == status)
                                    .length,
                                onTap: () => setState(() => _filter = status),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: OutlinedButton.icon(
                          onPressed: () => _exportCsv(filtered),
                          icon: const Icon(Icons.download_rounded),
                          label: Text(
                            l10n.isArabic ? 'تصدير CSV' : 'Exporter les commandes (CSV)',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_multiSelect) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: SoftCard(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    child: Row(
                      children: [
                        Icon(
                          Icons.checklist_rounded,
                          size: AppSizes.iconSm,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n.ordersCount(_selectedIds.length.toString()),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _multiSelect = false),
                          child: Text(l10n.cancel),
                        ),
                        for (final status in OrderStatus.values)
                          TextButton(
                            onPressed: () => _bulkUpdateStatus(status),
                            child: Text(l10n.statusLabel(status)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (_loading)
              SliverPadding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                sliver: SliverToBoxAdapter(
                  child: const OrderListSkeleton(),
                ),
              )
            else if (orders.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: l10n.noOrdersTitle,
                  body: l10n.noOrdersBody,
                  actionLabel: l10n.addOrder,
                  onAction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const OrderFormScreen(),
                      ),
                    );
                  },
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
                    setState(() => _filter = null);
                  },
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
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    return _AnimatedEntry(
                      key: ValueKey(order.id),
                      delay: Duration(milliseconds: (index * 34).clamp(0, 240)),
                      child: OrderCard(
                        order: order,
                        showCheckbox: _multiSelect,
                        checked: _selectedIds.contains(order.id),
                        onCheckboxChanged: _multiSelect
                            ? (value) => _toggleSelect(order.id)
                            : null,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderDetailsScreen(orderId: order.id),
                            ),
                          );
                        },
                        onWhatsApp: () async {
                          final message = l10n.whatsappOrderMessage(
                            customer: order.customerName,
                            product: order.productName,
                            wilaya: order.wilayaNameFor(arabic),
                            store: store.storeNameOr(l10n.storeDefault),
                          );
                          final ok = await WhatsAppService.openChat(
                            phone: order.phone,
                            message: message,
                          );
                          if (!ok && context.mounted) {
                            showAppSnackBar(
                              context,
                              l10n.whatsappUnavailable,
                              icon: Icons.error_outline_rounded,
                              iconColor: Theme.of(context).colorScheme.error,
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final texts = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.iconSm, color: color),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: texts.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: texts.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

class _AnimatedEntry extends StatefulWidget {
  const _AnimatedEntry({
    super.key,
    required this.child,
    required this.delay,
  });

  final Widget child;
  final Duration delay;

  @override
  State<_AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<_AnimatedEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}
