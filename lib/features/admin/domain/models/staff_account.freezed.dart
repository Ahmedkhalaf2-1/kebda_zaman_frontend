// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StaffAccount _$StaffAccountFromJson(Map<String, dynamic> json) {
  return _StaffAccount.fromJson(json);
}

/// @nodoc
mixin _$StaffAccount {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this StaffAccount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StaffAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StaffAccountCopyWith<StaffAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StaffAccountCopyWith<$Res> {
  factory $StaffAccountCopyWith(
    StaffAccount value,
    $Res Function(StaffAccount) then,
  ) = _$StaffAccountCopyWithImpl<$Res, StaffAccount>;
  @useResult
  $Res call({
    String id,
    String name,
    String? email,
    String? phone,
    bool isActive,
    DateTime createdAt,
  });
}

/// @nodoc
class _$StaffAccountCopyWithImpl<$Res, $Val extends StaffAccount>
    implements $StaffAccountCopyWith<$Res> {
  _$StaffAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StaffAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? isActive = null,
    Object? createdAt = null,
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
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StaffAccountImplCopyWith<$Res>
    implements $StaffAccountCopyWith<$Res> {
  factory _$$StaffAccountImplCopyWith(
    _$StaffAccountImpl value,
    $Res Function(_$StaffAccountImpl) then,
  ) = __$$StaffAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? email,
    String? phone,
    bool isActive,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$StaffAccountImplCopyWithImpl<$Res>
    extends _$StaffAccountCopyWithImpl<$Res, _$StaffAccountImpl>
    implements _$$StaffAccountImplCopyWith<$Res> {
  __$$StaffAccountImplCopyWithImpl(
    _$StaffAccountImpl _value,
    $Res Function(_$StaffAccountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StaffAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$StaffAccountImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StaffAccountImpl implements _StaffAccount {
  const _$StaffAccountImpl({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.isActive,
    required this.createdAt,
  });

  factory _$StaffAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$StaffAccountImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'StaffAccount(id: $id, name: $name, email: $email, phone: $phone, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StaffAccountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, email, phone, isActive, createdAt);

  /// Create a copy of StaffAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StaffAccountImplCopyWith<_$StaffAccountImpl> get copyWith =>
      __$$StaffAccountImplCopyWithImpl<_$StaffAccountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StaffAccountImplToJson(this);
  }
}

abstract class _StaffAccount implements StaffAccount {
  const factory _StaffAccount({
    required final String id,
    required final String name,
    final String? email,
    final String? phone,
    required final bool isActive,
    required final DateTime createdAt,
  }) = _$StaffAccountImpl;

  factory _StaffAccount.fromJson(Map<String, dynamic> json) =
      _$StaffAccountImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;

  /// Create a copy of StaffAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StaffAccountImplCopyWith<_$StaffAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
