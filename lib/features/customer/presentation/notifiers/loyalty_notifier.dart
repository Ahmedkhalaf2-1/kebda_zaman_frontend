import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/loyalty.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';

class LoyaltyData {
  final LoyaltyAccount account;
  final List<LoyaltyTransaction> history;
  final LoyaltyPolicy policy;

  LoyaltyData({
    required this.account,
    required this.history,
    required this.policy,
  });
}

class LoyaltyNotifier extends AutoDisposeAsyncNotifier<LoyaltyData> {
  @override
  Future<LoyaltyData> build() async {
    final repo = ref.read(loyaltyRepositoryProvider);
    final authState = ref.read(authNotifierProvider);
    const policy = LoyaltyPolicy.standard;

    if (!authState.isLoggedIn || (authState.user?.isGuest ?? false)) {
      return LoyaltyData(
        account: const LoyaltyAccount(
          userId: 'guest',
          pointsBalance: 0,
          lifetimePointsEarned: 0,
        ),
        history: [],
        policy: policy,
      );
    }

    final accResult = await repo.getMeLoyalty();
    final histResult = await repo.getMeLoyaltyTransactions();

    // Do NOT convert failures to zero/empty — that hides real API errors and
    // makes a failed request indistinguishable from a legitimate zero balance.
    // Throw the failure so the AutoDisposeAsyncNotifier surfaces AsyncError,
    // which the UI can display separately from a successful zero-point balance.
    final account = accResult.fold((f) => throw f, (data) => data);
    final history = histResult.fold((f) => throw f, (data) => data);

    return LoyaltyData(account: account, history: history, policy: policy);
  }
}

final loyaltyProvider =
    AutoDisposeAsyncNotifierProvider<LoyaltyNotifier, LoyaltyData>(
      () => LoyaltyNotifier(),
    );
