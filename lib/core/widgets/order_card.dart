import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/order.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';
import '../utils/haptics.dart';
import 'initials_avatar.dart';
import 'soft_card.dart';
import 'status_pill.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.onWhatsApp,
    this.showCheckbox = false,
    this.checked = false,
    this.onCheckboxChanged,
  });

  final Order order;
  final VoidCallback onTap;
  final VoidCallback? onWhatsApp;

  /// Bulk-select mode (Orders screen): shows a checkbox on every card.
  final bool showCheckbox;
  final bool checked;
  final ValueChanged<bool?>? onCheckboxChanged;

  bool get _canContact {
    return order.status == OrderStatus.newOrder ||
        order.status == OrderStatus.confirmed ||
        order.status == OrderStatus.noAnswer;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final arabic = l10n.isArabic;

    return SoftCard(
      onTap: showCheckbox ? null : onTap,
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showCheckbox) ...[
                SizedBox(
                  width: 24,
                  child: Checkbox(
                    value: checked,
                    onChanged: onCheckboxChanged,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              InitialsAvatar(name: order.customerName),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: texts.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_rounded,
                          size: AppSizes.iconXs,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            formatPhone(order.phone),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: texts.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              StatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  size: AppSizes.iconSm,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: texts.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${l10n.qtyShort} × ${formatNumber(context, order.quantity)}',
                      style: texts.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                formatCurrency(context, order.total),
                style: texts.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              vertical: AppSpacing.sm,
            ),
            child: Divider(color: scheme.outlineVariant, height: 1),
          ),
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: AppSizes.iconXs,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Flexible(
                child: Text(
                  order.wilayaNameFor(arabic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: texts.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.xs,
                ),
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_today_rounded,
                size: AppSizes.iconXs - 1,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                relativeDay(context, order.createdAt, l10n),
                style: texts.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              if (onWhatsApp != null && _canContact)
                Tooltip(
                  message: l10n.whatsappConfirm,
                  child: Material(
                    color: AppColors.mint.withValues(alpha: 0.12),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        AppHaptics.tap();
                        onWhatsApp!();
                      },
                      child: const SizedBox(
                        width: 34,
                        height: 34,
                        child: Icon(
                          Icons.chat_bubble_rounded,
                          size: AppSizes.iconSm,
                          color: AppColors.mintDeep,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
