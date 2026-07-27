import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/notifications/notification_model.dart';
import 'package:kebda_zaman/core/notifications/notification_service.dart';
import 'package:kebda_zaman/features/admin/domain/models/order_notification.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/admin_order_notification_repository.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_order_notification_notifier.dart';

/// Minimal fake standing in for the real API repository, following this
/// repo's existing test convention (fakes over mocking frameworks). Only
/// tracks call counts — enough to prove a provider was actually re-fetched
/// after invalidation, not just marked dirty.
class _FakeAdminOrderNotificationRepository implements AdminOrderNotificationRepository {
  int getNotificationsCallCount = 0;
  int getUnreadCountCallCount = 0;

  @override
  Future<Result<List<OrderNotification>>> getNotifications({int? page, int? limit}) async {
    getNotificationsCallCount++;
    return const Success([]);
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    getUnreadCountCallCount++;
    return const Success(0);
  }

  @override
  Future<Result<OrderNotification>> markAsRead(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<int>> markAllAsRead() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> clearAll() async {
    throw UnimplementedError();
  }
}

AppNotificationPayload _payload(Map<String, dynamic> rawData) {
  return AppNotificationPayload(
    id: 'n1',
    type: NotificationType.unknown,
    title: 'New order received',
    body: 'Ahmed Hassan placed order KZ-1001',
    timestamp: DateTime(2026, 7, 25),
    rawData: rawData,
  );
}

void main() {
  group('NotificationService.handleAdminNewOrderRefresh', () {
    test('a NEW_ORDER message re-fetches the admin unread count and notification list', () async {
      final fakeRepo = _FakeAdminOrderNotificationRepository();
      final container = ProviderContainer(
        overrides: [
          adminOrderNotificationRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      // Keep both autoDispose providers alive for the duration of the test,
      // same as the notification-center screen would via ref.watch().
      final sub1 = container.listen(adminOrderNotificationProvider, (_, __) {});
      final sub2 = container.listen(adminUnreadNotificationCountProvider, (_, __) {});
      addTearDown(sub1.close);
      addTearDown(sub2.close);

      await container.read(adminOrderNotificationProvider.future);
      await container.read(adminUnreadNotificationCountProvider.future);
      expect(fakeRepo.getNotificationsCallCount, 1);
      expect(fakeRepo.getUnreadCountCallCount, 1);

      NotificationService.instance.attachProviderContainer(container);
      NotificationService.instance.handleAdminNewOrderRefresh(_payload({
        'type': 'NEW_ORDER',
        'notificationId': 'n1',
        'orderId': 'order-1',
        'orderNumber': 'KZ-1001',
      }));

      await container.read(adminOrderNotificationProvider.future);
      await container.read(adminUnreadNotificationCountProvider.future);
      expect(fakeRepo.getNotificationsCallCount, 2);
      expect(fakeRepo.getUnreadCountCallCount, 2);
    });

    test('a non-NEW_ORDER message does not touch the admin notification providers', () async {
      final fakeRepo = _FakeAdminOrderNotificationRepository();
      final container = ProviderContainer(
        overrides: [
          adminOrderNotificationRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final sub1 = container.listen(adminOrderNotificationProvider, (_, __) {});
      final sub2 = container.listen(adminUnreadNotificationCountProvider, (_, __) {});
      addTearDown(sub1.close);
      addTearDown(sub2.close);

      await container.read(adminOrderNotificationProvider.future);
      await container.read(adminUnreadNotificationCountProvider.future);
      expect(fakeRepo.getNotificationsCallCount, 1);
      expect(fakeRepo.getUnreadCountCallCount, 1);

      NotificationService.instance.attachProviderContainer(container);
      NotificationService.instance.handleAdminNewOrderRefresh(_payload({
        'type': 'order_created',
        'entityId': 'order-1',
      }));

      // No invalidation should have been triggered — call counts unchanged.
      expect(fakeRepo.getNotificationsCallCount, 1);
      expect(fakeRepo.getUnreadCountCallCount, 1);
    });
  });
}
