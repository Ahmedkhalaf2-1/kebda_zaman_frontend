// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentIntentImpl _$$PaymentIntentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentIntentImpl(
      paymentId: json['paymentId'] as String,
      status: json['status'] as String,
      providerData: PaymentIntentProviderData.fromJson(
        json['providerData'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$$PaymentIntentImplToJson(_$PaymentIntentImpl instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'status': instance.status,
      'providerData': instance.providerData,
    };

_$PaymentIntentProviderDataImpl _$$PaymentIntentProviderDataImplFromJson(
  Map<String, dynamic> json,
) => _$PaymentIntentProviderDataImpl(
  publishableApiKey: json['publishableApiKey'] as String?,
  amount: (json['amount'] as num).toInt(),
  currency: json['currency'] as String,
  orderId: json['orderId'] as String,
  description: json['description'] as String?,
  callbackUrl: json['callbackUrl'] as String?,
  manual: json['manual'] as bool? ?? false,
  instructions: json['instructions'] as String?,
);

Map<String, dynamic> _$$PaymentIntentProviderDataImplToJson(
  _$PaymentIntentProviderDataImpl instance,
) => <String, dynamic>{
  'publishableApiKey': instance.publishableApiKey,
  'amount': instance.amount,
  'currency': instance.currency,
  'orderId': instance.orderId,
  'description': instance.description,
  'callbackUrl': instance.callbackUrl,
  'manual': instance.manual,
  'instructions': instance.instructions,
};

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      method: json['method'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      provider: json['provider'] as String,
      providerRef: json['providerRef'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'method': instance.method,
      'status': instance.status,
      'amount': instance.amount,
      'currency': instance.currency,
      'provider': instance.provider,
      'providerRef': instance.providerRef,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$SavedCardImpl _$$SavedCardImplFromJson(Map<String, dynamic> json) =>
    _$SavedCardImpl(
      id: json['id'] as String,
      brand: json['brand'] as String,
      lastFour: json['lastFour'] as String,
      expMonth: (json['expMonth'] as num).toInt(),
      expYear: (json['expYear'] as num).toInt(),
      isDefault: json['isDefault'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SavedCardImplToJson(_$SavedCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brand': instance.brand,
      'lastFour': instance.lastFour,
      'expMonth': instance.expMonth,
      'expYear': instance.expYear,
      'isDefault': instance.isDefault,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$CardChargeResultImpl _$$CardChargeResultImplFromJson(
  Map<String, dynamic> json,
) => _$CardChargeResultImpl(
  paymentId: json['paymentId'] as String,
  status: json['status'] as String,
  providerData: json['providerData'] == null
      ? null
      : CardChargeProviderData.fromJson(
          json['providerData'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$CardChargeResultImplToJson(
  _$CardChargeResultImpl instance,
) => <String, dynamic>{
  'paymentId': instance.paymentId,
  'status': instance.status,
  'providerData': instance.providerData,
};

_$CardChargeProviderDataImpl _$$CardChargeProviderDataImplFromJson(
  Map<String, dynamic> json,
) => _$CardChargeProviderDataImpl(
  transactionUrl: json['transactionUrl'] as String,
);

Map<String, dynamic> _$$CardChargeProviderDataImplToJson(
  _$CardChargeProviderDataImpl instance,
) => <String, dynamic>{'transactionUrl': instance.transactionUrl};
