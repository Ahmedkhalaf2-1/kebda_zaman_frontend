// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverAccount {

 String get id; String get name; String? get email; String? get phone; bool get isActive; DateTime get createdAt;@JsonKey(name: 'availability', fromJson: _availabilityFromWire, includeToJson: false) DriverAvailability get availability; String? get activeOrderId;
/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverAccountCopyWith<DriverAccount> get copyWith => _$DriverAccountCopyWithImpl<DriverAccount>(this as DriverAccount, _$identity);

  /// Serializes this DriverAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as DriverAccount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverAccount&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.availability, _this.availability) || other.availability == _this.availability)&&(identical(other.activeOrderId, _this.activeOrderId) || other.activeOrderId == _this.activeOrderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as DriverAccount;
  return Object.hash(runtimeType,_this.id,_this.name,_this.email,_this.phone,_this.isActive,_this.createdAt,_this.availability,_this.activeOrderId);
}

@override
String toString() {
  final _this = this as DriverAccount;
  return 'DriverAccount(id: ${_this.id}, name: ${_this.name}, email: ${_this.email}, phone: ${_this.phone}, isActive: ${_this.isActive}, createdAt: ${_this.createdAt}, availability: ${_this.availability}, activeOrderId: ${_this.activeOrderId})';
}


}

/// @nodoc
abstract mixin class $DriverAccountCopyWith<$Res>  {
  factory $DriverAccountCopyWith(DriverAccount value, $Res Function(DriverAccount) _then) = _$DriverAccountCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? email, String? phone, bool isActive, DateTime createdAt,@JsonKey(name: 'availability', fromJson: _availabilityFromWire, includeToJson: false) DriverAvailability availability, String? activeOrderId
});




}
/// @nodoc
class _$DriverAccountCopyWithImpl<$Res>
    implements $DriverAccountCopyWith<$Res> {
  _$DriverAccountCopyWithImpl(this._self, this._then);

  final DriverAccount _self;
  final $Res Function(DriverAccount) _then;

/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? isActive = null,Object? createdAt = null,Object? availability = null,Object? activeOrderId = freezed,}) {
  return _then(DriverAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as DriverAvailability,activeOrderId: freezed == activeOrderId ? _self.activeOrderId : activeOrderId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverAccount].
extension DriverAccountPatterns on DriverAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverAccount value)  $default,){
final _that = this;
switch (_that) {
case _DriverAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverAccount value)?  $default,){
final _that = this;
switch (_that) {
case _DriverAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? email,  String? phone,  bool isActive,  DateTime createdAt, @JsonKey(name: 'availability', fromJson: _availabilityFromWire, includeToJson: false)  DriverAvailability availability,  String? activeOrderId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverAccount() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.isActive,_that.createdAt,_that.availability,_that.activeOrderId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? email,  String? phone,  bool isActive,  DateTime createdAt, @JsonKey(name: 'availability', fromJson: _availabilityFromWire, includeToJson: false)  DriverAvailability availability,  String? activeOrderId)  $default,) {final _that = this;
switch (_that) {
case _DriverAccount():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.isActive,_that.createdAt,_that.availability,_that.activeOrderId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? email,  String? phone,  bool isActive,  DateTime createdAt, @JsonKey(name: 'availability', fromJson: _availabilityFromWire, includeToJson: false)  DriverAvailability availability,  String? activeOrderId)?  $default,) {final _that = this;
switch (_that) {
case _DriverAccount() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.isActive,_that.createdAt,_that.availability,_that.activeOrderId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverAccount implements DriverAccount {
  const _DriverAccount({required this.id, required this.name, this.email, this.phone, required this.isActive, required this.createdAt, @JsonKey(name: 'availability', fromJson: _availabilityFromWire, includeToJson: false) this.availability = DriverAvailability.unknown, this.activeOrderId});
  factory _DriverAccount.fromJson(Map<String, dynamic> json) => _$DriverAccountFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? email;
@override final  String? phone;
@override final  bool isActive;
@override final  DateTime createdAt;
@override@JsonKey(name: 'availability', fromJson: _availabilityFromWire, includeToJson: false) final  DriverAvailability availability;
@override final  String? activeOrderId;

/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverAccountCopyWith<_DriverAccount> get copyWith => __$DriverAccountCopyWithImpl<_DriverAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverAccountToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.availability, availability) || other.availability == availability)&&(identical(other.activeOrderId, activeOrderId) || other.activeOrderId == activeOrderId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,email,phone,isActive,createdAt,availability,activeOrderId);
}

@override
String toString() {
    return 'DriverAccount(id: $id, name: $name, email: $email, phone: $phone, isActive: $isActive, createdAt: $createdAt, availability: $availability, activeOrderId: $activeOrderId)';
}


}

/// @nodoc
abstract mixin class _$DriverAccountCopyWith<$Res> implements $DriverAccountCopyWith<$Res> {
  factory _$DriverAccountCopyWith(_DriverAccount value, $Res Function(_DriverAccount) _then) = __$DriverAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? email, String? phone, bool isActive, DateTime createdAt,@JsonKey(name: 'availability', fromJson: _availabilityFromWire, includeToJson: false) DriverAvailability availability, String? activeOrderId
});




}
/// @nodoc
class __$DriverAccountCopyWithImpl<$Res>
    implements _$DriverAccountCopyWith<$Res> {
  __$DriverAccountCopyWithImpl(this._self, this._then);

  final _DriverAccount _self;
  final $Res Function(_DriverAccount) _then;

/// Create a copy of DriverAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? isActive = null,Object? createdAt = null,Object? availability = null,Object? activeOrderId = freezed,}) {
  return _then(_DriverAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as DriverAvailability,activeOrderId: freezed == activeOrderId ? _self.activeOrderId : activeOrderId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
