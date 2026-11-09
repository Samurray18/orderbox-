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
