import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Friendly empty state with a hand-built illustration (no external images).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    this.actionIcon = Icons.add_rounded,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData actionIcon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: compact ? 138 : 176,
                width: compact ? 138 : 176,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: compact ? 126 : 160,
                      height: compact ? 126 : 160,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.06),
                        shape: BoxShape.circle,
                      ),
                    ),
                    PositionedDirectional(
                      top: compact ? 8 : 12,
                      end: compact ? 4 : 8,
                      child: Container(
                        width: compact ? 34 : 42,
                        height: compact ? 34 : 42,
                        decoration: BoxDecoration(
                          color: AppColors.mint.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: compact ? AppSizes.iconSm : AppSizes.iconMd,
                          color: AppColors.mintDeep,
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      bottom: compact ? 10 : 16,
                      start: compact ? 2 : 4,
                      child: Container(
                        width: compact ? 28 : 34,
                        height: compact ? 28 : 34,
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_rounded,
                          size: compact ? AppSizes.iconSm - 2 : AppSizes.iconSm,
                          color: AppColors.amber,
                        ),
                      ),
                    ),
                    Container(
                      width: compact ? 84 : 104,
                      height: compact ? 84 : 104,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(
                          compact ? AppRadius.xl : AppRadius.xxl,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: compact ? 38 : 48,
                        color: AppColors.lightSurface,
                      ),
                    ),
                    PositionedDirectional(
                      bottom: compact ? 16 : 24,
                      end: compact ? 12 : 18,
                      child: Container(
                        width: compact ? 30 : 36,
                        height: compact ? 30 : 36,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLowest,
                          shape: BoxShape.circle,
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: compact ? AppSizes.iconSm : AppSizes.iconMd,
                          color: AppColors.mint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: texts.headlineSmall?.copyWith(fontSize: 19),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                body,
                textAlign: TextAlign.center,
                style: texts.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.55,
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon, size: AppSizes.iconMd),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
