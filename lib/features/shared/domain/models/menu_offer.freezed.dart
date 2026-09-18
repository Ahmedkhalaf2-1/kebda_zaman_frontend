// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MenuOfferMenuItemSummary {

 String get id; String? get name; String? get imageUrl; double? get basePrice; bool? get isAvailable; String? get categoryId;
/// Create a copy of MenuOfferMenuItemSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuOfferMenuItemSummaryCopyWith<MenuOfferMenuItemSummary> get copyWith => _$MenuOfferMenuItemSummaryCopyWithImpl<MenuOfferMenuItemSummary>(this as MenuOfferMenuItemSummary, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MenuOfferMenuItemSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuOfferMenuItemSummary&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.basePrice, _this.basePrice) || other.basePrice == _this.basePrice)&&(identical(other.isAvailable, _this.isAvailable) || other.isAvailable == _this.isAvailable)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId));
}


@override
int get hashCode {
  final _this = this as MenuOfferMenuItemSummary;
  return Object.hash(runtimeType,_this.id,_this.name,_this.imageUrl,_this.basePrice,_this.isAvailable,_this.categoryId);
}

@override
String toString() {
  final _this = this as MenuOfferMenuItemSummary;
  return 'MenuOfferMenuItemSummary(id: ${_this.id}, name: ${_this.name}, imageUrl: ${_this.imageUrl}, basePrice: ${_this.basePrice}, isAvailable: ${_this.isAvailable}, categoryId: ${_this.categoryId})';
}


}

/// @nodoc
abstract mixin class $MenuOfferMenuItemSummaryCopyWith<$Res>  {
  factory $MenuOfferMenuItemSummaryCopyWith(MenuOfferMenuItemSummary value, $Res Function(MenuOfferMenuItemSummary) _then) = _$MenuOfferMenuItemSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String? name, String? imageUrl, double? basePrice, bool? isAvailable, String? categoryId
});




}
/// @nodoc
class _$MenuOfferMenuItemSummaryCopyWithImpl<$Res>
    implements $MenuOfferMenuItemSummaryCopyWith<$Res> {
  _$MenuOfferMenuItemSummaryCopyWithImpl(this._self, this._then);

  final MenuOfferMenuItemSummary _self;
  final $Res Function(MenuOfferMenuItemSummary) _then;

/// Create a copy of MenuOfferMenuItemSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? imageUrl = freezed,Object? basePrice = freezed,Object? isAvailable = freezed,Object? categoryId = freezed,}) {
  return _then(MenuOfferMenuItemSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,basePrice: freezed == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double?,isAvailable: freezed == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuOfferMenuItemSummary].
extension MenuOfferMenuItemSummaryPatterns on MenuOfferMenuItemSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuOfferMenuItemSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuOfferMenuItemSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuOfferMenuItemSummary value)  $default,){
final _that = this;
switch (_that) {
case _MenuOfferMenuItemSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuOfferMenuItemSummary value)?  $default,){
final _that = this;
switch (_that) {
case _MenuOfferMenuItemSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? name,  String? imageUrl,  double? basePrice,  bool? isAvailable,  String? categoryId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuOfferMenuItemSummary() when $default != null:
return $default(_that.id,_that.name,_that.imageUrl,_that.basePrice,_that.isAvailable,_that.categoryId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? name,  String? imageUrl,  double? basePrice,  bool? isAvailable,  String? categoryId)  $default,) {final _that = this;
switch (_that) {
case _MenuOfferMenuItemSummary():
return $default(_that.id,_that.name,_that.imageUrl,_that.basePrice,_that.isAvailable,_that.categoryId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? name,  String? imageUrl,  double? basePrice,  bool? isAvailable,  String? categoryId)?  $default,) {final _that = this;
switch (_that) {
case _MenuOfferMenuItemSummary() when $default != null:
return $default(_that.id,_that.name,_that.imageUrl,_that.basePrice,_that.isAvailable,_that.categoryId);case _:
  return null;

}
}

}

/// @nodoc


class _MenuOfferMenuItemSummary implements MenuOfferMenuItemSummary {
  const _MenuOfferMenuItemSummary({required this.id, this.name, this.imageUrl, this.basePrice, this.isAvailable, this.categoryId});
  

@override final  String id;
@override final  String? name;
@override final  String? imageUrl;
@override final  double? basePrice;
@override final  bool? isAvailable;
@override final  String? categoryId;

/// Create a copy of MenuOfferMenuItemSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuOfferMenuItemSummaryCopyWith<_MenuOfferMenuItemSummary> get copyWith => __$MenuOfferMenuItemSummaryCopyWithImpl<_MenuOfferMenuItemSummary>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuOfferMenuItemSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,imageUrl,basePrice,isAvailable,categoryId);
}

@override
String toString() {
    return 'MenuOfferMenuItemSummary(id: $id, name: $name, imageUrl: $imageUrl, basePrice: $basePrice, isAvailable: $isAvailable, categoryId: $categoryId)';
}


}

/// @nodoc
abstract mixin class _$MenuOfferMenuItemSummaryCopyWith<$Res> implements $MenuOfferMenuItemSummaryCopyWith<$Res> {
  factory _$MenuOfferMenuItemSummaryCopyWith(_MenuOfferMenuItemSummary value, $Res Function(_MenuOfferMenuItemSummary) _then) = __$MenuOfferMenuItemSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String? name, String? imageUrl, double? basePrice, bool? isAvailable, String? categoryId
});




}
/// @nodoc
class __$MenuOfferMenuItemSummaryCopyWithImpl<$Res>
    implements _$MenuOfferMenuItemSummaryCopyWith<$Res> {
  __$MenuOfferMenuItemSummaryCopyWithImpl(this._self, this._then);

  final _MenuOfferMenuItemSummary _self;
  final $Res Function(_MenuOfferMenuItemSummary) _then;

/// Create a copy of MenuOfferMenuItemSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? imageUrl = freezed,Object? basePrice = freezed,Object? isAvailable = freezed,Object? categoryId = freezed,}) {
  return _then(_MenuOfferMenuItemSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,basePrice: freezed == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double?,isAvailable: freezed == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$MenuOffer {

 String get id; String get menuItemId; String get imageUrl; String? get title; String? get description; bool get isActive; DateTime? get startAt; DateTime? get endAt; int get sortOrder; DateTime get createdAt; DateTime get updatedAt; MenuOfferMenuItemSummary? get menuItem;
/// Create a copy of MenuOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuOfferCopyWith<MenuOffer> get copyWith => _$MenuOfferCopyWithImpl<MenuOffer>(this as MenuOffer, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MenuOffer;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuOffer&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.isActive, _this.isActive) || other.isActive == _this.isActive)&&(identical(other.startAt, _this.startAt) || other.startAt == _this.startAt)&&(identical(other.endAt, _this.endAt) || other.endAt == _this.endAt)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.menuItem, _this.menuItem) || other.menuItem == _this.menuItem));
}


@override
int get hashCode {
  final _this = this as MenuOffer;
  return Object.hash(runtimeType,_this.id,_this.menuItemId,_this.imageUrl,_this.title,_this.description,_this.isActive,_this.startAt,_this.endAt,_this.sortOrder,_this.createdAt,_this.updatedAt,_this.menuItem);
}

@override
String toString() {
  final _this = this as MenuOffer;
  return 'MenuOffer(id: ${_this.id}, menuItemId: ${_this.menuItemId}, imageUrl: ${_this.imageUrl}, title: ${_this.title}, description: ${_this.description}, isActive: ${_this.isActive}, startAt: ${_this.startAt}, endAt: ${_this.endAt}, sortOrder: ${_this.sortOrder}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, menuItem: ${_this.menuItem})';
}


}

/// @nodoc
abstract mixin class $MenuOfferCopyWith<$Res>  {
  factory $MenuOfferCopyWith(MenuOffer value, $Res Function(MenuOffer) _then) = _$MenuOfferCopyWithImpl;
@useResult
$Res call({
 String id, String menuItemId, String imageUrl, String? title, String? description, bool isActive, DateTime? startAt, DateTime? endAt, int sortOrder, DateTime createdAt, DateTime updatedAt, MenuOfferMenuItemSummary? menuItem
});


$MenuOfferMenuItemSummaryCopyWith<$Res>? get menuItem;

}
/// @nodoc
class _$MenuOfferCopyWithImpl<$Res>
    implements $MenuOfferCopyWith<$Res> {
  _$MenuOfferCopyWithImpl(this._self, this._then);

  final MenuOffer _self;
  final $Res Function(MenuOffer) _then;

/// Create a copy of MenuOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? menuItemId = null,Object? imageUrl = null,Object? title = freezed,Object? description = freezed,Object? isActive = null,Object? startAt = freezed,Object? endAt = freezed,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? menuItem = freezed,}) {
  return _then(MenuOffer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,menuItem: freezed == menuItem ? _self.menuItem : menuItem // ignore: cast_nullable_to_non_nullable
as MenuOfferMenuItemSummary?,
  ));
}
/// Create a copy of MenuOffer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MenuOfferMenuItemSummaryCopyWith<$Res>? get menuItem {
    if (_self.menuItem == null) {
    return null;
  }

  return $MenuOfferMenuItemSummaryCopyWith<$Res>(_self.menuItem!, (value) {
    return _then(_self.copyWith(menuItem: value));
  });
}
}


/// Adds pattern-matching-related methods to [MenuOffer].
extension MenuOfferPatterns on MenuOffer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuOffer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuOffer value)  $default,){
final _that = this;
switch (_that) {
case _MenuOffer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuOffer value)?  $default,){
final _that = this;
switch (_that) {
case _MenuOffer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String menuItemId,  String imageUrl,  String? title,  String? description,  bool isActive,  DateTime? startAt,  DateTime? endAt,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  MenuOfferMenuItemSummary? menuItem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuOffer() when $default != null:
return $default(_that.id,_that.menuItemId,_that.imageUrl,_that.title,_that.description,_that.isActive,_that.startAt,_that.endAt,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.menuItem);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String menuItemId,  String imageUrl,  String? title,  String? description,  bool isActive,  DateTime? startAt,  DateTime? endAt,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  MenuOfferMenuItemSummary? menuItem)  $default,) {final _that = this;
switch (_that) {
case _MenuOffer():
return $default(_that.id,_that.menuItemId,_that.imageUrl,_that.title,_that.description,_that.isActive,_that.startAt,_that.endAt,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.menuItem);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String menuItemId,  String imageUrl,  String? title,  String? description,  bool isActive,  DateTime? startAt,  DateTime? endAt,  int sortOrder,  DateTime createdAt,  DateTime updatedAt,  MenuOfferMenuItemSummary? menuItem)?  $default,) {final _that = this;
switch (_that) {
case _MenuOffer() when $default != null:
return $default(_that.id,_that.menuItemId,_that.imageUrl,_that.title,_that.description,_that.isActive,_that.startAt,_that.endAt,_that.sortOrder,_that.createdAt,_that.updatedAt,_that.menuItem);case _:
  return null;

}
}

}

/// @nodoc


class _MenuOffer implements MenuOffer {
  const _MenuOffer({required this.id, required this.menuItemId, required this.imageUrl, this.title, this.description, this.isActive = true, this.startAt, this.endAt, this.sortOrder = 0, required this.createdAt, required this.updatedAt, this.menuItem});
  

@override final  String id;
@override final  String menuItemId;
@override final  String imageUrl;
@override final  String? title;
@override final  String? description;
@override@JsonKey() final  bool isActive;
@override final  DateTime? startAt;
@override final  DateTime? endAt;
@override@JsonKey() final  int sortOrder;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  MenuOfferMenuItemSummary? menuItem;

/// Create a copy of MenuOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuOfferCopyWith<_MenuOffer> get copyWith => __$MenuOfferCopyWithImpl<_MenuOffer>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuOffer&&(identical(other.id, id) || other.id == id)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.startAt, startAt) || other.startAt == startAt)&&(identical(other.endAt, endAt) || other.endAt == endAt)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.menuItem, menuItem) || other.menuItem == menuItem));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,menuItemId,imageUrl,title,description,isActive,startAt,endAt,sortOrder,createdAt,updatedAt,menuItem);
}

@override
String toString() {
    return 'MenuOffer(id: $id, menuItemId: $menuItemId, imageUrl: $imageUrl, title: $title, description: $description, isActive: $isActive, startAt: $startAt, endAt: $endAt, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, menuItem: $menuItem)';
}


}

/// @nodoc
abstract mixin class _$MenuOfferCopyWith<$Res> implements $MenuOfferCopyWith<$Res> {
  factory _$MenuOfferCopyWith(_MenuOffer value, $Res Function(_MenuOffer) _then) = __$MenuOfferCopyWithImpl;
@override @useResult
$Res call({
 String id, String menuItemId, String imageUrl, String? title, String? description, bool isActive, DateTime? startAt, DateTime? endAt, int sortOrder, DateTime createdAt, DateTime updatedAt, MenuOfferMenuItemSummary? menuItem
});


@override $MenuOfferMenuItemSummaryCopyWith<$Res>? get menuItem;

}
/// @nodoc
class __$MenuOfferCopyWithImpl<$Res>
    implements _$MenuOfferCopyWith<$Res> {
  __$MenuOfferCopyWithImpl(this._self, this._then);

  final _MenuOffer _self;
  final $Res Function(_MenuOffer) _then;

/// Create a copy of MenuOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? menuItemId = null,Object? imageUrl = null,Object? title = freezed,Object? description = freezed,Object? isActive = null,Object? startAt = freezed,Object? endAt = freezed,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,Object? menuItem = freezed,}) {
  return _then(_MenuOffer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startAt: freezed == startAt ? _self.startAt : startAt // ignore: cast_nullable_to_non_nullable
as DateTime?,endAt: freezed == endAt ? _self.endAt : endAt // ignore: cast_nullable_to_non_nullable
as DateTime?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,menuItem: freezed == menuItem ? _self.menuItem : menuItem // ignore: cast_nullable_to_non_nullable
as MenuOfferMenuItemSummary?,
  ));
}

/// Create a copy of MenuOffer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MenuOfferMenuItemSummaryCopyWith<$Res>? get menuItem {
    if (_self.menuItem == null) {
    return null;
  }

  return $MenuOfferMenuItemSummaryCopyWith<$Res>(_self.menuItem!, (value) {
    return _then(_self.copyWith(menuItem: value));
  });
}
}

// dart format on
