import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/app_store.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/fennecly_supabase.dart';
import '../../../core/services/fennecly_sync_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

import '../../../core/utils/haptics.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../domain/models/algeria_geo.dart';

class ShippingOptionsScreen extends StatefulWidget {
  const ShippingOptionsScreen({super.key});

  @override
  State<ShippingOptionsScreen> createState() => _ShippingOptionsScreenState();
}

class _ShippingOptionsScreenState extends State<ShippingOptionsScreen> {
  String _search = '';
  bool _syncing = false;

  Future<void> _syncFromFennecly() async {
    final ar = AppLocalizations.of(context).isArabic;
    if (!FenneclySupabase.isLoggedIn) {
      showAppSnackBar(context, ar ? 'سجّل الدخول بحساب Fennecly أولاً' : 'Connectez-vous avec Fennecly d’abord');
      return;
    }
    setState(() => _syncing = true);
    final store = context.read<AppStore>();
    final res = await FenneclySyncService.syncShipping(store);
    if (!mounted) return;
    setState(() => _syncing = false);
    if (res.error == null) {
      showAppSnackBar(context, ar
          ? 'تمت المزامنة: ${res.companies} شركات، ${res.tariffs} تعرفة'
          : 'Synchronisé : ${res.companies} sociétés, ${res.tariffs} tarifs');
    } else {
      showAppSnackBar(context, ar ? 'مزامنة جزئية' : 'Sync partielle', icon: Icons.info_outline_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l10n = AppLocalizations.of(context);
    final ar = l10n.isArabic;
    final scheme = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final wilayas = AlgeriaGeo.all.where((w) {
      if (_search.trim().isEmpty) return true;
      final q = _search.trim().toLowerCase();
      return w.nameFr.toLowerCase().contains(q) ||
          w.nameAr.contains(_search.trim()) ||
          w.codeStr.contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(ar ? 'خيارات الشحن' : 'Options de livraison'),
        actions: [
          IconButton(
            tooltip: ar ? 'مزامنة من Fennecly' : 'Sync Fennecly',
            onPressed: _syncing ? null : _syncFromFennecly,
            icon: _syncing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.cloud_sync_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
        children: [
          Text(
            ar
                ? 'شركات التوصيل وأسعار الولايات (مستوردة من fennecly)'
                : 'Sociétés de livraison et tarifs par wilaya (importés de fennecly)',
            style: texts.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionTitle(ar ? 'شركات التوصيل' : 'Sociétés de livraison'),
          const SizedBox(height: AppSpacing.xs),
          SoftCard(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    for (final c in store.deliveryCompanies)
                      InputChip(
                        label: Text(c),
                        selected: c == store.defaultDeliveryCompany,
                        onSelected: (_) {
                          AppHaptics.select();
                          store.setDefaultDeliveryCompany(c);
                        },
                        onDeleted: store.deliveryCompanies.length > 1
                            ? () => store.removeDeliveryCompany(c)
                            : null,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => _addCompany(context),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(ar ? 'إضافة شركة' : 'Ajouter une société'),
                  ),
                ),
                Text(
                  ar
                      ? 'اضغط لتعيين الشركة الافتراضية.'
                      : 'Touchez pour définir la société par défaut.',
                  style: texts.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(ar ? 'تطبيق سعر موحد' : 'Appliquer un tarif global'),
          const SizedBox(height: AppSpacing.xs),
          SoftCard(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ar
                        ? 'تعيين سعر المنزل/المكتب لكل الولايات (58)'
                        : 'Définir domicile/bureau pour les 58 wilayas',
                    style: texts.bodyMedium,
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () => _setAll(context),
                  child: Text(ar ? 'تعيين الكل' : 'Tout définir'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionTitle(ar ? 'أسعار التوصيل حسب الولاية' : 'Tarifs par wilaya'),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: ar ? 'بحث عن ولاية...' : 'Rechercher une wilaya...',
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...wilayas.map((w) => _WilayaPriceCard(
                code: w.codeStr,
                name: ar ? '${w.codeStr} - ${w.nameAr}' : '${w.codeStr} - ${w.nameFr}',
                home: store.shippingFee(w.codeStr, 'home'),
                office: store.shippingFee(w.codeStr, 'office'),
                onChanged: (home, office) =>
                    store.setShippingPrice(w.codeStr, home: home, office: office),
              )),
        ],
      ),
    );
  }

  Future<void> _addCompany(BuildContext context) async {
    final ar = AppLocalizations.of(context).isArabic;
    final c = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ar ? 'شركة توصيل' : 'Société de livraison'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: InputDecoration(
              hintText: ar ? 'اسم الشركة' : 'Nom de la société'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ar ? 'إلغاء' : 'Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: Text(ar ? 'إضافة' : 'Ajouter')),
        ],
      ),
    );
    if (name != null && name.trim().isNotEmpty && context.mounted) {
      context.read<AppStore>().addDeliveryCompany(name);
      showAppSnackBar(context, ar ? 'تمت الإضافة' : 'Ajouté');
    }
  }

  Future<void> _setAll(BuildContext context) async {
    final ar = AppLocalizations.of(context).isArabic;
    final homeC = TextEditingController(text: '600');
    final officeC = TextEditingController(text: '350');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ar ? 'تعيين الكل (58 ولاية)' : 'Tout définir (58 wilayas)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: homeC,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: ar ? 'المنزل (DA)' : 'Domicile (DA)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: officeC,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: ar ? 'المكتب (DA)' : 'Bureau (DA)'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ar ? 'إلغاء' : 'Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ar ? 'تطبيق' : 'Appliquer')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final home = double.tryParse(homeC.text.trim()) ?? 600;
      final office = double.tryParse(officeC.text.trim()) ?? 350;
      context.read<AppStore>().setAllShippingPrices(home: home, office: office);
      AppHaptics.success();
      showAppSnackBar(context, ar ? 'تم تطبيق الأسعار' : 'Tarifs appliqués');
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      );
}

class _WilayaPriceCard extends StatefulWidget {
  const _WilayaPriceCard({
    required this.code,
    required this.name,
    required this.home,
    required this.office,
    required this.onChanged,
  });
  final String code;
  final String name;
  final double home;
  final double office;
  final void Function(double home, double office) onChanged;

  @override
  State<_WilayaPriceCard> createState() => _WilayaPriceCardState();
}

class _WilayaPriceCardState extends State<_WilayaPriceCard> {
  late final TextEditingController _home;
  late final TextEditingController _office;

  @override
  void initState() {
    super.initState();
    _home = TextEditingController(text: widget.home.toStringAsFixed(0));
    _office = TextEditingController(text: widget.office.toStringAsFixed(0));
  }

  @override
  void didUpdateWidget(covariant _WilayaPriceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.home != widget.home && !_home.selection.isValid) {
      _home.text = widget.home.toStringAsFixed(0);
    }
    if (oldWidget.office != widget.office && !_office.selection.isValid) {
      _office.text = widget.office.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _home.dispose();
    _office.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      double.tryParse(_home.text.trim()) ?? widget.home,
      double.tryParse(_office.text.trim()) ?? widget.office,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ar = AppLocalizations.of(context).isArabic;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.xs),
      child: SoftCard(
        padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(widget.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _home,
                keyboardType: TextInputType.number,
                onChanged: (_) => _emit(),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: ar ? 'منزل' : 'Domicile',
                  suffixText: 'DA',
                  labelStyle: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: _office,
                keyboardType: TextInputType.number,
                onChanged: (_) => _emit(),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: ar ? 'مكتب' : 'Bureau',
                  suffixText: 'DA',
                  labelStyle: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
