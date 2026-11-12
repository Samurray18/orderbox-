import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../utils/haptics.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.margin,
    this.onTap,
    this.gradient,
    this.color,
    this.radius = AppRadius.lg,
    this.border = true,
    this.shadow = true,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;
  final double radius;
  final bool border;
  final bool shadow;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final decoration = BoxDecoration(
      color: gradient == null
          ? (color ?? scheme.surfaceContainerLowest)
          : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: border && gradient == null
          ? Border.all(color: scheme.outlineVariant)
          : null,
      boxShadow: shadow ? AppShadows.card(context) : null,
    );

    final content = Padding(padding: padding, child: child);

    final bool useGlow = shadow && gradient != null;
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: DecoratedBox(
        decoration: decoration.copyWith(
          boxShadow: useGlow ? AppShadows.glow(context) : (shadow ? AppShadows.card(context) : null),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: clipBehavior,
          child: Material(
            type: MaterialType.transparency,
            child: onTap == null
                ? content
                : InkWell(
                    onTap: () {
                      AppHaptics.tap();
                      onTap!();
                    },
                    child: content,
                  ),
          ),
        ),
      ),
    );
  }
}

/// A card that is intentionally quiet: no border, no shadow, just a tinted
/// surface. Useful for summaries and grouped rows.
class TintCard extends StatelessWidget {
  const TintCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.card,
    this.color,
    this.radius = AppRadius.md,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? scheme.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

class GradientIconBadge extends StatelessWidget {
  const GradientIconBadge({
    super.key,
    required this.icon,
    this.size = 48,
    this.gradient = AppColors.primaryGradient,
    this.radius = AppRadius.md,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final double size;
  final Gradient gradient;
  final double radius;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: size * 0.46),
    );
  }
}
