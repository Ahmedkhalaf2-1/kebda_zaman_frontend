// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RestaurantSettingsImpl _$$RestaurantSettingsImplFromJson(
  Map<String, dynamic> json,
) => _$RestaurantSettingsImpl(
  name: json['name'] as String? ?? 'Kebda Zaman',
  logoUrl: json['logoUrl'] as String? ?? '',
  address: json['address'] as String? ?? '',
  operatingHours:
      (json['operatingHours'] as List<dynamic>?)
          ?.map((e) => OperatingHours.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 15.0,
  minOrderValue: (json['minOrderValue'] as num?)?.toDouble() ?? 50.0,
  pickupLocations:
      (json['pickupLocations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  isOpen: json['isOpen'] as bool? ?? true,
  phone: json['phone'] as String? ?? '01000000000',
  taxRatePercent: (json['taxRatePercent'] as num?)?.toDouble() ?? 14.0,
  currency: json['currency'] as String? ?? 'EGP',
  workingHoursOpen: json['workingHoursOpen'] as String? ?? '09:00',
  workingHoursClose: json['workingHoursClose'] as String? ?? '23:00',
  loyaltyEgpStep: (json['loyaltyEgpStep'] as num?)?.toDouble() ?? 10.0,
  loyaltyPointsPerStep: (json['loyaltyPointsPerStep'] as num?)?.toInt() ?? 1,
  loyaltyEarnRatePerCurrencyUnit:
      (json['loyaltyEarnRatePerCurrencyUnit'] as num?)?.toDouble() ?? 1.0,
  loyaltyMinRedemptionPoints:
      (json['loyaltyMinRedemptionPoints'] as num?)?.toInt() ?? 100,
  loyaltyMaxDiscountFromPoints:
      (json['loyaltyMaxDiscountFromPoints'] as num?)?.toDouble() ?? 50.0,
);

Map<String, dynamic> _$$RestaurantSettingsImplToJson(
  _$RestaurantSettingsImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'logoUrl': instance.logoUrl,
  'address': instance.address,
  'operatingHours': instance.operatingHours,
  'deliveryFee': instance.deliveryFee,
  'minOrderValue': instance.minOrderValue,
  'pickupLocations': instance.pickupLocations,
  'isOpen': instance.isOpen,
  'phone': instance.phone,
  'taxRatePercent': instance.taxRatePercent,
  'currency': instance.currency,
  'workingHoursOpen': instance.workingHoursOpen,
  'workingHoursClose': instance.workingHoursClose,
  'loyaltyEgpStep': instance.loyaltyEgpStep,
  'loyaltyPointsPerStep': instance.loyaltyPointsPerStep,
  'loyaltyEarnRatePerCurrencyUnit': instance.loyaltyEarnRatePerCurrencyUnit,
  'loyaltyMinRedemptionPoints': instance.loyaltyMinRedemptionPoints,
  'loyaltyMaxDiscountFromPoints': instance.loyaltyMaxDiscountFromPoints,
};

_$OperatingHoursImpl _$$OperatingHoursImplFromJson(Map<String, dynamic> json) =>
    _$OperatingHoursImpl(
      day: json['day'] as String,
      openTime: json['openTime'] as String,
      closeTime: json['closeTime'] as String,
    );

Map<String, dynamic> _$$OperatingHoursImplToJson(
  _$OperatingHoursImpl instance,
) => <String, dynamic>{
  'day': instance.day,
  'openTime': instance.openTime,
  'closeTime': instance.closeTime,
};
