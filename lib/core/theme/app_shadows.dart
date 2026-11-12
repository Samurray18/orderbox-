import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  /// Default soft purple-tinted shadow for elevated cards.
  static List<BoxShadow> card(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: dark
            ? Colors.black.withValues(alpha: 0.36)
            : AppColors.primary.withValues(alpha: 0.10),
        blurRadius: dark ? 24 : 30,
        offset: const Offset(0, 14),
      ),
    ];
  }

  /// Stronger glow reserved for gradient hero / KPI cards.
  static List<BoxShadow> glow(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: dark ? 0.45 : 0.34),
        blurRadius: 34,
        offset: const Offset(0, 16),
      ),
      if (dark)
        BoxShadow(
          color: const Color(0xFF7A4DFF).withValues(alpha: 0.35),
          blurRadius: 18,
          offset: const Offset(0, 4),
        ),
    ];
  }

  static List<BoxShadow> nav(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: dark
            ? Colors.black.withValues(alpha: 0.45)
            : AppColors.primary.withValues(alpha: 0.14),
        blurRadius: 34,
        offset: const Offset(0, 14),
      ),
    ];
  }

  static List<BoxShadow> brand(BuildContext context) {
    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.38),
        blurRadius: 30,
        offset: const Offset(0, 14),
      ),
    ];
  }
}