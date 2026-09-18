/// Counts returned by both `GET /admin/customers/reset-preview` (a dry run)
/// and `DELETE /admin/customers/reset` (the actual wipe) — the backend
/// returns the identical shape from both. This reset never touches
/// customer accounts/logins: it only zeroes loyalty balances and clears
/// loyalty/review/feedback history, so there's no `customers` count here.
class CustomersResetSummary {
  final int loyaltyAccounts;
  final int pointsCleared;
  final int transactions;
  final int reviews;
  final int feedback;

  const CustomersResetSummary({
    required this.loyaltyAccounts,
    required this.pointsCleared,
    required this.transactions,
    required this.reviews,
    required this.feedback,
  });

  factory CustomersResetSummary.fromJson(Map<String, dynamic> json) {
    return CustomersResetSummary(
      loyaltyAccounts: (json['loyaltyAccounts'] as num?)?.toInt() ?? 0,
      pointsCleared: (json['pointsCleared'] as num?)?.toInt() ?? 0,
      transactions: (json['transactions'] as num?)?.toInt() ?? 0,
      reviews: (json['reviews'] as num?)?.toInt() ?? 0,
      feedback: (json['feedback'] as num?)?.toInt() ?? 0,
    );
  }
}
