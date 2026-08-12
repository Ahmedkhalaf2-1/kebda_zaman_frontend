// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menu_offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MenuOfferMenuItemSummary {
  String get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  double? get basePrice => throw _privateConstructorUsedError;
  bool? get isAvailable => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;

  /// Create a copy of MenuOfferMenuItemSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuOfferMenuItemSummaryCopyWith<MenuOfferMenuItemSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuOfferMenuItemSummaryCopyWith<$Res> {
  factory $MenuOfferMenuItemSummaryCopyWith(
    MenuOfferMenuItemSummary value,
    $Res Function(MenuOfferMenuItemSummary) then,
  ) = _$MenuOfferMenuItemSummaryCopyWithImpl<$Res, MenuOfferMenuItemSummary>;
  @useResult
  $Res call({
    String id,
    String? name,
    String? imageUrl,
    double? basePrice,
    bool? isAvailable,
    String? categoryId,
  });
}

/// @nodoc
class _$MenuOfferMenuItemSummaryCopyWithImpl<
  $Res,
  $Val extends MenuOfferMenuItemSummary
>
    implements $MenuOfferMenuItemSummaryCopyWith<$Res> {
  _$MenuOfferMenuItemSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuOfferMenuItemSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? imageUrl = freezed,
    Object? basePrice = freezed,
    Object? isAvailable = freezed,
    Object? categoryId = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            basePrice: freezed == basePrice
                ? _value.basePrice
                : basePrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            isAvailable: freezed == isAvailable
                ? _value.isAvailable
                : isAvailable // ignore: cast_nullable_to_non_nullable
                      as bool?,
            categoryId: freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MenuOfferMenuItemSummaryImplCopyWith<$Res>
    implements $MenuOfferMenuItemSummaryCopyWith<$Res> {
  factory _$$MenuOfferMenuItemSummaryImplCopyWith(
    _$MenuOfferMenuItemSummaryImpl value,
    $Res Function(_$MenuOfferMenuItemSummaryImpl) then,
  ) = __$$MenuOfferMenuItemSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? name,
    String? imageUrl,
    double? basePrice,
    bool? isAvailable,
    String? categoryId,
  });
}

/// @nodoc
class __$$MenuOfferMenuItemSummaryImplCopyWithImpl<$Res>
    extends
        _$MenuOfferMenuItemSummaryCopyWithImpl<
          $Res,
          _$MenuOfferMenuItemSummaryImpl
        >
    implements _$$MenuOfferMenuItemSummaryImplCopyWith<$Res> {
  __$$MenuOfferMenuItemSummaryImplCopyWithImpl(
    _$MenuOfferMenuItemSummaryImpl _value,
    $Res Function(_$MenuOfferMenuItemSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MenuOfferMenuItemSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? imageUrl = freezed,
    Object? basePrice = freezed,
    Object? isAvailable = freezed,
    Object? categoryId = freezed,
  }) {
    return _then(
      _$MenuOfferMenuItemSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        basePrice: freezed == basePrice
            ? _value.basePrice
            : basePrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        isAvailable: freezed == isAvailable
            ? _value.isAvailable
            : isAvailable // ignore: cast_nullable_to_non_nullable
                  as bool?,
        categoryId: freezed == categoryId
            ? _value.categoryId
            : categoryId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$MenuOfferMenuItemSummaryImpl implements _MenuOfferMenuItemSummary {
  const _$MenuOfferMenuItemSummaryImpl({
    required this.id,
    this.name,
    this.imageUrl,
    this.basePrice,
    this.isAvailable,
    this.categoryId,
  });

  @override
  final String id;
  @override
  final String? name;
  @override
  final String? imageUrl;
  @override
  final double? basePrice;
  @override
  final bool? isAvailable;
  @override
  final String? categoryId;

  @override
  String toString() {
    return 'MenuOfferMenuItemSummary(id: $id, name: $name, imageUrl: $imageUrl, basePrice: $basePrice, isAvailable: $isAvailable, categoryId: $categoryId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuOfferMenuItemSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.basePrice, basePrice) ||
                other.basePrice == basePrice) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    imageUrl,
    basePrice,
    isAvailable,
    categoryId,
  );

  /// Create a copy of MenuOfferMenuItemSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuOfferMenuItemSummaryImplCopyWith<_$MenuOfferMenuItemSummaryImpl>
  get copyWith =>
      __$$MenuOfferMenuItemSummaryImplCopyWithImpl<
        _$MenuOfferMenuItemSummaryImpl
      >(this, _$identity);
}

abstract class _MenuOfferMenuItemSummary implements MenuOfferMenuItemSummary {
  const factory _MenuOfferMenuItemSummary({
    required final String id,
    final String? name,
    final String? imageUrl,
    final double? basePrice,
    final bool? isAvailable,
    final String? categoryId,
  }) = _$MenuOfferMenuItemSummaryImpl;

  @override
  String get id;
  @override
  String? get name;
  @override
  String? get imageUrl;
  @override
  double? get basePrice;
  @override
  bool? get isAvailable;
  @override
  String? get categoryId;

  /// Create a copy of MenuOfferMenuItemSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuOfferMenuItemSummaryImplCopyWith<_$MenuOfferMenuItemSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MenuOffer {
  String get id => throw _privateConstructorUsedError;
  String get menuItemId => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get startAt => throw _privateConstructorUsedError;
  DateTime? get endAt => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  MenuOfferMenuItemSummary? get menuItem => throw _privateConstructorUsedError;

  /// Create a copy of MenuOffer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MenuOfferCopyWith<MenuOffer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenuOfferCopyWith<$Res> {
  factory $MenuOfferCopyWith(MenuOffer value, $Res Function(MenuOffer) then) =
      _$MenuOfferCopyWithImpl<$Res, MenuOffer>;
  @useResult
  $Res call({
    String id,
    String menuItemId,
    String imageUrl,
    String? title,
    String? description,
    bool isActive,
    DateTime? startAt,
    DateTime? endAt,
    int sortOrder,
    DateTime createdAt,
    DateTime updatedAt,
    MenuOfferMenuItemSummary? menuItem,
  });

  $MenuOfferMenuItemSummaryCopyWith<$Res>? get menuItem;
}

/// @nodoc
class _$MenuOfferCopyWithImpl<$Res, $Val extends MenuOffer>
    implements $MenuOfferCopyWith<$Res> {
  _$MenuOfferCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MenuOffer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = null,
    Object? imageUrl = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? isActive = null,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? sortOrder = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? menuItem = freezed,
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
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            startAt: freezed == startAt
                ? _value.startAt
                : startAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endAt: freezed == endAt
                ? _value.endAt
                : endAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            menuItem: freezed == menuItem
                ? _value.menuItem
                : menuItem // ignore: cast_nullable_to_non_nullable
                      as MenuOfferMenuItemSummary?,
          )
          as $Val,
    );
  }

  /// Create a copy of MenuOffer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MenuOfferMenuItemSummaryCopyWith<$Res>? get menuItem {
    if (_value.menuItem == null) {
      return null;
    }

    return $MenuOfferMenuItemSummaryCopyWith<$Res>(_value.menuItem!, (value) {
      return _then(_value.copyWith(menuItem: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MenuOfferImplCopyWith<$Res>
    implements $MenuOfferCopyWith<$Res> {
  factory _$$MenuOfferImplCopyWith(
    _$MenuOfferImpl value,
    $Res Function(_$MenuOfferImpl) then,
  ) = __$$MenuOfferImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String menuItemId,
    String imageUrl,
    String? title,
    String? description,
    bool isActive,
    DateTime? startAt,
    DateTime? endAt,
    int sortOrder,
    DateTime createdAt,
    DateTime updatedAt,
    MenuOfferMenuItemSummary? menuItem,
  });

  @override
  $MenuOfferMenuItemSummaryCopyWith<$Res>? get menuItem;
}

/// @nodoc
class __$$MenuOfferImplCopyWithImpl<$Res>
    extends _$MenuOfferCopyWithImpl<$Res, _$MenuOfferImpl>
    implements _$$MenuOfferImplCopyWith<$Res> {
  __$$MenuOfferImplCopyWithImpl(
    _$MenuOfferImpl _value,
    $Res Function(_$MenuOfferImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MenuOffer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? menuItemId = null,
    Object? imageUrl = null,
    Object? title = freezed,
    Object? description = freezed,
    Object? isActive = null,
    Object? startAt = freezed,
    Object? endAt = freezed,
    Object? sortOrder = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? menuItem = freezed,
  }) {
    return _then(
      _$MenuOfferImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        menuItemId: null == menuItemId
            ? _value.menuItemId
            : menuItemId // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        startAt: freezed == startAt
            ? _value.startAt
            : startAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endAt: freezed == endAt
            ? _value.endAt
            : endAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        menuItem: freezed == menuItem
            ? _value.menuItem
            : menuItem // ignore: cast_nullable_to_non_nullable
                  as MenuOfferMenuItemSummary?,
      ),
    );
  }
}

/// @nodoc

class _$MenuOfferImpl implements _MenuOffer {
  const _$MenuOfferImpl({
    required this.id,
    required this.menuItemId,
    required this.imageUrl,
    this.title,
    this.description,
    this.isActive = true,
    this.startAt,
    this.endAt,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.menuItem,
  });

  @override
  final String id;
  @override
  final String menuItemId;
  @override
  final String imageUrl;
  @override
  final String? title;
  @override
  final String? description;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? startAt;
  @override
  final DateTime? endAt;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final MenuOfferMenuItemSummary? menuItem;

  @override
  String toString() {
    return 'MenuOffer(id: $id, menuItemId: $menuItemId, imageUrl: $imageUrl, title: $title, description: $description, isActive: $isActive, startAt: $startAt, endAt: $endAt, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt, menuItem: $menuItem)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenuOfferImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.menuItemId, menuItemId) ||
                other.menuItemId == menuItemId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.startAt, startAt) || other.startAt == startAt) &&
            (identical(other.endAt, endAt) || other.endAt == endAt) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.menuItem, menuItem) ||
                other.menuItem == menuItem));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    menuItemId,
    imageUrl,
    title,
    description,
    isActive,
    startAt,
    endAt,
    sortOrder,
    createdAt,
    updatedAt,
    menuItem,
  );

  /// Create a copy of MenuOffer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MenuOfferImplCopyWith<_$MenuOfferImpl> get copyWith =>
      __$$MenuOfferImplCopyWithImpl<_$MenuOfferImpl>(this, _$identity);
}

abstract class _MenuOffer implements MenuOffer {
  const factory _MenuOffer({
    required final String id,
    required final String menuItemId,
    required final String imageUrl,
    final String? title,
    final String? description,
    final bool isActive,
    final DateTime? startAt,
    final DateTime? endAt,
    final int sortOrder,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final MenuOfferMenuItemSummary? menuItem,
  }) = _$MenuOfferImpl;

  @override
  String get id;
  @override
  String get menuItemId;
  @override
  String get imageUrl;
  @override
  String? get title;
  @override
  String? get description;
  @override
  bool get isActive;
  @override
  DateTime? get startAt;
  @override
  DateTime? get endAt;
  @override
  int get sortOrder;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  MenuOfferMenuItemSummary? get menuItem;

  /// Create a copy of MenuOffer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MenuOfferImplCopyWith<_$MenuOfferImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
