import 'package:flutter/material.dart';

import '../../core/services/fennecly_data_service.dart';
import '../../core/widgets/app_backdrop.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/soft_card.dart';

/// COD manager — parity with the web cod_collections / cod_transfers flow.
/// Collection statuses: in_transit | delivered | returned | collected.
class CodManagerScreen extends StatefulWidget {
  const CodManagerScreen({super.key});

  @override
  State<CodManagerScreen> createState() => _CodManagerScreenState();
}

class _CodManagerScreenState extends State<CodManagerScreen> {
  List<Map<String, dynamic>> _collections = const [];
  List<Map<String, dynamic>> _transfers = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      FenneclyDataService.listCodCollections(),
      FenneclyDataService.listCodTransfers(),
    ]);
    if (!mounted) return;
    setState(() {
      _collections = results[0];
      _transfers = results[1];
      _loading = false;
    });
  }

  double _double(Map<String, dynamic> row, String key) =>
      (row[key] as num?)?.toDouble() ?? 0;

  double get _collected {
    var sum = 0.0;
    for (final row in _collections) {
      if ((row['status'] ?? '').toString() == 'collected') {
        sum += _double(row, 'amount');
      }
    }
    return sum;
  }

  double get _pending {
    var sum = 0.0;
    for (final row in _collections) {
      final status = (row['status'] ?? '').toString();
      if (status == 'in_transit' || status == 'delivered') {
        sum += _double(row, 'amount');
      }
    }
    return sum;
  }

  double get _transferred {
    var sum = 0.0;
    for (final row in _transfers) {
      sum += _double(row, 'amount');
    }
    return sum;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'collected':
        return Colors.teal;
      case 'delivered':
        return Colors.indigo;
      case 'returned':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status, bool ar) {
    switch (status) {
      case 'collected':
        return ar ? 'تم التحصيل' : 'Encaissé';
      case 'delivered':
        return ar ? 'وصلت' : 'Livrée';
      case 'returned':
        return ar ? 'مرتجعة' : 'Retournée';
      default:
        return ar ? 'في الطريق' : 'En transit';
    }
  }

  String _dateText(dynamic raw) {
    final parsed = DateTime.tryParse((raw ?? '').toString());
    if (parsed == null) return '';
    return formatDateMedium(context, parsed);
  }

  @override
  Widget build(BuildContext context) {
    final ar = isArabicContext(context);
    final scheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: const AppBackButton(),
          title: Text(ar ? 'إدارة الدفع عند الاستلام' : 'Gestion COD'),
          bottom: TabBar(
            indicatorColor: scheme.primary,
            labelColor: scheme.primary,
            unselectedLabelColor: scheme.onSurfaceVariant,
            tabs: [
              Tab(text: ar ? 'التحصيلات' : 'Encaissements'),
              Tab(text: ar ? 'التحويلات' : 'Transferts'),
            ],
          ),
        ),
        body: AppBackdrop(
          child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: TabBarView(
                  children: [
                    _CollectionsTab(
                      collections: _collections,
                      collected: _collected,
                      pending: _pending,
                      statusColor: _statusColor,
                      statusLabel: (s) => _statusLabel(s, ar),
                      dateText: _dateText,
                    ),
                    _TransfersTab(
                      transfers: _transfers,
                      transferred: _transferred,
                      dateText: _dateText,
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            formatCurrency(context, value, compact: true),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

typedef _StatusColorFn = Color Function(String status);
typedef _StatusLabelFn = String Function(String status);

class _CollectionsTab extends StatelessWidget {
  const _CollectionsTab({
    required this.collections,
    required this.collected,
    required this.pending,
    required this.statusColor,
    required this.statusLabel,
    required this.dateText,
  });

  final List<Map<String, dynamic>> collections;
  final double collected;
  final double pending;
  final _StatusColorFn statusColor;
  final _StatusLabelFn statusLabel;
  final String Function(dynamic) dateText;

  @override
  Widget build(BuildContext context) {
    final ar = isArabicContext(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: ar ? 'مُحصَّل' : 'Collecté',
                value: collected,
                color: AppColors.mintDeep,
                icon: Icons.savings_rounded,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatTile(
                label: ar ? 'قيد الانتظار' : 'En attente',
                value: pending,
                color: AppColors.amber,
                icon: Icons.hourglass_top_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (collections.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.lg),
            child: EmptyState(
              compact: true,
              icon: Icons.storefront_rounded,
              title: 'Aucun versement COD',
              body:
                  'Les collections apparaissent dès que des colis parviennent à la livraison.',
            ),
          )
        else
          for (final row in collections) ...[
            _CollectionCard(
              row: row,
              statusColor: statusColor,
              statusLabel: statusLabel,
              dateText: dateText,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard({
    required this.row,
    required this.statusColor,
    required this.statusLabel,
    required this.dateText,
  });

  final Map<String, dynamic> row;
  final _StatusColorFn statusColor;
  final _StatusLabelFn statusLabel;
  final String Function(dynamic) dateText;

  @override
  Widget build(BuildContext context) {
    final status = (row['status'] ?? 'in_transit').toString();
    final amount = (row['amount'] as num?)?.toDouble() ?? 0;
    final theme = Theme.of(context);
    return SoftCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (row['customer_name'] ?? '—').toString(),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel(status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor(status),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${(row['delivery_company'] ?? '').toString()} · '
                  '${(row['tracking_number'] ?? '').toString()}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                formatCurrency(context, amount),
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          if (dateText(row['created_at']).isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              dateText(row['created_at']),
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransfersTab extends StatelessWidget {
  const _TransfersTab({
    required this.transfers,
    required this.transferred,
    required this.dateText,
  });

  final List<Map<String, dynamic>> transfers;
  final double transferred;
  final String Function(dynamic) dateText;

  @override
  Widget build(BuildContext context) {
    final ar = isArabicContext(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        _StatTile(
          label: ar ? 'محوّل إلى الورش' : 'Transféré',
          value: transferred,
          color: Theme.of(context).colorScheme.primary,
          icon: Icons.currency_exchange_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        if (transfers.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.lg),
            child: EmptyState(
              compact: true,
              icon: Icons.currency_exchange_rounded,
              title: 'Aucun transfert',
              body: 'Les versements de votre société de livraison apparaîtront ici.',
            ),
          )
        else
          for (final row in transfers) ...[
            SoftCard(
              padding: const EdgeInsetsDirectional.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.local_atm_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (row['delivery_company'] ?? '—').toString(),
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dateText(row['transfer_date'])}'
                          '${((row['reference'] ?? '').toString().isNotEmpty) ? ' · ${(row['reference'])}' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatCurrency(
                      context,
                      (row['amount'] as num?)?.toDouble() ?? 0,
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}
