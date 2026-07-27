// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cart.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Cart _$CartFromJson(Map<String, dynamic> json) {
  return _Cart.fromJson(json);
}

/// @nodoc
mixin _$Cart {
  String get id => throw _privateConstructorUsedError;
  List<CartItem> get items => throw _privateConstructorUsedError;
  String? get promoCodeId => throw _privateConstructorUsedError;
  int get loyaltyPointsApplied => throw _privateConstructorUsedError;
  double get deliveryFee => throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get discountTotal => throw _privateConstructorUsedError;
  double get taxTotal => throw _privateConstructorUsedError;
  double get grandTotal => throw _privateConstructorUsedError;

  /// Serializes this Cart to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartCopyWith<Cart> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartCopyWith<$Res> {
  factory $CartCopyWith(Cart value, $Res Function(Cart) then) =
      _$CartCopyWithImpl<$Res, Cart>;
  @useResult
  $Res call({
    String id,
    List<CartItem> items,
    String? promoCodeId,
    int loyaltyPointsApplied,
    double deliveryFee,
    double subtotal,
    double discountTotal,
    double taxTotal,
    double grandTotal,
  });
}

/// @nodoc
class _$CartCopyWithImpl<$Res, $Val extends Cart>
    implements $CartCopyWith<$Res> {
  _$CartCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? items = null,
    Object? promoCodeId = freezed,
    Object? loyaltyPointsApplied = null,
    Object? deliveryFee = null,
    Object? subtotal = null,
    Object? discountTotal = null,
    Object? taxTotal = null,
    Object? grandTotal = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<CartItem>,
            promoCodeId: freezed == promoCodeId
                ? _value.promoCodeId
                : promoCodeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            loyaltyPointsApplied: null == loyaltyPointsApplied
                ? _value.loyaltyPointsApplied
                : loyaltyPointsApplied // ignore: cast_nullable_to_non_nullable
                      as int,
            deliveryFee: null == deliveryFee
                ? _value.deliveryFee
                : deliveryFee // ignore: cast_nullable_to_non_nullable
                      as double,
            subtotal: null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                      as double,
            discountTotal: null == discountTotal
                ? _value.discountTotal
                : discountTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            taxTotal: null == taxTotal
                ? _value.taxTotal
                : taxTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            grandTotal: null == grandTotal
                ? _value.grandTotal
                : grandTotal // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CartImplCopyWith<$Res> implements $CartCopyWith<$Res> {
  factory _$$CartImplCopyWith(
    _$CartImpl value,
    $Res Function(_$CartImpl) then,
  ) = __$$CartImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    List<CartItem> items,
    String? promoCodeId,
    int loyaltyPointsApplied,
    double deliveryFee,
    double subtotal,
    double discountTotal,
    double taxTotal,
    double grandTotal,
  });
}

/// @nodoc
class __$$CartImplCopyWithImpl<$Res>
    extends _$CartCopyWithImpl<$Res, _$CartImpl>
    implements _$$CartImplCopyWith<$Res> {
  __$$CartImplCopyWithImpl(_$CartImpl _value, $Res Function(_$CartImpl) _then)
    : super(_value, _then);

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? items = null,
    Object? promoCodeId = freezed,
    Object? loyaltyPointsApplied = null,
    Object? deliveryFee = null,
    Object? subtotal = null,
    Object? discountTotal = null,
    Object? taxTotal = null,
    Object? grandTotal = null,
  }) {
    return _then(
      _$CartImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<CartItem>,
        promoCodeId: freezed == promoCodeId
            ? _value.promoCodeId
            : promoCodeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        loyaltyPointsApplied: null == loyaltyPointsApplied
            ? _value.loyaltyPointsApplied
            : loyaltyPointsApplied // ignore: cast_nullable_to_non_nullable
                  as int,
        deliveryFee: null == deliveryFee
            ? _value.deliveryFee
            : deliveryFee // ignore: cast_nullable_to_non_nullable
                  as double,
        subtotal: null == subtotal
            ? _value.subtotal
            : subtotal // ignore: cast_nullable_to_non_nullable
                  as double,
        discountTotal: null == discountTotal
            ? _value.discountTotal
            : discountTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        taxTotal: null == taxTotal
            ? _value.taxTotal
            : taxTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        grandTotal: null == grandTotal
            ? _value.grandTotal
            : grandTotal // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CartImpl implements _Cart {
  const _$CartImpl({
    required this.id,
    final List<CartItem> items = const [],
    this.promoCodeId,
    this.loyaltyPointsApplied = 0,
    this.deliveryFee = 0.0,
    this.subtotal = 0.0,
    this.discountTotal = 0.0,
    this.taxTotal = 0.0,
    this.grandTotal = 0.0,
  }) : _items = items;

  factory _$CartImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartImplFromJson(json);

  @override
  final String id;
  final List<CartItem> _items;
  @override
  @JsonKey()
  List<CartItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? promoCodeId;
  @override
  @JsonKey()
  final int loyaltyPointsApplied;
  @override
  @JsonKey()
  final double deliveryFee;
  @override
  @JsonKey()
  final double subtotal;
  @override
  @JsonKey()
  final double discountTotal;
  @override
  @JsonKey()
  final double taxTotal;
  @override
  @JsonKey()
  final double grandTotal;

  @override
  String toString() {
    return 'Cart(id: $id, items: $items, promoCodeId: $promoCodeId, loyaltyPointsApplied: $loyaltyPointsApplied, deliveryFee: $deliveryFee, subtotal: $subtotal, discountTotal: $discountTotal, taxTotal: $taxTotal, grandTotal: $grandTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.promoCodeId, promoCodeId) ||
                other.promoCodeId == promoCodeId) &&
            (identical(other.loyaltyPointsApplied, loyaltyPointsApplied) ||
                other.loyaltyPointsApplied == loyaltyPointsApplied) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.discountTotal, discountTotal) ||
                other.discountTotal == discountTotal) &&
            (identical(other.taxTotal, taxTotal) ||
                other.taxTotal == taxTotal) &&
            (identical(other.grandTotal, grandTotal) ||
                other.grandTotal == grandTotal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_items),
    promoCodeId,
    loyaltyPointsApplied,
    deliveryFee,
    subtotal,
    discountTotal,
    taxTotal,
    grandTotal,
  );

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartImplCopyWith<_$CartImpl> get copyWith =>
      __$$CartImplCopyWithImpl<_$CartImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartImplToJson(this);
  }
}

abstract class _Cart implements Cart {
  const factory _Cart({
    required final String id,
    final List<CartItem> items,
    final String? promoCodeId,
    final int loyaltyPointsApplied,
    final double deliveryFee,
    final double subtotal,
    final double discountTotal,
    final double taxTotal,
    final double grandTotal,
  }) = _$CartImpl;

  factory _Cart.fromJson(Map<String, dynamic> json) = _$CartImpl.fromJson;

  @override
  String get id;
  @override
  List<CartItem> get items;
  @override
  String? get promoCodeId;
  @override
  int get loyaltyPointsApplied;
  @override
  double get deliveryFee;
  @override
  double get subtotal;
  @override
  double get discountTotal;
  @override
  double get taxTotal;
  @override
  double get grandTotal;

  /// Create a copy of Cart
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartImplCopyWith<_$CartImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CartItem _$CartItemFromJson(Map<String, dynamic> json) {
  return _CartItem.fromJson(json);
}

/// @nodoc
mixin _$CartItem {
  String get id => throw _privateConstructorUsedError;
  String get menuItemId => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  String get productImage => throw _privateConstructorUsedError;
  double get basePrice => throw _privateConstructorUsedError;
  int get quantity => throw _privateConstructorUsedError;
  Map<String, List<String>> get selectedOptions =>
      throw _privateConstructorUsedError; // groupId -> list of optionIds
  Map<String, Map<String, List<String>>> get nestedSelections =>
      throw _privateConstructorUsedError; // optionId -> (groupId -> list of nestedOptionIds)
  Map<String, int> get extraQuantities =>
      throw _privateConstructorUsedError; // optionId -> quantity
  List<String> get removedIngredients => throw _privateConstructorUsedError;
  String get specialInstructions => throw _privateConstructorUsedError;
  double get unitPrice => throw _privateConstructorUsedError;
  double get lineTotal => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;

  /// Serializes this CartItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CartItemCopyWith<CartItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CartItemCopyWith<$Res> {
  factory $CartItemCopyWith(CartItem value, $Res Function(CartItem) then) =
      _$CartItemCopyWithImpl<$Res, CartItem>;
  @useResult
  $Res call({
    String id,
    String menuItemId,
    String productName,
    String productImage,
    double basePrice,
    int quantity,
    Map<String, List<String>> selectedOptions,
    Map<String, Map<String, List<String>>> nestedSelections,
    Map<String, int> extraQuantities,
    List<String> removedIngredients,
    String specialInstructions,
    double unitPrice,
    double lineTotal,
    bool isAvailable,
  });
}

/// @nodoc
class _$CartItemCopyWithImpl<$Res, $Val extends CartItem>
    implements $CartItemCopyWith<$Res> {
  _$CartItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = null,
    Object? productName = null,
    Object? productImage = null,
    Object? basePrice = null,
    Object? quantity = null,
    Object? selectedOptions = null,
    Object? nestedSelections = null,
    Object? extraQuantities = null,
    Object? removedIngredients = null,
    Object? specialInstructions = null,
    Object? unitPrice = null,
    Object? lineTotal = null,
    Object? isAvailable = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            menuItemId: null == menuItemId
                ? _value.menuItemId
                : menuItemId // ignore: cast_nullable_to_non_nullable
                      as String,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            productImage: null == productImage
                ? _value.productImage
                : productImage // ignore: cast_nullable_to_non_nullable
                      as String,
            basePrice: null == basePrice
                ? _value.basePrice
                : basePrice // ignore: cast_nullable_to_non_nullable
                      as double,
            quantity: null == quantity
                ? _value.quantity
                : quantity // ignore: cast_nullable_to_non_nullable
                      as int,
            selectedOptions: null == selectedOptions
                ? _value.selectedOptions
                : selectedOptions // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<String>>,
            nestedSelections: null == nestedSelections
                ? _value.nestedSelections
                : nestedSelections // ignore: cast_nullable_to_non_nullable
                      as Map<String, Map<String, List<String>>>,
            extraQuantities: null == extraQuantities
                ? _value.extraQuantities
                : extraQuantities // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
            removedIngredients: null == removedIngredients
                ? _value.removedIngredients
                : removedIngredients // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            specialInstructions: null == specialInstructions
                ? _value.specialInstructions
                : specialInstructions // ignore: cast_nullable_to_non_nullable
                      as String,
            unitPrice: null == unitPrice
                ? _value.unitPrice
                : unitPrice // ignore: cast_nullable_to_non_nullable
                      as double,
            lineTotal: null == lineTotal
                ? _value.lineTotal
                : lineTotal // ignore: cast_nullable_to_non_nullable
                      as double,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CartItemImplCopyWith<$Res>
    implements $CartItemCopyWith<$Res> {
  factory _$$CartItemImplCopyWith(
    _$CartItemImpl value,
    $Res Function(_$CartItemImpl) then,
  ) = __$$CartItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String menuItemId,
    String productName,
    String productImage,
    double basePrice,
    int quantity,
    Map<String, List<String>> selectedOptions,
    Map<String, Map<String, List<String>>> nestedSelections,
    Map<String, int> extraQuantities,
    List<String> removedIngredients,
    String specialInstructions,
    double unitPrice,
    double lineTotal,
    bool isAvailable,
  });
}

/// @nodoc
class __$$CartItemImplCopyWithImpl<$Res>
    extends _$CartItemCopyWithImpl<$Res, _$CartItemImpl>
    implements _$$CartItemImplCopyWith<$Res> {
  __$$CartItemImplCopyWithImpl(
    _$CartItemImpl _value,
    $Res Function(_$CartItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = null,
    Object? productName = null,
    Object? productImage = null,
    Object? basePrice = null,
    Object? quantity = null,
    Object? selectedOptions = null,
    Object? nestedSelections = null,
    Object? extraQuantities = null,
    Object? removedIngredients = null,
    Object? specialInstructions = null,
    Object? unitPrice = null,
    Object? lineTotal = null,
    Object? isAvailable = null,
  }) {
    return _then(
      _$CartItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        menuItemId: null == menuItemId
            ? _value.menuItemId
            : menuItemId // ignore: cast_nullable_to_non_nullable
                  as String,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        productImage: null == productImage
            ? _value.productImage
            : productImage // ignore: cast_nullable_to_non_nullable
                  as String,
        basePrice: null == basePrice
            ? _value.basePrice
            : basePrice // ignore: cast_nullable_to_non_nullable
                  as double,
        quantity: null == quantity
            ? _value.quantity
            : quantity // ignore: cast_nullable_to_non_nullable
                  as int,
        selectedOptions: null == selectedOptions
            ? _value._selectedOptions
            : selectedOptions // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<String>>,
        nestedSelections: null == nestedSelections
            ? _value._nestedSelections
            : nestedSelections // ignore: cast_nullable_to_non_nullable
                  as Map<String, Map<String, List<String>>>,
        extraQuantities: null == extraQuantities
            ? _value._extraQuantities
            : extraQuantities // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
        removedIngredients: null == removedIngredients
            ? _value._removedIngredients
            : removedIngredients // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        specialInstructions: null == specialInstructions
            ? _value.specialInstructions
            : specialInstructions // ignore: cast_nullable_to_non_nullable
                  as String,
        unitPrice: null == unitPrice
            ? _value.unitPrice
            : unitPrice // ignore: cast_nullable_to_non_nullable
                  as double,
        lineTotal: null == lineTotal
            ? _value.lineTotal
            : lineTotal // ignore: cast_nullable_to_non_nullable
                  as double,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CartItemImpl extends _CartItem {
  const _$CartItemImpl({
    required this.id,
    required this.menuItemId,
    required this.productName,
    required this.productImage,
    required this.basePrice,
    required this.quantity,
    final Map<String, List<String>> selectedOptions = const {},
    final Map<String, Map<String, List<String>>> nestedSelections = const {},
    final Map<String, int> extraQuantities = const {},
    final List<String> removedIngredients = const [],
    this.specialInstructions = '',
    required this.unitPrice,
    required this.lineTotal,
    this.isAvailable = true,
  }) : _selectedOptions = selectedOptions,
       _nestedSelections = nestedSelections,
       _extraQuantities = extraQuantities,
       _removedIngredients = removedIngredients,
       super._();

  factory _$CartItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$CartItemImplFromJson(json);

  @override
  final String id;
  @override
  final String menuItemId;
  @override
  final String productName;
  @override
  final String productImage;
  @override
  final double basePrice;
  @override
  final int quantity;
  final Map<String, List<String>> _selectedOptions;
  @override
  @JsonKey()
  Map<String, List<String>> get selectedOptions {
    if (_selectedOptions is EqualUnmodifiableMapView) return _selectedOptions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_selectedOptions);
  }

  // groupId -> list of optionIds
  final Map<String, Map<String, List<String>>> _nestedSelections;
  // groupId -> list of optionIds
  @override
  @JsonKey()
  Map<String, Map<String, List<String>>> get nestedSelections {
    if (_nestedSelections is EqualUnmodifiableMapView) return _nestedSelections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_nestedSelections);
  }

  // optionId -> (groupId -> list of nestedOptionIds)
  final Map<String, int> _extraQuantities;
  // optionId -> (groupId -> list of nestedOptionIds)
  @override
  @JsonKey()
  Map<String, int> get extraQuantities {
    if (_extraQuantities is EqualUnmodifiableMapView) return _extraQuantities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_extraQuantities);
  }

  // optionId -> quantity
  final List<String> _removedIngredients;
  // optionId -> quantity
  @override
  @JsonKey()
  List<String> get removedIngredients {
    if (_removedIngredients is EqualUnmodifiableListView)
      return _removedIngredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_removedIngredients);
  }

  @override
  @JsonKey()
  final String specialInstructions;
  @override
  final double unitPrice;
  @override
  final double lineTotal;
  @override
  @JsonKey()
  final bool isAvailable;

  @override
  String toString() {
    return 'CartItem(id: $id, menuItemId: $menuItemId, productName: $productName, productImage: $productImage, basePrice: $basePrice, quantity: $quantity, selectedOptions: $selectedOptions, nestedSelections: $nestedSelections, extraQuantities: $extraQuantities, removedIngredients: $removedIngredients, specialInstructions: $specialInstructions, unitPrice: $unitPrice, lineTotal: $lineTotal, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CartItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productImage, productImage) ||
                other.productImage == productImage) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            const DeepCollectionEquality().equals(
              other._selectedOptions,
              _selectedOptions,
            ) &&
            const DeepCollectionEquality().equals(
              other._nestedSelections,
              _nestedSelections,
            ) &&
            const DeepCollectionEquality().equals(
              other._extraQuantities,
              _extraQuantities,
            ) &&
            const DeepCollectionEquality().equals(
              other._removedIngredients,
              _removedIngredients,
            ) &&
            (identical(other.specialInstructions, specialInstructions) ||
                other.specialInstructions == specialInstructions) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.lineTotal, lineTotal) ||
                other.lineTotal == lineTotal) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    menuItemId,
    productName,
    productImage,
    basePrice,
    quantity,
    const DeepCollectionEquality().hash(_selectedOptions),
    const DeepCollectionEquality().hash(_nestedSelections),
    const DeepCollectionEquality().hash(_extraQuantities),
    const DeepCollectionEquality().hash(_removedIngredients),
    specialInstructions,
    unitPrice,
    lineTotal,
    isAvailable,
  );

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      __$$CartItemImplCopyWithImpl<_$CartItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CartItemImplToJson(this);
  }
}

abstract class _CartItem extends CartItem {
  const factory _CartItem({
    required final String id,
    required final String menuItemId,
    required final String productName,
    required final String productImage,
    required final double basePrice,
    required final int quantity,
    final Map<String, List<String>> selectedOptions,
    final Map<String, Map<String, List<String>>> nestedSelections,
    final Map<String, int> extraQuantities,
    final List<String> removedIngredients,
    final String specialInstructions,
    required final double unitPrice,
    required final double lineTotal,
    final bool isAvailable,
  }) = _$CartItemImpl;
  const _CartItem._() : super._();

  factory _CartItem.fromJson(Map<String, dynamic> json) =
      _$CartItemImpl.fromJson;

  @override
  String get id;
  @override
  String get menuItemId;
  @override
  String get productName;
  @override
  String get productImage;
  @override
  double get basePrice;
  @override
  int get quantity;
  @override
  Map<String, List<String>> get selectedOptions; // groupId -> list of optionIds
  @override
  Map<String, Map<String, List<String>>> get nestedSelections; // optionId -> (groupId -> list of nestedOptionIds)
  @override
  Map<String, int> get extraQuantities; // optionId -> quantity
  @override
  List<String> get removedIngredients;
  @override
  String get specialInstructions;
  @override
  double get unitPrice;
  @override
  double get lineTotal;
  @override
  bool get isAvailable;

  /// Create a copy of CartItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CartItemImplCopyWith<_$CartItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
