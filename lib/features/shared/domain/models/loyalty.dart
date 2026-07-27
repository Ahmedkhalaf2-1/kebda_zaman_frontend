import 'package:freezed_annotation/freezed_annotation.dart';

part 'loyalty.freezed.dart';
part 'loyalty.g.dart';

@freezed
class LoyaltyAccount with _$LoyaltyAccount {
  const factory LoyaltyAccount({
    required String userId,
    @Default(0) int pointsBalance,
    @Default(0) int lifetimePointsEarned,
  }) = _LoyaltyAccount;

  factory LoyaltyAccount.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyAccountFromJson(json);
}

enum LoyaltyTransactionType { earn, redeem, adjust }

@freezed
class LoyaltyTransaction with _$LoyaltyTransaction {
  const factory LoyaltyTransaction({
    required String id,
    required String userId,
    String? orderId,
    required LoyaltyTransactionType type,
    required int points,
    required int balanceAfter,
    required DateTime createdAt,
  }) = _LoyaltyTransaction;

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyTransactionFromJson(json);
}
