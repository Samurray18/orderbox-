import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/haptics.dart';

/// Circular FAB that expands into a labelled pill, then runs [onPressed].
class ExpandingFab extends StatefulWidget {
  const ExpandingFab({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final Future<void> Function() onPressed;

  @override
  State<ExpandingFab> createState() => _ExpandingFabState();
}

class _ExpandingFabState extends State<ExpandingFab> {
  bool _expanded = false;
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy) return;
    AppHaptics.tap();
    if (!_expanded) {
      setState(() => _expanded = true);
      await Future<void>.delayed(const Duration(milliseconds: 260));
    }
    if (!mounted) return;
    setState(() => _busy = true);
    await widget.onPressed();
    if (!mounted) return;
    setState(() {
      _expanded = false;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: widget.label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        width: _expanded ? 184 : AppSizes.fab,
        height: AppSizes.fab,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.38),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: _handleTap,
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 17,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: AppSizes.iconLg + 2,
                      color: AppColors.lightSurface,
                    ),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _expanded ? 1 : 0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: AppSpacing.xs,
                          ),
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: AppColors.lightSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
