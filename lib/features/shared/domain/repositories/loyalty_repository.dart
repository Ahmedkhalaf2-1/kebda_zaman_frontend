import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/loyalty.dart';

/// Loyalty repository interface per md1 §23.
abstract class LoyaltyRepository {
  Future<Result<LoyaltyAccount>> getAccount(String userId);
  Future<Result<List<LoyaltyTransaction>>> getTransactions(String userId);
  Future<Result<LoyaltyAccount>> getMeLoyalty();
  Future<Result<List<LoyaltyTransaction>>> getMeLoyaltyTransactions();
  Future<Result<Map<String, dynamic>>> redeemReward(String rewardId);
  Future<Result<LoyaltyTransaction>> earnPoints({
    required String userId,
    required String orderId,
    required int points,
  });
  Future<Result<LoyaltyTransaction>> redeemPoints({
    required String userId,
    required String orderId,
    required int points,
  });
  Future<Result<void>> revertRedemption(String transactionId);
}
