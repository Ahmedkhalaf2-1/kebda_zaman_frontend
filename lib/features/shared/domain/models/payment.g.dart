// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaymentImpl _$$PaymentImplFromJson(Map<String, dynamic> json) =>
    _$PaymentImpl(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
      amount: (json['amount'] as num).toDouble(),
      status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
      provider:
          $enumDecodeNullable(_$PaymentProviderEnumMap, json['provider']) ??
          PaymentProvider.mock,
      transactionRef: json['transactionRef'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PaymentImplToJson(_$PaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'method': _$PaymentMethodEnumMap[instance.method]!,
      'amount': instance.amount,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'provider': _$PaymentProviderEnumMap[instance.provider]!,
      'transactionRef': instance.transactionRef,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.cash: 'cash',
  PaymentMethod.card: 'card',
  PaymentMethod.wallet: 'wallet',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'pending',
  PaymentStatus.success: 'success',
  PaymentStatus.failed: 'failed',
  PaymentStatus.cancelled: 'cancelled',
};

const _$PaymentProviderEnumMap = {
  PaymentProvider.mock: 'mock',
  PaymentProvider.stripe: 'stripe',
  PaymentProvider.paymob: 'paymob',
};
