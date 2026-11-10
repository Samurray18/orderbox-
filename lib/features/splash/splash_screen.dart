import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/fennecly_supabase.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/auth/login_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/shell/home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );
  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
  );
  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
  );
  late final Animation<double> _titleFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.38, 0.7, curve: Curves.easeOutCubic),
  );
  late final Animation<Offset> _titleSlide = Tween<Offset>(
    begin: const Offset(0, 0.35),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.38, 0.7, curve: Curves.easeOutCubic),
    ),
  );
  late final Animation<double> _taglineFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.58, 0.88, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _dotsFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
  );

  bool _navigated = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 2150), _goNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    final store = context.read<AppStore>();
    final Widget target;
    if (!store.onboardingDone) {
      target = const OnboardingScreen();
    } else if (!FenneclySupabase.isLoggedIn) {
      target = const LoginScreen();
    } else {
      target = const HomeShell();
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 620),
        pageBuilder: (_, __, ___) => target,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PositionedDirectional(
              top: -size.height * 0.18,
              end: -size.width * 0.15,
              child: _GlowCircle(
                size: size.width * 0.82,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            PositionedDirectional(
              bottom: -size.height * 0.12,
              start: -size.width * 0.20,
              child: _GlowCircle(
                size: size.width * 0.78,
                color: AppColors.mint.withValues(alpha: 0.14),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 5),
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          width: 154,
                          height: 154,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(AppRadius.xxl),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/logo_mark.png',
                            width: 126,
                            height: 126,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: RichText(
                          textDirection: TextDirection.ltr,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'OrderBox',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      color: AppColors.lightSurface,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.8,
                                    ),
                              ),
                              TextSpan(
                                text: ' DZ',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      color: AppColors.mintDark,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.8,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    FadeTransition(
                      opacity: _taglineFade,
                      child: Text(
                        l10n.tagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.lightSurface.withValues(alpha: 0.78),
                        ),
                      ),
                    ),
                    const Spacer(flex: 7),
                    FadeTransition(
                      opacity: _dotsFade,
                      child: _LoadingDots(animation: _controller),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final phase = index * 0.22;
            final value = (animation.value - phase).clamp(0.0, 1.0);
            final pulse = (value * 2).clamp(0.0, 1.0);
            final scale = 0.7 + 0.4 * (1 - (2 * pulse - 1).abs());
            final opacity = 0.45 + 0.55 * (1 - (2 * pulse - 1).abs());
            return Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.lightSurface,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
