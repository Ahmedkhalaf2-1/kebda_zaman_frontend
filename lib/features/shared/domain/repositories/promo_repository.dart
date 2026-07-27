import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/promo_code.dart';

/// Promo code repository interface per md1 §25.
abstract class PromoRepository {
  Future<Result<PromoCode?>> getPromoByCode(String code);
  Future<Result<List<PromoCode>>> getAllPromos();
  Future<Result<bool>> validatePromo(String code, double orderSubtotal);

  // Admin CRUD
  Future<Result<void>> createPromo(PromoCode promo);
  Future<Result<void>> updatePromo(PromoCode promo);
  Future<Result<void>> deletePromo(String id);
}
