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
    // Global usage cap — backend field `maxUsage`. `null` means unlimited;
    // this exact convention is reused everywhere (model, payload, and the
    // admin form's "leave empty for unlimited" UX), never a second field.
    int? usageLimit,
    // Per-customer usage cap — backend field `perUserLimit`. Same
    // null-means-unlimited convention as [usageLimit].
    int? perUserLimit,
    // How many times this code has actually been successfully redeemed —
    // backend field `usageCount`, returned on every admin list/detail
    // response (AdminPromoResponseDto). Read-only from Flutter's side: it's
    // never sent in a create/update payload, only displayed.
    @Default(0) int usageCount,
  }) = _PromoCode;

  factory PromoCode.fromJson(Map<String, dynamic> json) =>
      _$PromoCodeFromJson(json);
}
