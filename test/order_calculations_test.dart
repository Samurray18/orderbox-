import 'package:flutter_test/flutter_test.dart';
import 'package:orderbox_dz/domain/logic/order_calculations.dart';

void main() {
  group('orderTotal', () {
    test('calculates price * quantity + delivery fee', () {
      expect(
        orderTotal(unitPriceDzd: 2500, quantity: 2, deliveryFeeDzd: 600),
        5600,
      );
    });

    test('handles quantity of one', () {
      expect(
        orderTotal(unitPriceDzd: 1000, quantity: 1, deliveryFeeDzd: 400),
        1400,
      );
    });

    test('handles zero delivery fee', () {
      expect(
        orderTotal(unitPriceDzd: 1000, quantity: 3, deliveryFeeDzd: 0),
        3000,
      );
    });

    test('negative quantity falls back to delivery fee', () {
      expect(
        orderTotal(unitPriceDzd: 1000, quantity: -1, deliveryFeeDzd: 500),
        500,
      );
    });
  });

  group('orderGoodsProfit', () {
    test('calculates (selling - buying) * quantity', () {
      expect(
        orderGoodsProfit(sellingPriceDzd: 3000, buyingCostDzd: 1800, quantity: 2),
        2400,
      );
    });

    test('can be negative when selling below cost', () {
      expect(
        orderGoodsProfit(sellingPriceDzd: 1000, buyingCostDzd: 1500, quantity: 1),
        -500,
      );
    });
  });

  group('netProfit', () {
    test('revenue minus product cost minus seller delivery cost', () {
      expect(
        netProfit(revenueDzd: 10000, productCostDzd: 4000, deliveryCostToSellerDzd: 600),
        5400,
      );
    });
  });
}
