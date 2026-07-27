// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OrderNotification _$OrderNotificationFromJson(Map<String, dynamic> json) {
  return _OrderNotification.fromJson(json);
}

/// @nodoc
mixin _$OrderNotification {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get customerId => throw _privateConstructorUsedError;
  String get customerName => throw _privateConstructorUsedError;
  String get orderNumber => throw _privateConstructorUsedError;
  double get totalAmount => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this OrderNotification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OrderNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OrderNotificationCopyWith<OrderNotification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OrderNotificationCopyWith<$Res> {
  factory $OrderNotificationCopyWith(
    OrderNotification value,
    $Res Function(OrderNotification) then,
  ) = _$OrderNotificationCopyWithImpl<$Res, OrderNotification>;
  @useResult
  $Res call({
    String id,
    String type,
    String title,
    String body,
    String orderId,
    String customerId,
    String customerName,
    String orderNumber,
    double totalAmount,
    bool isRead,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$OrderNotificationCopyWithImpl<$Res, $Val extends OrderNotification>
    implements $OrderNotificationCopyWith<$Res> {
  _$OrderNotificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OrderNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? body = null,
    Object? orderId = null,
    Object? customerId = null,
    Object? customerName = null,
    Object? orderNumber = null,
    Object? totalAmount = null,
    Object? isRead = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            customerId: null == customerId
                ? _value.customerId
                : customerId // ignore: cast_nullable_to_non_nullable
                      as String,
            customerName: null == customerName
                ? _value.customerName
                : customerName // ignore: cast_nullable_to_non_nullable
                      as String,
            orderNumber: null == orderNumber
                ? _value.orderNumber
                : orderNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OrderNotificationImplCopyWith<$Res>
    implements $OrderNotificationCopyWith<$Res> {
  factory _$$OrderNotificationImplCopyWith(
    _$OrderNotificationImpl value,
    $Res Function(_$OrderNotificationImpl) then,
  ) = __$$OrderNotificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String type,
    String title,
    String body,
    String orderId,
    String customerId,
    String customerName,
    String orderNumber,
    double totalAmount,
    bool isRead,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$OrderNotificationImplCopyWithImpl<$Res>
    extends _$OrderNotificationCopyWithImpl<$Res, _$OrderNotificationImpl>
    implements _$$OrderNotificationImplCopyWith<$Res> {
  __$$OrderNotificationImplCopyWithImpl(
    _$OrderNotificationImpl _value,
    $Res Function(_$OrderNotificationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OrderNotification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? body = null,
    Object? orderId = null,
    Object? customerId = null,
    Object? customerName = null,
    Object? orderNumber = null,
    Object? totalAmount = null,
    Object? isRead = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$OrderNotificationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerId: null == customerId
            ? _value.customerId
            : customerId // ignore: cast_nullable_to_non_nullable
                  as String,
        customerName: null == customerName
            ? _value.customerName
            : customerName // ignore: cast_nullable_to_non_nullable
                  as String,
        orderNumber: null == orderNumber
            ? _value.orderNumber
            : orderNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OrderNotificationImpl implements _OrderNotification {
  const _$OrderNotificationImpl({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.orderNumber,
    required this.totalAmount,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$OrderNotificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$OrderNotificationImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String title;
  @override
  final String body;
  @override
  final String orderId;
  @override
  final String customerId;
  @override
  final String customerName;
  @override
  final String orderNumber;
  @override
  final double totalAmount;
  @override
  final bool isRead;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'OrderNotification(id: $id, type: $type, title: $title, body: $body, orderId: $orderId, customerId: $customerId, customerName: $customerName, orderNumber: $orderNumber, totalAmount: $totalAmount, isRead: $isRead, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OrderNotificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.customerId, customerId) ||
                other.customerId == customerId) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.orderNumber, orderNumber) ||
                other.orderNumber == orderNumber) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    title,
    body,
    orderId,
    customerId,
    customerName,
    orderNumber,
    totalAmount,
    isRead,
    createdAt,
    updatedAt,
  );

  /// Create a copy of OrderNotification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OrderNotificationImplCopyWith<_$OrderNotificationImpl> get copyWith =>
      __$$OrderNotificationImplCopyWithImpl<_$OrderNotificationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OrderNotificationImplToJson(this);
  }
}

abstract class _OrderNotification implements OrderNotification {
  const factory _OrderNotification({
    required final String id,
    required final String type,
    required final String title,
    required final String body,
    required final String orderId,
    required final String customerId,
    required final String customerName,
    required final String orderNumber,
    required final double totalAmount,
    required final bool isRead,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$OrderNotificationImpl;

  factory _OrderNotification.fromJson(Map<String, dynamic> json) =
      _$OrderNotificationImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String get title;
  @override
  String get body;
  @override
  String get orderId;
  @override
  String get customerId;
  @override
  String get customerName;
  @override
  String get orderNumber;
  @override
  double get totalAmount;
  @override
  bool get isRead;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of OrderNotification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OrderNotificationImplCopyWith<_$OrderNotificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
