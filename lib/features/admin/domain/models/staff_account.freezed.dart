// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StaffAccount {

 String get id; String get name; String? get email; String? get phone; String get role; bool get isActive; DateTime get createdAt;
/// Create a copy of StaffAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffAccountCopyWith<StaffAccount> get copyWith => _$StaffAccountCopyWithImpl<StaffAccount>(this as StaffAccount, _$identity);

  /// Serializes this StaffAccount to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as StaffAccount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffAccount&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as StaffAccount;
  return Object.hash(runtimeType,_this.id,_this.name,_this.email,_this.phone,_this.role,_this.isActive,_this.createdAt);
}

@override
String toString() {
  final _this = this as StaffAccount;
  return 'StaffAccount(id: ${_this.id}, name: ${_this.name}, email: ${_this.email}, phone: ${_this.phone}, role: ${_this.role}, isActive: ${_this.isActive}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $StaffAccountCopyWith<$Res>  {
  factory $StaffAccountCopyWith(StaffAccount value, $Res Function(StaffAccount) _then) = _$StaffAccountCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? email, String? phone, String role, bool isActive, DateTime createdAt
});




}
/// @nodoc
class _$StaffAccountCopyWithImpl<$Res>
    implements $StaffAccountCopyWith<$Res> {
  _$StaffAccountCopyWithImpl(this._self, this._then);

  final StaffAccount _self;
  final $Res Function(StaffAccount) _then;

/// Create a copy of StaffAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? role = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(StaffAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StaffAccount].
extension StaffAccountPatterns on StaffAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StaffAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StaffAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StaffAccount value)  $default,){
final _that = this;
switch (_that) {
case _StaffAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StaffAccount value)?  $default,){
final _that = this;
switch (_that) {
case _StaffAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? email,  String? phone,  String role,  bool isActive,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StaffAccount() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.role,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? email,  String? phone,  String role,  bool isActive,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _StaffAccount():
return $default(_that.id,_that.name,_that.email,_that.phone,_that.role,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? email,  String? phone,  String role,  bool isActive,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _StaffAccount() when $default != null:
return $default(_that.id,_that.name,_that.email,_that.phone,_that.role,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StaffAccount implements StaffAccount {
  const _StaffAccount({required this.id, required this.name, this.email, this.phone, required this.role, required this.isActive, required this.createdAt});
  factory _StaffAccount.fromJson(Map<String, dynamic> json) => _$StaffAccountFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? email;
@override final  String? phone;
@override final  String role;
@override final  bool isActive;
@override final  DateTime createdAt;

/// Create a copy of StaffAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffAccountCopyWith<_StaffAccount> get copyWith => __$StaffAccountCopyWithImpl<_StaffAccount>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StaffAccountToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.role, role) || other.role == role)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,email,phone,role,isActive,createdAt);
}

@override
String toString() {
    return 'StaffAccount(id: $id, name: $name, email: $email, phone: $phone, role: $role, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$StaffAccountCopyWith<$Res> implements $StaffAccountCopyWith<$Res> {
  factory _$StaffAccountCopyWith(_StaffAccount value, $Res Function(_StaffAccount) _then) = __$StaffAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? email, String? phone, String role, bool isActive, DateTime createdAt
});




}
/// @nodoc
class __$StaffAccountCopyWithImpl<$Res>
    implements _$StaffAccountCopyWith<$Res> {
  __$StaffAccountCopyWithImpl(this._self, this._then);

  final _StaffAccount _self;
  final $Res Function(_StaffAccount) _then;

/// Create a copy of StaffAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? email = freezed,Object? phone = freezed,Object? role = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_StaffAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
