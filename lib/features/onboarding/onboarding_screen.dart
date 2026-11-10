import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/order.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/status_pill.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/auth/login_screen.dart';
import '../../features/shell/home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish({bool login = false}) {
    context.read<AppStore>().completeOnboarding();
    final Widget target;
    if (login) {
      target = const LoginScreen();
    } else {
      target = const HomeShell();
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 520),
        pageBuilder: (_, __, ___) => target,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _next() {
    if (_index == 2) {
      _finish();
      return;
    }
    _controller.animateToPage(
      _index + 1,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final pages = [
      _OnboardingPageData(
        title: l10n.onboarding1Title,
        body: l10n.onboarding1Body,
        illustration: const _OrdersIllustration(),
      ),
      _OnboardingPageData(
        title: l10n.onboarding2Title,
        body: l10n.onboarding2Body,
        illustration: const _WhatsAppIllustration(),
      ),
      _OnboardingPageData(
        title: l10n.onboarding3Title,
        body: l10n.onboarding3Body,
        illustration: const _ProfitIllustration(),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Column(
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        color: AppColors.lightSurface,
                        size: AppSizes.iconMd,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'OrderBox DZ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (_index < 2)
                      TextButton(
                        onPressed: _finish,
                        child: Text(l10n.onboardingSkip),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return PageView.builder(
                      controller: _controller,
                      onPageChanged: (value) {
                        setState(() => _index = value);
                      },
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        final page = pages[index];
                        return _OnboardingPage(
                          page: page,
                          compact: constraints.maxHeight < 620,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pages.length, (index) {
                  final selected = index == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsetsDirectional.symmetric(horizontal: 4),
                    width: selected ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? scheme.primary
                          : scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _index == 2
                            ? l10n.onboardingStart
                            : l10n.onboardingNext,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        _index == 2
                            ? Icons.arrow_forward_rounded
                            : Icons.chevron_right_rounded,
                        size: AppSizes.iconMd,
                      ),
                    ],
                  ),
                ),
              ),
              if (_index == 2) ...[
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  onPressed: () => _finish(login: true),
                  child: Text(
                    l10n.isArabic
                        ? 'تسجيل الدخول إلى Fennecly (اختياري)'
                        : 'Se connecter à Fennecly (optionnel)',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.body,
    required this.illustration,
  });

  final String title;
  final String body;
  final Widget illustration;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.page,
    required this.compact,
  });

  final _OnboardingPageData page;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height - 260,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: compact ? 16 : 32),
            SizedBox(
              height: compact ? 190 : 230,
              child: page.illustration
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.08, curve: Curves.easeOutCubic),
            ),
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
            Text(
              page.title,
              textAlign: TextAlign.center,
              style: texts.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: compact ? 20 : 22,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.sm,
              ),
              child: Text(
                page.body,
                textAlign: TextAlign.center,
                style: texts.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.6,
                  fontSize: compact ? 14 : 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersIllustration extends StatelessWidget {
  const _OrdersIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.10),
                AppColors.primary.withValues(alpha: 0.03),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .moveY(begin: -4, end: 4, duration: 2600.ms, curve: Curves.easeInOut),
        Positioned(
          top: 18,
          left: 26,
          child: _MiniOrderCard(
            width: 150,
            rotation: -0.06,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            leading: Icons.receipt_long_rounded,
          ),
        ),
        Positioned(
          top: 62,
          left: 42,
          child: _MiniOrderCard(
            width: 164,
            rotation: 0.04,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            leading: Icons.person_rounded,
            trailing: const StatusPill(status: OrderStatus.confirmed),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 30,
          child: _MiniOrderCard(
            width: 138,
            rotation: -0.02,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            leading: Icons.inventory_2_rounded,
          ),
        ),
        Positioned(
          bottom: 26,
          right: 12,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.mintGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.mint.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.lightSurface,
              size: AppSizes.iconLg,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniOrderCard extends StatelessWidget {
  const _MiniOrderCard({
    required this.width,
    required this.rotation,
    required this.color,
    required this.leading,
    this.trailing,
  });

  final double width;
  final double rotation;
  final Color color;
  final IconData leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: 44,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              leading,
              size: AppSizes.iconSm,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 7,
                    width: width * 0.42,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 5,
                    width: width * 0.28,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _WhatsAppIllustration extends StatelessWidget {
  const _WhatsAppIllustration();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            color: AppColors.mint.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 118,
          height: 118,
          decoration: BoxDecoration(
            gradient: AppColors.mintGradient,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            boxShadow: [
              BoxShadow(
                color: AppColors.mint.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: const Icon(
            Icons.chat_bubble_rounded,
            color: AppColors.lightSurface,
            size: 56,
          ),
        ),
        Positioned(
          top: 26,
          right: 18,
          child: _ChatBubble(
            color: scheme.surfaceContainerLowest,
            width: 104,
            lines: const [0.72, 0.48],
            trailingIcon: Icons.done_all_rounded,
            trailingColor: AppColors.mintDeep,
          ),
        ),
        Positioned(
          bottom: 24,
          left: 14,
          child: _ChatBubble(
            color: scheme.surfaceContainerLowest,
            width: 92,
            lines: const [0.62, 0.40],
            trailingIcon: Icons.done_all_rounded,
            trailingColor: AppColors.mintDeep,
          ),
        ),
      ],
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .moveY(begin: -5, end: 5, duration: 2800.ms, curve: Curves.easeInOut);
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.color,
    required this.width,
    required this.lines,
    required this.trailingIcon,
    required this.trailingColor,
  });

  final Color color;
  final double width;
  final List<double> lines;
  final IconData trailingIcon;
  final Color trailingColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsetsDirectional.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final factor in lines)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 4),
              child: Container(
                height: 6,
                width: width * factor,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Icon(
              trailingIcon,
              size: AppSizes.iconSm,
              color: trailingColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfitIllustration extends StatelessWidget {
  const _ProfitIllustration();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bars = [0.34, 0.62, 0.48, 0.88];
    final colors = [
      AppColors.primary,
      AppColors.mint,
      AppColors.amber,
      AppColors.primaryBright,
    ];

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 230,
          height: 170,
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(bars.length, (index) {
              return Container(
                width: 28,
                height: 130 * bars[index],
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors[index], colors[index].withValues(alpha: 0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.sm),
                  ),
                ),
              )
                  .animate(delay: (index * 120).ms)
                  .scaleY(
                    begin: 0.15,
                    end: 1,
                    alignment: Alignment.bottomCenter,
                    duration: 620.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: 320.ms);
            }),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: AppColors.mint.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.trending_up_rounded,
                  size: AppSizes.iconSm,
                  color: AppColors.mintDeep,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  '+12%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.mintDeep,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: -10,
          child: Row(
            children: List.generate(3, (index) {
              return Container(
                margin: const EdgeInsetsDirectional.only(end: 6),
                width: 26 - index * 3,
                height: 26 - index * 3,
                decoration: BoxDecoration(
                  color: index == 0 ? AppColors.amber : AppColors.mint,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.surfaceContainerLowest,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
