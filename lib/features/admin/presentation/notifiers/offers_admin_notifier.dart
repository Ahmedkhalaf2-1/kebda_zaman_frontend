import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/promo_code.dart';

class OffersAdminNotifier extends AutoDisposeAsyncNotifier<List<PromoCode>> {
  @override
  Future<List<PromoCode>> build() async {
    final repo = ref.read(promoRepositoryProvider);
    final result = await repo.getAllPromos();
    return result.fold((l) => throw l, (r) => r);
  }

  Future<void> deletePromo(String id) async {
    final repo = ref.read(promoRepositoryProvider);
    await repo.deletePromo(id);
    ref.invalidateSelf();
    ref.invalidate(promoRepositoryProvider);
  }

  Future<void> togglePromoAvailability(PromoCode promo) async {
    final repo = ref.read(promoRepositoryProvider);
    final updated = promo.copyWith(isActive: !promo.isActive);
    await repo.updatePromo(updated);
    ref.invalidateSelf();
    ref.invalidate(promoRepositoryProvider);
  }
}

final offersAdminProvider =
    AutoDisposeAsyncNotifierProvider<OffersAdminNotifier, List<PromoCode>>(() {
      return OffersAdminNotifier();
    });
