import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Global background used by the shell and full-screen routes:
/// a lavender gradient wash with soft, blurred purple blobs.
///
/// Drawn as a child of [Stack]/[Scaffold] so scroll views simply
/// render on top of it (use `Scaffold(backgroundColor: Colors.transparent)`).
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(
          child: BackdropGradient(),
        ),
        // Top-left blob
        PositionedDirectional(
          start: -118,
          top: -118,
          child: _Blob(
            size: 340,
            color: AppColors.blobPurple,
            dark: dark,
          ),
        ),
        // Top-right blob
        PositionedDirectional(
          end: -138,
          top: -84,
          child: _Blob(
            size: 300,
            color: AppColors.primary,
            dark: dark,
          ),
        ),
        // Lower-left blob
        PositionedDirectional(
          start: -152,
          bottom: 148,
          child: _Blob(
            size: 320,
            color: AppColors.blobPurple,
            dark: dark,
            strength: 0.42,
          ),
        ),
        // Mid-right mint blob
        PositionedDirectional(
          end: -96,
          top: 330,
          child: _Blob(
            size: 190,
            color: AppColors.blobMint,
            dark: dark,
            strength: 0.38,
          ),
        ),
        child,
      ],
    );
  }
}

/// The actual gradient wash (kept separate for repaint isolation).
class BackdropGradient extends StatelessWidget {
  const BackdropGradient({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: dark ? AppColors.backdropDark : AppColors.backdropLight,
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({
    required this.size,
    required this.color,
    required this.dark,
    this.strength = 0.55,
  });

  final double size;
  final Color color;
  final bool dark;
  final double strength;

  @override
  Widget build(BuildContext context) {
    final alpha = dark ? strength * 0.55 : strength;
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
