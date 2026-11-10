import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/fennecly_supabase.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_text_field.dart';

/// Phase 1 auth: "forgot password" — sends a reset link via Supabase Auth.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await FenneclySupabase.client.auth.resetPasswordForEmail(
        _email.text.trim(),
        redirectTo: 'https://fennecly.online/reset-password',
      );
      if (!mounted) return;
      setState(() => _sent = true);
      AppHaptics.success();
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
                          Icon(Icons.lock_reset_rounded, size: 44, color: scheme.primary),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            ar ? 'استعادة كلمة المرور' : 'Réinitialiser le mot de passe',
                            textAlign: TextAlign.center,
                            style: texts.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ar
                                ? 'سنرسل لك رابطًا لتعيين كلمة المرور الجديدة'
                                : 'Nous vous enverrons un lien pour définir un nouveau mot de passe',
                            textAlign: TextAlign.center,
                            style: texts.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.lg),
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
                          if (_error != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(_error!, style: TextStyle(color: scheme.error, fontSize: 13)),
                          ],
                          if (_sent) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              ar ? 'تم إرسال الرابط — تحقق من بريدك' : 'Lien envoyé — vérifiez votre boîte mail',
                              style: TextStyle(color: scheme.primary, fontSize: 13),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            onPressed: _loading || _sent ? null : _sendReset,
                            child: _loading
                                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                                : Text(ar ? 'إرسال الرابط' : 'Envoyer le lien'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(ar ? 'رجوع' : 'Retour'),
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
