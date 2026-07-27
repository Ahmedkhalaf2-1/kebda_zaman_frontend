import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';

class AdminSettingsNotifier
    extends AutoDisposeAsyncNotifier<RestaurantSettings> {
  @override
  Future<RestaurantSettings> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final res = await repo.getAdminSettings();
    return res.fold((l) => throw l, (r) => r);
  }

  Future<void> updateSettings(RestaurantSettings settings) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.updateSettings(settings);
    ref.invalidateSelf();
    ref.invalidate(restaurantSettingsProvider);
  }
}

final adminSettingsProvider =
    AutoDisposeAsyncNotifierProvider<AdminSettingsNotifier, RestaurantSettings>(
      () {
        return AdminSettingsNotifier();
      },
    );
