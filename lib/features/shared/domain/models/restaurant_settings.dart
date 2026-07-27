import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant_settings.freezed.dart';
part 'restaurant_settings.g.dart';

@freezed
class RestaurantSettings with _$RestaurantSettings {
  const factory RestaurantSettings({
    @Default('Kebda Zaman') String name,
    @Default('') String logoUrl,
    @Default('') String address,
    @Default([]) List<OperatingHours> operatingHours,
    @Default(15.0) double deliveryFee,
    @Default(50.0) double minOrderValue,
    @Default([]) List<String> pickupLocations,
    @Default(true) bool isOpen,
    @Default('01000000000') String phone,
    @Default(14.0) double taxRatePercent,
    @Default('EGP') String currency,
    @Default('09:00') String workingHoursOpen,
    @Default('23:00') String workingHoursClose,
    @Default(10.0) double loyaltyEgpStep,
    @Default(1) int loyaltyPointsPerStep,
    @Default(1.0) double loyaltyEarnRatePerCurrencyUnit,
    @Default(100) int loyaltyMinRedemptionPoints,
    @Default(50.0) double loyaltyMaxDiscountFromPoints,
  }) = _RestaurantSettings;

  factory RestaurantSettings.fromJson(Map<String, dynamic> json) =>
      _$RestaurantSettingsFromJson(json);
}

@freezed
class OperatingHours with _$OperatingHours {
  const factory OperatingHours({
    required String day,
    required String openTime,
    required String closeTime,
  }) = _OperatingHours;

  factory OperatingHours.fromJson(Map<String, dynamic> json) =>
      _$OperatingHoursFromJson(json);
}
