// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kitchen_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

KitchenOrder _$KitchenOrderFromJson(Map<String, dynamic> json) {
  return _KitchenOrder.fromJson(json);
}

/// @nodoc
mixin _$KitchenOrder {
  String get id => throw _privateConstructorUsedError;
  String get orderNumber => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  FulfillmentType get deliveryMethod => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<KitchenOrderItem> get items => throw _privateConstructorUsedError;

  /// Serializes this KitchenOrder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KitchenOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KitchenOrderCopyWith<KitchenOrder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KitchenOrderCopyWith<$Res> {
  factory $KitchenOrderCopyWith(
    KitchenOrder value,
    $Res Function(KitchenOrder) then,
  ) = _$KitchenOrderCopyWithImpl<$Res, KitchenOrder>;
  @useResult
  $Res call({
    String id,
    String orderNumber,
    OrderStatus status,
    FulfillmentType deliveryMethod,
    DateTime createdAt,
    List<KitchenOrderItem> items,
  });
}

/// @nodoc
class _$KitchenOrderCopyWithImpl<$Res, $Val extends KitchenOrder>
    implements $KitchenOrderCopyWith<$Res> {
  _$KitchenOrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KitchenOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? status = null,
    Object? deliveryMethod = null,
    Object? createdAt = null,
    Object? items = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderNumber: null == orderNumber
                ? _value.orderNumber
                : orderNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OrderStatus,
            deliveryMethod: null == deliveryMethod
                ? _value.deliveryMethod
                : deliveryMethod // ignore: cast_nullable_to_non_nullable
                      as FulfillmentType,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<KitchenOrderItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KitchenOrderImplCopyWith<$Res>
    implements $KitchenOrderCopyWith<$Res> {
  factory _$$KitchenOrderImplCopyWith(
    _$KitchenOrderImpl value,
    $Res Function(_$KitchenOrderImpl) then,
  ) = __$$KitchenOrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderNumber,
    OrderStatus status,
    FulfillmentType deliveryMethod,
    DateTime createdAt,
    List<KitchenOrderItem> items,
  });
}

/// @nodoc
class __$$KitchenOrderImplCopyWithImpl<$Res>
    extends _$KitchenOrderCopyWithImpl<$Res, _$KitchenOrderImpl>
    implements _$$KitchenOrderImplCopyWith<$Res> {
  __$$KitchenOrderImplCopyWithImpl(
    _$KitchenOrderImpl _value,
    $Res Function(_$KitchenOrderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KitchenOrder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? status = null,
    Object? deliveryMethod = null,
    Object? createdAt = null,
    Object? items = null,
  }) {
    return _then(
      _$KitchenOrderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderNumber: null == orderNumber
            ? _value.orderNumber
            : orderNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OrderStatus,
        deliveryMethod: null == deliveryMethod
            ? _value.deliveryMethod
            : deliveryMethod // ignore: cast_nullable_to_non_nullable
                  as FulfillmentType,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<KitchenOrderItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KitchenOrderImpl implements _KitchenOrder {
  const _$KitchenOrderImpl({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.deliveryMethod,
    required this.createdAt,
    required final List<KitchenOrderItem> items,
  }) : _items = items;

  factory _$KitchenOrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$KitchenOrderImplFromJson(json);

  @override
  final String id;
  @override
  final String orderNumber;
  @override
  final OrderStatus status;
  @override
  final FulfillmentType deliveryMethod;
  @override
  final DateTime createdAt;
  final List<KitchenOrderItem> _items;
  @override
  List<KitchenOrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'KitchenOrder(id: $id, orderNumber: $orderNumber, status: $status, deliveryMethod: $deliveryMethod, createdAt: $createdAt, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KitchenOrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.deliveryMethod, deliveryMethod) ||
                other.deliveryMethod == deliveryMethod) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderNumber,
    status,
    deliveryMethod,
    createdAt,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of KitchenOrder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KitchenOrderImplCopyWith<_$KitchenOrderImpl> get copyWith =>
      __$$KitchenOrderImplCopyWithImpl<_$KitchenOrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KitchenOrderImplToJson(this);
  }
}

abstract class _KitchenOrder implements KitchenOrder {
  const factory _KitchenOrder({
    required final String id,
    required final String orderNumber,
    required final OrderStatus status,
    required final FulfillmentType deliveryMethod,
    required final DateTime createdAt,
    required final List<KitchenOrderItem> items,
  }) = _$KitchenOrderImpl;

  factory _KitchenOrder.fromJson(Map<String, dynamic> json) =
      _$KitchenOrderImpl.fromJson;

  @override
  String get id;
  @override
  String get orderNumber;
  @override
  OrderStatus get status;
  @override
  FulfillmentType get deliveryMethod;
  @override
  DateTime get createdAt;
  @override
  List<KitchenOrderItem> get items;

  /// Create a copy of KitchenOrder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KitchenOrderImplCopyWith<_$KitchenOrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KitchenOrderItem _$KitchenOrderItemFromJson(Map<String, dynamic> json) {
  return _KitchenOrderItem.fromJson(json);
}

/// @nodoc
mixin _$KitchenOrderItem {
  String get id =>
      throw _privateConstructorUsedError; // Live MenuItem id — nullable the same way OrderItem.menuItemId is
  // (see order.dart's doc comment): null for a hard-deleted item. Not
  // used for anything on this screen today (no reorder/detail-link
  // action here), kept only in case that changes.
  String? get menuItemId => throw _privateConstructorUsedError;
  String get nameAr => throw _privateConstructorUsedError;
  String get nameEn => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  KitchenCustomizationSnapshot? get selectedVariant =>
      throw _privateConstructorUsedError;
  List<KitchenCustomizationSnapshot> get selectedAddons =>
      throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  String? get specialInstructions => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  double get totalPrice => throw _privateConstructorUsedError;

  /// Serializes this KitchenOrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KitchenOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KitchenOrderItemCopyWith<KitchenOrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KitchenOrderItemCopyWith<$Res> {
  factory $KitchenOrderItemCopyWith(
    KitchenOrderItem value,
    $Res Function(KitchenOrderItem) then,
  ) = _$KitchenOrderItemCopyWithImpl<$Res, KitchenOrderItem>;
  @useResult
  $Res call({
    String id,
    String? menuItemId,
    String nameAr,
    String nameEn,
    String? imageUrl,
    KitchenCustomizationSnapshot? selectedVariant,
    List<KitchenCustomizationSnapshot> selectedAddons,
    int quantity,
    String? specialInstructions,
    double unitPrice,
    double totalPrice,
  });

  $KitchenCustomizationSnapshotCopyWith<$Res>? get selectedVariant;
}

/// @nodoc
class _$KitchenOrderItemCopyWithImpl<$Res, $Val extends KitchenOrderItem>
    implements $KitchenOrderItemCopyWith<$Res> {
  _$KitchenOrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KitchenOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = freezed,
    Object? nameAr = null,
    Object? nameEn = null,
    Object? imageUrl = freezed,
    Object? selectedVariant = freezed,
    Object? selectedAddons = null,
    Object? quantity = null,
    Object? specialInstructions = freezed,
    Object? unitPrice = null,
    Object? totalPrice = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            menuItemId: freezed == menuItemId
                ? _value.menuItemId
                : menuItemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            nameAr: null == nameAr
                ? _value.nameAr
                : nameAr // ignore: cast_nullable_to_non_nullable
                      as String,
            nameEn: null == nameEn
                ? _value.nameEn
                : nameEn // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            selectedVariant: freezed == selectedVariant
                ? _value.selectedVariant
                : selectedVariant // ignore: cast_nullable_to_non_nullable
                      as KitchenCustomizationSnapshot?,
            selectedAddons: null == selectedAddons
                ? _value.selectedAddons
                : selectedAddons // ignore: cast_nullable_to_non_nullable
                      as List<KitchenCustomizationSnapshot>,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            specialInstructions: freezed == specialInstructions
                ? _value.specialInstructions
                : specialInstructions // ignore: cast_nullable_to_non_nullable
                      as String?,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            totalPrice: null == totalPrice
                ? _value.totalPrice
                : totalPrice // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }

  /// Create a copy of KitchenOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $KitchenCustomizationSnapshotCopyWith<$Res>? get selectedVariant {
    if (_value.selectedVariant == null) {
      return null;
    }

    return $KitchenCustomizationSnapshotCopyWith<$Res>(
      _value.selectedVariant!,
      (value) {
        return _then(_value.copyWith(selectedVariant: value) as $Val);
      },
    );
  }
}

/// @nodoc
abstract class _$$KitchenOrderItemImplCopyWith<$Res>
    implements $KitchenOrderItemCopyWith<$Res> {
  factory _$$KitchenOrderItemImplCopyWith(
    _$KitchenOrderItemImpl value,
    $Res Function(_$KitchenOrderItemImpl) then,
  ) = __$$KitchenOrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? menuItemId,
    String nameAr,
    String nameEn,
    String? imageUrl,
    KitchenCustomizationSnapshot? selectedVariant,
    List<KitchenCustomizationSnapshot> selectedAddons,
    int quantity,
    String? specialInstructions,
    double unitPrice,
    double totalPrice,
  });

  @override
  $KitchenCustomizationSnapshotCopyWith<$Res>? get selectedVariant;
}

/// @nodoc
class __$$KitchenOrderItemImplCopyWithImpl<$Res>
    extends _$KitchenOrderItemCopyWithImpl<$Res, _$KitchenOrderItemImpl>
    implements _$$KitchenOrderItemImplCopyWith<$Res> {
  __$$KitchenOrderItemImplCopyWithImpl(
    _$KitchenOrderItemImpl _value,
    $Res Function(_$KitchenOrderItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KitchenOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = freezed,
    Object? nameAr = null,
    Object? nameEn = null,
    Object? imageUrl = freezed,
    Object? selectedVariant = freezed,
    Object? selectedAddons = null,
    Object? quantity = null,
    Object? specialInstructions = freezed,
    Object? unitPrice = null,
    Object? totalPrice = null,
  }) {
    return _then(
      _$KitchenOrderItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        menuItemId: freezed == menuItemId
            ? _value.menuItemId
            : menuItemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameAr: null == nameAr
            ? _value.nameAr
            : nameAr // ignore: cast_nullable_to_non_nullable
                  as String,
        nameEn: null == nameEn
            ? _value.nameEn
            : nameEn // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedVariant: freezed == selectedVariant
            ? _value.selectedVariant
            : selectedVariant // ignore: cast_nullable_to_non_nullable
                  as KitchenCustomizationSnapshot?,
        selectedAddons: null == selectedAddons
            ? _value._selectedAddons
            : selectedAddons // ignore: cast_nullable_to_non_nullable
                  as List<KitchenCustomizationSnapshot>,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        specialInstructions: freezed == specialInstructions
            ? _value.specialInstructions
            : specialInstructions // ignore: cast_nullable_to_non_nullable
                  as String?,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        totalPrice: null == totalPrice
            ? _value.totalPrice
            : totalPrice // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KitchenOrderItemImpl implements _KitchenOrderItem {
  const _$KitchenOrderItemImpl({
    required this.id,
    this.menuItemId,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
    this.selectedVariant,
    final List<KitchenCustomizationSnapshot> selectedAddons = const [],
    required this.quantity,
    this.specialInstructions,
    required this.unitPrice,
    required this.totalPrice,
  }) : _selectedAddons = selectedAddons;

  factory _$KitchenOrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$KitchenOrderItemImplFromJson(json);

  @override
  final String id;
  // Live MenuItem id — nullable the same way OrderItem.menuItemId is
  // (see order.dart's doc comment): null for a hard-deleted item. Not
  // used for anything on this screen today (no reorder/detail-link
  // action here), kept only in case that changes.
  @override
  final String? menuItemId;
  @override
  final String nameAr;
  @override
  final String nameEn;
  @override
  final String? imageUrl;
  @override
  final KitchenCustomizationSnapshot? selectedVariant;
  final List<KitchenCustomizationSnapshot> _selectedAddons;
  @override
  @JsonKey()
  List<KitchenCustomizationSnapshot> get selectedAddons {
    if (_selectedAddons is EqualUnmodifiableListView) return _selectedAddons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedAddons);
  }

  @override
  final int quantity;
  @override
  final String? specialInstructions;
  @override
  final double unitPrice;
  @override
  final double totalPrice;

  @override
  String toString() {
    return 'KitchenOrderItem(id: $id, menuItemId: $menuItemId, nameAr: $nameAr, nameEn: $nameEn, imageUrl: $imageUrl, selectedVariant: $selectedVariant, selectedAddons: $selectedAddons, quantity: $quantity, specialInstructions: $specialInstructions, unitPrice: $unitPrice, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KitchenOrderItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.selectedVariant, selectedVariant) ||
                other.selectedVariant == selectedVariant) &&
            const DeepCollectionEquality().equals(
              other._selectedAddons,
              _selectedAddons,
            ) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.specialInstructions, specialInstructions) ||
                other.specialInstructions == specialInstructions) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    menuItemId,
    nameAr,
    nameEn,
    imageUrl,
    selectedVariant,
    const DeepCollectionEquality().hash(_selectedAddons),
    quantity,
    specialInstructions,
    unitPrice,
    totalPrice,
  );

  /// Create a copy of KitchenOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KitchenOrderItemImplCopyWith<_$KitchenOrderItemImpl> get copyWith =>
      __$$KitchenOrderItemImplCopyWithImpl<_$KitchenOrderItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$KitchenOrderItemImplToJson(this);
  }
}

abstract class _KitchenOrderItem implements KitchenOrderItem {
  const factory _KitchenOrderItem({
    required final String id,
    final String? menuItemId,
    required final String nameAr,
    required final String nameEn,
    final String? imageUrl,
    final KitchenCustomizationSnapshot? selectedVariant,
    final List<KitchenCustomizationSnapshot> selectedAddons,
    required final int quantity,
    final String? specialInstructions,
    required final double unitPrice,
    required final double totalPrice,
  }) = _$KitchenOrderItemImpl;

  factory _KitchenOrderItem.fromJson(Map<String, dynamic> json) =
      _$KitchenOrderItemImpl.fromJson;

  @override
  String get id; // Live MenuItem id — nullable the same way OrderItem.menuItemId is
  // (see order.dart's doc comment): null for a hard-deleted item. Not
  // used for anything on this screen today (no reorder/detail-link
  // action here), kept only in case that changes.
  @override
  String? get menuItemId;
  @override
  String get nameAr;
  @override
  String get nameEn;
  @override
  String? get imageUrl;
  @override
  KitchenCustomizationSnapshot? get selectedVariant;
  @override
  List<KitchenCustomizationSnapshot> get selectedAddons;
  @override
  int get quantity;
  @override
  String? get specialInstructions;
  @override
  double get unitPrice;
  @override
  double get totalPrice;

  /// Create a copy of KitchenOrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KitchenOrderItemImplCopyWith<_$KitchenOrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KitchenCustomizationSnapshot _$KitchenCustomizationSnapshotFromJson(
  Map<String, dynamic> json,
) {
  return _KitchenCustomizationSnapshot.fromJson(json);
}

/// @nodoc
mixin _$KitchenCustomizationSnapshot {
  String get id => throw _privateConstructorUsedError;
  String? get refId => throw _privateConstructorUsedError;
  String get nameAr => throw _privateConstructorUsedError;
  String get nameEn => throw _privateConstructorUsedError;
  double get priceSnapshot => throw _privateConstructorUsedError;

  /// Serializes this KitchenCustomizationSnapshot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KitchenCustomizationSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KitchenCustomizationSnapshotCopyWith<KitchenCustomizationSnapshot>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KitchenCustomizationSnapshotCopyWith<$Res> {
  factory $KitchenCustomizationSnapshotCopyWith(
    KitchenCustomizationSnapshot value,
    $Res Function(KitchenCustomizationSnapshot) then,
  ) =
      _$KitchenCustomizationSnapshotCopyWithImpl<
        $Res,
        KitchenCustomizationSnapshot
      >;
  @useResult
  $Res call({
    String id,
    String? refId,
    String nameAr,
    String nameEn,
    double priceSnapshot,
  });
}

/// @nodoc
class _$KitchenCustomizationSnapshotCopyWithImpl<
  $Res,
  $Val extends KitchenCustomizationSnapshot
>
    implements $KitchenCustomizationSnapshotCopyWith<$Res> {
  _$KitchenCustomizationSnapshotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KitchenCustomizationSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? refId = freezed,
    Object? nameAr = null,
    Object? nameEn = null,
    Object? priceSnapshot = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            refId: freezed == refId
                ? _value.refId
                : refId // ignore: cast_nullable_to_non_nullable
                      as String?,
            nameAr: null == nameAr
                ? _value.nameAr
                : nameAr // ignore: cast_nullable_to_non_nullable
                      as String,
            nameEn: null == nameEn
                ? _value.nameEn
                : nameEn // ignore: cast_nullable_to_non_nullable
                      as String,
            priceSnapshot: null == priceSnapshot
                ? _value.priceSnapshot
                : priceSnapshot // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KitchenCustomizationSnapshotImplCopyWith<$Res>
    implements $KitchenCustomizationSnapshotCopyWith<$Res> {
  factory _$$KitchenCustomizationSnapshotImplCopyWith(
    _$KitchenCustomizationSnapshotImpl value,
    $Res Function(_$KitchenCustomizationSnapshotImpl) then,
  ) = __$$KitchenCustomizationSnapshotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? refId,
    String nameAr,
    String nameEn,
    double priceSnapshot,
  });
}

/// @nodoc
class __$$KitchenCustomizationSnapshotImplCopyWithImpl<$Res>
    extends
        _$KitchenCustomizationSnapshotCopyWithImpl<
          $Res,
          _$KitchenCustomizationSnapshotImpl
        >
    implements _$$KitchenCustomizationSnapshotImplCopyWith<$Res> {
  __$$KitchenCustomizationSnapshotImplCopyWithImpl(
    _$KitchenCustomizationSnapshotImpl _value,
    $Res Function(_$KitchenCustomizationSnapshotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KitchenCustomizationSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? refId = freezed,
    Object? nameAr = null,
    Object? nameEn = null,
    Object? priceSnapshot = null,
  }) {
    return _then(
      _$KitchenCustomizationSnapshotImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        refId: freezed == refId
            ? _value.refId
            : refId // ignore: cast_nullable_to_non_nullable
                  as String?,
        nameAr: null == nameAr
            ? _value.nameAr
            : nameAr // ignore: cast_nullable_to_non_nullable
                  as String,
        nameEn: null == nameEn
            ? _value.nameEn
            : nameEn // ignore: cast_nullable_to_non_nullable
                  as String,
        priceSnapshot: null == priceSnapshot
            ? _value.priceSnapshot
            : priceSnapshot // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KitchenCustomizationSnapshotImpl
    implements _KitchenCustomizationSnapshot {
  const _$KitchenCustomizationSnapshotImpl({
    required this.id,
    this.refId,
    required this.nameAr,
    required this.nameEn,
    required this.priceSnapshot,
  });

  factory _$KitchenCustomizationSnapshotImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$KitchenCustomizationSnapshotImplFromJson(json);

  @override
  final String id;
  @override
  final String? refId;
  @override
  final String nameAr;
  @override
  final String nameEn;
  @override
  final double priceSnapshot;

  @override
  String toString() {
    return 'KitchenCustomizationSnapshot(id: $id, refId: $refId, nameAr: $nameAr, nameEn: $nameEn, priceSnapshot: $priceSnapshot)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KitchenCustomizationSnapshotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.refId, refId) || other.refId == refId) &&
            (identical(other.nameAr, nameAr) || other.nameAr == nameAr) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.priceSnapshot, priceSnapshot) ||
                other.priceSnapshot == priceSnapshot));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, refId, nameAr, nameEn, priceSnapshot);

  /// Create a copy of KitchenCustomizationSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KitchenCustomizationSnapshotImplCopyWith<
    _$KitchenCustomizationSnapshotImpl
  >
  get copyWith =>
      __$$KitchenCustomizationSnapshotImplCopyWithImpl<
        _$KitchenCustomizationSnapshotImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KitchenCustomizationSnapshotImplToJson(this);
  }
}

abstract class _KitchenCustomizationSnapshot
    implements KitchenCustomizationSnapshot {
  const factory _KitchenCustomizationSnapshot({
    required final String id,
    final String? refId,
    required final String nameAr,
    required final String nameEn,
    required final double priceSnapshot,
  }) = _$KitchenCustomizationSnapshotImpl;

  factory _KitchenCustomizationSnapshot.fromJson(Map<String, dynamic> json) =
      _$KitchenCustomizationSnapshotImpl.fromJson;

  @override
  String get id;
  @override
  String? get refId;
  @override
  String get nameAr;
  @override
  String get nameEn;
  @override
  double get priceSnapshot;

  /// Create a copy of KitchenCustomizationSnapshot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KitchenCustomizationSnapshotImplCopyWith<
    _$KitchenCustomizationSnapshotImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
