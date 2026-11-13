import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/fennecly_data_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_backdrop.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/soft_card.dart';

/// Credits top-up â€” mirrors the web /dashboard/credits page:
/// hero card with the live balance, 3 credit packs, 3 monthly plans,
/// payment via Chargily (CIB / EDAHABIA) or CCP screenshot proof.
class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

enum _Tab { packs, plans }

class _Pack {
  const _Pack({
    required this.id,
    required this.credits,
    required this.price,
    required this.label,
    required this.colors,
    this.badge,
  });

  final String id;
  final int credits;
  final int price;
  final String label;
  final List<Color> colors;
  final String? badge; // 'popular' | 'best'
}

class _Plan {
  const _Plan({
    required this.id,
    required this.credits,
    required this.price,
    required this.label,
    required this.colors,
    this.badge,
    this.unlimited = false,
  });

  final String id;
  final int credits;
  final int price;
  final String label;
  final List<Color> colors;
  final String? badge; // 'popular' | 'best'
  final bool unlimited;
}

const _packs = <_Pack>[
  _Pack(
    id: 'pack_50',
    credits: 50,
    price: 500,
    label: 'Starter',
    colors: [Color(0xFF38BDF8), Color(0xFF1D4ED8), Color(0xFF172554)],
  ),
  _Pack(
    id: 'pack_150',
    credits: 150,
    price: 1200,
    label: 'Standard',
    badge: 'popular',
    colors: [Color(0xFFA78BFA), Color(0xFF7C3AED), Color(0xFF3B0764)],
  ),
  _Pack(
    id: 'pack_500',
    credits: 500,
    price: 3500,
    label: 'Pro',
    badge: 'best',
    colors: [Color(0xFFFCD34D), Color(0xFFF97316), Color(0xFF7C2D12)],
  ),
];

const _plans = <_Plan>[
  _Plan(
    id: 'basic',
    credits: 100,
    price: 1500,
    label: 'Basic',
    colors: [Color(0xFF34D399), Color(0xFF059669), Color(0xFF052E16)],
  ),
  _Plan(
    id: 'pro',
    credits: 300,
    price: 3500,
    label: 'Pro',
    badge: 'popular',
    colors: [Color(0xFFA78BFA), Color(0xFF7C3AED), Color(0xFF3B0764)],
  ),
  _Plan(
    id: 'business',
    credits: 10000,
    price: 9000,
    label: 'Business',
    badge: 'best',
    unlimited: true,
    colors: [Color(0xFFFCD34D), Color(0xFFF59E0B), Color(0xFF78350F)],
  ),
];

class _CreditsScreenState extends State<CreditsScreen> {
  _Tab _tab = _Tab.packs;
  String _selected = 'pack_150';
  bool _chargilyMode = true;
  bool _submitting = false;
  String? _proofFileName;
  int? _proofBytesLength;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final store = context.read<AppStore>();
    final profile = await FenneclyDataService.fetchProfile();
    if (profile == null || !mounted) return;
    store.setFenneclyProfile(
      name: profile['name']?.toString(),
      email: profile['email']?.toString(),
      avatarUrl: profile['avatar_url']?.toString(),
      credits: profile['credits'] is num
          ? (profile['credits'] as num).toInt()
          : int.tryParse('${profile['credits']}') ?? 0,
      plan: profile['plan']?.toString(),
    );
  }

  Future<void> _payWithChargily() async {
    final ar = isArabicContext(context);
    setState(() => _submitting = true);
    final selectedPack = _packs.firstWhere((p) => p.id == _selected);
    final url = await FenneclyDataService.chargilyCheckoutUrl(
      amount: selectedPack.price,
      packId: selectedPack.id,
      orderId: 'CREDITS-${DateTime.now().millisecondsSinceEpoch}',
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (url == null) {
      showAppSnackBar(
        context,
        ar
            ? 'Ø¨ÙˆØ§Ø¨Ø© Ø§Ù„Ø¯ÙØ¹ ØºÙŠØ± Ù…ØªØ§Ø­Ø© â€” ØªØªØ·Ù„Ø¨ ØªÙ‡ÙŠØ¦Ø© Ù…Ù† ÙØ±ÙŠÙ‚ Fennecly'
            : 'Chargily checkout unavailable â€” the Edge Function needs to be configured on Fennecly side',
        icon: Icons.error_outline_rounded,
        iconColor: Theme.of(context).colorScheme.error,
      );
      return;
    }
    AppHaptics.success();
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _uploadProof() async {
    final ar = isArabicContext(context);
    AppHaptics.select();
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return;
    final file = files.first;
    Uint8List? bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {}
    if (bytes == null) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        ar ? 'Ø§Ù„Ù…Ù„Ù ØºÙŠØ± Ù‚Ø§Ø¨Ù„ Ù„Ù„ÙˆØµÙˆÙ„' : 'File not readable',
        icon: Icons.error_outline_rounded,
        iconColor: Theme.of(context).colorScheme.error,
      );
      return;
    }
    setState(() {
      _proofFileName = file.name;
      _proofBytesLength = bytes!.length;
    });
  }

  Future<void> _submitProof() async {
    if (_proofFileName == null) return;
    final ar = isArabicContext(context);
    final selectedPack = _tab == _Tab.packs
        ? _packs.firstWhere((p) => p.id == _selected)
        : null;
    final amount = selectedPack?.price ??
        _plans.firstWhere((p) => p.id == _selected).price;
    setState(() => _submitting = true);
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) {
      setState(() => _submitting = false);
      return;
    }
    final pick = files.first;
    Uint8List? bytes;
    try {
      bytes = await pick.readAsBytes();
    } catch (_) {}
    if (bytes == null) {
      setState(() => _submitting = false);
      return;
    }
    final ok = await FenneclyDataService.submitPaymentProof(
      bytes: bytes,
      filename: pick.name,
      packId: selectedPack?.id ?? _selected,
      amount: amount,
      mimeType: 'image/jpeg',
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    AppHaptics.select();
    showAppSnackBar(
      context,
      ok
          ? (ar
              ? 'ØªÙ… Ø±ÙØ¹ Ø§Ù„Ø¥Ø«Ø¨Ø§Øª â€” Ø³ØªØªÙ… Ø§Ù„Ù…Ø±Ø§Ø¬Ø¹Ø© Ø®Ù„Ø§Ù„ 24 Ø³Ø§Ø¹Ø©'
              : 'Proof sent â€” manual review within 24h')
          : (ar
              ? 'ÙØ´Ù„ Ø§Ù„Ø±ÙØ¹ â€” Ø­Ø§ÙˆÙ„ Ù…Ø±Ø© Ø£Ø®Ø±Ù‰'
              : 'Upload failed â€” try again'),
      icon: ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
      iconColor: ok ? null : Theme.of(context).colorScheme.error,
    );
    if (ok) {
      setState(() {
        _proofFileName = null;
        _proofBytesLength = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l10n = AppLocalizations.of(context);
    final ar = isArabicContext(context);
    final scheme = Theme.of(context).colorScheme;

    final selectedPack = _tab == _Tab.packs
        ? _packs.firstWhere((p) => p.id == _selected)
        : null;
    final selectedPlan = _tab == _Tab.plans
        ? _plans.firstWhere((p) => p.id == _selected)
        : null;
    final selectedPrice = selectedPack?.price ?? selectedPlan?.price ?? 0;
    final selectedCredits = selectedPack?.credits ?? selectedPlan?.credits ?? 0;
    final selectedIsUnlimited = selectedPlan?.unlimited ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(ar ? 'Ø§Ù„Ø±ÙŽÙ‘ØµÙŠØ¯' : 'Credits'),
      ),
      body: AppBackdrop(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: scheme.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              _HeroBalance(
                credits: store.fenneclyCredits,
                plan: store.fenneclyPlan,
                isUnlimited: store.isUnlimitedCredits,
                isArabic: ar,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                ar ? 'Ø§Ø®ØªØ± Ø¨Ø§Ù‚ØªÙƒ' : 'Choose an option',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _TabToggle(
                current: _tab,
                isArabic: ar,
                onChanged: (tab) {
                  setState(() {
                    _tab = tab;
                    _selected = tab == _Tab.packs ? 'pack_150' : 'pro';
                  });
                },
              ),
              const SizedBox(height: AppSpacing.md),
              if (_tab == _Tab.packs)
                _PackGrid(
                  isArabic: ar,
                  selected: _selected,
                  onSelected: (id) => setState(() => _selected = id),
                )
              else
                _PlanGrid(
                  isArabic: ar,
                  selected: _selected,
                  onSelected: (id) => setState(() => _selected = id),
                ),
              const SizedBox(height: AppSpacing.md),
              // ---- Payment section ----
              SoftCard(
                radius: 22,
                padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      ar ? 'Ø·Ø±ÙŠÙ‚Ø© Ø§Ù„Ø¯ÙØ¹' : 'Payment method',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _PaymentMethodButton(
                            label: 'CIB / EDAHABIA',
                            icon: Icons.credit_card_rounded,
                            selected: _chargilyMode,
                            onTap: () {
                              AppHaptics.select();
                              setState(() => _chargilyMode = true);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _PaymentMethodButton(
                            label: 'CCP / BaridiMob',
                            icon: Icons.smartphone_rounded,
                            selected: !_chargilyMode,
                            badge: ar ? 'ÙŠØ¯ÙˆÙŠ' : 'Manual',
                            onTap: () {
                              AppHaptics.select();
                              setState(() => _chargilyMode = false);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _AmountRow(
                            label: ar ? 'Ø§Ù„Ù…Ø¨Ù„Øº' : 'Amount due',
                            value: formatCurrency(context, selectedPrice),
                            accent: true,
                          ),
                        ),
                        Expanded(
                          child: _AmountRow(
                            label: ar ? 'Ø³ØªØ­ØµÙ„ Ø¹Ù„Ù‰' : 'You get',
                            value:
                                '${selectedIsUnlimited ? 'âˆž' : selectedCredits} ${ar ? 'Ø±ØµÙŠØ¯' : 'credits'}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (_chargilyMode) ...[
                      FilledButton.icon(
                        onPressed:
                            _submitting ? null : _payWithChargily,
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.bolt_rounded),
                        label: Text(
                          _submitting
                              ? (ar ? 'Ø¬Ø§Ø±ÙŠ ÙØªØ­ Ø§Ù„Ø¨ÙˆØ§Ø¨Ø©â€¦' : 'Opening checkoutâ€¦')
                              : (ar
                                  ? 'Ø§Ù„Ø¯ÙØ¹ Ø¹Ø¨Ø± Chargily Â· $selectedPrice DA'
                                  : 'Pay via Chargily Â· $selectedPrice DA'),
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: scheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_rounded,
                                color: AppColors.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: SelectableText(
                                '0012345678 91 â€” FENNACELY SARL',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontFamily: 'monospace',
                                      letterSpacing: 0.3,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      InkWell(
                        onTap: _submitting ? null : _uploadProof,
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                        child: Container(
                          padding: const EdgeInsetsDirectional
                              .all(AppSpacing.md),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _proofFileName != null
                                  ? scheme.primary
                                  : scheme.outlineVariant,
                              width: 1.4,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _proofFileName != null
                                    ? Icons.check_circle_rounded
                                    : Icons.cloud_upload_rounded,
                                color: _proofFileName != null
                                    ? AppColors.mintDeep
                                    : scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _proofFileName ??
                                          (ar
                                              ? 'Ø±ÙØ¹ Ø¥Ø«Ø¨Ø§Øª Ø§Ù„ØªØ­ÙˆÙŠÙ„'
                                              : 'Upload transfer screenshot'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                    if (_proofBytesLength != null)
                                      Text(
                                        '${(_proofBytesLength! / 1024).toStringAsFixed(0)} KB',
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      FilledButton.icon(
                        onPressed: _proofFileName == null ||
                                _submitting
                            ? null
                            : _submitProof,
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded),
                        label: Text(ar ? 'Ø¥Ø±Ø³Ø§Ù„ Ø§Ù„Ø¥Ø«Ø¨Ø§Øª' : 'Submit proof'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBalance extends StatelessWidget {
  const _HeroBalance({
    required this.credits,
    required this.plan,
    required this.isUnlimited,
    required this.isArabic,
  });

  final int credits;
  final String plan;
  final bool isUnlimited;
  final bool isArabic;

  String _planLabel() {
    switch (plan) {
      case 'basic':
        return 'Basic';
      case 'pro':
        return 'Pro';
      case 'business':
        return 'Business';
      default:
        return isArabic ? 'Ù…Ø¬Ø§Ù†ÙŠ' : 'Free';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      gradient: AppColors.revenueGradient,
      border: false,
      radius: 26,
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: AppSizes.iconSm,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                isArabic ? 'Ø±ØµÙŠØ¯Ùƒ Ø§Ù„Ø­Ø§Ù„ÙŠ' : 'YOUR BALANCE',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isUnlimited ? 'âˆž' : credits.toString(),
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 68,
                  height: 0.95,
                  letterSpacing: -1.5,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isUnlimited
                ? (isArabic
                    ? 'Ø¨Ø§Ù‚Ø© Business â€” Ø±ØµÙŠØ¯ Ø¨Ù„Ø§ Ø­Ø¯ÙˆØ¯'
                    : 'Business plan â€” infinite credits')
                : (isArabic
                    ? 'Ø±ØµÙŠØ¯ Ù„Ø£Ø¯ÙˆØ§Øª Ø§Ù„Ø°ÙƒØ§Ø¡ Ø§Ù„Ø§ØµØ·Ù†Ø§Ø¹ÙŠ Fennecly'
                    : 'Credits power Fennecly AI tools'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: AppColors.mint,
                size: AppSizes.iconSm,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${isArabic ? 'Ø¨Ø§Ù‚ØªÙƒ' : 'Plan'}: ${_planLabel()}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabToggle extends StatelessWidget {
  const _TabToggle({
    required this.current,
    required this.isArabic,
    required this.onChanged,
  });

  final _Tab current;
  final bool isArabic;
  final ValueChanged<_Tab> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(context, _Tab.packs,
                isArabic ? 'Ø§Ù„Ø­Ø²Ù…' : 'Packs'),
          ),
          Expanded(
            child: _tabButton(
                context, _Tab.plans, isArabic ? 'Ø§Ù„Ø§Ø´ØªØ±Ø§ÙƒØ§Øª' : 'Plans'),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(BuildContext context, _Tab tab, String label) {
    final scheme = Theme.of(context).colorScheme;
    final selected = current == tab;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: () {
        AppHaptics.select();
        onChanged(tab);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? scheme.surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _PackGrid extends StatelessWidget {
  const _PackGrid({
    required this.isArabic,
    required this.selected,
    required this.onSelected,
  });

  final bool isArabic;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 2),
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemCount: _packs.length,
        itemBuilder: (context, index) {
          final p = _packs[index];
          return SizedBox(
            width: 160,
            child: _ChoiceCard(
              id: p.id,
              label: p.label,
              credits: p.credits,
              price: p.price,
              colors: p.colors,
              badge: p.badge,
              selected: selected == p.id,
              onTap: () => onSelected(p.id),
            ),
          );
        },
      ),
    );
  }
}

class _PlanGrid extends StatelessWidget {
  const _PlanGrid({
    required this.isArabic,
    required this.selected,
    required this.onSelected,
  });

  final bool isArabic;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 2),
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemCount: _plans.length,
        itemBuilder: (context, index) {
          final p = _plans[index];
          return SizedBox(
            width: 160,
            child: _ChoiceCard(
              id: p.id,
              label: p.label,
              credits: p.credits,
              price: p.price,
              colors: p.colors,
              badge: p.badge,
              monthly: true,
              isUnlimited: p.unlimited,
              selected: selected == p.id,
              onTap: () => onSelected(p.id),
            ),
          );
        },
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.id,
    required this.label,
    required this.credits,
    required this.price,
    required this.colors,
    required this.selected,
    required this.onTap,
    this.badge,
    this.monthly = false,
    this.isUnlimited = false,
  });

  final String id;
  final String label;
  final int credits;
  final int price;
  final List<Color> colors;
  final String? badge;
  final bool monthly;
  final bool isUnlimited;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final texts = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
            width: selected ? 2.6 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.55),
              blurRadius: selected ? 26 : 12,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  id.startsWith('pack')
                      ? Icons.toll_rounded
                      : Icons.verified_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      badge == 'popular' ? 'POP.' : 'BEST',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: texts.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isUnlimited ? 'âˆž' : formatNumber(context, credits),
                  style: texts.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                Text(
                  isUnlimited
                      ? 'Unlimited credits / month'
                      : '$credits credits${monthly ? ' / month' : ''}',
                  style: texts.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              formatCurrency(context, price) + (monthly ? ' /mo' : ''),
              style: texts.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  const _PaymentMethodButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.10)
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
                size: 20),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          selected ? scheme.primary : scheme.onSurface,
                    ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow(
      {required this.label, required this.value, this.accent = false});

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: accent ? scheme.primary : scheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
