import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Rainbow LED-border chip mirroring the webapp's `.led-border` badge:
/// a thin conic sweep of hot colors rotating continuously around the pill.
/// Special "unlimited" rendering for the business plan (∞ row with infinity).
class CreditsLedChip extends StatefulWidget {
  const CreditsLedChip({
    super.key,
    required this.credits,
    required this.plan,
    this.onTap,
    this.isUnlimited = false,
  });

  final int credits;
  final String plan;
  final bool isUnlimited;
  final VoidCallback? onTap;

  @override
  State<CreditsLedChip> createState() => _CreditsLedChipState();
}

class _CreditsLedChipState extends State<CreditsLedChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final low = widget.credits < 5 && !widget.isUnlimited;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: widget.isUnlimited
          ? 'Credits: unlimited'
          : 'Credits: ${widget.credits}',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _rotation,
            builder: (context, _) {
              return CustomPaint(
                foregroundPainter: _LedBorderPainter(
                  rotation: _rotation.value * 2 * 3.141592653589793,
                  low: low,
                ),
                child: Container(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    5,
                    4,
                    AppSpacing.xs,
                    4,
                  ),
                  decoration: const BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isUnlimited
                            ? Icons.all_inclusive_rounded
                            : Icons.toll_rounded,
                        size: 16,
                        color: low
                            ? scheme.error
                            : (dark
                                ? AppColors.primaryDark
                                : AppColors.primary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.isUnlimited
                            ? '∞'
                            : widget.credits.toString(),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: low
                                  ? scheme.error
                                  : scheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Paints only the rotating conic-gradient stroke, so inside colors/hints
/// don't need to fight a masked layer.
class _LedBorderPainter extends CustomPainter {
  const _LedBorderPainter({required this.rotation, required this.low});

  final double rotation;
  final bool low;

  static const List<Color> _stops = [
    Color(0xFFFF0080),
    Color(0xFFFF8C00),
    Color(0xFFFFD500),
    Color(0xFF00FF88),
    Color(0xFF00D4FF),
    Color(0xFF8A2BE2),
    Color(0xFFFF0080),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(size.height / 2);
    final rrect = RRect.fromRectAndRadius(rect, radius);

    final shader = SweepGradient(
      startAngle: rotation,
      endAngle: rotation + 2 * 3.141592653589793,
      colors: low
          ? const [Colors.redAccent, Colors.redAccent, Colors.redAccent]
          : _stops,
    ).createShader(rect);

    final stroke = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final fill = Paint()
      ..color = const Color(0x00FFFFFF)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect, stroke);
  }

  @override
  bool shouldRepaint(covariant _LedBorderPainter oldDelegate) =>
      oldDelegate.rotation != rotation || oldDelegate.low != low;
}
