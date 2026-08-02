// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Order _$OrderFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

/// @nodoc
mixin _$Order {
  String get id => throw _privateConstructorUsedError;
  String get orderNumber => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get customerName => throw _privateConstructorUsedError;
  List<OrderItem> get items => throw _privateConstructorUsedError;
  FulfillmentType get fulfillmentType => throw _privateConstructorUsedError;
  String? get addressId => throw _privateConstructorUsedError;
  String? get pickupLocation =>
      throw _privateConstructorUsedError; // Immutable delivery-address snapshot taken at order placement time
  // (backend VO2.3) — null for pickup orders and for older orders placed
  // before the backend started returning this snapshot.
  OrderDeliveryAddress? get deliveryAddress =>
      throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get deliveryFee => throw _privateConstructorUsedError;
  double get discountTotal => throw _privateConstructorUsedError;
  int get loyaltyPointsUsed => throw _privateConstructorUsedError;
  int get loyaltyPointsEarned => throw _privateConstructorUsedError;
  double get grandTotal => throw _privateConstructorUsedError;
  String? get paymentId => throw _privateConstructorUsedError;
  String? get paymentStatus => throw _privateConstructorUsedError;
  String? get paymentMethod => throw _privateConstructorUsedError;
  DateTime get placedAt => throw _privateConstructorUsedError;
  List<OrderStatusEntry> get statusHistory =>
      throw _privateConstructorUsedError;
  String? get estimatedTime =>
      throw _privateConstructorUsedError; // Additive field on the checkout response only (03_DTO_REFERENCE.md) — null
  // when no loyalty reward was redeemed for this order (the normal case).
  LoyaltyRedemptionInfo? get loyaltyRedemption =>
      throw _privateConstructorUsedError;

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderCopyWith<Order> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) then) =
      _$OrderCopyWithImpl<$Res, Order>;
  @useResult
  $Res call({
    String id,
    String orderNumber,
    String userId,
    String? customerName,
    List<OrderItem> items,
    FulfillmentType fulfillmentType,
    String? addressId,
    String? pickupLocation,
    OrderDeliveryAddress? deliveryAddress,
    OrderStatus status,
    double subtotal,
    double deliveryFee,
    double discountTotal,
    int loyaltyPointsUsed,
    int loyaltyPointsEarned,
    double grandTotal,
    String? paymentId,
    String? paymentStatus,
    String? paymentMethod,
    DateTime placedAt,
    List<OrderStatusEntry> statusHistory,
    String? estimatedTime,
    LoyaltyRedemptionInfo? loyaltyRedemption,
  });

  $OrderDeliveryAddressCopyWith<$Res>? get deliveryAddress;
  $LoyaltyRedemptionInfoCopyWith<$Res>? get loyaltyRedemption;
}

/// @nodoc
class _$OrderCopyWithImpl<$Res, $Val extends Order>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? userId = null,
    Object? customerName = freezed,
    Object? items = null,
    Object? fulfillmentType = null,
    Object? addressId = freezed,
    Object? pickupLocation = freezed,
    Object? deliveryAddress = freezed,
    Object? status = null,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? discountTotal = null,
    Object? loyaltyPointsUsed = null,
    Object? loyaltyPointsEarned = null,
    Object? grandTotal = null,
    Object? paymentId = freezed,
    Object? paymentStatus = freezed,
    Object? paymentMethod = freezed,
    Object? placedAt = null,
    Object? statusHistory = null,
    Object? estimatedTime = freezed,
    Object? loyaltyRedemption = freezed,
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
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: freezed == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<OrderItem>,
            fulfillmentType: null == fulfillmentType
                ? _value.fulfillmentType
                : fulfillmentType // ignore: cast_nullable_to_non_nullable
                      as FulfillmentType,
            addressId: freezed == addressId
                ? _value.addressId
                : addressId // ignore: cast_nullable_to_non_nullable
                      as String?,
            pickupLocation: freezed == pickupLocation
                ? _value.pickupLocation
                : pickupLocation // ignore: cast_nullable_to_non_nullable
                      as String?,
            deliveryAddress: freezed == deliveryAddress
                ? _value.deliveryAddress
                : deliveryAddress // ignore: cast_nullable_to_non_nullable
                      as OrderDeliveryAddress?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OrderStatus,
            subtotal: null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                      as double,
            deliveryFee: null == deliveryFee
                ? _value.deliveryFee
                : deliveryFee // ignore: cast_nullable_to_non_nullable
                      as double,
            discountTotal: null == discountTotal
                ? _value.discountTotal
                : discountTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            loyaltyPointsUsed: null == loyaltyPointsUsed
                ? _value.loyaltyPointsUsed
                : loyaltyPointsUsed // ignore: cast_nullable_to_non_nullable
                      as int,
            loyaltyPointsEarned: null == loyaltyPointsEarned
                ? _value.loyaltyPointsEarned
                : loyaltyPointsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
            grandTotal: null == grandTotal
                ? _value.grandTotal
                : grandTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            paymentId: freezed == paymentId
                ? _value.paymentId
                : paymentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentStatus: freezed == paymentStatus
                ? _value.paymentStatus
                : paymentStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            paymentMethod: freezed == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            placedAt: null == placedAt
                ? _value.placedAt
                : placedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            statusHistory: null == statusHistory
                ? _value.statusHistory
                : statusHistory // ignore: cast_nullable_to_non_nullable
                      as List<OrderStatusEntry>,
            estimatedTime: freezed == estimatedTime
                ? _value.estimatedTime
                : estimatedTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            loyaltyRedemption: freezed == loyaltyRedemption
                ? _value.loyaltyRedemption
                : loyaltyRedemption // ignore: cast_nullable_to_non_nullable
                      as LoyaltyRedemptionInfo?,
          )
          as $Val,
    );
  }

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OrderDeliveryAddressCopyWith<$Res>? get deliveryAddress {
    if (_value.deliveryAddress == null) {
      return null;
    }

    return $OrderDeliveryAddressCopyWith<$Res>(_value.deliveryAddress!, (
      value,
    ) {
      return _then(_value.copyWith(deliveryAddress: value) as $Val);
    });
  }

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LoyaltyRedemptionInfoCopyWith<$Res>? get loyaltyRedemption {
    if (_value.loyaltyRedemption == null) {
      return null;
    }

    return $LoyaltyRedemptionInfoCopyWith<$Res>(_value.loyaltyRedemption!, (
      value,
    ) {
      return _then(_value.copyWith(loyaltyRedemption: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OrderImplCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$$OrderImplCopyWith(
    _$OrderImpl value,
    $Res Function(_$OrderImpl) then,
  ) = __$$OrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderNumber,
    String userId,
    String? customerName,
    List<OrderItem> items,
    FulfillmentType fulfillmentType,
    String? addressId,
    String? pickupLocation,
    OrderDeliveryAddress? deliveryAddress,
    OrderStatus status,
    double subtotal,
    double deliveryFee,
    double discountTotal,
    int loyaltyPointsUsed,
    int loyaltyPointsEarned,
    double grandTotal,
    String? paymentId,
    String? paymentStatus,
    String? paymentMethod,
    DateTime placedAt,
    List<OrderStatusEntry> statusHistory,
    String? estimatedTime,
    LoyaltyRedemptionInfo? loyaltyRedemption,
  });

  @override
  $OrderDeliveryAddressCopyWith<$Res>? get deliveryAddress;
  @override
  $LoyaltyRedemptionInfoCopyWith<$Res>? get loyaltyRedemption;
}

/// @nodoc
class __$$OrderImplCopyWithImpl<$Res>
    extends _$OrderCopyWithImpl<$Res, _$OrderImpl>
    implements _$$OrderImplCopyWith<$Res> {
  __$$OrderImplCopyWithImpl(
    _$OrderImpl _value,
    $Res Function(_$OrderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? userId = null,
    Object? customerName = freezed,
    Object? items = null,
    Object? fulfillmentType = null,
    Object? addressId = freezed,
    Object? pickupLocation = freezed,
    Object? deliveryAddress = freezed,
    Object? status = null,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? discountTotal = null,
    Object? loyaltyPointsUsed = null,
    Object? loyaltyPointsEarned = null,
    Object? grandTotal = null,
    Object? paymentId = freezed,
    Object? paymentStatus = freezed,
    Object? paymentMethod = freezed,
    Object? placedAt = null,
    Object? statusHistory = null,
    Object? estimatedTime = freezed,
    Object? loyaltyRedemption = freezed,
  }) {
    return _then(
      _$OrderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderNumber: null == orderNumber
            ? _value.orderNumber
            : orderNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: freezed == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<OrderItem>,
        fulfillmentType: null == fulfillmentType
            ? _value.fulfillmentType
            : fulfillmentType // ignore: cast_nullable_to_non_nullable
                  as FulfillmentType,
        addressId: freezed == addressId
            ? _value.addressId
            : addressId // ignore: cast_nullable_to_non_nullable
                  as String?,
        pickupLocation: freezed == pickupLocation
            ? _value.pickupLocation
            : pickupLocation // ignore: cast_nullable_to_non_nullable
                  as String?,
        deliveryAddress: freezed == deliveryAddress
            ? _value.deliveryAddress
            : deliveryAddress // ignore: cast_nullable_to_non_nullable
                  as OrderDeliveryAddress?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OrderStatus,
        subtotal: null == subtotal
            ? _value.subtotal
            : subtotal // ignore: cast_nullable_to_non_nullable
                  as double,
        deliveryFee: null == deliveryFee
            ? _value.deliveryFee
            : deliveryFee // ignore: cast_nullable_to_non_nullable
                  as double,
        discountTotal: null == discountTotal
            ? _value.discountTotal
            : discountTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        loyaltyPointsUsed: null == loyaltyPointsUsed
            ? _value.loyaltyPointsUsed
            : loyaltyPointsUsed // ignore: cast_nullable_to_non_nullable
                  as int,
        loyaltyPointsEarned: null == loyaltyPointsEarned
            ? _value.loyaltyPointsEarned
            : loyaltyPointsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
        grandTotal: null == grandTotal
            ? _value.grandTotal
            : grandTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        paymentId: freezed == paymentId
            ? _value.paymentId
            : paymentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentStatus: freezed == paymentStatus
            ? _value.paymentStatus
            : paymentStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        paymentMethod: freezed == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        placedAt: null == placedAt
            ? _value.placedAt
            : placedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        statusHistory: null == statusHistory
            ? _value._statusHistory
            : statusHistory // ignore: cast_nullable_to_non_nullable
                  as List<OrderStatusEntry>,
        estimatedTime: freezed == estimatedTime
            ? _value.estimatedTime
            : estimatedTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        loyaltyRedemption: freezed == loyaltyRedemption
            ? _value.loyaltyRedemption
            : loyaltyRedemption // ignore: cast_nullable_to_non_nullable
                  as LoyaltyRedemptionInfo?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderImpl implements _Order {
  const _$OrderImpl({
    required this.id,
    required this.orderNumber,
    required this.userId,
    this.customerName,
    required final List<OrderItem> items,
    required this.fulfillmentType,
    this.addressId,
    this.pickupLocation,
    this.deliveryAddress,
    required this.status,
    required this.subtotal,
    this.deliveryFee = 0.0,
    this.discountTotal = 0.0,
    this.loyaltyPointsUsed = 0,
    this.loyaltyPointsEarned = 0,
    required this.grandTotal,
    this.paymentId,
    this.paymentStatus,
    this.paymentMethod,
    required this.placedAt,
    final List<OrderStatusEntry> statusHistory = const [],
    this.estimatedTime,
    this.loyaltyRedemption,
  }) : _items = items,
       _statusHistory = statusHistory;

  factory _$OrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderImplFromJson(json);

  @override
  final String id;
  @override
  final String orderNumber;
  @override
  final String userId;
  @override
  final String? customerName;
  final List<OrderItem> _items;
  @override
  List<OrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final FulfillmentType fulfillmentType;
  @override
  final String? addressId;
  @override
  final String? pickupLocation;
  // Immutable delivery-address snapshot taken at order placement time
  // (backend VO2.3) — null for pickup orders and for older orders placed
  // before the backend started returning this snapshot.
  @override
  final OrderDeliveryAddress? deliveryAddress;
  @override
  final OrderStatus status;
  @override
  final double subtotal;
  @override
  @JsonKey()
  final double deliveryFee;
  @override
  @JsonKey()
  final double discountTotal;
  @override
  @JsonKey()
  final int loyaltyPointsUsed;
  @override
  @JsonKey()
  final int loyaltyPointsEarned;
  @override
  final double grandTotal;
  @override
  final String? paymentId;
  @override
  final String? paymentStatus;
  @override
  final String? paymentMethod;
  @override
  final DateTime placedAt;
  final List<OrderStatusEntry> _statusHistory;
  @override
  @JsonKey()
  List<OrderStatusEntry> get statusHistory {
    if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statusHistory);
  }

  @override
  final String? estimatedTime;
  // Additive field on the checkout response only (03_DTO_REFERENCE.md) — null
  // when no loyalty reward was redeemed for this order (the normal case).
  @override
  final LoyaltyRedemptionInfo? loyaltyRedemption;

  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, userId: $userId, customerName: $customerName, items: $items, fulfillmentType: $fulfillmentType, addressId: $addressId, pickupLocation: $pickupLocation, deliveryAddress: $deliveryAddress, status: $status, subtotal: $subtotal, deliveryFee: $deliveryFee, discountTotal: $discountTotal, loyaltyPointsUsed: $loyaltyPointsUsed, loyaltyPointsEarned: $loyaltyPointsEarned, grandTotal: $grandTotal, paymentId: $paymentId, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, placedAt: $placedAt, statusHistory: $statusHistory, estimatedTime: $estimatedTime, loyaltyRedemption: $loyaltyRedemption)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.fulfillmentType, fulfillmentType) ||
                other.fulfillmentType == fulfillmentType) &&
            (identical(other.addressId, addressId) ||
                other.addressId == addressId) &&
            (identical(other.pickupLocation, pickupLocation) ||
                other.pickupLocation == pickupLocation) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.discountTotal, discountTotal) ||
                other.discountTotal == discountTotal) &&
            (identical(other.loyaltyPointsUsed, loyaltyPointsUsed) ||
                other.loyaltyPointsUsed == loyaltyPointsUsed) &&
            (identical(other.loyaltyPointsEarned, loyaltyPointsEarned) ||
                other.loyaltyPointsEarned == loyaltyPointsEarned) &&
            (identical(other.grandTotal, grandTotal) ||
                other.grandTotal == grandTotal) &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.placedAt, placedAt) ||
                other.placedAt == placedAt) &&
            const DeepCollectionEquality().equals(
              other._statusHistory,
              _statusHistory,
            ) &&
            (identical(other.estimatedTime, estimatedTime) ||
                other.estimatedTime == estimatedTime) &&
            (identical(other.loyaltyRedemption, loyaltyRedemption) ||
                other.loyaltyRedemption == loyaltyRedemption));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    orderNumber,
    userId,
    customerName,
    const DeepCollectionEquality().hash(_items),
    fulfillmentType,
    addressId,
    pickupLocation,
    deliveryAddress,
    status,
    subtotal,
    deliveryFee,
    discountTotal,
    loyaltyPointsUsed,
    loyaltyPointsEarned,
    grandTotal,
    paymentId,
    paymentStatus,
    paymentMethod,
    placedAt,
    const DeepCollectionEquality().hash(_statusHistory),
    estimatedTime,
    loyaltyRedemption,
  ]);

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      __$$OrderImplCopyWithImpl<_$OrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderImplToJson(this);
  }
}

abstract class _Order implements Order {
  const factory _Order({
    required final String id,
    required final String orderNumber,
    required final String userId,
    final String? customerName,
    required final List<OrderItem> items,
    required final FulfillmentType fulfillmentType,
    final String? addressId,
    final String? pickupLocation,
    final OrderDeliveryAddress? deliveryAddress,
    required final OrderStatus status,
    required final double subtotal,
    final double deliveryFee,
    final double discountTotal,
    final int loyaltyPointsUsed,
    final int loyaltyPointsEarned,
    required final double grandTotal,
    final String? paymentId,
    final String? paymentStatus,
    final String? paymentMethod,
    required final DateTime placedAt,
    final List<OrderStatusEntry> statusHistory,
    final String? estimatedTime,
    final LoyaltyRedemptionInfo? loyaltyRedemption,
  }) = _$OrderImpl;

  factory _Order.fromJson(Map<String, dynamic> json) = _$OrderImpl.fromJson;

  @override
  String get id;
  @override
  String get orderNumber;
  @override
  String get userId;
  @override
  String? get customerName;
  @override
  List<OrderItem> get items;
  @override
  FulfillmentType get fulfillmentType;
  @override
  String? get addressId;
  @override
  String? get pickupLocation; // Immutable delivery-address snapshot taken at order placement time
  // (backend VO2.3) — null for pickup orders and for older orders placed
  // before the backend started returning this snapshot.
  @override
  OrderDeliveryAddress? get deliveryAddress;
  @override
  OrderStatus get status;
  @override
  double get subtotal;
  @override
  double get deliveryFee;
  @override
  double get discountTotal;
  @override
  int get loyaltyPointsUsed;
  @override
  int get loyaltyPointsEarned;
  @override
  double get grandTotal;
  @override
  String? get paymentId;
  @override
  String? get paymentStatus;
  @override
  String? get paymentMethod;
  @override
  DateTime get placedAt;
  @override
  List<OrderStatusEntry> get statusHistory;
  @override
  String? get estimatedTime; // Additive field on the checkout response only (03_DTO_REFERENCE.md) — null
  // when no loyalty reward was redeemed for this order (the normal case).
  @override
  LoyaltyRedemptionInfo? get loyaltyRedemption;

  /// Create a copy of Order
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderImplCopyWith<_$OrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderDeliveryAddress _$OrderDeliveryAddressFromJson(Map<String, dynamic> json) {
  return _OrderDeliveryAddress.fromJson(json);
}

/// @nodoc
mixin _$OrderDeliveryAddress {
  String? get label => throw _privateConstructorUsedError;
  String? get street => throw _privateConstructorUsedError;
  String? get building => throw _privateConstructorUsedError;
  String? get floor => throw _privateConstructorUsedError;
  String? get apartment => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get area => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  double? get lat => throw _privateConstructorUsedError;
  double? get lng => throw _privateConstructorUsedError;

  /// Serializes this OrderDeliveryAddress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderDeliveryAddress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderDeliveryAddressCopyWith<OrderDeliveryAddress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderDeliveryAddressCopyWith<$Res> {
  factory $OrderDeliveryAddressCopyWith(
    OrderDeliveryAddress value,
    $Res Function(OrderDeliveryAddress) then,
  ) = _$OrderDeliveryAddressCopyWithImpl<$Res, OrderDeliveryAddress>;
  @useResult
  $Res call({
    String? label,
    String? street,
    String? building,
    String? floor,
    String? apartment,
    String? city,
    String? area,
    String? notes,
    double? lat,
    double? lng,
  });
}

/// @nodoc
class _$OrderDeliveryAddressCopyWithImpl<
  $Res,
  $Val extends OrderDeliveryAddress
>
    implements $OrderDeliveryAddressCopyWith<$Res> {
  _$OrderDeliveryAddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderDeliveryAddress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = freezed,
    Object? street = freezed,
    Object? building = freezed,
    Object? floor = freezed,
    Object? apartment = freezed,
    Object? city = freezed,
    Object? area = freezed,
    Object? notes = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
  }) {
    return _then(
      _value.copyWith(
            label: freezed == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String?,
            street: freezed == street
                ? _value.street
                : street // ignore: cast_nullable_to_non_nullable
                      as String?,
            building: freezed == building
                ? _value.building
                : building // ignore: cast_nullable_to_non_nullable
                      as String?,
            floor: freezed == floor
                ? _value.floor
                : floor // ignore: cast_nullable_to_non_nullable
                      as String?,
            apartment: freezed == apartment
                ? _value.apartment
                : apartment // ignore: cast_nullable_to_non_nullable
                      as String?,
            city: freezed == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String?,
            area: freezed == area
                ? _value.area
                : area // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            lat: freezed == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double?,
            lng: freezed == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderDeliveryAddressImplCopyWith<$Res>
    implements $OrderDeliveryAddressCopyWith<$Res> {
  factory _$$OrderDeliveryAddressImplCopyWith(
    _$OrderDeliveryAddressImpl value,
    $Res Function(_$OrderDeliveryAddressImpl) then,
  ) = __$$OrderDeliveryAddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? label,
    String? street,
    String? building,
    String? floor,
    String? apartment,
    String? city,
    String? area,
    String? notes,
    double? lat,
    double? lng,
  });
}

/// @nodoc
class __$$OrderDeliveryAddressImplCopyWithImpl<$Res>
    extends _$OrderDeliveryAddressCopyWithImpl<$Res, _$OrderDeliveryAddressImpl>
    implements _$$OrderDeliveryAddressImplCopyWith<$Res> {
  __$$OrderDeliveryAddressImplCopyWithImpl(
    _$OrderDeliveryAddressImpl _value,
    $Res Function(_$OrderDeliveryAddressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderDeliveryAddress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = freezed,
    Object? street = freezed,
    Object? building = freezed,
    Object? floor = freezed,
    Object? apartment = freezed,
    Object? city = freezed,
    Object? area = freezed,
    Object? notes = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
  }) {
    return _then(
      _$OrderDeliveryAddressImpl(
        label: freezed == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String?,
        street: freezed == street
            ? _value.street
            : street // ignore: cast_nullable_to_non_nullable
                  as String?,
        building: freezed == building
            ? _value.building
            : building // ignore: cast_nullable_to_non_nullable
                  as String?,
        floor: freezed == floor
            ? _value.floor
            : floor // ignore: cast_nullable_to_non_nullable
                  as String?,
        apartment: freezed == apartment
            ? _value.apartment
            : apartment // ignore: cast_nullable_to_non_nullable
                  as String?,
        city: freezed == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String?,
        area: freezed == area
            ? _value.area
            : area // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        lat: freezed == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double?,
        lng: freezed == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderDeliveryAddressImpl implements _OrderDeliveryAddress {
  const _$OrderDeliveryAddressImpl({
    this.label,
    this.street,
    this.building,
    this.floor,
    this.apartment,
    this.city,
    this.area,
    this.notes,
    this.lat,
    this.lng,
  });

  factory _$OrderDeliveryAddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderDeliveryAddressImplFromJson(json);

  @override
  final String? label;
  @override
  final String? street;
  @override
  final String? building;
  @override
  final String? floor;
  @override
  final String? apartment;
  @override
  final String? city;
  @override
  final String? area;
  @override
  final String? notes;
  @override
  final double? lat;
  @override
  final double? lng;

  @override
  String toString() {
    return 'OrderDeliveryAddress(label: $label, street: $street, building: $building, floor: $floor, apartment: $apartment, city: $city, area: $area, notes: $notes, lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderDeliveryAddressImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.street, street) || other.street == street) &&
            (identical(other.building, building) ||
                other.building == building) &&
            (identical(other.floor, floor) || other.floor == floor) &&
            (identical(other.apartment, apartment) ||
                other.apartment == apartment) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    label,
    street,
    building,
    floor,
    apartment,
    city,
    area,
    notes,
    lat,
    lng,
  );

  /// Create a copy of OrderDeliveryAddress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderDeliveryAddressImplCopyWith<_$OrderDeliveryAddressImpl>
  get copyWith =>
      __$$OrderDeliveryAddressImplCopyWithImpl<_$OrderDeliveryAddressImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderDeliveryAddressImplToJson(this);
  }
}

abstract class _OrderDeliveryAddress implements OrderDeliveryAddress {
  const factory _OrderDeliveryAddress({
    final String? label,
    final String? street,
    final String? building,
    final String? floor,
    final String? apartment,
    final String? city,
    final String? area,
    final String? notes,
    final double? lat,
    final double? lng,
  }) = _$OrderDeliveryAddressImpl;

  factory _OrderDeliveryAddress.fromJson(Map<String, dynamic> json) =
      _$OrderDeliveryAddressImpl.fromJson;

  @override
  String? get label;
  @override
  String? get street;
  @override
  String? get building;
  @override
  String? get floor;
  @override
  String? get apartment;
  @override
  String? get city;
  @override
  String? get area;
  @override
  String? get notes;
  @override
  double? get lat;
  @override
  double? get lng;

  /// Create a copy of OrderDeliveryAddress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderDeliveryAddressImplCopyWith<_$OrderDeliveryAddressImpl>
  get copyWith => throw _privateConstructorUsedError;
}

LoyaltyRedemptionInfo _$LoyaltyRedemptionInfoFromJson(
  Map<String, dynamic> json,
) {
  return _LoyaltyRedemptionInfo.fromJson(json);
}

/// @nodoc
mixin _$LoyaltyRedemptionInfo {
  String get rewardId => throw _privateConstructorUsedError;
  String get rewardName => throw _privateConstructorUsedError;
  int get pointsRedeemed => throw _privateConstructorUsedError;

  /// Serializes this LoyaltyRedemptionInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoyaltyRedemptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoyaltyRedemptionInfoCopyWith<LoyaltyRedemptionInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoyaltyRedemptionInfoCopyWith<$Res> {
  factory $LoyaltyRedemptionInfoCopyWith(
    LoyaltyRedemptionInfo value,
    $Res Function(LoyaltyRedemptionInfo) then,
  ) = _$LoyaltyRedemptionInfoCopyWithImpl<$Res, LoyaltyRedemptionInfo>;
  @useResult
  $Res call({String rewardId, String rewardName, int pointsRedeemed});
}

/// @nodoc
class _$LoyaltyRedemptionInfoCopyWithImpl<
  $Res,
  $Val extends LoyaltyRedemptionInfo
>
    implements $LoyaltyRedemptionInfoCopyWith<$Res> {
  _$LoyaltyRedemptionInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoyaltyRedemptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rewardId = null,
    Object? rewardName = null,
    Object? pointsRedeemed = null,
  }) {
    return _then(
      _value.copyWith(
            rewardId: null == rewardId
                ? _value.rewardId
                : rewardId // ignore: cast_nullable_to_non_nullable
                      as String,
            rewardName: null == rewardName
                ? _value.rewardName
                : rewardName // ignore: cast_nullable_to_non_nullable
                      as String,
            pointsRedeemed: null == pointsRedeemed
                ? _value.pointsRedeemed
                : pointsRedeemed // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoyaltyRedemptionInfoImplCopyWith<$Res>
    implements $LoyaltyRedemptionInfoCopyWith<$Res> {
  factory _$$LoyaltyRedemptionInfoImplCopyWith(
    _$LoyaltyRedemptionInfoImpl value,
    $Res Function(_$LoyaltyRedemptionInfoImpl) then,
  ) = __$$LoyaltyRedemptionInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String rewardId, String rewardName, int pointsRedeemed});
}

/// @nodoc
class __$$LoyaltyRedemptionInfoImplCopyWithImpl<$Res>
    extends
        _$LoyaltyRedemptionInfoCopyWithImpl<$Res, _$LoyaltyRedemptionInfoImpl>
    implements _$$LoyaltyRedemptionInfoImplCopyWith<$Res> {
  __$$LoyaltyRedemptionInfoImplCopyWithImpl(
    _$LoyaltyRedemptionInfoImpl _value,
    $Res Function(_$LoyaltyRedemptionInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoyaltyRedemptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? rewardId = null,
    Object? rewardName = null,
    Object? pointsRedeemed = null,
  }) {
    return _then(
      _$LoyaltyRedemptionInfoImpl(
        rewardId: null == rewardId
            ? _value.rewardId
            : rewardId // ignore: cast_nullable_to_non_nullable
                  as String,
        rewardName: null == rewardName
            ? _value.rewardName
            : rewardName // ignore: cast_nullable_to_non_nullable
                  as String,
        pointsRedeemed: null == pointsRedeemed
            ? _value.pointsRedeemed
            : pointsRedeemed // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoyaltyRedemptionInfoImpl implements _LoyaltyRedemptionInfo {
  const _$LoyaltyRedemptionInfoImpl({
    required this.rewardId,
    required this.rewardName,
    required this.pointsRedeemed,
  });

  factory _$LoyaltyRedemptionInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoyaltyRedemptionInfoImplFromJson(json);

  @override
  final String rewardId;
  @override
  final String rewardName;
  @override
  final int pointsRedeemed;

  @override
  String toString() {
    return 'LoyaltyRedemptionInfo(rewardId: $rewardId, rewardName: $rewardName, pointsRedeemed: $pointsRedeemed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoyaltyRedemptionInfoImpl &&
            (identical(other.rewardId, rewardId) ||
                other.rewardId == rewardId) &&
            (identical(other.rewardName, rewardName) ||
                other.rewardName == rewardName) &&
            (identical(other.pointsRedeemed, pointsRedeemed) ||
                other.pointsRedeemed == pointsRedeemed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, rewardId, rewardName, pointsRedeemed);

  /// Create a copy of LoyaltyRedemptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoyaltyRedemptionInfoImplCopyWith<_$LoyaltyRedemptionInfoImpl>
  get copyWith =>
      __$$LoyaltyRedemptionInfoImplCopyWithImpl<_$LoyaltyRedemptionInfoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LoyaltyRedemptionInfoImplToJson(this);
  }
}

abstract class _LoyaltyRedemptionInfo implements LoyaltyRedemptionInfo {
  const factory _LoyaltyRedemptionInfo({
    required final String rewardId,
    required final String rewardName,
    required final int pointsRedeemed,
  }) = _$LoyaltyRedemptionInfoImpl;

  factory _LoyaltyRedemptionInfo.fromJson(Map<String, dynamic> json) =
      _$LoyaltyRedemptionInfoImpl.fromJson;

  @override
  String get rewardId;
  @override
  String get rewardName;
  @override
  int get pointsRedeemed;

  /// Create a copy of LoyaltyRedemptionInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoyaltyRedemptionInfoImplCopyWith<_$LoyaltyRedemptionInfoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) {
  return _OrderItem.fromJson(json);
}

/// @nodoc
mixin _$OrderItem {
  String get menuItemId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  double get basePrice => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  Map<String, List<String>> get selectedOptions =>
      throw _privateConstructorUsedError; // groupId -> list of optionIds
  Map<String, Map<String, List<String>>> get nestedSelections =>
      throw _privateConstructorUsedError; // optionId -> (groupId -> list of nestedOptionIds)
  Map<String, int> get extraQuantities =>
      throw _privateConstructorUsedError; // optionId -> quantity
  List<String> get removedIngredients => throw _privateConstructorUsedError;
  String get specialInstructions => throw _privateConstructorUsedError;
  String get formattedConfiguration => throw _privateConstructorUsedError;
  double get lineTotal => throw _privateConstructorUsedError;

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderItemCopyWith<OrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderItemCopyWith<$Res> {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) then) =
      _$OrderItemCopyWithImpl<$Res, OrderItem>;
  @useResult
  $Res call({
    String menuItemId,
    String name,
    String imageUrl,
    double basePrice,
    double unitPrice,
    int quantity,
    Map<String, List<String>> selectedOptions,
    Map<String, Map<String, List<String>>> nestedSelections,
    Map<String, int> extraQuantities,
    List<String> removedIngredients,
    String specialInstructions,
    String formattedConfiguration,
    double lineTotal,
  });
}

/// @nodoc
class _$OrderItemCopyWithImpl<$Res, $Val extends OrderItem>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuItemId = null,
    Object? name = null,
    Object? imageUrl = null,
    Object? basePrice = null,
    Object? unitPrice = null,
    Object? quantity = null,
    Object? selectedOptions = null,
    Object? nestedSelections = null,
    Object? extraQuantities = null,
    Object? removedIngredients = null,
    Object? specialInstructions = null,
    Object? formattedConfiguration = null,
    Object? lineTotal = null,
  }) {
    return _then(
      _value.copyWith(
            menuItemId: null == menuItemId
                ? _value.menuItemId
                : menuItemId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            basePrice: null == basePrice
                ? _value.basePrice
                : basePrice // ignore: cast_nullable_to_non_nullable
                      as double,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            selectedOptions: null == selectedOptions
                ? _value.selectedOptions
                : selectedOptions // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<String>>,
            nestedSelections: null == nestedSelections
                ? _value.nestedSelections
                : nestedSelections // ignore: cast_nullable_to_non_nullable
                      as Map<String, Map<String, List<String>>>,
            extraQuantities: null == extraQuantities
                ? _value.extraQuantities
                : extraQuantities // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            removedIngredients: null == removedIngredients
                ? _value.removedIngredients
                : removedIngredients // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            specialInstructions: null == specialInstructions
                ? _value.specialInstructions
                : specialInstructions // ignore: cast_nullable_to_non_nullable
                      as String,
            formattedConfiguration: null == formattedConfiguration
                ? _value.formattedConfiguration
                : formattedConfiguration // ignore: cast_nullable_to_non_nullable
                      as String,
            lineTotal: null == lineTotal
                ? _value.lineTotal
                : lineTotal // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderItemImplCopyWith<$Res>
    implements $OrderItemCopyWith<$Res> {
  factory _$$OrderItemImplCopyWith(
    _$OrderItemImpl value,
    $Res Function(_$OrderItemImpl) then,
  ) = __$$OrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String menuItemId,
    String name,
    String imageUrl,
    double basePrice,
    double unitPrice,
    int quantity,
    Map<String, List<String>> selectedOptions,
    Map<String, Map<String, List<String>>> nestedSelections,
    Map<String, int> extraQuantities,
    List<String> removedIngredients,
    String specialInstructions,
    String formattedConfiguration,
    double lineTotal,
  });
}

/// @nodoc
class __$$OrderItemImplCopyWithImpl<$Res>
    extends _$OrderItemCopyWithImpl<$Res, _$OrderItemImpl>
    implements _$$OrderItemImplCopyWith<$Res> {
  __$$OrderItemImplCopyWithImpl(
    _$OrderItemImpl _value,
    $Res Function(_$OrderItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? menuItemId = null,
    Object? name = null,
    Object? imageUrl = null,
    Object? basePrice = null,
    Object? unitPrice = null,
    Object? quantity = null,
    Object? selectedOptions = null,
    Object? nestedSelections = null,
    Object? extraQuantities = null,
    Object? removedIngredients = null,
    Object? specialInstructions = null,
    Object? formattedConfiguration = null,
    Object? lineTotal = null,
  }) {
    return _then(
      _$OrderItemImpl(
        menuItemId: null == menuItemId
            ? _value.menuItemId
            : menuItemId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        basePrice: null == basePrice
            ? _value.basePrice
            : basePrice // ignore: cast_nullable_to_non_nullable
                  as double,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        selectedOptions: null == selectedOptions
            ? _value._selectedOptions
            : selectedOptions // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<String>>,
        nestedSelections: null == nestedSelections
            ? _value._nestedSelections
            : nestedSelections // ignore: cast_nullable_to_non_nullable
                  as Map<String, Map<String, List<String>>>,
        extraQuantities: null == extraQuantities
            ? _value._extraQuantities
            : extraQuantities // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        removedIngredients: null == removedIngredients
            ? _value._removedIngredients
            : removedIngredients // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        specialInstructions: null == specialInstructions
            ? _value.specialInstructions
            : specialInstructions // ignore: cast_nullable_to_non_nullable
                  as String,
        formattedConfiguration: null == formattedConfiguration
            ? _value.formattedConfiguration
            : formattedConfiguration // ignore: cast_nullable_to_non_nullable
                  as String,
        lineTotal: null == lineTotal
            ? _value.lineTotal
            : lineTotal // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderItemImpl implements _OrderItem {
  const _$OrderItemImpl({
    required this.menuItemId,
    required this.name,
    required this.imageUrl,
    required this.basePrice,
    required this.unitPrice,
    required this.quantity,
    final Map<String, List<String>> selectedOptions = const {},
    final Map<String, Map<String, List<String>>> nestedSelections = const {},
    final Map<String, int> extraQuantities = const {},
    final List<String> removedIngredients = const [],
    this.specialInstructions = '',
    this.formattedConfiguration = '',
    required this.lineTotal,
  }) : _selectedOptions = selectedOptions,
       _nestedSelections = nestedSelections,
       _extraQuantities = extraQuantities,
       _removedIngredients = removedIngredients;

  factory _$OrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderItemImplFromJson(json);

  @override
  final String menuItemId;
  @override
  final String name;
  @override
  final String imageUrl;
  @override
  final double basePrice;
  @override
  final double unitPrice;
  @override
  final int quantity;
  final Map<String, List<String>> _selectedOptions;
  @override
  @JsonKey()
  Map<String, List<String>> get selectedOptions {
    if (_selectedOptions is EqualUnmodifiableMapView) return _selectedOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_selectedOptions);
  }

  // groupId -> list of optionIds
  final Map<String, Map<String, List<String>>> _nestedSelections;
  // groupId -> list of optionIds
  @override
  @JsonKey()
  Map<String, Map<String, List<String>>> get nestedSelections {
    if (_nestedSelections is EqualUnmodifiableMapView) return _nestedSelections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_nestedSelections);
  }

  // optionId -> (groupId -> list of nestedOptionIds)
  final Map<String, int> _extraQuantities;
  // optionId -> (groupId -> list of nestedOptionIds)
  @override
  @JsonKey()
  Map<String, int> get extraQuantities {
    if (_extraQuantities is EqualUnmodifiableMapView) return _extraQuantities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_extraQuantities);
  }

  // optionId -> quantity
  final List<String> _removedIngredients;
  // optionId -> quantity
  @override
  @JsonKey()
  List<String> get removedIngredients {
    if (_removedIngredients is EqualUnmodifiableListView)
      return _removedIngredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_removedIngredients);
  }

  @override
  @JsonKey()
  final String specialInstructions;
  @override
  @JsonKey()
  final String formattedConfiguration;
  @override
  final double lineTotal;

  @override
  String toString() {
    return 'OrderItem(menuItemId: $menuItemId, name: $name, imageUrl: $imageUrl, basePrice: $basePrice, unitPrice: $unitPrice, quantity: $quantity, selectedOptions: $selectedOptions, nestedSelections: $nestedSelections, extraQuantities: $extraQuantities, removedIngredients: $removedIngredients, specialInstructions: $specialInstructions, formattedConfiguration: $formattedConfiguration, lineTotal: $lineTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderItemImpl &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            const DeepCollectionEquality().equals(
              other._selectedOptions,
              _selectedOptions,
            ) &&
            const DeepCollectionEquality().equals(
              other._nestedSelections,
              _nestedSelections,
            ) &&
            const DeepCollectionEquality().equals(
              other._extraQuantities,
              _extraQuantities,
            ) &&
            const DeepCollectionEquality().equals(
              other._removedIngredients,
              _removedIngredients,
            ) &&
            (identical(other.specialInstructions, specialInstructions) ||
                other.specialInstructions == specialInstructions) &&
            (identical(other.formattedConfiguration, formattedConfiguration) ||
                other.formattedConfiguration == formattedConfiguration) &&
            (identical(other.lineTotal, lineTotal) ||
                other.lineTotal == lineTotal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    menuItemId,
    name,
    imageUrl,
    basePrice,
    unitPrice,
    quantity,
    const DeepCollectionEquality().hash(_selectedOptions),
    const DeepCollectionEquality().hash(_nestedSelections),
    const DeepCollectionEquality().hash(_extraQuantities),
    const DeepCollectionEquality().hash(_removedIngredients),
    specialInstructions,
    formattedConfiguration,
    lineTotal,
  );

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      __$$OrderItemImplCopyWithImpl<_$OrderItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderItemImplToJson(this);
  }
}

abstract class _OrderItem implements OrderItem {
  const factory _OrderItem({
    required final String menuItemId,
    required final String name,
    required final String imageUrl,
    required final double basePrice,
    required final double unitPrice,
    required final int quantity,
    final Map<String, List<String>> selectedOptions,
    final Map<String, Map<String, List<String>>> nestedSelections,
    final Map<String, int> extraQuantities,
    final List<String> removedIngredients,
    final String specialInstructions,
    final String formattedConfiguration,
    required final double lineTotal,
  }) = _$OrderItemImpl;

  factory _OrderItem.fromJson(Map<String, dynamic> json) =
      _$OrderItemImpl.fromJson;

  @override
  String get menuItemId;
  @override
  String get name;
  @override
  String get imageUrl;
  @override
  double get basePrice;
  @override
  double get unitPrice;
  @override
  int get quantity;
  @override
  Map<String, List<String>> get selectedOptions; // groupId -> list of optionIds
  @override
  Map<String, Map<String, List<String>>> get nestedSelections; // optionId -> (groupId -> list of nestedOptionIds)
  @override
  Map<String, int> get extraQuantities; // optionId -> quantity
  @override
  List<String> get removedIngredients;
  @override
  String get specialInstructions;
  @override
  String get formattedConfiguration;
  @override
  double get lineTotal;

  /// Create a copy of OrderItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderItemImplCopyWith<_$OrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OrderStatusEntry _$OrderStatusEntryFromJson(Map<String, dynamic> json) {
  return _OrderStatusEntry.fromJson(json);
}

/// @nodoc
mixin _$OrderStatusEntry {
  OrderStatus get status => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this OrderStatusEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderStatusEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderStatusEntryCopyWith<OrderStatusEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderStatusEntryCopyWith<$Res> {
  factory $OrderStatusEntryCopyWith(
    OrderStatusEntry value,
    $Res Function(OrderStatusEntry) then,
  ) = _$OrderStatusEntryCopyWithImpl<$Res, OrderStatusEntry>;
  @useResult
  $Res call({OrderStatus status, DateTime timestamp});
}

/// @nodoc
class _$OrderStatusEntryCopyWithImpl<$Res, $Val extends OrderStatusEntry>
    implements $OrderStatusEntryCopyWith<$Res> {
  _$OrderStatusEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderStatusEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = null, Object? timestamp = null}) {
    return _then(
      _value.copyWith(
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OrderStatus,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderStatusEntryImplCopyWith<$Res>
    implements $OrderStatusEntryCopyWith<$Res> {
  factory _$$OrderStatusEntryImplCopyWith(
    _$OrderStatusEntryImpl value,
    $Res Function(_$OrderStatusEntryImpl) then,
  ) = __$$OrderStatusEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({OrderStatus status, DateTime timestamp});
}

/// @nodoc
class __$$OrderStatusEntryImplCopyWithImpl<$Res>
    extends _$OrderStatusEntryCopyWithImpl<$Res, _$OrderStatusEntryImpl>
    implements _$$OrderStatusEntryImplCopyWith<$Res> {
  __$$OrderStatusEntryImplCopyWithImpl(
    _$OrderStatusEntryImpl _value,
    $Res Function(_$OrderStatusEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderStatusEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = null, Object? timestamp = null}) {
    return _then(
      _$OrderStatusEntryImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OrderStatus,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderStatusEntryImpl implements _OrderStatusEntry {
  const _$OrderStatusEntryImpl({required this.status, required this.timestamp});

  factory _$OrderStatusEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderStatusEntryImplFromJson(json);

  @override
  final OrderStatus status;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'OrderStatusEntry(status: $status, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderStatusEntryImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, status, timestamp);

  /// Create a copy of OrderStatusEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderStatusEntryImplCopyWith<_$OrderStatusEntryImpl> get copyWith =>
      __$$OrderStatusEntryImplCopyWithImpl<_$OrderStatusEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderStatusEntryImplToJson(this);
  }
}

abstract class _OrderStatusEntry implements OrderStatusEntry {
  const factory _OrderStatusEntry({
    required final OrderStatus status,
    required final DateTime timestamp,
  }) = _$OrderStatusEntryImpl;

  factory _OrderStatusEntry.fromJson(Map<String, dynamic> json) =
      _$OrderStatusEntryImpl.fromJson;

  @override
  OrderStatus get status;
  @override
  DateTime get timestamp;

  /// Create a copy of OrderStatusEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderStatusEntryImplCopyWith<_$OrderStatusEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
