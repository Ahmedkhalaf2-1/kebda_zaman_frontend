// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Cart {

 String get id; List<CartItem> get items; String? get promoCodeId; int get loyaltyPointsApplied; double get deliveryFee; double get subtotal; double get discountTotal; double get taxTotal; double get grandTotal;
/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartCopyWith<Cart> get copyWith => _$CartCopyWithImpl<Cart>(this as Cart, _$identity);

  /// Serializes this Cart to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Cart;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Cart&&(identical(other.id, _this.id) || other.id == _this.id)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.promoCodeId, _this.promoCodeId) || other.promoCodeId == _this.promoCodeId)&&(identical(other.loyaltyPointsApplied, _this.loyaltyPointsApplied) || other.loyaltyPointsApplied == _this.loyaltyPointsApplied)&&(identical(other.deliveryFee, _this.deliveryFee) || other.deliveryFee == _this.deliveryFee)&&(identical(other.subtotal, _this.subtotal) || other.subtotal == _this.subtotal)&&(identical(other.discountTotal, _this.discountTotal) || other.discountTotal == _this.discountTotal)&&(identical(other.taxTotal, _this.taxTotal) || other.taxTotal == _this.taxTotal)&&(identical(other.grandTotal, _this.grandTotal) || other.grandTotal == _this.grandTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Cart;
  return Object.hash(runtimeType,_this.id,const DeepCollectionEquality().hash(_this.items),_this.promoCodeId,_this.loyaltyPointsApplied,_this.deliveryFee,_this.subtotal,_this.discountTotal,_this.taxTotal,_this.grandTotal);
}

@override
String toString() {
  final _this = this as Cart;
  return 'Cart(id: ${_this.id}, items: ${_this.items}, promoCodeId: ${_this.promoCodeId}, loyaltyPointsApplied: ${_this.loyaltyPointsApplied}, deliveryFee: ${_this.deliveryFee}, subtotal: ${_this.subtotal}, discountTotal: ${_this.discountTotal}, taxTotal: ${_this.taxTotal}, grandTotal: ${_this.grandTotal})';
}


}

/// @nodoc
abstract mixin class $CartCopyWith<$Res>  {
  factory $CartCopyWith(Cart value, $Res Function(Cart) _then) = _$CartCopyWithImpl;
@useResult
$Res call({
 String id, List<CartItem> items, String? promoCodeId, int loyaltyPointsApplied, double deliveryFee, double subtotal, double discountTotal, double taxTotal, double grandTotal
});




}
/// @nodoc
class _$CartCopyWithImpl<$Res>
    implements $CartCopyWith<$Res> {
  _$CartCopyWithImpl(this._self, this._then);

  final Cart _self;
  final $Res Function(Cart) _then;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? items = null,Object? promoCodeId = freezed,Object? loyaltyPointsApplied = null,Object? deliveryFee = null,Object? subtotal = null,Object? discountTotal = null,Object? taxTotal = null,Object? grandTotal = null,}) {
  return _then(Cart(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,promoCodeId: freezed == promoCodeId ? _self.promoCodeId : promoCodeId // ignore: cast_nullable_to_non_nullable
as String?,loyaltyPointsApplied: null == loyaltyPointsApplied ? _self.loyaltyPointsApplied : loyaltyPointsApplied // ignore: cast_nullable_to_non_nullable
as int,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,discountTotal: null == discountTotal ? _self.discountTotal : discountTotal // ignore: cast_nullable_to_non_nullable
as double,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as double,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Cart].
extension CartPatterns on Cart {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Cart value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Cart() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Cart value)  $default,){
final _that = this;
switch (_that) {
case _Cart():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Cart value)?  $default,){
final _that = this;
switch (_that) {
case _Cart() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<CartItem> items,  String? promoCodeId,  int loyaltyPointsApplied,  double deliveryFee,  double subtotal,  double discountTotal,  double taxTotal,  double grandTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.id,_that.items,_that.promoCodeId,_that.loyaltyPointsApplied,_that.deliveryFee,_that.subtotal,_that.discountTotal,_that.taxTotal,_that.grandTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<CartItem> items,  String? promoCodeId,  int loyaltyPointsApplied,  double deliveryFee,  double subtotal,  double discountTotal,  double taxTotal,  double grandTotal)  $default,) {final _that = this;
switch (_that) {
case _Cart():
return $default(_that.id,_that.items,_that.promoCodeId,_that.loyaltyPointsApplied,_that.deliveryFee,_that.subtotal,_that.discountTotal,_that.taxTotal,_that.grandTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<CartItem> items,  String? promoCodeId,  int loyaltyPointsApplied,  double deliveryFee,  double subtotal,  double discountTotal,  double taxTotal,  double grandTotal)?  $default,) {final _that = this;
switch (_that) {
case _Cart() when $default != null:
return $default(_that.id,_that.items,_that.promoCodeId,_that.loyaltyPointsApplied,_that.deliveryFee,_that.subtotal,_that.discountTotal,_that.taxTotal,_that.grandTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Cart implements Cart {
  const _Cart({required this.id,  List<CartItem> items = const [], this.promoCodeId, this.loyaltyPointsApplied = 0, this.deliveryFee = 0.0, this.subtotal = 0.0, this.discountTotal = 0.0, this.taxTotal = 0.0, this.grandTotal = 0.0}): _items = items;
  factory _Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

@override final  String id;
 final  List<CartItem> _items;
@override@JsonKey() List<CartItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? promoCodeId;
@override@JsonKey() final  int loyaltyPointsApplied;
@override@JsonKey() final  double deliveryFee;
@override@JsonKey() final  double subtotal;
@override@JsonKey() final  double discountTotal;
@override@JsonKey() final  double taxTotal;
@override@JsonKey() final  double grandTotal;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartCopyWith<_Cart> get copyWith => __$CartCopyWithImpl<_Cart>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Cart&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.promoCodeId, promoCodeId) || other.promoCodeId == promoCodeId)&&(identical(other.loyaltyPointsApplied, loyaltyPointsApplied) || other.loyaltyPointsApplied == loyaltyPointsApplied)&&(identical(other.deliveryFee, deliveryFee) || other.deliveryFee == deliveryFee)&&(identical(other.subtotal, subtotal) || other.subtotal == subtotal)&&(identical(other.discountTotal, discountTotal) || other.discountTotal == discountTotal)&&(identical(other.taxTotal, taxTotal) || other.taxTotal == taxTotal)&&(identical(other.grandTotal, grandTotal) || other.grandTotal == grandTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_items),promoCodeId,loyaltyPointsApplied,deliveryFee,subtotal,discountTotal,taxTotal,grandTotal);
}

@override
String toString() {
    return 'Cart(id: $id, items: $items, promoCodeId: $promoCodeId, loyaltyPointsApplied: $loyaltyPointsApplied, deliveryFee: $deliveryFee, subtotal: $subtotal, discountTotal: $discountTotal, taxTotal: $taxTotal, grandTotal: $grandTotal)';
}


}

/// @nodoc
abstract mixin class _$CartCopyWith<$Res> implements $CartCopyWith<$Res> {
  factory _$CartCopyWith(_Cart value, $Res Function(_Cart) _then) = __$CartCopyWithImpl;
@override @useResult
$Res call({
 String id, List<CartItem> items, String? promoCodeId, int loyaltyPointsApplied, double deliveryFee, double subtotal, double discountTotal, double taxTotal, double grandTotal
});




}
/// @nodoc
class __$CartCopyWithImpl<$Res>
    implements _$CartCopyWith<$Res> {
  __$CartCopyWithImpl(this._self, this._then);

  final _Cart _self;
  final $Res Function(_Cart) _then;

/// Create a copy of Cart
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? items = null,Object? promoCodeId = freezed,Object? loyaltyPointsApplied = null,Object? deliveryFee = null,Object? subtotal = null,Object? discountTotal = null,Object? taxTotal = null,Object? grandTotal = null,}) {
  return _then(_Cart(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<CartItem>,promoCodeId: freezed == promoCodeId ? _self.promoCodeId : promoCodeId // ignore: cast_nullable_to_non_nullable
as String?,loyaltyPointsApplied: null == loyaltyPointsApplied ? _self.loyaltyPointsApplied : loyaltyPointsApplied // ignore: cast_nullable_to_non_nullable
as int,deliveryFee: null == deliveryFee ? _self.deliveryFee : deliveryFee // ignore: cast_nullable_to_non_nullable
as double,subtotal: null == subtotal ? _self.subtotal : subtotal // ignore: cast_nullable_to_non_nullable
as double,discountTotal: null == discountTotal ? _self.discountTotal : discountTotal // ignore: cast_nullable_to_non_nullable
as double,taxTotal: null == taxTotal ? _self.taxTotal : taxTotal // ignore: cast_nullable_to_non_nullable
as double,grandTotal: null == grandTotal ? _self.grandTotal : grandTotal // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$CartItem {

 String get id; String get menuItemId; String get productName; String get productImage; double get basePrice; int get quantity; Map<String, List<String>> get selectedOptions; Map<String, Map<String, List<String>>> get nestedSelections; Map<String, int> get extraQuantities; List<String> get removedIngredients; String get specialInstructions; double get unitPrice; double get lineTotal; bool get isAvailable; double? get menuItemBasePrice; double? get menuItemDiscountPrice;
/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CartItemCopyWith<CartItem> get copyWith => _$CartItemCopyWithImpl<CartItem>(this as CartItem, _$identity);

  /// Serializes this CartItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CartItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CartItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.productName, _this.productName) || other.productName == _this.productName)&&(identical(other.productImage, _this.productImage) || other.productImage == _this.productImage)&&(identical(other.basePrice, _this.basePrice) || other.basePrice == _this.basePrice)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&const DeepCollectionEquality().equals(other.selectedOptions, _this.selectedOptions)&&const DeepCollectionEquality().equals(other.nestedSelections, _this.nestedSelections)&&const DeepCollectionEquality().equals(other.extraQuantities, _this.extraQuantities)&&const DeepCollectionEquality().equals(other.removedIngredients, _this.removedIngredients)&&(identical(other.specialInstructions, _this.specialInstructions) || other.specialInstructions == _this.specialInstructions)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.lineTotal, _this.lineTotal) || other.lineTotal == _this.lineTotal)&&(identical(other.isAvailable, _this.isAvailable) || other.isAvailable == _this.isAvailable)&&(identical(other.menuItemBasePrice, _this.menuItemBasePrice) || other.menuItemBasePrice == _this.menuItemBasePrice)&&(identical(other.menuItemDiscountPrice, _this.menuItemDiscountPrice) || other.menuItemDiscountPrice == _this.menuItemDiscountPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CartItem;
  return Object.hash(runtimeType,_this.id,_this.menuItemId,_this.productName,_this.productImage,_this.basePrice,_this.quantity,const DeepCollectionEquality().hash(_this.selectedOptions),const DeepCollectionEquality().hash(_this.nestedSelections),const DeepCollectionEquality().hash(_this.extraQuantities),const DeepCollectionEquality().hash(_this.removedIngredients),_this.specialInstructions,_this.unitPrice,_this.lineTotal,_this.isAvailable,_this.menuItemBasePrice,_this.menuItemDiscountPrice);
}

@override
String toString() {
  final _this = this as CartItem;
  return 'CartItem(id: ${_this.id}, menuItemId: ${_this.menuItemId}, productName: ${_this.productName}, productImage: ${_this.productImage}, basePrice: ${_this.basePrice}, quantity: ${_this.quantity}, selectedOptions: ${_this.selectedOptions}, nestedSelections: ${_this.nestedSelections}, extraQuantities: ${_this.extraQuantities}, removedIngredients: ${_this.removedIngredients}, specialInstructions: ${_this.specialInstructions}, unitPrice: ${_this.unitPrice}, lineTotal: ${_this.lineTotal}, isAvailable: ${_this.isAvailable}, menuItemBasePrice: ${_this.menuItemBasePrice}, menuItemDiscountPrice: ${_this.menuItemDiscountPrice})';
}


}

/// @nodoc
abstract mixin class $CartItemCopyWith<$Res>  {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) _then) = _$CartItemCopyWithImpl;
@useResult
$Res call({
 String id, String menuItemId, String productName, String productImage, double basePrice, int quantity, Map<String, List<String>> selectedOptions, Map<String, Map<String, List<String>>> nestedSelections, Map<String, int> extraQuantities, List<String> removedIngredients, String specialInstructions, double unitPrice, double lineTotal, bool isAvailable, double? menuItemBasePrice, double? menuItemDiscountPrice
});




}
/// @nodoc
class _$CartItemCopyWithImpl<$Res>
    implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._self, this._then);

  final CartItem _self;
  final $Res Function(CartItem) _then;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? menuItemId = null,Object? productName = null,Object? productImage = null,Object? basePrice = null,Object? quantity = null,Object? selectedOptions = null,Object? nestedSelections = null,Object? extraQuantities = null,Object? removedIngredients = null,Object? specialInstructions = null,Object? unitPrice = null,Object? lineTotal = null,Object? isAvailable = null,Object? menuItemBasePrice = freezed,Object? menuItemDiscountPrice = freezed,}) {
  return _then(CartItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,productImage: null == productImage ? _self.productImage : productImage // ignore: cast_nullable_to_non_nullable
as String,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,selectedOptions: null == selectedOptions ? _self.selectedOptions : selectedOptions // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,nestedSelections: null == nestedSelections ? _self.nestedSelections : nestedSelections // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, List<String>>>,extraQuantities: null == extraQuantities ? _self.extraQuantities : extraQuantities // ignore: cast_nullable_to_non_nullable
as Map<String, int>,removedIngredients: null == removedIngredients ? _self.removedIngredients : removedIngredients // ignore: cast_nullable_to_non_nullable
as List<String>,specialInstructions: null == specialInstructions ? _self.specialInstructions : specialInstructions // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as double,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,menuItemBasePrice: freezed == menuItemBasePrice ? _self.menuItemBasePrice : menuItemBasePrice // ignore: cast_nullable_to_non_nullable
as double?,menuItemDiscountPrice: freezed == menuItemDiscountPrice ? _self.menuItemDiscountPrice : menuItemDiscountPrice // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [CartItem].
extension CartItemPatterns on CartItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CartItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CartItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CartItem value)  $default,){
final _that = this;
switch (_that) {
case _CartItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CartItem value)?  $default,){
final _that = this;
switch (_that) {
case _CartItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String menuItemId,  String productName,  String productImage,  double basePrice,  int quantity,  Map<String, List<String>> selectedOptions,  Map<String, Map<String, List<String>>> nestedSelections,  Map<String, int> extraQuantities,  List<String> removedIngredients,  String specialInstructions,  double unitPrice,  double lineTotal,  bool isAvailable,  double? menuItemBasePrice,  double? menuItemDiscountPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that.id,_that.menuItemId,_that.productName,_that.productImage,_that.basePrice,_that.quantity,_that.selectedOptions,_that.nestedSelections,_that.extraQuantities,_that.removedIngredients,_that.specialInstructions,_that.unitPrice,_that.lineTotal,_that.isAvailable,_that.menuItemBasePrice,_that.menuItemDiscountPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String menuItemId,  String productName,  String productImage,  double basePrice,  int quantity,  Map<String, List<String>> selectedOptions,  Map<String, Map<String, List<String>>> nestedSelections,  Map<String, int> extraQuantities,  List<String> removedIngredients,  String specialInstructions,  double unitPrice,  double lineTotal,  bool isAvailable,  double? menuItemBasePrice,  double? menuItemDiscountPrice)  $default,) {final _that = this;
switch (_that) {
case _CartItem():
return $default(_that.id,_that.menuItemId,_that.productName,_that.productImage,_that.basePrice,_that.quantity,_that.selectedOptions,_that.nestedSelections,_that.extraQuantities,_that.removedIngredients,_that.specialInstructions,_that.unitPrice,_that.lineTotal,_that.isAvailable,_that.menuItemBasePrice,_that.menuItemDiscountPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String menuItemId,  String productName,  String productImage,  double basePrice,  int quantity,  Map<String, List<String>> selectedOptions,  Map<String, Map<String, List<String>>> nestedSelections,  Map<String, int> extraQuantities,  List<String> removedIngredients,  String specialInstructions,  double unitPrice,  double lineTotal,  bool isAvailable,  double? menuItemBasePrice,  double? menuItemDiscountPrice)?  $default,) {final _that = this;
switch (_that) {
case _CartItem() when $default != null:
return $default(_that.id,_that.menuItemId,_that.productName,_that.productImage,_that.basePrice,_that.quantity,_that.selectedOptions,_that.nestedSelections,_that.extraQuantities,_that.removedIngredients,_that.specialInstructions,_that.unitPrice,_that.lineTotal,_that.isAvailable,_that.menuItemBasePrice,_that.menuItemDiscountPrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CartItem extends CartItem {
  const _CartItem({required this.id, required this.menuItemId, required this.productName, required this.productImage, required this.basePrice, required this.quantity,  Map<String, List<String>> selectedOptions = const {},  Map<String, Map<String, List<String>>> nestedSelections = const {},  Map<String, int> extraQuantities = const {},  List<String> removedIngredients = const [], this.specialInstructions = '', required this.unitPrice, required this.lineTotal, this.isAvailable = true, this.menuItemBasePrice, this.menuItemDiscountPrice}): _selectedOptions = selectedOptions,_nestedSelections = nestedSelections,_extraQuantities = extraQuantities,_removedIngredients = removedIngredients,super._();
  factory _CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);

@override final  String id;
@override final  String menuItemId;
@override final  String productName;
@override final  String productImage;
@override final  double basePrice;
@override final  int quantity;
 final  Map<String, List<String>> _selectedOptions;
@override@JsonKey() Map<String, List<String>> get selectedOptions {
  if (_selectedOptions is EqualUnmodifiableMapView) return _selectedOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_selectedOptions);
}

 final  Map<String, Map<String, List<String>>> _nestedSelections;
@override@JsonKey() Map<String, Map<String, List<String>>> get nestedSelections {
  if (_nestedSelections is EqualUnmodifiableMapView) return _nestedSelections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_nestedSelections);
}

 final  Map<String, int> _extraQuantities;
@override@JsonKey() Map<String, int> get extraQuantities {
  if (_extraQuantities is EqualUnmodifiableMapView) return _extraQuantities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_extraQuantities);
}

 final  List<String> _removedIngredients;
@override@JsonKey() List<String> get removedIngredients {
  if (_removedIngredients is EqualUnmodifiableListView) return _removedIngredients;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_removedIngredients);
}

@override@JsonKey() final  String specialInstructions;
@override final  double unitPrice;
@override final  double lineTotal;
@override@JsonKey() final  bool isAvailable;
@override final  double? menuItemBasePrice;
@override final  double? menuItemDiscountPrice;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CartItemCopyWith<_CartItem> get copyWith => __$CartItemCopyWithImpl<_CartItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CartItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CartItem&&(identical(other.id, id) || other.id == id)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productImage, productImage) || other.productImage == productImage)&&(identical(other.basePrice, basePrice) || other.basePrice == basePrice)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&const DeepCollectionEquality().equals(other.selectedOptions, _selectedOptions)&&const DeepCollectionEquality().equals(other.nestedSelections, _nestedSelections)&&const DeepCollectionEquality().equals(other.extraQuantities, _extraQuantities)&&const DeepCollectionEquality().equals(other.removedIngredients, _removedIngredients)&&(identical(other.specialInstructions, specialInstructions) || other.specialInstructions == specialInstructions)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.lineTotal, lineTotal) || other.lineTotal == lineTotal)&&(identical(other.isAvailable, isAvailable) || other.isAvailable == isAvailable)&&(identical(other.menuItemBasePrice, menuItemBasePrice) || other.menuItemBasePrice == menuItemBasePrice)&&(identical(other.menuItemDiscountPrice, menuItemDiscountPrice) || other.menuItemDiscountPrice == menuItemDiscountPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,menuItemId,productName,productImage,basePrice,quantity,const DeepCollectionEquality().hash(_selectedOptions),const DeepCollectionEquality().hash(_nestedSelections),const DeepCollectionEquality().hash(_extraQuantities),const DeepCollectionEquality().hash(_removedIngredients),specialInstructions,unitPrice,lineTotal,isAvailable,menuItemBasePrice,menuItemDiscountPrice);
}

@override
String toString() {
    return 'CartItem(id: $id, menuItemId: $menuItemId, productName: $productName, productImage: $productImage, basePrice: $basePrice, quantity: $quantity, selectedOptions: $selectedOptions, nestedSelections: $nestedSelections, extraQuantities: $extraQuantities, removedIngredients: $removedIngredients, specialInstructions: $specialInstructions, unitPrice: $unitPrice, lineTotal: $lineTotal, isAvailable: $isAvailable, menuItemBasePrice: $menuItemBasePrice, menuItemDiscountPrice: $menuItemDiscountPrice)';
}


}

/// @nodoc
abstract mixin class _$CartItemCopyWith<$Res> implements $CartItemCopyWith<$Res> {
  factory _$CartItemCopyWith(_CartItem value, $Res Function(_CartItem) _then) = __$CartItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String menuItemId, String productName, String productImage, double basePrice, int quantity, Map<String, List<String>> selectedOptions, Map<String, Map<String, List<String>>> nestedSelections, Map<String, int> extraQuantities, List<String> removedIngredients, String specialInstructions, double unitPrice, double lineTotal, bool isAvailable, double? menuItemBasePrice, double? menuItemDiscountPrice
});




}
/// @nodoc
class __$CartItemCopyWithImpl<$Res>
    implements _$CartItemCopyWith<$Res> {
  __$CartItemCopyWithImpl(this._self, this._then);

  final _CartItem _self;
  final $Res Function(_CartItem) _then;

/// Create a copy of CartItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? menuItemId = null,Object? productName = null,Object? productImage = null,Object? basePrice = null,Object? quantity = null,Object? selectedOptions = null,Object? nestedSelections = null,Object? extraQuantities = null,Object? removedIngredients = null,Object? specialInstructions = null,Object? unitPrice = null,Object? lineTotal = null,Object? isAvailable = null,Object? menuItemBasePrice = freezed,Object? menuItemDiscountPrice = freezed,}) {
  return _then(_CartItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,menuItemId: null == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,productImage: null == productImage ? _self.productImage : productImage // ignore: cast_nullable_to_non_nullable
as String,basePrice: null == basePrice ? _self.basePrice : basePrice // ignore: cast_nullable_to_non_nullable
as double,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,selectedOptions: null == selectedOptions ? _self._selectedOptions : selectedOptions // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,nestedSelections: null == nestedSelections ? _self._nestedSelections : nestedSelections // ignore: cast_nullable_to_non_nullable
as Map<String, Map<String, List<String>>>,extraQuantities: null == extraQuantities ? _self._extraQuantities : extraQuantities // ignore: cast_nullable_to_non_nullable
as Map<String, int>,removedIngredients: null == removedIngredients ? _self._removedIngredients : removedIngredients // ignore: cast_nullable_to_non_nullable
as List<String>,specialInstructions: null == specialInstructions ? _self.specialInstructions : specialInstructions // ignore: cast_nullable_to_non_nullable
as String,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,lineTotal: null == lineTotal ? _self.lineTotal : lineTotal // ignore: cast_nullable_to_non_nullable
as double,isAvailable: null == isAvailable ? _self.isAvailable : isAvailable // ignore: cast_nullable_to_non_nullable
as bool,menuItemBasePrice: freezed == menuItemBasePrice ? _self.menuItemBasePrice : menuItemBasePrice // ignore: cast_nullable_to_non_nullable
as double?,menuItemDiscountPrice: freezed == menuItemDiscountPrice ? _self.menuItemDiscountPrice : menuItemDiscountPrice // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
