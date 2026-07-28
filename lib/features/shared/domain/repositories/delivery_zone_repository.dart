import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/delivery_zone.dart';

abstract class DeliveryZoneRepository {
  /// Public — active zones only, used by checkout's delivery-zone picker.
  Future<Result<List<DeliveryZone>>> getPublicZones();

  /// ADMIN only — every non-deleted zone (active and inactive).
  Future<Result<List<DeliveryZone>>> getAdminZones();

  Future<Result<DeliveryZone>> createZone({
    required String nameAr,
    required String nameEn,
    required double deliveryFee,
    required double minimumOrder,
    bool isActive,
    int sortOrder,
  });

  Future<Result<DeliveryZone>> updateZone(
    String id, {
    required String nameAr,
    required String nameEn,
    required double deliveryFee,
    required double minimumOrder,
    required bool isActive,
    required int sortOrder,
  });

  /// Soft delete — mirrors the existing Category/PromoCode convention.
  Future<Result<void>> deleteZone(String id);
}
