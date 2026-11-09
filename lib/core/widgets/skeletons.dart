import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});

  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHigh;
    final highlight = Color.lerp(base, scheme.onSurface, 0.055)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [base, highlight, base],
              stops: const [0.12, 0.5, 0.88],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: _SlidingGradient(_controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradient extends GradientTransform {
  const _SlidingGradient(this.value);

  final double value;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final dx = (value * 2 - 1) * bounds.width;
    return Matrix4.translationValues(dx, 0, 0);
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.radius = AppRadius.sm,
    this.shape = BoxShape.rectangle,
  });

  final double height;
  final double? width;
  final double radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        shape: shape,
        borderRadius:
            shape == BoxShape.circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonBox(
                height: AppSizes.avatar,
                width: AppSizes.avatar,
                shape: BoxShape.circle,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(height: 14, width: 128),
                    SizedBox(height: AppSpacing.xs),
                    SkeletonBox(height: 10, width: 86),
                  ],
                ),
              ),
              SkeletonBox(height: 22, width: 62, radius: AppRadius.pill),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: SkeletonBox(height: 12)),
              SizedBox(width: AppSpacing.lg),
              SkeletonBox(height: 18, width: 66),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              SkeletonBox(height: 10, width: 84),
              SizedBox(width: AppSpacing.sm),
              SkeletonBox(height: 10, width: 64),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderListSkeleton extends StatelessWidget {
  const OrderListSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: List.generate(
          count,
          (_) => const OrderCardSkeleton(),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: [
          const SkeletonBox(
            height: 164,
            radius: AppRadius.xl,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: const [
              Expanded(
                child: SkeletonBox(height: 122, radius: AppRadius.lg),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SkeletonBox(height: 122, radius: AppRadius.lg),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonBox(height: 240, radius: AppRadius.lg),
          const SizedBox(height: AppSpacing.lg),
          const SkeletonBox(height: 180, radius: AppRadius.lg),
        ],
      ),
    );
  }
}

class ProductListSkeleton extends StatelessWidget {
  const ProductListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: const Row(
              children: [
                SkeletonBox(
                  height: 56,
                  width: 56,
                  radius: AppRadius.md,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(height: 14, width: 140),
                      SizedBox(height: AppSpacing.xs),
                      SkeletonBox(height: 10, width: 80),
                    ],
                  ),
                ),
                SkeletonBox(height: 22, width: 72, radius: AppRadius.pill),
              ],
            ),
          );
        }),
      ),
    );
  }
}
