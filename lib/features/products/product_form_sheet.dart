import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/product.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/soft_card.dart';
import '../../core/widgets/sheet_header.dart';

class ProductFormSheet extends StatefulWidget {
  const ProductFormSheet({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _costController;
  late final TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product == null
          ? ''
          : widget.product!.price.toStringAsFixed(0),
    );
    _costController = TextEditingController(
      text: widget.product == null
          ? ''
          : widget.product!.cost.toStringAsFixed(0),
    );
    _stockController = TextEditingController(
      text: (widget.product?.stock ?? 1).toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final store = context.read<AppStore>();
    final name = _nameController.text.trim();
    final price =
        double.tryParse(_priceController.text.replaceAll(',', '.').trim()) ?? 0;
    final cost =
        double.tryParse(_costController.text.replaceAll(',', '.').trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    if (widget.product == null) {
      store.addProduct(
        Product(
          id: store.newId(),
          name: name,
          price: price,
          cost: cost,
          stock: stock,
          createdAt: DateTime.now(),
        ),
      );
      store.createProductInFennecly(
        Product(
          id: store.newId(),
          name: name,
          price: price,
          cost: cost,
          stock: stock,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      store.updateProduct(
        widget.product!.copyWith(
          name: name,
          price: price,
          cost: cost,
          stock: stock,
        ),
      );
      store.updateProductInFennecly(
        widget.product!.copyWith(
          name: name,
          price: price,
          cost: cost,
          stock: stock,
        ),
      );
    }
    AppHaptics.success();
    if (!mounted) return;
    showAppSnackBar(
      context,
      widget.product == null ? l10n.productSaved : l10n.productUpdated,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.product != null;
    return Padding(
      padding: EdgeInsetsDirectional.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SheetHeader(
                title: isEditing ? l10n.editProduct : l10n.addProduct,
                subtitle: l10n.catalogueSubtitle,
                icon: Icons.inventory_2_rounded,
                trailing: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              AppTextField(
                controller: _nameController,
                label: l10n.productName,
                hint: l10n.productNameHint,
                prefixIcon: Icons.label_rounded,
                textInputAction: TextInputAction.next,
                validator: (value) => Validators.required(value, l10n),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _priceController,
                      label: l10n.productPrice,
                      prefixIcon: Icons.sell_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validators.amount(value, l10n),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppTextField(
                      controller: _costController,
                      label: l10n.productCost,
                      prefixIcon: Icons.shopping_bag_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (value) => Validators.amount(value, l10n),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _stockController,
                label: l10n.productStock,
                prefixIcon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                validator: (value) => Validators.quantity(value, l10n),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _save,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
