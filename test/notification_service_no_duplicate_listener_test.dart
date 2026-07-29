import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Fix 8 regression: DeviceService must be the SOLE subscriber to
/// `FirebaseMessaging.instance.onTokenRefresh`. Previously
/// NotificationService also subscribed via `_initTokenListeners()`, calling
/// the now-dead `syncTokenWithBackend()` no-op — a redundant listener.
///
/// A source-level check is used (rather than a behavioral test) because
/// exercising `FirebaseMessaging.instance.onTokenRefresh` in this suite
/// would require mocking FCM platform channels, which is not set up
/// anywhere else in this test suite (confirmed: no mocktail/mockito/
/// MethodChannel mock usage exists for FirebaseMessaging in `test/`).
void main() {
  group('NotificationService no longer owns a token-refresh listener', () {
    late String notificationServiceSource;
    late String deviceServiceSource;

    setUpAll(() {
      notificationServiceSource = File(
        'lib/core/notifications/notification_service.dart',
      ).readAsStringSync();
      deviceServiceSource = File(
        'lib/core/notifications/device_service.dart',
      ).readAsStringSync();
    });

    test('_initTokenListeners no longer exists', () {
      expect(
        notificationServiceSource.contains('_initTokenListeners'),
        isFalse,
      );
    });

    test('syncTokenWithBackend (dead legacy no-op) no longer exists', () {
      expect(
        notificationServiceSource.contains('syncTokenWithBackend'),
        isFalse,
      );
    });

    test('NotificationService no longer subscribes to onTokenRefresh', () {
      expect(
        notificationServiceSource.contains('onTokenRefresh'),
        isFalse,
      );
    });

    test(
      'DeviceService remains the sole onTokenRefresh subscriber (exactly '
      'one subscription site)',
      () {
        final matches = 'onTokenRefresh.listen'
            .allMatches(deviceServiceSource)
            .length;
        // Guard against a literal-string false positive: count real
        // occurrences of the subscription call, not the getter name alone.
        final subscriptionSites =
            RegExp(r'onTokenRefresh\.listen\(').allMatches(deviceServiceSource).length;
        expect(matches, greaterThanOrEqualTo(1));
        expect(subscriptionSites, 1);
      },
    );
  });
}
