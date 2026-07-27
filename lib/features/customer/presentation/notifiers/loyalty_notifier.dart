import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/loyalty.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';

class LoyaltyData {
  final LoyaltyAccount account;
  final List<LoyaltyTransaction> history;
  final RestaurantSettings settings;

  LoyaltyData({
    required this.account,
    required this.history,
    required this.settings,
  });
}

class LoyaltyNotifier extends AutoDisposeAsyncNotifier<LoyaltyData> {
  @override
  Future<LoyaltyData> build() async {
    final repo = ref.read(loyaltyRepositoryProvider);
    final settings = await ref.watch(restaurantSettingsProvider.future);
    final authState = ref.read(authNotifierProvider);

    if (!authState.isLoggedIn || (authState.user?.isGuest ?? false)) {
      return LoyaltyData(
        account: const LoyaltyAccount(
          userId: 'guest',
          pointsBalance: 0,
          lifetimePointsEarned: 0,
        ),
        history: [],
        settings: settings,
      );
    }

    final accResult = await repo.getMeLoyalty();
    final histResult = await repo.getMeLoyaltyTransactions();

    final account = accResult.fold(
      (f) => const LoyaltyAccount(
        userId: '',
        pointsBalance: 0,
        lifetimePointsEarned: 0,
      ),
      (data) => data,
    );
    final history = histResult.fold(
      (f) => <LoyaltyTransaction>[],
      (data) => data,
    );

    return LoyaltyData(account: account, history: history, settings: settings);
  }
}

final loyaltyProvider =
    AutoDisposeAsyncNotifierProvider<LoyaltyNotifier, LoyaltyData>(
      () => LoyaltyNotifier(),
    );
