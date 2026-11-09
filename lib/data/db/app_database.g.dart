// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _buyingCostDzdMeta = const VerificationMeta(
    'buyingCostDzd',
  );
  @override
  late final GeneratedColumn<int> buyingCostDzd = GeneratedColumn<int>(
    'buying_cost_dzd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sellingPriceDzdMeta = const VerificationMeta(
    'sellingPriceDzd',
  );
  @override
  late final GeneratedColumn<int> sellingPriceDzd = GeneratedColumn<int>(
    'selling_price_dzd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stockQtyMeta = const VerificationMeta(
    'stockQty',
  );
  @override
  late final GeneratedColumn<int> stockQty = GeneratedColumn<int>(
    'stock_qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    buyingCostDzd,
    sellingPriceDzd,
    stockQty,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('buying_cost_dzd')) {
      context.handle(
        _buyingCostDzdMeta,
        buyingCostDzd.isAcceptableOrUnknown(
          data['buying_cost_dzd']!,
          _buyingCostDzdMeta,
        ),
      );
    }
    if (data.containsKey('selling_price_dzd')) {
      context.handle(
        _sellingPriceDzdMeta,
        sellingPriceDzd.isAcceptableOrUnknown(
          data['selling_price_dzd']!,
          _sellingPriceDzdMeta,
        ),
      );
    }
    if (data.containsKey('stock_qty')) {
      context.handle(
        _stockQtyMeta,
        stockQty.isAcceptableOrUnknown(data['stock_qty']!, _stockQtyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      buyingCostDzd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}buying_cost_dzd'],
      )!,
      sellingPriceDzd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selling_price_dzd'],
      )!,
      stockQty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_qty'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final int id;
  final String name;
  final int buyingCostDzd;
  final int sellingPriceDzd;
  final int stockQty;
  final DateTime createdAt;
  const Product({
    required this.id,
    required this.name,
    required this.buyingCostDzd,
    required this.sellingPriceDzd,
    required this.stockQty,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['buying_cost_dzd'] = Variable<int>(buyingCostDzd);
    map['selling_price_dzd'] = Variable<int>(sellingPriceDzd);
    map['stock_qty'] = Variable<int>(stockQty);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      buyingCostDzd: Value(buyingCostDzd),
      sellingPriceDzd: Value(sellingPriceDzd),
      stockQty: Value(stockQty),
      createdAt: Value(createdAt),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      buyingCostDzd: serializer.fromJson<int>(json['buyingCostDzd']),
      sellingPriceDzd: serializer.fromJson<int>(json['sellingPriceDzd']),
      stockQty: serializer.fromJson<int>(json['stockQty']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'buyingCostDzd': serializer.toJson<int>(buyingCostDzd),
      'sellingPriceDzd': serializer.toJson<int>(sellingPriceDzd),
      'stockQty': serializer.toJson<int>(stockQty),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Product copyWith({
    int? id,
    String? name,
    int? buyingCostDzd,
    int? sellingPriceDzd,
    int? stockQty,
    DateTime? createdAt,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    buyingCostDzd: buyingCostDzd ?? this.buyingCostDzd,
    sellingPriceDzd: sellingPriceDzd ?? this.sellingPriceDzd,
    stockQty: stockQty ?? this.stockQty,
    createdAt: createdAt ?? this.createdAt,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      buyingCostDzd: data.buyingCostDzd.present
          ? data.buyingCostDzd.value
          : this.buyingCostDzd,
      sellingPriceDzd: data.sellingPriceDzd.present
          ? data.sellingPriceDzd.value
          : this.sellingPriceDzd,
      stockQty: data.stockQty.present ? data.stockQty.value : this.stockQty,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('buyingCostDzd: $buyingCostDzd, ')
          ..write('sellingPriceDzd: $sellingPriceDzd, ')
          ..write('stockQty: $stockQty, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    buyingCostDzd,
    sellingPriceDzd,
    stockQty,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.buyingCostDzd == this.buyingCostDzd &&
          other.sellingPriceDzd == this.sellingPriceDzd &&
          other.stockQty == this.stockQty &&
          other.createdAt == this.createdAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> buyingCostDzd;
  final Value<int> sellingPriceDzd;
  final Value<int> stockQty;
  final Value<DateTime> createdAt;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.buyingCostDzd = const Value.absent(),
    this.sellingPriceDzd = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.buyingCostDzd = const Value.absent(),
    this.sellingPriceDzd = const Value.absent(),
    this.stockQty = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? buyingCostDzd,
    Expression<int>? sellingPriceDzd,
    Expression<int>? stockQty,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (buyingCostDzd != null) 'buying_cost_dzd': buyingCostDzd,
      if (sellingPriceDzd != null) 'selling_price_dzd': sellingPriceDzd,
      if (stockQty != null) 'stock_qty': stockQty,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProductsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? buyingCostDzd,
    Value<int>? sellingPriceDzd,
    Value<int>? stockQty,
    Value<DateTime>? createdAt,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      buyingCostDzd: buyingCostDzd ?? this.buyingCostDzd,
      sellingPriceDzd: sellingPriceDzd ?? this.sellingPriceDzd,
      stockQty: stockQty ?? this.stockQty,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (buyingCostDzd.present) {
      map['buying_cost_dzd'] = Variable<int>(buyingCostDzd.value);
    }
    if (sellingPriceDzd.present) {
      map['selling_price_dzd'] = Variable<int>(sellingPriceDzd.value);
    }
    if (stockQty.present) {
      map['stock_qty'] = Variable<int>(stockQty.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('buyingCostDzd: $buyingCostDzd, ')
          ..write('sellingPriceDzd: $sellingPriceDzd, ')
          ..write('stockQty: $stockQty, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DeliveryPricesTable extends DeliveryPrices
    with TableInfo<$DeliveryPricesTable, DeliveryPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveryPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _wilayaCodeMeta = const VerificationMeta(
    'wilayaCode',
  );
  @override
  late final GeneratedColumn<int> wilayaCode = GeneratedColumn<int>(
    'wilaya_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _homeFeeDzdMeta = const VerificationMeta(
    'homeFeeDzd',
  );
  @override
  late final GeneratedColumn<int> homeFeeDzd = GeneratedColumn<int>(
    'home_fee_dzd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(500),
  );
  static const VerificationMeta _officeFeeDzdMeta = const VerificationMeta(
    'officeFeeDzd',
  );
  @override
  late final GeneratedColumn<int> officeFeeDzd = GeneratedColumn<int>(
    'office_fee_dzd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(350),
  );
  @override
  List<GeneratedColumn> get $columns => [wilayaCode, homeFeeDzd, officeFeeDzd];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'delivery_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeliveryPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('wilaya_code')) {
      context.handle(
        _wilayaCodeMeta,
        wilayaCode.isAcceptableOrUnknown(data['wilaya_code']!, _wilayaCodeMeta),
      );
    }
    if (data.containsKey('home_fee_dzd')) {
      context.handle(
        _homeFeeDzdMeta,
        homeFeeDzd.isAcceptableOrUnknown(
          data['home_fee_dzd']!,
          _homeFeeDzdMeta,
        ),
      );
    }
    if (data.containsKey('office_fee_dzd')) {
      context.handle(
        _officeFeeDzdMeta,
        officeFeeDzd.isAcceptableOrUnknown(
          data['office_fee_dzd']!,
          _officeFeeDzdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {wilayaCode};
  @override
  DeliveryPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveryPrice(
      wilayaCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wilaya_code'],
      )!,
      homeFeeDzd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}home_fee_dzd'],
      )!,
      officeFeeDzd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}office_fee_dzd'],
      )!,
    );
  }

  @override
  $DeliveryPricesTable createAlias(String alias) {
    return $DeliveryPricesTable(attachedDatabase, alias);
  }
}

class DeliveryPrice extends DataClass implements Insertable<DeliveryPrice> {
  final int wilayaCode;
  final int homeFeeDzd;
  final int officeFeeDzd;
  const DeliveryPrice({
    required this.wilayaCode,
    required this.homeFeeDzd,
    required this.officeFeeDzd,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['wilaya_code'] = Variable<int>(wilayaCode);
    map['home_fee_dzd'] = Variable<int>(homeFeeDzd);
    map['office_fee_dzd'] = Variable<int>(officeFeeDzd);
    return map;
  }

  DeliveryPricesCompanion toCompanion(bool nullToAbsent) {
    return DeliveryPricesCompanion(
      wilayaCode: Value(wilayaCode),
      homeFeeDzd: Value(homeFeeDzd),
      officeFeeDzd: Value(officeFeeDzd),
    );
  }

  factory DeliveryPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveryPrice(
      wilayaCode: serializer.fromJson<int>(json['wilayaCode']),
      homeFeeDzd: serializer.fromJson<int>(json['homeFeeDzd']),
      officeFeeDzd: serializer.fromJson<int>(json['officeFeeDzd']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'wilayaCode': serializer.toJson<int>(wilayaCode),
      'homeFeeDzd': serializer.toJson<int>(homeFeeDzd),
      'officeFeeDzd': serializer.toJson<int>(officeFeeDzd),
    };
  }

  DeliveryPrice copyWith({
    int? wilayaCode,
    int? homeFeeDzd,
    int? officeFeeDzd,
  }) => DeliveryPrice(
    wilayaCode: wilayaCode ?? this.wilayaCode,
    homeFeeDzd: homeFeeDzd ?? this.homeFeeDzd,
    officeFeeDzd: officeFeeDzd ?? this.officeFeeDzd,
  );
  DeliveryPrice copyWithCompanion(DeliveryPricesCompanion data) {
    return DeliveryPrice(
      wilayaCode: data.wilayaCode.present
          ? data.wilayaCode.value
          : this.wilayaCode,
      homeFeeDzd: data.homeFeeDzd.present
          ? data.homeFeeDzd.value
          : this.homeFeeDzd,
      officeFeeDzd: data.officeFeeDzd.present
          ? data.officeFeeDzd.value
          : this.officeFeeDzd,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryPrice(')
          ..write('wilayaCode: $wilayaCode, ')
          ..write('homeFeeDzd: $homeFeeDzd, ')
          ..write('officeFeeDzd: $officeFeeDzd')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(wilayaCode, homeFeeDzd, officeFeeDzd);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryPrice &&
          other.wilayaCode == this.wilayaCode &&
          other.homeFeeDzd == this.homeFeeDzd &&
          other.officeFeeDzd == this.officeFeeDzd);
}

class DeliveryPricesCompanion extends UpdateCompanion<DeliveryPrice> {
  final Value<int> wilayaCode;
  final Value<int> homeFeeDzd;
  final Value<int> officeFeeDzd;
  const DeliveryPricesCompanion({
    this.wilayaCode = const Value.absent(),
    this.homeFeeDzd = const Value.absent(),
    this.officeFeeDzd = const Value.absent(),
  });
  DeliveryPricesCompanion.insert({
    this.wilayaCode = const Value.absent(),
    this.homeFeeDzd = const Value.absent(),
    this.officeFeeDzd = const Value.absent(),
  });
  static Insertable<DeliveryPrice> custom({
    Expression<int>? wilayaCode,
    Expression<int>? homeFeeDzd,
    Expression<int>? officeFeeDzd,
  }) {
    return RawValuesInsertable({
      if (wilayaCode != null) 'wilaya_code': wilayaCode,
      if (homeFeeDzd != null) 'home_fee_dzd': homeFeeDzd,
      if (officeFeeDzd != null) 'office_fee_dzd': officeFeeDzd,
    });
  }

  DeliveryPricesCompanion copyWith({
    Value<int>? wilayaCode,
    Value<int>? homeFeeDzd,
    Value<int>? officeFeeDzd,
  }) {
    return DeliveryPricesCompanion(
      wilayaCode: wilayaCode ?? this.wilayaCode,
      homeFeeDzd: homeFeeDzd ?? this.homeFeeDzd,
      officeFeeDzd: officeFeeDzd ?? this.officeFeeDzd,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (wilayaCode.present) {
      map['wilaya_code'] = Variable<int>(wilayaCode.value);
    }
    if (homeFeeDzd.present) {
      map['home_fee_dzd'] = Variable<int>(homeFeeDzd.value);
    }
    if (officeFeeDzd.present) {
      map['office_fee_dzd'] = Variable<int>(officeFeeDzd.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryPricesCompanion(')
          ..write('wilayaCode: $wilayaCode, ')
          ..write('homeFeeDzd: $homeFeeDzd, ')
          ..write('officeFeeDzd: $officeFeeDzd')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wilayaCodeMeta = const VerificationMeta(
    'wilayaCode',
  );
  @override
  late final GeneratedColumn<int> wilayaCode = GeneratedColumn<int>(
    'wilaya_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _communeMeta = const VerificationMeta(
    'commune',
  );
  @override
  late final GeneratedColumn<String> commune = GeneratedColumn<String>(
    'commune',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _addressNoteMeta = const VerificationMeta(
    'addressNote',
  );
  @override
  late final GeneratedColumn<String> addressNote = GeneratedColumn<String>(
    'address_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _unitPriceDzdMeta = const VerificationMeta(
    'unitPriceDzd',
  );
  @override
  late final GeneratedColumn<int> unitPriceDzd = GeneratedColumn<int>(
    'unit_price_dzd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _buyingCostDzdMeta = const VerificationMeta(
    'buyingCostDzd',
  );
  @override
  late final GeneratedColumn<int> buyingCostDzd = GeneratedColumn<int>(
    'buying_cost_dzd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deliveryModeMeta = const VerificationMeta(
    'deliveryMode',
  );
  @override
  late final GeneratedColumn<String> deliveryMode = GeneratedColumn<String>(
    'delivery_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('home'),
  );
  static const VerificationMeta _deliveryFeeDzdMeta = const VerificationMeta(
    'deliveryFeeDzd',
  );
  @override
  late final GeneratedColumn<int> deliveryFeeDzd = GeneratedColumn<int>(
    'delivery_fee_dzd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalDzdMeta = const VerificationMeta(
    'totalDzd',
  );
  @override
  late final GeneratedColumn<int> totalDzd = GeneratedColumn<int>(
    'total_dzd',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('new'),
  );
  static const VerificationMeta _deliveryCompanyMeta = const VerificationMeta(
    'deliveryCompany',
  );
  @override
  late final GeneratedColumn<String> deliveryCompany = GeneratedColumn<String>(
    'delivery_company',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _trackingNumberMeta = const VerificationMeta(
    'trackingNumber',
  );
  @override
  late final GeneratedColumn<String> trackingNumber = GeneratedColumn<String>(
    'tracking_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _codPaidByCompanyMeta = const VerificationMeta(
    'codPaidByCompany',
  );
  @override
  late final GeneratedColumn<bool> codPaidByCompany = GeneratedColumn<bool>(
    'cod_paid_by_company',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cod_paid_by_company" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerName,
    phone,
    wilayaCode,
    commune,
    addressNote,
    productId,
    productName,
    quantity,
    unitPriceDzd,
    buyingCostDzd,
    deliveryMode,
    deliveryFeeDzd,
    totalDzd,
    status,
    deliveryCompany,
    trackingNumber,
    codPaidByCompany,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Order> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('wilaya_code')) {
      context.handle(
        _wilayaCodeMeta,
        wilayaCode.isAcceptableOrUnknown(data['wilaya_code']!, _wilayaCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_wilayaCodeMeta);
    }
    if (data.containsKey('commune')) {
      context.handle(
        _communeMeta,
        commune.isAcceptableOrUnknown(data['commune']!, _communeMeta),
      );
    }
    if (data.containsKey('address_note')) {
      context.handle(
        _addressNoteMeta,
        addressNote.isAcceptableOrUnknown(
          data['address_note']!,
          _addressNoteMeta,
        ),
      );
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit_price_dzd')) {
      context.handle(
        _unitPriceDzdMeta,
        unitPriceDzd.isAcceptableOrUnknown(
          data['unit_price_dzd']!,
          _unitPriceDzdMeta,
        ),
      );
    }
    if (data.containsKey('buying_cost_dzd')) {
      context.handle(
        _buyingCostDzdMeta,
        buyingCostDzd.isAcceptableOrUnknown(
          data['buying_cost_dzd']!,
          _buyingCostDzdMeta,
        ),
      );
    }
    if (data.containsKey('delivery_mode')) {
      context.handle(
        _deliveryModeMeta,
        deliveryMode.isAcceptableOrUnknown(
          data['delivery_mode']!,
          _deliveryModeMeta,
        ),
      );
    }
    if (data.containsKey('delivery_fee_dzd')) {
      context.handle(
        _deliveryFeeDzdMeta,
        deliveryFeeDzd.isAcceptableOrUnknown(
          data['delivery_fee_dzd']!,
          _deliveryFeeDzdMeta,
        ),
      );
    }
    if (data.containsKey('total_dzd')) {
      context.handle(
        _totalDzdMeta,
        totalDzd.isAcceptableOrUnknown(data['total_dzd']!, _totalDzdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('delivery_company')) {
      context.handle(
        _deliveryCompanyMeta,
        deliveryCompany.isAcceptableOrUnknown(
          data['delivery_company']!,
          _deliveryCompanyMeta,
        ),
      );
    }
    if (data.containsKey('tracking_number')) {
      context.handle(
        _trackingNumberMeta,
        trackingNumber.isAcceptableOrUnknown(
          data['tracking_number']!,
          _trackingNumberMeta,
        ),
      );
    }
    if (data.containsKey('cod_paid_by_company')) {
      context.handle(
        _codPaidByCompanyMeta,
        codPaidByCompany.isAcceptableOrUnknown(
          data['cod_paid_by_company']!,
          _codPaidByCompanyMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      wilayaCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wilaya_code'],
      )!,
      commune: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commune'],
      )!,
      addressNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_note'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      ),
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPriceDzd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_dzd'],
      )!,
      buyingCostDzd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}buying_cost_dzd'],
      )!,
      deliveryMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_mode'],
      )!,
      deliveryFeeDzd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}delivery_fee_dzd'],
      )!,
      totalDzd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_dzd'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      deliveryCompany: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_company'],
      )!,
      trackingNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tracking_number'],
      )!,
      codPaidByCompany: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cod_paid_by_company'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class Order extends DataClass implements Insertable<Order> {
  final int id;
  final String customerName;
  final String phone;
  final int wilayaCode;
  final String commune;
  final String addressNote;
  final int? productId;
  final String productName;
  final int quantity;
  final int unitPriceDzd;
  final int buyingCostDzd;
  final String deliveryMode;
  final int deliveryFeeDzd;
  final int totalDzd;
  final String status;
  final String deliveryCompany;
  final String trackingNumber;
  final bool codPaidByCompany;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Order({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.wilayaCode,
    required this.commune,
    required this.addressNote,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPriceDzd,
    required this.buyingCostDzd,
    required this.deliveryMode,
    required this.deliveryFeeDzd,
    required this.totalDzd,
    required this.status,
    required this.deliveryCompany,
    required this.trackingNumber,
    required this.codPaidByCompany,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_name'] = Variable<String>(customerName);
    map['phone'] = Variable<String>(phone);
    map['wilaya_code'] = Variable<int>(wilayaCode);
    map['commune'] = Variable<String>(commune);
    map['address_note'] = Variable<String>(addressNote);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<int>(productId);
    }
    map['product_name'] = Variable<String>(productName);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price_dzd'] = Variable<int>(unitPriceDzd);
    map['buying_cost_dzd'] = Variable<int>(buyingCostDzd);
    map['delivery_mode'] = Variable<String>(deliveryMode);
    map['delivery_fee_dzd'] = Variable<int>(deliveryFeeDzd);
    map['total_dzd'] = Variable<int>(totalDzd);
    map['status'] = Variable<String>(status);
    map['delivery_company'] = Variable<String>(deliveryCompany);
    map['tracking_number'] = Variable<String>(trackingNumber);
    map['cod_paid_by_company'] = Variable<bool>(codPaidByCompany);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      customerName: Value(customerName),
      phone: Value(phone),
      wilayaCode: Value(wilayaCode),
      commune: Value(commune),
      addressNote: Value(addressNote),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      productName: Value(productName),
      quantity: Value(quantity),
      unitPriceDzd: Value(unitPriceDzd),
      buyingCostDzd: Value(buyingCostDzd),
      deliveryMode: Value(deliveryMode),
      deliveryFeeDzd: Value(deliveryFeeDzd),
      totalDzd: Value(totalDzd),
      status: Value(status),
      deliveryCompany: Value(deliveryCompany),
      trackingNumber: Value(trackingNumber),
      codPaidByCompany: Value(codPaidByCompany),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Order.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<int>(json['id']),
      customerName: serializer.fromJson<String>(json['customerName']),
      phone: serializer.fromJson<String>(json['phone']),
      wilayaCode: serializer.fromJson<int>(json['wilayaCode']),
      commune: serializer.fromJson<String>(json['commune']),
      addressNote: serializer.fromJson<String>(json['addressNote']),
      productId: serializer.fromJson<int?>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPriceDzd: serializer.fromJson<int>(json['unitPriceDzd']),
      buyingCostDzd: serializer.fromJson<int>(json['buyingCostDzd']),
      deliveryMode: serializer.fromJson<String>(json['deliveryMode']),
      deliveryFeeDzd: serializer.fromJson<int>(json['deliveryFeeDzd']),
      totalDzd: serializer.fromJson<int>(json['totalDzd']),
      status: serializer.fromJson<String>(json['status']),
      deliveryCompany: serializer.fromJson<String>(json['deliveryCompany']),
      trackingNumber: serializer.fromJson<String>(json['trackingNumber']),
      codPaidByCompany: serializer.fromJson<bool>(json['codPaidByCompany']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerName': serializer.toJson<String>(customerName),
      'phone': serializer.toJson<String>(phone),
      'wilayaCode': serializer.toJson<int>(wilayaCode),
      'commune': serializer.toJson<String>(commune),
      'addressNote': serializer.toJson<String>(addressNote),
      'productId': serializer.toJson<int?>(productId),
      'productName': serializer.toJson<String>(productName),
      'quantity': serializer.toJson<int>(quantity),
      'unitPriceDzd': serializer.toJson<int>(unitPriceDzd),
      'buyingCostDzd': serializer.toJson<int>(buyingCostDzd),
      'deliveryMode': serializer.toJson<String>(deliveryMode),
      'deliveryFeeDzd': serializer.toJson<int>(deliveryFeeDzd),
      'totalDzd': serializer.toJson<int>(totalDzd),
      'status': serializer.toJson<String>(status),
      'deliveryCompany': serializer.toJson<String>(deliveryCompany),
      'trackingNumber': serializer.toJson<String>(trackingNumber),
      'codPaidByCompany': serializer.toJson<bool>(codPaidByCompany),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Order copyWith({
    int? id,
    String? customerName,
    String? phone,
    int? wilayaCode,
    String? commune,
    String? addressNote,
    Value<int?> productId = const Value.absent(),
    String? productName,
    int? quantity,
    int? unitPriceDzd,
    int? buyingCostDzd,
    String? deliveryMode,
    int? deliveryFeeDzd,
    int? totalDzd,
    String? status,
    String? deliveryCompany,
    String? trackingNumber,
    bool? codPaidByCompany,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Order(
    id: id ?? this.id,
    customerName: customerName ?? this.customerName,
    phone: phone ?? this.phone,
    wilayaCode: wilayaCode ?? this.wilayaCode,
    commune: commune ?? this.commune,
    addressNote: addressNote ?? this.addressNote,
    productId: productId.present ? productId.value : this.productId,
    productName: productName ?? this.productName,
    quantity: quantity ?? this.quantity,
    unitPriceDzd: unitPriceDzd ?? this.unitPriceDzd,
    buyingCostDzd: buyingCostDzd ?? this.buyingCostDzd,
    deliveryMode: deliveryMode ?? this.deliveryMode,
    deliveryFeeDzd: deliveryFeeDzd ?? this.deliveryFeeDzd,
    totalDzd: totalDzd ?? this.totalDzd,
    status: status ?? this.status,
    deliveryCompany: deliveryCompany ?? this.deliveryCompany,
    trackingNumber: trackingNumber ?? this.trackingNumber,
    codPaidByCompany: codPaidByCompany ?? this.codPaidByCompany,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      id: data.id.present ? data.id.value : this.id,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      phone: data.phone.present ? data.phone.value : this.phone,
      wilayaCode: data.wilayaCode.present
          ? data.wilayaCode.value
          : this.wilayaCode,
      commune: data.commune.present ? data.commune.value : this.commune,
      addressNote: data.addressNote.present
          ? data.addressNote.value
          : this.addressNote,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceDzd: data.unitPriceDzd.present
          ? data.unitPriceDzd.value
          : this.unitPriceDzd,
      buyingCostDzd: data.buyingCostDzd.present
          ? data.buyingCostDzd.value
          : this.buyingCostDzd,
      deliveryMode: data.deliveryMode.present
          ? data.deliveryMode.value
          : this.deliveryMode,
      deliveryFeeDzd: data.deliveryFeeDzd.present
          ? data.deliveryFeeDzd.value
          : this.deliveryFeeDzd,
      totalDzd: data.totalDzd.present ? data.totalDzd.value : this.totalDzd,
      status: data.status.present ? data.status.value : this.status,
      deliveryCompany: data.deliveryCompany.present
          ? data.deliveryCompany.value
          : this.deliveryCompany,
      trackingNumber: data.trackingNumber.present
          ? data.trackingNumber.value
          : this.trackingNumber,
      codPaidByCompany: data.codPaidByCompany.present
          ? data.codPaidByCompany.value
          : this.codPaidByCompany,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Order(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('phone: $phone, ')
          ..write('wilayaCode: $wilayaCode, ')
          ..write('commune: $commune, ')
          ..write('addressNote: $addressNote, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceDzd: $unitPriceDzd, ')
          ..write('buyingCostDzd: $buyingCostDzd, ')
          ..write('deliveryMode: $deliveryMode, ')
          ..write('deliveryFeeDzd: $deliveryFeeDzd, ')
          ..write('totalDzd: $totalDzd, ')
          ..write('status: $status, ')
          ..write('deliveryCompany: $deliveryCompany, ')
          ..write('trackingNumber: $trackingNumber, ')
          ..write('codPaidByCompany: $codPaidByCompany, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    customerName,
    phone,
    wilayaCode,
    commune,
    addressNote,
    productId,
    productName,
    quantity,
    unitPriceDzd,
    buyingCostDzd,
    deliveryMode,
    deliveryFeeDzd,
    totalDzd,
    status,
    deliveryCompany,
    trackingNumber,
    codPaidByCompany,
    notes,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.id == this.id &&
          other.customerName == this.customerName &&
          other.phone == this.phone &&
          other.wilayaCode == this.wilayaCode &&
          other.commune == this.commune &&
          other.addressNote == this.addressNote &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.unitPriceDzd == this.unitPriceDzd &&
          other.buyingCostDzd == this.buyingCostDzd &&
          other.deliveryMode == this.deliveryMode &&
          other.deliveryFeeDzd == this.deliveryFeeDzd &&
          other.totalDzd == this.totalDzd &&
          other.status == this.status &&
          other.deliveryCompany == this.deliveryCompany &&
          other.trackingNumber == this.trackingNumber &&
          other.codPaidByCompany == this.codPaidByCompany &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<int> id;
  final Value<String> customerName;
  final Value<String> phone;
  final Value<int> wilayaCode;
  final Value<String> commune;
  final Value<String> addressNote;
  final Value<int?> productId;
  final Value<String> productName;
  final Value<int> quantity;
  final Value<int> unitPriceDzd;
  final Value<int> buyingCostDzd;
  final Value<String> deliveryMode;
  final Value<int> deliveryFeeDzd;
  final Value<int> totalDzd;
  final Value<String> status;
  final Value<String> deliveryCompany;
  final Value<String> trackingNumber;
  final Value<bool> codPaidByCompany;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.customerName = const Value.absent(),
    this.phone = const Value.absent(),
    this.wilayaCode = const Value.absent(),
    this.commune = const Value.absent(),
    this.addressNote = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceDzd = const Value.absent(),
    this.buyingCostDzd = const Value.absent(),
    this.deliveryMode = const Value.absent(),
    this.deliveryFeeDzd = const Value.absent(),
    this.totalDzd = const Value.absent(),
    this.status = const Value.absent(),
    this.deliveryCompany = const Value.absent(),
    this.trackingNumber = const Value.absent(),
    this.codPaidByCompany = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  OrdersCompanion.insert({
    this.id = const Value.absent(),
    required String customerName,
    required String phone,
    required int wilayaCode,
    this.commune = const Value.absent(),
    this.addressNote = const Value.absent(),
    this.productId = const Value.absent(),
    required String productName,
    this.quantity = const Value.absent(),
    this.unitPriceDzd = const Value.absent(),
    this.buyingCostDzd = const Value.absent(),
    this.deliveryMode = const Value.absent(),
    this.deliveryFeeDzd = const Value.absent(),
    this.totalDzd = const Value.absent(),
    this.status = const Value.absent(),
    this.deliveryCompany = const Value.absent(),
    this.trackingNumber = const Value.absent(),
    this.codPaidByCompany = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : customerName = Value(customerName),
       phone = Value(phone),
       wilayaCode = Value(wilayaCode),
       productName = Value(productName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Order> custom({
    Expression<int>? id,
    Expression<String>? customerName,
    Expression<String>? phone,
    Expression<int>? wilayaCode,
    Expression<String>? commune,
    Expression<String>? addressNote,
    Expression<int>? productId,
    Expression<String>? productName,
    Expression<int>? quantity,
    Expression<int>? unitPriceDzd,
    Expression<int>? buyingCostDzd,
    Expression<String>? deliveryMode,
    Expression<int>? deliveryFeeDzd,
    Expression<int>? totalDzd,
    Expression<String>? status,
    Expression<String>? deliveryCompany,
    Expression<String>? trackingNumber,
    Expression<bool>? codPaidByCompany,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerName != null) 'customer_name': customerName,
      if (phone != null) 'phone': phone,
      if (wilayaCode != null) 'wilaya_code': wilayaCode,
      if (commune != null) 'commune': commune,
      if (addressNote != null) 'address_note': addressNote,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceDzd != null) 'unit_price_dzd': unitPriceDzd,
      if (buyingCostDzd != null) 'buying_cost_dzd': buyingCostDzd,
      if (deliveryMode != null) 'delivery_mode': deliveryMode,
      if (deliveryFeeDzd != null) 'delivery_fee_dzd': deliveryFeeDzd,
      if (totalDzd != null) 'total_dzd': totalDzd,
      if (status != null) 'status': status,
      if (deliveryCompany != null) 'delivery_company': deliveryCompany,
      if (trackingNumber != null) 'tracking_number': trackingNumber,
      if (codPaidByCompany != null) 'cod_paid_by_company': codPaidByCompany,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  OrdersCompanion copyWith({
    Value<int>? id,
    Value<String>? customerName,
    Value<String>? phone,
    Value<int>? wilayaCode,
    Value<String>? commune,
    Value<String>? addressNote,
    Value<int?>? productId,
    Value<String>? productName,
    Value<int>? quantity,
    Value<int>? unitPriceDzd,
    Value<int>? buyingCostDzd,
    Value<String>? deliveryMode,
    Value<int>? deliveryFeeDzd,
    Value<int>? totalDzd,
    Value<String>? status,
    Value<String>? deliveryCompany,
    Value<String>? trackingNumber,
    Value<bool>? codPaidByCompany,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return OrdersCompanion(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      wilayaCode: wilayaCode ?? this.wilayaCode,
      commune: commune ?? this.commune,
      addressNote: addressNote ?? this.addressNote,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPriceDzd: unitPriceDzd ?? this.unitPriceDzd,
      buyingCostDzd: buyingCostDzd ?? this.buyingCostDzd,
      deliveryMode: deliveryMode ?? this.deliveryMode,
      deliveryFeeDzd: deliveryFeeDzd ?? this.deliveryFeeDzd,
      totalDzd: totalDzd ?? this.totalDzd,
      status: status ?? this.status,
      deliveryCompany: deliveryCompany ?? this.deliveryCompany,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      codPaidByCompany: codPaidByCompany ?? this.codPaidByCompany,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (wilayaCode.present) {
      map['wilaya_code'] = Variable<int>(wilayaCode.value);
    }
    if (commune.present) {
      map['commune'] = Variable<String>(commune.value);
    }
    if (addressNote.present) {
      map['address_note'] = Variable<String>(addressNote.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPriceDzd.present) {
      map['unit_price_dzd'] = Variable<int>(unitPriceDzd.value);
    }
    if (buyingCostDzd.present) {
      map['buying_cost_dzd'] = Variable<int>(buyingCostDzd.value);
    }
    if (deliveryMode.present) {
      map['delivery_mode'] = Variable<String>(deliveryMode.value);
    }
    if (deliveryFeeDzd.present) {
      map['delivery_fee_dzd'] = Variable<int>(deliveryFeeDzd.value);
    }
    if (totalDzd.present) {
      map['total_dzd'] = Variable<int>(totalDzd.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (deliveryCompany.present) {
      map['delivery_company'] = Variable<String>(deliveryCompany.value);
    }
    if (trackingNumber.present) {
      map['tracking_number'] = Variable<String>(trackingNumber.value);
    }
    if (codPaidByCompany.present) {
      map['cod_paid_by_company'] = Variable<bool>(codPaidByCompany.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('phone: $phone, ')
          ..write('wilayaCode: $wilayaCode, ')
          ..write('commune: $commune, ')
          ..write('addressNote: $addressNote, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceDzd: $unitPriceDzd, ')
          ..write('buyingCostDzd: $buyingCostDzd, ')
          ..write('deliveryMode: $deliveryMode, ')
          ..write('deliveryFeeDzd: $deliveryFeeDzd, ')
          ..write('totalDzd: $totalDzd, ')
          ..write('status: $status, ')
          ..write('deliveryCompany: $deliveryCompany, ')
          ..write('trackingNumber: $trackingNumber, ')
          ..write('codPaidByCompany: $codPaidByCompany, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $DeliveryPricesTable deliveryPrices = $DeliveryPricesTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    products,
    deliveryPrices,
    orders,
    appSettings,
  ];
}

typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  required String name,
  Value<int> buyingCostDzd,
  Value<int> sellingPriceDzd,
  Value<int> stockQty,
  required DateTime createdAt,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> buyingCostDzd,
  Value<int> sellingPriceDzd,
  Value<int> stockQty,
  Value<DateTime> createdAt,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get buyingCostDzd => $composableBuilder(
    column: $table.buyingCostDzd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellingPriceDzd => $composableBuilder(
    column: $table.sellingPriceDzd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get buyingCostDzd => $composableBuilder(
    column: $table.buyingCostDzd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellingPriceDzd => $composableBuilder(
    column: $table.sellingPriceDzd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get buyingCostDzd => $composableBuilder(
    column: $table.buyingCostDzd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sellingPriceDzd => $composableBuilder(
    column: $table.sellingPriceDzd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockQty =>
      $composableBuilder(column: $table.stockQty, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
          Product,
          PrefetchHooks Function()
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> buyingCostDzd = const Value.absent(),
                Value<int> sellingPriceDzd = const Value.absent(),
                Value<int> stockQty = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                name: name,
                buyingCostDzd: buyingCostDzd,
                sellingPriceDzd: sellingPriceDzd,
                stockQty: stockQty,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> buyingCostDzd = const Value.absent(),
                Value<int> sellingPriceDzd = const Value.absent(),
                Value<int> stockQty = const Value.absent(),
                required DateTime createdAt,
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                buyingCostDzd: buyingCostDzd,
                sellingPriceDzd: sellingPriceDzd,
                stockQty: stockQty,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductsTable, Product>(table),
                  BaseReferences<_$AppDatabase, $ProductsTable, Product>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
      Product,
      PrefetchHooks Function()
    >;
typedef $$DeliveryPricesTableCreateCompanionBuilder =
    DeliveryPricesCompanion Function({
      Value<int> wilayaCode,
      Value<int> homeFeeDzd,
      Value<int> officeFeeDzd,
    });
typedef $$DeliveryPricesTableUpdateCompanionBuilder =
    DeliveryPricesCompanion Function({
      Value<int> wilayaCode,
      Value<int> homeFeeDzd,
      Value<int> officeFeeDzd,
    });

class $$DeliveryPricesTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveryPricesTable> {
  $$DeliveryPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get wilayaCode => $composableBuilder(
    column: $table.wilayaCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get homeFeeDzd => $composableBuilder(
    column: $table.homeFeeDzd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get officeFeeDzd => $composableBuilder(
    column: $table.officeFeeDzd,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeliveryPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveryPricesTable> {
  $$DeliveryPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get wilayaCode => $composableBuilder(
    column: $table.wilayaCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get homeFeeDzd => $composableBuilder(
    column: $table.homeFeeDzd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get officeFeeDzd => $composableBuilder(
    column: $table.officeFeeDzd,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeliveryPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveryPricesTable> {
  $$DeliveryPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get wilayaCode => $composableBuilder(
    column: $table.wilayaCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get homeFeeDzd => $composableBuilder(
    column: $table.homeFeeDzd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get officeFeeDzd => $composableBuilder(
    column: $table.officeFeeDzd,
    builder: (column) => column,
  );
}

class $$DeliveryPricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeliveryPricesTable,
          DeliveryPrice,
          $$DeliveryPricesTableFilterComposer,
          $$DeliveryPricesTableOrderingComposer,
          $$DeliveryPricesTableAnnotationComposer,
          $$DeliveryPricesTableCreateCompanionBuilder,
          $$DeliveryPricesTableUpdateCompanionBuilder,
          (
            DeliveryPrice,
            BaseReferences<_$AppDatabase, $DeliveryPricesTable, DeliveryPrice>,
          ),
          DeliveryPrice,
          PrefetchHooks Function()
        > {
  $$DeliveryPricesTableTableManager(
    _$AppDatabase db,
    $DeliveryPricesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveryPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveryPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveryPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> wilayaCode = const Value.absent(),
                Value<int> homeFeeDzd = const Value.absent(),
                Value<int> officeFeeDzd = const Value.absent(),
              }) => DeliveryPricesCompanion(
                wilayaCode: wilayaCode,
                homeFeeDzd: homeFeeDzd,
                officeFeeDzd: officeFeeDzd,
              ),
          createCompanionCallback:
              ({
                Value<int> wilayaCode = const Value.absent(),
                Value<int> homeFeeDzd = const Value.absent(),
                Value<int> officeFeeDzd = const Value.absent(),
              }) => DeliveryPricesCompanion.insert(
                wilayaCode: wilayaCode,
                homeFeeDzd: homeFeeDzd,
                officeFeeDzd: officeFeeDzd,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeliveryPricesTable, DeliveryPrice>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DeliveryPricesTable,
                    DeliveryPrice
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeliveryPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeliveryPricesTable,
      DeliveryPrice,
      $$DeliveryPricesTableFilterComposer,
      $$DeliveryPricesTableOrderingComposer,
      $$DeliveryPricesTableAnnotationComposer,
      $$DeliveryPricesTableCreateCompanionBuilder,
      $$DeliveryPricesTableUpdateCompanionBuilder,
      (
        DeliveryPrice,
        BaseReferences<_$AppDatabase, $DeliveryPricesTable, DeliveryPrice>,
      ),
      DeliveryPrice,
      PrefetchHooks Function()
    >;
typedef $$OrdersTableCreateCompanionBuilder = OrdersCompanion Function({
  Value<int> id,
  required String customerName,
  required String phone,
  required int wilayaCode,
  Value<String> commune,
  Value<String> addressNote,
  Value<int?> productId,
  required String productName,
  Value<int> quantity,
  Value<int> unitPriceDzd,
  Value<int> buyingCostDzd,
  Value<String> deliveryMode,
  Value<int> deliveryFeeDzd,
  Value<int> totalDzd,
  Value<String> status,
  Value<String> deliveryCompany,
  Value<String> trackingNumber,
  Value<bool> codPaidByCompany,
  Value<String> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<int> id,
  Value<String> customerName,
  Value<String> phone,
  Value<int> wilayaCode,
  Value<String> commune,
  Value<String> addressNote,
  Value<int?> productId,
  Value<String> productName,
  Value<int> quantity,
  Value<int> unitPriceDzd,
  Value<int> buyingCostDzd,
  Value<String> deliveryMode,
  Value<int> deliveryFeeDzd,
  Value<int> totalDzd,
  Value<String> status,
  Value<String> deliveryCompany,
  Value<String> trackingNumber,
  Value<bool> codPaidByCompany,
  Value<String> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wilayaCode => $composableBuilder(
    column: $table.wilayaCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commune => $composableBuilder(
    column: $table.commune,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressNote => $composableBuilder(
    column: $table.addressNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceDzd => $composableBuilder(
    column: $table.unitPriceDzd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get buyingCostDzd => $composableBuilder(
    column: $table.buyingCostDzd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryMode => $composableBuilder(
    column: $table.deliveryMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deliveryFeeDzd => $composableBuilder(
    column: $table.deliveryFeeDzd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDzd => $composableBuilder(
    column: $table.totalDzd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryCompany => $composableBuilder(
    column: $table.deliveryCompany,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackingNumber => $composableBuilder(
    column: $table.trackingNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get codPaidByCompany => $composableBuilder(
    column: $table.codPaidByCompany,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wilayaCode => $composableBuilder(
    column: $table.wilayaCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commune => $composableBuilder(
    column: $table.commune,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressNote => $composableBuilder(
    column: $table.addressNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceDzd => $composableBuilder(
    column: $table.unitPriceDzd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get buyingCostDzd => $composableBuilder(
    column: $table.buyingCostDzd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryMode => $composableBuilder(
    column: $table.deliveryMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deliveryFeeDzd => $composableBuilder(
    column: $table.deliveryFeeDzd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDzd => $composableBuilder(
    column: $table.totalDzd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryCompany => $composableBuilder(
    column: $table.deliveryCompany,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackingNumber => $composableBuilder(
    column: $table.trackingNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get codPaidByCompany => $composableBuilder(
    column: $table.codPaidByCompany,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<int> get wilayaCode => $composableBuilder(
    column: $table.wilayaCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commune =>
      $composableBuilder(column: $table.commune, builder: (column) => column);

  GeneratedColumn<String> get addressNote => $composableBuilder(
    column: $table.addressNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPriceDzd => $composableBuilder(
    column: $table.unitPriceDzd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get buyingCostDzd => $composableBuilder(
    column: $table.buyingCostDzd,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryMode => $composableBuilder(
    column: $table.deliveryMode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deliveryFeeDzd => $composableBuilder(
    column: $table.deliveryFeeDzd,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDzd =>
      $composableBuilder(column: $table.totalDzd, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get deliveryCompany => $composableBuilder(
    column: $table.deliveryCompany,
    builder: (column) => column,
  );

  GeneratedColumn<String> get trackingNumber => $composableBuilder(
    column: $table.trackingNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get codPaidByCompany => $composableBuilder(
    column: $table.codPaidByCompany,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$OrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrdersTable,
          Order,
          $$OrdersTableFilterComposer,
          $$OrdersTableOrderingComposer,
          $$OrdersTableAnnotationComposer,
          $$OrdersTableCreateCompanionBuilder,
          $$OrdersTableUpdateCompanionBuilder,
          (Order, BaseReferences<_$AppDatabase, $OrdersTable, Order>),
          Order,
          PrefetchHooks Function()
        > {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<int> wilayaCode = const Value.absent(),
                Value<String> commune = const Value.absent(),
                Value<String> addressNote = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> unitPriceDzd = const Value.absent(),
                Value<int> buyingCostDzd = const Value.absent(),
                Value<String> deliveryMode = const Value.absent(),
                Value<int> deliveryFeeDzd = const Value.absent(),
                Value<int> totalDzd = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> deliveryCompany = const Value.absent(),
                Value<String> trackingNumber = const Value.absent(),
                Value<bool> codPaidByCompany = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => OrdersCompanion(
                id: id,
                customerName: customerName,
                phone: phone,
                wilayaCode: wilayaCode,
                commune: commune,
                addressNote: addressNote,
                productId: productId,
                productName: productName,
                quantity: quantity,
                unitPriceDzd: unitPriceDzd,
                buyingCostDzd: buyingCostDzd,
                deliveryMode: deliveryMode,
                deliveryFeeDzd: deliveryFeeDzd,
                totalDzd: totalDzd,
                status: status,
                deliveryCompany: deliveryCompany,
                trackingNumber: trackingNumber,
                codPaidByCompany: codPaidByCompany,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String customerName,
                required String phone,
                required int wilayaCode,
                Value<String> commune = const Value.absent(),
                Value<String> addressNote = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                required String productName,
                Value<int> quantity = const Value.absent(),
                Value<int> unitPriceDzd = const Value.absent(),
                Value<int> buyingCostDzd = const Value.absent(),
                Value<String> deliveryMode = const Value.absent(),
                Value<int> deliveryFeeDzd = const Value.absent(),
                Value<int> totalDzd = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> deliveryCompany = const Value.absent(),
                Value<String> trackingNumber = const Value.absent(),
                Value<bool> codPaidByCompany = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => OrdersCompanion.insert(
                id: id,
                customerName: customerName,
                phone: phone,
                wilayaCode: wilayaCode,
                commune: commune,
                addressNote: addressNote,
                productId: productId,
                productName: productName,
                quantity: quantity,
                unitPriceDzd: unitPriceDzd,
                buyingCostDzd: buyingCostDzd,
                deliveryMode: deliveryMode,
                deliveryFeeDzd: deliveryFeeDzd,
                totalDzd: totalDzd,
                status: status,
                deliveryCompany: deliveryCompany,
                trackingNumber: trackingNumber,
                codPaidByCompany: codPaidByCompany,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OrdersTable, Order>(table),
                  BaseReferences<_$AppDatabase, $OrdersTable, Order>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrdersTable,
      Order,
      $$OrdersTableFilterComposer,
      $$OrdersTableOrderingComposer,
      $$OrdersTableAnnotationComposer,
      $$OrdersTableCreateCompanionBuilder,
      $$OrdersTableUpdateCompanionBuilder,
      (Order, BaseReferences<_$AppDatabase, $OrdersTable, Order>),
      Order,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      Value<String> value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$DeliveryPricesTableTableManager get deliveryPrices =>
      $$DeliveryPricesTableTableManager(_db, _db.deliveryPrices);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
