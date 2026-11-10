import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/services/fennecly_data_service.dart';
import '../../core/services/fennecly_supabase.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_backdrop.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/soft_card.dart';
import '../../features/auth/login_screen.dart';

/// Store settings parity with the web dashboard.store-settings page
/// (backend: stores + store_settings tables).
class StoreSettingsScreen extends StatefulWidget {
  const StoreSettingsScreen({super.key});

  @override
  State<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends State<StoreSettingsScreen> {
  static const _categories = <String>[
    'general',
    'fashion',
    'beauty',
    'electronics',
    'food',
    'home',
    'services',
    'other',
  ];
  static const _currencies = <String>['DZD', 'USD', 'EUR'];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pixelController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String _category = 'general';
  String _currency = 'DZD';
  bool _chargilyEnabled = false;
  bool _chargilyKnown = false;
  String _storeId = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pixelController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!FenneclySupabase.isLoggedIn) {
      setState(() => _loading = false);
      return;
    }
    final storeInfo = await FenneclyDataService.resolveCurrentStore();
    if (!mounted) return;
    final settings = storeInfo == null
        ? null
        : await FenneclyDataService.getStoreSettings(storeInfo.id);
    final chargily = await FenneclyDataService.getChargilyEnabled();
    if (!mounted) return;
    setState(() {
      _storeId = storeInfo?.id ?? '';
      if (settings != null) {
        _nameController.text = (settings['name'] ?? '').toString();
        _descriptionController.text = (settings['description'] ?? '').toString();
        _pixelController.text = (settings['tiktok_pixel_id'] ?? '').toString();
        final category = (settings['category'] ?? 'general').toString();
        _category = _categories.contains(category) ? category : 'general';
        final currency = (settings['currency'] ?? 'DZD').toString();
        _currency = _currencies.contains(currency) ? currency : 'DZD';
      } else {
        _nameController.text = storeInfo?.name ?? '';
      }
      _chargilyEnabled = chargily ?? false;
      _chargilyKnown = chargily != null;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final store = context.read<AppStore>();
    final ar = isArabicContext(context);
    setState(() => _saving = true);
    AppHaptics.select();
    final name = _nameController.text.trim();
    final ok = await FenneclyDataService.updateStoreSettings(
      storeId: _storeId,
      name: name.isEmpty ? null : name,
      category: _category,
      description: _descriptionController.text.trim(),
      currency: _currency,
      tiktokPixelId: _pixelController.text.trim(),
    );
    var chargilyOk = true;
    if (_chargilyKnown) {
      chargilyOk = await FenneclyDataService.updateChargilyEnabled(_chargilyEnabled);
    }
    if (name.isNotEmpty) {
      store.setStoreName(name);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    AppHaptics.select();
    showAppSnackBar(
      context,
      (ok && chargilyOk)
          ? (ar ? 'تم الحفظ ✓' : 'Enregistré ✓')
          : (ar ? 'بعض الحقول لم تُحفظ' : 'Certains champs n’ont pas été enregistrés'),
      icon: (ok && chargilyOk)
          ? Icons.check_circle_rounded
          : Icons.error_outline_rounded,
      iconColor: (ok && chargilyOk) ? null : Theme.of(context).colorScheme.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ar = isArabicContext(context);
    final scheme = Theme.of(context).colorScheme;
    final loggedIn = FenneclySupabase.isLoggedIn;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(ar ? 'إعدادات المتجر' : 'Store settings'),
      ),
      body: AppBackdrop(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : !loggedIn
                ? _SignedOutState(onSignIn: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    ))
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.lg + 32,
                    ),
                    children: [
                      SoftCard(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  ar ? 'معلومات المتجر' : 'Informations boutique',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: ar ? 'اسم المتجر' : 'Nom de la boutique',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            DropdownButtonFormField<String>(
                              initialValue: _category,
                              decoration: InputDecoration(
                                labelText: ar ? 'الفئة' : 'Catégorie',
                              ),
                              items: [
                                for (final category in _categories)
                                  DropdownMenuItem(
                                    value: category,
                                    child: Text(_categoryLabel(category, ar)),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                AppHaptics.select();
                                setState(() => _category = value);
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: ar ? 'الوصف' : 'Description',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            DropdownButtonFormField<String>(
                              initialValue: _currency,
                              decoration: InputDecoration(
                                labelText: ar ? 'العملة' : 'Devise',
                              ),
                              items: [
                                for (final currency in _currencies)
                                  DropdownMenuItem(
                                    value: currency,
                                    child: Text(currency),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _currency = value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SoftCard(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.music_note_rounded,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'TikTok Pixel',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextField(
                              controller: _pixelController,
                              decoration: const InputDecoration(
                                labelText: 'Pixel ID',
                                hintText: 'C3ABC1234567890',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SoftCard(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.credit_card_rounded,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ar ? 'الدفع عبر Chargily' : 'Paiements Chargily',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    ar
                                        ? 'CIB / Edahabia عبر Chargily Pay'
                                        : 'CIB / Edahabia via Chargily Pay',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _chargilyEnabled,
                              onChanged: (value) {
                                AppHaptics.select();
                                setState(() => _chargilyEnabled = value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(ar ? 'حفظ' : 'Enregistrer'),
                      ),
                    ],
                  ),
      ),
    );
  }

  String _categoryLabel(String category, bool ar) {
    switch (category) {
      case 'fashion':
        return ar ? 'أزياء' : 'Mode';
      case 'beauty':
        return ar ? 'تجميل' : 'Beauté';
      case 'electronics':
        return ar ? 'إلكترونيات' : 'Électronique';
      case 'food':
        return ar ? 'غذاء' : 'Alimentaire';
      case 'home':
        return ar ? 'منزل' : 'Maison';
      case 'services':
        return ar ? 'خدمات' : 'Services';
      case 'other':
        return ar ? 'أخرى' : 'Autre';
      default:
        return ar ? 'عام' : 'Général';
    }
  }
}

class _SignedOutState extends StatelessWidget {
  const _SignedOutState({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ar = isArabicContext(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_outlined,
              size: 56,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              ar
                  ? 'اربط حسابك أولاً لتعديل متجرك'
                  : 'Connectez-vous pour modifier votre boutique',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onSignIn,
              child: Text(ar ? 'تسجيل الدخول' : 'Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
