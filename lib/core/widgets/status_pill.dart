import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../models/order.dart';
import '../theme/app_spacing.dart';
import '../theme/status_colors.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.status,
    this.showDot = true,
  });

  final OrderStatus status;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final fg = StatusColors.foreground(context, status);
    final bg = StatusColors.background(context, status);
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: AppSizes.dot,
              height: AppSizes.dot,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: AppSpacing.xxs + 2),
          ],
          Flexible(
            child: Text(
              l10n.statusLabel(status),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
