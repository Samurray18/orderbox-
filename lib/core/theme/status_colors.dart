import 'package:flutter/material.dart';

import '../models/order.dart';
import 'app_colors.dart';

abstract final class StatusColors {
  static Color foreground(BuildContext context, OrderStatus status) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (status) {
      OrderStatus.newOrder => dark
          ? const Color(0xFF6AA9FF)
          : AppColors.blue,
      OrderStatus.confirmed => dark
          ? const Color(0xFFB39BFF)
          : AppColors.primary,
      OrderStatus.shipped => dark
          ? const Color(0xFFFFB673)
          : AppColors.orange,
      OrderStatus.delivered => dark
          ? const Color(0xFF47D98B)
          : AppColors.green,
      OrderStatus.returned => dark
          ? const Color(0xFFFF7B80)
          : AppColors.red,
      OrderStatus.cancelled => dark
          ? const Color(0xFFA7A0BA)
          : AppColors.grey,
      OrderStatus.noAnswer => dark
          ? const Color(0xFFFFC75C)
          : AppColors.amber,
    };
  }

  static Color background(BuildContext context, OrderStatus status) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return foreground(context, status).withValues(alpha: dark ? 0.16 : 0.11);
  }

  static LinearGradient gradient(BuildContext context, OrderStatus status) {
    final color = foreground(context, status);
    return LinearGradient(
      colors: [color, Color.lerp(color, Colors.black, 0.18)!],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
