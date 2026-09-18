// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverOrder {

 String get id; String get orderNumber; OrderStatus get status; List<OrderItem> get items; OrderDeliveryAddress? get deliveryAddress; FulfillmentType get deliveryMethod; String get customerName; String? get customerPhone; String get paymentMethod; String get paymentStatus; double get amountToCollect; double get totalAmount; DateTime get createdAt; int get assignmentVersion;
/// Create a copy of DriverOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverOrderCopyWith<DriverOrder> get copyWith => _$DriverOrderCopyWithImpl<DriverOrder>(this as DriverOrder, _$identity);

  /// Serializes this DriverOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DriverOrder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverOrder&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.orderNumber, _this.orderNumber) || other.orderNumber == _this.orderNumber)&&(identical(other.status, _this.status) || other.status == _this.status)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.deliveryAddress, _this.deliveryAddress) || other.deliveryAddress == _this.deliveryAddress)&&(identical(other.deliveryMethod, _this.deliveryMethod) || other.deliveryMethod == _this.deliveryMethod)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.customerPhone, _this.customerPhone) || other.customerPhone == _this.customerPhone)&&(identical(other.paymentMethod, _this.paymentMethod) || other.paymentMethod == _this.paymentMethod)&&(identical(other.paymentStatus, _this.paymentStatus) || other.paymentStatus == _this.paymentStatus)&&(identical(other.amountToCollect, _this.amountToCollect) || other.amountToCollect == _this.amountToCollect)&&(identical(other.totalAmount, _this.totalAmount) || other.totalAmount == _this.totalAmount)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.assignmentVersion, _this.assignmentVersion) || other.assignmentVersion == _this.assignmentVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DriverOrder;
  return Object.hash(runtimeType,_this.id,_this.orderNumber,_this.status,const DeepCollectionEquality().hash(_this.items),_this.deliveryAddress,_this.deliveryMethod,_this.customerName,_this.customerPhone,_this.paymentMethod,_this.paymentStatus,_this.amountToCollect,_this.totalAmount,_this.createdAt,_this.assignmentVersion);
}

@override
String toString() {
  final _this = this as DriverOrder;
  return 'DriverOrder(id: ${_this.id}, orderNumber: ${_this.orderNumber}, status: ${_this.status}, items: ${_this.items}, deliveryAddress: ${_this.deliveryAddress}, deliveryMethod: ${_this.deliveryMethod}, customerName: ${_this.customerName}, customerPhone: ${_this.customerPhone}, paymentMethod: ${_this.paymentMethod}, paymentStatus: ${_this.paymentStatus}, amountToCollect: ${_this.amountToCollect}, totalAmount: ${_this.totalAmount}, createdAt: ${_this.createdAt}, assignmentVersion: ${_this.assignmentVersion})';
}


}

/// @nodoc
abstract mixin class $DriverOrderCopyWith<$Res>  {
  factory $DriverOrderCopyWith(DriverOrder value, $Res Function(DriverOrder) _then) = _$DriverOrderCopyWithImpl;
@useResult
$Res call({
 String id, String orderNumber, OrderStatus status, List<OrderItem> items, OrderDeliveryAddress? deliveryAddress, FulfillmentType deliveryMethod, String customerName, String? customerPhone, String paymentMethod, String paymentStatus, double amountToCollect, double totalAmount, DateTime createdAt, int assignmentVersion
});


$OrderDeliveryAddressCopyWith<$Res>? get deliveryAddress;

}
/// @nodoc
class _$DriverOrderCopyWithImpl<$Res>
    implements $DriverOrderCopyWith<$Res> {
  _$DriverOrderCopyWithImpl(this._self, this._then);

  final DriverOrder _self;
  final $Res Function(DriverOrder) _then;

/// Create a copy of DriverOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? status = null,Object? items = null,Object? deliveryAddress = freezed,Object? deliveryMethod = null,Object? customerName = null,Object? customerPhone = freezed,Object? paymentMethod = null,Object? paymentStatus = null,Object? amountToCollect = null,Object? totalAmount = null,Object? createdAt = null,Object? assignmentVersion = null,}) {
  return _then(DriverOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as OrderDeliveryAddress?,deliveryMethod: null == deliveryMethod ? _self.deliveryMethod : deliveryMethod // ignore: cast_nullable_to_non_nullable
as FulfillmentType,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,amountToCollect: null == amountToCollect ? _self.amountToCollect : amountToCollect // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,assignmentVersion: null == assignmentVersion ? _self.assignmentVersion : assignmentVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of DriverOrder
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
}
}


/// Adds pattern-matching-related methods to [DriverOrder].
extension DriverOrderPatterns on DriverOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverOrder value)  $default,){
final _that = this;
switch (_that) {
case _DriverOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverOrder value)?  $default,){
final _that = this;
switch (_that) {
case _DriverOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orderNumber,  OrderStatus status,  List<OrderItem> items,  OrderDeliveryAddress? deliveryAddress,  FulfillmentType deliveryMethod,  String customerName,  String? customerPhone,  String paymentMethod,  String paymentStatus,  double amountToCollect,  double totalAmount,  DateTime createdAt,  int assignmentVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.status,_that.items,_that.deliveryAddress,_that.deliveryMethod,_that.customerName,_that.customerPhone,_that.paymentMethod,_that.paymentStatus,_that.amountToCollect,_that.totalAmount,_that.createdAt,_that.assignmentVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orderNumber,  OrderStatus status,  List<OrderItem> items,  OrderDeliveryAddress? deliveryAddress,  FulfillmentType deliveryMethod,  String customerName,  String? customerPhone,  String paymentMethod,  String paymentStatus,  double amountToCollect,  double totalAmount,  DateTime createdAt,  int assignmentVersion)  $default,) {final _that = this;
switch (_that) {
case _DriverOrder():
return $default(_that.id,_that.orderNumber,_that.status,_that.items,_that.deliveryAddress,_that.deliveryMethod,_that.customerName,_that.customerPhone,_that.paymentMethod,_that.paymentStatus,_that.amountToCollect,_that.totalAmount,_that.createdAt,_that.assignmentVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orderNumber,  OrderStatus status,  List<OrderItem> items,  OrderDeliveryAddress? deliveryAddress,  FulfillmentType deliveryMethod,  String customerName,  String? customerPhone,  String paymentMethod,  String paymentStatus,  double amountToCollect,  double totalAmount,  DateTime createdAt,  int assignmentVersion)?  $default,) {final _that = this;
switch (_that) {
case _DriverOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.status,_that.items,_that.deliveryAddress,_that.deliveryMethod,_that.customerName,_that.customerPhone,_that.paymentMethod,_that.paymentStatus,_that.amountToCollect,_that.totalAmount,_that.createdAt,_that.assignmentVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverOrder implements DriverOrder {
  const _DriverOrder({required this.id, required this.orderNumber, required this.status, required  List<OrderItem> items, this.deliveryAddress, required this.deliveryMethod, required this.customerName, this.customerPhone, required this.paymentMethod, required this.paymentStatus, required this.amountToCollect, required this.totalAmount, required this.createdAt, required this.assignmentVersion}): _items = items;
  factory _DriverOrder.fromJson(Map<String, dynamic> json) => _$DriverOrderFromJson(json);

@override final  String id;
@override final  String orderNumber;
@override final  OrderStatus status;
 final  List<OrderItem> _items;
@override List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  OrderDeliveryAddress? deliveryAddress;
@override final  FulfillmentType deliveryMethod;
@override final  String customerName;
@override final  String? customerPhone;
@override final  String paymentMethod;
@override final  String paymentStatus;
@override final  double amountToCollect;
@override final  double totalAmount;
@override final  DateTime createdAt;
@override final  int assignmentVersion;

/// Create a copy of DriverOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverOrderCopyWith<_DriverOrder> get copyWith => __$DriverOrderCopyWithImpl<_DriverOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverOrderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.deliveryAddress, deliveryAddress) || other.deliveryAddress == deliveryAddress)&&(identical(other.deliveryMethod, deliveryMethod) || other.deliveryMethod == deliveryMethod)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.amountToCollect, amountToCollect) || other.amountToCollect == amountToCollect)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.assignmentVersion, assignmentVersion) || other.assignmentVersion == assignmentVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,orderNumber,status,const DeepCollectionEquality().hash(_items),deliveryAddress,deliveryMethod,customerName,customerPhone,paymentMethod,paymentStatus,amountToCollect,totalAmount,createdAt,assignmentVersion);
}

@override
String toString() {
    return 'DriverOrder(id: $id, orderNumber: $orderNumber, status: $status, items: $items, deliveryAddress: $deliveryAddress, deliveryMethod: $deliveryMethod, customerName: $customerName, customerPhone: $customerPhone, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, amountToCollect: $amountToCollect, totalAmount: $totalAmount, createdAt: $createdAt, assignmentVersion: $assignmentVersion)';
}


}

/// @nodoc
abstract mixin class _$DriverOrderCopyWith<$Res> implements $DriverOrderCopyWith<$Res> {
  factory _$DriverOrderCopyWith(_DriverOrder value, $Res Function(_DriverOrder) _then) = __$DriverOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String orderNumber, OrderStatus status, List<OrderItem> items, OrderDeliveryAddress? deliveryAddress, FulfillmentType deliveryMethod, String customerName, String? customerPhone, String paymentMethod, String paymentStatus, double amountToCollect, double totalAmount, DateTime createdAt, int assignmentVersion
});


@override $OrderDeliveryAddressCopyWith<$Res>? get deliveryAddress;

}
/// @nodoc
class __$DriverOrderCopyWithImpl<$Res>
    implements _$DriverOrderCopyWith<$Res> {
  __$DriverOrderCopyWithImpl(this._self, this._then);

  final _DriverOrder _self;
  final $Res Function(_DriverOrder) _then;

/// Create a copy of DriverOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? status = null,Object? items = null,Object? deliveryAddress = freezed,Object? deliveryMethod = null,Object? customerName = null,Object? customerPhone = freezed,Object? paymentMethod = null,Object? paymentStatus = null,Object? amountToCollect = null,Object? totalAmount = null,Object? createdAt = null,Object? assignmentVersion = null,}) {
  return _then(_DriverOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,deliveryAddress: freezed == deliveryAddress ? _self.deliveryAddress : deliveryAddress // ignore: cast_nullable_to_non_nullable
as OrderDeliveryAddress?,deliveryMethod: null == deliveryMethod ? _self.deliveryMethod : deliveryMethod // ignore: cast_nullable_to_non_nullable
as FulfillmentType,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as String,amountToCollect: null == amountToCollect ? _self.amountToCollect : amountToCollect // ignore: cast_nullable_to_non_nullable
as double,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,assignmentVersion: null == assignmentVersion ? _self.assignmentVersion : assignmentVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of DriverOrder
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
}
}

// dart format on
