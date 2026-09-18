// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoyaltyAccount _$LoyaltyAccountFromJson(Map<String, dynamic> json) =>
    _LoyaltyAccount(
      userId: json['userId'] as String,
      pointsBalance: (json['pointsBalance'] as num?)?.toInt() ?? 0,
      lifetimePointsEarned:
          (json['lifetimePointsEarned'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$LoyaltyAccountToJson(_LoyaltyAccount instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'pointsBalance': instance.pointsBalance,
      'lifetimePointsEarned': instance.lifetimePointsEarned,
    };

_LoyaltyTransaction _$LoyaltyTransactionFromJson(Map<String, dynamic> json) =>
    _LoyaltyTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      orderId: json['orderId'] as String?,
      type: $enumDecode(_$LoyaltyTransactionTypeEnumMap, json['type']),
      points: (json['points'] as num).toInt(),
      balanceAfter: (json['balanceAfter'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LoyaltyTransactionToJson(_LoyaltyTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'orderId': instance.orderId,
      'type': _$LoyaltyTransactionTypeEnumMap[instance.type]!,
      'points': instance.points,
      'balanceAfter': instance.balanceAfter,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$LoyaltyTransactionTypeEnumMap = {
  LoyaltyTransactionType.earn: 'earn',
  LoyaltyTransactionType.redeem: 'redeem',
  LoyaltyTransactionType.adjust: 'adjust',
};
