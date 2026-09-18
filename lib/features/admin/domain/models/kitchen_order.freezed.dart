// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kitchen_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KitchenOrder {

 String get id; String get orderNumber; OrderStatus get status; FulfillmentType get deliveryMethod; DateTime get createdAt; List<KitchenOrderItem> get items; int? get preparationTimeMinutes; String? get estimatedDeliveryTime;
/// Create a copy of KitchenOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KitchenOrderCopyWith<KitchenOrder> get copyWith => _$KitchenOrderCopyWithImpl<KitchenOrder>(this as KitchenOrder, _$identity);

  /// Serializes this KitchenOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as KitchenOrder;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KitchenOrder&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.orderNumber, _this.orderNumber) || other.orderNumber == _this.orderNumber)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.deliveryMethod, _this.deliveryMethod) || other.deliveryMethod == _this.deliveryMethod)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&const DeepCollectionEquality().equals(other.items, _this.items)&&(identical(other.preparationTimeMinutes, _this.preparationTimeMinutes) || other.preparationTimeMinutes == _this.preparationTimeMinutes)&&(identical(other.estimatedDeliveryTime, _this.estimatedDeliveryTime) || other.estimatedDeliveryTime == _this.estimatedDeliveryTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as KitchenOrder;
  return Object.hash(runtimeType,_this.id,_this.orderNumber,_this.status,_this.deliveryMethod,_this.createdAt,const DeepCollectionEquality().hash(_this.items),_this.preparationTimeMinutes,_this.estimatedDeliveryTime);
}

@override
String toString() {
  final _this = this as KitchenOrder;
  return 'KitchenOrder(id: ${_this.id}, orderNumber: ${_this.orderNumber}, status: ${_this.status}, deliveryMethod: ${_this.deliveryMethod}, createdAt: ${_this.createdAt}, items: ${_this.items}, preparationTimeMinutes: ${_this.preparationTimeMinutes}, estimatedDeliveryTime: ${_this.estimatedDeliveryTime})';
}


}

/// @nodoc
abstract mixin class $KitchenOrderCopyWith<$Res>  {
  factory $KitchenOrderCopyWith(KitchenOrder value, $Res Function(KitchenOrder) _then) = _$KitchenOrderCopyWithImpl;
@useResult
$Res call({
 String id, String orderNumber, OrderStatus status, FulfillmentType deliveryMethod, DateTime createdAt, List<KitchenOrderItem> items, int? preparationTimeMinutes, String? estimatedDeliveryTime
});




}
/// @nodoc
class _$KitchenOrderCopyWithImpl<$Res>
    implements $KitchenOrderCopyWith<$Res> {
  _$KitchenOrderCopyWithImpl(this._self, this._then);

  final KitchenOrder _self;
  final $Res Function(KitchenOrder) _then;

/// Create a copy of KitchenOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? orderNumber = null,Object? status = null,Object? deliveryMethod = null,Object? createdAt = null,Object? items = null,Object? preparationTimeMinutes = freezed,Object? estimatedDeliveryTime = freezed,}) {
  return _then(KitchenOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,deliveryMethod: null == deliveryMethod ? _self.deliveryMethod : deliveryMethod // ignore: cast_nullable_to_non_nullable
as FulfillmentType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<KitchenOrderItem>,preparationTimeMinutes: freezed == preparationTimeMinutes ? _self.preparationTimeMinutes : preparationTimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,estimatedDeliveryTime: freezed == estimatedDeliveryTime ? _self.estimatedDeliveryTime : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [KitchenOrder].
extension KitchenOrderPatterns on KitchenOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KitchenOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KitchenOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KitchenOrder value)  $default,){
final _that = this;
switch (_that) {
case _KitchenOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KitchenOrder value)?  $default,){
final _that = this;
switch (_that) {
case _KitchenOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String orderNumber,  OrderStatus status,  FulfillmentType deliveryMethod,  DateTime createdAt,  List<KitchenOrderItem> items,  int? preparationTimeMinutes,  String? estimatedDeliveryTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KitchenOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.status,_that.deliveryMethod,_that.createdAt,_that.items,_that.preparationTimeMinutes,_that.estimatedDeliveryTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String orderNumber,  OrderStatus status,  FulfillmentType deliveryMethod,  DateTime createdAt,  List<KitchenOrderItem> items,  int? preparationTimeMinutes,  String? estimatedDeliveryTime)  $default,) {final _that = this;
switch (_that) {
case _KitchenOrder():
return $default(_that.id,_that.orderNumber,_that.status,_that.deliveryMethod,_that.createdAt,_that.items,_that.preparationTimeMinutes,_that.estimatedDeliveryTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String orderNumber,  OrderStatus status,  FulfillmentType deliveryMethod,  DateTime createdAt,  List<KitchenOrderItem> items,  int? preparationTimeMinutes,  String? estimatedDeliveryTime)?  $default,) {final _that = this;
switch (_that) {
case _KitchenOrder() when $default != null:
return $default(_that.id,_that.orderNumber,_that.status,_that.deliveryMethod,_that.createdAt,_that.items,_that.preparationTimeMinutes,_that.estimatedDeliveryTime);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KitchenOrder implements KitchenOrder {
  const _KitchenOrder({required this.id, required this.orderNumber, required this.status, required this.deliveryMethod, required this.createdAt, required  List<KitchenOrderItem> items, this.preparationTimeMinutes, this.estimatedDeliveryTime}): _items = items;
  factory _KitchenOrder.fromJson(Map<String, dynamic> json) => _$KitchenOrderFromJson(json);

@override final  String id;
@override final  String orderNumber;
@override final  OrderStatus status;
@override final  FulfillmentType deliveryMethod;
@override final  DateTime createdAt;
 final  List<KitchenOrderItem> _items;
@override List<KitchenOrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  int? preparationTimeMinutes;
@override final  String? estimatedDeliveryTime;

/// Create a copy of KitchenOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KitchenOrderCopyWith<_KitchenOrder> get copyWith => __$KitchenOrderCopyWithImpl<_KitchenOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KitchenOrderToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KitchenOrder&&(identical(other.id, id) || other.id == id)&&(identical(other.orderNumber, orderNumber) || other.orderNumber == orderNumber)&&(identical(other.status, status) || other.status == status)&&(identical(other.deliveryMethod, deliveryMethod) || other.deliveryMethod == deliveryMethod)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.items, _items)&&(identical(other.preparationTimeMinutes, preparationTimeMinutes) || other.preparationTimeMinutes == preparationTimeMinutes)&&(identical(other.estimatedDeliveryTime, estimatedDeliveryTime) || other.estimatedDeliveryTime == estimatedDeliveryTime));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,orderNumber,status,deliveryMethod,createdAt,const DeepCollectionEquality().hash(_items),preparationTimeMinutes,estimatedDeliveryTime);
}

@override
String toString() {
    return 'KitchenOrder(id: $id, orderNumber: $orderNumber, status: $status, deliveryMethod: $deliveryMethod, createdAt: $createdAt, items: $items, preparationTimeMinutes: $preparationTimeMinutes, estimatedDeliveryTime: $estimatedDeliveryTime)';
}


}

/// @nodoc
abstract mixin class _$KitchenOrderCopyWith<$Res> implements $KitchenOrderCopyWith<$Res> {
  factory _$KitchenOrderCopyWith(_KitchenOrder value, $Res Function(_KitchenOrder) _then) = __$KitchenOrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String orderNumber, OrderStatus status, FulfillmentType deliveryMethod, DateTime createdAt, List<KitchenOrderItem> items, int? preparationTimeMinutes, String? estimatedDeliveryTime
});




}
/// @nodoc
class __$KitchenOrderCopyWithImpl<$Res>
    implements _$KitchenOrderCopyWith<$Res> {
  __$KitchenOrderCopyWithImpl(this._self, this._then);

  final _KitchenOrder _self;
  final $Res Function(_KitchenOrder) _then;

/// Create a copy of KitchenOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? orderNumber = null,Object? status = null,Object? deliveryMethod = null,Object? createdAt = null,Object? items = null,Object? preparationTimeMinutes = freezed,Object? estimatedDeliveryTime = freezed,}) {
  return _then(_KitchenOrder(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,orderNumber: null == orderNumber ? _self.orderNumber : orderNumber // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as OrderStatus,deliveryMethod: null == deliveryMethod ? _self.deliveryMethod : deliveryMethod // ignore: cast_nullable_to_non_nullable
as FulfillmentType,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<KitchenOrderItem>,preparationTimeMinutes: freezed == preparationTimeMinutes ? _self.preparationTimeMinutes : preparationTimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,estimatedDeliveryTime: freezed == estimatedDeliveryTime ? _self.estimatedDeliveryTime : estimatedDeliveryTime // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$KitchenOrderItem {

 String get id; String? get menuItemId; String get nameAr; String get nameEn; String? get imageUrl; KitchenCustomizationSnapshot? get selectedVariant; List<KitchenCustomizationSnapshot> get selectedAddons; int get quantity; String? get specialInstructions; double get unitPrice; double get totalPrice;
/// Create a copy of KitchenOrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KitchenOrderItemCopyWith<KitchenOrderItem> get copyWith => _$KitchenOrderItemCopyWithImpl<KitchenOrderItem>(this as KitchenOrderItem, _$identity);

  /// Serializes this KitchenOrderItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as KitchenOrderItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KitchenOrderItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.menuItemId, _this.menuItemId) || other.menuItemId == _this.menuItemId)&&(identical(other.nameAr, _this.nameAr) || other.nameAr == _this.nameAr)&&(identical(other.nameEn, _this.nameEn) || other.nameEn == _this.nameEn)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.selectedVariant, _this.selectedVariant) || other.selectedVariant == _this.selectedVariant)&&const DeepCollectionEquality().equals(other.selectedAddons, _this.selectedAddons)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.specialInstructions, _this.specialInstructions) || other.specialInstructions == _this.specialInstructions)&&(identical(other.unitPrice, _this.unitPrice) || other.unitPrice == _this.unitPrice)&&(identical(other.totalPrice, _this.totalPrice) || other.totalPrice == _this.totalPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as KitchenOrderItem;
  return Object.hash(runtimeType,_this.id,_this.menuItemId,_this.nameAr,_this.nameEn,_this.imageUrl,_this.selectedVariant,const DeepCollectionEquality().hash(_this.selectedAddons),_this.quantity,_this.specialInstructions,_this.unitPrice,_this.totalPrice);
}

@override
String toString() {
  final _this = this as KitchenOrderItem;
  return 'KitchenOrderItem(id: ${_this.id}, menuItemId: ${_this.menuItemId}, nameAr: ${_this.nameAr}, nameEn: ${_this.nameEn}, imageUrl: ${_this.imageUrl}, selectedVariant: ${_this.selectedVariant}, selectedAddons: ${_this.selectedAddons}, quantity: ${_this.quantity}, specialInstructions: ${_this.specialInstructions}, unitPrice: ${_this.unitPrice}, totalPrice: ${_this.totalPrice})';
}


}

/// @nodoc
abstract mixin class $KitchenOrderItemCopyWith<$Res>  {
  factory $KitchenOrderItemCopyWith(KitchenOrderItem value, $Res Function(KitchenOrderItem) _then) = _$KitchenOrderItemCopyWithImpl;
@useResult
$Res call({
 String id, String? menuItemId, String nameAr, String nameEn, String? imageUrl, KitchenCustomizationSnapshot? selectedVariant, List<KitchenCustomizationSnapshot> selectedAddons, int quantity, String? specialInstructions, double unitPrice, double totalPrice
});


$KitchenCustomizationSnapshotCopyWith<$Res>? get selectedVariant;

}
/// @nodoc
class _$KitchenOrderItemCopyWithImpl<$Res>
    implements $KitchenOrderItemCopyWith<$Res> {
  _$KitchenOrderItemCopyWithImpl(this._self, this._then);

  final KitchenOrderItem _self;
  final $Res Function(KitchenOrderItem) _then;

/// Create a copy of KitchenOrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? menuItemId = freezed,Object? nameAr = null,Object? nameEn = null,Object? imageUrl = freezed,Object? selectedVariant = freezed,Object? selectedAddons = null,Object? quantity = null,Object? specialInstructions = freezed,Object? unitPrice = null,Object? totalPrice = null,}) {
  return _then(KitchenOrderItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String?,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,selectedVariant: freezed == selectedVariant ? _self.selectedVariant : selectedVariant // ignore: cast_nullable_to_non_nullable
as KitchenCustomizationSnapshot?,selectedAddons: null == selectedAddons ? _self.selectedAddons : selectedAddons // ignore: cast_nullable_to_non_nullable
as List<KitchenCustomizationSnapshot>,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,specialInstructions: freezed == specialInstructions ? _self.specialInstructions : specialInstructions // ignore: cast_nullable_to_non_nullable
as String?,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of KitchenOrderItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KitchenCustomizationSnapshotCopyWith<$Res>? get selectedVariant {
    if (_self.selectedVariant == null) {
    return null;
  }

  return $KitchenCustomizationSnapshotCopyWith<$Res>(_self.selectedVariant!, (value) {
    return _then(_self.copyWith(selectedVariant: value));
  });
}
}


/// Adds pattern-matching-related methods to [KitchenOrderItem].
extension KitchenOrderItemPatterns on KitchenOrderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KitchenOrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KitchenOrderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KitchenOrderItem value)  $default,){
final _that = this;
switch (_that) {
case _KitchenOrderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KitchenOrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _KitchenOrderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? menuItemId,  String nameAr,  String nameEn,  String? imageUrl,  KitchenCustomizationSnapshot? selectedVariant,  List<KitchenCustomizationSnapshot> selectedAddons,  int quantity,  String? specialInstructions,  double unitPrice,  double totalPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KitchenOrderItem() when $default != null:
return $default(_that.id,_that.menuItemId,_that.nameAr,_that.nameEn,_that.imageUrl,_that.selectedVariant,_that.selectedAddons,_that.quantity,_that.specialInstructions,_that.unitPrice,_that.totalPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? menuItemId,  String nameAr,  String nameEn,  String? imageUrl,  KitchenCustomizationSnapshot? selectedVariant,  List<KitchenCustomizationSnapshot> selectedAddons,  int quantity,  String? specialInstructions,  double unitPrice,  double totalPrice)  $default,) {final _that = this;
switch (_that) {
case _KitchenOrderItem():
return $default(_that.id,_that.menuItemId,_that.nameAr,_that.nameEn,_that.imageUrl,_that.selectedVariant,_that.selectedAddons,_that.quantity,_that.specialInstructions,_that.unitPrice,_that.totalPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? menuItemId,  String nameAr,  String nameEn,  String? imageUrl,  KitchenCustomizationSnapshot? selectedVariant,  List<KitchenCustomizationSnapshot> selectedAddons,  int quantity,  String? specialInstructions,  double unitPrice,  double totalPrice)?  $default,) {final _that = this;
switch (_that) {
case _KitchenOrderItem() when $default != null:
return $default(_that.id,_that.menuItemId,_that.nameAr,_that.nameEn,_that.imageUrl,_that.selectedVariant,_that.selectedAddons,_that.quantity,_that.specialInstructions,_that.unitPrice,_that.totalPrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KitchenOrderItem implements KitchenOrderItem {
  const _KitchenOrderItem({required this.id, this.menuItemId, required this.nameAr, required this.nameEn, this.imageUrl, this.selectedVariant,  List<KitchenCustomizationSnapshot> selectedAddons = const [], required this.quantity, this.specialInstructions, required this.unitPrice, required this.totalPrice}): _selectedAddons = selectedAddons;
  factory _KitchenOrderItem.fromJson(Map<String, dynamic> json) => _$KitchenOrderItemFromJson(json);

@override final  String id;
@override final  String? menuItemId;
@override final  String nameAr;
@override final  String nameEn;
@override final  String? imageUrl;
@override final  KitchenCustomizationSnapshot? selectedVariant;
 final  List<KitchenCustomizationSnapshot> _selectedAddons;
@override@JsonKey() List<KitchenCustomizationSnapshot> get selectedAddons {
  if (_selectedAddons is EqualUnmodifiableListView) return _selectedAddons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedAddons);
}

@override final  int quantity;
@override final  String? specialInstructions;
@override final  double unitPrice;
@override final  double totalPrice;

/// Create a copy of KitchenOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KitchenOrderItemCopyWith<_KitchenOrderItem> get copyWith => __$KitchenOrderItemCopyWithImpl<_KitchenOrderItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KitchenOrderItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KitchenOrderItem&&(identical(other.id, id) || other.id == id)&&(identical(other.menuItemId, menuItemId) || other.menuItemId == menuItemId)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.selectedVariant, selectedVariant) || other.selectedVariant == selectedVariant)&&const DeepCollectionEquality().equals(other.selectedAddons, _selectedAddons)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.specialInstructions, specialInstructions) || other.specialInstructions == specialInstructions)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,menuItemId,nameAr,nameEn,imageUrl,selectedVariant,const DeepCollectionEquality().hash(_selectedAddons),quantity,specialInstructions,unitPrice,totalPrice);
}

@override
String toString() {
    return 'KitchenOrderItem(id: $id, menuItemId: $menuItemId, nameAr: $nameAr, nameEn: $nameEn, imageUrl: $imageUrl, selectedVariant: $selectedVariant, selectedAddons: $selectedAddons, quantity: $quantity, specialInstructions: $specialInstructions, unitPrice: $unitPrice, totalPrice: $totalPrice)';
}


}

/// @nodoc
abstract mixin class _$KitchenOrderItemCopyWith<$Res> implements $KitchenOrderItemCopyWith<$Res> {
  factory _$KitchenOrderItemCopyWith(_KitchenOrderItem value, $Res Function(_KitchenOrderItem) _then) = __$KitchenOrderItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String? menuItemId, String nameAr, String nameEn, String? imageUrl, KitchenCustomizationSnapshot? selectedVariant, List<KitchenCustomizationSnapshot> selectedAddons, int quantity, String? specialInstructions, double unitPrice, double totalPrice
});


@override $KitchenCustomizationSnapshotCopyWith<$Res>? get selectedVariant;

}
/// @nodoc
class __$KitchenOrderItemCopyWithImpl<$Res>
    implements _$KitchenOrderItemCopyWith<$Res> {
  __$KitchenOrderItemCopyWithImpl(this._self, this._then);

  final _KitchenOrderItem _self;
  final $Res Function(_KitchenOrderItem) _then;

/// Create a copy of KitchenOrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? menuItemId = freezed,Object? nameAr = null,Object? nameEn = null,Object? imageUrl = freezed,Object? selectedVariant = freezed,Object? selectedAddons = null,Object? quantity = null,Object? specialInstructions = freezed,Object? unitPrice = null,Object? totalPrice = null,}) {
  return _then(_KitchenOrderItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,menuItemId: freezed == menuItemId ? _self.menuItemId : menuItemId // ignore: cast_nullable_to_non_nullable
as String?,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,selectedVariant: freezed == selectedVariant ? _self.selectedVariant : selectedVariant // ignore: cast_nullable_to_non_nullable
as KitchenCustomizationSnapshot?,selectedAddons: null == selectedAddons ? _self._selectedAddons : selectedAddons // ignore: cast_nullable_to_non_nullable
as List<KitchenCustomizationSnapshot>,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,specialInstructions: freezed == specialInstructions ? _self.specialInstructions : specialInstructions // ignore: cast_nullable_to_non_nullable
as String?,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as double,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of KitchenOrderItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$KitchenCustomizationSnapshotCopyWith<$Res>? get selectedVariant {
    if (_self.selectedVariant == null) {
    return null;
  }

  return $KitchenCustomizationSnapshotCopyWith<$Res>(_self.selectedVariant!, (value) {
    return _then(_self.copyWith(selectedVariant: value));
  });
}
}


/// @nodoc
mixin _$KitchenCustomizationSnapshot {

 String get id; String? get refId; String get nameAr; String get nameEn; double get priceSnapshot;
/// Create a copy of KitchenCustomizationSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KitchenCustomizationSnapshotCopyWith<KitchenCustomizationSnapshot> get copyWith => _$KitchenCustomizationSnapshotCopyWithImpl<KitchenCustomizationSnapshot>(this as KitchenCustomizationSnapshot, _$identity);

  /// Serializes this KitchenCustomizationSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as KitchenCustomizationSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KitchenCustomizationSnapshot&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.refId, _this.refId) || other.refId == _this.refId)&&(identical(other.nameAr, _this.nameAr) || other.nameAr == _this.nameAr)&&(identical(other.nameEn, _this.nameEn) || other.nameEn == _this.nameEn)&&(identical(other.priceSnapshot, _this.priceSnapshot) || other.priceSnapshot == _this.priceSnapshot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as KitchenCustomizationSnapshot;
  return Object.hash(runtimeType,_this.id,_this.refId,_this.nameAr,_this.nameEn,_this.priceSnapshot);
}

@override
String toString() {
  final _this = this as KitchenCustomizationSnapshot;
  return 'KitchenCustomizationSnapshot(id: ${_this.id}, refId: ${_this.refId}, nameAr: ${_this.nameAr}, nameEn: ${_this.nameEn}, priceSnapshot: ${_this.priceSnapshot})';
}


}

/// @nodoc
abstract mixin class $KitchenCustomizationSnapshotCopyWith<$Res>  {
  factory $KitchenCustomizationSnapshotCopyWith(KitchenCustomizationSnapshot value, $Res Function(KitchenCustomizationSnapshot) _then) = _$KitchenCustomizationSnapshotCopyWithImpl;
@useResult
$Res call({
 String id, String? refId, String nameAr, String nameEn, double priceSnapshot
});




}
/// @nodoc
class _$KitchenCustomizationSnapshotCopyWithImpl<$Res>
    implements $KitchenCustomizationSnapshotCopyWith<$Res> {
  _$KitchenCustomizationSnapshotCopyWithImpl(this._self, this._then);

  final KitchenCustomizationSnapshot _self;
  final $Res Function(KitchenCustomizationSnapshot) _then;

/// Create a copy of KitchenCustomizationSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? refId = freezed,Object? nameAr = null,Object? nameEn = null,Object? priceSnapshot = null,}) {
  return _then(KitchenCustomizationSnapshot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,refId: freezed == refId ? _self.refId : refId // ignore: cast_nullable_to_non_nullable
as String?,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,priceSnapshot: null == priceSnapshot ? _self.priceSnapshot : priceSnapshot // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [KitchenCustomizationSnapshot].
extension KitchenCustomizationSnapshotPatterns on KitchenCustomizationSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KitchenCustomizationSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KitchenCustomizationSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KitchenCustomizationSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _KitchenCustomizationSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KitchenCustomizationSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _KitchenCustomizationSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? refId,  String nameAr,  String nameEn,  double priceSnapshot)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KitchenCustomizationSnapshot() when $default != null:
return $default(_that.id,_that.refId,_that.nameAr,_that.nameEn,_that.priceSnapshot);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? refId,  String nameAr,  String nameEn,  double priceSnapshot)  $default,) {final _that = this;
switch (_that) {
case _KitchenCustomizationSnapshot():
return $default(_that.id,_that.refId,_that.nameAr,_that.nameEn,_that.priceSnapshot);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? refId,  String nameAr,  String nameEn,  double priceSnapshot)?  $default,) {final _that = this;
switch (_that) {
case _KitchenCustomizationSnapshot() when $default != null:
return $default(_that.id,_that.refId,_that.nameAr,_that.nameEn,_that.priceSnapshot);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KitchenCustomizationSnapshot implements KitchenCustomizationSnapshot {
  const _KitchenCustomizationSnapshot({required this.id, this.refId, required this.nameAr, required this.nameEn, required this.priceSnapshot});
  factory _KitchenCustomizationSnapshot.fromJson(Map<String, dynamic> json) => _$KitchenCustomizationSnapshotFromJson(json);

@override final  String id;
@override final  String? refId;
@override final  String nameAr;
@override final  String nameEn;
@override final  double priceSnapshot;

/// Create a copy of KitchenCustomizationSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KitchenCustomizationSnapshotCopyWith<_KitchenCustomizationSnapshot> get copyWith => __$KitchenCustomizationSnapshotCopyWithImpl<_KitchenCustomizationSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KitchenCustomizationSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KitchenCustomizationSnapshot&&(identical(other.id, id) || other.id == id)&&(identical(other.refId, refId) || other.refId == refId)&&(identical(other.nameAr, nameAr) || other.nameAr == nameAr)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.priceSnapshot, priceSnapshot) || other.priceSnapshot == priceSnapshot));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,refId,nameAr,nameEn,priceSnapshot);
}

@override
String toString() {
    return 'KitchenCustomizationSnapshot(id: $id, refId: $refId, nameAr: $nameAr, nameEn: $nameEn, priceSnapshot: $priceSnapshot)';
}


}

/// @nodoc
abstract mixin class _$KitchenCustomizationSnapshotCopyWith<$Res> implements $KitchenCustomizationSnapshotCopyWith<$Res> {
  factory _$KitchenCustomizationSnapshotCopyWith(_KitchenCustomizationSnapshot value, $Res Function(_KitchenCustomizationSnapshot) _then) = __$KitchenCustomizationSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String id, String? refId, String nameAr, String nameEn, double priceSnapshot
});




}
/// @nodoc
class __$KitchenCustomizationSnapshotCopyWithImpl<$Res>
    implements _$KitchenCustomizationSnapshotCopyWith<$Res> {
  __$KitchenCustomizationSnapshotCopyWithImpl(this._self, this._then);

  final _KitchenCustomizationSnapshot _self;
  final $Res Function(_KitchenCustomizationSnapshot) _then;

/// Create a copy of KitchenCustomizationSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? refId = freezed,Object? nameAr = null,Object? nameEn = null,Object? priceSnapshot = null,}) {
  return _then(_KitchenCustomizationSnapshot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,refId: freezed == refId ? _self.refId : refId // ignore: cast_nullable_to_non_nullable
as String?,nameAr: null == nameAr ? _self.nameAr : nameAr // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,priceSnapshot: null == priceSnapshot ? _self.priceSnapshot : priceSnapshot // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
