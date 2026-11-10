import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/soft_card.dart';

/// Profit & operating expenses — parity with the web dashboard money page.
/// Expense categories: ads | packaging | salary | rent | software | other.
class ProfitScreen extends StatefulWidget {
  const ProfitScreen({super.key});

  @override
  State<ProfitScreen> createState() => _ProfitScreenState();
}

class _ProfitScreenState extends State<ProfitScreen> {
  DashboardPeriod _period = DashboardPeriod.days30;

  static const _categories = <String>['ads', 'packaging', 'salary', 'rent', 'software', 'other'];

  String _categoryLabel(String category, bool ar) {
    switch (category) {
      case 'ads':
        return ar ? 'إعلانات' : 'Publicité';
      case 'packaging':
        return ar ? 'تغليف' : 'Emballage';
      case 'salary':
        return ar ? 'رواتب' : 'Salaires';
      case 'rent':
        return ar ? 'إيجار' : 'Loyer';
      case 'software':
        return ar ? 'برامج' : 'Logiciels';
      default:
        return ar ? 'أخرى' : 'Autre';
    }
  }

  String _periodLabel(DashboardPeriod period, bool ar) {
    switch (period) {
      case DashboardPeriod.days7:
        return ar ? '٧ أيام' : '7 jours';
      case DashboardPeriod.days30:
        return ar ? '٣٠ يوم' : '30 jours';
      default:
        return ar ? 'الكل' : 'Tout';
    }
  }

  List<Expense> get _expensesInPeriod {
    final store = context.read<AppStore>();
    final list = store.expenses;
    final now = DateTime.now();
    final cutoff = switch (_period) {
      DashboardPeriod.days7 => now.subtract(const Duration(days: 7)),
      DashboardPeriod.days30 => now.subtract(const Duration(days: 30)),
      _ => null,
    };
    if (cutoff == null) return list;
    return list.where((e) => !e.date.isBefore(cutoff)).toList();
  }

  double get _expensesPeriodTotal =>
      _expensesInPeriod.fold(0.0, (sum, e) => sum + e.amount);

  Future<void> _addOrEditExpense([Expense? existing]) async {
    final store = context.read<AppStore>();
    final ar = isArabicContext(context);
    final amountController = TextEditingController(
      text: existing == null ? '' : existing.amount.toStringAsFixed(0),
    );
    final noteController = TextEditingController(text: existing?.note ?? '');
    var category = existing?.category ?? 'ads';
    var date = existing?.date ?? DateTime.now();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(
                existing == null
                    ? (ar ? 'مصروف جديد' : 'Nouvelle dépense')
                    : (ar ? 'تعديل المصروف' : 'Modifier la dépense'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: InputDecoration(
                        labelText: ar ? 'الفئة' : 'Catégorie',
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        for (final c in _categories)
                          DropdownMenuItem(
                            value: c,
                            child: Text(_categoryLabel(c, ar)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => category = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: ar ? 'المبلغ (DA)' : 'Montant (DA)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatDateMedium(dialogContext, date),
                            style: Theme.of(dialogContext).textTheme.bodyMedium,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: dialogContext,
                              initialDate: date,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null) {
                              setDialogState(() => date = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_month_rounded),
                        ),
                      ],
                    ),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: ar ? 'ملاحظة (اختياري)' : 'Note (optionnel)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(ar ? 'إلغاء' : 'Annuler'),
                ),
                FilledButton(
                  onPressed: () {
                    final parsed = double.tryParse(
                          amountController.text.replaceAll(',', '.'),
                        ) ??
                        -1;
                    if (parsed < 0) return;
                    Navigator.of(dialogContext).pop(true);
                    final amount = parsed;
                    final note = noteController.text.trim();
                    if (existing == null) {
                      store.addExpense(
                        Expense(
                          id: store.newId(),
                          date: date,
                          category: category,
                          amount: amount,
                          note: note,
                        ),
                      );
                    } else {
                      store.updateExpense(
                        existing.copyWith(
                          date: date,
                          category: category,
                          amount: amount,
                          note: note,
                        ),
                      );
                    }
                    AppHaptics.success();
                    showAppSnackBar(
                      context,
                      ar ? 'تم الحفظ ✓' : 'Enregistré ✓',
                    );
                  },
                  child: Text(ar ? 'حفظ' : 'Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
    if (saved != true) return;
  }

  void _deleteExpense(Expense expense) {
    final store = context.read<AppStore>();
    store.deleteExpense(expense);
    AppHaptics.select();
    showAppSnackBar(context, isArabicContext(context) ? 'تم الحذف' : 'Supprimé');
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final ar = isArabicContext(context);
    final orders = store.ordersInPeriod(_period);
    final revenue = store.revenueOf(orders);
    final productProfit = store.profitOf(orders);
    final expensesTotal = _expensesPeriodTotal;
    final netProfit = productProfit - expensesTotal;
    final margin = revenue > 0 ? netProfit / revenue * 100 : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(ar ? 'الأرباح' : 'Profit & dépenses'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditExpense(),
        icon: const Icon(Icons.add_rounded),
        label: Text(ar ? 'مصروف' : 'Dépense'),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.fromSTEB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final period in DashboardPeriod.values)
                ChoiceChip(
                  label: Text(_periodLabel(period, ar)),
                  selected: _period == period,
                  onSelected: (_) {
                    AppHaptics.select();
                    setState(() => _period = period);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SoftCard(
            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ar ? 'صافي الربح' : 'Bénéfice net',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  formatCurrency(context, netProfit),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: netProfit >= 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${ar ? 'الهامش' : 'Marge'}: ${formatPercent(context, margin)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const Divider(height: AppSpacing.lg),
                _MoneyRow(
                  label: ar ? 'المبيعات (مُوصلات)' : 'Chiffre d’affaires',
                  value: revenue,
                ),
                _MoneyRow(
                  label: ar ? 'ربح المنتجات' : 'Marge produits',
                  value: productProfit,
                ),
                _MoneyRow(
                  label: ar ? 'المصاريف' : 'Dépenses',
                  value: -expensesTotal,
                  negative: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            title: ar ? 'المصاريف' : 'Dépenses',
            subtitle: '${_expensesInPeriod.length} '
                '${ar ? 'عنصر' : 'entrées'}',
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_expensesInPeriod.isEmpty)
            const EmptyState(
              compact: true,
              icon: Icons.receipt_long_rounded,
              title: 'Aucune dépense',
              body:
                  'Ajoutez vos dépenses (publicité, emballage…) pour un vrai bénéfice net.',
            )
          else
            for (final expense in _expensesInPeriod) ...[
              _ExpenseRow(
                expense: expense,
                categoryLabel: _categoryLabel(expense.category, ar),
                onEdit: () => _addOrEditExpense(expense),
                onDelete: () => _deleteExpense(expense),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({required this.label, required this.value, this.negative = false});

  final String label;
  final double value;
  final bool negative;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            formatCurrency(context, value.abs()),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: negative
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.expense,
    required this.categoryLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final Expense expense;
  final String categoryLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        categoryLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      formatDateShort(context, expense.date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (expense.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    expense.note,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Text(
            formatCurrency(context, expense.amount),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.error,
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Éditer',
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: theme.colorScheme.error,
            ),
            tooltip: 'Supprimer',
          ),
        ],
      ),
    );
  }
}
