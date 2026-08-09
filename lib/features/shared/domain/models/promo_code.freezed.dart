// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'promo_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PromoCode _$PromoCodeFromJson(Map<String, dynamic> json) {
  return _PromoCode.fromJson(json);
}

/// @nodoc
mixin _$PromoCode {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  DiscountType get discountType => throw _privateConstructorUsedError;
  double get value => throw _privateConstructorUsedError;
  double get minOrderValue => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  bool get isActive =>
      throw _privateConstructorUsedError; // Global usage cap — backend field `maxUsage`. `null` means unlimited;
  // this exact convention is reused everywhere (model, payload, and the
  // admin form's "leave empty for unlimited" UX), never a second field.
  int? get usageLimit =>
      throw _privateConstructorUsedError; // Per-customer usage cap — backend field `perUserLimit`. Same
  // null-means-unlimited convention as [usageLimit].
  int? get perUserLimit =>
      throw _privateConstructorUsedError; // How many times this code has actually been successfully redeemed —
  // backend field `usageCount`, returned on every admin list/detail
  // response (AdminPromoResponseDto). Read-only from Flutter's side: it's
  // never sent in a create/update payload, only displayed.
  int get usageCount => throw _privateConstructorUsedError;

  /// Serializes this PromoCode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PromoCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PromoCodeCopyWith<PromoCode> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PromoCodeCopyWith<$Res> {
  factory $PromoCodeCopyWith(PromoCode value, $Res Function(PromoCode) then) =
      _$PromoCodeCopyWithImpl<$Res, PromoCode>;
  @useResult
  $Res call({
    String id,
    String code,
    DiscountType discountType,
    double value,
    double minOrderValue,
    DateTime startDate,
    DateTime endDate,
    bool isActive,
    int? usageLimit,
    int? perUserLimit,
    int usageCount,
  });
}

/// @nodoc
class _$PromoCodeCopyWithImpl<$Res, $Val extends PromoCode>
    implements $PromoCodeCopyWith<$Res> {
  _$PromoCodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PromoCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? discountType = null,
    Object? value = null,
    Object? minOrderValue = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? isActive = null,
    Object? usageLimit = freezed,
    Object? perUserLimit = freezed,
    Object? usageCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            discountType: null == discountType
                ? _value.discountType
                : discountType // ignore: cast_nullable_to_non_nullable
                      as DiscountType,
            value: null == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as double,
            minOrderValue: null == minOrderValue
                ? _value.minOrderValue
                : minOrderValue // ignore: cast_nullable_to_non_nullable
                      as double,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            usageLimit: freezed == usageLimit
                ? _value.usageLimit
                : usageLimit // ignore: cast_nullable_to_non_nullable
                      as int?,
            perUserLimit: freezed == perUserLimit
                ? _value.perUserLimit
                : perUserLimit // ignore: cast_nullable_to_non_nullable
                      as int?,
            usageCount: null == usageCount
                ? _value.usageCount
                : usageCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PromoCodeImplCopyWith<$Res>
    implements $PromoCodeCopyWith<$Res> {
  factory _$$PromoCodeImplCopyWith(
    _$PromoCodeImpl value,
    $Res Function(_$PromoCodeImpl) then,
  ) = __$$PromoCodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String code,
    DiscountType discountType,
    double value,
    double minOrderValue,
    DateTime startDate,
    DateTime endDate,
    bool isActive,
    int? usageLimit,
    int? perUserLimit,
    int usageCount,
  });
}

/// @nodoc
class __$$PromoCodeImplCopyWithImpl<$Res>
    extends _$PromoCodeCopyWithImpl<$Res, _$PromoCodeImpl>
    implements _$$PromoCodeImplCopyWith<$Res> {
  __$$PromoCodeImplCopyWithImpl(
    _$PromoCodeImpl _value,
    $Res Function(_$PromoCodeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PromoCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? discountType = null,
    Object? value = null,
    Object? minOrderValue = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? isActive = null,
    Object? usageLimit = freezed,
    Object? perUserLimit = freezed,
    Object? usageCount = null,
  }) {
    return _then(
      _$PromoCodeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        discountType: null == discountType
            ? _value.discountType
            : discountType // ignore: cast_nullable_to_non_nullable
                  as DiscountType,
        value: null == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as double,
        minOrderValue: null == minOrderValue
            ? _value.minOrderValue
            : minOrderValue // ignore: cast_nullable_to_non_nullable
                  as double,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        usageLimit: freezed == usageLimit
            ? _value.usageLimit
            : usageLimit // ignore: cast_nullable_to_non_nullable
                  as int?,
        perUserLimit: freezed == perUserLimit
            ? _value.perUserLimit
            : perUserLimit // ignore: cast_nullable_to_non_nullable
                  as int?,
        usageCount: null == usageCount
            ? _value.usageCount
            : usageCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PromoCodeImpl implements _PromoCode {
  const _$PromoCodeImpl({
    required this.id,
    required this.code,
    required this.discountType,
    required this.value,
    this.minOrderValue = 0.0,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.usageLimit,
    this.perUserLimit,
    this.usageCount = 0,
  });

  factory _$PromoCodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$PromoCodeImplFromJson(json);

  @override
  final String id;
  @override
  final String code;
  @override
  final DiscountType discountType;
  @override
  final double value;
  @override
  @JsonKey()
  final double minOrderValue;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  @JsonKey()
  final bool isActive;
  // Global usage cap — backend field `maxUsage`. `null` means unlimited;
  // this exact convention is reused everywhere (model, payload, and the
  // admin form's "leave empty for unlimited" UX), never a second field.
  @override
  final int? usageLimit;
  // Per-customer usage cap — backend field `perUserLimit`. Same
  // null-means-unlimited convention as [usageLimit].
  @override
  final int? perUserLimit;
  // How many times this code has actually been successfully redeemed —
  // backend field `usageCount`, returned on every admin list/detail
  // response (AdminPromoResponseDto). Read-only from Flutter's side: it's
  // never sent in a create/update payload, only displayed.
  @override
  @JsonKey()
  final int usageCount;

  @override
  String toString() {
    return 'PromoCode(id: $id, code: $code, discountType: $discountType, value: $value, minOrderValue: $minOrderValue, startDate: $startDate, endDate: $endDate, isActive: $isActive, usageLimit: $usageLimit, perUserLimit: $perUserLimit, usageCount: $usageCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PromoCodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.discountType, discountType) ||
                other.discountType == discountType) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.minOrderValue, minOrderValue) ||
                other.minOrderValue == minOrderValue) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.usageLimit, usageLimit) ||
                other.usageLimit == usageLimit) &&
            (identical(other.perUserLimit, perUserLimit) ||
                other.perUserLimit == perUserLimit) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    code,
    discountType,
    value,
    minOrderValue,
    startDate,
    endDate,
    isActive,
    usageLimit,
    perUserLimit,
    usageCount,
  );

  /// Create a copy of PromoCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PromoCodeImplCopyWith<_$PromoCodeImpl> get copyWith =>
      __$$PromoCodeImplCopyWithImpl<_$PromoCodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PromoCodeImplToJson(this);
  }
}

abstract class _PromoCode implements PromoCode {
  const factory _PromoCode({
    required final String id,
    required final String code,
    required final DiscountType discountType,
    required final double value,
    final double minOrderValue,
    required final DateTime startDate,
    required final DateTime endDate,
    final bool isActive,
    final int? usageLimit,
    final int? perUserLimit,
    final int usageCount,
  }) = _$PromoCodeImpl;

  factory _PromoCode.fromJson(Map<String, dynamic> json) =
      _$PromoCodeImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  DiscountType get discountType;
  @override
  double get value;
  @override
  double get minOrderValue;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  bool get isActive; // Global usage cap — backend field `maxUsage`. `null` means unlimited;
  // this exact convention is reused everywhere (model, payload, and the
  // admin form's "leave empty for unlimited" UX), never a second field.
  @override
  int? get usageLimit; // Per-customer usage cap — backend field `perUserLimit`. Same
  // null-means-unlimited convention as [usageLimit].
  @override
  int? get perUserLimit; // How many times this code has actually been successfully redeemed —
  // backend field `usageCount`, returned on every admin list/detail
  // response (AdminPromoResponseDto). Read-only from Flutter's side: it's
  // never sent in a create/update payload, only displayed.
  @override
  int get usageCount;

  /// Create a copy of PromoCode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PromoCodeImplCopyWith<_$PromoCodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
