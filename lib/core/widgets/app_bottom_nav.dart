import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/haptics.dart';

class NavDestination {
  const NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    required this.destinations,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final List<NavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: AppSizes.navHeight + AppSpacing.sm,
      padding: const EdgeInsetsDirectional.all(AppSpacing.xxs + 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.10),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var index = 0; index < destinations.length; index++)
            Expanded(
              child: _NavItem(
                destination: destinations[index],
                selected: index == currentIndex,
                onTap: () {
                  if (index == currentIndex) return;
                  AppHaptics.select();
                  onSelected(index);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final texts = Theme.of(context).textTheme;
    const duration = Duration(milliseconds: 280);

    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: onTap,
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            margin: const EdgeInsetsDirectional.symmetric(horizontal: 3),
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: selected ? 10 : 2,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? (dark ? AppColors.lavenderPillDark : AppColors.lavenderPill)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1, end: selected ? 1.08 : 1),
                  duration: duration,
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    size: AppSizes.iconMd + 2,
                    color: selected
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: duration,
                  style:
                      (texts.labelSmall ?? const TextStyle()).copyWith(
                        fontSize: 10,
                        color: selected
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        height: 1.15,
                      ),
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
