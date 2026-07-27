import 'package:freezed_annotation/freezed_annotation.dart';

part 'promo_code.freezed.dart';
part 'promo_code.g.dart';

enum DiscountType { percentage, fixed }

@freezed
class PromoCode with _$PromoCode {
  const factory PromoCode({
    required String id,
    required String code,
    required DiscountType discountType,
    required double value,
    @Default(0.0) double minOrderValue,
    required DateTime startDate,
    required DateTime endDate,
    @Default(true) bool isActive,
    int? usageLimit,
    int? perUserLimit,
  }) = _PromoCode;

  factory PromoCode.fromJson(Map<String, dynamic> json) =>
      _$PromoCodeFromJson(json);
}
