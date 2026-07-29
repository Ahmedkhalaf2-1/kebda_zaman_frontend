import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/notifications/notification_service.dart';

void main() {
  group('shouldShowLocalNotificationForBackgroundMessage', () {
    test('data-only message (no notification block) returns true', () {
      const message = RemoteMessage(
        data: {'type': 'order_created', 'entityId': 'order-123'},
      );

      expect(shouldShowLocalNotificationForBackgroundMessage(message), isTrue);
    });

    test('notification+data message returns false (prevents duplicate)', () {
      const message = RemoteMessage(
        notification: RemoteNotification(
          title: 'New order',
          body: 'Order KZ-1001 placed',
        ),
        data: {'type': 'NEW_ORDER', 'orderId': 'order-1'},
      );

      expect(
        shouldShowLocalNotificationForBackgroundMessage(message),
        isFalse,
      );
    });

    test('notification-only message returns false', () {
      const message = RemoteMessage(
        notification: RemoteNotification(
          title: 'New order',
          body: 'Order KZ-1001 placed',
        ),
      );

      expect(
        shouldShowLocalNotificationForBackgroundMessage(message),
        isFalse,
      );
    });
  });
}
