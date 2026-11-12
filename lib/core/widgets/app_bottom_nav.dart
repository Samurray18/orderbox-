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

/// Floating pill navigation bar.
///
/// V2: taller, softer radius, frosted surface, gradient pill for the
/// active tab (purple gradient + glow shadow) with a traveling
/// shimmer sweep.
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
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: AppSizes.navHeight + 10,
      padding: const EdgeInsetsDirectional.all(5),
      decoration: BoxDecoration(
        color: dark
            ? scheme.surfaceContainerLowest.withValues(alpha: 0.9)
            : scheme.surfaceContainerLowest.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: dark ? 0.25 : 0.18),
            blurRadius: 30,
            offset: const Offset(0, 10),
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

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );

  @override
  void initState() {
    super.initState();
    if (widget.selected) _shimmer.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected) {
      if (!_shimmer.isAnimating) _shimmer.repeat(reverse: true);
    } else if (_shimmer.isAnimating) {
      _shimmer.stop();
      _shimmer.reset();
    }
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  bool get _selected => widget.selected;
  NavDestination get destination => widget.destination;
  VoidCallback get onTap => widget.onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    const duration = Duration(milliseconds: 320);

    return Semantics(
      selected: _selected,
      button: true,
      label: destination.label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            margin: const EdgeInsetsDirectional.symmetric(horizontal: 2),
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: _selected ? 8 : 2,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              gradient: _selected ? AppColors.primaryGradient : null,
              boxShadow: _selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: dark ? 0.5 : 0.42,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
              borderRadius: BorderRadius.circular(22),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _selected ? destination.selectedIcon : destination.icon,
                        size: AppSizes.iconMd + (_selected ? 2 : 0),
                        color: _selected ? Colors.white : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: (texts.labelSmall ?? const TextStyle()).copyWith(
                          fontSize: 10,
                          height: 1.1,
                          fontWeight:
                              _selected ? FontWeight.w800 : FontWeight.w500,
                          color: _selected
                              ? Colors.white
                              : scheme.onSurfaceVariant,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  if (_selected)
                    AnimatedBuilder(
                      animation: _shimmer,
                      builder: (context, _) {
                        final v = _shimmer.value;
                        return Transform.translate(
                          offset: Offset(-90 + v * 180, 0),
                          child: IgnorePointer(
                            child: SizedBox(
                              width: 60,
                              height: 48,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0),
                                      Colors.white.withValues(alpha: 0.55),
                                      Colors.white.withValues(alpha: 0),
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
