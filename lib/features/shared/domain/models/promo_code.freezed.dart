// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'promo_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PromoCode {

 String get id; String get code; DiscountType get discountType; double get value; double get minOrderValue; DateTime get startDate; DateTime get endDate; bool get isActive; int? get usageLimit; int? get perUserLimit; int get usageCount;
/// Create a copy of PromoCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PromoCodeCopyWith<PromoCode> get copyWith => _$PromoCodeCopyWithImpl<PromoCode>(this as PromoCode, _$identity);

  /// Serializes this PromoCode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PromoCode;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PromoCode&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.discountType, _this.discountType) || other.discountType == _this.discountType)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.minOrderValue, _this.minOrderValue) || other.minOrderValue == _this.minOrderValue)&&(identical(other.startDate, _this.startDate) || other.startDate == _this.startDate)&&(identical(other.endDate, _this.endDate) || other.endDate == _this.endDate)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.usageLimit, _this.usageLimit) || other.usageLimit == _this.usageLimit)&&(identical(other.perUserLimit, _this.perUserLimit) || other.perUserLimit == _this.perUserLimit)&&(identical(other.usageCount, _this.usageCount) || other.usageCount == _this.usageCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PromoCode;
  return Object.hash(runtimeType,_this.id,_this.code,_this.discountType,_this.value,_this.minOrderValue,_this.startDate,_this.endDate,_this.isActive,_this.usageLimit,_this.perUserLimit,_this.usageCount);
}

@override
String toString() {
  final _this = this as PromoCode;
  return 'PromoCode(id: ${_this.id}, code: ${_this.code}, discountType: ${_this.discountType}, value: ${_this.value}, minOrderValue: ${_this.minOrderValue}, startDate: ${_this.startDate}, endDate: ${_this.endDate}, isActive: ${_this.isActive}, usageLimit: ${_this.usageLimit}, perUserLimit: ${_this.perUserLimit}, usageCount: ${_this.usageCount})';
}


}

/// @nodoc
abstract mixin class $PromoCodeCopyWith<$Res>  {
  factory $PromoCodeCopyWith(PromoCode value, $Res Function(PromoCode) _then) = _$PromoCodeCopyWithImpl;
@useResult
$Res call({
 String id, String code, DiscountType discountType, double value, double minOrderValue, DateTime startDate, DateTime endDate, bool isActive, int? usageLimit, int? perUserLimit, int usageCount
});




}
/// @nodoc
class _$PromoCodeCopyWithImpl<$Res>
    implements $PromoCodeCopyWith<$Res> {
  _$PromoCodeCopyWithImpl(this._self, this._then);

  final PromoCode _self;
  final $Res Function(PromoCode) _then;

/// Create a copy of PromoCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? discountType = null,Object? value = null,Object? minOrderValue = null,Object? startDate = null,Object? endDate = null,Object? isActive = null,Object? usageLimit = freezed,Object? perUserLimit = freezed,Object? usageCount = null,}) {
  return _then(PromoCode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as DiscountType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,minOrderValue: null == minOrderValue ? _self.minOrderValue : minOrderValue // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,usageLimit: freezed == usageLimit ? _self.usageLimit : usageLimit // ignore: cast_nullable_to_non_nullable
as int?,perUserLimit: freezed == perUserLimit ? _self.perUserLimit : perUserLimit // ignore: cast_nullable_to_non_nullable
as int?,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PromoCode].
extension PromoCodePatterns on PromoCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PromoCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PromoCode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PromoCode value)  $default,){
final _that = this;
switch (_that) {
case _PromoCode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PromoCode value)?  $default,){
final _that = this;
switch (_that) {
case _PromoCode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  DiscountType discountType,  double value,  double minOrderValue,  DateTime startDate,  DateTime endDate,  bool isActive,  int? usageLimit,  int? perUserLimit,  int usageCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PromoCode() when $default != null:
return $default(_that.id,_that.code,_that.discountType,_that.value,_that.minOrderValue,_that.startDate,_that.endDate,_that.isActive,_that.usageLimit,_that.perUserLimit,_that.usageCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  DiscountType discountType,  double value,  double minOrderValue,  DateTime startDate,  DateTime endDate,  bool isActive,  int? usageLimit,  int? perUserLimit,  int usageCount)  $default,) {final _that = this;
switch (_that) {
case _PromoCode():
return $default(_that.id,_that.code,_that.discountType,_that.value,_that.minOrderValue,_that.startDate,_that.endDate,_that.isActive,_that.usageLimit,_that.perUserLimit,_that.usageCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  DiscountType discountType,  double value,  double minOrderValue,  DateTime startDate,  DateTime endDate,  bool isActive,  int? usageLimit,  int? perUserLimit,  int usageCount)?  $default,) {final _that = this;
switch (_that) {
case _PromoCode() when $default != null:
return $default(_that.id,_that.code,_that.discountType,_that.value,_that.minOrderValue,_that.startDate,_that.endDate,_that.isActive,_that.usageLimit,_that.perUserLimit,_that.usageCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PromoCode implements PromoCode {
  const _PromoCode({required this.id, required this.code, required this.discountType, required this.value, this.minOrderValue = 0.0, required this.startDate, required this.endDate, this.isActive = true, this.usageLimit, this.perUserLimit, this.usageCount = 0});
  factory _PromoCode.fromJson(Map<String, dynamic> json) => _$PromoCodeFromJson(json);

@override final  String id;
@override final  String code;
@override final  DiscountType discountType;
@override final  double value;
@override@JsonKey() final  double minOrderValue;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override@JsonKey() final  bool isActive;
@override final  int? usageLimit;
@override final  int? perUserLimit;
@override@JsonKey() final  int usageCount;

/// Create a copy of PromoCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PromoCodeCopyWith<_PromoCode> get copyWith => __$PromoCodeCopyWithImpl<_PromoCode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PromoCodeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PromoCode&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.value, value) || other.value == value)&&(identical(other.minOrderValue, minOrderValue) || other.minOrderValue == minOrderValue)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.usageLimit, usageLimit) || other.usageLimit == usageLimit)&&(identical(other.perUserLimit, perUserLimit) || other.perUserLimit == perUserLimit)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,code,discountType,value,minOrderValue,startDate,endDate,isActive,usageLimit,perUserLimit,usageCount);
}

@override
String toString() {
    return 'PromoCode(id: $id, code: $code, discountType: $discountType, value: $value, minOrderValue: $minOrderValue, startDate: $startDate, endDate: $endDate, isActive: $isActive, usageLimit: $usageLimit, perUserLimit: $perUserLimit, usageCount: $usageCount)';
}


}

/// @nodoc
abstract mixin class _$PromoCodeCopyWith<$Res> implements $PromoCodeCopyWith<$Res> {
  factory _$PromoCodeCopyWith(_PromoCode value, $Res Function(_PromoCode) _then) = __$PromoCodeCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, DiscountType discountType, double value, double minOrderValue, DateTime startDate, DateTime endDate, bool isActive, int? usageLimit, int? perUserLimit, int usageCount
});




}
/// @nodoc
class __$PromoCodeCopyWithImpl<$Res>
    implements _$PromoCodeCopyWith<$Res> {
  __$PromoCodeCopyWithImpl(this._self, this._then);

  final _PromoCode _self;
  final $Res Function(_PromoCode) _then;

/// Create a copy of PromoCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? discountType = null,Object? value = null,Object? minOrderValue = null,Object? startDate = null,Object? endDate = null,Object? isActive = null,Object? usageLimit = freezed,Object? perUserLimit = freezed,Object? usageCount = null,}) {
  return _then(_PromoCode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as DiscountType,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double,minOrderValue: null == minOrderValue ? _self.minOrderValue : minOrderValue // ignore: cast_nullable_to_non_nullable
as double,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,usageLimit: freezed == usageLimit ? _self.usageLimit : usageLimit // ignore: cast_nullable_to_non_nullable
as int?,perUserLimit: freezed == perUserLimit ? _self.perUserLimit : perUserLimit // ignore: cast_nullable_to_non_nullable
as int?,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
