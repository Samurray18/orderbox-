import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../../core/widgets/initials_avatar.dart';
import '../../core/widgets/soft_card.dart';
import '../../features/onboarding/onboarding_screen.dart';
import 'shipping/shipping_options_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _editStoreName() async {
    final store = context.read<AppStore>();
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: store.customStoreName);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.editStoreName),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.storeName,
              hintText: l10n.storeNameHint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    if (result == null) return;
    store.setStoreName(result);
    if (!mounted) return;
    showAppSnackBar(context, l10n.storeNameSaved);
  }

  Future<void> _restoreDemo() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.restoreDemo,
      body: l10n.restoreDemoBody,
      confirmLabel: l10n.confirm,
      destructive: false,
      icon: Icons.restart_alt_rounded,
    );
    if (!confirmed || !mounted) return;
    context.read<AppStore>().restoreDemoData();
    AppHaptics.success();
    showAppSnackBar(context, l10n.demoRestored);
  }

  Future<void> _clearData() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      title: l10n.clearData,
      body: l10n.clearDataBody,
      confirmLabel: l10n.delete,
      icon: Icons.delete_sweep_rounded,
    );
    if (!confirmed || !mounted) return;
    context.read<AppStore>().clearAllData();
    AppHaptics.warning();
    showAppSnackBar(context, l10n.dataCleared);
  }

  Future<void> _replayOnboarding() async {
    final store = context.read<AppStore>();
    store.resetOnboarding();
    if (!mounted) return;
    await Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 460),
        pageBuilder: (_, __, ___) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final storeName = store.storeNameOr(l10n.storeDefault);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsTitle,
                      style: texts.headlineLarge?.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.settingsSubtitle,
                      style: texts.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: SoftCard(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                child: Row(
                  children: [
                    InitialsAvatar(
                      name: storeName,
                      size: AppSizes.avatarLg,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            storeName,
                            style: texts.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.profileInitialsHint,
                            style: texts.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.editStoreName,
                      onPressed: _editStoreName,
                      icon: const Icon(Icons.edit_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Text(
                l10n.appearance,
                style: texts.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: SoftCard(
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appearance,
                      style: texts.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ThemeModeSelector(
                      value: store.themeMode,
                      onChanged: store.setThemeMode,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.language,
                      style: texts.labelLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.languageSubtitle,
                      style: texts.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _LanguageSelector(
                      locale: store.locale,
                      onChanged: store.setLocale,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Text(
                l10n.dataSection,
                style: texts.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.lg,
              ),
              child: SoftCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.local_shipping_rounded,
                      color: scheme.primary,
                      title: l10n.isArabic ? 'خيارات الشحن' : 'Options de livraison',
                      body: l10n.isArabic
                          ? 'شركات التوصيل وأسعار الولايات (منزل/مكتب) — من fennecly'
                          : 'Sociétés, tarifs wilaya (domicile/bureau) — import fennecly',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ShippingOptionsScreen(),
                        ),
                      ),
                    ),
                    Divider(color: scheme.outlineVariant, height: 1),
                    _SettingsTile(
                      icon: Icons.restart_alt_rounded,
                      color: scheme.primary,
                      title: l10n.restoreDemo,
                      body: l10n.restoreDemoBody,
                      onTap: _restoreDemo,
                    ),
                    Divider(color: scheme.outlineVariant, height: 1),
                    _SettingsTile(
                      icon: Icons.delete_sweep_rounded,
                      color: scheme.error,
                      title: l10n.clearData,
                      body: l10n.clearDataBody,
                      onTap: _clearData,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Text(
                l10n.about,
                style: texts.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.bottomNavClearance,
              ),
              child: SoftCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.info_outline_rounded,
                      title: l10n.version,
                      value: '1.0.0',
                    ),
                    Divider(color: scheme.outlineVariant, height: 1),
                    _InfoTile(
                      icon: Icons.favorite_rounded,
                      title: l10n.madeIn,
                      value: 'OrderBox DZ',
                    ),
                    Divider(color: scheme.outlineVariant, height: 1),
                    _SettingsTile(
                      icon: Icons.play_circle_outline_rounded,
                      color: scheme.primary,
                      title: l10n.replayOnboarding,
                      body: l10n.replayOnboardingSub,
                      onTap: _replayOnboarding,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final options = [
      (ThemeMode.system, Icons.brightness_auto_rounded, l10n.themeSystem),
      (ThemeMode.light, Icons.light_mode_rounded, l10n.themeLight),
      (ThemeMode.dark, Icons.dark_mode_rounded, l10n.themeDark),
    ];

    return Row(
      children: options.map((option) {
        final selected = option.$1 == value;
        return Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
            child: GestureDetector(
              onTap: () {
                AppHaptics.select();
                onChanged(option.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsetsDirectional.symmetric(
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.primaryGradient : null,
                  color: selected
                      ? null
                      : scheme.surfaceContainerHigh.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: selected
                      ? null
                      : Border.all(color: scheme.outlineVariant),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      option.$2,
                      size: AppSizes.iconMd,
                      color: selected
                          ? AppColors.lightSurface
                          : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      option.$3,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected
                            ? AppColors.lightSurface
                            : scheme.onSurfaceVariant,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.locale, required this.onChanged});

  final Locale locale;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final options = [
      (const Locale('ar'), 'العربية', l10n.arabic),
      (const Locale('fr'), 'Français', l10n.french),
    ];

    return Row(
      children: options.map((option) {
        final selected = option.$1.languageCode == locale.languageCode;
        return Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: AppSpacing.xs),
            child: GestureDetector(
              onTap: () {
                AppHaptics.select();
                onChanged(option.$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.primaryGradient : null,
                  color: selected
                      ? null
                      : scheme.surfaceContainerHigh.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: selected
                      ? null
                      : Border.all(color: scheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Text(
                      option.$2,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selected
                            ? AppColors.lightSurface
                            : scheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (selected)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.lightSurface,
                        size: AppSizes.iconMd,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: color, size: AppSizes.iconMd),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: texts.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: texts.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconMd, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: texts.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
