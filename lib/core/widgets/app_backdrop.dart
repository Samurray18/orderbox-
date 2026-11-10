import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Global background used by the shell and full-screen routes.
///
/// V2: a deep, atmospheric gradient with three soft colour blooms
/// (primary lavender top-left, mint accent bottom-right and a warm pink
/// top-right), plus a faint radial vignette to ground the screen.
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(child: BackdropGradient()),
        PositionedDirectional(
          start: -150,
          top: -150,
          child: _Blob(
            size: 420,
            color: AppColors.primary,
            dark: dark,
            strength: dark ? 0.32 : 0.26,
          ),
        ),
        PositionedDirectional(
          end: -140,
          top: -90,
          child: _Blob(
            size: 330,
            color: const Color(0xFFFF8FAF),
            dark: dark,
            strength: dark ? 0.22 : 0.22,
          ),
        ),
        PositionedDirectional(
          start: -160,
          bottom: 120,
          child: _Blob(
            size: 380,
            color: AppColors.mint,
            dark: dark,
            strength: dark ? 0.16 : 0.14,
          ),
        ),
        PositionedDirectional(
          end: -120,
          top: 340,
          child: _Blob(
            size: 220,
            color: AppColors.blobPurple,
            dark: dark,
            strength: dark ? 0.22 : 0.22,
          ),
        ),
        const RepaintBoundary(child: _Vignette()),
        child,
      ],
    );
  }
}

/// The actual gradient wash (re-used standalone).
class BackdropGradient extends StatelessWidget {
  const BackdropGradient({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: dark ? AppColors.v2BackdropDark : AppColors.v2BackdropLight,
      ),
    );
  }
}

class _Vignette extends StatelessWidget {
  const _Vignette();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.7),
          radius: 1.15,
          colors: [
            Colors.transparent,
            (dark ? Colors.black : AppColors.primary).withValues(alpha: dark ? 0.30 : 0.05),
          ],
          stops: const [0.55, 1.0],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.size,
    required this.color,
    required this.dark,
    required this.strength,
  });

  final double size;
  final Color color;
  final bool dark;
  final double strength;

  @override
  Widget build(BuildContext context) {
    final alpha = dark ? strength * 0.85 : strength;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: alpha),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
