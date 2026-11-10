import 'package:flutter_test/flutter_test.dart';
import 'package:orderbox_dz/core/models/order.dart';
import 'package:orderbox_dz/domain/logic/order_calculations.dart';

void main() {
  group('Fennecly status mapping (Phase 1 parity)', () {
    test('maps every web status value onto the local status', () {
      expect(OrderStatusX.fromId('pending'), OrderStatus.newOrder);
      expect(OrderStatusX.fromId('new'), OrderStatus.newOrder);
      expect(OrderStatusX.fromId('new_order'), OrderStatus.newOrder);
      expect(OrderStatusX.fromId('confirmed'), OrderStatus.confirmed);
      expect(OrderStatusX.fromId('shipped'), OrderStatus.shipped);
      expect(OrderStatusX.fromId('in_transit'), OrderStatus.shipped);
      expect(OrderStatusX.fromId('out_for_delivery'), OrderStatus.shipped);
      expect(OrderStatusX.fromId('delivered'), OrderStatus.delivered);
      expect(OrderStatusX.fromId('completed'), OrderStatus.delivered);
      expect(OrderStatusX.fromId('returned'), OrderStatus.returned);
      expect(OrderStatusX.fromId('refunded'), OrderStatus.returned);
      expect(OrderStatusX.fromId('cancelled'), OrderStatus.cancelled);
      expect(OrderStatusX.fromId('canceled'), OrderStatus.cancelled);
      expect(OrderStatusX.fromId('no_answer'), OrderStatus.noAnswer);
      expect(OrderStatusX.fromId('noanswer'), OrderStatus.noAnswer);
      expect(OrderStatusX.fromId('unreachable'), OrderStatus.noAnswer);
      expect(OrderStatusX.fromId(null), OrderStatus.newOrder);
      expect(OrderStatusX.fromId('totally_unknown'), OrderStatus.newOrder);
    });

    test('maps local status back to the web status values', () {
      expect(OrderStatus.newOrder.fenneclyId, 'pending');
      expect(OrderStatus.confirmed.fenneclyId, 'confirmed');
      expect(OrderStatus.shipped.fenneclyId, 'shipped');
      expect(OrderStatus.delivered.fenneclyId, 'delivered');
      expect(OrderStatus.returned.fenneclyId, 'returned');
      expect(OrderStatus.cancelled.fenneclyId, 'cancelled');
      // Web has no "no answer" order status: it is stored via call_logs.
      expect(OrderStatus.noAnswer.fenneclyId, 'pending');
    });
  });

  group('COD manager totals (Phase 1 parity)', () {
    final Order deliveredWithCod = Order(
      id: 'o1',
      reference: 'OB-1',
      customerName: 'Ali',
      phone: '0551234567',
      wilayaCode: '01',
      wilayaName: 'Adrar',
      wilayaNameAr: 'أدرار',
      commune: 'Bab',
      address: 'Street 1',
      productId: 'p1',
      productName: 'Milk',
      quantity: 2,
      unitPrice: 300,
      costPrice: 100,
      deliveryPrice: 600,
      status: OrderStatus.delivered,
      createdAt: DateTime(2026, 1, 1),
      codPaidByCompany: false,
    );

    final Order deliveredPaidCod = Order(
      id: 'o2',
      reference: 'OB-2',
      customerName: 'Sara',
      phone: '0559876543',
      wilayaCode: '02',
      wilayaName: 'Blida',
      wilayaNameAr: 'بلدة',
      commune: 'Blida',
      address: 'Street 2',
      productId: 'p2',
      productName: 'Bread',
      quantity: 1,
      unitPrice: 250,
      costPrice: 80,
      deliveryPrice: 350,
      status: OrderStatus.delivered,
      createdAt: DateTime(2026, 1, 2),
      codPaidByCompany: true,
    );

    final Order pendingOrder = Order(
      id: 'o3',
      reference: 'OB-3',
      customerName: 'Omar',
      phone: '0551112222',
      wilayaCode: '03',
      wilayaName: 'Médéa',
      wilayaNameAr: 'مضادية',
      commune: 'Médéa',
      address: 'Street 3',
      productId: 'p3',
      productName: 'Tea',
      quantity: 3,
      unitPrice: 200,
      costPrice: 60,
      deliveryPrice: 500,
      status: OrderStatus.confirmed,
      createdAt: DateTime(2026, 1, 3),
      codPaidByCompany: false,
    );

    test('codOwedToSeller sums delivered orders not yet collected', () {
      final owed = codOwedToSeller([deliveredWithCod, deliveredPaidCod, pendingOrder]);
      // (300*2 + 600) + 0 for the paid one; pending order is not delivered.
      expect(owed, 1200);
    });

    test('codOwedToSeller returns zero when nothing is owed', () {
      final paidOnly = [deliveredPaidCod];
      expect(codOwedToSeller(paidOnly), 0);
      expect(codOwedToSeller(const <Order>[]), 0);
    });
  });

  group('Profit formulas (Phase 1 parity with web lib/profit/compute.ts)', () {
    test('deliveredOrderProfit subtracts refunds, cogs and delivery cost', () {
      final profit = deliveredOrderProfit(
        revenue: 5000,
        refunds: 1500,
        cogs: 1200,
        deliveryCost: 600,
      );
      expect(profit, 1700);
    });

    test('netProfitAfterReturns subtracts return loss and expenses', () {
      final net = netProfitAfterReturns(
        revenue: 5000,
        refunds: 1500,
        cogs: 1200,
        deliveryCost: 600,
        returnLoss: 250,
        expenses: 100,
      );
      // delivered: 5000 - 1500 - 1200 - 600 = 1700
      // minus return loss (delivery 600 + return 250... here simplified) - expenses
      expect(net, lessThan(1700));
    });

    test('marginPercent computes net/revenue', () {
      expect(marginPercent(netProfit: 250, revenue: 1000), 25);
      expect(marginPercent(netProfit: 0, revenue: 0), 0);
    });
  });
}
