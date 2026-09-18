import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

part 'driver_order.freezed.dart';
part 'driver_order.g.dart';

/// Read-only "delivery ticket" for the DRIVER role
/// (DRIVER_DELIVERY_API_CONTRACT.md, `DriverOrderResponseDto`) — a much
/// smaller shape than the admin/customer [Order]: never a pricing breakdown
/// beyond the total, never promo/loyalty detail, never payment-provider
/// internals, never the customer's email. Reuses [OrderStatus]/
/// [FulfillmentType]/[OrderItem]/[OrderDeliveryAddress] from the shared
/// order model since the wire shapes are identical.
@freezed
abstract class DriverOrder with _$DriverOrder {
  const factory DriverOrder({
    required String id,
    required String orderNumber,
    required OrderStatus status,
    required List<OrderItem> items,
    OrderDeliveryAddress? deliveryAddress,
    required FulfillmentType deliveryMethod,
    required String customerName,
    // Always null on the completed-delivery history view — stripped once
    // the delivery is over (contract's minimize-customer-info requirement).
    String? customerPhone,
    // Raw wire value: 'cash' | 'card' | 'wallet'.
    required String paymentMethod,
    // Raw wire value: 'PENDING' | 'PAID' | 'CAPTURED' | ... (uppercase).
    required String paymentStatus,
    // What the driver must physically collect on delivery — the order total
    // for an unpaid CASH order, 0 for everything already paid/captured.
    // Never derive this from totalAmount client-side; always the backend
    // value.
    required double amountToCollect,
    required double totalAmount,
    required DateTime createdAt,
    // Phase 2 live-tracking identifier — the value this order's driver app
    // must echo back on every location upload. Preserved here (unused until
    // the tracking phase) so a stale value is never silently dropped.
    required int assignmentVersion,
  }) = _DriverOrder;

  factory DriverOrder.fromJson(Map<String, dynamic> json) =>
      _$DriverOrderFromJson(json);
}
