import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/fennecly_data_service.dart';
import '../../core/services/fennecly_supabase.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_snackbar.dart';
import '../auth/forgot_password_screen.dart';
import '../auth/signup_screen.dart';
import '../shell/home_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    if (!FenneclySupabase.isConfigured) {
      setState(() {
        _loading = false;
        _error = l10n.isArabic
            ? 'خدمة Fennecly غير متاحة في هذا الإصدار — انقر "متابعة بدون حساب".'
            : 'Service Fennecly indisponible dans cette version — utilisez « Continuer sans compte ».';
      });
      return;
    }
    try {
      await FenneclySupabase.client.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      // Pull the same account data shown on fennecly.online (store, products, orders, shipping)
      final store = context.read<AppStore>();
      final res = await FenneclyDataService.syncAll(store);
      if (!mounted) return;
      AppHaptics.success();
      final msg = l10n.isArabic
          ? 'تمت مزامنة Fennecly: ${res.orders} طلب، ${res.products} منتج، ${res.customers} عميل'
          : 'Fennecly synchronisé : ${res.orders} commandes, ${res.products} produits, ${res.customers} clients';
      showAppSnackBar(context, res.error == null ? msg : (l10n.isArabic ? '$msg (جزئي)' : '$msg (partiel)'));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (_) => false,
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      final message = e.toString();
      setState(() {
        _error = message.contains('Client has not been initialized') ||
                message.contains('Supabase')
            ? (AppLocalizations.of(context).isArabic
                ? 'خدمة Fennecly غير متاحة — معاينة بدون حساب فقط، أو أعد البناء بمفاتيح Supabase.'
                : 'Service Fennecly indisponible — utilisez « Continuer sans compte » ou rebuild avec les clés Supabase.')
            : message;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    if (!FenneclySupabase.isConfigured) {
      setState(() {
        _loading = false;
        _error = l10n.isArabic
            ? 'خدمة Fennecly غير متاحة في هذا الإصدار.'
            : 'Service Fennecly indisponible dans cette version.';
      });
      return;
    }
    try {
      // Phase 1: optional Google sign-in (Fennecly parity).
      await FenneclySupabase.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://fennecly.online/login',
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      final message = e.toString();
      setState(() {
        final ar = l10n.isArabic;
        _error = message.contains('Client has not been initialized') ||
                message.contains('Supabase')
            ? (ar
                ? 'خدمة Fennecly غير متاحة في هذا الإصدار.'
                : 'Service Fennecly indisponible dans cette version.')
            : message;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ar = l10n.isArabic;
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 0,
                  color: scheme.surface.withValues(alpha: 0.96),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(Icons.lock_rounded, size: 44, color: scheme.primary),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            ar ? 'تسجيل الدخول' : 'Connexion',
                            textAlign: TextAlign.center,
                            style: texts.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ar
                                ? 'نفس حساب fennecly.online — ستظهر نفس الطلبات والمنتجات والعملاء'
                                : 'Même compte que fennecly.online — mêmes commandes, produits et clients',
                            textAlign: TextAlign.center,
                            style: texts.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const SizedBox(height: AppSpacing.sm),
                          if (!FenneclySupabase.isConfigured)
                            Container(
                              padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: scheme.errorContainer.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(
                                  color: scheme.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: AppSizes.iconSm,
                                    color: scheme.onErrorContainer,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      ar
                                          ? 'خدمة Fennecly غير متاحة في هذا البناء (بدون مفتاح Supabase). استخدم « متابعة بدون حساب ».'
                                          : 'Service Fennecly indisponible dans cette version (clé manquante). Utilisez « Continuer sans compte ».',
                                      maxLines: 3,
                                      style: texts.bodySmall?.copyWith(
                                        color: scheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            autofillHints: const [AutofillHints.email],
                            decoration: InputDecoration(
                              labelText: ar ? 'البريد الإلكتروني' : 'Email',
                              prefixIcon: const Icon(Icons.email_rounded),
                            ),
                            validator: (v) => (v == null || !v.contains('@'))
                                ? (ar ? 'أدخل بريدًا صحيحًا' : 'Email invalide')
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              labelText: ar ? 'كلمة المرور' : 'Mot de passe',
                              prefixIcon: const Icon(Icons.password_rounded),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? (ar ? 'أدخل كلمة المرور' : 'Mot de passe requis')
                                : null,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(_error!, style: TextStyle(color: scheme.error, fontSize: 13)),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            onPressed: _loading ? null : _signIn,
                            child: _loading
                                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                                : Text(ar ? 'دخول' : 'Se connecter'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton(
                            onPressed: _loading
                                ? null
                                : () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (_) => const HomeShell()),
                                      (_) => false,
                                    );
                                  },
                            child: Text(ar ? 'متابعة بدون حساب' : 'Continuer sans compte'),
                          ),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                                    );
                                  },
                            child: Text(ar ? 'نسيت كلمة المرور؟' : 'Mot de passe oublié ?'),
                          ),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                                      (route) => false,
                                    );
                                  },
                            child: Text(ar ? 'إنشاء حساب جديد' : 'Créer un compte'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          OutlinedButton.icon(
                            onPressed: _loading ? null : _signInWithGoogle,
                            icon: const Icon(Icons.android_rounded),
                            label: Text(ar ? 'المتابعة عبر Google' : 'Continuer avec Google'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
