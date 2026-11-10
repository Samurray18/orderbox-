import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/product.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/skeletons.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/soft_card.dart';
import 'product_form_sheet.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, this.onViewOrders});

  final VoidCallback? onViewOrders;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 520), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _deleteProduct(Product product) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.deleteProduct,
      body: l10n.deleteProductBody,
      confirmLabel: l10n.delete,
      icon: Icons.inventory_2_rounded,
    );
    if (!confirmed || !mounted) return;
    context.read<AppStore>().deleteProduct(product.id);
    AppHaptics.warning();
    showAppSnackBar(context, l10n.productDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l10n = AppLocalizations.of(context);
    final products = store.products;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
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
                            Icons.inventory_2_rounded,
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
                                l10n.productsTitle.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.6,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${products.length}',
                                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            height: 0.9,
                                          ),
                                    ),
                                    TextSpan(
                                      text: ' ${l10n.productsTitle.toLowerCase()}',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () {
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
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SoftCard(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                      child: Row(
                        children: [
                          _ProductStat(
                            icon: Icons.inventory_2_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            label: l10n.productsTitle,
                            value: formatNumber(context, products.length),
                          ),
                          _StatDivider(),
                          _ProductStat(
                            icon: Icons.trending_up_rounded,
                            color: AppColors.mintDeep,
                            label: l10n.margin,
                            value: products.isEmpty
                                ? '0%'
                                : '${formatNumber(context, products.fold<double>(0, (sum, p) => sum + p.marginPercent) / products.length, decimals: 0)}%',
                          ),
                          _StatDivider(),
                          _ProductStat(
                            icon: Icons.warning_amber_rounded,
                            color: AppColors.amber,
                            label: l10n.lowStock,
                            value: formatNumber(
                              context,
                              products.where((p) => p.stock > 0 && p.stock < 5).length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_loading)
            SliverPadding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.lg,
              ),
              sliver: SliverToBoxAdapter(
                child: const ProductListSkeleton(),
              ),
            )
          else if (products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.inventory_2_rounded,
                title: l10n.noProductsTitle,
                body: l10n.noProductsBody,
                actionLabel: l10n.addProduct,
                onAction: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (context) => const ProductFormSheet(),
                  );
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
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(
                      bottom: AppSpacing.sm,
                    ),
                    child: _ProductCard(
                      product: product,
                      onEdit: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (context) => ProductFormSheet(
                            product: product,
                          ),
                        );
                      },
                      onDelete: () => _deleteProduct(product),
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

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final seed = colorSeedOf(product.name);
    final gradient = AppColors.avatarGradients[seed % AppColors.avatarGradients.length];

    return SoftCard(
      onTap: onEdit,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.lightSurface,
              size: AppSizes.iconXl,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: texts.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      formatCurrency(context, product.price),
                      style: texts.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${l10n.margin} ${formatPercent(context, product.marginPercent)}',
                      style: texts.bodySmall?.copyWith(
                        color: AppColors.mintDeep,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _StockPill(stock: product.stock),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_rounded, size: AppSizes.iconMd),
                    const SizedBox(width: AppSpacing.xs),
                    Text(l10n.edit),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: AppSizes.iconMd,
                      color: scheme.error,
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
    );
  }
}

class _ProductStat extends StatelessWidget {
  const _ProductStat({
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
    return Expanded(
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

class _StockPill extends StatelessWidget {
  const _StockPill({required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final Color color;
    final String label;
    if (stock <= 0) {
      color = scheme.error;
      label = l10n.outOfStock;
    } else if (stock < 5) {
      color = AppColors.amber;
      label = l10n.lowStock;
    } else {
      color = AppColors.mintDeep;
      label = l10n.inStock;
    }
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppSizes.dot,
            height: AppSizes.dot,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.xxs + 2),
          Text(
            '$label · $stock',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
