// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PaymentIntent _$PaymentIntentFromJson(Map<String, dynamic> json) {
  return _PaymentIntent.fromJson(json);
}

/// @nodoc
mixin _$PaymentIntent {
  String get paymentId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  PaymentIntentProviderData get providerData =>
      throw _privateConstructorUsedError;

  /// Serializes this PaymentIntent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentIntent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentIntentCopyWith<PaymentIntent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentIntentCopyWith<$Res> {
  factory $PaymentIntentCopyWith(
    PaymentIntent value,
    $Res Function(PaymentIntent) then,
  ) = _$PaymentIntentCopyWithImpl<$Res, PaymentIntent>;
  @useResult
  $Res call({
    String paymentId,
    String status,
    PaymentIntentProviderData providerData,
  });

  $PaymentIntentProviderDataCopyWith<$Res> get providerData;
}

/// @nodoc
class _$PaymentIntentCopyWithImpl<$Res, $Val extends PaymentIntent>
    implements $PaymentIntentCopyWith<$Res> {
  _$PaymentIntentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentIntent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentId = null,
    Object? status = null,
    Object? providerData = null,
  }) {
    return _then(
      _value.copyWith(
            paymentId: null == paymentId
                ? _value.paymentId
                : paymentId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            providerData: null == providerData
                ? _value.providerData
                : providerData // ignore: cast_nullable_to_non_nullable
                      as PaymentIntentProviderData,
          )
          as $Val,
    );
  }

  /// Create a copy of PaymentIntent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PaymentIntentProviderDataCopyWith<$Res> get providerData {
    return $PaymentIntentProviderDataCopyWith<$Res>(_value.providerData, (
      value,
    ) {
      return _then(_value.copyWith(providerData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PaymentIntentImplCopyWith<$Res>
    implements $PaymentIntentCopyWith<$Res> {
  factory _$$PaymentIntentImplCopyWith(
    _$PaymentIntentImpl value,
    $Res Function(_$PaymentIntentImpl) then,
  ) = __$$PaymentIntentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String paymentId,
    String status,
    PaymentIntentProviderData providerData,
  });

  @override
  $PaymentIntentProviderDataCopyWith<$Res> get providerData;
}

/// @nodoc
class __$$PaymentIntentImplCopyWithImpl<$Res>
    extends _$PaymentIntentCopyWithImpl<$Res, _$PaymentIntentImpl>
    implements _$$PaymentIntentImplCopyWith<$Res> {
  __$$PaymentIntentImplCopyWithImpl(
    _$PaymentIntentImpl _value,
    $Res Function(_$PaymentIntentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentIntent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentId = null,
    Object? status = null,
    Object? providerData = null,
  }) {
    return _then(
      _$PaymentIntentImpl(
        paymentId: null == paymentId
            ? _value.paymentId
            : paymentId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        providerData: null == providerData
            ? _value.providerData
            : providerData // ignore: cast_nullable_to_non_nullable
                  as PaymentIntentProviderData,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentIntentImpl implements _PaymentIntent {
  const _$PaymentIntentImpl({
    required this.paymentId,
    required this.status,
    required this.providerData,
  });

  factory _$PaymentIntentImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentIntentImplFromJson(json);

  @override
  final String paymentId;
  @override
  final String status;
  @override
  final PaymentIntentProviderData providerData;

  @override
  String toString() {
    return 'PaymentIntent(paymentId: $paymentId, status: $status, providerData: $providerData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentIntentImpl &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.providerData, providerData) ||
                other.providerData == providerData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, paymentId, status, providerData);

  /// Create a copy of PaymentIntent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentIntentImplCopyWith<_$PaymentIntentImpl> get copyWith =>
      __$$PaymentIntentImplCopyWithImpl<_$PaymentIntentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentIntentImplToJson(this);
  }
}

abstract class _PaymentIntent implements PaymentIntent {
  const factory _PaymentIntent({
    required final String paymentId,
    required final String status,
    required final PaymentIntentProviderData providerData,
  }) = _$PaymentIntentImpl;

  factory _PaymentIntent.fromJson(Map<String, dynamic> json) =
      _$PaymentIntentImpl.fromJson;

  @override
  String get paymentId;
  @override
  String get status;
  @override
  PaymentIntentProviderData get providerData;

  /// Create a copy of PaymentIntent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentIntentImplCopyWith<_$PaymentIntentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PaymentIntentProviderData _$PaymentIntentProviderDataFromJson(
  Map<String, dynamic> json,
) {
  return _PaymentIntentProviderData.fromJson(json);
}

/// @nodoc
mixin _$PaymentIntentProviderData {
  // Absent for CASH intents (there is nothing to feed the Moyasar SDK).
  String? get publishableApiKey =>
      throw _privateConstructorUsedError; // Smallest-currency-unit amount (e.g. halalas) — already correctly
  // scaled by the backend, never multiplied/divided again client-side.
  int get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get callbackUrl => throw _privateConstructorUsedError;
  bool get manual =>
      throw _privateConstructorUsedError; // Present for CASH intents only ("Pay with cash upon delivery").
  String? get instructions => throw _privateConstructorUsedError;

  /// Serializes this PaymentIntentProviderData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PaymentIntentProviderData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentIntentProviderDataCopyWith<PaymentIntentProviderData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentIntentProviderDataCopyWith<$Res> {
  factory $PaymentIntentProviderDataCopyWith(
    PaymentIntentProviderData value,
    $Res Function(PaymentIntentProviderData) then,
  ) = _$PaymentIntentProviderDataCopyWithImpl<$Res, PaymentIntentProviderData>;
  @useResult
  $Res call({
    String? publishableApiKey,
    int amount,
    String currency,
    String orderId,
    String? description,
    String? callbackUrl,
    bool manual,
    String? instructions,
  });
}

/// @nodoc
class _$PaymentIntentProviderDataCopyWithImpl<
  $Res,
  $Val extends PaymentIntentProviderData
>
    implements $PaymentIntentProviderDataCopyWith<$Res> {
  _$PaymentIntentProviderDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentIntentProviderData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publishableApiKey = freezed,
    Object? amount = null,
    Object? currency = null,
    Object? orderId = null,
    Object? description = freezed,
    Object? callbackUrl = freezed,
    Object? manual = null,
    Object? instructions = freezed,
  }) {
    return _then(
      _value.copyWith(
            publishableApiKey: freezed == publishableApiKey
                ? _value.publishableApiKey
                : publishableApiKey // ignore: cast_nullable_to_non_nullable
                      as String?,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as int,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            callbackUrl: freezed == callbackUrl
                ? _value.callbackUrl
                : callbackUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            manual: null == manual
                ? _value.manual
                : manual // ignore: cast_nullable_to_non_nullable
                      as bool,
            instructions: freezed == instructions
                ? _value.instructions
                : instructions // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentIntentProviderDataImplCopyWith<$Res>
    implements $PaymentIntentProviderDataCopyWith<$Res> {
  factory _$$PaymentIntentProviderDataImplCopyWith(
    _$PaymentIntentProviderDataImpl value,
    $Res Function(_$PaymentIntentProviderDataImpl) then,
  ) = __$$PaymentIntentProviderDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? publishableApiKey,
    int amount,
    String currency,
    String orderId,
    String? description,
    String? callbackUrl,
    bool manual,
    String? instructions,
  });
}

/// @nodoc
class __$$PaymentIntentProviderDataImplCopyWithImpl<$Res>
    extends
        _$PaymentIntentProviderDataCopyWithImpl<
          $Res,
          _$PaymentIntentProviderDataImpl
        >
    implements _$$PaymentIntentProviderDataImplCopyWith<$Res> {
  __$$PaymentIntentProviderDataImplCopyWithImpl(
    _$PaymentIntentProviderDataImpl _value,
    $Res Function(_$PaymentIntentProviderDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentIntentProviderData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? publishableApiKey = freezed,
    Object? amount = null,
    Object? currency = null,
    Object? orderId = null,
    Object? description = freezed,
    Object? callbackUrl = freezed,
    Object? manual = null,
    Object? instructions = freezed,
  }) {
    return _then(
      _$PaymentIntentProviderDataImpl(
        publishableApiKey: freezed == publishableApiKey
            ? _value.publishableApiKey
            : publishableApiKey // ignore: cast_nullable_to_non_nullable
                  as String?,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as int,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        callbackUrl: freezed == callbackUrl
            ? _value.callbackUrl
            : callbackUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        manual: null == manual
            ? _value.manual
            : manual // ignore: cast_nullable_to_non_nullable
                  as bool,
        instructions: freezed == instructions
            ? _value.instructions
            : instructions // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentIntentProviderDataImpl implements _PaymentIntentProviderData {
  const _$PaymentIntentProviderDataImpl({
    this.publishableApiKey,
    required this.amount,
    required this.currency,
    required this.orderId,
    this.description,
    this.callbackUrl,
    this.manual = false,
    this.instructions,
  });

  factory _$PaymentIntentProviderDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentIntentProviderDataImplFromJson(json);

  // Absent for CASH intents (there is nothing to feed the Moyasar SDK).
  @override
  final String? publishableApiKey;
  // Smallest-currency-unit amount (e.g. halalas) — already correctly
  // scaled by the backend, never multiplied/divided again client-side.
  @override
  final int amount;
  @override
  final String currency;
  @override
  final String orderId;
  @override
  final String? description;
  @override
  final String? callbackUrl;
  @override
  @JsonKey()
  final bool manual;
  // Present for CASH intents only ("Pay with cash upon delivery").
  @override
  final String? instructions;

  @override
  String toString() {
    return 'PaymentIntentProviderData(publishableApiKey: $publishableApiKey, amount: $amount, currency: $currency, orderId: $orderId, description: $description, callbackUrl: $callbackUrl, manual: $manual, instructions: $instructions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentIntentProviderDataImpl &&
            (identical(other.publishableApiKey, publishableApiKey) ||
                other.publishableApiKey == publishableApiKey) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.callbackUrl, callbackUrl) ||
                other.callbackUrl == callbackUrl) &&
            (identical(other.manual, manual) || other.manual == manual) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    publishableApiKey,
    amount,
    currency,
    orderId,
    description,
    callbackUrl,
    manual,
    instructions,
  );

  /// Create a copy of PaymentIntentProviderData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentIntentProviderDataImplCopyWith<_$PaymentIntentProviderDataImpl>
  get copyWith =>
      __$$PaymentIntentProviderDataImplCopyWithImpl<
        _$PaymentIntentProviderDataImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentIntentProviderDataImplToJson(this);
  }
}

abstract class _PaymentIntentProviderData implements PaymentIntentProviderData {
  const factory _PaymentIntentProviderData({
    final String? publishableApiKey,
    required final int amount,
    required final String currency,
    required final String orderId,
    final String? description,
    final String? callbackUrl,
    final bool manual,
    final String? instructions,
  }) = _$PaymentIntentProviderDataImpl;

  factory _PaymentIntentProviderData.fromJson(Map<String, dynamic> json) =
      _$PaymentIntentProviderDataImpl.fromJson;

  // Absent for CASH intents (there is nothing to feed the Moyasar SDK).
  @override
  String? get publishableApiKey; // Smallest-currency-unit amount (e.g. halalas) — already correctly
  // scaled by the backend, never multiplied/divided again client-side.
  @override
  int get amount;
  @override
  String get currency;
  @override
  String get orderId;
  @override
  String? get description;
  @override
  String? get callbackUrl;
  @override
  bool get manual; // Present for CASH intents only ("Pay with cash upon delivery").
  @override
  String? get instructions;

  /// Create a copy of PaymentIntentProviderData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentIntentProviderDataImplCopyWith<_$PaymentIntentProviderDataImpl>
  get copyWith => throw _privateConstructorUsedError;
}

Payment _$PaymentFromJson(Map<String, dynamic> json) {
  return _Payment.fromJson(json);
}

/// @nodoc
mixin _$Payment {
  String get id => throw _privateConstructorUsedError;
  String get orderId => throw _privateConstructorUsedError;
  String get method => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  String? get providerRef => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Payment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentCopyWith<Payment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentCopyWith<$Res> {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) then) =
      _$PaymentCopyWithImpl<$Res, Payment>;
  @useResult
  $Res call({
    String id,
    String orderId,
    String method,
    String status,
    double amount,
    String currency,
    String provider,
    String? providerRef,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$PaymentCopyWithImpl<$Res, $Val extends Payment>
    implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? method = null,
    Object? status = null,
    Object? amount = null,
    Object? currency = null,
    Object? provider = null,
    Object? providerRef = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            orderId: null == orderId
                ? _value.orderId
                : orderId // ignore: cast_nullable_to_non_nullable
                      as String,
            method: null == method
                ? _value.method
                : method // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            providerRef: freezed == providerRef
                ? _value.providerRef
                : providerRef // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaymentImplCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$$PaymentImplCopyWith(
    _$PaymentImpl value,
    $Res Function(_$PaymentImpl) then,
  ) = __$$PaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String orderId,
    String method,
    String status,
    double amount,
    String currency,
    String provider,
    String? providerRef,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$PaymentImplCopyWithImpl<$Res>
    extends _$PaymentCopyWithImpl<$Res, _$PaymentImpl>
    implements _$$PaymentImplCopyWith<$Res> {
  __$$PaymentImplCopyWithImpl(
    _$PaymentImpl _value,
    $Res Function(_$PaymentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? orderId = null,
    Object? method = null,
    Object? status = null,
    Object? amount = null,
    Object? currency = null,
    Object? provider = null,
    Object? providerRef = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$PaymentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        orderId: null == orderId
            ? _value.orderId
            : orderId // ignore: cast_nullable_to_non_nullable
                  as String,
        method: null == method
            ? _value.method
            : method // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        providerRef: freezed == providerRef
            ? _value.providerRef
            : providerRef // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PaymentImpl implements _Payment {
  const _$PaymentImpl({
    required this.id,
    required this.orderId,
    required this.method,
    required this.status,
    required this.amount,
    required this.currency,
    required this.provider,
    this.providerRef,
    required this.createdAt,
    this.updatedAt,
  });

  factory _$PaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$PaymentImplFromJson(json);

  @override
  final String id;
  @override
  final String orderId;
  @override
  final String method;
  @override
  final String status;
  @override
  final double amount;
  @override
  final String currency;
  @override
  final String provider;
  @override
  final String? providerRef;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Payment(id: $id, orderId: $orderId, method: $method, status: $status, amount: $amount, currency: $currency, provider: $provider, providerRef: $providerRef, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.method, method) || other.method == method) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.providerRef, providerRef) ||
                other.providerRef == providerRef) &&
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
    orderId,
    method,
    status,
    amount,
    currency,
    provider,
    providerRef,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      __$$PaymentImplCopyWithImpl<_$PaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PaymentImplToJson(this);
  }
}

abstract class _Payment implements Payment {
  const factory _Payment({
    required final String id,
    required final String orderId,
    required final String method,
    required final String status,
    required final double amount,
    required final String currency,
    required final String provider,
    final String? providerRef,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$PaymentImpl;

  factory _Payment.fromJson(Map<String, dynamic> json) = _$PaymentImpl.fromJson;

  @override
  String get id;
  @override
  String get orderId;
  @override
  String get method;
  @override
  String get status;
  @override
  double get amount;
  @override
  String get currency;
  @override
  String get provider;
  @override
  String? get providerRef;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaymentImplCopyWith<_$PaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SavedCard _$SavedCardFromJson(Map<String, dynamic> json) {
  return _SavedCard.fromJson(json);
}

/// @nodoc
mixin _$SavedCard {
  String get id => throw _privateConstructorUsedError;
  String get brand => throw _privateConstructorUsedError;
  String get lastFour => throw _privateConstructorUsedError;
  int get expMonth => throw _privateConstructorUsedError;
  int get expYear => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SavedCard to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavedCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavedCardCopyWith<SavedCard> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavedCardCopyWith<$Res> {
  factory $SavedCardCopyWith(SavedCard value, $Res Function(SavedCard) then) =
      _$SavedCardCopyWithImpl<$Res, SavedCard>;
  @useResult
  $Res call({
    String id,
    String brand,
    String lastFour,
    int expMonth,
    int expYear,
    bool isDefault,
    DateTime createdAt,
  });
}

/// @nodoc
class _$SavedCardCopyWithImpl<$Res, $Val extends SavedCard>
    implements $SavedCardCopyWith<$Res> {
  _$SavedCardCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavedCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brand = null,
    Object? lastFour = null,
    Object? expMonth = null,
    Object? expYear = null,
    Object? isDefault = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            brand: null == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                      as String,
            lastFour: null == lastFour
                ? _value.lastFour
                : lastFour // ignore: cast_nullable_to_non_nullable
                      as String,
            expMonth: null == expMonth
                ? _value.expMonth
                : expMonth // ignore: cast_nullable_to_non_nullable
                      as int,
            expYear: null == expYear
                ? _value.expYear
                : expYear // ignore: cast_nullable_to_non_nullable
                      as int,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SavedCardImplCopyWith<$Res>
    implements $SavedCardCopyWith<$Res> {
  factory _$$SavedCardImplCopyWith(
    _$SavedCardImpl value,
    $Res Function(_$SavedCardImpl) then,
  ) = __$$SavedCardImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String brand,
    String lastFour,
    int expMonth,
    int expYear,
    bool isDefault,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$SavedCardImplCopyWithImpl<$Res>
    extends _$SavedCardCopyWithImpl<$Res, _$SavedCardImpl>
    implements _$$SavedCardImplCopyWith<$Res> {
  __$$SavedCardImplCopyWithImpl(
    _$SavedCardImpl _value,
    $Res Function(_$SavedCardImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SavedCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brand = null,
    Object? lastFour = null,
    Object? expMonth = null,
    Object? expYear = null,
    Object? isDefault = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SavedCardImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        brand: null == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
                  as String,
        lastFour: null == lastFour
            ? _value.lastFour
            : lastFour // ignore: cast_nullable_to_non_nullable
                  as String,
        expMonth: null == expMonth
            ? _value.expMonth
            : expMonth // ignore: cast_nullable_to_non_nullable
                  as int,
        expYear: null == expYear
            ? _value.expYear
            : expYear // ignore: cast_nullable_to_non_nullable
                  as int,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
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
class _$SavedCardImpl implements _SavedCard {
  const _$SavedCardImpl({
    required this.id,
    required this.brand,
    required this.lastFour,
    required this.expMonth,
    required this.expYear,
    required this.isDefault,
    required this.createdAt,
  });

  factory _$SavedCardImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavedCardImplFromJson(json);

  @override
  final String id;
  @override
  final String brand;
  @override
  final String lastFour;
  @override
  final int expMonth;
  @override
  final int expYear;
  @override
  final bool isDefault;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SavedCard(id: $id, brand: $brand, lastFour: $lastFour, expMonth: $expMonth, expYear: $expYear, isDefault: $isDefault, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavedCardImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.lastFour, lastFour) ||
                other.lastFour == lastFour) &&
            (identical(other.expMonth, expMonth) ||
                other.expMonth == expMonth) &&
            (identical(other.expYear, expYear) || other.expYear == expYear) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    brand,
    lastFour,
    expMonth,
    expYear,
    isDefault,
    createdAt,
  );

  /// Create a copy of SavedCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavedCardImplCopyWith<_$SavedCardImpl> get copyWith =>
      __$$SavedCardImplCopyWithImpl<_$SavedCardImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SavedCardImplToJson(this);
  }
}

abstract class _SavedCard implements SavedCard {
  const factory _SavedCard({
    required final String id,
    required final String brand,
    required final String lastFour,
    required final int expMonth,
    required final int expYear,
    required final bool isDefault,
    required final DateTime createdAt,
  }) = _$SavedCardImpl;

  factory _SavedCard.fromJson(Map<String, dynamic> json) =
      _$SavedCardImpl.fromJson;

  @override
  String get id;
  @override
  String get brand;
  @override
  String get lastFour;
  @override
  int get expMonth;
  @override
  int get expYear;
  @override
  bool get isDefault;
  @override
  DateTime get createdAt;

  /// Create a copy of SavedCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavedCardImplCopyWith<_$SavedCardImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CardChargeResult _$CardChargeResultFromJson(Map<String, dynamic> json) {
  return _CardChargeResult.fromJson(json);
}

/// @nodoc
mixin _$CardChargeResult {
  String get paymentId => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  CardChargeProviderData? get providerData =>
      throw _privateConstructorUsedError;

  /// Serializes this CardChargeResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CardChargeResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardChargeResultCopyWith<CardChargeResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardChargeResultCopyWith<$Res> {
  factory $CardChargeResultCopyWith(
    CardChargeResult value,
    $Res Function(CardChargeResult) then,
  ) = _$CardChargeResultCopyWithImpl<$Res, CardChargeResult>;
  @useResult
  $Res call({
    String paymentId,
    String status,
    CardChargeProviderData? providerData,
  });

  $CardChargeProviderDataCopyWith<$Res>? get providerData;
}

/// @nodoc
class _$CardChargeResultCopyWithImpl<$Res, $Val extends CardChargeResult>
    implements $CardChargeResultCopyWith<$Res> {
  _$CardChargeResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CardChargeResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentId = null,
    Object? status = null,
    Object? providerData = freezed,
  }) {
    return _then(
      _value.copyWith(
            paymentId: null == paymentId
                ? _value.paymentId
                : paymentId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            providerData: freezed == providerData
                ? _value.providerData
                : providerData // ignore: cast_nullable_to_non_nullable
                      as CardChargeProviderData?,
          )
          as $Val,
    );
  }

  /// Create a copy of CardChargeResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CardChargeProviderDataCopyWith<$Res>? get providerData {
    if (_value.providerData == null) {
      return null;
    }

    return $CardChargeProviderDataCopyWith<$Res>(_value.providerData!, (value) {
      return _then(_value.copyWith(providerData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CardChargeResultImplCopyWith<$Res>
    implements $CardChargeResultCopyWith<$Res> {
  factory _$$CardChargeResultImplCopyWith(
    _$CardChargeResultImpl value,
    $Res Function(_$CardChargeResultImpl) then,
  ) = __$$CardChargeResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String paymentId,
    String status,
    CardChargeProviderData? providerData,
  });

  @override
  $CardChargeProviderDataCopyWith<$Res>? get providerData;
}

/// @nodoc
class __$$CardChargeResultImplCopyWithImpl<$Res>
    extends _$CardChargeResultCopyWithImpl<$Res, _$CardChargeResultImpl>
    implements _$$CardChargeResultImplCopyWith<$Res> {
  __$$CardChargeResultImplCopyWithImpl(
    _$CardChargeResultImpl _value,
    $Res Function(_$CardChargeResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CardChargeResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paymentId = null,
    Object? status = null,
    Object? providerData = freezed,
  }) {
    return _then(
      _$CardChargeResultImpl(
        paymentId: null == paymentId
            ? _value.paymentId
            : paymentId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        providerData: freezed == providerData
            ? _value.providerData
            : providerData // ignore: cast_nullable_to_non_nullable
                  as CardChargeProviderData?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CardChargeResultImpl implements _CardChargeResult {
  const _$CardChargeResultImpl({
    required this.paymentId,
    required this.status,
    this.providerData,
  });

  factory _$CardChargeResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardChargeResultImplFromJson(json);

  @override
  final String paymentId;
  @override
  final String status;
  @override
  final CardChargeProviderData? providerData;

  @override
  String toString() {
    return 'CardChargeResult(paymentId: $paymentId, status: $status, providerData: $providerData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardChargeResultImpl &&
            (identical(other.paymentId, paymentId) ||
                other.paymentId == paymentId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.providerData, providerData) ||
                other.providerData == providerData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, paymentId, status, providerData);

  /// Create a copy of CardChargeResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardChargeResultImplCopyWith<_$CardChargeResultImpl> get copyWith =>
      __$$CardChargeResultImplCopyWithImpl<_$CardChargeResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CardChargeResultImplToJson(this);
  }
}

abstract class _CardChargeResult implements CardChargeResult {
  const factory _CardChargeResult({
    required final String paymentId,
    required final String status,
    final CardChargeProviderData? providerData,
  }) = _$CardChargeResultImpl;

  factory _CardChargeResult.fromJson(Map<String, dynamic> json) =
      _$CardChargeResultImpl.fromJson;

  @override
  String get paymentId;
  @override
  String get status;
  @override
  CardChargeProviderData? get providerData;

  /// Create a copy of CardChargeResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardChargeResultImplCopyWith<_$CardChargeResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CardChargeProviderData _$CardChargeProviderDataFromJson(
  Map<String, dynamic> json,
) {
  return _CardChargeProviderData.fromJson(json);
}

/// @nodoc
mixin _$CardChargeProviderData {
  String get transactionUrl => throw _privateConstructorUsedError;

  /// Serializes this CardChargeProviderData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CardChargeProviderData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardChargeProviderDataCopyWith<CardChargeProviderData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardChargeProviderDataCopyWith<$Res> {
  factory $CardChargeProviderDataCopyWith(
    CardChargeProviderData value,
    $Res Function(CardChargeProviderData) then,
  ) = _$CardChargeProviderDataCopyWithImpl<$Res, CardChargeProviderData>;
  @useResult
  $Res call({String transactionUrl});
}

/// @nodoc
class _$CardChargeProviderDataCopyWithImpl<
  $Res,
  $Val extends CardChargeProviderData
>
    implements $CardChargeProviderDataCopyWith<$Res> {
  _$CardChargeProviderDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CardChargeProviderData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? transactionUrl = null}) {
    return _then(
      _value.copyWith(
            transactionUrl: null == transactionUrl
                ? _value.transactionUrl
                : transactionUrl // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CardChargeProviderDataImplCopyWith<$Res>
    implements $CardChargeProviderDataCopyWith<$Res> {
  factory _$$CardChargeProviderDataImplCopyWith(
    _$CardChargeProviderDataImpl value,
    $Res Function(_$CardChargeProviderDataImpl) then,
  ) = __$$CardChargeProviderDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String transactionUrl});
}

/// @nodoc
class __$$CardChargeProviderDataImplCopyWithImpl<$Res>
    extends
        _$CardChargeProviderDataCopyWithImpl<$Res, _$CardChargeProviderDataImpl>
    implements _$$CardChargeProviderDataImplCopyWith<$Res> {
  __$$CardChargeProviderDataImplCopyWithImpl(
    _$CardChargeProviderDataImpl _value,
    $Res Function(_$CardChargeProviderDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CardChargeProviderData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? transactionUrl = null}) {
    return _then(
      _$CardChargeProviderDataImpl(
        transactionUrl: null == transactionUrl
            ? _value.transactionUrl
            : transactionUrl // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CardChargeProviderDataImpl implements _CardChargeProviderData {
  const _$CardChargeProviderDataImpl({required this.transactionUrl});

  factory _$CardChargeProviderDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardChargeProviderDataImplFromJson(json);

  @override
  final String transactionUrl;

  @override
  String toString() {
    return 'CardChargeProviderData(transactionUrl: $transactionUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardChargeProviderDataImpl &&
            (identical(other.transactionUrl, transactionUrl) ||
                other.transactionUrl == transactionUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, transactionUrl);

  /// Create a copy of CardChargeProviderData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardChargeProviderDataImplCopyWith<_$CardChargeProviderDataImpl>
  get copyWith =>
      __$$CardChargeProviderDataImplCopyWithImpl<_$CardChargeProviderDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CardChargeProviderDataImplToJson(this);
  }
}

abstract class _CardChargeProviderData implements CardChargeProviderData {
  const factory _CardChargeProviderData({
    required final String transactionUrl,
  }) = _$CardChargeProviderDataImpl;

  factory _CardChargeProviderData.fromJson(Map<String, dynamic> json) =
      _$CardChargeProviderDataImpl.fromJson;

  @override
  String get transactionUrl;

  /// Create a copy of CardChargeProviderData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardChargeProviderDataImplCopyWith<_$CardChargeProviderDataImpl>
  get copyWith => throw _privateConstructorUsedError;
}
