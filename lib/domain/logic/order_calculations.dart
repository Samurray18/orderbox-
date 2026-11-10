import '../../core/models/order.dart';

/// Total collected/charged for an order line: (unit price * quantity) + delivery fee.
int orderTotal({
  required int unitPriceDzd,
  required int quantity,
  required int deliveryFeeDzd,
}) {
  if (quantity < 0) return deliveryFeeDzd;
  return (unitPriceDzd * quantity) + deliveryFeeDzd;
}

/// Gross profit on goods (excludes delivery fee pass-through effects).
int orderGoodsProfit({
  required int sellingPriceDzd,
  required int buyingCostDzd,
  required int quantity,
}) {
  if (quantity < 0) return 0;
  return (sellingPriceDzd - buyingCostDzd) * quantity;
}

/// Net profit for a set of realized (delivered, COD paid model context) figures.
/// deliveryCostToSeller: what the seller pays out for delivery (0 if charged to customer only).
int netProfit({
  required int revenueDzd,
  required int productCostDzd,
  required int deliveryCostToSellerDzd,
}) {
  return revenueDzd - productCostDzd - deliveryCostToSellerDzd;
}

/// COD owed to the seller: delivered orders whose collection by the delivery
/// company has not been registered yet (cod_paid_by_company == false).
double codOwedToSeller(List<Order> orders) {
  double owed = 0;
  for (final order in orders) {
    if (order.status == OrderStatus.delivered && !order.codPaidByCompany) {
      owed += order.total;
    }
  }
  return owed;
}

/// Profit for a delivered order: revenue - refunds - product cost - delivery cost.
/// Mirrors the Fennecly web profit computation (`lib/profit/compute.ts`).
double deliveredOrderProfit({
  required double revenue,
  required double refunds,
  required double cogs,
  required double deliveryCost,
}) {
  return revenue - refunds - cogs - deliveryCost;
}

/// Net profit after returns (loss = delivery + return cost) and operating
/// expenses: revenue - refunds - cogs - delivery - returnLosses - expenses.
double netProfitAfterReturns({
  required double revenue,
  required double refunds,
  required double cogs,
  required double deliveryCost,
  double returnLoss = 0,
  double expenses = 0,
}) {
  return revenue - refunds - cogs - deliveryCost - returnLoss - expenses;
}

/// Margin percentage: net profit / revenue * 100 (0 when revenue is 0).
double marginPercent({required double netProfit, required double revenue}) {
  if (revenue <= 0) return 0;
  return (netProfit / revenue) * 100;
}
