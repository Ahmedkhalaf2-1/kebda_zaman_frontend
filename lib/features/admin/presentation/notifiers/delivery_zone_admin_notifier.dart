import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/delivery_zone_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/delivery_zone.dart';

class DeliveryZoneAdminNotifier
    extends AutoDisposeAsyncNotifier<List<DeliveryZone>> {
  @override
  Future<List<DeliveryZone>> build() async {
    final repo = ref.read(deliveryZoneRepositoryProvider);
    final result = await repo.getAdminZones();
    return result.fold((f) => throw f, (zones) => zones);
  }

  Future<void> createZone({
    required String nameAr,
    required String nameEn,
    required double deliveryFee,
    required double minimumOrder,
    bool isActive = true,
    int sortOrder = 0,
  }) async {
    final repo = ref.read(deliveryZoneRepositoryProvider);
    final result = await repo.createZone(
      nameAr: nameAr,
      nameEn: nameEn,
      deliveryFee: deliveryFee,
      minimumOrder: minimumOrder,
      isActive: isActive,
      sortOrder: sortOrder,
    );
    result.fold((f) => throw f, (_) => null);
    _refreshAll();
  }

  Future<void> updateZone(
    String id, {
    required String nameAr,
    required String nameEn,
    required double deliveryFee,
    required double minimumOrder,
    required bool isActive,
    required int sortOrder,
  }) async {
    final repo = ref.read(deliveryZoneRepositoryProvider);
    final result = await repo.updateZone(
      id,
      nameAr: nameAr,
      nameEn: nameEn,
      deliveryFee: deliveryFee,
      minimumOrder: minimumOrder,
      isActive: isActive,
      sortOrder: sortOrder,
    );
    result.fold((f) => throw f, (_) => null);
    _refreshAll();
  }

  Future<void> toggleActive(DeliveryZone zone) async {
    await updateZone(
      zone.id,
      nameAr: zone.nameAr,
      nameEn: zone.nameEn,
      deliveryFee: zone.deliveryFee,
      minimumOrder: zone.minimumOrder,
      isActive: !zone.isActive,
      sortOrder: zone.sortOrder,
    );
  }

  Future<void> deleteZone(String id) async {
    final repo = ref.read(deliveryZoneRepositoryProvider);
    final result = await repo.deleteZone(id);
    result.fold((f) => throw f, (_) => null);
    _refreshAll();
  }

  void _refreshAll() {
    ref.invalidateSelf();
    // Public zone list (used by customer checkout) can change shape too
    // (activation, fee, minimum) — keep it in sync with admin edits.
    ref.invalidate(deliveryZonesProvider);
  }
}

final deliveryZoneAdminProvider =
    AutoDisposeAsyncNotifierProvider<
      DeliveryZoneAdminNotifier,
      List<DeliveryZone>
    >(DeliveryZoneAdminNotifier.new);
