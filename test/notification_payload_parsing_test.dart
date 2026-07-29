import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kebda_zaman/core/notifications/notification_service.dart';
import 'package:kebda_zaman/core/notifications/notification_navigation_service.dart';

// Create a fake router to observe navigation actions
class FakeRouter implements GoRouter {
  String? lastPushedPath;

  @override
  Future<T?> push<T extends Object?>(String location, {Object? extra}) async {
    lastPushedPath = location;
    return null;
  }

  @override
  void go(String location, {Object? extra}) {
    lastPushedPath = location;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Notification Payload Parsing', () {
    late FakeRouter router;

    setUp(() {
      router = FakeRouter();
      NotificationNavigationService.instance.setRouter(router);
    });

    test('valid JSON payload opens the correct route (ORDER type)', () {
      final payload = jsonEncode({
        'id': '123',
        'title': 'Test',
        'body': 'Test Body',
        'type': 'order_created',
        'entityId': 'order-123',
      });

      NotificationService.handleLocalNotificationTap(payload);

      expect(router.lastPushedPath, '/orders/tracking/order-123');
    });

    test('malformed JSON does not throw', () {
      final malformedPayload =
          '{"id": "123", "title": "Test"'; // missing closing brace

      expect(
        () => NotificationService.handleLocalNotificationTap(malformedPayload),
        returnsNormally,
      );
      expect(router.lastPushedPath, isNull);
    });

    test('empty payload does not throw', () {
      expect(
        () => NotificationService.handleLocalNotificationTap(''),
        returnsNormally,
      );
      expect(router.lastPushedPath, isNull);
    });

    test('null payload does not throw', () {
      expect(
        () => NotificationService.handleLocalNotificationTap(null),
        returnsNormally,
      );
      expect(router.lastPushedPath, isNull);
    });

    test('decoded JSON that is not a map does not throw', () {
      final listPayload = jsonEncode(['item1', 'item2']);
      final stringPayload = jsonEncode('just a string');
      final numberPayload = jsonEncode(42);

      expect(
        () => NotificationService.handleLocalNotificationTap(listPayload),
        returnsNormally,
      );
      expect(
        () => NotificationService.handleLocalNotificationTap(stringPayload),
        returnsNormally,
      );
      expect(
        () => NotificationService.handleLocalNotificationTap(numberPayload),
        returnsNormally,
      );
      expect(router.lastPushedPath, isNull);
    });
  });
}
