import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static List<BoxShadow> card(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: dark
            ? Colors.black.withValues(alpha: 0.32)
            : AppColors.primary.withValues(alpha: 0.06),
        blurRadius: dark ? 22 : 26,
        offset: const Offset(0, 10),
      ),
    ];
  }

  static List<BoxShadow> nav(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: dark
            ? Colors.black.withValues(alpha: 0.45)
            : AppColors.primary.withValues(alpha: 0.10),
        blurRadius: 30,
        offset: const Offset(0, 12),
      ),
    ];
  }

  static List<BoxShadow> brand(BuildContext context) {
    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.32),
        blurRadius: 26,
        offset: const Offset(0, 12),
      ),
    ];
  }
}
