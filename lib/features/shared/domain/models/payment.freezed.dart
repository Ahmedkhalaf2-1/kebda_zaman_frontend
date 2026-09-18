// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentIntent {

 String get paymentId; String get status; PaymentIntentProviderData get providerData;
/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentIntentCopyWith<PaymentIntent> get copyWith => _$PaymentIntentCopyWithImpl<PaymentIntent>(this as PaymentIntent, _$identity);

  /// Serializes this PaymentIntent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaymentIntent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentIntent&&(identical(other.paymentId, _this.paymentId) || other.paymentId == _this.paymentId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.providerData, _this.providerData) || other.providerData == _this.providerData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaymentIntent;
  return Object.hash(runtimeType,_this.paymentId,_this.status,_this.providerData);
}

@override
String toString() {
  final _this = this as PaymentIntent;
  return 'PaymentIntent(paymentId: ${_this.paymentId}, status: ${_this.status}, providerData: ${_this.providerData})';
}


}

/// @nodoc
abstract mixin class $PaymentIntentCopyWith<$Res>  {
  factory $PaymentIntentCopyWith(PaymentIntent value, $Res Function(PaymentIntent) _then) = _$PaymentIntentCopyWithImpl;
@useResult
$Res call({
 String paymentId, String status, PaymentIntentProviderData providerData
});


$PaymentIntentProviderDataCopyWith<$Res> get providerData;

}
/// @nodoc
class _$PaymentIntentCopyWithImpl<$Res>
    implements $PaymentIntentCopyWith<$Res> {
  _$PaymentIntentCopyWithImpl(this._self, this._then);

  final PaymentIntent _self;
  final $Res Function(PaymentIntent) _then;

/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentId = null,Object? status = null,Object? providerData = null,}) {
  return _then(PaymentIntent(
paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,providerData: null == providerData ? _self.providerData : providerData // ignore: cast_nullable_to_non_nullable
as PaymentIntentProviderData,
  ));
}
/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentIntentProviderDataCopyWith<$Res> get providerData {
  
  return $PaymentIntentProviderDataCopyWith<$Res>(_self.providerData, (value) {
    return _then(_self.copyWith(providerData: value));
  });
}
}


/// Adds pattern-matching-related methods to [PaymentIntent].
extension PaymentIntentPatterns on PaymentIntent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentIntent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentIntent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentIntent value)  $default,){
final _that = this;
switch (_that) {
case _PaymentIntent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentIntent value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentIntent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String paymentId,  String status,  PaymentIntentProviderData providerData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentIntent() when $default != null:
return $default(_that.paymentId,_that.status,_that.providerData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String paymentId,  String status,  PaymentIntentProviderData providerData)  $default,) {final _that = this;
switch (_that) {
case _PaymentIntent():
return $default(_that.paymentId,_that.status,_that.providerData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String paymentId,  String status,  PaymentIntentProviderData providerData)?  $default,) {final _that = this;
switch (_that) {
case _PaymentIntent() when $default != null:
return $default(_that.paymentId,_that.status,_that.providerData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentIntent implements PaymentIntent {
  const _PaymentIntent({required this.paymentId, required this.status, required this.providerData});
  factory _PaymentIntent.fromJson(Map<String, dynamic> json) => _$PaymentIntentFromJson(json);

@override final  String paymentId;
@override final  String status;
@override final  PaymentIntentProviderData providerData;

/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentIntentCopyWith<_PaymentIntent> get copyWith => __$PaymentIntentCopyWithImpl<_PaymentIntent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentIntentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentIntent&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.providerData, providerData) || other.providerData == providerData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,paymentId,status,providerData);
}

@override
String toString() {
    return 'PaymentIntent(paymentId: $paymentId, status: $status, providerData: $providerData)';
}


}

/// @nodoc
abstract mixin class _$PaymentIntentCopyWith<$Res> implements $PaymentIntentCopyWith<$Res> {
  factory _$PaymentIntentCopyWith(_PaymentIntent value, $Res Function(_PaymentIntent) _then) = __$PaymentIntentCopyWithImpl;
@override @useResult
$Res call({
 String paymentId, String status, PaymentIntentProviderData providerData
});


@override $PaymentIntentProviderDataCopyWith<$Res> get providerData;

}
/// @nodoc
class __$PaymentIntentCopyWithImpl<$Res>
    implements _$PaymentIntentCopyWith<$Res> {
  __$PaymentIntentCopyWithImpl(this._self, this._then);

  final _PaymentIntent _self;
  final $Res Function(_PaymentIntent) _then;

/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentId = null,Object? status = null,Object? providerData = null,}) {
  return _then(_PaymentIntent(
paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,providerData: null == providerData ? _self.providerData : providerData // ignore: cast_nullable_to_non_nullable
as PaymentIntentProviderData,
  ));
}

/// Create a copy of PaymentIntent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PaymentIntentProviderDataCopyWith<$Res> get providerData {
  
  return $PaymentIntentProviderDataCopyWith<$Res>(_self.providerData, (value) {
    return _then(_self.copyWith(providerData: value));
  });
}
}


/// @nodoc
mixin _$PaymentIntentProviderData {

 String? get publishableApiKey; int get amount; String get currency; String get orderId; String? get description; String? get callbackUrl; bool get manual; String? get instructions;
/// Create a copy of PaymentIntentProviderData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentIntentProviderDataCopyWith<PaymentIntentProviderData> get copyWith => _$PaymentIntentProviderDataCopyWithImpl<PaymentIntentProviderData>(this as PaymentIntentProviderData, _$identity);

  /// Serializes this PaymentIntentProviderData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PaymentIntentProviderData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentIntentProviderData&&(identical(other.publishableApiKey, _this.publishableApiKey) || other.publishableApiKey == _this.publishableApiKey)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.callbackUrl, _this.callbackUrl) || other.callbackUrl == _this.callbackUrl)&&(identical(other.manual, _this.manual) || other.manual == _this.manual)&&(identical(other.instructions, _this.instructions) || other.instructions == _this.instructions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PaymentIntentProviderData;
  return Object.hash(runtimeType,_this.publishableApiKey,_this.amount,_this.currency,_this.orderId,_this.description,_this.callbackUrl,_this.manual,_this.instructions);
}

@override
String toString() {
  final _this = this as PaymentIntentProviderData;
  return 'PaymentIntentProviderData(publishableApiKey: ${_this.publishableApiKey}, amount: ${_this.amount}, currency: ${_this.currency}, orderId: ${_this.orderId}, description: ${_this.description}, callbackUrl: ${_this.callbackUrl}, manual: ${_this.manual}, instructions: ${_this.instructions})';
}


}

/// @nodoc
abstract mixin class $PaymentIntentProviderDataCopyWith<$Res>  {
  factory $PaymentIntentProviderDataCopyWith(PaymentIntentProviderData value, $Res Function(PaymentIntentProviderData) _then) = _$PaymentIntentProviderDataCopyWithImpl;
@useResult
$Res call({
 String? publishableApiKey, int amount, String currency, String orderId, String? description, String? callbackUrl, bool manual, String? instructions
});




}
/// @nodoc
class _$PaymentIntentProviderDataCopyWithImpl<$Res>
    implements $PaymentIntentProviderDataCopyWith<$Res> {
  _$PaymentIntentProviderDataCopyWithImpl(this._self, this._then);

  final PaymentIntentProviderData _self;
  final $Res Function(PaymentIntentProviderData) _then;

/// Create a copy of PaymentIntentProviderData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? publishableApiKey = freezed,Object? amount = null,Object? currency = null,Object? orderId = null,Object? description = freezed,Object? callbackUrl = freezed,Object? manual = null,Object? instructions = freezed,}) {
  return _then(PaymentIntentProviderData(
publishableApiKey: freezed == publishableApiKey ? _self.publishableApiKey : publishableApiKey // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,callbackUrl: freezed == callbackUrl ? _self.callbackUrl : callbackUrl // ignore: cast_nullable_to_non_nullable
as String?,manual: null == manual ? _self.manual : manual // ignore: cast_nullable_to_non_nullable
as bool,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentIntentProviderData].
extension PaymentIntentProviderDataPatterns on PaymentIntentProviderData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentIntentProviderData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentIntentProviderData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentIntentProviderData value)  $default,){
final _that = this;
switch (_that) {
case _PaymentIntentProviderData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentIntentProviderData value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentIntentProviderData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? publishableApiKey,  int amount,  String currency,  String orderId,  String? description,  String? callbackUrl,  bool manual,  String? instructions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentIntentProviderData() when $default != null:
return $default(_that.publishableApiKey,_that.amount,_that.currency,_that.orderId,_that.description,_that.callbackUrl,_that.manual,_that.instructions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? publishableApiKey,  int amount,  String currency,  String orderId,  String? description,  String? callbackUrl,  bool manual,  String? instructions)  $default,) {final _that = this;
switch (_that) {
case _PaymentIntentProviderData():
return $default(_that.publishableApiKey,_that.amount,_that.currency,_that.orderId,_that.description,_that.callbackUrl,_that.manual,_that.instructions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? publishableApiKey,  int amount,  String currency,  String orderId,  String? description,  String? callbackUrl,  bool manual,  String? instructions)?  $default,) {final _that = this;
switch (_that) {
case _PaymentIntentProviderData() when $default != null:
return $default(_that.publishableApiKey,_that.amount,_that.currency,_that.orderId,_that.description,_that.callbackUrl,_that.manual,_that.instructions);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentIntentProviderData implements PaymentIntentProviderData {
  const _PaymentIntentProviderData({this.publishableApiKey, required this.amount, required this.currency, required this.orderId, this.description, this.callbackUrl, this.manual = false, this.instructions});
  factory _PaymentIntentProviderData.fromJson(Map<String, dynamic> json) => _$PaymentIntentProviderDataFromJson(json);

@override final  String? publishableApiKey;
@override final  int amount;
@override final  String currency;
@override final  String orderId;
@override final  String? description;
@override final  String? callbackUrl;
@override@JsonKey() final  bool manual;
@override final  String? instructions;

/// Create a copy of PaymentIntentProviderData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentIntentProviderDataCopyWith<_PaymentIntentProviderData> get copyWith => __$PaymentIntentProviderDataCopyWithImpl<_PaymentIntentProviderData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentIntentProviderDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentIntentProviderData&&(identical(other.publishableApiKey, publishableApiKey) || other.publishableApiKey == publishableApiKey)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.description, description) || other.description == description)&&(identical(other.callbackUrl, callbackUrl) || other.callbackUrl == callbackUrl)&&(identical(other.manual, manual) || other.manual == manual)&&(identical(other.instructions, instructions) || other.instructions == instructions));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,publishableApiKey,amount,currency,orderId,description,callbackUrl,manual,instructions);
}

@override
String toString() {
    return 'PaymentIntentProviderData(publishableApiKey: $publishableApiKey, amount: $amount, currency: $currency, orderId: $orderId, description: $description, callbackUrl: $callbackUrl, manual: $manual, instructions: $instructions)';
}


}

/// @nodoc
abstract mixin class _$PaymentIntentProviderDataCopyWith<$Res> implements $PaymentIntentProviderDataCopyWith<$Res> {
  factory _$PaymentIntentProviderDataCopyWith(_PaymentIntentProviderData value, $Res Function(_PaymentIntentProviderData) _then) = __$PaymentIntentProviderDataCopyWithImpl;
@override @useResult
$Res call({
 String? publishableApiKey, int amount, String currency, String orderId, String? description, String? callbackUrl, bool manual, String? instructions
});




}
/// @nodoc
class __$PaymentIntentProviderDataCopyWithImpl<$Res>
    implements _$PaymentIntentProviderDataCopyWith<$Res> {
  __$PaymentIntentProviderDataCopyWithImpl(this._self, this._then);

  final _PaymentIntentProviderData _self;
  final $Res Function(_PaymentIntentProviderData) _then;

/// Create a copy of PaymentIntentProviderData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? publishableApiKey = freezed,Object? amount = null,Object? currency = null,Object? orderId = null,Object? description = freezed,Object? callbackUrl = freezed,Object? manual = null,Object? instructions = freezed,}) {
  return _then(_PaymentIntentProviderData(
publishableApiKey: freezed == publishableApiKey ? _self.publishableApiKey : publishableApiKey // ignore: cast_nullable_to_non_nullable
as String?,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,callbackUrl: freezed == callbackUrl ? _self.callbackUrl : callbackUrl // ignore: cast_nullable_to_non_nullable
as String?,manual: null == manual ? _self.manual : manual // ignore: cast_nullable_to_non_nullable
as bool,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Payment {

 String get id; String get orderId; String get method; String get status; double get amount; String get currency; String get provider; String? get providerRef; DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentCopyWith<Payment> get copyWith => _$PaymentCopyWithImpl<Payment>(this as Payment, _$identity);

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Payment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Payment&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency)&&(identical(other.provider, _this.provider) || other.provider == _this.provider)&&(identical(other.providerRef, _this.providerRef) || other.providerRef == _this.providerRef)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Payment;
  return Object.hash(runtimeType,_this.id,_this.orderId,_this.method,_this.status,_this.amount,_this.currency,_this.provider,_this.providerRef,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Payment;
  return 'Payment(id: ${_this.id}, orderId: ${_this.orderId}, method: ${_this.method}, status: ${_this.status}, amount: ${_this.amount}, currency: ${_this.currency}, provider: ${_this.provider}, providerRef: ${_this.providerRef}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $PaymentCopyWith<$Res>  {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) _then) = _$PaymentCopyWithImpl;
@useResult
$Res call({
 String id, String orderId, String method, String status, double amount, String currency, String provider, String? providerRef, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$PaymentCopyWithImpl<$Res>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._self, this._then);

  final Payment _self;
  final $Res Function(Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = null,Object? method = null,Object? status = null,Object? amount = null,Object? currency = null,Object? provider = null,Object? providerRef = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(Payment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,providerRef: freezed == providerRef ? _self.providerRef : providerRef // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Payment].
extension PaymentPatterns on Payment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Payment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Payment value)  $default,){
final _that = this;
switch (_that) {
case _Payment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Payment value)?  $default,){
final _that = this;
switch (_that) {
case _Payment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orderId,  String method,  String status,  double amount,  String currency,  String provider,  String? providerRef,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.orderId,_that.method,_that.status,_that.amount,_that.currency,_that.provider,_that.providerRef,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orderId,  String method,  String status,  double amount,  String currency,  String provider,  String? providerRef,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Payment():
return $default(_that.id,_that.orderId,_that.method,_that.status,_that.amount,_that.currency,_that.provider,_that.providerRef,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orderId,  String method,  String status,  double amount,  String currency,  String provider,  String? providerRef,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Payment() when $default != null:
return $default(_that.id,_that.orderId,_that.method,_that.status,_that.amount,_that.currency,_that.provider,_that.providerRef,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Payment implements Payment {
  const _Payment({required this.id, required this.orderId, required this.method, required this.status, required this.amount, required this.currency, required this.provider, this.providerRef, required this.createdAt, this.updatedAt});
  factory _Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);

@override final  String id;
@override final  String orderId;
@override final  String method;
@override final  String status;
@override final  double amount;
@override final  String currency;
@override final  String provider;
@override final  String? providerRef;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentCopyWith<_Payment> get copyWith => __$PaymentCopyWithImpl<_Payment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Payment&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.method, method) || other.method == method)&&(identical(other.status, status) || other.status == status)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.providerRef, providerRef) || other.providerRef == providerRef)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,orderId,method,status,amount,currency,provider,providerRef,createdAt,updatedAt);
}

@override
String toString() {
    return 'Payment(id: $id, orderId: $orderId, method: $method, status: $status, amount: $amount, currency: $currency, provider: $provider, providerRef: $providerRef, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$PaymentCopyWith(_Payment value, $Res Function(_Payment) _then) = __$PaymentCopyWithImpl;
@override @useResult
$Res call({
 String id, String orderId, String method, String status, double amount, String currency, String provider, String? providerRef, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$PaymentCopyWithImpl<$Res>
    implements _$PaymentCopyWith<$Res> {
  __$PaymentCopyWithImpl(this._self, this._then);

  final _Payment _self;
  final $Res Function(_Payment) _then;

/// Create a copy of Payment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = null,Object? method = null,Object? status = null,Object? amount = null,Object? currency = null,Object? provider = null,Object? providerRef = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_Payment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as String,providerRef: freezed == providerRef ? _self.providerRef : providerRef // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$SavedCard {

 String get id; String get brand; String get lastFour; int get expMonth; int get expYear; bool get isDefault; DateTime get createdAt;
/// Create a copy of SavedCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedCardCopyWith<SavedCard> get copyWith => _$SavedCardCopyWithImpl<SavedCard>(this as SavedCard, _$identity);

  /// Serializes this SavedCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SavedCard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedCard&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.brand, _this.brand) || other.brand == _this.brand)&&(identical(other.lastFour, _this.lastFour) || other.lastFour == _this.lastFour)&&(identical(other.expMonth, _this.expMonth) || other.expMonth == _this.expMonth)&&(identical(other.expYear, _this.expYear) || other.expYear == _this.expYear)&&(identical(other.isDefault, _this.isDefault) || other.isDefault == _this.isDefault)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SavedCard;
  return Object.hash(runtimeType,_this.id,_this.brand,_this.lastFour,_this.expMonth,_this.expYear,_this.isDefault,_this.createdAt);
}

@override
String toString() {
  final _this = this as SavedCard;
  return 'SavedCard(id: ${_this.id}, brand: ${_this.brand}, lastFour: ${_this.lastFour}, expMonth: ${_this.expMonth}, expYear: ${_this.expYear}, isDefault: ${_this.isDefault}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $SavedCardCopyWith<$Res>  {
  factory $SavedCardCopyWith(SavedCard value, $Res Function(SavedCard) _then) = _$SavedCardCopyWithImpl;
@useResult
$Res call({
 String id, String brand, String lastFour, int expMonth, int expYear, bool isDefault, DateTime createdAt
});




}
/// @nodoc
class _$SavedCardCopyWithImpl<$Res>
    implements $SavedCardCopyWith<$Res> {
  _$SavedCardCopyWithImpl(this._self, this._then);

  final SavedCard _self;
  final $Res Function(SavedCard) _then;

/// Create a copy of SavedCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? brand = null,Object? lastFour = null,Object? expMonth = null,Object? expYear = null,Object? isDefault = null,Object? createdAt = null,}) {
  return _then(SavedCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,lastFour: null == lastFour ? _self.lastFour : lastFour // ignore: cast_nullable_to_non_nullable
as String,expMonth: null == expMonth ? _self.expMonth : expMonth // ignore: cast_nullable_to_non_nullable
as int,expYear: null == expYear ? _self.expYear : expYear // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedCard].
extension SavedCardPatterns on SavedCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedCard value)  $default,){
final _that = this;
switch (_that) {
case _SavedCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedCard value)?  $default,){
final _that = this;
switch (_that) {
case _SavedCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String brand,  String lastFour,  int expMonth,  int expYear,  bool isDefault,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedCard() when $default != null:
return $default(_that.id,_that.brand,_that.lastFour,_that.expMonth,_that.expYear,_that.isDefault,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String brand,  String lastFour,  int expMonth,  int expYear,  bool isDefault,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SavedCard():
return $default(_that.id,_that.brand,_that.lastFour,_that.expMonth,_that.expYear,_that.isDefault,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String brand,  String lastFour,  int expMonth,  int expYear,  bool isDefault,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SavedCard() when $default != null:
return $default(_that.id,_that.brand,_that.lastFour,_that.expMonth,_that.expYear,_that.isDefault,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedCard implements SavedCard {
  const _SavedCard({required this.id, required this.brand, required this.lastFour, required this.expMonth, required this.expYear, required this.isDefault, required this.createdAt});
  factory _SavedCard.fromJson(Map<String, dynamic> json) => _$SavedCardFromJson(json);

@override final  String id;
@override final  String brand;
@override final  String lastFour;
@override final  int expMonth;
@override final  int expYear;
@override final  bool isDefault;
@override final  DateTime createdAt;

/// Create a copy of SavedCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedCardCopyWith<_SavedCard> get copyWith => __$SavedCardCopyWithImpl<_SavedCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedCardToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedCard&&(identical(other.id, id) || other.id == id)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.lastFour, lastFour) || other.lastFour == lastFour)&&(identical(other.expMonth, expMonth) || other.expMonth == expMonth)&&(identical(other.expYear, expYear) || other.expYear == expYear)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,brand,lastFour,expMonth,expYear,isDefault,createdAt);
}

@override
String toString() {
    return 'SavedCard(id: $id, brand: $brand, lastFour: $lastFour, expMonth: $expMonth, expYear: $expYear, isDefault: $isDefault, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SavedCardCopyWith<$Res> implements $SavedCardCopyWith<$Res> {
  factory _$SavedCardCopyWith(_SavedCard value, $Res Function(_SavedCard) _then) = __$SavedCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String brand, String lastFour, int expMonth, int expYear, bool isDefault, DateTime createdAt
});




}
/// @nodoc
class __$SavedCardCopyWithImpl<$Res>
    implements _$SavedCardCopyWith<$Res> {
  __$SavedCardCopyWithImpl(this._self, this._then);

  final _SavedCard _self;
  final $Res Function(_SavedCard) _then;

/// Create a copy of SavedCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? brand = null,Object? lastFour = null,Object? expMonth = null,Object? expYear = null,Object? isDefault = null,Object? createdAt = null,}) {
  return _then(_SavedCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,lastFour: null == lastFour ? _self.lastFour : lastFour // ignore: cast_nullable_to_non_nullable
as String,expMonth: null == expMonth ? _self.expMonth : expMonth // ignore: cast_nullable_to_non_nullable
as int,expYear: null == expYear ? _self.expYear : expYear // ignore: cast_nullable_to_non_nullable
as int,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$CardChargeResult {

 String get paymentId; String get status; CardChargeProviderData? get providerData;
/// Create a copy of CardChargeResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardChargeResultCopyWith<CardChargeResult> get copyWith => _$CardChargeResultCopyWithImpl<CardChargeResult>(this as CardChargeResult, _$identity);

  /// Serializes this CardChargeResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CardChargeResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardChargeResult&&(identical(other.paymentId, _this.paymentId) || other.paymentId == _this.paymentId)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.providerData, _this.providerData) || other.providerData == _this.providerData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CardChargeResult;
  return Object.hash(runtimeType,_this.paymentId,_this.status,_this.providerData);
}

@override
String toString() {
  final _this = this as CardChargeResult;
  return 'CardChargeResult(paymentId: ${_this.paymentId}, status: ${_this.status}, providerData: ${_this.providerData})';
}


}

/// @nodoc
abstract mixin class $CardChargeResultCopyWith<$Res>  {
  factory $CardChargeResultCopyWith(CardChargeResult value, $Res Function(CardChargeResult) _then) = _$CardChargeResultCopyWithImpl;
@useResult
$Res call({
 String paymentId, String status, CardChargeProviderData? providerData
});


$CardChargeProviderDataCopyWith<$Res>? get providerData;

}
/// @nodoc
class _$CardChargeResultCopyWithImpl<$Res>
    implements $CardChargeResultCopyWith<$Res> {
  _$CardChargeResultCopyWithImpl(this._self, this._then);

  final CardChargeResult _self;
  final $Res Function(CardChargeResult) _then;

/// Create a copy of CardChargeResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? paymentId = null,Object? status = null,Object? providerData = freezed,}) {
  return _then(CardChargeResult(
paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,providerData: freezed == providerData ? _self.providerData : providerData // ignore: cast_nullable_to_non_nullable
as CardChargeProviderData?,
  ));
}
/// Create a copy of CardChargeResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardChargeProviderDataCopyWith<$Res>? get providerData {
    if (_self.providerData == null) {
    return null;
  }

  return $CardChargeProviderDataCopyWith<$Res>(_self.providerData!, (value) {
    return _then(_self.copyWith(providerData: value));
  });
}
}


/// Adds pattern-matching-related methods to [CardChargeResult].
extension CardChargeResultPatterns on CardChargeResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardChargeResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardChargeResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardChargeResult value)  $default,){
final _that = this;
switch (_that) {
case _CardChargeResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardChargeResult value)?  $default,){
final _that = this;
switch (_that) {
case _CardChargeResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String paymentId,  String status,  CardChargeProviderData? providerData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardChargeResult() when $default != null:
return $default(_that.paymentId,_that.status,_that.providerData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String paymentId,  String status,  CardChargeProviderData? providerData)  $default,) {final _that = this;
switch (_that) {
case _CardChargeResult():
return $default(_that.paymentId,_that.status,_that.providerData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String paymentId,  String status,  CardChargeProviderData? providerData)?  $default,) {final _that = this;
switch (_that) {
case _CardChargeResult() when $default != null:
return $default(_that.paymentId,_that.status,_that.providerData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardChargeResult implements CardChargeResult {
  const _CardChargeResult({required this.paymentId, required this.status, this.providerData});
  factory _CardChargeResult.fromJson(Map<String, dynamic> json) => _$CardChargeResultFromJson(json);

@override final  String paymentId;
@override final  String status;
@override final  CardChargeProviderData? providerData;

/// Create a copy of CardChargeResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardChargeResultCopyWith<_CardChargeResult> get copyWith => __$CardChargeResultCopyWithImpl<_CardChargeResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardChargeResultToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardChargeResult&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId)&&(identical(other.status, status) || other.status == status)&&(identical(other.providerData, providerData) || other.providerData == providerData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,paymentId,status,providerData);
}

@override
String toString() {
    return 'CardChargeResult(paymentId: $paymentId, status: $status, providerData: $providerData)';
}


}

/// @nodoc
abstract mixin class _$CardChargeResultCopyWith<$Res> implements $CardChargeResultCopyWith<$Res> {
  factory _$CardChargeResultCopyWith(_CardChargeResult value, $Res Function(_CardChargeResult) _then) = __$CardChargeResultCopyWithImpl;
@override @useResult
$Res call({
 String paymentId, String status, CardChargeProviderData? providerData
});


@override $CardChargeProviderDataCopyWith<$Res>? get providerData;

}
/// @nodoc
class __$CardChargeResultCopyWithImpl<$Res>
    implements _$CardChargeResultCopyWith<$Res> {
  __$CardChargeResultCopyWithImpl(this._self, this._then);

  final _CardChargeResult _self;
  final $Res Function(_CardChargeResult) _then;

/// Create a copy of CardChargeResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? paymentId = null,Object? status = null,Object? providerData = freezed,}) {
  return _then(_CardChargeResult(
paymentId: null == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,providerData: freezed == providerData ? _self.providerData : providerData // ignore: cast_nullable_to_non_nullable
as CardChargeProviderData?,
  ));
}

/// Create a copy of CardChargeResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CardChargeProviderDataCopyWith<$Res>? get providerData {
    if (_self.providerData == null) {
    return null;
  }

  return $CardChargeProviderDataCopyWith<$Res>(_self.providerData!, (value) {
    return _then(_self.copyWith(providerData: value));
  });
}
}


/// @nodoc
mixin _$CardChargeProviderData {

 String get transactionUrl;
/// Create a copy of CardChargeProviderData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CardChargeProviderDataCopyWith<CardChargeProviderData> get copyWith => _$CardChargeProviderDataCopyWithImpl<CardChargeProviderData>(this as CardChargeProviderData, _$identity);

  /// Serializes this CardChargeProviderData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CardChargeProviderData;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CardChargeProviderData&&(identical(other.transactionUrl, _this.transactionUrl) || other.transactionUrl == _this.transactionUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CardChargeProviderData;
  return Object.hash(runtimeType,_this.transactionUrl);
}

@override
String toString() {
  final _this = this as CardChargeProviderData;
  return 'CardChargeProviderData(transactionUrl: ${_this.transactionUrl})';
}


}

/// @nodoc
abstract mixin class $CardChargeProviderDataCopyWith<$Res>  {
  factory $CardChargeProviderDataCopyWith(CardChargeProviderData value, $Res Function(CardChargeProviderData) _then) = _$CardChargeProviderDataCopyWithImpl;
@useResult
$Res call({
 String transactionUrl
});




}
/// @nodoc
class _$CardChargeProviderDataCopyWithImpl<$Res>
    implements $CardChargeProviderDataCopyWith<$Res> {
  _$CardChargeProviderDataCopyWithImpl(this._self, this._then);

  final CardChargeProviderData _self;
  final $Res Function(CardChargeProviderData) _then;

/// Create a copy of CardChargeProviderData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? transactionUrl = null,}) {
  return _then(CardChargeProviderData(
transactionUrl: null == transactionUrl ? _self.transactionUrl : transactionUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CardChargeProviderData].
extension CardChargeProviderDataPatterns on CardChargeProviderData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CardChargeProviderData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CardChargeProviderData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CardChargeProviderData value)  $default,){
final _that = this;
switch (_that) {
case _CardChargeProviderData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CardChargeProviderData value)?  $default,){
final _that = this;
switch (_that) {
case _CardChargeProviderData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String transactionUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CardChargeProviderData() when $default != null:
return $default(_that.transactionUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String transactionUrl)  $default,) {final _that = this;
switch (_that) {
case _CardChargeProviderData():
return $default(_that.transactionUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String transactionUrl)?  $default,) {final _that = this;
switch (_that) {
case _CardChargeProviderData() when $default != null:
return $default(_that.transactionUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CardChargeProviderData implements CardChargeProviderData {
  const _CardChargeProviderData({required this.transactionUrl});
  factory _CardChargeProviderData.fromJson(Map<String, dynamic> json) => _$CardChargeProviderDataFromJson(json);

@override final  String transactionUrl;

/// Create a copy of CardChargeProviderData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CardChargeProviderDataCopyWith<_CardChargeProviderData> get copyWith => __$CardChargeProviderDataCopyWithImpl<_CardChargeProviderData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CardChargeProviderDataToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CardChargeProviderData&&(identical(other.transactionUrl, transactionUrl) || other.transactionUrl == transactionUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,transactionUrl);
}

@override
String toString() {
    return 'CardChargeProviderData(transactionUrl: $transactionUrl)';
}


}

/// @nodoc
abstract mixin class _$CardChargeProviderDataCopyWith<$Res> implements $CardChargeProviderDataCopyWith<$Res> {
  factory _$CardChargeProviderDataCopyWith(_CardChargeProviderData value, $Res Function(_CardChargeProviderData) _then) = __$CardChargeProviderDataCopyWithImpl;
@override @useResult
$Res call({
 String transactionUrl
});




}
/// @nodoc
class __$CardChargeProviderDataCopyWithImpl<$Res>
    implements _$CardChargeProviderDataCopyWith<$Res> {
  __$CardChargeProviderDataCopyWithImpl(this._self, this._then);

  final _CardChargeProviderData _self;
  final $Res Function(_CardChargeProviderData) _then;

/// Create a copy of CardChargeProviderData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? transactionUrl = null,}) {
  return _then(_CardChargeProviderData(
transactionUrl: null == transactionUrl ? _self.transactionUrl : transactionUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
