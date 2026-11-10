import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'dart:convert';
import 'dart:io';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/order.dart';
import '../../core/services/fennecly_data_service.dart';
import '../../core/services/whatsapp_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/filter_pill.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/soft_card.dart';
import '../../core/widgets/status_pill.dart';
import 'order_form_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Order? _order;
  bool _missing = false;
  final TextEditingController _trackingController = TextEditingController();
  bool _busyShipment = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = context.read<AppStore>();
    try {
      _order = store.orders.firstWhere((order) => order.id == widget.orderId);
      _missing = false;
    } catch (_) {
      _order = null;
      _missing = true;
    }
  }

  Future<void> _setStatus(OrderStatus status) async {
    final order = _order;
    if (order == null || order.status == status) return;
    context.read<AppStore>().updateOrderStatus(order, status);
    AppHaptics.success();
    final l10n = AppLocalizations.of(context);
    showAppSnackBar(context, l10n.statusUpdated);
  }

  Future<void> _openWhatsApp() async {
    final order = _order;
    if (order == null) return;
    final store = context.read<AppStore>();
    final l10n = AppLocalizations.of(context);
    final arabic = l10n.isArabic;
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
    if (!ok && mounted) {
      showAppSnackBar(
        context,
        l10n.whatsappUnavailable,
        icon: Icons.error_outline_rounded,
        iconColor: Theme.of(context).colorScheme.error,
      );
    }
  }

  Future<void> _call() async {
    final order = _order;
    if (order == null) return;
    final ok = await WhatsAppService.call(order.phone);
    if (!ok) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      showAppSnackBar(
        context,
        l10n.callNotSupported,
        icon: Icons.error_outline_rounded,
        iconColor: Theme.of(context).colorScheme.error,
      );
      return;
    }
    if (!mounted) return;
    // Phase 1 parity: record the call in the shared call_logs table, then let
    // the merchant pick the outcome (answered | no_answer | callback | pending).
    final callLogId = await FenneclyDataService.logCall(
      orderId: order.id,
      customerPhone: order.phone,
      customerName: order.customerName,
      channel: 'phone',
    );
    if (callLogId == null || !mounted) return;
    final outcome = await _askCallOutcome();
    if (outcome == null || !mounted) return;
    final updated = await FenneclyDataService.updateCallOutcome(
      callLogId: callLogId,
      outcome: outcome,
    );
    if (!updated || !mounted) return;
    if (outcome == 'no_answer') {
      // Web stores "no answer" outcomes via call_logs; mirror it onto the
      // order status (local + shared DB push handled by AppStore).
      if (!mounted) return;
      context.read<AppStore>().updateOrderStatus(
            order.copyWith(status: OrderStatus.noAnswer),
            OrderStatus.noAnswer,
          );
    }
  }

  Future<String?> _askCallOutcome() async {
    final l10n = AppLocalizations.of(context);
    const options = <({String value, String label})>[
      (value: 'answered', label: 'answered'),
      (value: 'no_answer', label: 'noAnswer'),
      (value: 'callback', label: 'callback'),
      (value: 'pending', label: 'pending'),
    ];
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        final texts = Theme.of(sheetContext).textTheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.callOutcomeTitle,
                  textAlign: TextAlign.center,
                  style: texts.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final option in options) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      option.value == 'no_answer'
                          ? Icons.phone_disabled_rounded
                          : Icons.call_rounded,
                      color: scheme.primary,
                    ),
                    title: Text(
                      option.value == 'answered'
                          ? l10n.callOutcomeAnswered
                          : option.value == 'no_answer'
                              ? l10n.callOutcomeNoAnswer
                              : option.value == 'callback'
                                  ? l10n.callOutcomeCallback
                                  : l10n.callOutcomePending,
                    ),
                    onTap: () => Navigator.of(sheetContext).pop(option.value),
                  ),
                  const Divider(height: 1),
                ],
              ],
            ),
          ),
        );
      },
    );
    return picked;
  }

  Future<void> _delete() async {
    final order = _order;
    if (order == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.deleteOrder,
      body: l10n.deleteOrderBody,
      confirmLabel: l10n.delete,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    context.read<AppStore>().deleteOrder(order.id);
    AppHaptics.warning();
    showAppSnackBar(context, l10n.orderDeleted);
    Navigator.of(context).pop();
  }

  Future<void> _toggleCodPaid() async {
    final order = _order;
    if (order == null) return;
    context.read<AppStore>().updateOrder(order.copyWith(codPaidByCompany: !order.codPaidByCompany));
    AppHaptics.select();
    final l10n = AppLocalizations.of(context);
    if (!mounted) return;
    showAppSnackBar(context, l10n.isArabic ? 'تم تحديث الدفع (COD)' : 'Paiement COD mis à jour');
  }

  Future<void> _createShipmentNow() async {
    final order = _order;
    if (order == null) return;
    final tracking = _trackingController.text.trim();
    if (tracking.isEmpty) {
      showAppSnackBar(context, 'Tracking number requis');
      return;
    }
    setState(() => _busyShipment = true);
    final storeInfo = await FenneclyDataService.resolveCurrentStore();
    final ok = await FenneclyDataService.createShipment(
      storeId: storeInfo?.id ?? '',
      orderId: order.id,
      trackingNumber: tracking,
      deliveryType: order.deliveryType == 'office' ? 'stopdesk' : 'domicile',
    );
    if (!mounted) return;
    setState(() => _busyShipment = false);
    if (ok) {
      AppHaptics.success();
      showAppSnackBar(context, 'Expédition créée');
    } else {
      AppHaptics.warning();
      showAppSnackBar(context, 'Échec de la création de l’expédition');
    }
  }

  Future<void> _fetchAndShareBordereau() async {
    final order = _order;
    if (order == null) return;
    final storeInfo = await FenneclyDataService.resolveCurrentStore();
    final storeId = storeInfo?.id ?? '';
    final colisId = order.trackingNumber.isNotEmpty ? order.trackingNumber : order.id;
    final pdfBase64 = await FenneclyDataService.fetchBordereauPdf(
      storeId: storeId,
      colisId: colisId,
    );
    if (!mounted) return;
    if (pdfBase64 == null || pdfBase64.isEmpty) {
      AppHaptics.warning();
      showAppSnackBar(context, 'Bordereau indisponible');
      return;
    }
    final bytes = base64Decode(pdfBase64);
    final file = File(
      '${Directory.systemTemp.path}/orderbox_bordereau_${order.id}.pdf',
    );
    await file.writeAsBytes(bytes);
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], subject: 'Bordereau'),
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_missing) {
      return Scaffold(
        appBar: AppBar(leading: const AppBackButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final order = _order!;
    final l10n = AppLocalizations.of(context);
    final arabic = l10n.isArabic;
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: const AppBackButton(),
            title: Text('${l10n.orderNumber} ${order.reference}'),
            actions: [
              IconButton(
                tooltip: l10n.edit,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OrderFormScreen(orderId: order.id),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_rounded),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') _delete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: scheme.error,
                          size: AppSizes.iconMd,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          l10n.delete,
                          style: TextStyle(color: scheme.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.bottomNavClearance,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusPill(status: order.status),
                            const Spacer(),
                            Text(
                              formatDateTime(context, order.createdAt),
                              style: texts.bodySmall?.copyWith(
                                color: AppColors.lightSurface.withValues(
                                  alpha: 0.78,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          order.customerName,
                          style: texts.headlineSmall?.copyWith(
                            color: AppColors.lightSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          order.productName,
                          style: texts.bodyMedium?.copyWith(
                            color: AppColors.lightSurface.withValues(
                              alpha: 0.82,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            _HeaderAmount(
                              label: l10n.total,
                              value: formatCurrency(context, order.total),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            _HeaderAmount(
                              label: l10n.profit,
                              value: formatCurrency(context, order.profit),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _openWhatsApp,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.mint,
                            foregroundColor: AppColors.lightSurface,
                          ),
                          icon: const Icon(Icons.chat_bubble_rounded),
                          label: Text(
                            order.status == OrderStatus.newOrder ||
                                    order.status == OrderStatus.noAnswer
                                ? l10n.whatsappConfirm
                                : l10n.whatsappContact,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _CircleAction(
                        icon: Icons.call_rounded,
                        color: scheme.primary,
                        onTap: _call,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _CircleAction(
                        icon: Icons.content_copy_rounded,
                        color: scheme.onSurfaceVariant,
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: order.phone),
                          );
                          showAppSnackBar(context, l10n.phoneCopied);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(
                    title: l10n.status,
                    subtitle: l10n.chooseStatus,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: OrderStatus.values.map((status) {
                        final selected = order.status == status;
                        return Padding(
                          padding: const EdgeInsetsDirectional.only(
                            end: AppSpacing.xs,
                          ),
                          child: FilterPill(
                            label: l10n.statusLabel(status),
                            selected: selected,
                            onTap: () => _setStatus(status),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(title: l10n.customer),
                  const SizedBox(height: AppSpacing.xs),
                  SoftCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.person_rounded,
                          label: l10n.customerName,
                          value: order.customerName,
                        ),
                        _InfoRow(
                          icon: Icons.phone_rounded,
                          label: l10n.phone,
                          value: formatPhone(order.phone),
                          valueDirection: TextDirection.ltr,
                        ),
                        _InfoRow(
                          icon: Icons.location_on_rounded,
                          label: l10n.wilaya,
                          value: order.wilayaNameFor(arabic),
                        ),
                        _InfoRow(
                          icon: Icons.map_rounded,
                          label: l10n.commune,
                          value: order.commune,
                        ),
                        _InfoRow(
                          icon: Icons.home_rounded,
                          label: l10n.address,
                          value: order.address,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(title: l10n.isArabic ? 'الشحن (fennecly)' : 'Expédition (fennecly)'),
                  const SizedBox(height: AppSpacing.xs),
                  SoftCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.local_shipping_rounded,
                          label: l10n.isArabic ? 'شركة التوصيل' : 'Société',
                          value: order.deliveryCompany.isEmpty ? '-' : order.deliveryCompany,
                        ),
                        _InfoRow(
                          icon: order.deliveryType == 'office' ? Icons.store_rounded : Icons.home_rounded,
                          label: l10n.isArabic ? 'نوع التوصيل' : 'Type',
                          value: order.deliveryType == 'office'
                              ? (l10n.isArabic ? 'مكتب (Stopdesk)' : 'Bureau (Stopdesk)')
                              : (l10n.isArabic ? 'منزل' : 'Domicile'),
                        ),
                        _InfoRow(
                          icon: Icons.payments_rounded,
                          label: l10n.deliveryPrice,
                          value: formatCurrency(context, order.deliveryPrice),
                        ),
                        _InfoRow(
                          icon: Icons.qr_code_2_rounded,
                          label: l10n.isArabic ? 'رقم التتبع' : 'Suivi',
                          value: order.trackingNumber.isEmpty ? '-' : order.trackingNumber,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SoftCard(
                    child: Row(
                      children: [
                        Icon(
                          order.codPaidByCompany ? Icons.verified_rounded : Icons.hourglass_bottom_rounded,
                          color: order.codPaidByCompany ? AppColors.mintDeep : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.isArabic ? 'الدفع عند الاستلام — مستحق عند شركة التوصيل' : 'COD — dû par la société de livraison',
                                style: texts.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                order.codPaidByCompany
                                    ? (l10n.isArabic ? 'تم استلام المبلغ من الشركة' : 'Payé par la société')
                                    : (l10n.isArabic ? 'لم يُستلم بعد' : 'Non reçu'),
                                style: texts.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Switch(value: order.codPaidByCompany, onChanged: (_) => _toggleCodPaid()),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _busyShipment ? null : _createShipmentNow,
                          icon: _busyShipment
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.local_shipping_rounded),
                          label: Text(
                            _order?.status == OrderStatus.newOrder ||
                                    _order?.status == OrderStatus.noAnswer
                                ? 'Créer expédition'
                                : 'Nouvelle expédition',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: _busyShipment ? null : _fetchAndShareBordereau,
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        label: const Text('Bordereau'),
                      ),
                    ],
                  ),
                  TextField(
                    controller: _trackingController,
                    decoration: InputDecoration(
                      labelText: 'Tracking / Colis ID',
                      hintText: _order?.trackingNumber ?? '',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(title: l10n.deliveryInfo),
                  const SizedBox(height: AppSpacing.xs),
                  SoftCard(
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.inventory_2_rounded,
                          label: l10n.product,
                          value: order.productName,
                        ),
                        _InfoRow(
                          icon: Icons.numbers_rounded,
                          label: l10n.quantity,
                          value: formatNumber(context, order.quantity),
                        ),
                        _InfoRow(
                          icon: Icons.sell_rounded,
                          label: l10n.unitPrice,
                          value: formatCurrency(context, order.unitPrice),
                        ),
                        _InfoRow(
                          icon: Icons.receipt_long_rounded,
                          label: l10n.subtotal,
                          value: formatCurrency(context, order.subtotal),
                        ),
                        _InfoRow(
                          icon: Icons.summarize_rounded,
                          label: l10n.total,
                          value: formatCurrency(context, order.total),
                          valueStyle: texts.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _InfoRow(
                          icon: Icons.trending_up_rounded,
                          label: l10n.profit,
                          value: formatCurrency(context, order.profit),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SectionHeader(title: l10n.notes),
                  const SizedBox(height: AppSpacing.xs),
                  SoftCard(
                    child: Text(
                      order.notes.trim().isEmpty
                          ? l10n.noNotes
                          : order.notes,
                      style: texts.bodyMedium?.copyWith(
                        color: order.notes.trim().isEmpty
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                        fontStyle: order.notes.trim().isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton.icon(
                    onPressed: _delete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                      side: BorderSide(color: scheme.error.withValues(alpha: 0.4)),
                      minimumSize: const Size.fromHeight(52),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: Text(l10n.deleteOrder),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderAmount extends StatelessWidget {
  const _HeaderAmount({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final texts = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: texts.labelSmall?.copyWith(
            color: AppColors.lightSurface.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: texts.titleMedium?.copyWith(
            color: AppColors.lightSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: color, size: AppSizes.iconMd),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueDirection,
    this.valueStyle,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextDirection? valueDirection;
  final TextStyle? valueStyle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              size: AppSizes.iconSm,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: texts.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  textDirection: valueDirection,
                  style: valueStyle ??
                      texts.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
