import '../localization/app_localizations.dart';

abstract final class Validators {
  static String? required(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.requiredField;
    return null;
  }

  static String? phone(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.requiredField;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final valid =
        (digits.length == 10 && digits.startsWith('0')) ||
        (digits.length == 12 && digits.startsWith('213')) ||
        (digits.length == 9 &&
            (digits.startsWith('5') ||
                digits.startsWith('6') ||
                digits.startsWith('7')));
    return valid ? null : l10n.invalidPhone;
  }

  static String? amount(String? value, AppLocalizations l10n,
      {bool allowZero = true}) {
    if (value == null || value.trim().isEmpty) return l10n.requiredField;
    final parsed = double.tryParse(value.replaceAll(',', '.').trim());
    if (parsed == null || parsed < 0 || (!allowZero && parsed == 0)) {
      return l10n.invalidPrice;
    }
    return null;
  }

  static String? quantity(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.requiredField;
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return l10n.invalidQuantity;
    return null;
  }

  static String? wilaya(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.selectWilayaError;
    return null;
  }

  static String? product(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.selectProductError;
    return null;
  }
}
