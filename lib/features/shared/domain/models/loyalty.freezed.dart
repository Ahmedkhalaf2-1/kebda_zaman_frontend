// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'loyalty.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LoyaltyAccount _$LoyaltyAccountFromJson(Map<String, dynamic> json) {
  return _LoyaltyAccount.fromJson(json);
}

/// @nodoc
mixin _$LoyaltyAccount {
  String get userId => throw _privateConstructorUsedError;
  int get pointsBalance => throw _privateConstructorUsedError;
  int get lifetimePointsEarned => throw _privateConstructorUsedError;

  /// Serializes this LoyaltyAccount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoyaltyAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoyaltyAccountCopyWith<LoyaltyAccount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoyaltyAccountCopyWith<$Res> {
  factory $LoyaltyAccountCopyWith(
    LoyaltyAccount value,
    $Res Function(LoyaltyAccount) then,
  ) = _$LoyaltyAccountCopyWithImpl<$Res, LoyaltyAccount>;
  @useResult
  $Res call({String userId, int pointsBalance, int lifetimePointsEarned});
}

/// @nodoc
class _$LoyaltyAccountCopyWithImpl<$Res, $Val extends LoyaltyAccount>
    implements $LoyaltyAccountCopyWith<$Res> {
  _$LoyaltyAccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoyaltyAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? pointsBalance = null,
    Object? lifetimePointsEarned = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            pointsBalance: null == pointsBalance
                ? _value.pointsBalance
                : pointsBalance // ignore: cast_nullable_to_non_nullable
                      as int,
            lifetimePointsEarned: null == lifetimePointsEarned
                ? _value.lifetimePointsEarned
                : lifetimePointsEarned // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoyaltyAccountImplCopyWith<$Res>
    implements $LoyaltyAccountCopyWith<$Res> {
  factory _$$LoyaltyAccountImplCopyWith(
    _$LoyaltyAccountImpl value,
    $Res Function(_$LoyaltyAccountImpl) then,
  ) = __$$LoyaltyAccountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, int pointsBalance, int lifetimePointsEarned});
}

/// @nodoc
class __$$LoyaltyAccountImplCopyWithImpl<$Res>
    extends _$LoyaltyAccountCopyWithImpl<$Res, _$LoyaltyAccountImpl>
    implements _$$LoyaltyAccountImplCopyWith<$Res> {
  __$$LoyaltyAccountImplCopyWithImpl(
    _$LoyaltyAccountImpl _value,
    $Res Function(_$LoyaltyAccountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoyaltyAccount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? pointsBalance = null,
    Object? lifetimePointsEarned = null,
  }) {
    return _then(
      _$LoyaltyAccountImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        pointsBalance: null == pointsBalance
            ? _value.pointsBalance
            : pointsBalance // ignore: cast_nullable_to_non_nullable
                  as int,
        lifetimePointsEarned: null == lifetimePointsEarned
            ? _value.lifetimePointsEarned
            : lifetimePointsEarned // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoyaltyAccountImpl implements _LoyaltyAccount {
  const _$LoyaltyAccountImpl({
    required this.userId,
    this.pointsBalance = 0,
    this.lifetimePointsEarned = 0,
  });

  factory _$LoyaltyAccountImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoyaltyAccountImplFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final int pointsBalance;
  @override
  @JsonKey()
  final int lifetimePointsEarned;

  @override
  String toString() {
    return 'LoyaltyAccount(userId: $userId, pointsBalance: $pointsBalance, lifetimePointsEarned: $lifetimePointsEarned)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoyaltyAccountImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.pointsBalance, pointsBalance) ||
                other.pointsBalance == pointsBalance) &&
            (identical(other.lifetimePointsEarned, lifetimePointsEarned) ||
                other.lifetimePointsEarned == lifetimePointsEarned));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, pointsBalance, lifetimePointsEarned);

  /// Create a copy of LoyaltyAccount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoyaltyAccountImplCopyWith<_$LoyaltyAccountImpl> get copyWith =>
      __$$LoyaltyAccountImplCopyWithImpl<_$LoyaltyAccountImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LoyaltyAccountImplToJson(this);
  }
}

abstract class _LoyaltyAccount implements LoyaltyAccount {
  const factory _LoyaltyAccount({
    required final String userId,
    final int pointsBalance,
    final int lifetimePointsEarned,
  }) = _$LoyaltyAccountImpl;

  factory _LoyaltyAccount.fromJson(Map<String, dynamic> json) =
      _$LoyaltyAccountImpl.fromJson;

  @override
  String get userId;
  @override
  int get pointsBalance;
  @override
  int get lifetimePointsEarned;

  /// Create a copy of LoyaltyAccount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoyaltyAccountImplCopyWith<_$LoyaltyAccountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoyaltyTransaction _$LoyaltyTransactionFromJson(Map<String, dynamic> json) {
  return _LoyaltyTransaction.fromJson(json);
}

/// @nodoc
mixin _$LoyaltyTransaction {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get orderId => throw _privateConstructorUsedError;
  LoyaltyTransactionType get type => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get balanceAfter => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this LoyaltyTransaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoyaltyTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoyaltyTransactionCopyWith<LoyaltyTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoyaltyTransactionCopyWith<$Res> {
  factory $LoyaltyTransactionCopyWith(
    LoyaltyTransaction value,
    $Res Function(LoyaltyTransaction) then,
  ) = _$LoyaltyTransactionCopyWithImpl<$Res, LoyaltyTransaction>;
  @useResult
  $Res call({
    String id,
    String userId,
    String? orderId,
    LoyaltyTransactionType type,
    int points,
    int balanceAfter,
    DateTime createdAt,
  });
}

/// @nodoc
class _$LoyaltyTransactionCopyWithImpl<$Res, $Val extends LoyaltyTransaction>
    implements $LoyaltyTransactionCopyWith<$Res> {
  _$LoyaltyTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoyaltyTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? orderId = freezed,
    Object? type = null,
    Object? points = null,
    Object? balanceAfter = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: freezed == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as LoyaltyTransactionType,
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as int,
            balanceAfter: null == balanceAfter
                ? _value.balanceAfter
                : balanceAfter // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$LoyaltyTransactionImplCopyWith<$Res>
    implements $LoyaltyTransactionCopyWith<$Res> {
  factory _$$LoyaltyTransactionImplCopyWith(
    _$LoyaltyTransactionImpl value,
    $Res Function(_$LoyaltyTransactionImpl) then,
  ) = __$$LoyaltyTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String? orderId,
    LoyaltyTransactionType type,
    int points,
    int balanceAfter,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$LoyaltyTransactionImplCopyWithImpl<$Res>
    extends _$LoyaltyTransactionCopyWithImpl<$Res, _$LoyaltyTransactionImpl>
    implements _$$LoyaltyTransactionImplCopyWith<$Res> {
  __$$LoyaltyTransactionImplCopyWithImpl(
    _$LoyaltyTransactionImpl _value,
    $Res Function(_$LoyaltyTransactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoyaltyTransaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? orderId = freezed,
    Object? type = null,
    Object? points = null,
    Object? balanceAfter = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$LoyaltyTransactionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: freezed == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as LoyaltyTransactionType,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
        balanceAfter: null == balanceAfter
            ? _value.balanceAfter
            : balanceAfter // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$LoyaltyTransactionImpl implements _LoyaltyTransaction {
  const _$LoyaltyTransactionImpl({
    required this.id,
    required this.userId,
    this.orderId,
    required this.type,
    required this.points,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory _$LoyaltyTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoyaltyTransactionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? orderId;
  @override
  final LoyaltyTransactionType type;
  @override
  final int points;
  @override
  final int balanceAfter;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'LoyaltyTransaction(id: $id, userId: $userId, orderId: $orderId, type: $type, points: $points, balanceAfter: $balanceAfter, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoyaltyTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.balanceAfter, balanceAfter) ||
                other.balanceAfter == balanceAfter) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    orderId,
    type,
    points,
    balanceAfter,
    createdAt,
  );

  /// Create a copy of LoyaltyTransaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoyaltyTransactionImplCopyWith<_$LoyaltyTransactionImpl> get copyWith =>
      __$$LoyaltyTransactionImplCopyWithImpl<_$LoyaltyTransactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LoyaltyTransactionImplToJson(this);
  }
}

abstract class _LoyaltyTransaction implements LoyaltyTransaction {
  const factory _LoyaltyTransaction({
    required final String id,
    required final String userId,
    final String? orderId,
    required final LoyaltyTransactionType type,
    required final int points,
    required final int balanceAfter,
    required final DateTime createdAt,
  }) = _$LoyaltyTransactionImpl;

  factory _LoyaltyTransaction.fromJson(Map<String, dynamic> json) =
      _$LoyaltyTransactionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get orderId;
  @override
  LoyaltyTransactionType get type;
  @override
  int get points;
  @override
  int get balanceAfter;
  @override
  DateTime get createdAt;

  /// Create a copy of LoyaltyTransaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoyaltyTransactionImplCopyWith<_$LoyaltyTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
