import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_offer.dart';

class MenuOffersAdminNotifier extends AutoDisposeAsyncNotifier<List<MenuOffer>> {
  @override
  Future<List<MenuOffer>> build() async {
    final repo = ref.read(adminMenuOfferRepositoryProvider);
    final result = await repo.getMenuOffers();
    return result.fold((l) => throw l, (r) => r);
  }

  Future<void> deleteMenuOffer(String id) async {
    final repo = ref.read(adminMenuOfferRepositoryProvider);
    await repo.deleteMenuOffer(id);
    ref.invalidateSelf();
    ref.invalidate(adminMenuOfferRepositoryProvider);
  }

  Future<void> toggleOfferActive(MenuOffer offer) async {
    final repo = ref.read(adminMenuOfferRepositoryProvider);
    final updated = offer.copyWith(isActive: !offer.isActive);
    await repo.updateMenuOffer(updated);
    ref.invalidateSelf();
    ref.invalidate(adminMenuOfferRepositoryProvider);
  }
}

final menuOffersAdminProvider =
    AutoDisposeAsyncNotifierProvider<MenuOffersAdminNotifier, List<MenuOffer>>(
      () => MenuOffersAdminNotifier(),
    );
