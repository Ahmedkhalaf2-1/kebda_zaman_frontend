import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_offer.dart';

/// Customer-facing Menu Offers feed (`GET /menu-offers`, public). A plain
/// `FutureProvider` — same shape as [itemDetailsProvider]/`homeDataProvider`
/// — since this is read-only supplementary content with no local mutation.
/// Deliberately independent of `menuNotifierProvider`: a failure here must
/// never block the Menu itself, so the two are watched separately and the
/// Menu screen's offers section simply collapses on error instead of
/// surfacing a blocking error state.
final customerMenuOffersProvider = FutureProvider<List<MenuOffer>>((
  ref,
) async {
  final repo = ref.watch(menuRepositoryProvider);
  final result = await repo.getMenuOffers();
  return result.fold((f) => throw Exception(f.message), (data) => data);
});
