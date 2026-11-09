import '../models/order_status.dart';

class RiskyCustomerSignal {
  const RiskyCustomerSignal({
    required this.returnedCount,
    required this.noAnswerCount,
  });

  final int returnedCount;
  final int noAnswerCount;

  bool get isRisky => returnedCount > 0 || noAnswerCount > 0;
  int get totalIncidents => returnedCount + noAnswerCount;
}

/// Computes risk from a customer's historical statuses (excluding the current draft/order if desired).
RiskyCustomerSignal riskySignalForStatuses(Iterable<OrderStatus> statuses) {
  var returned = 0;
  var noAnswer = 0;
  for (final s in statuses) {
    if (s == OrderStatus.returned) returned++;
    if (s == OrderStatus.noAnswer) noAnswer++;
  }
  return RiskyCustomerSignal(
    returnedCount: returned,
    noAnswerCount: noAnswer,
  );
}

/// Algerian mobile: 05/06/07 + 8 digits (10 digits total).
bool isValidAlgerianPhone(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) {
    return digits.startsWith('05') ||
        digits.startsWith('06') ||
        digits.startsWith('07');
  }
  if (digits.length == 12 && digits.startsWith('213')) {
    final local = digits.substring(3);
    return local.startsWith('5') ||
        local.startsWith('6') ||
        local.startsWith('7');
  }
  if (digits.length == 9) {
    return digits.startsWith('5') ||
        digits.startsWith('6') ||
        digits.startsWith('7');
  }
  return false;
}

String normalizePhone(String input) {
  return input.replaceAll(RegExp(r'\D'), '');
}
