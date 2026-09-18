/// Counts returned by both `GET /admin/orders/reset-preview` (a dry run)
/// and `DELETE /admin/orders/reset` (the actual deletion) — the backend
/// returns the identical shape from both, computed before any deletion
/// runs, so one model covers both calls.
class OrdersResetSummary {
  final int orders;
  final int items;
  final int payments;
  final int reviews;
  final int feedback;

  const OrdersResetSummary({
    required this.orders,
    required this.items,
    required this.payments,
    required this.reviews,
    required this.feedback,
  });

  factory OrdersResetSummary.fromJson(Map<String, dynamic> json) {
    return OrdersResetSummary(
      orders: (json['orders'] as num?)?.toInt() ?? 0,
      items: (json['items'] as num?)?.toInt() ?? 0,
      payments: (json['payments'] as num?)?.toInt() ?? 0,
      reviews: (json['reviews'] as num?)?.toInt() ?? 0,
      feedback: (json['feedback'] as num?)?.toInt() ?? 0,
    );
  }
}
