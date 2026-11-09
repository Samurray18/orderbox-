enum OrderStatus {
  newOrder,
  confirmed,
  shipped,
  delivered,
  returned,
  cancelled,
  noAnswer,
}

extension OrderStatusX on OrderStatus {
  String get key => switch (this) {
        OrderStatus.newOrder => 'new',
        OrderStatus.confirmed => 'confirmed',
        OrderStatus.shipped => 'shipped',
        OrderStatus.delivered => 'delivered',
        OrderStatus.returned => 'returned',
        OrderStatus.cancelled => 'cancelled',
        OrderStatus.noAnswer => 'no_answer',
      };

  static OrderStatus fromKey(String? value) {
    return OrderStatus.values.firstWhere(
      (s) => s.key == value,
      orElse: () => OrderStatus.newOrder,
    );
  }
}
