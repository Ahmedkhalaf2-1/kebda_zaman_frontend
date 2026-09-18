// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$User {

 String get id; String? get phone; String get name; String? get email; List<String> get addressIds; List<String> get favoriteItemIds; String? get loyaltyAccountId; String? get role; bool get isGuest; DateTime get createdAt;
/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserCopyWith<User> get copyWith => _$UserCopyWithImpl<User>(this as User, _$identity);

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as User;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is User&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.email, _this.email) || other.email == _this.email)&&const DeepCollectionEquality().equals(other.addressIds, _this.addressIds)&&const DeepCollectionEquality().equals(other.favoriteItemIds, _this.favoriteItemIds)&&(identical(other.loyaltyAccountId, _this.loyaltyAccountId) || other.loyaltyAccountId == _this.loyaltyAccountId)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.isGuest, _this.isGuest) || other.isGuest == _this.isGuest)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as User;
  return Object.hash(runtimeType,_this.id,_this.phone,_this.name,_this.email,const DeepCollectionEquality().hash(_this.addressIds),const DeepCollectionEquality().hash(_this.favoriteItemIds),_this.loyaltyAccountId,_this.role,_this.isGuest,_this.createdAt);
}

@override
String toString() {
  final _this = this as User;
  return 'User(id: ${_this.id}, phone: ${_this.phone}, name: ${_this.name}, email: ${_this.email}, addressIds: ${_this.addressIds}, favoriteItemIds: ${_this.favoriteItemIds}, loyaltyAccountId: ${_this.loyaltyAccountId}, role: ${_this.role}, isGuest: ${_this.isGuest}, createdAt: ${_this.createdAt})';
}


}

/// @nodoc
abstract mixin class $UserCopyWith<$Res>  {
  factory $UserCopyWith(User value, $Res Function(User) _then) = _$UserCopyWithImpl;
@useResult
$Res call({
 String id, String? phone, String name, String? email, List<String> addressIds, List<String> favoriteItemIds, String? loyaltyAccountId, String? role, bool isGuest, DateTime createdAt
});




}
/// @nodoc
class _$UserCopyWithImpl<$Res>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._self, this._then);

  final User _self;
  final $Res Function(User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? phone = freezed,Object? name = null,Object? email = freezed,Object? addressIds = null,Object? favoriteItemIds = null,Object? loyaltyAccountId = freezed,Object? role = freezed,Object? isGuest = null,Object? createdAt = null,}) {
  return _then(User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,addressIds: null == addressIds ? _self.addressIds : addressIds // ignore: cast_nullable_to_non_nullable
as List<String>,favoriteItemIds: null == favoriteItemIds ? _self.favoriteItemIds : favoriteItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,loyaltyAccountId: freezed == loyaltyAccountId ? _self.loyaltyAccountId : loyaltyAccountId // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [User].
extension UserPatterns on User {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _User value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _User value)  $default,){
final _that = this;
switch (_that) {
case _User():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _User value)?  $default,){
final _that = this;
switch (_that) {
case _User() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? phone,  String name,  String? email,  List<String> addressIds,  List<String> favoriteItemIds,  String? loyaltyAccountId,  String? role,  bool isGuest,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.phone,_that.name,_that.email,_that.addressIds,_that.favoriteItemIds,_that.loyaltyAccountId,_that.role,_that.isGuest,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? phone,  String name,  String? email,  List<String> addressIds,  List<String> favoriteItemIds,  String? loyaltyAccountId,  String? role,  bool isGuest,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _User():
return $default(_that.id,_that.phone,_that.name,_that.email,_that.addressIds,_that.favoriteItemIds,_that.loyaltyAccountId,_that.role,_that.isGuest,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? phone,  String name,  String? email,  List<String> addressIds,  List<String> favoriteItemIds,  String? loyaltyAccountId,  String? role,  bool isGuest,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _User() when $default != null:
return $default(_that.id,_that.phone,_that.name,_that.email,_that.addressIds,_that.favoriteItemIds,_that.loyaltyAccountId,_that.role,_that.isGuest,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _User implements User {
  const _User({required this.id, this.phone, required this.name, this.email,  List<String> addressIds = const [],  List<String> favoriteItemIds = const [], this.loyaltyAccountId, this.role, this.isGuest = false, required this.createdAt}): _addressIds = addressIds,_favoriteItemIds = favoriteItemIds;
  factory _User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

@override final  String id;
@override final  String? phone;
@override final  String name;
@override final  String? email;
 final  List<String> _addressIds;
@override@JsonKey() List<String> get addressIds {
  if (_addressIds is EqualUnmodifiableListView) return _addressIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_addressIds);
}

 final  List<String> _favoriteItemIds;
@override@JsonKey() List<String> get favoriteItemIds {
  if (_favoriteItemIds is EqualUnmodifiableListView) return _favoriteItemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favoriteItemIds);
}

@override final  String? loyaltyAccountId;
@override final  String? role;
@override@JsonKey() final  bool isGuest;
@override final  DateTime createdAt;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserCopyWith<_User> get copyWith => __$UserCopyWithImpl<_User>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _User&&(identical(other.id, id) || other.id == id)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&const DeepCollectionEquality().equals(other.addressIds, _addressIds)&&const DeepCollectionEquality().equals(other.favoriteItemIds, _favoriteItemIds)&&(identical(other.loyaltyAccountId, loyaltyAccountId) || other.loyaltyAccountId == loyaltyAccountId)&&(identical(other.role, role) || other.role == role)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,phone,name,email,const DeepCollectionEquality().hash(_addressIds),const DeepCollectionEquality().hash(_favoriteItemIds),loyaltyAccountId,role,isGuest,createdAt);
}

@override
String toString() {
    return 'User(id: $id, phone: $phone, name: $name, email: $email, addressIds: $addressIds, favoriteItemIds: $favoriteItemIds, loyaltyAccountId: $loyaltyAccountId, role: $role, isGuest: $isGuest, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UserCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$UserCopyWith(_User value, $Res Function(_User) _then) = __$UserCopyWithImpl;
@override @useResult
$Res call({
 String id, String? phone, String name, String? email, List<String> addressIds, List<String> favoriteItemIds, String? loyaltyAccountId, String? role, bool isGuest, DateTime createdAt
});




}
/// @nodoc
class __$UserCopyWithImpl<$Res>
    implements _$UserCopyWith<$Res> {
  __$UserCopyWithImpl(this._self, this._then);

  final _User _self;
  final $Res Function(_User) _then;

/// Create a copy of User
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? phone = freezed,Object? name = null,Object? email = freezed,Object? addressIds = null,Object? favoriteItemIds = null,Object? loyaltyAccountId = freezed,Object? role = freezed,Object? isGuest = null,Object? createdAt = null,}) {
  return _then(_User(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,addressIds: null == addressIds ? _self._addressIds : addressIds // ignore: cast_nullable_to_non_nullable
as List<String>,favoriteItemIds: null == favoriteItemIds ? _self._favoriteItemIds : favoriteItemIds // ignore: cast_nullable_to_non_nullable
as List<String>,loyaltyAccountId: freezed == loyaltyAccountId ? _self.loyaltyAccountId : loyaltyAccountId // ignore: cast_nullable_to_non_nullable
as String?,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
