import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle_rounded,
  Color? iconColor,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? AppColors.mintDark,
              size: AppSizes.iconMd,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
