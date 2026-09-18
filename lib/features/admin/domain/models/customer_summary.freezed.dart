// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RecentOrderSummary {

 String get id; String get orderNumber; OrderStatus get status; double get totalAmount; String? get paymentMethod; FulfillmentType get fulfillmentType; DateTime get createdAt;
/// Create a copy of RecentOrderSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentOrderSummaryCopyWith<RecentOrderSummary> get copyWith => _$RecentOrderSummaryCopyWithImpl<RecentOrderSummary>(this as RecentOrderSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RecentOrderSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentOrderSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.orderNumber, _this.orderNumber) || other.orderNumber == _this.orderNumber)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.totalAmount, _this.totalAmount) || other.totalAmount == _this.totalAmount)&&(identical(other.paymentMethod, _this.paymentMethod) || other.paymentMethod == _this.paymentMethod)&&(identical(other.fulfillmentType, _this.fulfillmentType) || other.fulfillmentType == _this.fulfillmentType)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}


@override
int get hashCode {
  final _this = this as RecentOrderSummary;
  return Object.hash(runtimeType,_this.id,_this.orderNumber,_this.status,_this.totalAmount,_this.paymentMethod,_this.fulfillmentType,_this.createdAt);
}

@override
String toString() {
  final _this = this as RecentOrderSummary;
  return 'RecentOrderSummary(id: ${_this.id}, orderNumber: ${_this.orderNumber}, status: ${_this.status}, totalAmount: ${_this.totalAmount}, paymentMethod: ${_this.paymentMethod}, fulfillmentType: ${_this.fulfillmentType}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $RecentOrderSummaryCopyWith<$Res>  {
  factory $RecentOrderSummaryCopyWith(RecentOrderSummary value, $Res Function(RecentOrderSummary) _then) = _$RecentOrderSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String orderNumber, OrderStatus status, double totalAmount, String? paymentMethod, FulfillmentType fulfillmentType, DateTime createdAt
});




}
/// @nodoc
class _$RecentOrderSummaryCopyWithImpl<$Res>
    implements $RecentOrderSummaryCopyWith<$Res> {
  _$RecentOrderSummaryCopyWithImpl(this._self, this._then);

  final RecentOrderSummary _self;
  final $Res Function(RecentOrderSummary) _then;

/// Create a copy of RecentOrderSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? status = null,Object? totalAmount = null,Object? paymentMethod = freezed,Object? fulfillmentType = null,Object? createdAt = null,}) {
  return _then(RecentOrderSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as FulfillmentType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentOrderSummary].
extension RecentOrderSummaryPatterns on RecentOrderSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentOrderSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentOrderSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentOrderSummary value)  $default,){
final _that = this;
switch (_that) {
case _RecentOrderSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentOrderSummary value)?  $default,){
final _that = this;
switch (_that) {
case _RecentOrderSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orderNumber,  OrderStatus status,  double totalAmount,  String? paymentMethod,  FulfillmentType fulfillmentType,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentOrderSummary() when $default != null:
return $default(_that.id,_that.orderNumber,_that.status,_that.totalAmount,_that.paymentMethod,_that.fulfillmentType,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orderNumber,  OrderStatus status,  double totalAmount,  String? paymentMethod,  FulfillmentType fulfillmentType,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _RecentOrderSummary():
return $default(_that.id,_that.orderNumber,_that.status,_that.totalAmount,_that.paymentMethod,_that.fulfillmentType,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orderNumber,  OrderStatus status,  double totalAmount,  String? paymentMethod,  FulfillmentType fulfillmentType,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _RecentOrderSummary() when $default != null:
return $default(_that.id,_that.orderNumber,_that.status,_that.totalAmount,_that.paymentMethod,_that.fulfillmentType,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _RecentOrderSummary implements RecentOrderSummary {
  const _RecentOrderSummary({required this.id, required this.orderNumber, required this.status, required this.totalAmount, this.paymentMethod, required this.fulfillmentType, required this.createdAt});
  

@override final  String id;
@override final  String orderNumber;
@override final  OrderStatus status;
@override final  double totalAmount;
@override final  String? paymentMethod;
@override final  FulfillmentType fulfillmentType;
@override final  DateTime createdAt;

/// Create a copy of RecentOrderSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentOrderSummaryCopyWith<_RecentOrderSummary> get copyWith => __$RecentOrderSummaryCopyWithImpl<_RecentOrderSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentOrderSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.fulfillmentType, fulfillmentType) || other.fulfillmentType == fulfillmentType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,orderNumber,status,totalAmount,paymentMethod,fulfillmentType,createdAt);
}

@override
String toString() {
    return 'RecentOrderSummary(id: $id, orderNumber: $orderNumber, status: $status, totalAmount: $totalAmount, paymentMethod: $paymentMethod, fulfillmentType: $fulfillmentType, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$RecentOrderSummaryCopyWith<$Res> implements $RecentOrderSummaryCopyWith<$Res> {
  factory _$RecentOrderSummaryCopyWith(_RecentOrderSummary value, $Res Function(_RecentOrderSummary) _then) = __$RecentOrderSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String orderNumber, OrderStatus status, double totalAmount, String? paymentMethod, FulfillmentType fulfillmentType, DateTime createdAt
});




}
/// @nodoc
class __$RecentOrderSummaryCopyWithImpl<$Res>
    implements _$RecentOrderSummaryCopyWith<$Res> {
  __$RecentOrderSummaryCopyWithImpl(this._self, this._then);

  final _RecentOrderSummary _self;
  final $Res Function(_RecentOrderSummary) _then;

/// Create a copy of RecentOrderSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? status = null,Object? totalAmount = null,Object? paymentMethod = freezed,Object? fulfillmentType = null,Object? createdAt = null,}) {
  return _then(_RecentOrderSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as double,paymentMethod: freezed == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String?,fulfillmentType: null == fulfillmentType ? _self.fulfillmentType : fulfillmentType // ignore: cast_nullable_to_non_nullable
as FulfillmentType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$CustomerSummary {

 String get id; String get name; String? get email; String? get phone; bool get isGuest; bool get isActive; DateTime get createdAt; int get orderCount; double get totalSpent;
/// Create a copy of CustomerSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerSummaryCopyWith<CustomerSummary> get copyWith => _$CustomerSummaryCopyWithImpl<CustomerSummary>(this as CustomerSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomerSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.isGuest, _this.isGuest) || other.isGuest == _this.isGuest)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.orderCount, _this.orderCount) || other.orderCount == _this.orderCount)&&(identical(other.totalSpent, _this.totalSpent) || other.totalSpent == _this.totalSpent));
}


@override
int get hashCode {
  final _this = this as CustomerSummary;
  return Object.hash(runtimeType,_this.id,_this.name,_this.email,_this.phone,_this.isGuest,_this.isActive,_this.createdAt,_this.orderCount,_this.totalSpent);
}

@override
String toString() {
  final _this = this as CustomerSummary;
  return 'CustomerSummary(id: ${_this.id}, name: ${_this.name}, email: ${_this.email}, phone: ${_this.phone}, isGuest: ${_this.isGuest}, isActive: ${_this.isActive}, createdAt: ${_this.createdAt}, orderCount: ${_this.orderCount}, totalSpent: ${_this.totalSpent})';
}


}

/// @nodoc
abstract mixin class $CustomerSummaryCopyWith<$Res>  {
  factory $CustomerSummaryCopyWith(CustomerSummary value, $Res Function(CustomerSummary) _then) = _$CustomerSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? email, String? phone, bool isGuest, bool isActive, DateTime createdAt, int orderCount, double totalSpent
});




}
/// @nodoc
class _$CustomerSummaryCopyWithImpl<$Res>
    implements $CustomerSummaryCopyWith<$Res> {
  _$CustomerSummaryCopyWithImpl(this._self, this._then);

  final CustomerSummary _self;
  final $Res Function(CustomerSummary) _then;

/// Create a copy of CustomerSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? isGuest = null,Object? isActive = null,Object? createdAt = null,Object? orderCount = null,Object? totalSpent = null,}) {
  return _then(CustomerSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerSummary].
extension CustomerSummaryPatterns on CustomerSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerSummary value)  $default,){
final _that = this;
switch (_that) {
case _CustomerSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? email,  String? phone,  bool isGuest,  bool isActive,  DateTime createdAt,  int orderCount,  double totalSpent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerSummary() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.isGuest,_that.isActive,_that.createdAt,_that.orderCount,_that.totalSpent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? email,  String? phone,  bool isGuest,  bool isActive,  DateTime createdAt,  int orderCount,  double totalSpent)  $default,) {final _that = this;
switch (_that) {
case _CustomerSummary():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.isGuest,_that.isActive,_that.createdAt,_that.orderCount,_that.totalSpent);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? email,  String? phone,  bool isGuest,  bool isActive,  DateTime createdAt,  int orderCount,  double totalSpent)?  $default,) {final _that = this;
switch (_that) {
case _CustomerSummary() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.isGuest,_that.isActive,_that.createdAt,_that.orderCount,_that.totalSpent);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerSummary implements CustomerSummary {
  const _CustomerSummary({required this.id, required this.name, this.email, this.phone, required this.isGuest, required this.isActive, required this.createdAt, required this.orderCount, required this.totalSpent});
  

@override final  String id;
@override final  String name;
@override final  String? email;
@override final  String? phone;
@override final  bool isGuest;
@override final  bool isActive;
@override final  DateTime createdAt;
@override final  int orderCount;
@override final  double totalSpent;

/// Create a copy of CustomerSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerSummaryCopyWith<_CustomerSummary> get copyWith => __$CustomerSummaryCopyWithImpl<_CustomerSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.orderCount, orderCount) || other.orderCount == orderCount)&&(identical(other.totalSpent, totalSpent) || other.totalSpent == totalSpent));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,email,phone,isGuest,isActive,createdAt,orderCount,totalSpent);
}

@override
String toString() {
    return 'CustomerSummary(id: $id, name: $name, email: $email, phone: $phone, isGuest: $isGuest, isActive: $isActive, createdAt: $createdAt, orderCount: $orderCount, totalSpent: $totalSpent)';
}


}

/// @nodoc
abstract mixin class _$CustomerSummaryCopyWith<$Res> implements $CustomerSummaryCopyWith<$Res> {
  factory _$CustomerSummaryCopyWith(_CustomerSummary value, $Res Function(_CustomerSummary) _then) = __$CustomerSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? email, String? phone, bool isGuest, bool isActive, DateTime createdAt, int orderCount, double totalSpent
});




}
/// @nodoc
class __$CustomerSummaryCopyWithImpl<$Res>
    implements _$CustomerSummaryCopyWith<$Res> {
  __$CustomerSummaryCopyWithImpl(this._self, this._then);

  final _CustomerSummary _self;
  final $Res Function(_CustomerSummary) _then;

/// Create a copy of CustomerSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? isGuest = null,Object? isActive = null,Object? createdAt = null,Object? orderCount = null,Object? totalSpent = null,}) {
  return _then(_CustomerSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,orderCount: null == orderCount ? _self.orderCount : orderCount // ignore: cast_nullable_to_non_nullable
as int,totalSpent: null == totalSpent ? _self.totalSpent : totalSpent // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$CustomerDetail {

 CustomerSummary get summary; List<RecentOrderSummary> get recentOrders;
/// Create a copy of CustomerDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerDetailCopyWith<CustomerDetail> get copyWith => _$CustomerDetailCopyWithImpl<CustomerDetail>(this as CustomerDetail, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CustomerDetail;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerDetail&&(identical(other.summary, _this.summary) || other.summary == _this.summary)&&const DeepCollectionEquality().equals(other.recentOrders, _this.recentOrders));
}


@override
int get hashCode {
  final _this = this as CustomerDetail;
  return Object.hash(runtimeType,_this.summary,const DeepCollectionEquality().hash(_this.recentOrders));
}

@override
String toString() {
  final _this = this as CustomerDetail;
  return 'CustomerDetail(summary: ${_this.summary}, recentOrders: ${_this.recentOrders})';
}


}

/// @nodoc
abstract mixin class $CustomerDetailCopyWith<$Res>  {
  factory $CustomerDetailCopyWith(CustomerDetail value, $Res Function(CustomerDetail) _then) = _$CustomerDetailCopyWithImpl;
@useResult
$Res call({
 CustomerSummary summary, List<RecentOrderSummary> recentOrders
});


$CustomerSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$CustomerDetailCopyWithImpl<$Res>
    implements $CustomerDetailCopyWith<$Res> {
  _$CustomerDetailCopyWithImpl(this._self, this._then);

  final CustomerDetail _self;
  final $Res Function(CustomerDetail) _then;

/// Create a copy of CustomerDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = null,Object? recentOrders = null,}) {
  return _then(CustomerDetail(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as CustomerSummary,recentOrders: null == recentOrders ? _self.recentOrders : recentOrders // ignore: cast_nullable_to_non_nullable
as List<RecentOrderSummary>,
  ));
}
/// Create a copy of CustomerDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerSummaryCopyWith<$Res> get summary {
  
  return $CustomerSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [CustomerDetail].
extension CustomerDetailPatterns on CustomerDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerDetail value)  $default,){
final _that = this;
switch (_that) {
case _CustomerDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerDetail value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CustomerSummary summary,  List<RecentOrderSummary> recentOrders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerDetail() when $default != null:
return $default(_that.summary,_that.recentOrders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CustomerSummary summary,  List<RecentOrderSummary> recentOrders)  $default,) {final _that = this;
switch (_that) {
case _CustomerDetail():
return $default(_that.summary,_that.recentOrders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CustomerSummary summary,  List<RecentOrderSummary> recentOrders)?  $default,) {final _that = this;
switch (_that) {
case _CustomerDetail() when $default != null:
return $default(_that.summary,_that.recentOrders);case _:
  return null;

}
}

}

/// @nodoc


class _CustomerDetail implements CustomerDetail {
  const _CustomerDetail({required this.summary, required  List<RecentOrderSummary> recentOrders}): _recentOrders = recentOrders;
  

@override final  CustomerSummary summary;
 final  List<RecentOrderSummary> _recentOrders;
@override List<RecentOrderSummary> get recentOrders {
  if (_recentOrders is EqualUnmodifiableListView) return _recentOrders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentOrders);
}


/// Create a copy of CustomerDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerDetailCopyWith<_CustomerDetail> get copyWith => __$CustomerDetailCopyWithImpl<_CustomerDetail>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerDetail&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.recentOrders, _recentOrders));
}


@override
int get hashCode {
    return Object.hash(runtimeType,summary,const DeepCollectionEquality().hash(_recentOrders));
}

@override
String toString() {
    return 'CustomerDetail(summary: $summary, recentOrders: $recentOrders)';
}


}

/// @nodoc
abstract mixin class _$CustomerDetailCopyWith<$Res> implements $CustomerDetailCopyWith<$Res> {
  factory _$CustomerDetailCopyWith(_CustomerDetail value, $Res Function(_CustomerDetail) _then) = __$CustomerDetailCopyWithImpl;
@override @useResult
$Res call({
 CustomerSummary summary, List<RecentOrderSummary> recentOrders
});


@override $CustomerSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$CustomerDetailCopyWithImpl<$Res>
    implements _$CustomerDetailCopyWith<$Res> {
  __$CustomerDetailCopyWithImpl(this._self, this._then);

  final _CustomerDetail _self;
  final $Res Function(_CustomerDetail) _then;

/// Create a copy of CustomerDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? recentOrders = null,}) {
  return _then(_CustomerDetail(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as CustomerSummary,recentOrders: null == recentOrders ? _self._recentOrders : recentOrders // ignore: cast_nullable_to_non_nullable
as List<RecentOrderSummary>,
  ));
}

/// Create a copy of CustomerDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerSummaryCopyWith<$Res> get summary {
  
  return $CustomerSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
