import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_notification.freezed.dart';
part 'order_notification.g.dart';

/// A single admin-facing notification about an order event (e.g. "new order
/// placed"). Distinct from `NotificationCampaign` (outbound push campaigns
/// admins send to customers) — this is the inbound admin notification inbox.
///
/// Mirrors the confirmed backend contract for
/// `GET /admin/notifications` exactly — field names match the wire format.
@freezed
class OrderNotification with _$OrderNotification {
  const factory OrderNotification({
    required String id,
    required String type,
    required String title,
    required String body,
    required String orderId,
    required String customerId,
    required String customerName,
    required String orderNumber,
    required double totalAmount,
    required bool isRead,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _OrderNotification;

  factory OrderNotification.fromJson(Map<String, dynamic> json) =>
      _$OrderNotificationFromJson(json);
}
