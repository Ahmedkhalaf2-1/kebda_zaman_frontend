import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/order_notification.dart';

/// Admin inbox of order-event notifications (e.g. "new order placed").
/// Distinct from `AdminNotificationRepository`, which sends outbound push
/// campaigns to customers.
abstract class AdminOrderNotificationRepository {
  Future<Result<List<OrderNotification>>> getNotifications({
    int? page,
    int? limit,
  });
  Future<Result<int>> getUnreadCount();
  Future<Result<OrderNotification>> markAsRead(String id);
  Future<Result<int>> markAllAsRead();
  Future<Result<void>> clearAll();
}
