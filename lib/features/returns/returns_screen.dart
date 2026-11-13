import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/models/order.dart';
import '../../core/services/fennecly_data_service.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_backdrop.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/soft_card.dart';

/// Returns & refunds — parity with the web dashboard.returns route.
/// Statuses: requested | approved | rejected | received | refunded.
class ReturnsScreen extends StatefulWidget {
  const ReturnsScreen({super.key});

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  final List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  bool _busy = false;

  bool _isUuid(String s) =>
      RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
          .hasMatch(s);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await FenneclyDataService.listReturns();
    if (!mounted) return;
    setState(() {
      _rows
        ..clear()
        ..addAll(rows);
      _loading = false;
    });
  }

  String _shortId(String orderId) =>
      orderId.length <= 8 ? orderId : orderId.substring(0, 8);

  double _orderTotal(String orderId) {
    final store = context.read<AppStore>();
    for (final order in store.orders) {
      if (order.id == orderId) return order.total;
    }
    return 0;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
      case 'received':
        return Colors.teal;
      case 'refunded':
        return Colors.indigo;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    final ar = isArabicContext(context);
    switch (status) {
      case 'approved':
        return ar ? 'موافق عليها' : 'Approuvé';
      case 'rejected':
        return ar ? 'مرفوضة' : 'Rejeté';
      case 'received':
        return ar ? 'تم استلامها' : 'Reçue';
      case 'refunded':
        return ar ? 'تمّت التحويلة' : 'Remboursé';
      default:
        return ar ? 'طلب جديد' : 'Demandé';
    }
  }

  Future<void> _updateStatus(
    Map<String, dynamic> row,
    String status, {
    double? refundAmount,
  }) async {
    setState(() => _busy = true);
    final ok = await FenneclyDataService.updateReturnStatus(
      (row['id'] ?? '').toString(),
      status,
      refundAmount: refundAmount,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) {
        row['status'] = status;
        if (refundAmount != null) row['refund_amount'] = refundAmount;
      }
    });
    AppHaptics.select();
    showAppSnackBar(
      context,
      ok ? '✓ ${_statusLabel(status)}' : 'Échec de la mise à jour',
      icon: ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
      iconColor: ok ? null : Theme.of(context).colorScheme.error,
    );
  }

  Future<void> _refund(Map<String, dynamic> row) async {
    final orderId = (row['order_id'] ?? '').toString();
    final defaultAmount = _orderTotal(orderId);
    final controller = TextEditingController(
      text: defaultAmount > 0
          ? defaultAmount.toStringAsFixed(0)
          : '0',
    );
    final amount = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Montant du remboursement'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: 'DA ',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final parsed =
                    double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;
                Navigator.of(dialogContext).pop(parsed);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (amount == null || !mounted) return;
    await _updateStatus(row, 'refunded', refundAmount: amount);
  }

  Future<void> _createReturn() async {
    final store = context.read<AppStore>();
    final eligible = store.orders.where((o) => _isUuid(o.id)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (eligible.isEmpty) {
      showAppSnackBar(
        context,
        'Aucune commande synchronisée n’est éligible',
        icon: Icons.info_outline_rounded,
      );
      return;
    }
    Order order = eligible.first;
    final nameController = TextEditingController(text: order.customerName);
    final emailController = TextEditingController();
    final reasonController = TextEditingController();
    final detailsController = TextEditingController();
    Order picked = order;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nouvelle demande de retour',
                      textAlign: TextAlign.center,
                      style: Theme.of(sheetContext)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<Order>(
                      initialValue: picked,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Commande',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final o in eligible.take(50))
                          DropdownMenuItem(
                            value: o,
                            child: Text(
                              '#${_shortId(o.id)} — ${o.customerName}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() {
                          picked = value;
                          nameController.text = value.customerName;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du client',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email (optionnel)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Motif du retour',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: detailsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Détails (optionnel)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(sheetContext).pop(true),
                      child: const Text('Envoyer la demande'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (created != true || !mounted) return;
    final storeInfo = await FenneclyDataService.resolveCurrentStore();
    setState(() => _busy = true);
    final ok = await FenneclyDataService.createReturn(
      orderId: picked.id,
      storeOwnerId: storeInfo?.ownerId ?? '',
      customerName: nameController.text.trim(),
      customerEmail: emailController.text.trim(),
      reason: reasonController.text.trim(),
      details: detailsController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    AppHaptics.select();
    if (ok) {
      showAppSnackBar(context, 'Demande de retour créée ✓');
      await _load();
    } else {
      showAppSnackBar(
        context,
        'Échec de la création',
        icon: Icons.error_outline_rounded,
        iconColor: Theme.of(context).colorScheme.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ar = isArabicContext(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(ar ? 'المرتجعات' : 'Retours & remboursements'),
      ),
      floatingActionButton: (_loading || _busy)
          ? null
          : FloatingActionButton.extended(
              onPressed: _createReturn,
              icon: const Icon(Icons.add_rounded),
              label: Text(ar ? 'طلب إرجاع' : 'Nouveau retour'),
            ),
      body: AppBackdrop(
        child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _rows.isEmpty
                  ? CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        const SliverFillRemaining(
                          child: EmptyState(
                            icon: Icons.assignment_return_rounded,
                            title: 'Aucune demande de retour',
                            body:
                                'Créez une demande à partir d’une commande synchronisée.',
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.xxl,
                      ),
                      itemCount: _rows.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final row = _rows[index];
                        final status = (row['status'] ?? 'requested').toString();
                        final orderId = (row['order_id'] ?? '').toString();
                        final amount =
                            (row['refund_amount'] as num?)?.toDouble() ?? 0;
                        return SoftCard(
                          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      (row['customer_name'] ?? '').toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _statusColor(status).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      _statusLabel(status),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: _statusColor(status),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '#${_shortId(orderId)} · ${(row['reason'] ?? '').toString()}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (amount > 0) ...[
                                const SizedBox(height: 6),
                                Text(
                                  formatCurrency(context, amount),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color:
                                            Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.sm),
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.xs,
                                children: [
                                  if (status == 'requested') ...[
                                    OutlinedButton(
                                      onPressed: _busy
                                          ? null
                                          : () => _updateStatus(row, 'approved'),
                                      child: Text(ar ? 'موافقة' : 'Approuver'),
                                    ),
                                    OutlinedButton(
                                      onPressed: _busy
                                          ? null
                                          : () => _updateStatus(row, 'rejected'),
                                      child: Text(
                                        ar ? 'رفض' : 'Rejeter',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (status == 'approved')
                                    OutlinedButton(
                                      onPressed: _busy
                                          ? null
                                          : () => _updateStatus(row, 'received'),
                                      child:
                                          Text(ar ? 'تمّ الاستلام' : 'Marquer reçue'),
                                    ),
                                  if (status == 'received')
                                    FilledButton(
                                      onPressed:
                                          _busy ? null : () => _refund(row),
                                      child: Text(ar ? 'استرجاع المبلغ' : 'Rembourser'),
                                    ),
                                  if (status == 'refunded' && amount > 0)
                                    Text(
                                      '${ar ? 'المبلغ:' : 'Refund:'} ${formatCurrency(context, amount)}',
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
        ),
    );
  }
}
