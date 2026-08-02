// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) {
  return _MenuItem.fromJson(json);
}

/// @nodoc
mixin _$MenuItem {
  String get id => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  double get basePrice => throw _privateConstructorUsedError;
  double? get discountPrice => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  bool get isFeatured => throw _privateConstructorUsedError;
  bool get isBestSeller => throw _privateConstructorUsedError;
  int get prepTimeMinutes => throw _privateConstructorUsedError;
  List<ModifierGroup> get modifierGroups => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  int? get calories => throw _privateConstructorUsedError;
  double? get compareAtPrice => throw _privateConstructorUsedError;
  MenuItemBadge? get badge => throw _privateConstructorUsedError;
  List<MenuItem> get oftenOrderedWith => throw _privateConstructorUsedError;

  /// Serializes this MenuItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuItemCopyWith<MenuItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuItemCopyWith<$Res> {
  factory $MenuItemCopyWith(MenuItem value, $Res Function(MenuItem) then) =
      _$MenuItemCopyWithImpl<$Res, MenuItem>;
  @useResult
  $Res call({
    String id,
    String categoryId,
    String name,
    String description,
    String imageUrl,
    double basePrice,
    double? discountPrice,
    bool isAvailable,
    bool isFeatured,
    bool isBestSeller,
    int prepTimeMinutes,
    List<ModifierGroup> modifierGroups,
    int sortOrder,
    int? calories,
    double? compareAtPrice,
    MenuItemBadge? badge,
    List<MenuItem> oftenOrderedWith,
  });
}

/// @nodoc
class _$MenuItemCopyWithImpl<$Res, $Val extends MenuItem>
    implements $MenuItemCopyWith<$Res> {
  _$MenuItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = null,
    Object? name = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? basePrice = null,
    Object? discountPrice = freezed,
    Object? isAvailable = null,
    Object? isFeatured = null,
    Object? isBestSeller = null,
    Object? prepTimeMinutes = null,
    Object? modifierGroups = null,
    Object? sortOrder = null,
    Object? calories = freezed,
    Object? compareAtPrice = freezed,
    Object? badge = freezed,
    Object? oftenOrderedWith = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            categoryId: null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            basePrice: null == basePrice
                ? _value.basePrice
                : basePrice // ignore: cast_nullable_to_non_nullable
                      as double,
            discountPrice: freezed == discountPrice
                ? _value.discountPrice
                : discountPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFeatured: null == isFeatured
                ? _value.isFeatured
                : isFeatured // ignore: cast_nullable_to_non_nullable
                      as bool,
            isBestSeller: null == isBestSeller
                ? _value.isBestSeller
                : isBestSeller // ignore: cast_nullable_to_non_nullable
                      as bool,
            prepTimeMinutes: null == prepTimeMinutes
                ? _value.prepTimeMinutes
                : prepTimeMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            modifierGroups: null == modifierGroups
                ? _value.modifierGroups
                : modifierGroups // ignore: cast_nullable_to_non_nullable
                      as List<ModifierGroup>,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            calories: freezed == calories
                ? _value.calories
                : calories // ignore: cast_nullable_to_non_nullable
                      as int?,
            compareAtPrice: freezed == compareAtPrice
                ? _value.compareAtPrice
                : compareAtPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            badge: freezed == badge
                ? _value.badge
                : badge // ignore: cast_nullable_to_non_nullable
                      as MenuItemBadge?,
            oftenOrderedWith: null == oftenOrderedWith
                ? _value.oftenOrderedWith
                : oftenOrderedWith // ignore: cast_nullable_to_non_nullable
                      as List<MenuItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MenuItemImplCopyWith<$Res>
    implements $MenuItemCopyWith<$Res> {
  factory _$$MenuItemImplCopyWith(
    _$MenuItemImpl value,
    $Res Function(_$MenuItemImpl) then,
  ) = __$$MenuItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String categoryId,
    String name,
    String description,
    String imageUrl,
    double basePrice,
    double? discountPrice,
    bool isAvailable,
    bool isFeatured,
    bool isBestSeller,
    int prepTimeMinutes,
    List<ModifierGroup> modifierGroups,
    int sortOrder,
    int? calories,
    double? compareAtPrice,
    MenuItemBadge? badge,
    List<MenuItem> oftenOrderedWith,
  });
}

/// @nodoc
class __$$MenuItemImplCopyWithImpl<$Res>
    extends _$MenuItemCopyWithImpl<$Res, _$MenuItemImpl>
    implements _$$MenuItemImplCopyWith<$Res> {
  __$$MenuItemImplCopyWithImpl(
    _$MenuItemImpl _value,
    $Res Function(_$MenuItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = null,
    Object? name = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? basePrice = null,
    Object? discountPrice = freezed,
    Object? isAvailable = null,
    Object? isFeatured = null,
    Object? isBestSeller = null,
    Object? prepTimeMinutes = null,
    Object? modifierGroups = null,
    Object? sortOrder = null,
    Object? calories = freezed,
    Object? compareAtPrice = freezed,
    Object? badge = freezed,
    Object? oftenOrderedWith = null,
  }) {
    return _then(
      _$MenuItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        categoryId: null == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        basePrice: null == basePrice
            ? _value.basePrice
            : basePrice // ignore: cast_nullable_to_non_nullable
                  as double,
        discountPrice: freezed == discountPrice
            ? _value.discountPrice
            : discountPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFeatured: null == isFeatured
            ? _value.isFeatured
            : isFeatured // ignore: cast_nullable_to_non_nullable
                  as bool,
        isBestSeller: null == isBestSeller
            ? _value.isBestSeller
            : isBestSeller // ignore: cast_nullable_to_non_nullable
                  as bool,
        prepTimeMinutes: null == prepTimeMinutes
            ? _value.prepTimeMinutes
            : prepTimeMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        modifierGroups: null == modifierGroups
            ? _value._modifierGroups
            : modifierGroups // ignore: cast_nullable_to_non_nullable
                  as List<ModifierGroup>,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        calories: freezed == calories
            ? _value.calories
            : calories // ignore: cast_nullable_to_non_nullable
                  as int?,
        compareAtPrice: freezed == compareAtPrice
            ? _value.compareAtPrice
            : compareAtPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        badge: freezed == badge
            ? _value.badge
            : badge // ignore: cast_nullable_to_non_nullable
                  as MenuItemBadge?,
        oftenOrderedWith: null == oftenOrderedWith
            ? _value._oftenOrderedWith
            : oftenOrderedWith // ignore: cast_nullable_to_non_nullable
                  as List<MenuItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MenuItemImpl implements _MenuItem {
  const _$MenuItemImpl({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.basePrice,
    this.discountPrice,
    this.isAvailable = true,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.prepTimeMinutes = 15,
    final List<ModifierGroup> modifierGroups = const [],
    this.sortOrder = 0,
    this.calories,
    this.compareAtPrice,
    this.badge,
    final List<MenuItem> oftenOrderedWith = const [],
  }) : _modifierGroups = modifierGroups,
       _oftenOrderedWith = oftenOrderedWith;

  factory _$MenuItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenuItemImplFromJson(json);

  @override
  final String id;
  @override
  final String categoryId;
  @override
  final String name;
  @override
  final String description;
  @override
  final String imageUrl;
  @override
  final double basePrice;
  @override
  final double? discountPrice;
  @override
  @JsonKey()
  final bool isAvailable;
  @override
  @JsonKey()
  final bool isFeatured;
  @override
  @JsonKey()
  final bool isBestSeller;
  @override
  @JsonKey()
  final int prepTimeMinutes;
  final List<ModifierGroup> _modifierGroups;
  @override
  @JsonKey()
  List<ModifierGroup> get modifierGroups {
    if (_modifierGroups is EqualUnmodifiableListView) return _modifierGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_modifierGroups);
  }

  @override
  @JsonKey()
  final int sortOrder;
  @override
  final int? calories;
  @override
  final double? compareAtPrice;
  @override
  final MenuItemBadge? badge;
  final List<MenuItem> _oftenOrderedWith;
  @override
  @JsonKey()
  List<MenuItem> get oftenOrderedWith {
    if (_oftenOrderedWith is EqualUnmodifiableListView)
      return _oftenOrderedWith;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_oftenOrderedWith);
  }

  @override
  String toString() {
    return 'MenuItem(id: $id, categoryId: $categoryId, name: $name, description: $description, imageUrl: $imageUrl, basePrice: $basePrice, discountPrice: $discountPrice, isAvailable: $isAvailable, isFeatured: $isFeatured, isBestSeller: $isBestSeller, prepTimeMinutes: $prepTimeMinutes, modifierGroups: $modifierGroups, sortOrder: $sortOrder, calories: $calories, compareAtPrice: $compareAtPrice, badge: $badge, oftenOrderedWith: $oftenOrderedWith)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.discountPrice, discountPrice) ||
                other.discountPrice == discountPrice) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.isBestSeller, isBestSeller) ||
                other.isBestSeller == isBestSeller) &&
            (identical(other.prepTimeMinutes, prepTimeMinutes) ||
                other.prepTimeMinutes == prepTimeMinutes) &&
            const DeepCollectionEquality().equals(
              other._modifierGroups,
              _modifierGroups,
            ) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.compareAtPrice, compareAtPrice) ||
                other.compareAtPrice == compareAtPrice) &&
            (identical(other.badge, badge) || other.badge == badge) &&
            const DeepCollectionEquality().equals(
              other._oftenOrderedWith,
              _oftenOrderedWith,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    categoryId,
    name,
    description,
    imageUrl,
    basePrice,
    discountPrice,
    isAvailable,
    isFeatured,
    isBestSeller,
    prepTimeMinutes,
    const DeepCollectionEquality().hash(_modifierGroups),
    sortOrder,
    calories,
    compareAtPrice,
    badge,
    const DeepCollectionEquality().hash(_oftenOrderedWith),
  );

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuItemImplCopyWith<_$MenuItemImpl> get copyWith =>
      __$$MenuItemImplCopyWithImpl<_$MenuItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenuItemImplToJson(this);
  }
}

abstract class _MenuItem implements MenuItem {
  const factory _MenuItem({
    required final String id,
    required final String categoryId,
    required final String name,
    required final String description,
    required final String imageUrl,
    required final double basePrice,
    final double? discountPrice,
    final bool isAvailable,
    final bool isFeatured,
    final bool isBestSeller,
    final int prepTimeMinutes,
    final List<ModifierGroup> modifierGroups,
    final int sortOrder,
    final int? calories,
    final double? compareAtPrice,
    final MenuItemBadge? badge,
    final List<MenuItem> oftenOrderedWith,
  }) = _$MenuItemImpl;

  factory _MenuItem.fromJson(Map<String, dynamic> json) =
      _$MenuItemImpl.fromJson;

  @override
  String get id;
  @override
  String get categoryId;
  @override
  String get name;
  @override
  String get description;
  @override
  String get imageUrl;
  @override
  double get basePrice;
  @override
  double? get discountPrice;
  @override
  bool get isAvailable;
  @override
  bool get isFeatured;
  @override
  bool get isBestSeller;
  @override
  int get prepTimeMinutes;
  @override
  List<ModifierGroup> get modifierGroups;
  @override
  int get sortOrder;
  @override
  int? get calories;
  @override
  double? get compareAtPrice;
  @override
  MenuItemBadge? get badge;
  @override
  List<MenuItem> get oftenOrderedWith;

  /// Create a copy of MenuItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuItemImplCopyWith<_$MenuItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModifierGroup _$ModifierGroupFromJson(Map<String, dynamic> json) {
  return _ModifierGroup.fromJson(json);
}

/// @nodoc
mixin _$ModifierGroup {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get isRequired => throw _privateConstructorUsedError;
  String get selectionType =>
      throw _privateConstructorUsedError; // SINGLE, MULTIPLE, QUANTITY
  int get minSelections => throw _privateConstructorUsedError;
  int get maxSelections => throw _privateConstructorUsedError;
  List<ModifierOption> get options => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;

  /// Serializes this ModifierGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModifierGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModifierGroupCopyWith<ModifierGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModifierGroupCopyWith<$Res> {
  factory $ModifierGroupCopyWith(
    ModifierGroup value,
    $Res Function(ModifierGroup) then,
  ) = _$ModifierGroupCopyWithImpl<$Res, ModifierGroup>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    bool isRequired,
    String selectionType,
    int minSelections,
    int maxSelections,
    List<ModifierOption> options,
    int sortOrder,
  });
}

/// @nodoc
class _$ModifierGroupCopyWithImpl<$Res, $Val extends ModifierGroup>
    implements $ModifierGroupCopyWith<$Res> {
  _$ModifierGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModifierGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? isRequired = null,
    Object? selectionType = null,
    Object? minSelections = null,
    Object? maxSelections = null,
    Object? options = null,
    Object? sortOrder = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            isRequired: null == isRequired
                ? _value.isRequired
                : isRequired // ignore: cast_nullable_to_non_nullable
                      as bool,
            selectionType: null == selectionType
                ? _value.selectionType
                : selectionType // ignore: cast_nullable_to_non_nullable
                      as String,
            minSelections: null == minSelections
                ? _value.minSelections
                : minSelections // ignore: cast_nullable_to_non_nullable
                      as int,
            maxSelections: null == maxSelections
                ? _value.maxSelections
                : maxSelections // ignore: cast_nullable_to_non_nullable
                      as int,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<ModifierOption>,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ModifierGroupImplCopyWith<$Res>
    implements $ModifierGroupCopyWith<$Res> {
  factory _$$ModifierGroupImplCopyWith(
    _$ModifierGroupImpl value,
    $Res Function(_$ModifierGroupImpl) then,
  ) = __$$ModifierGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    bool isRequired,
    String selectionType,
    int minSelections,
    int maxSelections,
    List<ModifierOption> options,
    int sortOrder,
  });
}

/// @nodoc
class __$$ModifierGroupImplCopyWithImpl<$Res>
    extends _$ModifierGroupCopyWithImpl<$Res, _$ModifierGroupImpl>
    implements _$$ModifierGroupImplCopyWith<$Res> {
  __$$ModifierGroupImplCopyWithImpl(
    _$ModifierGroupImpl _value,
    $Res Function(_$ModifierGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ModifierGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? isRequired = null,
    Object? selectionType = null,
    Object? minSelections = null,
    Object? maxSelections = null,
    Object? options = null,
    Object? sortOrder = null,
  }) {
    return _then(
      _$ModifierGroupImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        isRequired: null == isRequired
            ? _value.isRequired
            : isRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
        selectionType: null == selectionType
            ? _value.selectionType
            : selectionType // ignore: cast_nullable_to_non_nullable
                  as String,
        minSelections: null == minSelections
            ? _value.minSelections
            : minSelections // ignore: cast_nullable_to_non_nullable
                  as int,
        maxSelections: null == maxSelections
            ? _value.maxSelections
            : maxSelections // ignore: cast_nullable_to_non_nullable
                  as int,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<ModifierOption>,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ModifierGroupImpl implements _ModifierGroup {
  const _$ModifierGroupImpl({
    required this.id,
    required this.name,
    this.description,
    this.isRequired = false,
    this.selectionType = 'SINGLE',
    this.minSelections = 0,
    this.maxSelections = 1,
    final List<ModifierOption> options = const [],
    this.sortOrder = 0,
  }) : _options = options;

  factory _$ModifierGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModifierGroupImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey()
  final bool isRequired;
  @override
  @JsonKey()
  final String selectionType;
  // SINGLE, MULTIPLE, QUANTITY
  @override
  @JsonKey()
  final int minSelections;
  @override
  @JsonKey()
  final int maxSelections;
  final List<ModifierOption> _options;
  @override
  @JsonKey()
  List<ModifierOption> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  @JsonKey()
  final int sortOrder;

  @override
  String toString() {
    return 'ModifierGroup(id: $id, name: $name, description: $description, isRequired: $isRequired, selectionType: $selectionType, minSelections: $minSelections, maxSelections: $maxSelections, options: $options, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModifierGroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isRequired, isRequired) ||
                other.isRequired == isRequired) &&
            (identical(other.selectionType, selectionType) ||
                other.selectionType == selectionType) &&
            (identical(other.minSelections, minSelections) ||
                other.minSelections == minSelections) &&
            (identical(other.maxSelections, maxSelections) ||
                other.maxSelections == maxSelections) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    isRequired,
    selectionType,
    minSelections,
    maxSelections,
    const DeepCollectionEquality().hash(_options),
    sortOrder,
  );

  /// Create a copy of ModifierGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModifierGroupImplCopyWith<_$ModifierGroupImpl> get copyWith =>
      __$$ModifierGroupImplCopyWithImpl<_$ModifierGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ModifierGroupImplToJson(this);
  }
}

abstract class _ModifierGroup implements ModifierGroup {
  const factory _ModifierGroup({
    required final String id,
    required final String name,
    final String? description,
    final bool isRequired,
    final String selectionType,
    final int minSelections,
    final int maxSelections,
    final List<ModifierOption> options,
    final int sortOrder,
  }) = _$ModifierGroupImpl;

  factory _ModifierGroup.fromJson(Map<String, dynamic> json) =
      _$ModifierGroupImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  bool get isRequired;
  @override
  String get selectionType; // SINGLE, MULTIPLE, QUANTITY
  @override
  int get minSelections;
  @override
  int get maxSelections;
  @override
  List<ModifierOption> get options;
  @override
  int get sortOrder;

  /// Create a copy of ModifierGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModifierGroupImplCopyWith<_$ModifierGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ModifierOption _$ModifierOptionFromJson(Map<String, dynamic> json) {
  return _ModifierOption.fromJson(json);
}

/// @nodoc
mixin _$ModifierOption {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  double get priceModifier => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  List<ModifierGroup> get nestedModifierGroups =>
      throw _privateConstructorUsedError;

  /// Serializes this ModifierOption to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ModifierOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ModifierOptionCopyWith<ModifierOption> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ModifierOptionCopyWith<$Res> {
  factory $ModifierOptionCopyWith(
    ModifierOption value,
    $Res Function(ModifierOption) then,
  ) = _$ModifierOptionCopyWithImpl<$Res, ModifierOption>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String? image,
    double priceModifier,
    bool isDefault,
    bool isAvailable,
    List<ModifierGroup> nestedModifierGroups,
  });
}

/// @nodoc
class _$ModifierOptionCopyWithImpl<$Res, $Val extends ModifierOption>
    implements $ModifierOptionCopyWith<$Res> {
  _$ModifierOptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ModifierOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? image = freezed,
    Object? priceModifier = null,
    Object? isDefault = null,
    Object? isAvailable = null,
    Object? nestedModifierGroups = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            image: freezed == image
                ? _value.image
                : image // ignore: cast_nullable_to_non_nullable
                      as String?,
            priceModifier: null == priceModifier
                ? _value.priceModifier
                : priceModifier // ignore: cast_nullable_to_non_nullable
                      as double,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            isAvailable: null == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            nestedModifierGroups: null == nestedModifierGroups
                ? _value.nestedModifierGroups
                : nestedModifierGroups // ignore: cast_nullable_to_non_nullable
                      as List<ModifierGroup>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ModifierOptionImplCopyWith<$Res>
    implements $ModifierOptionCopyWith<$Res> {
  factory _$$ModifierOptionImplCopyWith(
    _$ModifierOptionImpl value,
    $Res Function(_$ModifierOptionImpl) then,
  ) = __$$ModifierOptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String? image,
    double priceModifier,
    bool isDefault,
    bool isAvailable,
    List<ModifierGroup> nestedModifierGroups,
  });
}

/// @nodoc
class __$$ModifierOptionImplCopyWithImpl<$Res>
    extends _$ModifierOptionCopyWithImpl<$Res, _$ModifierOptionImpl>
    implements _$$ModifierOptionImplCopyWith<$Res> {
  __$$ModifierOptionImplCopyWithImpl(
    _$ModifierOptionImpl _value,
    $Res Function(_$ModifierOptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ModifierOption
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? image = freezed,
    Object? priceModifier = null,
    Object? isDefault = null,
    Object? isAvailable = null,
    Object? nestedModifierGroups = null,
  }) {
    return _then(
      _$ModifierOptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        image: freezed == image
            ? _value.image
            : image // ignore: cast_nullable_to_non_nullable
                  as String?,
        priceModifier: null == priceModifier
            ? _value.priceModifier
            : priceModifier // ignore: cast_nullable_to_non_nullable
                  as double,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        isAvailable: null == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        nestedModifierGroups: null == nestedModifierGroups
            ? _value._nestedModifierGroups
            : nestedModifierGroups // ignore: cast_nullable_to_non_nullable
                  as List<ModifierGroup>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ModifierOptionImpl implements _ModifierOption {
  const _$ModifierOptionImpl({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.priceModifier = 0.0,
    this.isDefault = false,
    this.isAvailable = true,
    final List<ModifierGroup> nestedModifierGroups = const [],
  }) : _nestedModifierGroups = nestedModifierGroups;

  factory _$ModifierOptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ModifierOptionImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? image;
  @override
  @JsonKey()
  final double priceModifier;
  @override
  @JsonKey()
  final bool isDefault;
  @override
  @JsonKey()
  final bool isAvailable;
  final List<ModifierGroup> _nestedModifierGroups;
  @override
  @JsonKey()
  List<ModifierGroup> get nestedModifierGroups {
    if (_nestedModifierGroups is EqualUnmodifiableListView)
      return _nestedModifierGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nestedModifierGroups);
  }

  @override
  String toString() {
    return 'ModifierOption(id: $id, name: $name, description: $description, image: $image, priceModifier: $priceModifier, isDefault: $isDefault, isAvailable: $isAvailable, nestedModifierGroups: $nestedModifierGroups)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ModifierOptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.priceModifier, priceModifier) ||
                other.priceModifier == priceModifier) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            const DeepCollectionEquality().equals(
              other._nestedModifierGroups,
              _nestedModifierGroups,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    image,
    priceModifier,
    isDefault,
    isAvailable,
    const DeepCollectionEquality().hash(_nestedModifierGroups),
  );

  /// Create a copy of ModifierOption
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ModifierOptionImplCopyWith<_$ModifierOptionImpl> get copyWith =>
      __$$ModifierOptionImplCopyWithImpl<_$ModifierOptionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ModifierOptionImplToJson(this);
  }
}

abstract class _ModifierOption implements ModifierOption {
  const factory _ModifierOption({
    required final String id,
    required final String name,
    final String? description,
    final String? image,
    final double priceModifier,
    final bool isDefault,
    final bool isAvailable,
    final List<ModifierGroup> nestedModifierGroups,
  }) = _$ModifierOptionImpl;

  factory _ModifierOption.fromJson(Map<String, dynamic> json) =
      _$ModifierOptionImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get image;
  @override
  double get priceModifier;
  @override
  bool get isDefault;
  @override
  bool get isAvailable;
  @override
  List<ModifierGroup> get nestedModifierGroups;

  /// Create a copy of ModifierOption
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ModifierOptionImplCopyWith<_$ModifierOptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
