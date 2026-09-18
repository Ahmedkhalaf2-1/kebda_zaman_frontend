// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ItemReview {

 String get id; String get orderItemId; String? get menuItemId; int get rating; String? get comment; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of ItemReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemReviewCopyWith<ItemReview> get copyWith => _$ItemReviewCopyWithImpl<ItemReview>(this as ItemReview, _$identity);

  /// Serializes this ItemReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ItemReview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemReview&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.orderItemId, _this.orderItemId) || other.orderItemId == _this.orderItemId)&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ItemReview;
  return Object.hash(runtimeType,_this.id,_this.orderItemId,_this.menuItemId,_this.rating,_this.comment,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as ItemReview;
  return 'ItemReview(id: ${_this.id}, orderItemId: ${_this.orderItemId}, menuItemId: ${_this.menuItemId}, rating: ${_this.rating}, comment: ${_this.comment}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $ItemReviewCopyWith<$Res>  {
  factory $ItemReviewCopyWith(ItemReview value, $Res Function(ItemReview) _then) = _$ItemReviewCopyWithImpl;
@useResult
$Res call({
 String id, String orderItemId, String? menuItemId, int rating, String? comment, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$ItemReviewCopyWithImpl<$Res>
    implements $ItemReviewCopyWith<$Res> {
  _$ItemReviewCopyWithImpl(this._self, this._then);

  final ItemReview _self;
  final $Res Function(ItemReview) _then;

/// Create a copy of ItemReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderItemId = null,Object? menuItemId = freezed,Object? rating = null,Object? comment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(ItemReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderItemId: null == orderItemId ? _self.orderItemId : orderItemId // ignore: cast_nullable_to_non_nullable
as String,menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemReview].
extension ItemReviewPatterns on ItemReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemReview value)  $default,){
final _that = this;
switch (_that) {
case _ItemReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemReview value)?  $default,){
final _that = this;
switch (_that) {
case _ItemReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orderItemId,  String? menuItemId,  int rating,  String? comment,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemReview() when $default != null:
return $default(_that.id,_that.orderItemId,_that.menuItemId,_that.rating,_that.comment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orderItemId,  String? menuItemId,  int rating,  String? comment,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ItemReview():
return $default(_that.id,_that.orderItemId,_that.menuItemId,_that.rating,_that.comment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orderItemId,  String? menuItemId,  int rating,  String? comment,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ItemReview() when $default != null:
return $default(_that.id,_that.orderItemId,_that.menuItemId,_that.rating,_that.comment,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemReview implements ItemReview {
  const _ItemReview({required this.id, required this.orderItemId, this.menuItemId, required this.rating, this.comment, required this.createdAt, required this.updatedAt});
  factory _ItemReview.fromJson(Map<String, dynamic> json) => _$ItemReviewFromJson(json);

@override final  String id;
@override final  String orderItemId;
@override final  String? menuItemId;
@override final  int rating;
@override final  String? comment;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of ItemReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemReviewCopyWith<_ItemReview> get copyWith => __$ItemReviewCopyWithImpl<_ItemReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemReviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemReview&&(identical(other.id, id) || other.id == id)&&(identical(other.orderItemId, orderItemId) || other.orderItemId == orderItemId)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,orderItemId,menuItemId,rating,comment,createdAt,updatedAt);
}

@override
String toString() {
    return 'ItemReview(id: $id, orderItemId: $orderItemId, menuItemId: $menuItemId, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ItemReviewCopyWith<$Res> implements $ItemReviewCopyWith<$Res> {
  factory _$ItemReviewCopyWith(_ItemReview value, $Res Function(_ItemReview) _then) = __$ItemReviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String orderItemId, String? menuItemId, int rating, String? comment, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$ItemReviewCopyWithImpl<$Res>
    implements _$ItemReviewCopyWith<$Res> {
  __$ItemReviewCopyWithImpl(this._self, this._then);

  final _ItemReview _self;
  final $Res Function(_ItemReview) _then;

/// Create a copy of ItemReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderItemId = null,Object? menuItemId = freezed,Object? rating = null,Object? comment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ItemReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderItemId: null == orderItemId ? _self.orderItemId : orderItemId // ignore: cast_nullable_to_non_nullable
as String,menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$OrderFeedback {

 String get id; String get orderId; int get rating; String? get comment; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of OrderFeedback
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderFeedbackCopyWith<OrderFeedback> get copyWith => _$OrderFeedbackCopyWithImpl<OrderFeedback>(this as OrderFeedback, _$identity);

  /// Serializes this OrderFeedback to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrderFeedback;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderFeedback&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrderFeedback;
  return Object.hash(runtimeType,_this.id,_this.orderId,_this.rating,_this.comment,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as OrderFeedback;
  return 'OrderFeedback(id: ${_this.id}, orderId: ${_this.orderId}, rating: ${_this.rating}, comment: ${_this.comment}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $OrderFeedbackCopyWith<$Res>  {
  factory $OrderFeedbackCopyWith(OrderFeedback value, $Res Function(OrderFeedback) _then) = _$OrderFeedbackCopyWithImpl;
@useResult
$Res call({
 String id, String orderId, int rating, String? comment, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$OrderFeedbackCopyWithImpl<$Res>
    implements $OrderFeedbackCopyWith<$Res> {
  _$OrderFeedbackCopyWithImpl(this._self, this._then);

  final OrderFeedback _self;
  final $Res Function(OrderFeedback) _then;

/// Create a copy of OrderFeedback
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderId = null,Object? rating = null,Object? comment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(OrderFeedback(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderFeedback].
extension OrderFeedbackPatterns on OrderFeedback {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderFeedback value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderFeedback() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderFeedback value)  $default,){
final _that = this;
switch (_that) {
case _OrderFeedback():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderFeedback value)?  $default,){
final _that = this;
switch (_that) {
case _OrderFeedback() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orderId,  int rating,  String? comment,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderFeedback() when $default != null:
return $default(_that.id,_that.orderId,_that.rating,_that.comment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orderId,  int rating,  String? comment,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _OrderFeedback():
return $default(_that.id,_that.orderId,_that.rating,_that.comment,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orderId,  int rating,  String? comment,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _OrderFeedback() when $default != null:
return $default(_that.id,_that.orderId,_that.rating,_that.comment,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderFeedback implements OrderFeedback {
  const _OrderFeedback({required this.id, required this.orderId, required this.rating, this.comment, required this.createdAt, required this.updatedAt});
  factory _OrderFeedback.fromJson(Map<String, dynamic> json) => _$OrderFeedbackFromJson(json);

@override final  String id;
@override final  String orderId;
@override final  int rating;
@override final  String? comment;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of OrderFeedback
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderFeedbackCopyWith<_OrderFeedback> get copyWith => __$OrderFeedbackCopyWithImpl<_OrderFeedback>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderFeedbackToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,orderId,rating,comment,createdAt,updatedAt);
}

@override
String toString() {
    return 'OrderFeedback(id: $id, orderId: $orderId, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderFeedbackCopyWith<$Res> implements $OrderFeedbackCopyWith<$Res> {
  factory _$OrderFeedbackCopyWith(_OrderFeedback value, $Res Function(_OrderFeedback) _then) = __$OrderFeedbackCopyWithImpl;
@override @useResult
$Res call({
 String id, String orderId, int rating, String? comment, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$OrderFeedbackCopyWithImpl<$Res>
    implements _$OrderFeedbackCopyWith<$Res> {
  __$OrderFeedbackCopyWithImpl(this._self, this._then);

  final _OrderFeedback _self;
  final $Res Function(_OrderFeedback) _then;

/// Create a copy of OrderFeedback
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderId = null,Object? rating = null,Object? comment = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_OrderFeedback(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$OrderReviewItem {

 String get orderItemId; String? get menuItemId; String get nameAr; String get nameEn; String? get imageUrl; int get quantity; ItemReview? get review;
/// Create a copy of OrderReviewItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderReviewItemCopyWith<OrderReviewItem> get copyWith => _$OrderReviewItemCopyWithImpl<OrderReviewItem>(this as OrderReviewItem, _$identity);

  /// Serializes this OrderReviewItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrderReviewItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderReviewItem&&(identical(other.orderItemId, _this.orderItemId) || other.orderItemId == _this.orderItemId)&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.nameAr, _this.nameAr) || other.nameAr == _this.nameAr)&&(identical(other.nameEn, _this.nameEn) || other.nameEn == _this.nameEn)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.review, _this.review) || other.review == _this.review));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrderReviewItem;
  return Object.hash(runtimeType,_this.orderItemId,_this.menuItemId,_this.nameAr,_this.nameEn,_this.imageUrl,_this.quantity,_this.review);
}

@override
String toString() {
  final _this = this as OrderReviewItem;
  return 'OrderReviewItem(orderItemId: ${_this.orderItemId}, menuItemId: ${_this.menuItemId}, nameAr: ${_this.nameAr}, nameEn: ${_this.nameEn}, imageUrl: ${_this.imageUrl}, quantity: ${_this.quantity}, review: ${_this.review})';
}


}

/// @nodoc
abstract mixin class $OrderReviewItemCopyWith<$Res>  {
  factory $OrderReviewItemCopyWith(OrderReviewItem value, $Res Function(OrderReviewItem) _then) = _$OrderReviewItemCopyWithImpl;
@useResult
$Res call({
 String orderItemId, String? menuItemId, String nameAr, String nameEn, String? imageUrl, int quantity, ItemReview? review
});


$ItemReviewCopyWith<$Res>? get review;

}
/// @nodoc
class _$OrderReviewItemCopyWithImpl<$Res>
    implements $OrderReviewItemCopyWith<$Res> {
  _$OrderReviewItemCopyWithImpl(this._self, this._then);

  final OrderReviewItem _self;
  final $Res Function(OrderReviewItem) _then;

/// Create a copy of OrderReviewItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderItemId = null,Object? menuItemId = freezed,Object? nameAr = null,Object? nameEn = null,Object? imageUrl = freezed,Object? quantity = null,Object? review = freezed,}) {
  return _then(OrderReviewItem(
orderItemId: null == orderItemId ? _self.orderItemId : orderItemId // ignore: cast_nullable_to_non_nullable
as String,menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String?,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as ItemReview?,
  ));
}
/// Create a copy of OrderReviewItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemReviewCopyWith<$Res>? get review {
    if (_self.review == null) {
    return null;
  }

  return $ItemReviewCopyWith<$Res>(_self.review!, (value) {
    return _then(_self.copyWith(review: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderReviewItem].
extension OrderReviewItemPatterns on OrderReviewItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderReviewItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderReviewItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderReviewItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderReviewItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderReviewItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderReviewItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String orderItemId,  String? menuItemId,  String nameAr,  String nameEn,  String? imageUrl,  int quantity,  ItemReview? review)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderReviewItem() when $default != null:
return $default(_that.orderItemId,_that.menuItemId,_that.nameAr,_that.nameEn,_that.imageUrl,_that.quantity,_that.review);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String orderItemId,  String? menuItemId,  String nameAr,  String nameEn,  String? imageUrl,  int quantity,  ItemReview? review)  $default,) {final _that = this;
switch (_that) {
case _OrderReviewItem():
return $default(_that.orderItemId,_that.menuItemId,_that.nameAr,_that.nameEn,_that.imageUrl,_that.quantity,_that.review);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String orderItemId,  String? menuItemId,  String nameAr,  String nameEn,  String? imageUrl,  int quantity,  ItemReview? review)?  $default,) {final _that = this;
switch (_that) {
case _OrderReviewItem() when $default != null:
return $default(_that.orderItemId,_that.menuItemId,_that.nameAr,_that.nameEn,_that.imageUrl,_that.quantity,_that.review);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderReviewItem implements OrderReviewItem {
  const _OrderReviewItem({required this.orderItemId, this.menuItemId, required this.nameAr, required this.nameEn, this.imageUrl, required this.quantity, this.review});
  factory _OrderReviewItem.fromJson(Map<String, dynamic> json) => _$OrderReviewItemFromJson(json);

@override final  String orderItemId;
@override final  String? menuItemId;
@override final  String nameAr;
@override final  String nameEn;
@override final  String? imageUrl;
@override final  int quantity;
@override final  ItemReview? review;

/// Create a copy of OrderReviewItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderReviewItemCopyWith<_OrderReviewItem> get copyWith => __$OrderReviewItemCopyWithImpl<_OrderReviewItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderReviewItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderReviewItem&&(identical(other.orderItemId, orderItemId) || other.orderItemId == orderItemId)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.review, review) || other.review == review));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,orderItemId,menuItemId,nameAr,nameEn,imageUrl,quantity,review);
}

@override
String toString() {
    return 'OrderReviewItem(orderItemId: $orderItemId, menuItemId: $menuItemId, nameAr: $nameAr, nameEn: $nameEn, imageUrl: $imageUrl, quantity: $quantity, review: $review)';
}


}

/// @nodoc
abstract mixin class _$OrderReviewItemCopyWith<$Res> implements $OrderReviewItemCopyWith<$Res> {
  factory _$OrderReviewItemCopyWith(_OrderReviewItem value, $Res Function(_OrderReviewItem) _then) = __$OrderReviewItemCopyWithImpl;
@override @useResult
$Res call({
 String orderItemId, String? menuItemId, String nameAr, String nameEn, String? imageUrl, int quantity, ItemReview? review
});


@override $ItemReviewCopyWith<$Res>? get review;

}
/// @nodoc
class __$OrderReviewItemCopyWithImpl<$Res>
    implements _$OrderReviewItemCopyWith<$Res> {
  __$OrderReviewItemCopyWithImpl(this._self, this._then);

  final _OrderReviewItem _self;
  final $Res Function(_OrderReviewItem) _then;

/// Create a copy of OrderReviewItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderItemId = null,Object? menuItemId = freezed,Object? nameAr = null,Object? nameEn = null,Object? imageUrl = freezed,Object? quantity = null,Object? review = freezed,}) {
  return _then(_OrderReviewItem(
orderItemId: null == orderItemId ? _self.orderItemId : orderItemId // ignore: cast_nullable_to_non_nullable
as String,menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String?,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as ItemReview?,
  ));
}

/// Create a copy of OrderReviewItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ItemReviewCopyWith<$Res>? get review {
    if (_self.review == null) {
    return null;
  }

  return $ItemReviewCopyWith<$Res>(_self.review!, (value) {
    return _then(_self.copyWith(review: value));
  });
}
}


/// @nodoc
mixin _$OrderReviewDetails {

 String get orderId; String get orderStatus; bool get eligible; List<OrderReviewItem> get items; OrderFeedback? get orderFeedback;
/// Create a copy of OrderReviewDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderReviewDetailsCopyWith<OrderReviewDetails> get copyWith => _$OrderReviewDetailsCopyWithImpl<OrderReviewDetails>(this as OrderReviewDetails, _$identity);

  /// Serializes this OrderReviewDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OrderReviewDetails;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderReviewDetails&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.orderStatus, _this.orderStatus) || other.orderStatus == _this.orderStatus)&&(identical(other.eligible, _this.eligible) || other.eligible == _this.eligible)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.orderFeedback, _this.orderFeedback) || other.orderFeedback == _this.orderFeedback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OrderReviewDetails;
  return Object.hash(runtimeType,_this.orderId,_this.orderStatus,_this.eligible,const DeepCollectionEquality().hash(_this.items),_this.orderFeedback);
}

@override
String toString() {
  final _this = this as OrderReviewDetails;
  return 'OrderReviewDetails(orderId: ${_this.orderId}, orderStatus: ${_this.orderStatus}, eligible: ${_this.eligible}, items: ${_this.items}, orderFeedback: ${_this.orderFeedback})';
}


}

/// @nodoc
abstract mixin class $OrderReviewDetailsCopyWith<$Res>  {
  factory $OrderReviewDetailsCopyWith(OrderReviewDetails value, $Res Function(OrderReviewDetails) _then) = _$OrderReviewDetailsCopyWithImpl;
@useResult
$Res call({
 String orderId, String orderStatus, bool eligible, List<OrderReviewItem> items, OrderFeedback? orderFeedback
});


$OrderFeedbackCopyWith<$Res>? get orderFeedback;

}
/// @nodoc
class _$OrderReviewDetailsCopyWithImpl<$Res>
    implements $OrderReviewDetailsCopyWith<$Res> {
  _$OrderReviewDetailsCopyWithImpl(this._self, this._then);

  final OrderReviewDetails _self;
  final $Res Function(OrderReviewDetails) _then;

/// Create a copy of OrderReviewDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = null,Object? orderStatus = null,Object? eligible = null,Object? items = null,Object? orderFeedback = freezed,}) {
  return _then(OrderReviewDetails(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,orderStatus: null == orderStatus ? _self.orderStatus : orderStatus // ignore: cast_nullable_to_non_nullable
as String,eligible: null == eligible ? _self.eligible : eligible // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderReviewItem>,orderFeedback: freezed == orderFeedback ? _self.orderFeedback : orderFeedback // ignore: cast_nullable_to_non_nullable
as OrderFeedback?,
  ));
}
/// Create a copy of OrderReviewDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderFeedbackCopyWith<$Res>? get orderFeedback {
    if (_self.orderFeedback == null) {
    return null;
  }

  return $OrderFeedbackCopyWith<$Res>(_self.orderFeedback!, (value) {
    return _then(_self.copyWith(orderFeedback: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderReviewDetails].
extension OrderReviewDetailsPatterns on OrderReviewDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderReviewDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderReviewDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderReviewDetails value)  $default,){
final _that = this;
switch (_that) {
case _OrderReviewDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderReviewDetails value)?  $default,){
final _that = this;
switch (_that) {
case _OrderReviewDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String orderId,  String orderStatus,  bool eligible,  List<OrderReviewItem> items,  OrderFeedback? orderFeedback)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderReviewDetails() when $default != null:
return $default(_that.orderId,_that.orderStatus,_that.eligible,_that.items,_that.orderFeedback);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String orderId,  String orderStatus,  bool eligible,  List<OrderReviewItem> items,  OrderFeedback? orderFeedback)  $default,) {final _that = this;
switch (_that) {
case _OrderReviewDetails():
return $default(_that.orderId,_that.orderStatus,_that.eligible,_that.items,_that.orderFeedback);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String orderId,  String orderStatus,  bool eligible,  List<OrderReviewItem> items,  OrderFeedback? orderFeedback)?  $default,) {final _that = this;
switch (_that) {
case _OrderReviewDetails() when $default != null:
return $default(_that.orderId,_that.orderStatus,_that.eligible,_that.items,_that.orderFeedback);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OrderReviewDetails implements OrderReviewDetails {
  const _OrderReviewDetails({required this.orderId, required this.orderStatus, required this.eligible, required  List<OrderReviewItem> items, this.orderFeedback}): _items = items;
  factory _OrderReviewDetails.fromJson(Map<String, dynamic> json) => _$OrderReviewDetailsFromJson(json);

@override final  String orderId;
@override final  String orderStatus;
@override final  bool eligible;
 final  List<OrderReviewItem> _items;
@override List<OrderReviewItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  OrderFeedback? orderFeedback;

/// Create a copy of OrderReviewDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderReviewDetailsCopyWith<_OrderReviewDetails> get copyWith => __$OrderReviewDetailsCopyWithImpl<_OrderReviewDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OrderReviewDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderReviewDetails&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.orderStatus, orderStatus) || other.orderStatus == orderStatus)&&(identical(other.eligible, eligible) || other.eligible == eligible)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.orderFeedback, orderFeedback) || other.orderFeedback == orderFeedback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,orderId,orderStatus,eligible,const DeepCollectionEquality().hash(_items),orderFeedback);
}

@override
String toString() {
    return 'OrderReviewDetails(orderId: $orderId, orderStatus: $orderStatus, eligible: $eligible, items: $items, orderFeedback: $orderFeedback)';
}


}

/// @nodoc
abstract mixin class _$OrderReviewDetailsCopyWith<$Res> implements $OrderReviewDetailsCopyWith<$Res> {
  factory _$OrderReviewDetailsCopyWith(_OrderReviewDetails value, $Res Function(_OrderReviewDetails) _then) = __$OrderReviewDetailsCopyWithImpl;
@override @useResult
$Res call({
 String orderId, String orderStatus, bool eligible, List<OrderReviewItem> items, OrderFeedback? orderFeedback
});


@override $OrderFeedbackCopyWith<$Res>? get orderFeedback;

}
/// @nodoc
class __$OrderReviewDetailsCopyWithImpl<$Res>
    implements _$OrderReviewDetailsCopyWith<$Res> {
  __$OrderReviewDetailsCopyWithImpl(this._self, this._then);

  final _OrderReviewDetails _self;
  final $Res Function(_OrderReviewDetails) _then;

/// Create a copy of OrderReviewDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? orderStatus = null,Object? eligible = null,Object? items = null,Object? orderFeedback = freezed,}) {
  return _then(_OrderReviewDetails(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,orderStatus: null == orderStatus ? _self.orderStatus : orderStatus // ignore: cast_nullable_to_non_nullable
as String,eligible: null == eligible ? _self.eligible : eligible // ignore: cast_nullable_to_non_nullable
as bool,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderReviewItem>,orderFeedback: freezed == orderFeedback ? _self.orderFeedback : orderFeedback // ignore: cast_nullable_to_non_nullable
as OrderFeedback?,
  ));
}

/// Create a copy of OrderReviewDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OrderFeedbackCopyWith<$Res>? get orderFeedback {
    if (_self.orderFeedback == null) {
    return null;
  }

  return $OrderFeedbackCopyWith<$Res>(_self.orderFeedback!, (value) {
    return _then(_self.copyWith(orderFeedback: value));
  });
}
}


/// @nodoc
mixin _$AdminReviewCustomer {

 String get id; String get fullName; String? get email; String? get phone;
/// Create a copy of AdminReviewCustomer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminReviewCustomerCopyWith<AdminReviewCustomer> get copyWith => _$AdminReviewCustomerCopyWithImpl<AdminReviewCustomer>(this as AdminReviewCustomer, _$identity);

  /// Serializes this AdminReviewCustomer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminReviewCustomer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminReviewCustomer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.email, _this.email) || other.email == _this.email)&&(identical(other.phone, _this.phone) || other.phone == _this.phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminReviewCustomer;
  return Object.hash(runtimeType,_this.id,_this.fullName,_this.email,_this.phone);
}

@override
String toString() {
  final _this = this as AdminReviewCustomer;
  return 'AdminReviewCustomer(id: ${_this.id}, fullName: ${_this.fullName}, email: ${_this.email}, phone: ${_this.phone})';
}


}

/// @nodoc
abstract mixin class $AdminReviewCustomerCopyWith<$Res>  {
  factory $AdminReviewCustomerCopyWith(AdminReviewCustomer value, $Res Function(AdminReviewCustomer) _then) = _$AdminReviewCustomerCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String? email, String? phone
});




}
/// @nodoc
class _$AdminReviewCustomerCopyWithImpl<$Res>
    implements $AdminReviewCustomerCopyWith<$Res> {
  _$AdminReviewCustomerCopyWithImpl(this._self, this._then);

  final AdminReviewCustomer _self;
  final $Res Function(AdminReviewCustomer) _then;

/// Create a copy of AdminReviewCustomer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? email = freezed,Object? phone = freezed,}) {
  return _then(AdminReviewCustomer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminReviewCustomer].
extension AdminReviewCustomerPatterns on AdminReviewCustomer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminReviewCustomer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminReviewCustomer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminReviewCustomer value)  $default,){
final _that = this;
switch (_that) {
case _AdminReviewCustomer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminReviewCustomer value)?  $default,){
final _that = this;
switch (_that) {
case _AdminReviewCustomer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String? email,  String? phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminReviewCustomer() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String? email,  String? phone)  $default,) {final _that = this;
switch (_that) {
case _AdminReviewCustomer():
return $default(_that.id,_that.fullName,_that.email,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String? email,  String? phone)?  $default,) {final _that = this;
switch (_that) {
case _AdminReviewCustomer() when $default != null:
return $default(_that.id,_that.fullName,_that.email,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminReviewCustomer implements AdminReviewCustomer {
  const _AdminReviewCustomer({required this.id, required this.fullName, this.email, this.phone});
  factory _AdminReviewCustomer.fromJson(Map<String, dynamic> json) => _$AdminReviewCustomerFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String? email;
@override final  String? phone;

/// Create a copy of AdminReviewCustomer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminReviewCustomerCopyWith<_AdminReviewCustomer> get copyWith => __$AdminReviewCustomerCopyWithImpl<_AdminReviewCustomer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminReviewCustomerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminReviewCustomer&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fullName,email,phone);
}

@override
String toString() {
    return 'AdminReviewCustomer(id: $id, fullName: $fullName, email: $email, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$AdminReviewCustomerCopyWith<$Res> implements $AdminReviewCustomerCopyWith<$Res> {
  factory _$AdminReviewCustomerCopyWith(_AdminReviewCustomer value, $Res Function(_AdminReviewCustomer) _then) = __$AdminReviewCustomerCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String? email, String? phone
});




}
/// @nodoc
class __$AdminReviewCustomerCopyWithImpl<$Res>
    implements _$AdminReviewCustomerCopyWith<$Res> {
  __$AdminReviewCustomerCopyWithImpl(this._self, this._then);

  final _AdminReviewCustomer _self;
  final $Res Function(_AdminReviewCustomer) _then;

/// Create a copy of AdminReviewCustomer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? email = freezed,Object? phone = freezed,}) {
  return _then(_AdminReviewCustomer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AdminReviewOrderRef {

 String get id; String get orderNumber;
/// Create a copy of AdminReviewOrderRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminReviewOrderRefCopyWith<AdminReviewOrderRef> get copyWith => _$AdminReviewOrderRefCopyWithImpl<AdminReviewOrderRef>(this as AdminReviewOrderRef, _$identity);

  /// Serializes this AdminReviewOrderRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminReviewOrderRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminReviewOrderRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.orderNumber, _this.orderNumber) || other.orderNumber == _this.orderNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminReviewOrderRef;
  return Object.hash(runtimeType,_this.id,_this.orderNumber);
}

@override
String toString() {
  final _this = this as AdminReviewOrderRef;
  return 'AdminReviewOrderRef(id: ${_this.id}, orderNumber: ${_this.orderNumber})';
}


}

/// @nodoc
abstract mixin class $AdminReviewOrderRefCopyWith<$Res>  {
  factory $AdminReviewOrderRefCopyWith(AdminReviewOrderRef value, $Res Function(AdminReviewOrderRef) _then) = _$AdminReviewOrderRefCopyWithImpl;
@useResult
$Res call({
 String id, String orderNumber
});




}
/// @nodoc
class _$AdminReviewOrderRefCopyWithImpl<$Res>
    implements $AdminReviewOrderRefCopyWith<$Res> {
  _$AdminReviewOrderRefCopyWithImpl(this._self, this._then);

  final AdminReviewOrderRef _self;
  final $Res Function(AdminReviewOrderRef) _then;

/// Create a copy of AdminReviewOrderRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,}) {
  return _then(AdminReviewOrderRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminReviewOrderRef].
extension AdminReviewOrderRefPatterns on AdminReviewOrderRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminReviewOrderRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminReviewOrderRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminReviewOrderRef value)  $default,){
final _that = this;
switch (_that) {
case _AdminReviewOrderRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminReviewOrderRef value)?  $default,){
final _that = this;
switch (_that) {
case _AdminReviewOrderRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orderNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminReviewOrderRef() when $default != null:
return $default(_that.id,_that.orderNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orderNumber)  $default,) {final _that = this;
switch (_that) {
case _AdminReviewOrderRef():
return $default(_that.id,_that.orderNumber);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orderNumber)?  $default,) {final _that = this;
switch (_that) {
case _AdminReviewOrderRef() when $default != null:
return $default(_that.id,_that.orderNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminReviewOrderRef implements AdminReviewOrderRef {
  const _AdminReviewOrderRef({required this.id, required this.orderNumber});
  factory _AdminReviewOrderRef.fromJson(Map<String, dynamic> json) => _$AdminReviewOrderRefFromJson(json);

@override final  String id;
@override final  String orderNumber;

/// Create a copy of AdminReviewOrderRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminReviewOrderRefCopyWith<_AdminReviewOrderRef> get copyWith => __$AdminReviewOrderRefCopyWithImpl<_AdminReviewOrderRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminReviewOrderRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminReviewOrderRef&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,orderNumber);
}

@override
String toString() {
    return 'AdminReviewOrderRef(id: $id, orderNumber: $orderNumber)';
}


}

/// @nodoc
abstract mixin class _$AdminReviewOrderRefCopyWith<$Res> implements $AdminReviewOrderRefCopyWith<$Res> {
  factory _$AdminReviewOrderRefCopyWith(_AdminReviewOrderRef value, $Res Function(_AdminReviewOrderRef) _then) = __$AdminReviewOrderRefCopyWithImpl;
@override @useResult
$Res call({
 String id, String orderNumber
});




}
/// @nodoc
class __$AdminReviewOrderRefCopyWithImpl<$Res>
    implements _$AdminReviewOrderRefCopyWith<$Res> {
  __$AdminReviewOrderRefCopyWithImpl(this._self, this._then);

  final _AdminReviewOrderRef _self;
  final $Res Function(_AdminReviewOrderRef) _then;

/// Create a copy of AdminReviewOrderRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,}) {
  return _then(_AdminReviewOrderRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AdminReviewItemRef {

 String get orderItemId; String? get menuItemId; String get nameAr; String get nameEn; String? get imageUrl;
/// Create a copy of AdminReviewItemRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminReviewItemRefCopyWith<AdminReviewItemRef> get copyWith => _$AdminReviewItemRefCopyWithImpl<AdminReviewItemRef>(this as AdminReviewItemRef, _$identity);

  /// Serializes this AdminReviewItemRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminReviewItemRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminReviewItemRef&&(identical(other.orderItemId, _this.orderItemId) || other.orderItemId == _this.orderItemId)&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.nameAr, _this.nameAr) || other.nameAr == _this.nameAr)&&(identical(other.nameEn, _this.nameEn) || other.nameEn == _this.nameEn)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminReviewItemRef;
  return Object.hash(runtimeType,_this.orderItemId,_this.menuItemId,_this.nameAr,_this.nameEn,_this.imageUrl);
}

@override
String toString() {
  final _this = this as AdminReviewItemRef;
  return 'AdminReviewItemRef(orderItemId: ${_this.orderItemId}, menuItemId: ${_this.menuItemId}, nameAr: ${_this.nameAr}, nameEn: ${_this.nameEn}, imageUrl: ${_this.imageUrl})';
}


}

/// @nodoc
abstract mixin class $AdminReviewItemRefCopyWith<$Res>  {
  factory $AdminReviewItemRefCopyWith(AdminReviewItemRef value, $Res Function(AdminReviewItemRef) _then) = _$AdminReviewItemRefCopyWithImpl;
@useResult
$Res call({
 String orderItemId, String? menuItemId, String nameAr, String nameEn, String? imageUrl
});




}
/// @nodoc
class _$AdminReviewItemRefCopyWithImpl<$Res>
    implements $AdminReviewItemRefCopyWith<$Res> {
  _$AdminReviewItemRefCopyWithImpl(this._self, this._then);

  final AdminReviewItemRef _self;
  final $Res Function(AdminReviewItemRef) _then;

/// Create a copy of AdminReviewItemRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderItemId = null,Object? menuItemId = freezed,Object? nameAr = null,Object? nameEn = null,Object? imageUrl = freezed,}) {
  return _then(AdminReviewItemRef(
orderItemId: null == orderItemId ? _self.orderItemId : orderItemId // ignore: cast_nullable_to_non_nullable
as String,menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String?,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminReviewItemRef].
extension AdminReviewItemRefPatterns on AdminReviewItemRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminReviewItemRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminReviewItemRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminReviewItemRef value)  $default,){
final _that = this;
switch (_that) {
case _AdminReviewItemRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminReviewItemRef value)?  $default,){
final _that = this;
switch (_that) {
case _AdminReviewItemRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String orderItemId,  String? menuItemId,  String nameAr,  String nameEn,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminReviewItemRef() when $default != null:
return $default(_that.orderItemId,_that.menuItemId,_that.nameAr,_that.nameEn,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String orderItemId,  String? menuItemId,  String nameAr,  String nameEn,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _AdminReviewItemRef():
return $default(_that.orderItemId,_that.menuItemId,_that.nameAr,_that.nameEn,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String orderItemId,  String? menuItemId,  String nameAr,  String nameEn,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _AdminReviewItemRef() when $default != null:
return $default(_that.orderItemId,_that.menuItemId,_that.nameAr,_that.nameEn,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminReviewItemRef implements AdminReviewItemRef {
  const _AdminReviewItemRef({required this.orderItemId, this.menuItemId, required this.nameAr, required this.nameEn, this.imageUrl});
  factory _AdminReviewItemRef.fromJson(Map<String, dynamic> json) => _$AdminReviewItemRefFromJson(json);

@override final  String orderItemId;
@override final  String? menuItemId;
@override final  String nameAr;
@override final  String nameEn;
@override final  String? imageUrl;

/// Create a copy of AdminReviewItemRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminReviewItemRefCopyWith<_AdminReviewItemRef> get copyWith => __$AdminReviewItemRefCopyWithImpl<_AdminReviewItemRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminReviewItemRefToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminReviewItemRef&&(identical(other.orderItemId, orderItemId) || other.orderItemId == orderItemId)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,orderItemId,menuItemId,nameAr,nameEn,imageUrl);
}

@override
String toString() {
    return 'AdminReviewItemRef(orderItemId: $orderItemId, menuItemId: $menuItemId, nameAr: $nameAr, nameEn: $nameEn, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$AdminReviewItemRefCopyWith<$Res> implements $AdminReviewItemRefCopyWith<$Res> {
  factory _$AdminReviewItemRefCopyWith(_AdminReviewItemRef value, $Res Function(_AdminReviewItemRef) _then) = __$AdminReviewItemRefCopyWithImpl;
@override @useResult
$Res call({
 String orderItemId, String? menuItemId, String nameAr, String nameEn, String? imageUrl
});




}
/// @nodoc
class __$AdminReviewItemRefCopyWithImpl<$Res>
    implements _$AdminReviewItemRefCopyWith<$Res> {
  __$AdminReviewItemRefCopyWithImpl(this._self, this._then);

  final _AdminReviewItemRef _self;
  final $Res Function(_AdminReviewItemRef) _then;

/// Create a copy of AdminReviewItemRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderItemId = null,Object? menuItemId = freezed,Object? nameAr = null,Object? nameEn = null,Object? imageUrl = freezed,}) {
  return _then(_AdminReviewItemRef(
orderItemId: null == orderItemId ? _self.orderItemId : orderItemId // ignore: cast_nullable_to_non_nullable
as String,menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String?,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$AdminItemReview {

 String get id; int get rating; String? get comment; DateTime get createdAt; DateTime get updatedAt; AdminReviewCustomer get customer; AdminReviewOrderRef get order; AdminReviewItemRef get item;
/// Create a copy of AdminItemReview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminItemReviewCopyWith<AdminItemReview> get copyWith => _$AdminItemReviewCopyWithImpl<AdminItemReview>(this as AdminItemReview, _$identity);

  /// Serializes this AdminItemReview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminItemReview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminItemReview&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.customer, _this.customer) || other.customer == _this.customer)&&(identical(other.order, _this.order) || other.order == _this.order)&&(identical(other.item, _this.item) || other.item == _this.item));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminItemReview;
  return Object.hash(runtimeType,_this.id,_this.rating,_this.comment,_this.createdAt,_this.updatedAt,_this.customer,_this.order,_this.item);
}

@override
String toString() {
  final _this = this as AdminItemReview;
  return 'AdminItemReview(id: ${_this.id}, rating: ${_this.rating}, comment: ${_this.comment}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, customer: ${_this.customer}, order: ${_this.order}, item: ${_this.item})';
}


}

/// @nodoc
abstract mixin class $AdminItemReviewCopyWith<$Res>  {
  factory $AdminItemReviewCopyWith(AdminItemReview value, $Res Function(AdminItemReview) _then) = _$AdminItemReviewCopyWithImpl;
@useResult
$Res call({
 String id, int rating, String? comment, DateTime createdAt, DateTime updatedAt, AdminReviewCustomer customer, AdminReviewOrderRef order, AdminReviewItemRef item
});


$AdminReviewCustomerCopyWith<$Res> get customer;$AdminReviewOrderRefCopyWith<$Res> get order;$AdminReviewItemRefCopyWith<$Res> get item;

}
/// @nodoc
class _$AdminItemReviewCopyWithImpl<$Res>
    implements $AdminItemReviewCopyWith<$Res> {
  _$AdminItemReviewCopyWithImpl(this._self, this._then);

  final AdminItemReview _self;
  final $Res Function(AdminItemReview) _then;

/// Create a copy of AdminItemReview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rating = null,Object? comment = freezed,Object? createdAt = null,Object? updatedAt = null,Object? customer = null,Object? order = null,Object? item = null,}) {
  return _then(AdminItemReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as AdminReviewCustomer,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as AdminReviewOrderRef,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as AdminReviewItemRef,
  ));
}
/// Create a copy of AdminItemReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminReviewCustomerCopyWith<$Res> get customer {
  
  return $AdminReviewCustomerCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of AdminItemReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminReviewOrderRefCopyWith<$Res> get order {
  
  return $AdminReviewOrderRefCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}/// Create a copy of AdminItemReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminReviewItemRefCopyWith<$Res> get item {
  
  return $AdminReviewItemRefCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}


/// Adds pattern-matching-related methods to [AdminItemReview].
extension AdminItemReviewPatterns on AdminItemReview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminItemReview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminItemReview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminItemReview value)  $default,){
final _that = this;
switch (_that) {
case _AdminItemReview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminItemReview value)?  $default,){
final _that = this;
switch (_that) {
case _AdminItemReview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int rating,  String? comment,  DateTime createdAt,  DateTime updatedAt,  AdminReviewCustomer customer,  AdminReviewOrderRef order,  AdminReviewItemRef item)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminItemReview() when $default != null:
return $default(_that.id,_that.rating,_that.comment,_that.createdAt,_that.updatedAt,_that.customer,_that.order,_that.item);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int rating,  String? comment,  DateTime createdAt,  DateTime updatedAt,  AdminReviewCustomer customer,  AdminReviewOrderRef order,  AdminReviewItemRef item)  $default,) {final _that = this;
switch (_that) {
case _AdminItemReview():
return $default(_that.id,_that.rating,_that.comment,_that.createdAt,_that.updatedAt,_that.customer,_that.order,_that.item);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int rating,  String? comment,  DateTime createdAt,  DateTime updatedAt,  AdminReviewCustomer customer,  AdminReviewOrderRef order,  AdminReviewItemRef item)?  $default,) {final _that = this;
switch (_that) {
case _AdminItemReview() when $default != null:
return $default(_that.id,_that.rating,_that.comment,_that.createdAt,_that.updatedAt,_that.customer,_that.order,_that.item);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminItemReview implements AdminItemReview {
  const _AdminItemReview({required this.id, required this.rating, this.comment, required this.createdAt, required this.updatedAt, required this.customer, required this.order, required this.item});
  factory _AdminItemReview.fromJson(Map<String, dynamic> json) => _$AdminItemReviewFromJson(json);

@override final  String id;
@override final  int rating;
@override final  String? comment;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  AdminReviewCustomer customer;
@override final  AdminReviewOrderRef order;
@override final  AdminReviewItemRef item;

/// Create a copy of AdminItemReview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminItemReviewCopyWith<_AdminItemReview> get copyWith => __$AdminItemReviewCopyWithImpl<_AdminItemReview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminItemReviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminItemReview&&(identical(other.id, id) || other.id == id)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.order, order) || other.order == order)&&(identical(other.item, item) || other.item == item));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,rating,comment,createdAt,updatedAt,customer,order,item);
}

@override
String toString() {
    return 'AdminItemReview(id: $id, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt, customer: $customer, order: $order, item: $item)';
}


}

/// @nodoc
abstract mixin class _$AdminItemReviewCopyWith<$Res> implements $AdminItemReviewCopyWith<$Res> {
  factory _$AdminItemReviewCopyWith(_AdminItemReview value, $Res Function(_AdminItemReview) _then) = __$AdminItemReviewCopyWithImpl;
@override @useResult
$Res call({
 String id, int rating, String? comment, DateTime createdAt, DateTime updatedAt, AdminReviewCustomer customer, AdminReviewOrderRef order, AdminReviewItemRef item
});


@override $AdminReviewCustomerCopyWith<$Res> get customer;@override $AdminReviewOrderRefCopyWith<$Res> get order;@override $AdminReviewItemRefCopyWith<$Res> get item;

}
/// @nodoc
class __$AdminItemReviewCopyWithImpl<$Res>
    implements _$AdminItemReviewCopyWith<$Res> {
  __$AdminItemReviewCopyWithImpl(this._self, this._then);

  final _AdminItemReview _self;
  final $Res Function(_AdminItemReview) _then;

/// Create a copy of AdminItemReview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rating = null,Object? comment = freezed,Object? createdAt = null,Object? updatedAt = null,Object? customer = null,Object? order = null,Object? item = null,}) {
  return _then(_AdminItemReview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as AdminReviewCustomer,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as AdminReviewOrderRef,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as AdminReviewItemRef,
  ));
}

/// Create a copy of AdminItemReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminReviewCustomerCopyWith<$Res> get customer {
  
  return $AdminReviewCustomerCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of AdminItemReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminReviewOrderRefCopyWith<$Res> get order {
  
  return $AdminReviewOrderRefCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}/// Create a copy of AdminItemReview
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminReviewItemRefCopyWith<$Res> get item {
  
  return $AdminReviewItemRefCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}


/// @nodoc
mixin _$AdminOrderFeedback {

 String get id; int get rating; String? get comment; DateTime get createdAt; DateTime get updatedAt; AdminReviewCustomer get customer; AdminReviewOrderRef get order;
/// Create a copy of AdminOrderFeedback
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminOrderFeedbackCopyWith<AdminOrderFeedback> get copyWith => _$AdminOrderFeedbackCopyWithImpl<AdminOrderFeedback>(this as AdminOrderFeedback, _$identity);

  /// Serializes this AdminOrderFeedback to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminOrderFeedback;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminOrderFeedback&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.rating, _this.rating) || other.rating == _this.rating)&&(identical(other.comment, _this.comment) || other.comment == _this.comment)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.customer, _this.customer) || other.customer == _this.customer)&&(identical(other.order, _this.order) || other.order == _this.order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminOrderFeedback;
  return Object.hash(runtimeType,_this.id,_this.rating,_this.comment,_this.createdAt,_this.updatedAt,_this.customer,_this.order);
}

@override
String toString() {
  final _this = this as AdminOrderFeedback;
  return 'AdminOrderFeedback(id: ${_this.id}, rating: ${_this.rating}, comment: ${_this.comment}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, customer: ${_this.customer}, order: ${_this.order})';
}


}

/// @nodoc
abstract mixin class $AdminOrderFeedbackCopyWith<$Res>  {
  factory $AdminOrderFeedbackCopyWith(AdminOrderFeedback value, $Res Function(AdminOrderFeedback) _then) = _$AdminOrderFeedbackCopyWithImpl;
@useResult
$Res call({
 String id, int rating, String? comment, DateTime createdAt, DateTime updatedAt, AdminReviewCustomer customer, AdminReviewOrderRef order
});


$AdminReviewCustomerCopyWith<$Res> get customer;$AdminReviewOrderRefCopyWith<$Res> get order;

}
/// @nodoc
class _$AdminOrderFeedbackCopyWithImpl<$Res>
    implements $AdminOrderFeedbackCopyWith<$Res> {
  _$AdminOrderFeedbackCopyWithImpl(this._self, this._then);

  final AdminOrderFeedback _self;
  final $Res Function(AdminOrderFeedback) _then;

/// Create a copy of AdminOrderFeedback
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? rating = null,Object? comment = freezed,Object? createdAt = null,Object? updatedAt = null,Object? customer = null,Object? order = null,}) {
  return _then(AdminOrderFeedback(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as AdminReviewCustomer,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as AdminReviewOrderRef,
  ));
}
/// Create a copy of AdminOrderFeedback
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminReviewCustomerCopyWith<$Res> get customer {
  
  return $AdminReviewCustomerCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of AdminOrderFeedback
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminReviewOrderRefCopyWith<$Res> get order {
  
  return $AdminReviewOrderRefCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}


/// Adds pattern-matching-related methods to [AdminOrderFeedback].
extension AdminOrderFeedbackPatterns on AdminOrderFeedback {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminOrderFeedback value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminOrderFeedback() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminOrderFeedback value)  $default,){
final _that = this;
switch (_that) {
case _AdminOrderFeedback():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminOrderFeedback value)?  $default,){
final _that = this;
switch (_that) {
case _AdminOrderFeedback() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int rating,  String? comment,  DateTime createdAt,  DateTime updatedAt,  AdminReviewCustomer customer,  AdminReviewOrderRef order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminOrderFeedback() when $default != null:
return $default(_that.id,_that.rating,_that.comment,_that.createdAt,_that.updatedAt,_that.customer,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int rating,  String? comment,  DateTime createdAt,  DateTime updatedAt,  AdminReviewCustomer customer,  AdminReviewOrderRef order)  $default,) {final _that = this;
switch (_that) {
case _AdminOrderFeedback():
return $default(_that.id,_that.rating,_that.comment,_that.createdAt,_that.updatedAt,_that.customer,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int rating,  String? comment,  DateTime createdAt,  DateTime updatedAt,  AdminReviewCustomer customer,  AdminReviewOrderRef order)?  $default,) {final _that = this;
switch (_that) {
case _AdminOrderFeedback() when $default != null:
return $default(_that.id,_that.rating,_that.comment,_that.createdAt,_that.updatedAt,_that.customer,_that.order);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminOrderFeedback implements AdminOrderFeedback {
  const _AdminOrderFeedback({required this.id, required this.rating, this.comment, required this.createdAt, required this.updatedAt, required this.customer, required this.order});
  factory _AdminOrderFeedback.fromJson(Map<String, dynamic> json) => _$AdminOrderFeedbackFromJson(json);

@override final  String id;
@override final  int rating;
@override final  String? comment;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  AdminReviewCustomer customer;
@override final  AdminReviewOrderRef order;

/// Create a copy of AdminOrderFeedback
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminOrderFeedbackCopyWith<_AdminOrderFeedback> get copyWith => __$AdminOrderFeedbackCopyWithImpl<_AdminOrderFeedback>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminOrderFeedbackToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminOrderFeedback&&(identical(other.id, id) || other.id == id)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.order, order) || other.order == order));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,rating,comment,createdAt,updatedAt,customer,order);
}

@override
String toString() {
    return 'AdminOrderFeedback(id: $id, rating: $rating, comment: $comment, createdAt: $createdAt, updatedAt: $updatedAt, customer: $customer, order: $order)';
}


}

/// @nodoc
abstract mixin class _$AdminOrderFeedbackCopyWith<$Res> implements $AdminOrderFeedbackCopyWith<$Res> {
  factory _$AdminOrderFeedbackCopyWith(_AdminOrderFeedback value, $Res Function(_AdminOrderFeedback) _then) = __$AdminOrderFeedbackCopyWithImpl;
@override @useResult
$Res call({
 String id, int rating, String? comment, DateTime createdAt, DateTime updatedAt, AdminReviewCustomer customer, AdminReviewOrderRef order
});


@override $AdminReviewCustomerCopyWith<$Res> get customer;@override $AdminReviewOrderRefCopyWith<$Res> get order;

}
/// @nodoc
class __$AdminOrderFeedbackCopyWithImpl<$Res>
    implements _$AdminOrderFeedbackCopyWith<$Res> {
  __$AdminOrderFeedbackCopyWithImpl(this._self, this._then);

  final _AdminOrderFeedback _self;
  final $Res Function(_AdminOrderFeedback) _then;

/// Create a copy of AdminOrderFeedback
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rating = null,Object? comment = freezed,Object? createdAt = null,Object? updatedAt = null,Object? customer = null,Object? order = null,}) {
  return _then(_AdminOrderFeedback(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as AdminReviewCustomer,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as AdminReviewOrderRef,
  ));
}

/// Create a copy of AdminOrderFeedback
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminReviewCustomerCopyWith<$Res> get customer {
  
  return $AdminReviewCustomerCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of AdminOrderFeedback
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminReviewOrderRefCopyWith<$Res> get order {
  
  return $AdminReviewOrderRefCopyWith<$Res>(_self.order, (value) {
    return _then(_self.copyWith(order: value));
  });
}
}


/// @nodoc
mixin _$AdminTopRatedItem {

 String get menuItemId; String? get nameAr; String? get nameEn; String? get imageUrl; double get averageRating; int get reviewCount;
/// Create a copy of AdminTopRatedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminTopRatedItemCopyWith<AdminTopRatedItem> get copyWith => _$AdminTopRatedItemCopyWithImpl<AdminTopRatedItem>(this as AdminTopRatedItem, _$identity);

  /// Serializes this AdminTopRatedItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminTopRatedItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminTopRatedItem&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.nameAr, _this.nameAr) || other.nameAr == _this.nameAr)&&(identical(other.nameEn, _this.nameEn) || other.nameEn == _this.nameEn)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.averageRating, _this.averageRating) || other.averageRating == _this.averageRating)&&(identical(other.reviewCount, _this.reviewCount) || other.reviewCount == _this.reviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminTopRatedItem;
  return Object.hash(runtimeType,_this.menuItemId,_this.nameAr,_this.nameEn,_this.imageUrl,_this.averageRating,_this.reviewCount);
}

@override
String toString() {
  final _this = this as AdminTopRatedItem;
  return 'AdminTopRatedItem(menuItemId: ${_this.menuItemId}, nameAr: ${_this.nameAr}, nameEn: ${_this.nameEn}, imageUrl: ${_this.imageUrl}, averageRating: ${_this.averageRating}, reviewCount: ${_this.reviewCount})';
}


}

/// @nodoc
abstract mixin class $AdminTopRatedItemCopyWith<$Res>  {
  factory $AdminTopRatedItemCopyWith(AdminTopRatedItem value, $Res Function(AdminTopRatedItem) _then) = _$AdminTopRatedItemCopyWithImpl;
@useResult
$Res call({
 String menuItemId, String? nameAr, String? nameEn, String? imageUrl, double averageRating, int reviewCount
});




}
/// @nodoc
class _$AdminTopRatedItemCopyWithImpl<$Res>
    implements $AdminTopRatedItemCopyWith<$Res> {
  _$AdminTopRatedItemCopyWithImpl(this._self, this._then);

  final AdminTopRatedItem _self;
  final $Res Function(AdminTopRatedItem) _then;

/// Create a copy of AdminTopRatedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? menuItemId = null,Object? nameAr = freezed,Object? nameEn = freezed,Object? imageUrl = freezed,Object? averageRating = null,Object? reviewCount = null,}) {
  return _then(AdminTopRatedItem(
menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminTopRatedItem].
extension AdminTopRatedItemPatterns on AdminTopRatedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminTopRatedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminTopRatedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminTopRatedItem value)  $default,){
final _that = this;
switch (_that) {
case _AdminTopRatedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminTopRatedItem value)?  $default,){
final _that = this;
switch (_that) {
case _AdminTopRatedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String menuItemId,  String? nameAr,  String? nameEn,  String? imageUrl,  double averageRating,  int reviewCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminTopRatedItem() when $default != null:
return $default(_that.menuItemId,_that.nameAr,_that.nameEn,_that.imageUrl,_that.averageRating,_that.reviewCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String menuItemId,  String? nameAr,  String? nameEn,  String? imageUrl,  double averageRating,  int reviewCount)  $default,) {final _that = this;
switch (_that) {
case _AdminTopRatedItem():
return $default(_that.menuItemId,_that.nameAr,_that.nameEn,_that.imageUrl,_that.averageRating,_that.reviewCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String menuItemId,  String? nameAr,  String? nameEn,  String? imageUrl,  double averageRating,  int reviewCount)?  $default,) {final _that = this;
switch (_that) {
case _AdminTopRatedItem() when $default != null:
return $default(_that.menuItemId,_that.nameAr,_that.nameEn,_that.imageUrl,_that.averageRating,_that.reviewCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminTopRatedItem implements AdminTopRatedItem {
  const _AdminTopRatedItem({required this.menuItemId, this.nameAr, this.nameEn, this.imageUrl, required this.averageRating, required this.reviewCount});
  factory _AdminTopRatedItem.fromJson(Map<String, dynamic> json) => _$AdminTopRatedItemFromJson(json);

@override final  String menuItemId;
@override final  String? nameAr;
@override final  String? nameEn;
@override final  String? imageUrl;
@override final  double averageRating;
@override final  int reviewCount;

/// Create a copy of AdminTopRatedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminTopRatedItemCopyWith<_AdminTopRatedItem> get copyWith => __$AdminTopRatedItemCopyWithImpl<_AdminTopRatedItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminTopRatedItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminTopRatedItem&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,menuItemId,nameAr,nameEn,imageUrl,averageRating,reviewCount);
}

@override
String toString() {
    return 'AdminTopRatedItem(menuItemId: $menuItemId, nameAr: $nameAr, nameEn: $nameEn, imageUrl: $imageUrl, averageRating: $averageRating, reviewCount: $reviewCount)';
}


}

/// @nodoc
abstract mixin class _$AdminTopRatedItemCopyWith<$Res> implements $AdminTopRatedItemCopyWith<$Res> {
  factory _$AdminTopRatedItemCopyWith(_AdminTopRatedItem value, $Res Function(_AdminTopRatedItem) _then) = __$AdminTopRatedItemCopyWithImpl;
@override @useResult
$Res call({
 String menuItemId, String? nameAr, String? nameEn, String? imageUrl, double averageRating, int reviewCount
});




}
/// @nodoc
class __$AdminTopRatedItemCopyWithImpl<$Res>
    implements _$AdminTopRatedItemCopyWith<$Res> {
  __$AdminTopRatedItemCopyWithImpl(this._self, this._then);

  final _AdminTopRatedItem _self;
  final $Res Function(_AdminTopRatedItem) _then;

/// Create a copy of AdminTopRatedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? menuItemId = null,Object? nameAr = freezed,Object? nameEn = freezed,Object? imageUrl = freezed,Object? averageRating = null,Object? reviewCount = null,}) {
  return _then(_AdminTopRatedItem(
menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AdminRatingAggregate {

 double get averageRating; int get reviewCount;
/// Create a copy of AdminRatingAggregate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminRatingAggregateCopyWith<AdminRatingAggregate> get copyWith => _$AdminRatingAggregateCopyWithImpl<AdminRatingAggregate>(this as AdminRatingAggregate, _$identity);

  /// Serializes this AdminRatingAggregate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminRatingAggregate;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminRatingAggregate&&(identical(other.averageRating, _this.averageRating) || other.averageRating == _this.averageRating)&&(identical(other.reviewCount, _this.reviewCount) || other.reviewCount == _this.reviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminRatingAggregate;
  return Object.hash(runtimeType,_this.averageRating,_this.reviewCount);
}

@override
String toString() {
  final _this = this as AdminRatingAggregate;
  return 'AdminRatingAggregate(averageRating: ${_this.averageRating}, reviewCount: ${_this.reviewCount})';
}


}

/// @nodoc
abstract mixin class $AdminRatingAggregateCopyWith<$Res>  {
  factory $AdminRatingAggregateCopyWith(AdminRatingAggregate value, $Res Function(AdminRatingAggregate) _then) = _$AdminRatingAggregateCopyWithImpl;
@useResult
$Res call({
 double averageRating, int reviewCount
});




}
/// @nodoc
class _$AdminRatingAggregateCopyWithImpl<$Res>
    implements $AdminRatingAggregateCopyWith<$Res> {
  _$AdminRatingAggregateCopyWithImpl(this._self, this._then);

  final AdminRatingAggregate _self;
  final $Res Function(AdminRatingAggregate) _then;

/// Create a copy of AdminRatingAggregate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? averageRating = null,Object? reviewCount = null,}) {
  return _then(AdminRatingAggregate(
averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AdminRatingAggregate].
extension AdminRatingAggregatePatterns on AdminRatingAggregate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminRatingAggregate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminRatingAggregate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminRatingAggregate value)  $default,){
final _that = this;
switch (_that) {
case _AdminRatingAggregate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminRatingAggregate value)?  $default,){
final _that = this;
switch (_that) {
case _AdminRatingAggregate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double averageRating,  int reviewCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminRatingAggregate() when $default != null:
return $default(_that.averageRating,_that.reviewCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double averageRating,  int reviewCount)  $default,) {final _that = this;
switch (_that) {
case _AdminRatingAggregate():
return $default(_that.averageRating,_that.reviewCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double averageRating,  int reviewCount)?  $default,) {final _that = this;
switch (_that) {
case _AdminRatingAggregate() when $default != null:
return $default(_that.averageRating,_that.reviewCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminRatingAggregate implements AdminRatingAggregate {
  const _AdminRatingAggregate({required this.averageRating, required this.reviewCount});
  factory _AdminRatingAggregate.fromJson(Map<String, dynamic> json) => _$AdminRatingAggregateFromJson(json);

@override final  double averageRating;
@override final  int reviewCount;

/// Create a copy of AdminRatingAggregate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminRatingAggregateCopyWith<_AdminRatingAggregate> get copyWith => __$AdminRatingAggregateCopyWithImpl<_AdminRatingAggregate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminRatingAggregateToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminRatingAggregate&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,averageRating,reviewCount);
}

@override
String toString() {
    return 'AdminRatingAggregate(averageRating: $averageRating, reviewCount: $reviewCount)';
}


}

/// @nodoc
abstract mixin class _$AdminRatingAggregateCopyWith<$Res> implements $AdminRatingAggregateCopyWith<$Res> {
  factory _$AdminRatingAggregateCopyWith(_AdminRatingAggregate value, $Res Function(_AdminRatingAggregate) _then) = __$AdminRatingAggregateCopyWithImpl;
@override @useResult
$Res call({
 double averageRating, int reviewCount
});




}
/// @nodoc
class __$AdminRatingAggregateCopyWithImpl<$Res>
    implements _$AdminRatingAggregateCopyWith<$Res> {
  __$AdminRatingAggregateCopyWithImpl(this._self, this._then);

  final _AdminRatingAggregate _self;
  final $Res Function(_AdminRatingAggregate) _then;

/// Create a copy of AdminRatingAggregate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? averageRating = null,Object? reviewCount = null,}) {
  return _then(_AdminRatingAggregate(
averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$AdminReviewsSummary {

 AdminRatingAggregate get itemReviews; AdminRatingAggregate get orderFeedback;@JsonKey(fromJson: adminRatingDistributionFromApi, toJson: _adminRatingDistributionToApi) Map<int, int> get ratingDistribution; List<AdminTopRatedItem> get topRatedItems; List<AdminTopRatedItem> get lowestRatedItems;
/// Create a copy of AdminReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdminReviewsSummaryCopyWith<AdminReviewsSummary> get copyWith => _$AdminReviewsSummaryCopyWithImpl<AdminReviewsSummary>(this as AdminReviewsSummary, _$identity);

  /// Serializes this AdminReviewsSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AdminReviewsSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdminReviewsSummary&&(identical(other.itemReviews, _this.itemReviews) || other.itemReviews == _this.itemReviews)&&(identical(other.orderFeedback, _this.orderFeedback) || other.orderFeedback == _this.orderFeedback)&&const DeepCollectionEquality().equals(other.ratingDistribution, _this.ratingDistribution)&&const DeepCollectionEquality().equals(other.topRatedItems, _this.topRatedItems)&&const DeepCollectionEquality().equals(other.lowestRatedItems, _this.lowestRatedItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AdminReviewsSummary;
  return Object.hash(runtimeType,_this.itemReviews,_this.orderFeedback,const DeepCollectionEquality().hash(_this.ratingDistribution),const DeepCollectionEquality().hash(_this.topRatedItems),const DeepCollectionEquality().hash(_this.lowestRatedItems));
}

@override
String toString() {
  final _this = this as AdminReviewsSummary;
  return 'AdminReviewsSummary(itemReviews: ${_this.itemReviews}, orderFeedback: ${_this.orderFeedback}, ratingDistribution: ${_this.ratingDistribution}, topRatedItems: ${_this.topRatedItems}, lowestRatedItems: ${_this.lowestRatedItems})';
}


}

/// @nodoc
abstract mixin class $AdminReviewsSummaryCopyWith<$Res>  {
  factory $AdminReviewsSummaryCopyWith(AdminReviewsSummary value, $Res Function(AdminReviewsSummary) _then) = _$AdminReviewsSummaryCopyWithImpl;
@useResult
$Res call({
 AdminRatingAggregate itemReviews, AdminRatingAggregate orderFeedback,@JsonKey(fromJson: adminRatingDistributionFromApi, toJson: _adminRatingDistributionToApi) Map<int, int> ratingDistribution, List<AdminTopRatedItem> topRatedItems, List<AdminTopRatedItem> lowestRatedItems
});


$AdminRatingAggregateCopyWith<$Res> get itemReviews;$AdminRatingAggregateCopyWith<$Res> get orderFeedback;

}
/// @nodoc
class _$AdminReviewsSummaryCopyWithImpl<$Res>
    implements $AdminReviewsSummaryCopyWith<$Res> {
  _$AdminReviewsSummaryCopyWithImpl(this._self, this._then);

  final AdminReviewsSummary _self;
  final $Res Function(AdminReviewsSummary) _then;

/// Create a copy of AdminReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemReviews = null,Object? orderFeedback = null,Object? ratingDistribution = null,Object? topRatedItems = null,Object? lowestRatedItems = null,}) {
  return _then(AdminReviewsSummary(
itemReviews: null == itemReviews ? _self.itemReviews : itemReviews // ignore: cast_nullable_to_non_nullable
as AdminRatingAggregate,orderFeedback: null == orderFeedback ? _self.orderFeedback : orderFeedback // ignore: cast_nullable_to_non_nullable
as AdminRatingAggregate,ratingDistribution: null == ratingDistribution ? _self.ratingDistribution : ratingDistribution // ignore: cast_nullable_to_non_nullable
as Map<int, int>,topRatedItems: null == topRatedItems ? _self.topRatedItems : topRatedItems // ignore: cast_nullable_to_non_nullable
as List<AdminTopRatedItem>,lowestRatedItems: null == lowestRatedItems ? _self.lowestRatedItems : lowestRatedItems // ignore: cast_nullable_to_non_nullable
as List<AdminTopRatedItem>,
  ));
}
/// Create a copy of AdminReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminRatingAggregateCopyWith<$Res> get itemReviews {
  
  return $AdminRatingAggregateCopyWith<$Res>(_self.itemReviews, (value) {
    return _then(_self.copyWith(itemReviews: value));
  });
}/// Create a copy of AdminReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminRatingAggregateCopyWith<$Res> get orderFeedback {
  
  return $AdminRatingAggregateCopyWith<$Res>(_self.orderFeedback, (value) {
    return _then(_self.copyWith(orderFeedback: value));
  });
}
}


/// Adds pattern-matching-related methods to [AdminReviewsSummary].
extension AdminReviewsSummaryPatterns on AdminReviewsSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdminReviewsSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdminReviewsSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdminReviewsSummary value)  $default,){
final _that = this;
switch (_that) {
case _AdminReviewsSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdminReviewsSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AdminReviewsSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AdminRatingAggregate itemReviews,  AdminRatingAggregate orderFeedback, @JsonKey(fromJson: adminRatingDistributionFromApi, toJson: _adminRatingDistributionToApi)  Map<int, int> ratingDistribution,  List<AdminTopRatedItem> topRatedItems,  List<AdminTopRatedItem> lowestRatedItems)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdminReviewsSummary() when $default != null:
return $default(_that.itemReviews,_that.orderFeedback,_that.ratingDistribution,_that.topRatedItems,_that.lowestRatedItems);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AdminRatingAggregate itemReviews,  AdminRatingAggregate orderFeedback, @JsonKey(fromJson: adminRatingDistributionFromApi, toJson: _adminRatingDistributionToApi)  Map<int, int> ratingDistribution,  List<AdminTopRatedItem> topRatedItems,  List<AdminTopRatedItem> lowestRatedItems)  $default,) {final _that = this;
switch (_that) {
case _AdminReviewsSummary():
return $default(_that.itemReviews,_that.orderFeedback,_that.ratingDistribution,_that.topRatedItems,_that.lowestRatedItems);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AdminRatingAggregate itemReviews,  AdminRatingAggregate orderFeedback, @JsonKey(fromJson: adminRatingDistributionFromApi, toJson: _adminRatingDistributionToApi)  Map<int, int> ratingDistribution,  List<AdminTopRatedItem> topRatedItems,  List<AdminTopRatedItem> lowestRatedItems)?  $default,) {final _that = this;
switch (_that) {
case _AdminReviewsSummary() when $default != null:
return $default(_that.itemReviews,_that.orderFeedback,_that.ratingDistribution,_that.topRatedItems,_that.lowestRatedItems);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdminReviewsSummary implements AdminReviewsSummary {
  const _AdminReviewsSummary({required this.itemReviews, required this.orderFeedback, @JsonKey(fromJson: adminRatingDistributionFromApi, toJson: _adminRatingDistributionToApi)  Map<int, int> ratingDistribution = const {},  List<AdminTopRatedItem> topRatedItems = const [],  List<AdminTopRatedItem> lowestRatedItems = const []}): _ratingDistribution = ratingDistribution,_topRatedItems = topRatedItems,_lowestRatedItems = lowestRatedItems;
  factory _AdminReviewsSummary.fromJson(Map<String, dynamic> json) => _$AdminReviewsSummaryFromJson(json);

@override final  AdminRatingAggregate itemReviews;
@override final  AdminRatingAggregate orderFeedback;
 final  Map<int, int> _ratingDistribution;
@override@JsonKey(fromJson: adminRatingDistributionFromApi, toJson: _adminRatingDistributionToApi) Map<int, int> get ratingDistribution {
  if (_ratingDistribution is EqualUnmodifiableMapView) return _ratingDistribution;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_ratingDistribution);
}

 final  List<AdminTopRatedItem> _topRatedItems;
@override@JsonKey() List<AdminTopRatedItem> get topRatedItems {
  if (_topRatedItems is EqualUnmodifiableListView) return _topRatedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topRatedItems);
}

 final  List<AdminTopRatedItem> _lowestRatedItems;
@override@JsonKey() List<AdminTopRatedItem> get lowestRatedItems {
  if (_lowestRatedItems is EqualUnmodifiableListView) return _lowestRatedItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lowestRatedItems);
}


/// Create a copy of AdminReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdminReviewsSummaryCopyWith<_AdminReviewsSummary> get copyWith => __$AdminReviewsSummaryCopyWithImpl<_AdminReviewsSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdminReviewsSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdminReviewsSummary&&(identical(other.itemReviews, itemReviews) || other.itemReviews == itemReviews)&&(identical(other.orderFeedback, orderFeedback) || other.orderFeedback == orderFeedback)&&const DeepCollectionEquality().equals(other.ratingDistribution, _ratingDistribution)&&const DeepCollectionEquality().equals(other.topRatedItems, _topRatedItems)&&const DeepCollectionEquality().equals(other.lowestRatedItems, _lowestRatedItems));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,itemReviews,orderFeedback,const DeepCollectionEquality().hash(_ratingDistribution),const DeepCollectionEquality().hash(_topRatedItems),const DeepCollectionEquality().hash(_lowestRatedItems));
}

@override
String toString() {
    return 'AdminReviewsSummary(itemReviews: $itemReviews, orderFeedback: $orderFeedback, ratingDistribution: $ratingDistribution, topRatedItems: $topRatedItems, lowestRatedItems: $lowestRatedItems)';
}


}

/// @nodoc
abstract mixin class _$AdminReviewsSummaryCopyWith<$Res> implements $AdminReviewsSummaryCopyWith<$Res> {
  factory _$AdminReviewsSummaryCopyWith(_AdminReviewsSummary value, $Res Function(_AdminReviewsSummary) _then) = __$AdminReviewsSummaryCopyWithImpl;
@override @useResult
$Res call({
 AdminRatingAggregate itemReviews, AdminRatingAggregate orderFeedback,@JsonKey(fromJson: adminRatingDistributionFromApi, toJson: _adminRatingDistributionToApi) Map<int, int> ratingDistribution, List<AdminTopRatedItem> topRatedItems, List<AdminTopRatedItem> lowestRatedItems
});


@override $AdminRatingAggregateCopyWith<$Res> get itemReviews;@override $AdminRatingAggregateCopyWith<$Res> get orderFeedback;

}
/// @nodoc
class __$AdminReviewsSummaryCopyWithImpl<$Res>
    implements _$AdminReviewsSummaryCopyWith<$Res> {
  __$AdminReviewsSummaryCopyWithImpl(this._self, this._then);

  final _AdminReviewsSummary _self;
  final $Res Function(_AdminReviewsSummary) _then;

/// Create a copy of AdminReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemReviews = null,Object? orderFeedback = null,Object? ratingDistribution = null,Object? topRatedItems = null,Object? lowestRatedItems = null,}) {
  return _then(_AdminReviewsSummary(
itemReviews: null == itemReviews ? _self.itemReviews : itemReviews // ignore: cast_nullable_to_non_nullable
as AdminRatingAggregate,orderFeedback: null == orderFeedback ? _self.orderFeedback : orderFeedback // ignore: cast_nullable_to_non_nullable
as AdminRatingAggregate,ratingDistribution: null == ratingDistribution ? _self._ratingDistribution : ratingDistribution // ignore: cast_nullable_to_non_nullable
as Map<int, int>,topRatedItems: null == topRatedItems ? _self._topRatedItems : topRatedItems // ignore: cast_nullable_to_non_nullable
as List<AdminTopRatedItem>,lowestRatedItems: null == lowestRatedItems ? _self._lowestRatedItems : lowestRatedItems // ignore: cast_nullable_to_non_nullable
as List<AdminTopRatedItem>,
  ));
}

/// Create a copy of AdminReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminRatingAggregateCopyWith<$Res> get itemReviews {
  
  return $AdminRatingAggregateCopyWith<$Res>(_self.itemReviews, (value) {
    return _then(_self.copyWith(itemReviews: value));
  });
}/// Create a copy of AdminReviewsSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AdminRatingAggregateCopyWith<$Res> get orderFeedback {
  
  return $AdminRatingAggregateCopyWith<$Res>(_self.orderFeedback, (value) {
    return _then(_self.copyWith(orderFeedback: value));
  });
}
}

// dart format on
