// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promo_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PromoCodeImpl _$$PromoCodeImplFromJson(Map<String, dynamic> json) =>
    _$PromoCodeImpl(
      id: json['id'] as String,
      code: json['code'] as String,
      discountType: $enumDecode(_$DiscountTypeEnumMap, json['discountType']),
      value: (json['value'] as num).toDouble(),
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      usageLimit: (json['usageLimit'] as num?)?.toInt(),
      perUserLimit: (json['perUserLimit'] as num?)?.toInt(),
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PromoCodeImplToJson(_$PromoCodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'discountType': _$DiscountTypeEnumMap[instance.discountType]!,
      'value': instance.value,
      'minOrderValue': instance.minOrderValue,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'isActive': instance.isActive,
      'usageLimit': instance.usageLimit,
      'perUserLimit': instance.perUserLimit,
      'usageCount': instance.usageCount,
    };

const _$DiscountTypeEnumMap = {
  DiscountType.percentage: 'percentage',
  DiscountType.fixed: 'fixed',
};
