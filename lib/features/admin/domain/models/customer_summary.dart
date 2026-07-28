import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

part 'customer_summary.freezed.dart';

/// Concise recent-order fields for the Customer Details screen
/// (PHASE_6_CUSTOMER_MANAGEMENT_API_CONTRACT.md — `CustomerDetailDto.recentOrders`).
/// Mapped manually in `ApiCustomerRepository` (not via generated JSON codegen)
/// to reuse the same defensive enum-fallback handling as `ApiOrderRepository`.
@freezed
class RecentOrderSummary with _$RecentOrderSummary {
  const factory RecentOrderSummary({
    required String id,
    required String orderNumber,
    required OrderStatus status,
    required double totalAmount,
    String? paymentMethod,
    required FulfillmentType fulfillmentType,
    required DateTime createdAt,
  }) = _RecentOrderSummary;
}

/// `CustomerListItemDto` — one row in `GET /admin/customers`.
@freezed
class CustomerSummary with _$CustomerSummary {
  const factory CustomerSummary({
    required String id,
    required String name,
    String? email,
    String? phone,
    required bool isGuest,
    required bool isActive,
    required DateTime createdAt,
    required int orderCount,
    required double totalSpent,
  }) = _CustomerSummary;
}

/// `CustomerDetailDto` — `CustomerListItemDto` fields + recent orders.
@freezed
class CustomerDetail with _$CustomerDetail {
  const factory CustomerDetail({
    required CustomerSummary summary,
    required List<RecentOrderSummary> recentOrders,
  }) = _CustomerDetail;
}
