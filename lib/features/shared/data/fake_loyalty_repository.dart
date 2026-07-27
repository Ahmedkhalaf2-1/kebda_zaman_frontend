import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/loyalty.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/loyalty_repository.dart';

class FakeLoyaltyRepository implements LoyaltyRepository {
  static const _accountKey = 'loyalty_account_state';
  static const _txKey = 'loyalty_transactions_state';

  LoyaltyAccount _account = const LoyaltyAccount(
    userId: 'user_1',
    pointsBalance: 0,
    lifetimePointsEarned: 0,
  );
  List<LoyaltyTransaction> _transactions = [];
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final accountJson = prefs.getString(_accountKey);
    if (accountJson != null) {
      try {
        _account = LoyaltyAccount.fromJson(jsonDecode(accountJson));
      } catch (_) {}
    }

    final txJson = prefs.getString(_txKey);
    if (txJson != null) {
      try {
        final List list = jsonDecode(txJson);
        _transactions = list
            .map((item) => LoyaltyTransaction.fromJson(item))
            .toList();
      } catch (_) {}
    }
    _initialized = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accountKey, jsonEncode(_account.toJson()));
    await prefs.setString(
      _txKey,
      jsonEncode(_transactions.map((t) => t.toJson()).toList()),
    );
  }

  @override
  Future<Result<LoyaltyAccount>> getAccount(String userId) async {
    await _init();
    return Success(_account);
  }

  @override
  Future<Result<List<LoyaltyTransaction>>> getTransactions(
    String userId,
  ) async {
    await _init();
    return Success(_transactions);
  }

  @override
  Future<Result<LoyaltyAccount>> getMeLoyalty() async {
    await _init();
    return Success(_account);
  }

  @override
  Future<Result<List<LoyaltyTransaction>>> getMeLoyaltyTransactions() async {
    await _init();
    return Success(_transactions);
  }

  @override
  Future<Result<Map<String, dynamic>>> redeemReward(String rewardId) async {
    await _init();
    return Success({
      'account': _account.toJson(),
      'redemption': {
        'rewardId': rewardId,
        'rewardName': 'Reward',
        'pointsCost': 100,
        'transactionId': 'tx_123',
        'redeemedAt': DateTime.now().toIso8601String(),
      },
    });
  }

  @override
  Future<Result<LoyaltyTransaction>> earnPoints({
    required String userId,
    required String orderId,
    required int points,
  }) async {
    await _init();
    _account = _account.copyWith(
      pointsBalance: _account.pointsBalance + points,
      lifetimePointsEarned: _account.lifetimePointsEarned + points,
    );

    final tx = LoyaltyTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      orderId: orderId,
      type: LoyaltyTransactionType.earn,
      points: points,
      balanceAfter: _account.pointsBalance,
      createdAt: DateTime.now(),
    );
    _transactions.insert(0, tx);

    await _persist();
    return Success(tx);
  }

  @override
  Future<Result<LoyaltyTransaction>> redeemPoints({
    required String userId,
    required String orderId,
    required int points,
  }) async {
    await _init();
    if (_account.pointsBalance < points) {
      return const Err(UnknownFailure('Not enough points'));
    }
    _account = _account.copyWith(
      pointsBalance: _account.pointsBalance - points,
    );
    final tx = LoyaltyTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      orderId: orderId,
      type: LoyaltyTransactionType.redeem,
      points: points,
      balanceAfter: _account.pointsBalance,
      createdAt: DateTime.now(),
    );
    _transactions.insert(0, tx);

    await _persist();
    return Success(tx);
  }

  @override
  Future<Result<void>> revertRedemption(String transactionId) async {
    return const Success(null);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    _account = const LoyaltyAccount(
      userId: 'user_1',
      pointsBalance: 0,
      lifetimePointsEarned: 0,
    );
    _transactions.clear();
    await prefs.remove(_accountKey);
    await prefs.remove(_txKey);
  }
}
