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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
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
    price,
    cost,
    stock,
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
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
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
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
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
  final String id;
  final String name;
  final double price;
  final double cost;
  final int stock;
  final DateTime createdAt;
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.cost,
    required this.stock,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['price'] = Variable<double>(price);
    map['cost'] = Variable<double>(cost);
    map['stock'] = Variable<int>(stock);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      price: Value(price),
      cost: Value(cost),
      stock: Value(stock),
      createdAt: Value(createdAt),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      price: serializer.fromJson<double>(json['price']),
      cost: serializer.fromJson<double>(json['cost']),
      stock: serializer.fromJson<int>(json['stock']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'price': serializer.toJson<double>(price),
      'cost': serializer.toJson<double>(cost),
      'stock': serializer.toJson<int>(stock),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    double? cost,
    int? stock,
    DateTime? createdAt,
  }) => Product(
    id: id ?? this.id,
    name: name ?? this.name,
    price: price ?? this.price,
    cost: cost ?? this.cost,
    stock: stock ?? this.stock,
    createdAt: createdAt ?? this.createdAt,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      price: data.price.present ? data.price.value : this.price,
      cost: data.cost.present ? data.cost.value : this.cost,
      stock: data.stock.present ? data.stock.value : this.stock,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('cost: $cost, ')
          ..write('stock: $stock, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, price, cost, stock, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.price == this.price &&
          other.cost == this.cost &&
          other.stock == this.stock &&
          other.createdAt == this.createdAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> price;
  final Value<double> cost;
  final Value<int> stock;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.price = const Value.absent(),
    this.cost = const Value.absent(),
    this.stock = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    this.price = const Value.absent(),
    this.cost = const Value.absent(),
    this.stock = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Product> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? price,
    Expression<double>? cost,
    Expression<int>? stock,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (cost != null) 'cost': cost,
      if (stock != null) 'stock': stock,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? price,
    Value<double>? cost,
    Value<int>? stock,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('price: $price, ')
          ..write('cost: $cost, ')
          ..write('stock: $stock, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
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
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  late final GeneratedColumn<String> wilayaCode = GeneratedColumn<String>(
    'wilaya_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _wilayaNameMeta = const VerificationMeta(
    'wilayaName',
  );
  @override
  late final GeneratedColumn<String> wilayaName = GeneratedColumn<String>(
    'wilaya_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _wilayaNameArMeta = const VerificationMeta(
    'wilayaNameAr',
  );
  @override
  late final GeneratedColumn<String> wilayaNameAr = GeneratedColumn<String>(
    'wilaya_name_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
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
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _costPriceMeta = const VerificationMeta(
    'costPrice',
  );
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
    'cost_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _deliveryPriceMeta = const VerificationMeta(
    'deliveryPrice',
  );
  @override
  late final GeneratedColumn<double> deliveryPrice = GeneratedColumn<double>(
    'delivery_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _deliveryTypeMeta = const VerificationMeta(
    'deliveryType',
  );
  @override
  late final GeneratedColumn<String> deliveryType = GeneratedColumn<String>(
    'delivery_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('home'),
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reference,
    customerName,
    phone,
    wilayaCode,
    wilayaName,
    wilayaNameAr,
    commune,
    address,
    productId,
    productName,
    quantity,
    unitPrice,
    costPrice,
    deliveryPrice,
    deliveryType,
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
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
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
    }
    if (data.containsKey('wilaya_name')) {
      context.handle(
        _wilayaNameMeta,
        wilayaName.isAcceptableOrUnknown(data['wilaya_name']!, _wilayaNameMeta),
      );
    }
    if (data.containsKey('wilaya_name_ar')) {
      context.handle(
        _wilayaNameArMeta,
        wilayaNameAr.isAcceptableOrUnknown(
          data['wilaya_name_ar']!,
          _wilayaNameArMeta,
        ),
      );
    }
    if (data.containsKey('commune')) {
      context.handle(
        _communeMeta,
        commune.isAcceptableOrUnknown(data['commune']!, _communeMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
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
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    }
    if (data.containsKey('cost_price')) {
      context.handle(
        _costPriceMeta,
        costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta),
      );
    }
    if (data.containsKey('delivery_price')) {
      context.handle(
        _deliveryPriceMeta,
        deliveryPrice.isAcceptableOrUnknown(
          data['delivery_price']!,
          _deliveryPriceMeta,
        ),
      );
    }
    if (data.containsKey('delivery_type')) {
      context.handle(
        _deliveryTypeMeta,
        deliveryType.isAcceptableOrUnknown(
          data['delivery_type']!,
          _deliveryTypeMeta,
        ),
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
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
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
        DriftSqlType.string,
        data['${effectivePrefix}wilaya_code'],
      )!,
      wilayaName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wilaya_name'],
      )!,
      wilayaNameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}wilaya_name_ar'],
      )!,
      commune: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}commune'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      costPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_price'],
      )!,
      deliveryPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}delivery_price'],
      )!,
      deliveryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_type'],
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
      ),
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class Order extends DataClass implements Insertable<Order> {
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
  final String deliveryType;
  final String status;
  final String deliveryCompany;
  final String trackingNumber;
  final bool codPaidByCompany;
  final String notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
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
    required this.deliveryType,
    required this.status,
    required this.deliveryCompany,
    required this.trackingNumber,
    required this.codPaidByCompany,
    required this.notes,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['reference'] = Variable<String>(reference);
    map['customer_name'] = Variable<String>(customerName);
    map['phone'] = Variable<String>(phone);
    map['wilaya_code'] = Variable<String>(wilayaCode);
    map['wilaya_name'] = Variable<String>(wilayaName);
    map['wilaya_name_ar'] = Variable<String>(wilayaNameAr);
    map['commune'] = Variable<String>(commune);
    map['address'] = Variable<String>(address);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['cost_price'] = Variable<double>(costPrice);
    map['delivery_price'] = Variable<double>(deliveryPrice);
    map['delivery_type'] = Variable<String>(deliveryType);
    map['status'] = Variable<String>(status);
    map['delivery_company'] = Variable<String>(deliveryCompany);
    map['tracking_number'] = Variable<String>(trackingNumber);
    map['cod_paid_by_company'] = Variable<bool>(codPaidByCompany);
    map['notes'] = Variable<String>(notes);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      reference: Value(reference),
      customerName: Value(customerName),
      phone: Value(phone),
      wilayaCode: Value(wilayaCode),
      wilayaName: Value(wilayaName),
      wilayaNameAr: Value(wilayaNameAr),
      commune: Value(commune),
      address: Value(address),
      productId: Value(productId),
      productName: Value(productName),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      costPrice: Value(costPrice),
      deliveryPrice: Value(deliveryPrice),
      deliveryType: Value(deliveryType),
      status: Value(status),
      deliveryCompany: Value(deliveryCompany),
      trackingNumber: Value(trackingNumber),
      codPaidByCompany: Value(codPaidByCompany),
      notes: Value(notes),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory Order.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<String>(json['id']),
      reference: serializer.fromJson<String>(json['reference']),
      customerName: serializer.fromJson<String>(json['customerName']),
      phone: serializer.fromJson<String>(json['phone']),
      wilayaCode: serializer.fromJson<String>(json['wilayaCode']),
      wilayaName: serializer.fromJson<String>(json['wilayaName']),
      wilayaNameAr: serializer.fromJson<String>(json['wilayaNameAr']),
      commune: serializer.fromJson<String>(json['commune']),
      address: serializer.fromJson<String>(json['address']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
      deliveryPrice: serializer.fromJson<double>(json['deliveryPrice']),
      deliveryType: serializer.fromJson<String>(json['deliveryType']),
      status: serializer.fromJson<String>(json['status']),
      deliveryCompany: serializer.fromJson<String>(json['deliveryCompany']),
      trackingNumber: serializer.fromJson<String>(json['trackingNumber']),
      codPaidByCompany: serializer.fromJson<bool>(json['codPaidByCompany']),
      notes: serializer.fromJson<String>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reference': serializer.toJson<String>(reference),
      'customerName': serializer.toJson<String>(customerName),
      'phone': serializer.toJson<String>(phone),
      'wilayaCode': serializer.toJson<String>(wilayaCode),
      'wilayaName': serializer.toJson<String>(wilayaName),
      'wilayaNameAr': serializer.toJson<String>(wilayaNameAr),
      'commune': serializer.toJson<String>(commune),
      'address': serializer.toJson<String>(address),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'costPrice': serializer.toJson<double>(costPrice),
      'deliveryPrice': serializer.toJson<double>(deliveryPrice),
      'deliveryType': serializer.toJson<String>(deliveryType),
      'status': serializer.toJson<String>(status),
      'deliveryCompany': serializer.toJson<String>(deliveryCompany),
      'trackingNumber': serializer.toJson<String>(trackingNumber),
      'codPaidByCompany': serializer.toJson<bool>(codPaidByCompany),
      'notes': serializer.toJson<String>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  Order copyWith({
    String? id,
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
    String? deliveryType,
    String? status,
    String? deliveryCompany,
    String? trackingNumber,
    bool? codPaidByCompany,
    String? notes,
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => Order(
    id: id ?? this.id,
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
    deliveryType: deliveryType ?? this.deliveryType,
    status: status ?? this.status,
    deliveryCompany: deliveryCompany ?? this.deliveryCompany,
    trackingNumber: trackingNumber ?? this.trackingNumber,
    codPaidByCompany: codPaidByCompany ?? this.codPaidByCompany,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      id: data.id.present ? data.id.value : this.id,
      reference: data.reference.present ? data.reference.value : this.reference,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      phone: data.phone.present ? data.phone.value : this.phone,
      wilayaCode: data.wilayaCode.present
          ? data.wilayaCode.value
          : this.wilayaCode,
      wilayaName: data.wilayaName.present
          ? data.wilayaName.value
          : this.wilayaName,
      wilayaNameAr: data.wilayaNameAr.present
          ? data.wilayaNameAr.value
          : this.wilayaNameAr,
      commune: data.commune.present ? data.commune.value : this.commune,
      address: data.address.present ? data.address.value : this.address,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      deliveryPrice: data.deliveryPrice.present
          ? data.deliveryPrice.value
          : this.deliveryPrice,
      deliveryType: data.deliveryType.present
          ? data.deliveryType.value
          : this.deliveryType,
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
          ..write('reference: $reference, ')
          ..write('customerName: $customerName, ')
          ..write('phone: $phone, ')
          ..write('wilayaCode: $wilayaCode, ')
          ..write('wilayaName: $wilayaName, ')
          ..write('wilayaNameAr: $wilayaNameAr, ')
          ..write('commune: $commune, ')
          ..write('address: $address, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('costPrice: $costPrice, ')
          ..write('deliveryPrice: $deliveryPrice, ')
          ..write('deliveryType: $deliveryType, ')
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
    reference,
    customerName,
    phone,
    wilayaCode,
    wilayaName,
    wilayaNameAr,
    commune,
    address,
    productId,
    productName,
    quantity,
    unitPrice,
    costPrice,
    deliveryPrice,
    deliveryType,
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
          other.reference == this.reference &&
          other.customerName == this.customerName &&
          other.phone == this.phone &&
          other.wilayaCode == this.wilayaCode &&
          other.wilayaName == this.wilayaName &&
          other.wilayaNameAr == this.wilayaNameAr &&
          other.commune == this.commune &&
          other.address == this.address &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.costPrice == this.costPrice &&
          other.deliveryPrice == this.deliveryPrice &&
          other.deliveryType == this.deliveryType &&
          other.status == this.status &&
          other.deliveryCompany == this.deliveryCompany &&
          other.trackingNumber == this.trackingNumber &&
          other.codPaidByCompany == this.codPaidByCompany &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<String> id;
  final Value<String> reference;
  final Value<String> customerName;
  final Value<String> phone;
  final Value<String> wilayaCode;
  final Value<String> wilayaName;
  final Value<String> wilayaNameAr;
  final Value<String> commune;
  final Value<String> address;
  final Value<String> productId;
  final Value<String> productName;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> costPrice;
  final Value<double> deliveryPrice;
  final Value<String> deliveryType;
  final Value<String> status;
  final Value<String> deliveryCompany;
  final Value<String> trackingNumber;
  final Value<bool> codPaidByCompany;
  final Value<String> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.reference = const Value.absent(),
    this.customerName = const Value.absent(),
    this.phone = const Value.absent(),
    this.wilayaCode = const Value.absent(),
    this.wilayaName = const Value.absent(),
    this.wilayaNameAr = const Value.absent(),
    this.commune = const Value.absent(),
    this.address = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.deliveryPrice = const Value.absent(),
    this.deliveryType = const Value.absent(),
    this.status = const Value.absent(),
    this.deliveryCompany = const Value.absent(),
    this.trackingNumber = const Value.absent(),
    this.codPaidByCompany = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrdersCompanion.insert({
    required String id,
    this.reference = const Value.absent(),
    required String customerName,
    required String phone,
    this.wilayaCode = const Value.absent(),
    this.wilayaName = const Value.absent(),
    this.wilayaNameAr = const Value.absent(),
    this.commune = const Value.absent(),
    this.address = const Value.absent(),
    this.productId = const Value.absent(),
    required String productName,
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.deliveryPrice = const Value.absent(),
    this.deliveryType = const Value.absent(),
    this.status = const Value.absent(),
    this.deliveryCompany = const Value.absent(),
    this.trackingNumber = const Value.absent(),
    this.codPaidByCompany = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerName = Value(customerName),
       phone = Value(phone),
       productName = Value(productName),
       createdAt = Value(createdAt);
  static Insertable<Order> custom({
    Expression<String>? id,
    Expression<String>? reference,
    Expression<String>? customerName,
    Expression<String>? phone,
    Expression<String>? wilayaCode,
    Expression<String>? wilayaName,
    Expression<String>? wilayaNameAr,
    Expression<String>? commune,
    Expression<String>? address,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? costPrice,
    Expression<double>? deliveryPrice,
    Expression<String>? deliveryType,
    Expression<String>? status,
    Expression<String>? deliveryCompany,
    Expression<String>? trackingNumber,
    Expression<bool>? codPaidByCompany,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reference != null) 'reference': reference,
      if (customerName != null) 'customer_name': customerName,
      if (phone != null) 'phone': phone,
      if (wilayaCode != null) 'wilaya_code': wilayaCode,
      if (wilayaName != null) 'wilaya_name': wilayaName,
      if (wilayaNameAr != null) 'wilaya_name_ar': wilayaNameAr,
      if (commune != null) 'commune': commune,
      if (address != null) 'address': address,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (costPrice != null) 'cost_price': costPrice,
      if (deliveryPrice != null) 'delivery_price': deliveryPrice,
      if (deliveryType != null) 'delivery_type': deliveryType,
      if (status != null) 'status': status,
      if (deliveryCompany != null) 'delivery_company': deliveryCompany,
      if (trackingNumber != null) 'tracking_number': trackingNumber,
      if (codPaidByCompany != null) 'cod_paid_by_company': codPaidByCompany,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrdersCompanion copyWith({
    Value<String>? id,
    Value<String>? reference,
    Value<String>? customerName,
    Value<String>? phone,
    Value<String>? wilayaCode,
    Value<String>? wilayaName,
    Value<String>? wilayaNameAr,
    Value<String>? commune,
    Value<String>? address,
    Value<String>? productId,
    Value<String>? productName,
    Value<int>? quantity,
    Value<double>? unitPrice,
    Value<double>? costPrice,
    Value<double>? deliveryPrice,
    Value<String>? deliveryType,
    Value<String>? status,
    Value<String>? deliveryCompany,
    Value<String>? trackingNumber,
    Value<bool>? codPaidByCompany,
    Value<String>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return OrdersCompanion(
      id: id ?? this.id,
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
      deliveryType: deliveryType ?? this.deliveryType,
      status: status ?? this.status,
      deliveryCompany: deliveryCompany ?? this.deliveryCompany,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      codPaidByCompany: codPaidByCompany ?? this.codPaidByCompany,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (wilayaCode.present) {
      map['wilaya_code'] = Variable<String>(wilayaCode.value);
    }
    if (wilayaName.present) {
      map['wilaya_name'] = Variable<String>(wilayaName.value);
    }
    if (wilayaNameAr.present) {
      map['wilaya_name_ar'] = Variable<String>(wilayaNameAr.value);
    }
    if (commune.present) {
      map['commune'] = Variable<String>(commune.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (deliveryPrice.present) {
      map['delivery_price'] = Variable<double>(deliveryPrice.value);
    }
    if (deliveryType.present) {
      map['delivery_type'] = Variable<String>(deliveryType.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('reference: $reference, ')
          ..write('customerName: $customerName, ')
          ..write('phone: $phone, ')
          ..write('wilayaCode: $wilayaCode, ')
          ..write('wilayaName: $wilayaName, ')
          ..write('wilayaNameAr: $wilayaNameAr, ')
          ..write('commune: $commune, ')
          ..write('address: $address, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('costPrice: $costPrice, ')
          ..write('deliveryPrice: $deliveryPrice, ')
          ..write('deliveryType: $deliveryType, ')
          ..write('status: $status, ')
          ..write('deliveryCompany: $deliveryCompany, ')
          ..write('trackingNumber: $trackingNumber, ')
          ..write('codPaidByCompany: $codPaidByCompany, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
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
  required String id,
  required String name,
  Value<double> price,
  Value<double> cost,
  Value<int> stock,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double> price,
  Value<double> cost,
  Value<int> stock,
  Value<DateTime> createdAt,
  Value<int> rowid,
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
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

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
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                name: name,
                price: price,
                cost: cost,
                stock: stock,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<double> price = const Value.absent(),
                Value<double> cost = const Value.absent(),
                Value<int> stock = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                id: id,
                name: name,
                price: price,
                cost: cost,
                stock: stock,
                createdAt: createdAt,
                rowid: rowid,
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
  required String id,
  Value<String> reference,
  required String customerName,
  required String phone,
  Value<String> wilayaCode,
  Value<String> wilayaName,
  Value<String> wilayaNameAr,
  Value<String> commune,
  Value<String> address,
  Value<String> productId,
  required String productName,
  Value<int> quantity,
  Value<double> unitPrice,
  Value<double> costPrice,
  Value<double> deliveryPrice,
  Value<String> deliveryType,
  Value<String> status,
  Value<String> deliveryCompany,
  Value<String> trackingNumber,
  Value<bool> codPaidByCompany,
  Value<String> notes,
  required DateTime createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<String> id,
  Value<String> reference,
  Value<String> customerName,
  Value<String> phone,
  Value<String> wilayaCode,
  Value<String> wilayaName,
  Value<String> wilayaNameAr,
  Value<String> commune,
  Value<String> address,
  Value<String> productId,
  Value<String> productName,
  Value<int> quantity,
  Value<double> unitPrice,
  Value<double> costPrice,
  Value<double> deliveryPrice,
  Value<String> deliveryType,
  Value<String> status,
  Value<String> deliveryCompany,
  Value<String> trackingNumber,
  Value<bool> codPaidByCompany,
  Value<String> notes,
  Value<DateTime> createdAt,
  Value<DateTime?> updatedAt,
  Value<int> rowid,
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
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
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

  ColumnFilters<String> get wilayaCode => $composableBuilder(
    column: $table.wilayaCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wilayaName => $composableBuilder(
    column: $table.wilayaName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get wilayaNameAr => $composableBuilder(
    column: $table.wilayaNameAr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commune => $composableBuilder(
    column: $table.commune,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
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

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get deliveryPrice => $composableBuilder(
    column: $table.deliveryPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryType => $composableBuilder(
    column: $table.deliveryType,
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
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

  ColumnOrderings<String> get wilayaCode => $composableBuilder(
    column: $table.wilayaCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wilayaName => $composableBuilder(
    column: $table.wilayaName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get wilayaNameAr => $composableBuilder(
    column: $table.wilayaNameAr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commune => $composableBuilder(
    column: $table.commune,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
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

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costPrice => $composableBuilder(
    column: $table.costPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get deliveryPrice => $composableBuilder(
    column: $table.deliveryPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryType => $composableBuilder(
    column: $table.deliveryType,
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
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get wilayaCode => $composableBuilder(
    column: $table.wilayaCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wilayaName => $composableBuilder(
    column: $table.wilayaName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get wilayaNameAr => $composableBuilder(
    column: $table.wilayaNameAr,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commune =>
      $composableBuilder(column: $table.commune, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<double> get deliveryPrice => $composableBuilder(
    column: $table.deliveryPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryType => $composableBuilder(
    column: $table.deliveryType,
    builder: (column) => column,
  );

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
                Value<String> id = const Value.absent(),
                Value<String> reference = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> wilayaCode = const Value.absent(),
                Value<String> wilayaName = const Value.absent(),
                Value<String> wilayaNameAr = const Value.absent(),
                Value<String> commune = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> costPrice = const Value.absent(),
                Value<double> deliveryPrice = const Value.absent(),
                Value<String> deliveryType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> deliveryCompany = const Value.absent(),
                Value<String> trackingNumber = const Value.absent(),
                Value<bool> codPaidByCompany = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion(
                id: id,
                reference: reference,
                customerName: customerName,
                phone: phone,
                wilayaCode: wilayaCode,
                wilayaName: wilayaName,
                wilayaNameAr: wilayaNameAr,
                commune: commune,
                address: address,
                productId: productId,
                productName: productName,
                quantity: quantity,
                unitPrice: unitPrice,
                costPrice: costPrice,
                deliveryPrice: deliveryPrice,
                deliveryType: deliveryType,
                status: status,
                deliveryCompany: deliveryCompany,
                trackingNumber: trackingNumber,
                codPaidByCompany: codPaidByCompany,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> reference = const Value.absent(),
                required String customerName,
                required String phone,
                Value<String> wilayaCode = const Value.absent(),
                Value<String> wilayaName = const Value.absent(),
                Value<String> wilayaNameAr = const Value.absent(),
                Value<String> commune = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> productId = const Value.absent(),
                required String productName,
                Value<int> quantity = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> costPrice = const Value.absent(),
                Value<double> deliveryPrice = const Value.absent(),
                Value<String> deliveryType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> deliveryCompany = const Value.absent(),
                Value<String> trackingNumber = const Value.absent(),
                Value<bool> codPaidByCompany = const Value.absent(),
                Value<String> notes = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrdersCompanion.insert(
                id: id,
                reference: reference,
                customerName: customerName,
                phone: phone,
                wilayaCode: wilayaCode,
                wilayaName: wilayaName,
                wilayaNameAr: wilayaNameAr,
                commune: commune,
                address: address,
                productId: productId,
                productName: productName,
                quantity: quantity,
                unitPrice: unitPrice,
                costPrice: costPrice,
                deliveryPrice: deliveryPrice,
                deliveryType: deliveryType,
                status: status,
                deliveryCompany: deliveryCompany,
                trackingNumber: trackingNumber,
                codPaidByCompany: codPaidByCompany,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
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
