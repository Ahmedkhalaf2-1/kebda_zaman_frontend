// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'customer_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RecentOrderSummary {
  String get id => throw _privateConstructorUsedError;
  String get orderNumber => throw _privateConstructorUsedError;
  OrderStatus get status => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  String? get paymentMethod => throw _privateConstructorUsedError;
  FulfillmentType get fulfillmentType => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Create a copy of RecentOrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecentOrderSummaryCopyWith<RecentOrderSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentOrderSummaryCopyWith<$Res> {
  factory $RecentOrderSummaryCopyWith(
    RecentOrderSummary value,
    $Res Function(RecentOrderSummary) then,
  ) = _$RecentOrderSummaryCopyWithImpl<$Res, RecentOrderSummary>;
  @useResult
  $Res call({
    String id,
    String orderNumber,
    OrderStatus status,
    double totalAmount,
    String? paymentMethod,
    FulfillmentType fulfillmentType,
    DateTime createdAt,
  });
}

/// @nodoc
class _$RecentOrderSummaryCopyWithImpl<$Res, $Val extends RecentOrderSummary>
    implements $RecentOrderSummaryCopyWith<$Res> {
  _$RecentOrderSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecentOrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? status = null,
    Object? totalAmount = null,
    Object? paymentMethod = freezed,
    Object? fulfillmentType = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderNumber: null == orderNumber
                ? _value.orderNumber
                : orderNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as OrderStatus,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            paymentMethod: freezed == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            fulfillmentType: null == fulfillmentType
                ? _value.fulfillmentType
                : fulfillmentType // ignore: cast_nullable_to_non_nullable
                      as FulfillmentType,
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
abstract class _$$RecentOrderSummaryImplCopyWith<$Res>
    implements $RecentOrderSummaryCopyWith<$Res> {
  factory _$$RecentOrderSummaryImplCopyWith(
    _$RecentOrderSummaryImpl value,
    $Res Function(_$RecentOrderSummaryImpl) then,
  ) = __$$RecentOrderSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderNumber,
    OrderStatus status,
    double totalAmount,
    String? paymentMethod,
    FulfillmentType fulfillmentType,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$RecentOrderSummaryImplCopyWithImpl<$Res>
    extends _$RecentOrderSummaryCopyWithImpl<$Res, _$RecentOrderSummaryImpl>
    implements _$$RecentOrderSummaryImplCopyWith<$Res> {
  __$$RecentOrderSummaryImplCopyWithImpl(
    _$RecentOrderSummaryImpl _value,
    $Res Function(_$RecentOrderSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecentOrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderNumber = null,
    Object? status = null,
    Object? totalAmount = null,
    Object? paymentMethod = freezed,
    Object? fulfillmentType = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$RecentOrderSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderNumber: null == orderNumber
            ? _value.orderNumber
            : orderNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as OrderStatus,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        paymentMethod: freezed == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        fulfillmentType: null == fulfillmentType
            ? _value.fulfillmentType
            : fulfillmentType // ignore: cast_nullable_to_non_nullable
                  as FulfillmentType,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$RecentOrderSummaryImpl implements _RecentOrderSummary {
  const _$RecentOrderSummaryImpl({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.totalAmount,
    this.paymentMethod,
    required this.fulfillmentType,
    required this.createdAt,
  });

  @override
  final String id;
  @override
  final String orderNumber;
  @override
  final OrderStatus status;
  @override
  final double totalAmount;
  @override
  final String? paymentMethod;
  @override
  final FulfillmentType fulfillmentType;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'RecentOrderSummary(id: $id, orderNumber: $orderNumber, status: $status, totalAmount: $totalAmount, paymentMethod: $paymentMethod, fulfillmentType: $fulfillmentType, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentOrderSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.fulfillmentType, fulfillmentType) ||
                other.fulfillmentType == fulfillmentType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    orderNumber,
    status,
    totalAmount,
    paymentMethod,
    fulfillmentType,
    createdAt,
  );

  /// Create a copy of RecentOrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentOrderSummaryImplCopyWith<_$RecentOrderSummaryImpl> get copyWith =>
      __$$RecentOrderSummaryImplCopyWithImpl<_$RecentOrderSummaryImpl>(
        this,
        _$identity,
      );
}

abstract class _RecentOrderSummary implements RecentOrderSummary {
  const factory _RecentOrderSummary({
    required final String id,
    required final String orderNumber,
    required final OrderStatus status,
    required final double totalAmount,
    final String? paymentMethod,
    required final FulfillmentType fulfillmentType,
    required final DateTime createdAt,
  }) = _$RecentOrderSummaryImpl;

  @override
  String get id;
  @override
  String get orderNumber;
  @override
  OrderStatus get status;
  @override
  double get totalAmount;
  @override
  String? get paymentMethod;
  @override
  FulfillmentType get fulfillmentType;
  @override
  DateTime get createdAt;

  /// Create a copy of RecentOrderSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecentOrderSummaryImplCopyWith<_$RecentOrderSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CustomerSummary {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  bool get isGuest => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  int get orderCount => throw _privateConstructorUsedError;
  double get totalSpent => throw _privateConstructorUsedError;

  /// Create a copy of CustomerSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerSummaryCopyWith<CustomerSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerSummaryCopyWith<$Res> {
  factory $CustomerSummaryCopyWith(
    CustomerSummary value,
    $Res Function(CustomerSummary) then,
  ) = _$CustomerSummaryCopyWithImpl<$Res, CustomerSummary>;
  @useResult
  $Res call({
    String id,
    String name,
    String? email,
    String? phone,
    bool isGuest,
    bool isActive,
    DateTime createdAt,
    int orderCount,
    double totalSpent,
  });
}

/// @nodoc
class _$CustomerSummaryCopyWithImpl<$Res, $Val extends CustomerSummary>
    implements $CustomerSummaryCopyWith<$Res> {
  _$CustomerSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? isGuest = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? orderCount = null,
    Object? totalSpent = null,
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
            isGuest: null == isGuest
                ? _value.isGuest
                : isGuest // ignore: cast_nullable_to_non_nullable
                      as bool,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            orderCount: null == orderCount
                ? _value.orderCount
                : orderCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalSpent: null == totalSpent
                ? _value.totalSpent
                : totalSpent // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CustomerSummaryImplCopyWith<$Res>
    implements $CustomerSummaryCopyWith<$Res> {
  factory _$$CustomerSummaryImplCopyWith(
    _$CustomerSummaryImpl value,
    $Res Function(_$CustomerSummaryImpl) then,
  ) = __$$CustomerSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? email,
    String? phone,
    bool isGuest,
    bool isActive,
    DateTime createdAt,
    int orderCount,
    double totalSpent,
  });
}

/// @nodoc
class __$$CustomerSummaryImplCopyWithImpl<$Res>
    extends _$CustomerSummaryCopyWithImpl<$Res, _$CustomerSummaryImpl>
    implements _$$CustomerSummaryImplCopyWith<$Res> {
  __$$CustomerSummaryImplCopyWithImpl(
    _$CustomerSummaryImpl _value,
    $Res Function(_$CustomerSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? isGuest = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? orderCount = null,
    Object? totalSpent = null,
  }) {
    return _then(
      _$CustomerSummaryImpl(
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
        isGuest: null == isGuest
            ? _value.isGuest
            : isGuest // ignore: cast_nullable_to_non_nullable
                  as bool,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        orderCount: null == orderCount
            ? _value.orderCount
            : orderCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalSpent: null == totalSpent
            ? _value.totalSpent
            : totalSpent // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$CustomerSummaryImpl implements _CustomerSummary {
  const _$CustomerSummaryImpl({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.isGuest,
    required this.isActive,
    required this.createdAt,
    required this.orderCount,
    required this.totalSpent,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final bool isGuest;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final int orderCount;
  @override
  final double totalSpent;

  @override
  String toString() {
    return 'CustomerSummary(id: $id, name: $name, email: $email, phone: $phone, isGuest: $isGuest, isActive: $isActive, createdAt: $createdAt, orderCount: $orderCount, totalSpent: $totalSpent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.isGuest, isGuest) || other.isGuest == isGuest) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.orderCount, orderCount) ||
                other.orderCount == orderCount) &&
            (identical(other.totalSpent, totalSpent) ||
                other.totalSpent == totalSpent));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    email,
    phone,
    isGuest,
    isActive,
    createdAt,
    orderCount,
    totalSpent,
  );

  /// Create a copy of CustomerSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerSummaryImplCopyWith<_$CustomerSummaryImpl> get copyWith =>
      __$$CustomerSummaryImplCopyWithImpl<_$CustomerSummaryImpl>(
        this,
        _$identity,
      );
}

abstract class _CustomerSummary implements CustomerSummary {
  const factory _CustomerSummary({
    required final String id,
    required final String name,
    final String? email,
    final String? phone,
    required final bool isGuest,
    required final bool isActive,
    required final DateTime createdAt,
    required final int orderCount,
    required final double totalSpent,
  }) = _$CustomerSummaryImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  bool get isGuest;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  int get orderCount;
  @override
  double get totalSpent;

  /// Create a copy of CustomerSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerSummaryImplCopyWith<_$CustomerSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CustomerDetail {
  CustomerSummary get summary => throw _privateConstructorUsedError;
  List<RecentOrderSummary> get recentOrders =>
      throw _privateConstructorUsedError;

  /// Create a copy of CustomerDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CustomerDetailCopyWith<CustomerDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CustomerDetailCopyWith<$Res> {
  factory $CustomerDetailCopyWith(
    CustomerDetail value,
    $Res Function(CustomerDetail) then,
  ) = _$CustomerDetailCopyWithImpl<$Res, CustomerDetail>;
  @useResult
  $Res call({CustomerSummary summary, List<RecentOrderSummary> recentOrders});

  $CustomerSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class _$CustomerDetailCopyWithImpl<$Res, $Val extends CustomerDetail>
    implements $CustomerDetailCopyWith<$Res> {
  _$CustomerDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CustomerDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? summary = null, Object? recentOrders = null}) {
    return _then(
      _value.copyWith(
            summary: null == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                      as CustomerSummary,
            recentOrders: null == recentOrders
                ? _value.recentOrders
                : recentOrders // ignore: cast_nullable_to_non_nullable
                      as List<RecentOrderSummary>,
          )
          as $Val,
    );
  }

  /// Create a copy of CustomerDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CustomerSummaryCopyWith<$Res> get summary {
    return $CustomerSummaryCopyWith<$Res>(_value.summary, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CustomerDetailImplCopyWith<$Res>
    implements $CustomerDetailCopyWith<$Res> {
  factory _$$CustomerDetailImplCopyWith(
    _$CustomerDetailImpl value,
    $Res Function(_$CustomerDetailImpl) then,
  ) = __$$CustomerDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({CustomerSummary summary, List<RecentOrderSummary> recentOrders});

  @override
  $CustomerSummaryCopyWith<$Res> get summary;
}

/// @nodoc
class __$$CustomerDetailImplCopyWithImpl<$Res>
    extends _$CustomerDetailCopyWithImpl<$Res, _$CustomerDetailImpl>
    implements _$$CustomerDetailImplCopyWith<$Res> {
  __$$CustomerDetailImplCopyWithImpl(
    _$CustomerDetailImpl _value,
    $Res Function(_$CustomerDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CustomerDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? summary = null, Object? recentOrders = null}) {
    return _then(
      _$CustomerDetailImpl(
        summary: null == summary
            ? _value.summary
            : summary // ignore: cast_nullable_to_non_nullable
                  as CustomerSummary,
        recentOrders: null == recentOrders
            ? _value._recentOrders
            : recentOrders // ignore: cast_nullable_to_non_nullable
                  as List<RecentOrderSummary>,
      ),
    );
  }
}

/// @nodoc

class _$CustomerDetailImpl implements _CustomerDetail {
  const _$CustomerDetailImpl({
    required this.summary,
    required final List<RecentOrderSummary> recentOrders,
  }) : _recentOrders = recentOrders;

  @override
  final CustomerSummary summary;
  final List<RecentOrderSummary> _recentOrders;
  @override
  List<RecentOrderSummary> get recentOrders {
    if (_recentOrders is EqualUnmodifiableListView) return _recentOrders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentOrders);
  }

  @override
  String toString() {
    return 'CustomerDetail(summary: $summary, recentOrders: $recentOrders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CustomerDetailImpl &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(
              other._recentOrders,
              _recentOrders,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    summary,
    const DeepCollectionEquality().hash(_recentOrders),
  );

  /// Create a copy of CustomerDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CustomerDetailImplCopyWith<_$CustomerDetailImpl> get copyWith =>
      __$$CustomerDetailImplCopyWithImpl<_$CustomerDetailImpl>(
        this,
        _$identity,
      );
}

abstract class _CustomerDetail implements CustomerDetail {
  const factory _CustomerDetail({
    required final CustomerSummary summary,
    required final List<RecentOrderSummary> recentOrders,
  }) = _$CustomerDetailImpl;

  @override
  CustomerSummary get summary;
  @override
  List<RecentOrderSummary> get recentOrders;

  /// Create a copy of CustomerDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CustomerDetailImplCopyWith<_$CustomerDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
