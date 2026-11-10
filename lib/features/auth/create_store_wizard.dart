import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/fennecly_supabase.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/soft_card.dart';

const List<String> _kCategories = <String>[
  'fashion',
  'electronics',
  'beauty',
  'home',
  'food',
  'sports',
  'books',
  'toys',
  'general',
];

/// Phase 1: "create store" flow for brand-new Fennecly accounts.
/// Mirrors the web app wizard (store name → category → logo/description → review).
class CreateStoreWizard extends StatefulWidget {
  const CreateStoreWizard({super.key});

  @override
  State<CreateStoreWizard> createState() => _CreateStoreWizardState();
}

class _CreateStoreWizardState extends State<CreateStoreWizard> {
  int _step = 1;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'general';
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final ownerId = FenneclySupabase.client.auth.currentUser?.id ?? '';
    setState(() => _submitting = true);
    try {
      final res = await FenneclySupabase.client
          .from('stores')
          .insert(<String, dynamic>{
            'owner_id': ownerId,
            'name': name,
            'slug': 'store-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}',
            'category': _category,
            'currency': 'DZD',
            'description': _descriptionController.text.trim(),
            'is_default': false,
          })
          .select('id')
          .single();
      final storeId = (res['id'] ?? '').toString();
      if (!mounted) return;
      context.read<AppStore>().setFenneclyStore(name: name, id: storeId);
      AppHaptics.success();
      showAppSnackBar(context, 'Store created!');
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      AppHaptics.warning();
      showAppSnackBar(context, 'Failed to create store');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final ar = l10n.isArabic;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(ar ? 'إنشاء متجر' : 'Créer un magasin'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  for (var i = 1; i <= 3; i++)
                    Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i <= _step ? scheme.primary : scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_step == 1) ...[
                        Text(
                          ar ? 'اسم المتجر' : 'Nom du magasin',
                          style: texts.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppTextField(
                          controller: _nameController,
                          label: ar ? 'الاسم' : 'Nom',
                          prefixIcon: Icons.store_rounded,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          ar ? 'الفئة' : 'Catégorie',
                          style: texts.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: _kCategories.map((c) {
                            final selected = _category == c;
                            return ChoiceChip(
                              label: Text(c),
                              selected: selected,
                              onSelected: (_) => setState(() => _category = c),
                            );
                          }).toList(),
                        ),
                      ],
                      if (_step == 2) ...[
                        Text(
                          ar ? 'وصف المتجر' : 'Description',
                          style: texts.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppTextField(
                          controller: _descriptionController,
                          label: ar ? 'الوصف' : 'Description',
                          prefixIcon: Icons.description_rounded,
                          maxLines: 4,
                        ),
                      ],
                      if (_step == 3) ...[
                        Text(
                          ar ? 'مراجعة' : 'Récapitulatif',
                          style: texts.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SoftCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nameController.text.trim().isEmpty
                                    ? ''
                                    : _nameController.text.trim(),
                                style: texts.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _category,
                                style: texts.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                              if (_descriptionController.text.trim().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(_descriptionController.text.trim()),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          ar
                              ? 'يمكنك تغيير هذه التفاصيل لاحقًا من إعدادات المتجر.'
                              : 'Vous pourrez modifier ces détails plus tard dans les réglages du magasin.',
                          style: texts.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  if (_step > 1)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        child: Text(ar ? 'رجوع' : 'Retour'),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submitting
                          ? null
                          : () {
                              if (_step < 3) {
                                setState(() => _step++);
                              } else {
                                _create();
                              }
                            },
                      child: _submitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4),
                            )
                          : Text(_step < 3
                              ? (ar ? 'التالي' : 'Suivant')
                              : (ar ? 'إنشاء' : 'Créer')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
