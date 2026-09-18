// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentIntent _$PaymentIntentFromJson(Map<String, dynamic> json) =>
    _PaymentIntent(
      paymentId: json['paymentId'] as String,
      status: json['status'] as String,
      providerData: PaymentIntentProviderData.fromJson(
        json['providerData'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$PaymentIntentToJson(_PaymentIntent instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'status': instance.status,
      'providerData': instance.providerData,
    };

_PaymentIntentProviderData _$PaymentIntentProviderDataFromJson(
  Map<String, dynamic> json,
) => _PaymentIntentProviderData(
  publishableApiKey: json['publishableApiKey'] as String?,
  amount: (json['amount'] as num).toInt(),
  currency: json['currency'] as String,
  orderId: json['orderId'] as String,
  description: json['description'] as String?,
  callbackUrl: json['callbackUrl'] as String?,
  manual: json['manual'] as bool? ?? false,
  instructions: json['instructions'] as String?,
);

Map<String, dynamic> _$PaymentIntentProviderDataToJson(
  _PaymentIntentProviderData instance,
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

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
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

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
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

_SavedCard _$SavedCardFromJson(Map<String, dynamic> json) => _SavedCard(
  id: json['id'] as String,
  brand: json['brand'] as String,
  lastFour: json['lastFour'] as String,
  expMonth: (json['expMonth'] as num).toInt(),
  expYear: (json['expYear'] as num).toInt(),
  isDefault: json['isDefault'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$SavedCardToJson(_SavedCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brand': instance.brand,
      'lastFour': instance.lastFour,
      'expMonth': instance.expMonth,
      'expYear': instance.expYear,
      'isDefault': instance.isDefault,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_CardChargeResult _$CardChargeResultFromJson(Map<String, dynamic> json) =>
    _CardChargeResult(
      paymentId: json['paymentId'] as String,
      status: json['status'] as String,
      providerData: json['providerData'] == null
          ? null
          : CardChargeProviderData.fromJson(
              json['providerData'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$CardChargeResultToJson(_CardChargeResult instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'status': instance.status,
      'providerData': instance.providerData,
    };

_CardChargeProviderData _$CardChargeProviderDataFromJson(
  Map<String, dynamic> json,
) => _CardChargeProviderData(transactionUrl: json['transactionUrl'] as String);

Map<String, dynamic> _$CardChargeProviderDataToJson(
  _CardChargeProviderData instance,
) => <String, dynamic>{'transactionUrl': instance.transactionUrl};
