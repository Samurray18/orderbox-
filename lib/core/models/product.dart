class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.cost,
    required this.stock,
    required this.createdAt,
  });

  final String id;
  final String name;
  final double price;
  final double cost;
  final int stock;
  final DateTime createdAt;

  double get margin => price - cost;

  double get marginPercent {
    if (price <= 0) return 0;
    return (margin / price) * 100;
  }

  Product copyWith({
    String? name,
    double? price,
    double? cost,
    int? stock,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'cost': cost,
    'stock': stock,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
