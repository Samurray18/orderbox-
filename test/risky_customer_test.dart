import 'package:flutter_test/flutter_test.dart';
import 'package:orderbox_dz/domain/logic/risky_customer.dart';
import 'package:orderbox_dz/domain/models/order_status.dart';

void main() {
  group('riskySignalForStatuses', () {
    test('not risky with no incidents', () {
      final signal = riskySignalForStatuses(const [
        OrderStatus.newOrder,
        OrderStatus.delivered,
        OrderStatus.confirmed,
      ]);
      expect(signal.isRisky, false);
      expect(signal.returnedCount, 0);
      expect(signal.noAnswerCount, 0);
    });

    test('risky when previous returns exist', () {
      final signal = riskySignalForStatuses(const [
        OrderStatus.delivered,
        OrderStatus.returned,
        OrderStatus.returned,
      ]);
      expect(signal.isRisky, true);
      expect(signal.returnedCount, 2);
      expect(signal.totalIncidents, 2);
    });

    test('risky when previous no-answer exists', () {
      final signal = riskySignalForStatuses(const [
        OrderStatus.noAnswer,
        OrderStatus.delivered,
      ]);
      expect(signal.isRisky, true);
      expect(signal.noAnswerCount, 1);
    });

    test('counts both returned and no-answer', () {
      final signal = riskySignalForStatuses(const [
        OrderStatus.returned,
        OrderStatus.noAnswer,
        OrderStatus.cancelled,
      ]);
      expect(signal.isRisky, true);
      expect(signal.totalIncidents, 2);
    });
  });

  group('isValidAlgerianPhone', () {
    test('accepts 05/06/07 + 8 digits', () {
      expect(isValidAlgerianPhone('0551234567'), true);
      expect(isValidAlgerianPhone('0661234567'), true);
      expect(isValidAlgerianPhone('0771234567'), true);
    });

    test('rejects invalid prefixes/lengths', () {
      expect(isValidAlgerianPhone('0451234567'), false);
      expect(isValidAlgerianPhone('055123456'), false);
      expect(isValidAlgerianPhone('05512345678'), false);
      expect(isValidAlgerianPhone(''), false);
    });

    test('accepts formatted/intl variants', () {
      expect(isValidAlgerianPhone('+213 551 23 45 67'), true);
      expect(isValidAlgerianPhone('213551234567'), true);
    });
  });
}
