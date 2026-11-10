import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/fennecly_supabase.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../features/shell/home_shell.dart';
import 'create_store_wizard.dart';
import 'forgot_password_screen.dart';
import 'login_screen.dart';

/// Phase 1 auth: mirrors the Fennecly /signup page (name, email, password,
/// optional phone, wilaya + city) and creates the shared Supabase auth user.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _wilaya = TextEditingController();
  final _city = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _wilaya.dispose();
    _city.dispose();
    super.dispose();
  }

  int _passwordScore(String pw) {
    var score = 0;
    if (pw.length >= 8) score++;
    if (pw.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(pw)) score++;
    if (RegExp(r'[0-9]').hasMatch(pw)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(pw)) score++;
    if (score <= 1) return 0;
    if (score <= 3) return 1;
    return 2;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      final res = await FenneclySupabase.client.auth.signUp(
        email: _email.text.trim(),
        password: _password.text,
        data: <String, dynamic>{
          'name': _name.text.trim(),
          'phone': _phone.text.trim(),
          'wilaya': _wilaya.text.trim(),
          'city': _city.text.trim(),
        },
      );
      if (!mounted) return;
      AppHaptics.success();
      if (res.session != null) {
        // Signed up and session created → go create the store (web parity).
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const CreateStoreWizard()),
          (route) => false,
        );
        return;
      }
      // Email confirmation required.
      showAppSnackBar(
        context,
        l10n.isArabic
            ? 'تم إنشاء الحساب — تحقق من بريدك الإلكتروني'
            : 'Compte créé — vérifiez votre email',
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
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
                          Icon(Icons.store_rounded, size: 44, color: scheme.primary),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            ar ? 'إنشاء متجرك' : 'Créez votre boutique',
                            textAlign: TextAlign.center,
                            style: texts.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ar
                                ? 'سجّل حسابك وابدأ البيع في دقائق'
                                : 'Inscrivez-vous et lancez votre boutique en quelques minutes',
                            textAlign: TextAlign.center,
                            style: texts.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _name,
                            label: ar ? 'الاسم' : 'Nom',
                            hint: ar ? 'مثال: متجر أحمد' : 'Ex. Boutique Ahmed',
                            prefixIcon: Icons.person_rounded,
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? (ar ? 'الاسم مطلوب' : 'Nom requis')
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(
                            controller: _email,
                            label: ar ? 'البريد الإلكتروني' : 'Email',
                            prefixIcon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textDirection: TextDirection.ltr,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || !v.contains('@'))
                                ? (ar ? 'أدخل بريدًا صحيحًا' : 'Email invalide')
                                : null,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(
                            controller: _password,
                            label: ar ? 'كلمة المرور' : 'Mot de passe',
                            prefixIcon: Icons.password_rounded,
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.length < 8)
                                ? (ar ? 'كلمة المرور (8+) مطلوبة' : 'Mot de passe (8+) requis')
                                : null,
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                            ),
                          ),
                          if (_password.text.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                ar ? 'قوة كلمة المرور' : 'Force du mot de passe',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: (_passwordScore(_password.text) / 2).clamp(0.0, 1.0),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(
                            controller: _phone,
                            label: ar ? 'الهاتف (اختياري)' : 'Téléphone (optionnel)',
                            prefixIcon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                            textDirection: TextDirection.ltr,
                            autofillHints: const [AutofillHints.telephoneNumber],
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(
                            controller: _wilaya,
                            label: ar ? 'الولاية' : 'Wilaya',
                            prefixIcon: Icons.location_city_rounded,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(
                            controller: _city,
                            label: ar ? 'البلدية' : 'Commune',
                            prefixIcon: Icons.map_rounded,
                            textInputAction: TextInputAction.next,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(_error!, style: TextStyle(color: scheme.error, fontSize: 13)),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            onPressed: _loading ? null : _signUp,
                            child: _loading
                                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                                : Text(ar ? 'إنشاء الحساب' : 'Créer le compte'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            child: Text(ar ? 'لديك حساب بالفعل؟ دخول' : 'Déjà un compte ? Connexion'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                              );
                            },
                            child: Text(ar ? 'نسيت كلمة المرور؟' : 'Mot de passe oublié ?'),
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
