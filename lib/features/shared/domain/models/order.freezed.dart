// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Order {

 String get id; String get orderNumber; String get userId; String? get customerName; List<OrderItem> get items; FulfillmentType get fulfillmentType; String? get addressId; String? get pickupLocation; OrderDeliveryAddress? get deliveryAddress; OrderStatus get status; double get subtotal; double get deliveryFee; int? get deliveryDistanceMeters; double? get deliveryDistanceKm; int? get deliveryDurationSeconds; OrderDeliveryTier? get deliveryTier; OrderDeliveryZoneSnapshot? get deliveryZone; double get discountTotal; int get loyaltyPointsUsed; int get loyaltyPointsEarned; double get grandTotal; String? get paymentId; String? get paymentStatus; String? get paymentMethod; DateTime? get paymentAuthorizedAt; DateTime get placedAt; List<OrderStatusEntry> get statusHistory; String? get estimatedTime; int? get preparationTimeMinutes; LoyaltyRedemptionInfo? get loyaltyRedemption; String? get driverId;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);

  /// Serializes this Order to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Order;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.orderNumber, _this.orderNumber) || other.orderNumber == _this.orderNumber)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.fulfillmentType, _this.fulfillmentType) || other.fulfillmentType == _this.fulfillmentType)&&(identical(other.addressId, _this.addressId) || other.addressId == _this.addressId)&&(identical(other.pickupLocation, _this.pickupLocation) || other.pickupLocation == _this.pickupLocation)&&(identical(other.deliveryAddress, _this.deliveryAddress) || other.deliveryAddress == _this.deliveryAddress)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal)&&(identical(other.deliveryFee, _this.deliveryFee) || other.deliveryFee == _this.deliveryFee)&&(identical(other.deliveryDistanceMeters, _this.deliveryDistanceMeters) || other.deliveryDistanceMeters == _this.deliveryDistanceMeters)&&(identical(other.deliveryDistanceKm, _this.deliveryDistanceKm) || other.deliveryDistanceKm == _this.deliveryDistanceKm)&&(identical(other.deliveryDurationSeconds, _this.deliveryDurationSeconds) || other.deliveryDurationSeconds == _this.deliveryDurationSeconds)&&(identical(other.deliveryTier, _this.deliveryTier) || other.deliveryTier == _this.deliveryTier)&&(identical(other.deliveryZone, _this.deliveryZone) || other.deliveryZone == _this.deliveryZone)&&(identical(other.discountTotal, _this.discountTotal) || other.discountTotal == _this.discountTotal)&&(identical(other.loyaltyPointsUsed, _this.loyaltyPointsUsed) || other.loyaltyPointsUsed == _this.loyaltyPointsUsed)&&(identical(other.loyaltyPointsEarned, _this.loyaltyPointsEarned) || other.loyaltyPointsEarned == _this.loyaltyPointsEarned)&&(identical(other.grandTotal, _this.grandTotal) || other.grandTotal == _this.grandTotal)&&(identical(other.paymentId, _this.paymentId) || other.paymentId == _this.paymentId)&&(identical(other.paymentStatus, _this.paymentStatus) || other.paymentStatus == _this.paymentStatus)&&(identical(other.paymentMethod, _this.paymentMethod) || other.paymentMethod == _this.paymentMethod)&&(identical(other.paymentAuthorizedAt, _this.paymentAuthorizedAt) || other.paymentAuthorizedAt == _this.paymentAuthorizedAt)&&(identical(other.placedAt, _this.placedAt) || other.placedAt == _this.placedAt)&&const DeepCollectionEquality().equals(other.statusHistory, _this.statusHistory)&&(identical(other.estimatedTime, _this.estimatedTime) || other.estimatedTime == _this.estimatedTime)&&(identical(other.preparationTimeMinutes, _this.preparationTimeMinutes) || other.preparationTimeMinutes == _this.preparationTimeMinutes)&&(identical(other.loyaltyRedemption, _this.loyaltyRedemption) || other.loyaltyRedemption == _this.loyaltyRedemption)&&(identical(other.driverId, _this.driverId) || other.driverId == _this.driverId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Order;
  return Object.hashAll([runtimeType,_this.id,_this.orderNumber,_this.userId,_this.customerName,const DeepCollectionEquality().hash(_this.items),_this.fulfillmentType,_this.addressId,_this.pickupLocation,_this.deliveryAddress,_this.status,_this.subtotal,_this.deliveryFee,_this.deliveryDistanceMeters,_this.deliveryDistanceKm,_this.deliveryDurationSeconds,_this.deliveryTier,_this.deliveryZone,_this.discountTotal,_this.loyaltyPointsUsed,_this.loyaltyPointsEarned,_this.grandTotal,_this.paymentId,_this.paymentStatus,_this.paymentMethod,_this.paymentAuthorizedAt,_this.placedAt,const DeepCollectionEquality().hash(_this.statusHistory),_this.estimatedTime,_this.preparationTimeMinutes,_this.loyaltyRedemption,_this.driverId]);
}

@override
String toString() {
  final _this = this as Order;
  return 'Order(id: ${_this.id}, orderNumber: ${_this.orderNumber}, userId: ${_this.userId}, customerName: ${_this.customerName}, items: ${_this.items}, fulfillmentType: ${_this.fulfillmentType}, addressId: ${_this.addressId}, pickupLocation: ${_this.pickupLocation}, deliveryAddress: ${_this.deliveryAddress}, status: ${_this.status}, subtotal: ${_this.subtotal}, deliveryFee: ${_this.deliveryFee}, deliveryDistanceMeters: ${_this.deliveryDistanceMeters}, deliveryDistanceKm: ${_this.deliveryDistanceKm}, deliveryDurationSeconds: ${_this.deliveryDurationSeconds}, deliveryTier: ${_this.deliveryTier}, deliveryZone: ${_this.deliveryZone}, discountTotal: ${_this.discountTotal}, loyaltyPointsUsed: ${_this.loyaltyPointsUsed}, loyaltyPointsEarned: ${_this.loyaltyPointsEarned}, grandTotal: ${_this.grandTotal}, paymentId: ${_this.paymentId}, paymentStatus: ${_this.paymentStatus}, paymentMethod: ${_this.paymentMethod}, paymentAuthorizedAt: ${_this.paymentAuthorizedAt}, placedAt: ${_this.placedAt}, statusHistory: ${_this.statusHistory}, estimatedTime: ${_this.estimatedTime}, preparationTimeMinutes: ${_this.preparationTimeMinutes}, loyaltyRedemption: ${_this.loyaltyRedemption}, driverId: ${_this.driverId})';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id, String orderNumber, String userId, String? customerName, List<OrderItem> items, FulfillmentType fulfillmentType, String? addressId, String? pickupLocation, OrderDeliveryAddress? deliveryAddress, OrderStatus status, double subtotal, double deliveryFee, int? deliveryDistanceMeters, double? deliveryDistanceKm, int? deliveryDurationSeconds, OrderDeliveryTier? deliveryTier, OrderDeliveryZoneSnapshot? deliveryZone, double discountTotal, int loyaltyPointsUsed, int loyaltyPointsEarned, double grandTotal, String? paymentId, String? paymentStatus, String? paymentMethod, DateTime? paymentAuthorizedAt, DateTime placedAt, List<OrderStatusEntry> statusHistory, String? estimatedTime, int? preparationTimeMinutes, LoyaltyRedemptionInfo? loyaltyRedemption, String? driverId
});


$OrderDeliveryAddressCopyWith<$Res>? get deliveryAddress;$OrderDeliveryTierCopyWith<$Res>? get deliveryTier;$OrderDeliveryZoneSnapshotCopyWith<$Res>? get deliveryZone;$LoyaltyRedemptionInfoCopyWith<$Res>? get loyaltyRedemption;

}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? userId = null,Object? customerName = freezed,Object? items = null,Object? fulfillmentType = null,Object? addressId = freezed,Object? pickupLocation = freezed,Object? deliveryAddress = freezed,Object? status = null,Object? subtotal = null,Object? deliveryFee = null,Object? deliveryDistanceMeters = freezed,Object? deliveryDistanceKm = freezed,Object? deliveryDurationSeconds = freezed,Object? deliveryTier = freezed,Object? deliveryZone = freezed,Object? discountTotal = null,Object? loyaltyPointsUsed = null,Object? loyaltyPointsEarned = null,Object? grandTotal = null,Object? paymentId = freezed,Object? paymentStatus = freezed,Object? paymentMethod = freezed,Object? paymentAuthorizedAt = freezed,Object? placedAt = null,Object? statusHistory = null,Object? estimatedTime = freezed,Object? preparationTimeMinutes = freezed,Object? loyaltyRedemption = freezed,Object? driverId = freezed,}) {
  return _then(Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as FulfillmentType,addressId: freezed == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as String?,pickupLocation: freezed == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as OrderDeliveryAddress?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,deliveryDistanceMeters: freezed == deliveryDistanceMeters ? _self.deliveryDistanceMeters : deliveryDistanceMeters // ignore: cast_nullable_to_non_nullable
as int?,deliveryDistanceKm: freezed == deliveryDistanceKm ? _self.deliveryDistanceKm : deliveryDistanceKm // ignore: cast_nullable_to_non_nullable
as double?,deliveryDurationSeconds: freezed == deliveryDurationSeconds ? _self.deliveryDurationSeconds : deliveryDurationSeconds // ignore: cast_nullable_to_non_nullable
as int?,deliveryTier: freezed == deliveryTier ? _self.deliveryTier : deliveryTier // ignore: cast_nullable_to_non_nullable
as OrderDeliveryTier?,deliveryZone: freezed == deliveryZone ? _self.deliveryZone : deliveryZone // ignore: cast_nullable_to_non_nullable
as OrderDeliveryZoneSnapshot?,discountTotal: null == discountTotal ? _self.discountTotal : discountTotal // ignore: cast_nullable_to_non_nullable
as double,loyaltyPointsUsed: null == loyaltyPointsUsed ? _self.loyaltyPointsUsed : loyaltyPointsUsed // ignore: cast_nullable_to_non_nullable
as int,loyaltyPointsEarned: null == loyaltyPointsEarned ? _self.loyaltyPointsEarned : loyaltyPointsEarned // ignore: cast_nullable_to_non_nullable
as int,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,paymentAuthorizedAt: freezed == paymentAuthorizedAt ? _self.paymentAuthorizedAt : paymentAuthorizedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,statusHistory: null == statusHistory ? _self.statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<OrderStatusEntry>,estimatedTime: freezed == estimatedTime ? _self.estimatedTime : estimatedTime // ignore: cast_nullable_to_non_nullable
as String?,preparationTimeMinutes: freezed == preparationTimeMinutes ? _self.preparationTimeMinutes : preparationTimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,loyaltyRedemption: freezed == loyaltyRedemption ? _self.loyaltyRedemption : loyaltyRedemption // ignore: cast_nullable_to_non_nullable
as LoyaltyRedemptionInfo?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderDeliveryAddressCopyWith<$Res>? get deliveryAddress {
    if (_self.deliveryAddress == null) {
    return null;
  }

  return $OrderDeliveryAddressCopyWith<$Res>(_self.deliveryAddress!, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderDeliveryTierCopyWith<$Res>? get deliveryTier {
    if (_self.deliveryTier == null) {
    return null;
  }

  return $OrderDeliveryTierCopyWith<$Res>(_self.deliveryTier!, (value) {
    return _then(_self.copyWith(deliveryTier: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderDeliveryZoneSnapshotCopyWith<$Res>? get deliveryZone {
    if (_self.deliveryZone == null) {
    return null;
  }

  return $OrderDeliveryZoneSnapshotCopyWith<$Res>(_self.deliveryZone!, (value) {
    return _then(_self.copyWith(deliveryZone: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoyaltyRedemptionInfoCopyWith<$Res>? get loyaltyRedemption {
    if (_self.loyaltyRedemption == null) {
    return null;
  }

  return $LoyaltyRedemptionInfoCopyWith<$Res>(_self.loyaltyRedemption!, (value) {
    return _then(_self.copyWith(loyaltyRedemption: value));
  });
}
}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orderNumber,  String userId,  String? customerName,  List<OrderItem> items,  FulfillmentType fulfillmentType,  String? addressId,  String? pickupLocation,  OrderDeliveryAddress? deliveryAddress,  OrderStatus status,  double subtotal,  double deliveryFee,  int? deliveryDistanceMeters,  double? deliveryDistanceKm,  int? deliveryDurationSeconds,  OrderDeliveryTier? deliveryTier,  OrderDeliveryZoneSnapshot? deliveryZone,  double discountTotal,  int loyaltyPointsUsed,  int loyaltyPointsEarned,  double grandTotal,  String? paymentId,  String? paymentStatus,  String? paymentMethod,  DateTime? paymentAuthorizedAt,  DateTime placedAt,  List<OrderStatusEntry> statusHistory,  String? estimatedTime,  int? preparationTimeMinutes,  LoyaltyRedemptionInfo? loyaltyRedemption,  String? driverId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.orderNumber,_that.userId,_that.customerName,_that.items,_that.fulfillmentType,_that.addressId,_that.pickupLocation,_that.deliveryAddress,_that.status,_that.subtotal,_that.deliveryFee,_that.deliveryDistanceMeters,_that.deliveryDistanceKm,_that.deliveryDurationSeconds,_that.deliveryTier,_that.deliveryZone,_that.discountTotal,_that.loyaltyPointsUsed,_that.loyaltyPointsEarned,_that.grandTotal,_that.paymentId,_that.paymentStatus,_that.paymentMethod,_that.paymentAuthorizedAt,_that.placedAt,_that.statusHistory,_that.estimatedTime,_that.preparationTimeMinutes,_that.loyaltyRedemption,_that.driverId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orderNumber,  String userId,  String? customerName,  List<OrderItem> items,  FulfillmentType fulfillmentType,  String? addressId,  String? pickupLocation,  OrderDeliveryAddress? deliveryAddress,  OrderStatus status,  double subtotal,  double deliveryFee,  int? deliveryDistanceMeters,  double? deliveryDistanceKm,  int? deliveryDurationSeconds,  OrderDeliveryTier? deliveryTier,  OrderDeliveryZoneSnapshot? deliveryZone,  double discountTotal,  int loyaltyPointsUsed,  int loyaltyPointsEarned,  double grandTotal,  String? paymentId,  String? paymentStatus,  String? paymentMethod,  DateTime? paymentAuthorizedAt,  DateTime placedAt,  List<OrderStatusEntry> statusHistory,  String? estimatedTime,  int? preparationTimeMinutes,  LoyaltyRedemptionInfo? loyaltyRedemption,  String? driverId)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.orderNumber,_that.userId,_that.customerName,_that.items,_that.fulfillmentType,_that.addressId,_that.pickupLocation,_that.deliveryAddress,_that.status,_that.subtotal,_that.deliveryFee,_that.deliveryDistanceMeters,_that.deliveryDistanceKm,_that.deliveryDurationSeconds,_that.deliveryTier,_that.deliveryZone,_that.discountTotal,_that.loyaltyPointsUsed,_that.loyaltyPointsEarned,_that.grandTotal,_that.paymentId,_that.paymentStatus,_that.paymentMethod,_that.paymentAuthorizedAt,_that.placedAt,_that.statusHistory,_that.estimatedTime,_that.preparationTimeMinutes,_that.loyaltyRedemption,_that.driverId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orderNumber,  String userId,  String? customerName,  List<OrderItem> items,  FulfillmentType fulfillmentType,  String? addressId,  String? pickupLocation,  OrderDeliveryAddress? deliveryAddress,  OrderStatus status,  double subtotal,  double deliveryFee,  int? deliveryDistanceMeters,  double? deliveryDistanceKm,  int? deliveryDurationSeconds,  OrderDeliveryTier? deliveryTier,  OrderDeliveryZoneSnapshot? deliveryZone,  double discountTotal,  int loyaltyPointsUsed,  int loyaltyPointsEarned,  double grandTotal,  String? paymentId,  String? paymentStatus,  String? paymentMethod,  DateTime? paymentAuthorizedAt,  DateTime placedAt,  List<OrderStatusEntry> statusHistory,  String? estimatedTime,  int? preparationTimeMinutes,  LoyaltyRedemptionInfo? loyaltyRedemption,  String? driverId)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.orderNumber,_that.userId,_that.customerName,_that.items,_that.fulfillmentType,_that.addressId,_that.pickupLocation,_that.deliveryAddress,_that.status,_that.subtotal,_that.deliveryFee,_that.deliveryDistanceMeters,_that.deliveryDistanceKm,_that.deliveryDurationSeconds,_that.deliveryTier,_that.deliveryZone,_that.discountTotal,_that.loyaltyPointsUsed,_that.loyaltyPointsEarned,_that.grandTotal,_that.paymentId,_that.paymentStatus,_that.paymentMethod,_that.paymentAuthorizedAt,_that.placedAt,_that.statusHistory,_that.estimatedTime,_that.preparationTimeMinutes,_that.loyaltyRedemption,_that.driverId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Order implements Order {
  const _Order({required this.id, required this.orderNumber, required this.userId, this.customerName, required  List<OrderItem> items, required this.fulfillmentType, this.addressId, this.pickupLocation, this.deliveryAddress, required this.status, required this.subtotal, this.deliveryFee = 0.0, this.deliveryDistanceMeters, this.deliveryDistanceKm, this.deliveryDurationSeconds, this.deliveryTier, this.deliveryZone, this.discountTotal = 0.0, this.loyaltyPointsUsed = 0, this.loyaltyPointsEarned = 0, required this.grandTotal, this.paymentId, this.paymentStatus, this.paymentMethod, this.paymentAuthorizedAt, required this.placedAt,  List<OrderStatusEntry> statusHistory = const [], this.estimatedTime, this.preparationTimeMinutes, this.loyaltyRedemption, this.driverId}): _items = items,_statusHistory = statusHistory;
  factory _Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

@override final  String id;
@override final  String orderNumber;
@override final  String userId;
@override final  String? customerName;
 final  List<OrderItem> _items;
@override List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  FulfillmentType fulfillmentType;
@override final  String? addressId;
@override final  String? pickupLocation;
@override final  OrderDeliveryAddress? deliveryAddress;
@override final  OrderStatus status;
@override final  double subtotal;
@override@JsonKey() final  double deliveryFee;
@override final  int? deliveryDistanceMeters;
@override final  double? deliveryDistanceKm;
@override final  int? deliveryDurationSeconds;
@override final  OrderDeliveryTier? deliveryTier;
@override final  OrderDeliveryZoneSnapshot? deliveryZone;
@override@JsonKey() final  double discountTotal;
@override@JsonKey() final  int loyaltyPointsUsed;
@override@JsonKey() final  int loyaltyPointsEarned;
@override final  double grandTotal;
@override final  String? paymentId;
@override final  String? paymentStatus;
@override final  String? paymentMethod;
@override final  DateTime? paymentAuthorizedAt;
@override final  DateTime placedAt;
 final  List<OrderStatusEntry> _statusHistory;
@override@JsonKey() List<OrderStatusEntry> get statusHistory {
  if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statusHistory);
}

@override final  String? estimatedTime;
@override final  int? preparationTimeMinutes;
@override final  LoyaltyRedemptionInfo? loyaltyRedemption;
@override final  String? driverId;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.fulfillmentType, fulfillmentType) || other.fulfillmentType == fulfillmentType)&&(identical(other.addressId, addressId) || other.addressId == addressId)&&(identical(other.pickupLocation, pickupLocation) || other.pickupLocation == pickupLocation)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.status, status) || other.status == status)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.deliveryDistanceMeters, deliveryDistanceMeters) || other.deliveryDistanceMeters == deliveryDistanceMeters)&&(identical(other.deliveryDistanceKm, deliveryDistanceKm) || other.deliveryDistanceKm == deliveryDistanceKm)&&(identical(other.deliveryDurationSeconds, deliveryDurationSeconds) || other.deliveryDurationSeconds == deliveryDurationSeconds)&&(identical(other.deliveryTier, deliveryTier) || other.deliveryTier == deliveryTier)&&(identical(other.deliveryZone, deliveryZone) || other.deliveryZone == deliveryZone)&&(identical(other.discountTotal, discountTotal) || other.discountTotal == discountTotal)&&(identical(other.loyaltyPointsUsed, loyaltyPointsUsed) || other.loyaltyPointsUsed == loyaltyPointsUsed)&&(identical(other.loyaltyPointsEarned, loyaltyPointsEarned) || other.loyaltyPointsEarned == loyaltyPointsEarned)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentAuthorizedAt, paymentAuthorizedAt) || other.paymentAuthorizedAt == paymentAuthorizedAt)&&(identical(other.placedAt, placedAt) || other.placedAt == placedAt)&&const DeepCollectionEquality().equals(other.statusHistory, _statusHistory)&&(identical(other.estimatedTime, estimatedTime) || other.estimatedTime == estimatedTime)&&(identical(other.preparationTimeMinutes, preparationTimeMinutes) || other.preparationTimeMinutes == preparationTimeMinutes)&&(identical(other.loyaltyRedemption, loyaltyRedemption) || other.loyaltyRedemption == loyaltyRedemption)&&(identical(other.driverId, driverId) || other.driverId == driverId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,orderNumber,userId,customerName,const DeepCollectionEquality().hash(_items),fulfillmentType,addressId,pickupLocation,deliveryAddress,status,subtotal,deliveryFee,deliveryDistanceMeters,deliveryDistanceKm,deliveryDurationSeconds,deliveryTier,deliveryZone,discountTotal,loyaltyPointsUsed,loyaltyPointsEarned,grandTotal,paymentId,paymentStatus,paymentMethod,paymentAuthorizedAt,placedAt,const DeepCollectionEquality().hash(_statusHistory),estimatedTime,preparationTimeMinutes,loyaltyRedemption,driverId]);
}

@override
String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, userId: $userId, customerName: $customerName, items: $items, fulfillmentType: $fulfillmentType, addressId: $addressId, pickupLocation: $pickupLocation, deliveryAddress: $deliveryAddress, status: $status, subtotal: $subtotal, deliveryFee: $deliveryFee, deliveryDistanceMeters: $deliveryDistanceMeters, deliveryDistanceKm: $deliveryDistanceKm, deliveryDurationSeconds: $deliveryDurationSeconds, deliveryTier: $deliveryTier, deliveryZone: $deliveryZone, discountTotal: $discountTotal, loyaltyPointsUsed: $loyaltyPointsUsed, loyaltyPointsEarned: $loyaltyPointsEarned, grandTotal: $grandTotal, paymentId: $paymentId, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, paymentAuthorizedAt: $paymentAuthorizedAt, placedAt: $placedAt, statusHistory: $statusHistory, estimatedTime: $estimatedTime, preparationTimeMinutes: $preparationTimeMinutes, loyaltyRedemption: $loyaltyRedemption, driverId: $driverId)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String orderNumber, String userId, String? customerName, List<OrderItem> items, FulfillmentType fulfillmentType, String? addressId, String? pickupLocation, OrderDeliveryAddress? deliveryAddress, OrderStatus status, double subtotal, double deliveryFee, int? deliveryDistanceMeters, double? deliveryDistanceKm, int? deliveryDurationSeconds, OrderDeliveryTier? deliveryTier, OrderDeliveryZoneSnapshot? deliveryZone, double discountTotal, int loyaltyPointsUsed, int loyaltyPointsEarned, double grandTotal, String? paymentId, String? paymentStatus, String? paymentMethod, DateTime? paymentAuthorizedAt, DateTime placedAt, List<OrderStatusEntry> statusHistory, String? estimatedTime, int? preparationTimeMinutes, LoyaltyRedemptionInfo? loyaltyRedemption, String? driverId
});


@override $OrderDeliveryAddressCopyWith<$Res>? get deliveryAddress;@override $OrderDeliveryTierCopyWith<$Res>? get deliveryTier;@override $OrderDeliveryZoneSnapshotCopyWith<$Res>? get deliveryZone;@override $LoyaltyRedemptionInfoCopyWith<$Res>? get loyaltyRedemption;

}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? userId = null,Object? customerName = freezed,Object? items = null,Object? fulfillmentType = null,Object? addressId = freezed,Object? pickupLocation = freezed,Object? deliveryAddress = freezed,Object? status = null,Object? subtotal = null,Object? deliveryFee = null,Object? deliveryDistanceMeters = freezed,Object? deliveryDistanceKm = freezed,Object? deliveryDurationSeconds = freezed,Object? deliveryTier = freezed,Object? deliveryZone = freezed,Object? discountTotal = null,Object? loyaltyPointsUsed = null,Object? loyaltyPointsEarned = null,Object? grandTotal = null,Object? paymentId = freezed,Object? paymentStatus = freezed,Object? paymentMethod = freezed,Object? paymentAuthorizedAt = freezed,Object? placedAt = null,Object? statusHistory = null,Object? estimatedTime = freezed,Object? preparationTimeMinutes = freezed,Object? loyaltyRedemption = freezed,Object? driverId = freezed,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as FulfillmentType,addressId: freezed == addressId ? _self.addressId : addressId // ignore: cast_nullable_to_non_nullable
as String?,pickupLocation: freezed == pickupLocation ? _self.pickupLocation : pickupLocation // ignore: cast_nullable_to_non_nullable
as String?,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as OrderDeliveryAddress?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,deliveryDistanceMeters: freezed == deliveryDistanceMeters ? _self.deliveryDistanceMeters : deliveryDistanceMeters // ignore: cast_nullable_to_non_nullable
as int?,deliveryDistanceKm: freezed == deliveryDistanceKm ? _self.deliveryDistanceKm : deliveryDistanceKm // ignore: cast_nullable_to_non_nullable
as double?,deliveryDurationSeconds: freezed == deliveryDurationSeconds ? _self.deliveryDurationSeconds : deliveryDurationSeconds // ignore: cast_nullable_to_non_nullable
as int?,deliveryTier: freezed == deliveryTier ? _self.deliveryTier : deliveryTier // ignore: cast_nullable_to_non_nullable
as OrderDeliveryTier?,deliveryZone: freezed == deliveryZone ? _self.deliveryZone : deliveryZone // ignore: cast_nullable_to_non_nullable
as OrderDeliveryZoneSnapshot?,discountTotal: null == discountTotal ? _self.discountTotal : discountTotal // ignore: cast_nullable_to_non_nullable
as double,loyaltyPointsUsed: null == loyaltyPointsUsed ? _self.loyaltyPointsUsed : loyaltyPointsUsed // ignore: cast_nullable_to_non_nullable
as int,loyaltyPointsEarned: null == loyaltyPointsEarned ? _self.loyaltyPointsEarned : loyaltyPointsEarned // ignore: cast_nullable_to_non_nullable
as int,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,paymentStatus: freezed == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,paymentAuthorizedAt: freezed == paymentAuthorizedAt ? _self.paymentAuthorizedAt : paymentAuthorizedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,placedAt: null == placedAt ? _self.placedAt : placedAt // ignore: cast_nullable_to_non_nullable
as DateTime,statusHistory: null == statusHistory ? _self._statusHistory : statusHistory // ignore: cast_nullable_to_non_nullable
as List<OrderStatusEntry>,estimatedTime: freezed == estimatedTime ? _self.estimatedTime : estimatedTime // ignore: cast_nullable_to_non_nullable
as String?,preparationTimeMinutes: freezed == preparationTimeMinutes ? _self.preparationTimeMinutes : preparationTimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,loyaltyRedemption: freezed == loyaltyRedemption ? _self.loyaltyRedemption : loyaltyRedemption // ignore: cast_nullable_to_non_nullable
as LoyaltyRedemptionInfo?,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderDeliveryAddressCopyWith<$Res>? get deliveryAddress {
    if (_self.deliveryAddress == null) {
    return null;
  }

  return $OrderDeliveryAddressCopyWith<$Res>(_self.deliveryAddress!, (value) {
    return _then(_self.copyWith(deliveryAddress: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderDeliveryTierCopyWith<$Res>? get deliveryTier {
    if (_self.deliveryTier == null) {
    return null;
  }

  return $OrderDeliveryTierCopyWith<$Res>(_self.deliveryTier!, (value) {
    return _then(_self.copyWith(deliveryTier: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderDeliveryZoneSnapshotCopyWith<$Res>? get deliveryZone {
    if (_self.deliveryZone == null) {
    return null;
  }

  return $OrderDeliveryZoneSnapshotCopyWith<$Res>(_self.deliveryZone!, (value) {
    return _then(_self.copyWith(deliveryZone: value));
  });
}/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LoyaltyRedemptionInfoCopyWith<$Res>? get loyaltyRedemption {
    if (_self.loyaltyRedemption == null) {
    return null;
  }

  return $LoyaltyRedemptionInfoCopyWith<$Res>(_self.loyaltyRedemption!, (value) {
    return _then(_self.copyWith(loyaltyRedemption: value));
  });
}
}


/// @nodoc
mixin _$OrderDeliveryAddress {

 String? get label; String? get street; String? get building; String? get floor; String? get apartment; String? get city; String? get area; String? get notes; double? get lat; double? get lng;
/// Create a copy of OrderDeliveryAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderDeliveryAddressCopyWith<OrderDeliveryAddress> get copyWith => _$OrderDeliveryAddressCopyWithImpl<OrderDeliveryAddress>(this as OrderDeliveryAddress, _$identity);

  /// Serializes this OrderDeliveryAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrderDeliveryAddress;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderDeliveryAddress&&(identical(other.label, _this.label) || other.label == _this.label)&&(identical(other.street, _this.street) || other.street == _this.street)&&(identical(other.building, _this.building) || other.building == _this.building)&&(identical(other.floor, _this.floor) || other.floor == _this.floor)&&(identical(other.apartment, _this.apartment) || other.apartment == _this.apartment)&&(identical(other.city, _this.city) || other.city == _this.city)&&(identical(other.area, _this.area) || other.area == _this.area)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&(identical(other.lat, _this.lat) || other.lat == _this.lat)&&(identical(other.lng, _this.lng) || other.lng == _this.lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrderDeliveryAddress;
  return Object.hash(runtimeType,_this.label,_this.street,_this.building,_this.floor,_this.apartment,_this.city,_this.area,_this.notes,_this.lat,_this.lng);
}

@override
String toString() {
  final _this = this as OrderDeliveryAddress;
  return 'OrderDeliveryAddress(label: ${_this.label}, street: ${_this.street}, building: ${_this.building}, floor: ${_this.floor}, apartment: ${_this.apartment}, city: ${_this.city}, area: ${_this.area}, notes: ${_this.notes}, lat: ${_this.lat}, lng: ${_this.lng})';
}


}

/// @nodoc
abstract mixin class $OrderDeliveryAddressCopyWith<$Res>  {
  factory $OrderDeliveryAddressCopyWith(OrderDeliveryAddress value, $Res Function(OrderDeliveryAddress) _then) = _$OrderDeliveryAddressCopyWithImpl;
@useResult
$Res call({
 String? label, String? street, String? building, String? floor, String? apartment, String? city, String? area, String? notes, double? lat, double? lng
});




}
/// @nodoc
class _$OrderDeliveryAddressCopyWithImpl<$Res>
    implements $OrderDeliveryAddressCopyWith<$Res> {
  _$OrderDeliveryAddressCopyWithImpl(this._self, this._then);

  final OrderDeliveryAddress _self;
  final $Res Function(OrderDeliveryAddress) _then;

/// Create a copy of OrderDeliveryAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = freezed,Object? street = freezed,Object? building = freezed,Object? floor = freezed,Object? apartment = freezed,Object? city = freezed,Object? area = freezed,Object? notes = freezed,Object? lat = freezed,Object? lng = freezed,}) {
  return _then(OrderDeliveryAddress(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,building: freezed == building ? _self.building : building // ignore: cast_nullable_to_non_nullable
as String?,floor: freezed == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as String?,apartment: freezed == apartment ? _self.apartment : apartment // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderDeliveryAddress].
extension OrderDeliveryAddressPatterns on OrderDeliveryAddress {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderDeliveryAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderDeliveryAddress() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderDeliveryAddress value)  $default,){
final _that = this;
switch (_that) {
case _OrderDeliveryAddress():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderDeliveryAddress value)?  $default,){
final _that = this;
switch (_that) {
case _OrderDeliveryAddress() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? label,  String? street,  String? building,  String? floor,  String? apartment,  String? city,  String? area,  String? notes,  double? lat,  double? lng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderDeliveryAddress() when $default != null:
return $default(_that.label,_that.street,_that.building,_that.floor,_that.apartment,_that.city,_that.area,_that.notes,_that.lat,_that.lng);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? label,  String? street,  String? building,  String? floor,  String? apartment,  String? city,  String? area,  String? notes,  double? lat,  double? lng)  $default,) {final _that = this;
switch (_that) {
case _OrderDeliveryAddress():
return $default(_that.label,_that.street,_that.building,_that.floor,_that.apartment,_that.city,_that.area,_that.notes,_that.lat,_that.lng);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? label,  String? street,  String? building,  String? floor,  String? apartment,  String? city,  String? area,  String? notes,  double? lat,  double? lng)?  $default,) {final _that = this;
switch (_that) {
case _OrderDeliveryAddress() when $default != null:
return $default(_that.label,_that.street,_that.building,_that.floor,_that.apartment,_that.city,_that.area,_that.notes,_that.lat,_that.lng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderDeliveryAddress implements OrderDeliveryAddress {
  const _OrderDeliveryAddress({this.label, this.street, this.building, this.floor, this.apartment, this.city, this.area, this.notes, this.lat, this.lng});
  factory _OrderDeliveryAddress.fromJson(Map<String, dynamic> json) => _$OrderDeliveryAddressFromJson(json);

@override final  String? label;
@override final  String? street;
@override final  String? building;
@override final  String? floor;
@override final  String? apartment;
@override final  String? city;
@override final  String? area;
@override final  String? notes;
@override final  double? lat;
@override final  double? lng;

/// Create a copy of OrderDeliveryAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderDeliveryAddressCopyWith<_OrderDeliveryAddress> get copyWith => __$OrderDeliveryAddressCopyWithImpl<_OrderDeliveryAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderDeliveryAddressToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderDeliveryAddress&&(identical(other.label, label) || other.label == label)&&(identical(other.street, street) || other.street == street)&&(identical(other.building, building) || other.building == building)&&(identical(other.floor, floor) || other.floor == floor)&&(identical(other.apartment, apartment) || other.apartment == apartment)&&(identical(other.city, city) || other.city == city)&&(identical(other.area, area) || other.area == area)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,label,street,building,floor,apartment,city,area,notes,lat,lng);
}

@override
String toString() {
    return 'OrderDeliveryAddress(label: $label, street: $street, building: $building, floor: $floor, apartment: $apartment, city: $city, area: $area, notes: $notes, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class _$OrderDeliveryAddressCopyWith<$Res> implements $OrderDeliveryAddressCopyWith<$Res> {
  factory _$OrderDeliveryAddressCopyWith(_OrderDeliveryAddress value, $Res Function(_OrderDeliveryAddress) _then) = __$OrderDeliveryAddressCopyWithImpl;
@override @useResult
$Res call({
 String? label, String? street, String? building, String? floor, String? apartment, String? city, String? area, String? notes, double? lat, double? lng
});




}
/// @nodoc
class __$OrderDeliveryAddressCopyWithImpl<$Res>
    implements _$OrderDeliveryAddressCopyWith<$Res> {
  __$OrderDeliveryAddressCopyWithImpl(this._self, this._then);

  final _OrderDeliveryAddress _self;
  final $Res Function(_OrderDeliveryAddress) _then;

/// Create a copy of OrderDeliveryAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = freezed,Object? street = freezed,Object? building = freezed,Object? floor = freezed,Object? apartment = freezed,Object? city = freezed,Object? area = freezed,Object? notes = freezed,Object? lat = freezed,Object? lng = freezed,}) {
  return _then(_OrderDeliveryAddress(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,building: freezed == building ? _self.building : building // ignore: cast_nullable_to_non_nullable
as String?,floor: freezed == floor ? _self.floor : floor // ignore: cast_nullable_to_non_nullable
as String?,apartment: freezed == apartment ? _self.apartment : apartment // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$OrderDeliveryTier {

 String get id; double get minDistanceKm; double get maxDistanceKm;
/// Create a copy of OrderDeliveryTier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderDeliveryTierCopyWith<OrderDeliveryTier> get copyWith => _$OrderDeliveryTierCopyWithImpl<OrderDeliveryTier>(this as OrderDeliveryTier, _$identity);

  /// Serializes this OrderDeliveryTier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrderDeliveryTier;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderDeliveryTier&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.minDistanceKm, _this.minDistanceKm) || other.minDistanceKm == _this.minDistanceKm)&&(identical(other.maxDistanceKm, _this.maxDistanceKm) || other.maxDistanceKm == _this.maxDistanceKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrderDeliveryTier;
  return Object.hash(runtimeType,_this.id,_this.minDistanceKm,_this.maxDistanceKm);
}

@override
String toString() {
  final _this = this as OrderDeliveryTier;
  return 'OrderDeliveryTier(id: ${_this.id}, minDistanceKm: ${_this.minDistanceKm}, maxDistanceKm: ${_this.maxDistanceKm})';
}


}

/// @nodoc
abstract mixin class $OrderDeliveryTierCopyWith<$Res>  {
  factory $OrderDeliveryTierCopyWith(OrderDeliveryTier value, $Res Function(OrderDeliveryTier) _then) = _$OrderDeliveryTierCopyWithImpl;
@useResult
$Res call({
 String id, double minDistanceKm, double maxDistanceKm
});




}
/// @nodoc
class _$OrderDeliveryTierCopyWithImpl<$Res>
    implements $OrderDeliveryTierCopyWith<$Res> {
  _$OrderDeliveryTierCopyWithImpl(this._self, this._then);

  final OrderDeliveryTier _self;
  final $Res Function(OrderDeliveryTier) _then;

/// Create a copy of OrderDeliveryTier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? minDistanceKm = null,Object? maxDistanceKm = null,}) {
  return _then(OrderDeliveryTier(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,minDistanceKm: null == minDistanceKm ? _self.minDistanceKm : minDistanceKm // ignore: cast_nullable_to_non_nullable
as double,maxDistanceKm: null == maxDistanceKm ? _self.maxDistanceKm : maxDistanceKm // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderDeliveryTier].
extension OrderDeliveryTierPatterns on OrderDeliveryTier {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderDeliveryTier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderDeliveryTier() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderDeliveryTier value)  $default,){
final _that = this;
switch (_that) {
case _OrderDeliveryTier():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderDeliveryTier value)?  $default,){
final _that = this;
switch (_that) {
case _OrderDeliveryTier() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double minDistanceKm,  double maxDistanceKm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderDeliveryTier() when $default != null:
return $default(_that.id,_that.minDistanceKm,_that.maxDistanceKm);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double minDistanceKm,  double maxDistanceKm)  $default,) {final _that = this;
switch (_that) {
case _OrderDeliveryTier():
return $default(_that.id,_that.minDistanceKm,_that.maxDistanceKm);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double minDistanceKm,  double maxDistanceKm)?  $default,) {final _that = this;
switch (_that) {
case _OrderDeliveryTier() when $default != null:
return $default(_that.id,_that.minDistanceKm,_that.maxDistanceKm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderDeliveryTier implements OrderDeliveryTier {
  const _OrderDeliveryTier({required this.id, required this.minDistanceKm, required this.maxDistanceKm});
  factory _OrderDeliveryTier.fromJson(Map<String, dynamic> json) => _$OrderDeliveryTierFromJson(json);

@override final  String id;
@override final  double minDistanceKm;
@override final  double maxDistanceKm;

/// Create a copy of OrderDeliveryTier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderDeliveryTierCopyWith<_OrderDeliveryTier> get copyWith => __$OrderDeliveryTierCopyWithImpl<_OrderDeliveryTier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderDeliveryTierToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderDeliveryTier&&(identical(other.id, id) || other.id == id)&&(identical(other.minDistanceKm, minDistanceKm) || other.minDistanceKm == minDistanceKm)&&(identical(other.maxDistanceKm, maxDistanceKm) || other.maxDistanceKm == maxDistanceKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,minDistanceKm,maxDistanceKm);
}

@override
String toString() {
    return 'OrderDeliveryTier(id: $id, minDistanceKm: $minDistanceKm, maxDistanceKm: $maxDistanceKm)';
}


}

/// @nodoc
abstract mixin class _$OrderDeliveryTierCopyWith<$Res> implements $OrderDeliveryTierCopyWith<$Res> {
  factory _$OrderDeliveryTierCopyWith(_OrderDeliveryTier value, $Res Function(_OrderDeliveryTier) _then) = __$OrderDeliveryTierCopyWithImpl;
@override @useResult
$Res call({
 String id, double minDistanceKm, double maxDistanceKm
});




}
/// @nodoc
class __$OrderDeliveryTierCopyWithImpl<$Res>
    implements _$OrderDeliveryTierCopyWith<$Res> {
  __$OrderDeliveryTierCopyWithImpl(this._self, this._then);

  final _OrderDeliveryTier _self;
  final $Res Function(_OrderDeliveryTier) _then;

/// Create a copy of OrderDeliveryTier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? minDistanceKm = null,Object? maxDistanceKm = null,}) {
  return _then(_OrderDeliveryTier(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,minDistanceKm: null == minDistanceKm ? _self.minDistanceKm : minDistanceKm // ignore: cast_nullable_to_non_nullable
as double,maxDistanceKm: null == maxDistanceKm ? _self.maxDistanceKm : maxDistanceKm // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$OrderDeliveryZoneSnapshot {

 String get id; String get nameAr; String get nameEn;
/// Create a copy of OrderDeliveryZoneSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderDeliveryZoneSnapshotCopyWith<OrderDeliveryZoneSnapshot> get copyWith => _$OrderDeliveryZoneSnapshotCopyWithImpl<OrderDeliveryZoneSnapshot>(this as OrderDeliveryZoneSnapshot, _$identity);

  /// Serializes this OrderDeliveryZoneSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrderDeliveryZoneSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderDeliveryZoneSnapshot&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nameAr, _this.nameAr) || other.nameAr == _this.nameAr)&&(identical(other.nameEn, _this.nameEn) || other.nameEn == _this.nameEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrderDeliveryZoneSnapshot;
  return Object.hash(runtimeType,_this.id,_this.nameAr,_this.nameEn);
}

@override
String toString() {
  final _this = this as OrderDeliveryZoneSnapshot;
  return 'OrderDeliveryZoneSnapshot(id: ${_this.id}, nameAr: ${_this.nameAr}, nameEn: ${_this.nameEn})';
}


}

/// @nodoc
abstract mixin class $OrderDeliveryZoneSnapshotCopyWith<$Res>  {
  factory $OrderDeliveryZoneSnapshotCopyWith(OrderDeliveryZoneSnapshot value, $Res Function(OrderDeliveryZoneSnapshot) _then) = _$OrderDeliveryZoneSnapshotCopyWithImpl;
@useResult
$Res call({
 String id, String nameAr, String nameEn
});




}
/// @nodoc
class _$OrderDeliveryZoneSnapshotCopyWithImpl<$Res>
    implements $OrderDeliveryZoneSnapshotCopyWith<$Res> {
  _$OrderDeliveryZoneSnapshotCopyWithImpl(this._self, this._then);

  final OrderDeliveryZoneSnapshot _self;
  final $Res Function(OrderDeliveryZoneSnapshot) _then;

/// Create a copy of OrderDeliveryZoneSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameAr = null,Object? nameEn = null,}) {
  return _then(OrderDeliveryZoneSnapshot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderDeliveryZoneSnapshot].
extension OrderDeliveryZoneSnapshotPatterns on OrderDeliveryZoneSnapshot {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderDeliveryZoneSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderDeliveryZoneSnapshot() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderDeliveryZoneSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _OrderDeliveryZoneSnapshot():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderDeliveryZoneSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _OrderDeliveryZoneSnapshot() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nameAr,  String nameEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderDeliveryZoneSnapshot() when $default != null:
return $default(_that.id,_that.nameAr,_that.nameEn);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nameAr,  String nameEn)  $default,) {final _that = this;
switch (_that) {
case _OrderDeliveryZoneSnapshot():
return $default(_that.id,_that.nameAr,_that.nameEn);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nameAr,  String nameEn)?  $default,) {final _that = this;
switch (_that) {
case _OrderDeliveryZoneSnapshot() when $default != null:
return $default(_that.id,_that.nameAr,_that.nameEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderDeliveryZoneSnapshot implements OrderDeliveryZoneSnapshot {
  const _OrderDeliveryZoneSnapshot({required this.id, required this.nameAr, required this.nameEn});
  factory _OrderDeliveryZoneSnapshot.fromJson(Map<String, dynamic> json) => _$OrderDeliveryZoneSnapshotFromJson(json);

@override final  String id;
@override final  String nameAr;
@override final  String nameEn;

/// Create a copy of OrderDeliveryZoneSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderDeliveryZoneSnapshotCopyWith<_OrderDeliveryZoneSnapshot> get copyWith => __$OrderDeliveryZoneSnapshotCopyWithImpl<_OrderDeliveryZoneSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderDeliveryZoneSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderDeliveryZoneSnapshot&&(identical(other.id, id) || other.id == id)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nameAr,nameEn);
}

@override
String toString() {
    return 'OrderDeliveryZoneSnapshot(id: $id, nameAr: $nameAr, nameEn: $nameEn)';
}


}

/// @nodoc
abstract mixin class _$OrderDeliveryZoneSnapshotCopyWith<$Res> implements $OrderDeliveryZoneSnapshotCopyWith<$Res> {
  factory _$OrderDeliveryZoneSnapshotCopyWith(_OrderDeliveryZoneSnapshot value, $Res Function(_OrderDeliveryZoneSnapshot) _then) = __$OrderDeliveryZoneSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameAr, String nameEn
});




}
/// @nodoc
class __$OrderDeliveryZoneSnapshotCopyWithImpl<$Res>
    implements _$OrderDeliveryZoneSnapshotCopyWith<$Res> {
  __$OrderDeliveryZoneSnapshotCopyWithImpl(this._self, this._then);

  final _OrderDeliveryZoneSnapshot _self;
  final $Res Function(_OrderDeliveryZoneSnapshot) _then;

/// Create a copy of OrderDeliveryZoneSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameAr = null,Object? nameEn = null,}) {
  return _then(_OrderDeliveryZoneSnapshot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$LoyaltyRedemptionInfo {

 String get rewardId; String get rewardName; int get pointsRedeemed;
/// Create a copy of LoyaltyRedemptionInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoyaltyRedemptionInfoCopyWith<LoyaltyRedemptionInfo> get copyWith => _$LoyaltyRedemptionInfoCopyWithImpl<LoyaltyRedemptionInfo>(this as LoyaltyRedemptionInfo, _$identity);

  /// Serializes this LoyaltyRedemptionInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoyaltyRedemptionInfo;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoyaltyRedemptionInfo&&(identical(other.rewardId, _this.rewardId) || other.rewardId == _this.rewardId)&&(identical(other.rewardName, _this.rewardName) || other.rewardName == _this.rewardName)&&(identical(other.pointsRedeemed, _this.pointsRedeemed) || other.pointsRedeemed == _this.pointsRedeemed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoyaltyRedemptionInfo;
  return Object.hash(runtimeType,_this.rewardId,_this.rewardName,_this.pointsRedeemed);
}

@override
String toString() {
  final _this = this as LoyaltyRedemptionInfo;
  return 'LoyaltyRedemptionInfo(rewardId: ${_this.rewardId}, rewardName: ${_this.rewardName}, pointsRedeemed: ${_this.pointsRedeemed})';
}


}

/// @nodoc
abstract mixin class $LoyaltyRedemptionInfoCopyWith<$Res>  {
  factory $LoyaltyRedemptionInfoCopyWith(LoyaltyRedemptionInfo value, $Res Function(LoyaltyRedemptionInfo) _then) = _$LoyaltyRedemptionInfoCopyWithImpl;
@useResult
$Res call({
 String rewardId, String rewardName, int pointsRedeemed
});




}
/// @nodoc
class _$LoyaltyRedemptionInfoCopyWithImpl<$Res>
    implements $LoyaltyRedemptionInfoCopyWith<$Res> {
  _$LoyaltyRedemptionInfoCopyWithImpl(this._self, this._then);

  final LoyaltyRedemptionInfo _self;
  final $Res Function(LoyaltyRedemptionInfo) _then;

/// Create a copy of LoyaltyRedemptionInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rewardId = null,Object? rewardName = null,Object? pointsRedeemed = null,}) {
  return _then(LoyaltyRedemptionInfo(
rewardId: null == rewardId ? _self.rewardId : rewardId // ignore: cast_nullable_to_non_nullable
as String,rewardName: null == rewardName ? _self.rewardName : rewardName // ignore: cast_nullable_to_non_nullable
as String,pointsRedeemed: null == pointsRedeemed ? _self.pointsRedeemed : pointsRedeemed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LoyaltyRedemptionInfo].
extension LoyaltyRedemptionInfoPatterns on LoyaltyRedemptionInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoyaltyRedemptionInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoyaltyRedemptionInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoyaltyRedemptionInfo value)  $default,){
final _that = this;
switch (_that) {
case _LoyaltyRedemptionInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoyaltyRedemptionInfo value)?  $default,){
final _that = this;
switch (_that) {
case _LoyaltyRedemptionInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rewardId,  String rewardName,  int pointsRedeemed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoyaltyRedemptionInfo() when $default != null:
return $default(_that.rewardId,_that.rewardName,_that.pointsRedeemed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rewardId,  String rewardName,  int pointsRedeemed)  $default,) {final _that = this;
switch (_that) {
case _LoyaltyRedemptionInfo():
return $default(_that.rewardId,_that.rewardName,_that.pointsRedeemed);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rewardId,  String rewardName,  int pointsRedeemed)?  $default,) {final _that = this;
switch (_that) {
case _LoyaltyRedemptionInfo() when $default != null:
return $default(_that.rewardId,_that.rewardName,_that.pointsRedeemed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoyaltyRedemptionInfo implements LoyaltyRedemptionInfo {
  const _LoyaltyRedemptionInfo({required this.rewardId, required this.rewardName, required this.pointsRedeemed});
  factory _LoyaltyRedemptionInfo.fromJson(Map<String, dynamic> json) => _$LoyaltyRedemptionInfoFromJson(json);

@override final  String rewardId;
@override final  String rewardName;
@override final  int pointsRedeemed;

/// Create a copy of LoyaltyRedemptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoyaltyRedemptionInfoCopyWith<_LoyaltyRedemptionInfo> get copyWith => __$LoyaltyRedemptionInfoCopyWithImpl<_LoyaltyRedemptionInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoyaltyRedemptionInfoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoyaltyRedemptionInfo&&(identical(other.rewardId, rewardId) || other.rewardId == rewardId)&&(identical(other.rewardName, rewardName) || other.rewardName == rewardName)&&(identical(other.pointsRedeemed, pointsRedeemed) || other.pointsRedeemed == pointsRedeemed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,rewardId,rewardName,pointsRedeemed);
}

@override
String toString() {
    return 'LoyaltyRedemptionInfo(rewardId: $rewardId, rewardName: $rewardName, pointsRedeemed: $pointsRedeemed)';
}


}

/// @nodoc
abstract mixin class _$LoyaltyRedemptionInfoCopyWith<$Res> implements $LoyaltyRedemptionInfoCopyWith<$Res> {
  factory _$LoyaltyRedemptionInfoCopyWith(_LoyaltyRedemptionInfo value, $Res Function(_LoyaltyRedemptionInfo) _then) = __$LoyaltyRedemptionInfoCopyWithImpl;
@override @useResult
$Res call({
 String rewardId, String rewardName, int pointsRedeemed
});




}
/// @nodoc
class __$LoyaltyRedemptionInfoCopyWithImpl<$Res>
    implements _$LoyaltyRedemptionInfoCopyWith<$Res> {
  __$LoyaltyRedemptionInfoCopyWithImpl(this._self, this._then);

  final _LoyaltyRedemptionInfo _self;
  final $Res Function(_LoyaltyRedemptionInfo) _then;

/// Create a copy of LoyaltyRedemptionInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rewardId = null,Object? rewardName = null,Object? pointsRedeemed = null,}) {
  return _then(_LoyaltyRedemptionInfo(
rewardId: null == rewardId ? _self.rewardId : rewardId // ignore: cast_nullable_to_non_nullable
as String,rewardName: null == rewardName ? _self.rewardName : rewardName // ignore: cast_nullable_to_non_nullable
as String,pointsRedeemed: null == pointsRedeemed ? _self.pointsRedeemed : pointsRedeemed // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OrderItem {

 String? get menuItemId; String? get variantRefId; List<String> get addonRefIds; String get name; String get imageUrl; double get basePrice; double get unitPrice; int get quantity; Map<String, List<String>> get selectedOptions; Map<String, Map<String, List<String>>> get nestedSelections; Map<String, int> get extraQuantities; List<String> get removedIngredients; String get specialInstructions; String get formattedConfiguration; double get lineTotal;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);

  /// Serializes this OrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrderItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.variantRefId, _this.variantRefId) || other.variantRefId == _this.variantRefId)&&const DeepCollectionEquality().equals(other.addonRefIds, _this.addonRefIds)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.basePrice, _this.basePrice) || other.basePrice == _this.basePrice)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&const DeepCollectionEquality().equals(other.selectedOptions, _this.selectedOptions)&&const DeepCollectionEquality().equals(other.nestedSelections, _this.nestedSelections)&&const DeepCollectionEquality().equals(other.extraQuantities, _this.extraQuantities)&&const DeepCollectionEquality().equals(other.removedIngredients, _this.removedIngredients)&&(identical(other.specialInstructions, _this.specialInstructions) || other.specialInstructions == _this.specialInstructions)&&(identical(other.formattedConfiguration, _this.formattedConfiguration) || other.formattedConfiguration == _this.formattedConfiguration)&&(identical(other.lineTotal, _this.lineTotal) || other.lineTotal == _this.lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrderItem;
  return Object.hash(runtimeType,_this.menuItemId,_this.variantRefId,const DeepCollectionEquality().hash(_this.addonRefIds),_this.name,_this.imageUrl,_this.basePrice,_this.unitPrice,_this.quantity,const DeepCollectionEquality().hash(_this.selectedOptions),const DeepCollectionEquality().hash(_this.nestedSelections),const DeepCollectionEquality().hash(_this.extraQuantities),const DeepCollectionEquality().hash(_this.removedIngredients),_this.specialInstructions,_this.formattedConfiguration,_this.lineTotal);
}

@override
String toString() {
  final _this = this as OrderItem;
  return 'OrderItem(menuItemId: ${_this.menuItemId}, variantRefId: ${_this.variantRefId}, addonRefIds: ${_this.addonRefIds}, name: ${_this.name}, imageUrl: ${_this.imageUrl}, basePrice: ${_this.basePrice}, unitPrice: ${_this.unitPrice}, quantity: ${_this.quantity}, selectedOptions: ${_this.selectedOptions}, nestedSelections: ${_this.nestedSelections}, extraQuantities: ${_this.extraQuantities}, removedIngredients: ${_this.removedIngredients}, specialInstructions: ${_this.specialInstructions}, formattedConfiguration: ${_this.formattedConfiguration}, lineTotal: ${_this.lineTotal})';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
 String? menuItemId, String? variantRefId, List<String> addonRefIds, String name, String imageUrl, double basePrice, double unitPrice, int quantity, Map<String, List<String>> selectedOptions, Map<String, Map<String, List<String>>> nestedSelections, Map<String, int> extraQuantities, List<String> removedIngredients, String specialInstructions, String formattedConfiguration, double lineTotal
});




}
/// @nodoc
class _$OrderItemCopyWithImpl<$Res>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._self, this._then);

  final OrderItem _self;
  final $Res Function(OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menuItemId = freezed,Object? variantRefId = freezed,Object? addonRefIds = null,Object? name = null,Object? imageUrl = null,Object? basePrice = null,Object? unitPrice = null,Object? quantity = null,Object? selectedOptions = null,Object? nestedSelections = null,Object? extraQuantities = null,Object? removedIngredients = null,Object? specialInstructions = null,Object? formattedConfiguration = null,Object? lineTotal = null,}) {
  return _then(OrderItem(
menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String?,variantRefId: freezed == variantRefId ? _self.variantRefId : variantRefId // ignore: cast_nullable_to_non_nullable
as String?,addonRefIds: null == addonRefIds ? _self.addonRefIds : addonRefIds // ignore: cast_nullable_to_non_nullable
as List<String>,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,selectedOptions: null == selectedOptions ? _self.selectedOptions : selectedOptions // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,nestedSelections: null == nestedSelections ? _self.nestedSelections : nestedSelections // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, List<String>>>,extraQuantities: null == extraQuantities ? _self.extraQuantities : extraQuantities // ignore: cast_nullable_to_non_nullable
as Map<String, int>,removedIngredients: null == removedIngredients ? _self.removedIngredients : removedIngredients // ignore: cast_nullable_to_non_nullable
as List<String>,specialInstructions: null == specialInstructions ? _self.specialInstructions : specialInstructions // ignore: cast_nullable_to_non_nullable
as String,formattedConfiguration: null == formattedConfiguration ? _self.formattedConfiguration : formattedConfiguration // ignore: cast_nullable_to_non_nullable
as String,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItem].
extension OrderItemPatterns on OrderItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? menuItemId,  String? variantRefId,  List<String> addonRefIds,  String name,  String imageUrl,  double basePrice,  double unitPrice,  int quantity,  Map<String, List<String>> selectedOptions,  Map<String, Map<String, List<String>>> nestedSelections,  Map<String, int> extraQuantities,  List<String> removedIngredients,  String specialInstructions,  String formattedConfiguration,  double lineTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.menuItemId,_that.variantRefId,_that.addonRefIds,_that.name,_that.imageUrl,_that.basePrice,_that.unitPrice,_that.quantity,_that.selectedOptions,_that.nestedSelections,_that.extraQuantities,_that.removedIngredients,_that.specialInstructions,_that.formattedConfiguration,_that.lineTotal);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? menuItemId,  String? variantRefId,  List<String> addonRefIds,  String name,  String imageUrl,  double basePrice,  double unitPrice,  int quantity,  Map<String, List<String>> selectedOptions,  Map<String, Map<String, List<String>>> nestedSelections,  Map<String, int> extraQuantities,  List<String> removedIngredients,  String specialInstructions,  String formattedConfiguration,  double lineTotal)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.menuItemId,_that.variantRefId,_that.addonRefIds,_that.name,_that.imageUrl,_that.basePrice,_that.unitPrice,_that.quantity,_that.selectedOptions,_that.nestedSelections,_that.extraQuantities,_that.removedIngredients,_that.specialInstructions,_that.formattedConfiguration,_that.lineTotal);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? menuItemId,  String? variantRefId,  List<String> addonRefIds,  String name,  String imageUrl,  double basePrice,  double unitPrice,  int quantity,  Map<String, List<String>> selectedOptions,  Map<String, Map<String, List<String>>> nestedSelections,  Map<String, int> extraQuantities,  List<String> removedIngredients,  String specialInstructions,  String formattedConfiguration,  double lineTotal)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.menuItemId,_that.variantRefId,_that.addonRefIds,_that.name,_that.imageUrl,_that.basePrice,_that.unitPrice,_that.quantity,_that.selectedOptions,_that.nestedSelections,_that.extraQuantities,_that.removedIngredients,_that.specialInstructions,_that.formattedConfiguration,_that.lineTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderItem implements OrderItem {
  const _OrderItem({this.menuItemId, this.variantRefId,  List<String> addonRefIds = const [], required this.name, required this.imageUrl, required this.basePrice, required this.unitPrice, required this.quantity,  Map<String, List<String>> selectedOptions = const {},  Map<String, Map<String, List<String>>> nestedSelections = const {},  Map<String, int> extraQuantities = const {},  List<String> removedIngredients = const [], this.specialInstructions = '', this.formattedConfiguration = '', required this.lineTotal}): _addonRefIds = addonRefIds,_selectedOptions = selectedOptions,_nestedSelections = nestedSelections,_extraQuantities = extraQuantities,_removedIngredients = removedIngredients;
  factory _OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);

@override final  String? menuItemId;
@override final  String? variantRefId;
 final  List<String> _addonRefIds;
@override@JsonKey() List<String> get addonRefIds {
  if (_addonRefIds is EqualUnmodifiableListView) return _addonRefIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addonRefIds);
}

@override final  String name;
@override final  String imageUrl;
@override final  double basePrice;
@override final  double unitPrice;
@override final  int quantity;
 final  Map<String, List<String>> _selectedOptions;
@override@JsonKey() Map<String, List<String>> get selectedOptions {
  if (_selectedOptions is EqualUnmodifiableMapView) return _selectedOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedOptions);
}

 final  Map<String, Map<String, List<String>>> _nestedSelections;
@override@JsonKey() Map<String, Map<String, List<String>>> get nestedSelections {
  if (_nestedSelections is EqualUnmodifiableMapView) return _nestedSelections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_nestedSelections);
}

 final  Map<String, int> _extraQuantities;
@override@JsonKey() Map<String, int> get extraQuantities {
  if (_extraQuantities is EqualUnmodifiableMapView) return _extraQuantities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extraQuantities);
}

 final  List<String> _removedIngredients;
@override@JsonKey() List<String> get removedIngredients {
  if (_removedIngredients is EqualUnmodifiableListView) return _removedIngredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_removedIngredients);
}

@override@JsonKey() final  String specialInstructions;
@override@JsonKey() final  String formattedConfiguration;
@override final  double lineTotal;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.variantRefId, variantRefId) || other.variantRefId == variantRefId)&&const DeepCollectionEquality().equals(other.addonRefIds, _addonRefIds)&&(identical(other.name, name) || other.name == name)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&const DeepCollectionEquality().equals(other.selectedOptions, _selectedOptions)&&const DeepCollectionEquality().equals(other.nestedSelections, _nestedSelections)&&const DeepCollectionEquality().equals(other.extraQuantities, _extraQuantities)&&const DeepCollectionEquality().equals(other.removedIngredients, _removedIngredients)&&(identical(other.specialInstructions, specialInstructions) || other.specialInstructions == specialInstructions)&&(identical(other.formattedConfiguration, formattedConfiguration) || other.formattedConfiguration == formattedConfiguration)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,menuItemId,variantRefId,const DeepCollectionEquality().hash(_addonRefIds),name,imageUrl,basePrice,unitPrice,quantity,const DeepCollectionEquality().hash(_selectedOptions),const DeepCollectionEquality().hash(_nestedSelections),const DeepCollectionEquality().hash(_extraQuantities),const DeepCollectionEquality().hash(_removedIngredients),specialInstructions,formattedConfiguration,lineTotal);
}

@override
String toString() {
    return 'OrderItem(menuItemId: $menuItemId, variantRefId: $variantRefId, addonRefIds: $addonRefIds, name: $name, imageUrl: $imageUrl, basePrice: $basePrice, unitPrice: $unitPrice, quantity: $quantity, selectedOptions: $selectedOptions, nestedSelections: $nestedSelections, extraQuantities: $extraQuantities, removedIngredients: $removedIngredients, specialInstructions: $specialInstructions, formattedConfiguration: $formattedConfiguration, lineTotal: $lineTotal)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
 String? menuItemId, String? variantRefId, List<String> addonRefIds, String name, String imageUrl, double basePrice, double unitPrice, int quantity, Map<String, List<String>> selectedOptions, Map<String, Map<String, List<String>>> nestedSelections, Map<String, int> extraQuantities, List<String> removedIngredients, String specialInstructions, String formattedConfiguration, double lineTotal
});




}
/// @nodoc
class __$OrderItemCopyWithImpl<$Res>
    implements _$OrderItemCopyWith<$Res> {
  __$OrderItemCopyWithImpl(this._self, this._then);

  final _OrderItem _self;
  final $Res Function(_OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menuItemId = freezed,Object? variantRefId = freezed,Object? addonRefIds = null,Object? name = null,Object? imageUrl = null,Object? basePrice = null,Object? unitPrice = null,Object? quantity = null,Object? selectedOptions = null,Object? nestedSelections = null,Object? extraQuantities = null,Object? removedIngredients = null,Object? specialInstructions = null,Object? formattedConfiguration = null,Object? lineTotal = null,}) {
  return _then(_OrderItem(
menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String?,variantRefId: freezed == variantRefId ? _self.variantRefId : variantRefId // ignore: cast_nullable_to_non_nullable
as String?,addonRefIds: null == addonRefIds ? _self._addonRefIds : addonRefIds // ignore: cast_nullable_to_non_nullable
as List<String>,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,selectedOptions: null == selectedOptions ? _self._selectedOptions : selectedOptions // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,nestedSelections: null == nestedSelections ? _self._nestedSelections : nestedSelections // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, List<String>>>,extraQuantities: null == extraQuantities ? _self._extraQuantities : extraQuantities // ignore: cast_nullable_to_non_nullable
as Map<String, int>,removedIngredients: null == removedIngredients ? _self._removedIngredients : removedIngredients // ignore: cast_nullable_to_non_nullable
as List<String>,specialInstructions: null == specialInstructions ? _self.specialInstructions : specialInstructions // ignore: cast_nullable_to_non_nullable
as String,formattedConfiguration: null == formattedConfiguration ? _self.formattedConfiguration : formattedConfiguration // ignore: cast_nullable_to_non_nullable
as String,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$OrderStatusEntry {

 OrderStatus get status; DateTime get timestamp;
/// Create a copy of OrderStatusEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderStatusEntryCopyWith<OrderStatusEntry> get copyWith => _$OrderStatusEntryCopyWithImpl<OrderStatusEntry>(this as OrderStatusEntry, _$identity);

  /// Serializes this OrderStatusEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrderStatusEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderStatusEntry&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.timestamp, _this.timestamp) || other.timestamp == _this.timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrderStatusEntry;
  return Object.hash(runtimeType,_this.status,_this.timestamp);
}

@override
String toString() {
  final _this = this as OrderStatusEntry;
  return 'OrderStatusEntry(status: ${_this.status}, timestamp: ${_this.timestamp})';
}


}

/// @nodoc
abstract mixin class $OrderStatusEntryCopyWith<$Res>  {
  factory $OrderStatusEntryCopyWith(OrderStatusEntry value, $Res Function(OrderStatusEntry) _then) = _$OrderStatusEntryCopyWithImpl;
@useResult
$Res call({
 OrderStatus status, DateTime timestamp
});




}
/// @nodoc
class _$OrderStatusEntryCopyWithImpl<$Res>
    implements $OrderStatusEntryCopyWith<$Res> {
  _$OrderStatusEntryCopyWithImpl(this._self, this._then);

  final OrderStatusEntry _self;
  final $Res Function(OrderStatusEntry) _then;

/// Create a copy of OrderStatusEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? timestamp = null,}) {
  return _then(OrderStatusEntry(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderStatusEntry].
extension OrderStatusEntryPatterns on OrderStatusEntry {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderStatusEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderStatusEntry() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderStatusEntry value)  $default,){
final _that = this;
switch (_that) {
case _OrderStatusEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderStatusEntry value)?  $default,){
final _that = this;
switch (_that) {
case _OrderStatusEntry() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OrderStatus status,  DateTime timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderStatusEntry() when $default != null:
return $default(_that.status,_that.timestamp);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OrderStatus status,  DateTime timestamp)  $default,) {final _that = this;
switch (_that) {
case _OrderStatusEntry():
return $default(_that.status,_that.timestamp);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OrderStatus status,  DateTime timestamp)?  $default,) {final _that = this;
switch (_that) {
case _OrderStatusEntry() when $default != null:
return $default(_that.status,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderStatusEntry implements OrderStatusEntry {
  const _OrderStatusEntry({required this.status, required this.timestamp});
  factory _OrderStatusEntry.fromJson(Map<String, dynamic> json) => _$OrderStatusEntryFromJson(json);

@override final  OrderStatus status;
@override final  DateTime timestamp;

/// Create a copy of OrderStatusEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderStatusEntryCopyWith<_OrderStatusEntry> get copyWith => __$OrderStatusEntryCopyWithImpl<_OrderStatusEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderStatusEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderStatusEntry&&(identical(other.status, status) || other.status == status)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,status,timestamp);
}

@override
String toString() {
    return 'OrderStatusEntry(status: $status, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$OrderStatusEntryCopyWith<$Res> implements $OrderStatusEntryCopyWith<$Res> {
  factory _$OrderStatusEntryCopyWith(_OrderStatusEntry value, $Res Function(_OrderStatusEntry) _then) = __$OrderStatusEntryCopyWithImpl;
@override @useResult
$Res call({
 OrderStatus status, DateTime timestamp
});




}
/// @nodoc
class __$OrderStatusEntryCopyWithImpl<$Res>
    implements _$OrderStatusEntryCopyWith<$Res> {
  __$OrderStatusEntryCopyWithImpl(this._self, this._then);

  final _OrderStatusEntry _self;
  final $Res Function(_OrderStatusEntry) _then;

/// Create a copy of OrderStatusEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? timestamp = null,}) {
  return _then(_OrderStatusEntry(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
