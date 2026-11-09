import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/order.dart';
import '../../core/models/product.dart';
import '../../core/models/wilaya.dart';
import '../../domain/models/algeria_geo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/filter_pill.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/soft_card.dart';
import '../products/product_form_sheet.dart';
import '../../core/widgets/sheet_header.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key, this.orderId});

  final String? orderId;

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _customerController;
  late final TextEditingController _phoneController;
  late final TextEditingController _communeController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _deliveryController;
  late final TextEditingController _trackingController;

  Order? _existing;
  String? _wilayaCode;
  String? _productId;
  OrderStatus _status = OrderStatus.newOrder;
  String _deliveryCompany = 'Yalidine';
  String _deliveryType = 'home'; // home | office
  bool _codPaidByCompany = false;
  bool _saving = false;
  int _riskyReturned = 0;
  int _riskyNoAnswer = 0;

  bool get _isEditing => widget.orderId != null;

  @override
  void initState() {
    super.initState();
    final store = context.read<AppStore>();
    _existing = widget.orderId == null
        ? null
        : store.orders.firstWhere(
            (order) => order.id == widget.orderId,
            orElse: () => store.orders.first,
          );
    if (_existing != null && _existing!.id != widget.orderId) {
      _existing = null;
    }

    _customerController = TextEditingController(
      text: _existing?.customerName ?? '',
    );
    _phoneController = TextEditingController(text: _existing?.phone ?? '');
    _communeController = TextEditingController(text: _existing?.commune ?? '');
    _addressController = TextEditingController(text: _existing?.address ?? '');
    _notesController = TextEditingController(text: _existing?.notes ?? '');
    _quantityController = TextEditingController(
      text: (_existing?.quantity ?? 1).toString(),
    );
    _priceController = TextEditingController(
      text: _existing == null
          ? ''
          : _existing!.unitPrice.toStringAsFixed(0),
    );
    _deliveryController = TextEditingController(
      text: (_existing?.deliveryPrice ?? 500).toStringAsFixed(0),
    );
    _trackingController = TextEditingController(text: _existing?.trackingNumber ?? '');

    _wilayaCode = _existing?.wilayaCode;
    _productId = _existing?.productId;
    _status = _existing?.status ?? OrderStatus.newOrder;
    _deliveryCompany = _existing?.deliveryCompany.isNotEmpty == true
        ? _existing!.deliveryCompany
        : (store.deliveryCompanies.isNotEmpty ? store.defaultDeliveryCompany : 'Yalidine');
    _deliveryType = _existing?.deliveryType ?? 'home';
    _codPaidByCompany = _existing?.codPaidByCompany ?? false;
    _checkRisky(_phoneController.text);
  }

  void _checkRisky(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) {
      if (_riskyReturned != 0 || _riskyNoAnswer != 0) {
        setState(() { _riskyReturned = 0; _riskyNoAnswer = 0; });
      }
      return;
    }
    final store = context.read<AppStore>();
    var ret = 0, na = 0;
    for (final o in store.orders) {
      if (_existing != null && o.id == _existing!.id) continue;
      final od = o.phone.replaceAll(RegExp(r'\D'), '');
      if (od.isEmpty || (!digits.endsWith(od.length >= 9 ? od.substring(od.length - 9) : od) && !od.endsWith(digits.length >= 9 ? digits.substring(digits.length - 9) : digits))) continue;
      if (o.status == OrderStatus.returned) ret++;
      if (o.status == OrderStatus.noAnswer) na++;
    }
    if (ret != _riskyReturned || na != _riskyNoAnswer) {
      setState(() { _riskyReturned = ret; _riskyNoAnswer = na; });
    }
  }

  @override
  void dispose() {
    _customerController.dispose();
    _phoneController.dispose();
    _communeController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _deliveryController.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  Product? get _selectedProduct {
    if (_productId == null) return null;
    return context.read<AppStore>().productById(_productId!);
  }

  Wilaya? get _selectedWilaya {
    if (_wilayaCode == null) return null;
    return Wilaya.all.firstWhere(
      (wilaya) => wilaya.code == _wilayaCode,
      orElse: () => Wilaya.all.first,
    );
  }

  void _selectWilaya() async {
    final selected = await showModalBottomSheet<Wilaya>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _WilayaPickerSheet(),
    );
    if (selected != null) {
      final store = context.read<AppStore>();
      final fee = store.shippingFee(selected.code, _deliveryType);
      setState(() {
        _wilayaCode = selected.code;
        _deliveryController.text = fee.toStringAsFixed(0);
      });
    }
  }

  void _applyDeliveryFee() {
    final code = _wilayaCode;
    if (code == null) return;
    final fee = context.read<AppStore>().shippingFee(code, _deliveryType);
    setState(() => _deliveryController.text = fee.toStringAsFixed(0));
  }

  Future<void> _pickCommune() async {
    final codeStr = _wilayaCode;
    if (codeStr == null) return;
    final code = int.tryParse(codeStr) ?? 0;
    if (code <= 0) return;
    final l10n = AppLocalizations.of(context);
    final communes = AlgeriaGeo.communesOf(code);
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _CommunePickerSheet(communes: communes, isArabic: l10n.isArabic),
    );
    if (selected != null) {
      setState(() => _communeController.text = selected);
    }
  }

  void _selectProduct() async {
    final l10n = AppLocalizations.of(context);
    final store = context.read<AppStore>();
    final products = store.products;
    if (products.isEmpty) {
      final create = await showAppConfirmDialog(
        context,
        title: l10n.productRequiredForOrder,
        body: l10n.productRequiredForOrder,
        confirmLabel: l10n.addProduct,
        icon: Icons.inventory_2_rounded,
      );
      if (create) {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => const ProductFormSheet(),
        );
        if (mounted) setState(() {});
      }
      return;
    }

    final selected = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ProductPickerSheet(selectedId: _productId),
    );
    if (selected != null) {
      setState(() {
        _productId = selected.id;
        if (_priceController.text.trim().isEmpty) {
          _priceController.text = selected.price.toStringAsFixed(0);
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final store = context.read<AppStore>();
    final product = _selectedProduct;
    if (product == null) {
      showAppSnackBar(
        context,
        l10n.selectProductError,
        icon: Icons.error_outline_rounded,
        iconColor: Theme.of(context).colorScheme.error,
      );
      return;
    }
    final wilaya = _selectedWilaya;
    if (wilaya == null) {
      showAppSnackBar(
        context,
        l10n.selectWilayaError,
        icon: Icons.error_outline_rounded,
        iconColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final unitPrice =
        double.tryParse(_priceController.text.replaceAll(',', '.').trim()) ??
        product.price;
    final delivery =
        double.tryParse(_deliveryController.text.replaceAll(',', '.').trim()) ??
        0;

    setState(() => _saving = true);
    AppHaptics.success();

    final order = Order(
      id: _existing?.id ?? store.newId(),
      reference: _existing?.reference ?? store.nextReference(),
      customerName: _customerController.text.trim(),
      phone: _phoneController.text.trim(),
      wilayaCode: wilaya.code,
      wilayaName: wilaya.fr,
      wilayaNameAr: wilaya.ar,
      commune: _communeController.text.trim(),
      address: _addressController.text.trim(),
      productId: product.id,
      productName: product.name,
      quantity: quantity,
      unitPrice: unitPrice,
      costPrice: product.cost,
      deliveryPrice: delivery,
      status: _status,
      createdAt: _existing?.createdAt ?? DateTime.now(),
      notes: _notesController.text.trim(),
      deliveryCompany: _deliveryCompany,
      deliveryType: _deliveryType,
      trackingNumber: _trackingController.text.trim(),
      codPaidByCompany: _codPaidByCompany,
    );

    if (_isEditing) {
      store.updateOrder(order);
    } else {
      store.addOrder(order);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    showAppSnackBar(
      context,
      _isEditing ? l10n.orderUpdated : l10n.orderSaved,
    );
    Navigator.of(context).pop();
  }

  double get _subtotal {
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    final price =
        double.tryParse(_priceController.text.replaceAll(',', '.').trim()) ?? 0;
    return quantity * price;
  }

  double get _delivery =>
      double.tryParse(_deliveryController.text.replaceAll(',', '.').trim()) ?? 0;

  double get _total => _subtotal + _delivery;

  double get _profit {
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    final price =
        double.tryParse(_priceController.text.replaceAll(',', '.').trim()) ?? 0;
    final product = _selectedProduct;
    final cost = product?.cost ?? 0;
    return (price - cost) * quantity;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final store = context.watch<AppStore>();
    final product = _selectedProduct;
    final wilaya = _selectedWilaya;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(
          _isEditing ? l10n.editOrderTitle : l10n.newOrderTitle,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              SheetHeader(
                title: _isEditing ? l10n.editOrderTitle : l10n.newOrderTitle,
                subtitle: l10n.orderSummary,
                icon: Icons.receipt_long_rounded,
              ),
              AppTextField(
                controller: _customerController,
                label: l10n.customerName,
                hint: l10n.customerNameHint,
                prefixIcon: Icons.person_rounded,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.required(value, l10n),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _phoneController,
                label: l10n.phone,
                hint: l10n.phoneHint,
                prefixIcon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                ],
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.phone(value, l10n),
                onChanged: _checkRisky,
              ),
              if (_riskyReturned > 0 || _riskyNoAnswer > 0) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.isArabic
                              ? 'عميل محفوف بالمخاطر: مرتجعات $_riskyReturned، بلا رد $_riskyNoAnswer'
                              : 'Client à risque : $_riskyReturned retour(s), $_riskyNoAnswer sans réponse',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              _PickerField(
                label: l10n.wilaya,
                value: wilaya?.name(l10n.isArabic),
                hint: l10n.wilayaHint,
                icon: Icons.location_city_rounded,
                errorText: _wilayaCode == null ? null : null,
                onTap: _selectWilaya,
              ),
              if (_wilayaCode == null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.md,
                    top: 6,
                  ),
                  child: Text(
                    '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _communeController,
                      label: l10n.commune,
                      hint: l10n.communeHint,
                      prefixIcon: Icons.map_rounded,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: IconButton.filledTonal(
                      tooltip: l10n.isArabic ? 'اختر البلدية' : 'Choisir commune',
                      onPressed: _wilayaCode == null ? null : _pickCommune,
                      icon: const Icon(Icons.list_alt_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _addressController,
                label: l10n.address,
                hint: l10n.addressHint,
                prefixIcon: Icons.home_rounded,
                maxLines: 2,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.required(value, l10n),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(title: l10n.product),
              const SizedBox(height: AppSpacing.xs),
              _PickerField(
                label: l10n.product,
                value: product?.name,
                hint: l10n.selectProductHint,
                icon: Icons.inventory_2_rounded,
                onTap: _selectProduct,
              ),
              if (product != null) ...[
                const SizedBox(height: AppSpacing.sm),
                SoftCard(
                  color: scheme.surfaceContainerHigh.withValues(alpha: 0.5),
                  border: false,
                  shadow: false,
                  padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${l10n.cost}: ${formatCurrency(context, product.cost)}  ·  '
                              '${l10n.stock}: ${formatNumber(context, product.stock)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (context) =>
                                ProductFormSheet(product: product),
                          ).then((_) => setState(() {}));
                        },
                        child: Text(l10n.edit),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AppTextField(
                      controller: _quantityController,
                      label: l10n.quantity,
                      prefixIcon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validators.quantity(value, l10n),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 3,
                    child: AppTextField(
                      controller: _priceController,
                      label: l10n.unitPrice,
                      prefixIcon: Icons.sell_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.,]'),
                        ),
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validators.amount(value, l10n),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(title: l10n.isArabic ? 'خيارات الشحن (fennecly)' : 'Options de livraison (fennecly)'),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<String>(
                initialValue: context.read<AppStore>().deliveryCompanies.contains(_deliveryCompany)
                    ? _deliveryCompany
                    : (context.read<AppStore>().deliveryCompanies.isNotEmpty
                        ? context.read<AppStore>().deliveryCompanies.first
                        : null),
                decoration: InputDecoration(
                  labelText: l10n.isArabic ? 'شركة التوصيل' : 'Société de livraison',
                  prefixIcon: const Icon(Icons.local_shipping_rounded, size: 22),
                ),
                items: context
                    .read<AppStore>()
                    .deliveryCompanies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _deliveryCompany = v ?? _deliveryCompany),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.isArabic ? 'نوع التوصيل' : 'Type de livraison',
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'home', label: Text(l10n.isArabic ? 'المنزل' : 'Domicile'), icon: const Icon(Icons.home_rounded)),
                  ButtonSegment(value: 'office', label: Text(l10n.isArabic ? 'المكتب' : 'Bureau'), icon: const Icon(Icons.store_rounded)),
                ],
                selected: {_deliveryType},
                onSelectionChanged: (s) {
                  setState(() => _deliveryType = s.first);
                  _applyDeliveryFee();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _deliveryController,
                      label: l10n.deliveryPrice,
                      prefixIcon: Icons.payments_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validators.amount(value, l10n),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: l10n.isArabic ? 'تعبئة السعر' : 'Auto-tarif',
                    onPressed: _applyDeliveryFee,
                    icon: const Icon(Icons.auto_fix_high_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _trackingController,
                label: l10n.isArabic ? 'رقم التتبع (اختياري)' : 'Numéro de suivi (optionnel)',
                prefixIcon: Icons.qr_code_2_rounded,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(title: l10n.status),
              const SizedBox(height: AppSpacing.xs),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: OrderStatus.values.map((status) {
                    final selected = _status == status;
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: AppSpacing.xs,
                      ),
                      child: FilterPill(
                        label: l10n.statusLabel(status),
                        selected: selected,
                        onTap: () => setState(() => _status = status),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _notesController,
                label: l10n.notes,
                hint: l10n.notesHint,
                prefixIcon: Icons.sticky_note_2_rounded,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.lg),
              SoftCard(
                color: scheme.surfaceContainerHigh.withValues(alpha: 0.55),
                border: false,
                shadow: false,
                child: Column(
                  children: [
                    _SummaryRow(
                      label: l10n.subtotal,
                      value: formatCurrency(context, _subtotal),
                    ),
                    _SummaryRow(
                      label: l10n.deliveryPrice,
                      value: formatCurrency(context, _delivery),
                    ),
                    Divider(color: scheme.outlineVariant),
                    _SummaryRow(
                      label: l10n.total,
                      value: formatCurrency(context, _total),
                      bold: true,
                    ),
                    _SummaryRow(
                      label: l10n.profit,
                      value: formatCurrency(context, _profit),
                      color: AppColors.mintDeep,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: scheme.onPrimary,
                        ),
                      )
                    : Text(l10n.saveOrder),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.value,
    this.errorText,
  });

  final String label;
  final String? value;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: AppSizes.iconMd),
          suffixIcon: const Icon(Icons.expand_more_rounded),
          errorText: errorText,
        ),
        child: Text(
          value ?? hint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: value == null
              ? texts.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                )
              : texts.bodyLarge,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final texts = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: texts.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: (bold ? texts.titleSmall : texts.bodyMedium)?.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: color ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _WilayaPickerSheet extends StatefulWidget {
  const _WilayaPickerSheet();

  @override
  State<_WilayaPickerSheet> createState() => _WilayaPickerSheetState();
}

class _WilayaPickerSheetState extends State<_WilayaPickerSheet> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final arabic = l10n.isArabic;
    final filtered = Wilaya.all.where((wilaya) {
      if (_query.isEmpty) return true;
      final haystack = '${wilaya.fr} ${wilaya.ar} ${wilaya.code}'.toLowerCase();
      return haystack.contains(_query.toLowerCase());
    }).toList();

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.82,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          children: [
            SheetHeader(
              title: l10n.wilaya,
              subtitle: l10n.searchWilaya,
              icon: Icons.location_city_rounded,
              trailing: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            AppTextField(
              controller: _search,
              label: l10n.search,
              hint: l10n.searchWilaya,
              prefixIcon: Icons.search_rounded,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => Divider(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final wilaya = filtered[index];
                  return ListTile(
                    contentPadding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        wilaya.code,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(wilaya.name(arabic)),
                    subtitle: Text(
                      arabic ? wilaya.fr : wilaya.ar,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      AppHaptics.select();
                      Navigator.of(context).pop(wilaya);
                    },
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

class _ProductPickerSheet extends StatefulWidget {
  const _ProductPickerSheet({this.selectedId});

  final String? selectedId;

  @override
  State<_ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<_ProductPickerSheet> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final store = context.watch<AppStore>();
    final filtered = store.products.where((product) {
      if (_query.isEmpty) return true;
      return product.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.78,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          children: [
            SheetHeader(
              title: l10n.selectProduct,
              subtitle: l10n.searchProduct,
              icon: Icons.inventory_2_rounded,
              trailing: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            AppTextField(
              controller: _search,
              label: l10n.search,
              hint: l10n.searchProduct,
              prefixIcon: Icons.search_rounded,
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      compact: true,
                      icon: Icons.inventory_2_rounded,
                      title: l10n.noProductsTitle,
                      body: l10n.noProductsBody,
                      actionLabel: l10n.addProduct,
                      onAction: () {
                        Navigator.of(context).pop();
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (context) => const ProductFormSheet(),
                        );
                      },
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.xs),
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        final selected = product.id == widget.selectedId;
                        return SoftCard(
                          onTap: () {
                            AppHaptics.select();
                            Navigator.of(context).pop(product);
                          },
                          color: selected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.45)
                              : null,
                          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.sm,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_rounded,
                                  color: AppColors.lightSurface,
                                  size: AppSizes.iconMd,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${l10n.price}: ${formatCurrency(context, product.price)}  ·  '
                                      '${l10n.stock}: ${formatNumber(context, product.stock)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (context) => const ProductFormSheet(),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.addProduct),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunePickerSheet extends StatefulWidget {
  const _CommunePickerSheet({required this.communes, required this.isArabic});
  final List<String> communes;
  final bool isArabic;

  @override
  State<_CommunePickerSheet> createState() => _CommunePickerSheetState();
}

class _CommunePickerSheetState extends State<_CommunePickerSheet> {
  String _q = '';
  final TextEditingController _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.communes.where((c) {
      if (_q.trim().isEmpty) return true;
      return c.toLowerCase().contains(_q.trim().toLowerCase());
    }).toList();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.75,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          children: [
            SheetHeader(
              title: widget.isArabic ? 'اختر البلدية' : 'Choisir une commune',
              subtitle: widget.isArabic ? 'بيانات fennecly / الجزائر' : 'Données fennecly / Algérie',
              icon: Icons.map_rounded,
              trailing: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            AppTextField(
              controller: _c,
              label: AppLocalizations.of(context).search,
              hint: widget.isArabic ? 'بحث...' : 'Rechercher...',
              prefixIcon: Icons.search_rounded,
              onChanged: (v) => setState(() => _q = v),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(filtered[i]),
                  onTap: () {
                    AppHaptics.select();
                    Navigator.pop(context, filtered[i]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
