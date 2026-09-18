// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OrderNotification {

 String get id; String get type; String get title; String get body; String get orderId; String get customerId; String get customerName; String get orderNumber; double get totalAmount; bool get isRead; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of OrderNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderNotificationCopyWith<OrderNotification> get copyWith => _$OrderNotificationCopyWithImpl<OrderNotification>(this as OrderNotification, _$identity);

  /// Serializes this OrderNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrderNotification;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderNotification&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.customerId, _this.customerId) || other.customerId == _this.customerId)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.orderNumber, _this.orderNumber) || other.orderNumber == _this.orderNumber)&&(identical(other.totalAmount, _this.totalAmount) || other.totalAmount == _this.totalAmount)&&(identical(other.isRead, _this.isRead) || other.isRead == _this.isRead)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrderNotification;
  return Object.hash(runtimeType,_this.id,_this.type,_this.title,_this.body,_this.orderId,_this.customerId,_this.customerName,_this.orderNumber,_this.totalAmount,_this.isRead,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as OrderNotification;
  return 'OrderNotification(id: ${_this.id}, type: ${_this.type}, title: ${_this.title}, body: ${_this.body}, orderId: ${_this.orderId}, customerId: ${_this.customerId}, customerName: ${_this.customerName}, orderNumber: ${_this.orderNumber}, totalAmount: ${_this.totalAmount}, isRead: ${_this.isRead}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $OrderNotificationCopyWith<$Res>  {
  factory $OrderNotificationCopyWith(OrderNotification value, $Res Function(OrderNotification) _then) = _$OrderNotificationCopyWithImpl;
@useResult
$Res call({
 String id, String type, String title, String body, String orderId, String customerId, String customerName, String orderNumber, double totalAmount, bool isRead, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$OrderNotificationCopyWithImpl<$Res>
    implements $OrderNotificationCopyWith<$Res> {
  _$OrderNotificationCopyWithImpl(this._self, this._then);

  final OrderNotification _self;
  final $Res Function(OrderNotification) _then;

/// Create a copy of OrderNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? title = null,Object? body = null,Object? orderId = null,Object? customerId = null,Object? customerName = null,Object? orderNumber = null,Object? totalAmount = null,Object? isRead = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(OrderNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderNotification].
extension OrderNotificationPatterns on OrderNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderNotification value)  $default,){
final _that = this;
switch (_that) {
case _OrderNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderNotification value)?  $default,){
final _that = this;
switch (_that) {
case _OrderNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String title,  String body,  String orderId,  String customerId,  String customerName,  String orderNumber,  double totalAmount,  bool isRead,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderNotification() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.body,_that.orderId,_that.customerId,_that.customerName,_that.orderNumber,_that.totalAmount,_that.isRead,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String title,  String body,  String orderId,  String customerId,  String customerName,  String orderNumber,  double totalAmount,  bool isRead,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _OrderNotification():
return $default(_that.id,_that.type,_that.title,_that.body,_that.orderId,_that.customerId,_that.customerName,_that.orderNumber,_that.totalAmount,_that.isRead,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String title,  String body,  String orderId,  String customerId,  String customerName,  String orderNumber,  double totalAmount,  bool isRead,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderNotification() when $default != null:
return $default(_that.id,_that.type,_that.title,_that.body,_that.orderId,_that.customerId,_that.customerName,_that.orderNumber,_that.totalAmount,_that.isRead,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderNotification implements OrderNotification {
  const _OrderNotification({required this.id, required this.type, required this.title, required this.body, required this.orderId, required this.customerId, required this.customerName, required this.orderNumber, required this.totalAmount, required this.isRead, required this.createdAt, required this.updatedAt});
  factory _OrderNotification.fromJson(Map<String, dynamic> json) => _$OrderNotificationFromJson(json);

@override final  String id;
@override final  String type;
@override final  String title;
@override final  String body;
@override final  String orderId;
@override final  String customerId;
@override final  String customerName;
@override final  String orderNumber;
@override final  double totalAmount;
@override final  bool isRead;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of OrderNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderNotificationCopyWith<_OrderNotification> get copyWith => __$OrderNotificationCopyWithImpl<_OrderNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.customerId, customerId) || other.customerId == customerId)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,type,title,body,orderId,customerId,customerName,orderNumber,totalAmount,isRead,createdAt,updatedAt);
}

@override
String toString() {
    return 'OrderNotification(id: $id, type: $type, title: $title, body: $body, orderId: $orderId, customerId: $customerId, customerName: $customerName, orderNumber: $orderNumber, totalAmount: $totalAmount, isRead: $isRead, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderNotificationCopyWith<$Res> implements $OrderNotificationCopyWith<$Res> {
  factory _$OrderNotificationCopyWith(_OrderNotification value, $Res Function(_OrderNotification) _then) = __$OrderNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String title, String body, String orderId, String customerId, String customerName, String orderNumber, double totalAmount, bool isRead, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$OrderNotificationCopyWithImpl<$Res>
    implements _$OrderNotificationCopyWith<$Res> {
  __$OrderNotificationCopyWithImpl(this._self, this._then);

  final _OrderNotification _self;
  final $Res Function(_OrderNotification) _then;

/// Create a copy of OrderNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? title = null,Object? body = null,Object? orderId = null,Object? customerId = null,Object? customerName = null,Object? orderNumber = null,Object? totalAmount = null,Object? isRead = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_OrderNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,customerId: null == customerId ? _self.customerId : customerId // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
