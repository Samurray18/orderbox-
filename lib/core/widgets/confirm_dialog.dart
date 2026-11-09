import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../theme/app_spacing.dart';
import '../utils/haptics.dart';

Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = true,
  IconData icon = Icons.delete_outline_rounded,
}) async {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  final result = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (dialogContext) {
      final danger = destructive ? scheme.error : scheme.primary;
      return AlertDialog(
        icon: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: danger.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: danger, size: AppSizes.iconXl - 4),
        ),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(body, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  style: destructive
                      ? FilledButton.styleFrom(backgroundColor: scheme.error)
                      : null,
                  onPressed: () {
                    AppHaptics.warning();
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
  return result ?? false;
}
