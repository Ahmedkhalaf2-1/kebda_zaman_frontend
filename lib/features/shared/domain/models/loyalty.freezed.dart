// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loyalty.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoyaltyAccount {

 String get userId; int get pointsBalance; int get lifetimePointsEarned;
/// Create a copy of LoyaltyAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoyaltyAccountCopyWith<LoyaltyAccount> get copyWith => _$LoyaltyAccountCopyWithImpl<LoyaltyAccount>(this as LoyaltyAccount, _$identity);

  /// Serializes this LoyaltyAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoyaltyAccount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoyaltyAccount&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.pointsBalance, _this.pointsBalance) || other.pointsBalance == _this.pointsBalance)&&(identical(other.lifetimePointsEarned, _this.lifetimePointsEarned) || other.lifetimePointsEarned == _this.lifetimePointsEarned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoyaltyAccount;
  return Object.hash(runtimeType,_this.userId,_this.pointsBalance,_this.lifetimePointsEarned);
}

@override
String toString() {
  final _this = this as LoyaltyAccount;
  return 'LoyaltyAccount(userId: ${_this.userId}, pointsBalance: ${_this.pointsBalance}, lifetimePointsEarned: ${_this.lifetimePointsEarned})';
}


}

/// @nodoc
abstract mixin class $LoyaltyAccountCopyWith<$Res>  {
  factory $LoyaltyAccountCopyWith(LoyaltyAccount value, $Res Function(LoyaltyAccount) _then) = _$LoyaltyAccountCopyWithImpl;
@useResult
$Res call({
 String userId, int pointsBalance, int lifetimePointsEarned
});




}
/// @nodoc
class _$LoyaltyAccountCopyWithImpl<$Res>
    implements $LoyaltyAccountCopyWith<$Res> {
  _$LoyaltyAccountCopyWithImpl(this._self, this._then);

  final LoyaltyAccount _self;
  final $Res Function(LoyaltyAccount) _then;

/// Create a copy of LoyaltyAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? pointsBalance = null,Object? lifetimePointsEarned = null,}) {
  return _then(LoyaltyAccount(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,pointsBalance: null == pointsBalance ? _self.pointsBalance : pointsBalance // ignore: cast_nullable_to_non_nullable
as int,lifetimePointsEarned: null == lifetimePointsEarned ? _self.lifetimePointsEarned : lifetimePointsEarned // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LoyaltyAccount].
extension LoyaltyAccountPatterns on LoyaltyAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoyaltyAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoyaltyAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoyaltyAccount value)  $default,){
final _that = this;
switch (_that) {
case _LoyaltyAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoyaltyAccount value)?  $default,){
final _that = this;
switch (_that) {
case _LoyaltyAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int pointsBalance,  int lifetimePointsEarned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoyaltyAccount() when $default != null:
return $default(_that.userId,_that.pointsBalance,_that.lifetimePointsEarned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int pointsBalance,  int lifetimePointsEarned)  $default,) {final _that = this;
switch (_that) {
case _LoyaltyAccount():
return $default(_that.userId,_that.pointsBalance,_that.lifetimePointsEarned);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int pointsBalance,  int lifetimePointsEarned)?  $default,) {final _that = this;
switch (_that) {
case _LoyaltyAccount() when $default != null:
return $default(_that.userId,_that.pointsBalance,_that.lifetimePointsEarned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoyaltyAccount implements LoyaltyAccount {
  const _LoyaltyAccount({required this.userId, this.pointsBalance = 0, this.lifetimePointsEarned = 0});
  factory _LoyaltyAccount.fromJson(Map<String, dynamic> json) => _$LoyaltyAccountFromJson(json);

@override final  String userId;
@override@JsonKey() final  int pointsBalance;
@override@JsonKey() final  int lifetimePointsEarned;

/// Create a copy of LoyaltyAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoyaltyAccountCopyWith<_LoyaltyAccount> get copyWith => __$LoyaltyAccountCopyWithImpl<_LoyaltyAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoyaltyAccountToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoyaltyAccount&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.pointsBalance, pointsBalance) || other.pointsBalance == pointsBalance)&&(identical(other.lifetimePointsEarned, lifetimePointsEarned) || other.lifetimePointsEarned == lifetimePointsEarned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,userId,pointsBalance,lifetimePointsEarned);
}

@override
String toString() {
    return 'LoyaltyAccount(userId: $userId, pointsBalance: $pointsBalance, lifetimePointsEarned: $lifetimePointsEarned)';
}


}

/// @nodoc
abstract mixin class _$LoyaltyAccountCopyWith<$Res> implements $LoyaltyAccountCopyWith<$Res> {
  factory _$LoyaltyAccountCopyWith(_LoyaltyAccount value, $Res Function(_LoyaltyAccount) _then) = __$LoyaltyAccountCopyWithImpl;
@override @useResult
$Res call({
 String userId, int pointsBalance, int lifetimePointsEarned
});




}
/// @nodoc
class __$LoyaltyAccountCopyWithImpl<$Res>
    implements _$LoyaltyAccountCopyWith<$Res> {
  __$LoyaltyAccountCopyWithImpl(this._self, this._then);

  final _LoyaltyAccount _self;
  final $Res Function(_LoyaltyAccount) _then;

/// Create a copy of LoyaltyAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? pointsBalance = null,Object? lifetimePointsEarned = null,}) {
  return _then(_LoyaltyAccount(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,pointsBalance: null == pointsBalance ? _self.pointsBalance : pointsBalance // ignore: cast_nullable_to_non_nullable
as int,lifetimePointsEarned: null == lifetimePointsEarned ? _self.lifetimePointsEarned : lifetimePointsEarned // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LoyaltyTransaction {

 String get id; String get userId; String? get orderId; LoyaltyTransactionType get type; int get points; int get balanceAfter; DateTime get createdAt;
/// Create a copy of LoyaltyTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoyaltyTransactionCopyWith<LoyaltyTransaction> get copyWith => _$LoyaltyTransactionCopyWithImpl<LoyaltyTransaction>(this as LoyaltyTransaction, _$identity);

  /// Serializes this LoyaltyTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LoyaltyTransaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoyaltyTransaction&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.points, _this.points) || other.points == _this.points)&&(identical(other.balanceAfter, _this.balanceAfter) || other.balanceAfter == _this.balanceAfter)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LoyaltyTransaction;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.orderId,_this.type,_this.points,_this.balanceAfter,_this.createdAt);
}

@override
String toString() {
  final _this = this as LoyaltyTransaction;
  return 'LoyaltyTransaction(id: ${_this.id}, userId: ${_this.userId}, orderId: ${_this.orderId}, type: ${_this.type}, points: ${_this.points}, balanceAfter: ${_this.balanceAfter}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $LoyaltyTransactionCopyWith<$Res>  {
  factory $LoyaltyTransactionCopyWith(LoyaltyTransaction value, $Res Function(LoyaltyTransaction) _then) = _$LoyaltyTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? orderId, LoyaltyTransactionType type, int points, int balanceAfter, DateTime createdAt
});




}
/// @nodoc
class _$LoyaltyTransactionCopyWithImpl<$Res>
    implements $LoyaltyTransactionCopyWith<$Res> {
  _$LoyaltyTransactionCopyWithImpl(this._self, this._then);

  final LoyaltyTransaction _self;
  final $Res Function(LoyaltyTransaction) _then;

/// Create a copy of LoyaltyTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? orderId = freezed,Object? type = null,Object? points = null,Object? balanceAfter = null,Object? createdAt = null,}) {
  return _then(LoyaltyTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LoyaltyTransactionType,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,balanceAfter: null == balanceAfter ? _self.balanceAfter : balanceAfter // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [LoyaltyTransaction].
extension LoyaltyTransactionPatterns on LoyaltyTransaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoyaltyTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoyaltyTransaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoyaltyTransaction value)  $default,){
final _that = this;
switch (_that) {
case _LoyaltyTransaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoyaltyTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _LoyaltyTransaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? orderId,  LoyaltyTransactionType type,  int points,  int balanceAfter,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoyaltyTransaction() when $default != null:
return $default(_that.id,_that.userId,_that.orderId,_that.type,_that.points,_that.balanceAfter,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? orderId,  LoyaltyTransactionType type,  int points,  int balanceAfter,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _LoyaltyTransaction():
return $default(_that.id,_that.userId,_that.orderId,_that.type,_that.points,_that.balanceAfter,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? orderId,  LoyaltyTransactionType type,  int points,  int balanceAfter,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LoyaltyTransaction() when $default != null:
return $default(_that.id,_that.userId,_that.orderId,_that.type,_that.points,_that.balanceAfter,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoyaltyTransaction implements LoyaltyTransaction {
  const _LoyaltyTransaction({required this.id, required this.userId, this.orderId, required this.type, required this.points, required this.balanceAfter, required this.createdAt});
  factory _LoyaltyTransaction.fromJson(Map<String, dynamic> json) => _$LoyaltyTransactionFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String? orderId;
@override final  LoyaltyTransactionType type;
@override final  int points;
@override final  int balanceAfter;
@override final  DateTime createdAt;

/// Create a copy of LoyaltyTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoyaltyTransactionCopyWith<_LoyaltyTransaction> get copyWith => __$LoyaltyTransactionCopyWithImpl<_LoyaltyTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoyaltyTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoyaltyTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.type, type) || other.type == type)&&(identical(other.points, points) || other.points == points)&&(identical(other.balanceAfter, balanceAfter) || other.balanceAfter == balanceAfter)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,orderId,type,points,balanceAfter,createdAt);
}

@override
String toString() {
    return 'LoyaltyTransaction(id: $id, userId: $userId, orderId: $orderId, type: $type, points: $points, balanceAfter: $balanceAfter, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LoyaltyTransactionCopyWith<$Res> implements $LoyaltyTransactionCopyWith<$Res> {
  factory _$LoyaltyTransactionCopyWith(_LoyaltyTransaction value, $Res Function(_LoyaltyTransaction) _then) = __$LoyaltyTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? orderId, LoyaltyTransactionType type, int points, int balanceAfter, DateTime createdAt
});




}
/// @nodoc
class __$LoyaltyTransactionCopyWithImpl<$Res>
    implements _$LoyaltyTransactionCopyWith<$Res> {
  __$LoyaltyTransactionCopyWithImpl(this._self, this._then);

  final _LoyaltyTransaction _self;
  final $Res Function(_LoyaltyTransaction) _then;

/// Create a copy of LoyaltyTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? orderId = freezed,Object? type = null,Object? points = null,Object? balanceAfter = null,Object? createdAt = null,}) {
  return _then(_LoyaltyTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,orderId: freezed == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LoyaltyTransactionType,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,balanceAfter: null == balanceAfter ? _self.balanceAfter : balanceAfter // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
