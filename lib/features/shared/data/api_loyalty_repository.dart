import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/loyalty.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/loyalty_repository.dart';

class ApiLoyaltyRepository implements LoyaltyRepository {
  final ApiClient _apiClient;

  ApiLoyaltyRepository(this._apiClient);

  Failure _handleError(dynamic e, String defaultMsg) {
    if (e is DioException) {
      if (e.error is ApiException) {
        final apiEx = e.error as ApiException;
        if (apiEx.code == 'GUEST_NOT_ELIGIBLE' ||
            e.response?.statusCode == 403) {
          return AuthFailure(apiEx.message, apiEx);
        }
        if (apiEx.code == 'REWARD_NOT_FOUND' || e.response?.statusCode == 404) {
          return NotFoundFailure(apiEx.message, apiEx);
        }
        if (apiEx.code == 'INSUFFICIENT_POINTS' ||
            e.response?.statusCode == 422) {
          return ValidationFailure(apiEx.message, apiEx);
        }
        return NetworkFailure(apiEx.message, apiEx);
      }
      return NetworkFailure(e.message ?? defaultMsg);
    }
    return UnknownFailure(e.toString());
  }

  LoyaltyAccount _mapAccount(Map<String, dynamic> json) {
    return LoyaltyAccount(
      userId: json['userId'] ?? '',
      pointsBalance: (json['pointsBalance'] as num?)?.toInt() ?? 0,
      lifetimePointsEarned: (json['pointsBalance'] as num?)?.toInt() ?? 0,
    );
  }

  LoyaltyTransaction _mapTransaction(Map<String, dynamic> json) {
    final delta = (json['delta'] as num?)?.toInt() ?? 0;
    return LoyaltyTransaction(
      id: json['id'] ?? '',
      userId: '',
      orderId: json['orderId'],
      type: delta >= 0
          ? LoyaltyTransactionType.earn
          : LoyaltyTransactionType.redeem,
      points: delta.abs(),
      balanceAfter: 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  @override
  Future<Result<LoyaltyAccount>> getMeLoyalty() async {
    try {
      final response = await _apiClient.dio.get('/me/loyalty');
      return Success(_mapAccount(response.data as Map<String, dynamic>));
    } catch (e) {
      return Err(_handleError(e, 'Failed to fetch loyalty account'));
    }
  }

  @override
  Future<Result<List<LoyaltyTransaction>>> getMeLoyaltyTransactions() async {
    try {
      final response = await _apiClient.dio.get('/me/loyalty/transactions');
      final list = (response.data as List)
          .map((item) => _mapTransaction(item as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Err(_handleError(e, 'Failed to fetch loyalty transactions'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> redeemReward(String rewardId) async {
    try {
      final response = await _apiClient.dio.post(
        '/me/loyalty/redeem',
        data: {'rewardId': rewardId},
      );
      return Success(response.data as Map<String, dynamic>);
    } catch (e) {
      return Err(_handleError(e, 'Failed to redeem reward'));
    }
  }

  @override
  Future<Result<LoyaltyAccount>> getAccount(String userId) => getMeLoyalty();

  @override
  Future<Result<List<LoyaltyTransaction>>> getTransactions(String userId) =>
      getMeLoyaltyTransactions();

  @override
  Future<Result<LoyaltyTransaction>> earnPoints({
    required String userId,
    required String orderId,
    required int points,
  }) async {
    return const Err(
      UnknownFailure(
        'Points earned automatically by backend upon order delivery.',
      ),
    );
  }

  @override
  Future<Result<LoyaltyTransaction>> redeemPoints({
    required String userId,
    required String orderId,
    required int points,
  }) async {
    return const Err(UnknownFailure('Use redeemReward(rewardId) endpoint.'));
  }

  @override
  Future<Result<void>> revertRedemption(String transactionId) async {
    return const Success(null);
  }
}
