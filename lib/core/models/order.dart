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
  String get id => switch (this) {
    OrderStatus.newOrder => 'new',
    OrderStatus.confirmed => 'confirmed',
    OrderStatus.shipped => 'shipped',
    OrderStatus.delivered => 'delivered',
    OrderStatus.returned => 'returned',
    OrderStatus.cancelled => 'cancelled',
    OrderStatus.noAnswer => 'no_answer',
  };

  static OrderStatus fromId(String? value) {
    return OrderStatus.values.firstWhere(
      (status) => status.id == value,
      orElse: () => OrderStatus.newOrder,
    );
  }

  bool get isClosed =>
      this == OrderStatus.delivered ||
      this == OrderStatus.returned ||
      this == OrderStatus.cancelled;
}

class Order {
  const Order({
    required this.id,
    required this.reference,
    required this.customerName,
    required this.phone,
    required this.wilayaCode,
    required this.wilayaName,
    required this.wilayaNameAr,
    required this.commune,
    required this.address,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
    required this.deliveryPrice,
    required this.status,
    required this.createdAt,
    this.notes = '',
    this.deliveryCompany = '',
    this.deliveryType = 'home',
    this.trackingNumber = '',
    this.codPaidByCompany = false,
  });

  final String id;
  final String reference;
  final String customerName;
  final String phone;
  final String wilayaCode;
  final String wilayaName;
  final String wilayaNameAr;
  final String commune;
  final String address;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double costPrice;
  final double deliveryPrice;
  final OrderStatus status;
  final DateTime createdAt;
  final String notes;
  // Fennecly-inspired shipping options
  final String deliveryCompany;
  final String deliveryType; // home | office (stopdesk)
  final String trackingNumber;
  final bool codPaidByCompany;

  double get subtotal => unitPrice * quantity;

  double get total => subtotal + deliveryPrice;

  /// Gross margin on the goods. Delivery is charged back to the customer.
  double get profit => (unitPrice - costPrice) * quantity;

  double get marginPercent {
    if (subtotal <= 0) return 0;
    return (profit / subtotal) * 100;
  }

  bool get earnsRevenue => status == OrderStatus.delivered;

  String wilayaNameFor(bool arabic) => arabic ? wilayaNameAr : wilayaName;

  Order copyWith({
    String? reference,
    String? customerName,
    String? phone,
    String? wilayaCode,
    String? wilayaName,
    String? wilayaNameAr,
    String? commune,
    String? address,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? costPrice,
    double? deliveryPrice,
    OrderStatus? status,
    DateTime? createdAt,
    String? notes,
    String? deliveryCompany,
    String? deliveryType,
    String? trackingNumber,
    bool? codPaidByCompany,
  }) {
    return Order(
      id: id,
      reference: reference ?? this.reference,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      wilayaCode: wilayaCode ?? this.wilayaCode,
      wilayaName: wilayaName ?? this.wilayaName,
      wilayaNameAr: wilayaNameAr ?? this.wilayaNameAr,
      commune: commune ?? this.commune,
      address: address ?? this.address,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      costPrice: costPrice ?? this.costPrice,
      deliveryPrice: deliveryPrice ?? this.deliveryPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      deliveryCompany: deliveryCompany ?? this.deliveryCompany,
      deliveryType: deliveryType ?? this.deliveryType,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      codPaidByCompany: codPaidByCompany ?? this.codPaidByCompany,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'customerName': customerName,
    'phone': phone,
    'wilayaCode': wilayaCode,
    'wilayaName': wilayaName,
    'wilayaNameAr': wilayaNameAr,
    'commune': commune,
    'address': address,
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'costPrice': costPrice,
    'deliveryPrice': deliveryPrice,
    'status': status.id,
    'createdAt': createdAt.toIso8601String(),
    'notes': notes,
    'deliveryCompany': deliveryCompany,
    'deliveryType': deliveryType,
    'trackingNumber': trackingNumber,
    'codPaidByCompany': codPaidByCompany,
  };

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      wilayaCode: json['wilayaCode'] as String? ?? '',
      wilayaName: json['wilayaName'] as String? ?? '',
      wilayaNameAr: json['wilayaNameAr'] as String? ?? '',
      commune: json['commune'] as String? ?? '',
      address: json['address'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0,
      deliveryPrice: (json['deliveryPrice'] as num?)?.toDouble() ?? 0,
      status: OrderStatusX.fromId(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      notes: json['notes'] as String? ?? '',
      deliveryCompany: json['deliveryCompany'] as String? ?? '',
      deliveryType: json['deliveryType'] as String? ?? 'home',
      trackingNumber: json['trackingNumber'] as String? ?? '',
      codPaidByCompany: json['codPaidByCompany'] as bool? ?? false,
    );
  }
}
