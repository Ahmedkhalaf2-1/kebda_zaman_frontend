// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MenuItem {

 String get id; String get categoryId; String get name; String get description; String get imageUrl; double get basePrice;/// The discounted price the customer actually pays, or null when the
/// item has no active discount (always strictly less than [basePrice]
/// when set — enforced server-side). Maps to the backend's `salePrice`
/// JSON field (see `ApiMenuRepository._mapMenuItem`/
/// `_buildMenuItemPayload`) — kept as `discountPrice` here since this
/// field already existed under that name before the backend added
/// `salePrice`; do not confuse with [compareAtPrice], a separate,
/// purely cosmetic "was" price with opposite semantics.
 double? get discountPrice; bool get isAvailable; bool get isFeatured; bool get isBestSeller; int get prepTimeMinutes; List<ModifierGroup> get modifierGroups; int get sortOrder; int? get calories; double? get compareAtPrice; MenuItemBadge? get badge; List<MenuItem> get oftenOrderedWith; String? get nameAr; String? get nameEn; String? get descriptionAr; String? get descriptionEn; double get averageRating; int get reviewCount;
/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MenuItemCopyWith<MenuItem> get copyWith => _$MenuItemCopyWithImpl<MenuItem>(this as MenuItem, _$identity);

  /// Serializes this MenuItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MenuItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MenuItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.basePrice, _this.basePrice) || other.basePrice == _this.basePrice)&&(identical(other.discountPrice, _this.discountPrice) || other.discountPrice == _this.discountPrice)&&(identical(other.isAvailable, _this.isAvailable) || other.isAvailable == _this.isAvailable)&&(identical(other.isFeatured, _this.isFeatured) || other.isFeatured == _this.isFeatured)&&(identical(other.isBestSeller, _this.isBestSeller) || other.isBestSeller == _this.isBestSeller)&&(identical(other.prepTimeMinutes, _this.prepTimeMinutes) || other.prepTimeMinutes == _this.prepTimeMinutes)&&const DeepCollectionEquality().equals(other.modifierGroups, _this.modifierGroups)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.calories, _this.calories) || other.calories == _this.calories)&&(identical(other.compareAtPrice, _this.compareAtPrice) || other.compareAtPrice == _this.compareAtPrice)&&(identical(other.badge, _this.badge) || other.badge == _this.badge)&&const DeepCollectionEquality().equals(other.oftenOrderedWith, _this.oftenOrderedWith)&&(identical(other.nameAr, _this.nameAr) || other.nameAr == _this.nameAr)&&(identical(other.nameEn, _this.nameEn) || other.nameEn == _this.nameEn)&&(identical(other.descriptionAr, _this.descriptionAr) || other.descriptionAr == _this.descriptionAr)&&(identical(other.descriptionEn, _this.descriptionEn) || other.descriptionEn == _this.descriptionEn)&&(identical(other.averageRating, _this.averageRating) || other.averageRating == _this.averageRating)&&(identical(other.reviewCount, _this.reviewCount) || other.reviewCount == _this.reviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MenuItem;
  return Object.hashAll([runtimeType,_this.id,_this.categoryId,_this.name,_this.description,_this.imageUrl,_this.basePrice,_this.discountPrice,_this.isAvailable,_this.isFeatured,_this.isBestSeller,_this.prepTimeMinutes,const DeepCollectionEquality().hash(_this.modifierGroups),_this.sortOrder,_this.calories,_this.compareAtPrice,_this.badge,const DeepCollectionEquality().hash(_this.oftenOrderedWith),_this.nameAr,_this.nameEn,_this.descriptionAr,_this.descriptionEn,_this.averageRating,_this.reviewCount]);
}

@override
String toString() {
  final _this = this as MenuItem;
  return 'MenuItem(id: ${_this.id}, categoryId: ${_this.categoryId}, name: ${_this.name}, description: ${_this.description}, imageUrl: ${_this.imageUrl}, basePrice: ${_this.basePrice}, discountPrice: ${_this.discountPrice}, isAvailable: ${_this.isAvailable}, isFeatured: ${_this.isFeatured}, isBestSeller: ${_this.isBestSeller}, prepTimeMinutes: ${_this.prepTimeMinutes}, modifierGroups: ${_this.modifierGroups}, sortOrder: ${_this.sortOrder}, calories: ${_this.calories}, compareAtPrice: ${_this.compareAtPrice}, badge: ${_this.badge}, oftenOrderedWith: ${_this.oftenOrderedWith}, nameAr: ${_this.nameAr}, nameEn: ${_this.nameEn}, descriptionAr: ${_this.descriptionAr}, descriptionEn: ${_this.descriptionEn}, averageRating: ${_this.averageRating}, reviewCount: ${_this.reviewCount})';
}


}

/// @nodoc
abstract mixin class $MenuItemCopyWith<$Res>  {
  factory $MenuItemCopyWith(MenuItem value, $Res Function(MenuItem) _then) = _$MenuItemCopyWithImpl;
@useResult
$Res call({
 String id, String categoryId, String name, String description, String imageUrl, double basePrice, double? discountPrice, bool isAvailable, bool isFeatured, bool isBestSeller, int prepTimeMinutes, List<ModifierGroup> modifierGroups, int sortOrder, int? calories, double? compareAtPrice, MenuItemBadge? badge, List<MenuItem> oftenOrderedWith, String? nameAr, String? nameEn, String? descriptionAr, String? descriptionEn, double averageRating, int reviewCount
});




}
/// @nodoc
class _$MenuItemCopyWithImpl<$Res>
    implements $MenuItemCopyWith<$Res> {
  _$MenuItemCopyWithImpl(this._self, this._then);

  final MenuItem _self;
  final $Res Function(MenuItem) _then;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? categoryId = null,Object? name = null,Object? description = null,Object? imageUrl = null,Object? basePrice = null,Object? discountPrice = freezed,Object? isAvailable = null,Object? isFeatured = null,Object? isBestSeller = null,Object? prepTimeMinutes = null,Object? modifierGroups = null,Object? sortOrder = null,Object? calories = freezed,Object? compareAtPrice = freezed,Object? badge = freezed,Object? oftenOrderedWith = null,Object? nameAr = freezed,Object? nameEn = freezed,Object? descriptionAr = freezed,Object? descriptionEn = freezed,Object? averageRating = null,Object? reviewCount = null,}) {
  return _then(MenuItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,discountPrice: freezed == discountPrice ? _self.discountPrice : discountPrice // ignore: cast_nullable_to_non_nullable
as double?,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,isBestSeller: null == isBestSeller ? _self.isBestSeller : isBestSeller // ignore: cast_nullable_to_non_nullable
as bool,prepTimeMinutes: null == prepTimeMinutes ? _self.prepTimeMinutes : prepTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,modifierGroups: null == modifierGroups ? _self.modifierGroups : modifierGroups // ignore: cast_nullable_to_non_nullable
as List<ModifierGroup>,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int?,compareAtPrice: freezed == compareAtPrice ? _self.compareAtPrice : compareAtPrice // ignore: cast_nullable_to_non_nullable
as double?,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as MenuItemBadge?,oftenOrderedWith: null == oftenOrderedWith ? _self.oftenOrderedWith : oftenOrderedWith // ignore: cast_nullable_to_non_nullable
as List<MenuItem>,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,descriptionAr: freezed == descriptionAr ? _self.descriptionAr : descriptionAr // ignore: cast_nullable_to_non_nullable
as String?,descriptionEn: freezed == descriptionEn ? _self.descriptionEn : descriptionEn // ignore: cast_nullable_to_non_nullable
as String?,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MenuItem].
extension MenuItemPatterns on MenuItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MenuItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MenuItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MenuItem value)  $default,){
final _that = this;
switch (_that) {
case _MenuItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MenuItem value)?  $default,){
final _that = this;
switch (_that) {
case _MenuItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String categoryId,  String name,  String description,  String imageUrl,  double basePrice,  double? discountPrice,  bool isAvailable,  bool isFeatured,  bool isBestSeller,  int prepTimeMinutes,  List<ModifierGroup> modifierGroups,  int sortOrder,  int? calories,  double? compareAtPrice,  MenuItemBadge? badge,  List<MenuItem> oftenOrderedWith,  String? nameAr,  String? nameEn,  String? descriptionAr,  String? descriptionEn,  double averageRating,  int reviewCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MenuItem() when $default != null:
return $default(_that.id,_that.categoryId,_that.name,_that.description,_that.imageUrl,_that.basePrice,_that.discountPrice,_that.isAvailable,_that.isFeatured,_that.isBestSeller,_that.prepTimeMinutes,_that.modifierGroups,_that.sortOrder,_that.calories,_that.compareAtPrice,_that.badge,_that.oftenOrderedWith,_that.nameAr,_that.nameEn,_that.descriptionAr,_that.descriptionEn,_that.averageRating,_that.reviewCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String categoryId,  String name,  String description,  String imageUrl,  double basePrice,  double? discountPrice,  bool isAvailable,  bool isFeatured,  bool isBestSeller,  int prepTimeMinutes,  List<ModifierGroup> modifierGroups,  int sortOrder,  int? calories,  double? compareAtPrice,  MenuItemBadge? badge,  List<MenuItem> oftenOrderedWith,  String? nameAr,  String? nameEn,  String? descriptionAr,  String? descriptionEn,  double averageRating,  int reviewCount)  $default,) {final _that = this;
switch (_that) {
case _MenuItem():
return $default(_that.id,_that.categoryId,_that.name,_that.description,_that.imageUrl,_that.basePrice,_that.discountPrice,_that.isAvailable,_that.isFeatured,_that.isBestSeller,_that.prepTimeMinutes,_that.modifierGroups,_that.sortOrder,_that.calories,_that.compareAtPrice,_that.badge,_that.oftenOrderedWith,_that.nameAr,_that.nameEn,_that.descriptionAr,_that.descriptionEn,_that.averageRating,_that.reviewCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String categoryId,  String name,  String description,  String imageUrl,  double basePrice,  double? discountPrice,  bool isAvailable,  bool isFeatured,  bool isBestSeller,  int prepTimeMinutes,  List<ModifierGroup> modifierGroups,  int sortOrder,  int? calories,  double? compareAtPrice,  MenuItemBadge? badge,  List<MenuItem> oftenOrderedWith,  String? nameAr,  String? nameEn,  String? descriptionAr,  String? descriptionEn,  double averageRating,  int reviewCount)?  $default,) {final _that = this;
switch (_that) {
case _MenuItem() when $default != null:
return $default(_that.id,_that.categoryId,_that.name,_that.description,_that.imageUrl,_that.basePrice,_that.discountPrice,_that.isAvailable,_that.isFeatured,_that.isBestSeller,_that.prepTimeMinutes,_that.modifierGroups,_that.sortOrder,_that.calories,_that.compareAtPrice,_that.badge,_that.oftenOrderedWith,_that.nameAr,_that.nameEn,_that.descriptionAr,_that.descriptionEn,_that.averageRating,_that.reviewCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MenuItem implements MenuItem {
  const _MenuItem({required this.id, required this.categoryId, required this.name, required this.description, required this.imageUrl, required this.basePrice, this.discountPrice, this.isAvailable = true, this.isFeatured = false, this.isBestSeller = false, this.prepTimeMinutes = 15,  List<ModifierGroup> modifierGroups = const [], this.sortOrder = 0, this.calories, this.compareAtPrice, this.badge,  List<MenuItem> oftenOrderedWith = const [], this.nameAr, this.nameEn, this.descriptionAr, this.descriptionEn, this.averageRating = 0.0, this.reviewCount = 0}): _modifierGroups = modifierGroups,_oftenOrderedWith = oftenOrderedWith;
  factory _MenuItem.fromJson(Map<String, dynamic> json) => _$MenuItemFromJson(json);

@override final  String id;
@override final  String categoryId;
@override final  String name;
@override final  String description;
@override final  String imageUrl;
@override final  double basePrice;
/// The discounted price the customer actually pays, or null when the
/// item has no active discount (always strictly less than [basePrice]
/// when set — enforced server-side). Maps to the backend's `salePrice`
/// JSON field (see `ApiMenuRepository._mapMenuItem`/
/// `_buildMenuItemPayload`) — kept as `discountPrice` here since this
/// field already existed under that name before the backend added
/// `salePrice`; do not confuse with [compareAtPrice], a separate,
/// purely cosmetic "was" price with opposite semantics.
@override final  double? discountPrice;
@override@JsonKey() final  bool isAvailable;
@override@JsonKey() final  bool isFeatured;
@override@JsonKey() final  bool isBestSeller;
@override@JsonKey() final  int prepTimeMinutes;
 final  List<ModifierGroup> _modifierGroups;
@override@JsonKey() List<ModifierGroup> get modifierGroups {
  if (_modifierGroups is EqualUnmodifiableListView) return _modifierGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_modifierGroups);
}

@override@JsonKey() final  int sortOrder;
@override final  int? calories;
@override final  double? compareAtPrice;
@override final  MenuItemBadge? badge;
 final  List<MenuItem> _oftenOrderedWith;
@override@JsonKey() List<MenuItem> get oftenOrderedWith {
  if (_oftenOrderedWith is EqualUnmodifiableListView) return _oftenOrderedWith;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_oftenOrderedWith);
}

@override final  String? nameAr;
@override final  String? nameEn;
@override final  String? descriptionAr;
@override final  String? descriptionEn;
@override@JsonKey() final  double averageRating;
@override@JsonKey() final  int reviewCount;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MenuItemCopyWith<_MenuItem> get copyWith => __$MenuItemCopyWithImpl<_MenuItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MenuItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MenuItem&&(identical(other.id, id) || other.id == id)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.discountPrice, discountPrice) || other.discountPrice == discountPrice)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.isBestSeller, isBestSeller) || other.isBestSeller == isBestSeller)&&(identical(other.prepTimeMinutes, prepTimeMinutes) || other.prepTimeMinutes == prepTimeMinutes)&&const DeepCollectionEquality().equals(other.modifierGroups, _modifierGroups)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.compareAtPrice, compareAtPrice) || other.compareAtPrice == compareAtPrice)&&(identical(other.badge, badge) || other.badge == badge)&&const DeepCollectionEquality().equals(other.oftenOrderedWith, _oftenOrderedWith)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.descriptionAr, descriptionAr) || other.descriptionAr == descriptionAr)&&(identical(other.descriptionEn, descriptionEn) || other.descriptionEn == descriptionEn)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,categoryId,name,description,imageUrl,basePrice,discountPrice,isAvailable,isFeatured,isBestSeller,prepTimeMinutes,const DeepCollectionEquality().hash(_modifierGroups),sortOrder,calories,compareAtPrice,badge,const DeepCollectionEquality().hash(_oftenOrderedWith),nameAr,nameEn,descriptionAr,descriptionEn,averageRating,reviewCount]);
}

@override
String toString() {
    return 'MenuItem(id: $id, categoryId: $categoryId, name: $name, description: $description, imageUrl: $imageUrl, basePrice: $basePrice, discountPrice: $discountPrice, isAvailable: $isAvailable, isFeatured: $isFeatured, isBestSeller: $isBestSeller, prepTimeMinutes: $prepTimeMinutes, modifierGroups: $modifierGroups, sortOrder: $sortOrder, calories: $calories, compareAtPrice: $compareAtPrice, badge: $badge, oftenOrderedWith: $oftenOrderedWith, nameAr: $nameAr, nameEn: $nameEn, descriptionAr: $descriptionAr, descriptionEn: $descriptionEn, averageRating: $averageRating, reviewCount: $reviewCount)';
}


}

/// @nodoc
abstract mixin class _$MenuItemCopyWith<$Res> implements $MenuItemCopyWith<$Res> {
  factory _$MenuItemCopyWith(_MenuItem value, $Res Function(_MenuItem) _then) = __$MenuItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String categoryId, String name, String description, String imageUrl, double basePrice, double? discountPrice, bool isAvailable, bool isFeatured, bool isBestSeller, int prepTimeMinutes, List<ModifierGroup> modifierGroups, int sortOrder, int? calories, double? compareAtPrice, MenuItemBadge? badge, List<MenuItem> oftenOrderedWith, String? nameAr, String? nameEn, String? descriptionAr, String? descriptionEn, double averageRating, int reviewCount
});




}
/// @nodoc
class __$MenuItemCopyWithImpl<$Res>
    implements _$MenuItemCopyWith<$Res> {
  __$MenuItemCopyWithImpl(this._self, this._then);

  final _MenuItem _self;
  final $Res Function(_MenuItem) _then;

/// Create a copy of MenuItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? categoryId = null,Object? name = null,Object? description = null,Object? imageUrl = null,Object? basePrice = null,Object? discountPrice = freezed,Object? isAvailable = null,Object? isFeatured = null,Object? isBestSeller = null,Object? prepTimeMinutes = null,Object? modifierGroups = null,Object? sortOrder = null,Object? calories = freezed,Object? compareAtPrice = freezed,Object? badge = freezed,Object? oftenOrderedWith = null,Object? nameAr = freezed,Object? nameEn = freezed,Object? descriptionAr = freezed,Object? descriptionEn = freezed,Object? averageRating = null,Object? reviewCount = null,}) {
  return _then(_MenuItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,discountPrice: freezed == discountPrice ? _self.discountPrice : discountPrice // ignore: cast_nullable_to_non_nullable
as double?,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,isBestSeller: null == isBestSeller ? _self.isBestSeller : isBestSeller // ignore: cast_nullable_to_non_nullable
as bool,prepTimeMinutes: null == prepTimeMinutes ? _self.prepTimeMinutes : prepTimeMinutes // ignore: cast_nullable_to_non_nullable
as int,modifierGroups: null == modifierGroups ? _self._modifierGroups : modifierGroups // ignore: cast_nullable_to_non_nullable
as List<ModifierGroup>,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int?,compareAtPrice: freezed == compareAtPrice ? _self.compareAtPrice : compareAtPrice // ignore: cast_nullable_to_non_nullable
as double?,badge: freezed == badge ? _self.badge : badge // ignore: cast_nullable_to_non_nullable
as MenuItemBadge?,oftenOrderedWith: null == oftenOrderedWith ? _self._oftenOrderedWith : oftenOrderedWith // ignore: cast_nullable_to_non_nullable
as List<MenuItem>,nameAr: freezed == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,descriptionAr: freezed == descriptionAr ? _self.descriptionAr : descriptionAr // ignore: cast_nullable_to_non_nullable
as String?,descriptionEn: freezed == descriptionEn ? _self.descriptionEn : descriptionEn // ignore: cast_nullable_to_non_nullable
as String?,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ModifierGroup {

 String get id; String get name; String? get description; bool get isRequired; String get selectionType; int get minSelections; int get maxSelections; List<ModifierOption> get options; int get sortOrder;
/// Create a copy of ModifierGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModifierGroupCopyWith<ModifierGroup> get copyWith => _$ModifierGroupCopyWithImpl<ModifierGroup>(this as ModifierGroup, _$identity);

  /// Serializes this ModifierGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ModifierGroup;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModifierGroup&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.isRequired, _this.isRequired) || other.isRequired == _this.isRequired)&&(identical(other.selectionType, _this.selectionType) || other.selectionType == _this.selectionType)&&(identical(other.minSelections, _this.minSelections) || other.minSelections == _this.minSelections)&&(identical(other.maxSelections, _this.maxSelections) || other.maxSelections == _this.maxSelections)&&const DeepCollectionEquality().equals(other.options, _this.options)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ModifierGroup;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,_this.isRequired,_this.selectionType,_this.minSelections,_this.maxSelections,const DeepCollectionEquality().hash(_this.options),_this.sortOrder);
}

@override
String toString() {
  final _this = this as ModifierGroup;
  return 'ModifierGroup(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, isRequired: ${_this.isRequired}, selectionType: ${_this.selectionType}, minSelections: ${_this.minSelections}, maxSelections: ${_this.maxSelections}, options: ${_this.options}, sortOrder: ${_this.sortOrder})';
}


}

/// @nodoc
abstract mixin class $ModifierGroupCopyWith<$Res>  {
  factory $ModifierGroupCopyWith(ModifierGroup value, $Res Function(ModifierGroup) _then) = _$ModifierGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, bool isRequired, String selectionType, int minSelections, int maxSelections, List<ModifierOption> options, int sortOrder
});




}
/// @nodoc
class _$ModifierGroupCopyWithImpl<$Res>
    implements $ModifierGroupCopyWith<$Res> {
  _$ModifierGroupCopyWithImpl(this._self, this._then);

  final ModifierGroup _self;
  final $Res Function(ModifierGroup) _then;

/// Create a copy of ModifierGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? isRequired = null,Object? selectionType = null,Object? minSelections = null,Object? maxSelections = null,Object? options = null,Object? sortOrder = null,}) {
  return _then(ModifierGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,selectionType: null == selectionType ? _self.selectionType : selectionType // ignore: cast_nullable_to_non_nullable
as String,minSelections: null == minSelections ? _self.minSelections : minSelections // ignore: cast_nullable_to_non_nullable
as int,maxSelections: null == maxSelections ? _self.maxSelections : maxSelections // ignore: cast_nullable_to_non_nullable
as int,options: null == options ? _self.options : options // ignore: cast_nullable_to_non_nullable
as List<ModifierOption>,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ModifierGroup].
extension ModifierGroupPatterns on ModifierGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModifierGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModifierGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModifierGroup value)  $default,){
final _that = this;
switch (_that) {
case _ModifierGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModifierGroup value)?  $default,){
final _that = this;
switch (_that) {
case _ModifierGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  bool isRequired,  String selectionType,  int minSelections,  int maxSelections,  List<ModifierOption> options,  int sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModifierGroup() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.isRequired,_that.selectionType,_that.minSelections,_that.maxSelections,_that.options,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  bool isRequired,  String selectionType,  int minSelections,  int maxSelections,  List<ModifierOption> options,  int sortOrder)  $default,) {final _that = this;
switch (_that) {
case _ModifierGroup():
return $default(_that.id,_that.name,_that.description,_that.isRequired,_that.selectionType,_that.minSelections,_that.maxSelections,_that.options,_that.sortOrder);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  bool isRequired,  String selectionType,  int minSelections,  int maxSelections,  List<ModifierOption> options,  int sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _ModifierGroup() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.isRequired,_that.selectionType,_that.minSelections,_that.maxSelections,_that.options,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModifierGroup implements ModifierGroup {
  const _ModifierGroup({required this.id, required this.name, this.description, this.isRequired = false, this.selectionType = 'SINGLE', this.minSelections = 0, this.maxSelections = 1,  List<ModifierOption> options = const [], this.sortOrder = 0}): _options = options;
  factory _ModifierGroup.fromJson(Map<String, dynamic> json) => _$ModifierGroupFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  bool isRequired;
@override@JsonKey() final  String selectionType;
@override@JsonKey() final  int minSelections;
@override@JsonKey() final  int maxSelections;
 final  List<ModifierOption> _options;
@override@JsonKey() List<ModifierOption> get options {
  if (_options is EqualUnmodifiableListView) return _options;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_options);
}

@override@JsonKey() final  int sortOrder;

/// Create a copy of ModifierGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModifierGroupCopyWith<_ModifierGroup> get copyWith => __$ModifierGroupCopyWithImpl<_ModifierGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModifierGroupToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModifierGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isRequired, isRequired) || other.isRequired == isRequired)&&(identical(other.selectionType, selectionType) || other.selectionType == selectionType)&&(identical(other.minSelections, minSelections) || other.minSelections == minSelections)&&(identical(other.maxSelections, maxSelections) || other.maxSelections == maxSelections)&&const DeepCollectionEquality().equals(other.options, _options)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,isRequired,selectionType,minSelections,maxSelections,const DeepCollectionEquality().hash(_options),sortOrder);
}

@override
String toString() {
    return 'ModifierGroup(id: $id, name: $name, description: $description, isRequired: $isRequired, selectionType: $selectionType, minSelections: $minSelections, maxSelections: $maxSelections, options: $options, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$ModifierGroupCopyWith<$Res> implements $ModifierGroupCopyWith<$Res> {
  factory _$ModifierGroupCopyWith(_ModifierGroup value, $Res Function(_ModifierGroup) _then) = __$ModifierGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, bool isRequired, String selectionType, int minSelections, int maxSelections, List<ModifierOption> options, int sortOrder
});




}
/// @nodoc
class __$ModifierGroupCopyWithImpl<$Res>
    implements _$ModifierGroupCopyWith<$Res> {
  __$ModifierGroupCopyWithImpl(this._self, this._then);

  final _ModifierGroup _self;
  final $Res Function(_ModifierGroup) _then;

/// Create a copy of ModifierGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? isRequired = null,Object? selectionType = null,Object? minSelections = null,Object? maxSelections = null,Object? options = null,Object? sortOrder = null,}) {
  return _then(_ModifierGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isRequired: null == isRequired ? _self.isRequired : isRequired // ignore: cast_nullable_to_non_nullable
as bool,selectionType: null == selectionType ? _self.selectionType : selectionType // ignore: cast_nullable_to_non_nullable
as String,minSelections: null == minSelections ? _self.minSelections : minSelections // ignore: cast_nullable_to_non_nullable
as int,maxSelections: null == maxSelections ? _self.maxSelections : maxSelections // ignore: cast_nullable_to_non_nullable
as int,options: null == options ? _self._options : options // ignore: cast_nullable_to_non_nullable
as List<ModifierOption>,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ModifierOption {

 String get id; String get name; String? get description; String? get image; double get priceModifier; bool get isDefault; bool get isAvailable; List<ModifierGroup> get nestedModifierGroups;
/// Create a copy of ModifierOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModifierOptionCopyWith<ModifierOption> get copyWith => _$ModifierOptionCopyWithImpl<ModifierOption>(this as ModifierOption, _$identity);

  /// Serializes this ModifierOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ModifierOption;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModifierOption&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description)&&(identical(other.image, _this.image) || other.image == _this.image)&&(identical(other.priceModifier, _this.priceModifier) || other.priceModifier == _this.priceModifier)&&(identical(other.isDefault, _this.isDefault) || other.isDefault == _this.isDefault)&&(identical(other.isAvailable, _this.isAvailable) || other.isAvailable == _this.isAvailable)&&const DeepCollectionEquality().equals(other.nestedModifierGroups, _this.nestedModifierGroups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ModifierOption;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description,_this.image,_this.priceModifier,_this.isDefault,_this.isAvailable,const DeepCollectionEquality().hash(_this.nestedModifierGroups));
}

@override
String toString() {
  final _this = this as ModifierOption;
  return 'ModifierOption(id: ${_this.id}, name: ${_this.name}, description: ${_this.description}, image: ${_this.image}, priceModifier: ${_this.priceModifier}, isDefault: ${_this.isDefault}, isAvailable: ${_this.isAvailable}, nestedModifierGroups: ${_this.nestedModifierGroups})';
}


}

/// @nodoc
abstract mixin class $ModifierOptionCopyWith<$Res>  {
  factory $ModifierOptionCopyWith(ModifierOption value, $Res Function(ModifierOption) _then) = _$ModifierOptionCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String? image, double priceModifier, bool isDefault, bool isAvailable, List<ModifierGroup> nestedModifierGroups
});




}
/// @nodoc
class _$ModifierOptionCopyWithImpl<$Res>
    implements $ModifierOptionCopyWith<$Res> {
  _$ModifierOptionCopyWithImpl(this._self, this._then);

  final ModifierOption _self;
  final $Res Function(ModifierOption) _then;

/// Create a copy of ModifierOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? image = freezed,Object? priceModifier = null,Object? isDefault = null,Object? isAvailable = null,Object? nestedModifierGroups = null,}) {
  return _then(ModifierOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,priceModifier: null == priceModifier ? _self.priceModifier : priceModifier // ignore: cast_nullable_to_non_nullable
as double,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,nestedModifierGroups: null == nestedModifierGroups ? _self.nestedModifierGroups : nestedModifierGroups // ignore: cast_nullable_to_non_nullable
as List<ModifierGroup>,
  ));
}

}


/// Adds pattern-matching-related methods to [ModifierOption].
extension ModifierOptionPatterns on ModifierOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModifierOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModifierOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModifierOption value)  $default,){
final _that = this;
switch (_that) {
case _ModifierOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModifierOption value)?  $default,){
final _that = this;
switch (_that) {
case _ModifierOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? image,  double priceModifier,  bool isDefault,  bool isAvailable,  List<ModifierGroup> nestedModifierGroups)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModifierOption() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.image,_that.priceModifier,_that.isDefault,_that.isAvailable,_that.nestedModifierGroups);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? image,  double priceModifier,  bool isDefault,  bool isAvailable,  List<ModifierGroup> nestedModifierGroups)  $default,) {final _that = this;
switch (_that) {
case _ModifierOption():
return $default(_that.id,_that.name,_that.description,_that.image,_that.priceModifier,_that.isDefault,_that.isAvailable,_that.nestedModifierGroups);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String? image,  double priceModifier,  bool isDefault,  bool isAvailable,  List<ModifierGroup> nestedModifierGroups)?  $default,) {final _that = this;
switch (_that) {
case _ModifierOption() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.image,_that.priceModifier,_that.isDefault,_that.isAvailable,_that.nestedModifierGroups);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModifierOption implements ModifierOption {
  const _ModifierOption({required this.id, required this.name, this.description, this.image, this.priceModifier = 0.0, this.isDefault = false, this.isAvailable = true,  List<ModifierGroup> nestedModifierGroups = const []}): _nestedModifierGroups = nestedModifierGroups;
  factory _ModifierOption.fromJson(Map<String, dynamic> json) => _$ModifierOptionFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String? image;
@override@JsonKey() final  double priceModifier;
@override@JsonKey() final  bool isDefault;
@override@JsonKey() final  bool isAvailable;
 final  List<ModifierGroup> _nestedModifierGroups;
@override@JsonKey() List<ModifierGroup> get nestedModifierGroups {
  if (_nestedModifierGroups is EqualUnmodifiableListView) return _nestedModifierGroups;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_nestedModifierGroups);
}


/// Create a copy of ModifierOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModifierOptionCopyWith<_ModifierOption> get copyWith => __$ModifierOptionCopyWithImpl<_ModifierOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModifierOptionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModifierOption&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.image, image) || other.image == image)&&(identical(other.priceModifier, priceModifier) || other.priceModifier == priceModifier)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&const DeepCollectionEquality().equals(other.nestedModifierGroups, _nestedModifierGroups));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description,image,priceModifier,isDefault,isAvailable,const DeepCollectionEquality().hash(_nestedModifierGroups));
}

@override
String toString() {
    return 'ModifierOption(id: $id, name: $name, description: $description, image: $image, priceModifier: $priceModifier, isDefault: $isDefault, isAvailable: $isAvailable, nestedModifierGroups: $nestedModifierGroups)';
}


}

/// @nodoc
abstract mixin class _$ModifierOptionCopyWith<$Res> implements $ModifierOptionCopyWith<$Res> {
  factory _$ModifierOptionCopyWith(_ModifierOption value, $Res Function(_ModifierOption) _then) = __$ModifierOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String? image, double priceModifier, bool isDefault, bool isAvailable, List<ModifierGroup> nestedModifierGroups
});




}
/// @nodoc
class __$ModifierOptionCopyWithImpl<$Res>
    implements _$ModifierOptionCopyWith<$Res> {
  __$ModifierOptionCopyWithImpl(this._self, this._then);

  final _ModifierOption _self;
  final $Res Function(_ModifierOption) _then;

/// Create a copy of ModifierOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? image = freezed,Object? priceModifier = null,Object? isDefault = null,Object? isAvailable = null,Object? nestedModifierGroups = null,}) {
  return _then(_ModifierOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as String?,priceModifier: null == priceModifier ? _self.priceModifier : priceModifier // ignore: cast_nullable_to_non_nullable
as double,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,nestedModifierGroups: null == nestedModifierGroups ? _self._nestedModifierGroups : nestedModifierGroups // ignore: cast_nullable_to_non_nullable
as List<ModifierGroup>,
  ));
}


}

// dart format on
