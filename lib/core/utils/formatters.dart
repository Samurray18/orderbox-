import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../localization/app_localizations.dart';

String localeCodeOf(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

bool isArabicContext(BuildContext context) => localeCodeOf(context) == 'ar';

String intlLocaleOf(BuildContext context) =>
    isArabicContext(context) ? 'ar_DZ' : 'fr_FR';

String formatNumber(
  BuildContext context,
  num value, {
  int decimals = 0,
  bool compact = false,
}) {
  final locale = intlLocaleOf(context);
  if (compact) {
    return NumberFormat.compact(locale: locale).format(value);
  }
  final pattern = decimals > 0 ? '#,##0.${'#' * decimals}' : '#,##0';
  return NumberFormat(pattern, locale).format(value);
}

String formatCurrency(
  BuildContext context,
  num value, {
  bool compact = false,
}) {
  final l10n = AppLocalizations.of(context);
  return '${formatNumber(context, value, compact: compact)} ${l10n.currency}';
}

String formatPercent(BuildContext context, num value) {
  return '${formatNumber(context, value, decimals: 1)}${AppLocalizations.of(context).percent}';
}

String formatDateShort(BuildContext context, DateTime date) {
  return DateFormat('d MMM', intlLocaleOf(context)).format(date);
}

String formatDateMedium(BuildContext context, DateTime date) {
  return DateFormat('d MMM yyyy', intlLocaleOf(context)).format(date);
}

String formatDateFull(BuildContext context, DateTime date) {
  return DateFormat('EEEE d MMMM yyyy', intlLocaleOf(context)).format(date);
}

String formatDateTime(BuildContext context, DateTime date) {
  return DateFormat('d MMM · HH:mm', intlLocaleOf(context)).format(date);
}

String formatMonthDay(BuildContext context, DateTime date) {
  return DateFormat('EEE', intlLocaleOf(context)).format(date);
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String relativeDay(
  BuildContext context,
  DateTime date,
  AppLocalizations l10n,
) {
  final now = DateTime.now();
  if (isSameDay(date, now)) return l10n.today;
  if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
    return l10n.yesterday;
  }
  return formatDateShort(context, date);
}

String greetingOf(BuildContext context, AppLocalizations l10n) {
  return l10n.greetingForHour(DateTime.now().hour);
}

String initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final only = parts.first;
    return (only.length > 1 ? only.substring(0, 2) : only).toUpperCase();
  }
  return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
}

int colorSeedOf(String value) {
  var hash = 0;
  for (final unit in value.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}

String formatPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.startsWith('+213')) {
    final rest = digits.substring(4);
    if (rest.length == 9) {
      return '+213 ${rest.substring(0, 3)} ${rest.substring(3, 5)} ${rest.substring(5, 7)} ${rest.substring(7)}';
    }
    return digits;
  }
  if (digits.startsWith('213') && digits.length == 12) {
    final rest = digits.substring(3);
    return '+213 ${rest.substring(0, 3)} ${rest.substring(3, 5)} ${rest.substring(5, 7)} ${rest.substring(7)}';
  }
  if (digits.length == 10) {
    return '${digits.substring(0, 2)} ${digits.substring(2, 4)} ${digits.substring(4, 6)} ${digits.substring(6, 8)} ${digits.substring(8)}';
  }
  return raw;
}

String toWhatsAppNumber(String raw) {
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.startsWith('213')) return digits;
  if (digits.startsWith('0')) return '213${digits.substring(1)}';
  if (digits.length == 9) return '213$digits';
  return digits;
}
