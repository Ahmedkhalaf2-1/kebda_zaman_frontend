import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/delivery_zone.dart';

/// Active delivery zones for the checkout picker (`GET /delivery-zones`,
/// public/no-auth). One canonical source — checkout reads this provider
/// directly rather than re-fetching per rebuild.
final deliveryZonesProvider = FutureProvider.autoDispose<List<DeliveryZone>>((
  ref,
) async {
  final repo = ref.read(deliveryZoneRepositoryProvider);
  final result = await repo.getPublicZones();
  return result.fold((f) => throw f, (zones) => zones);
});
