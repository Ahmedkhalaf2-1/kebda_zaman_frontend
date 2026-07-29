import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/notifications/device_service.dart';

// Mirrors DeviceService's private `_tokenPrefKey` constant so these tests can
// assert against SharedPreferences directly without needing a public getter
// for the key itself.
const String _tokenPrefKey = 'kz_fcm_device_token';

void main() {
  setUp(() async {
    // DeviceService.instance is a process-wide singleton, so a previous
    // test's in-memory `_currentToken` could otherwise leak into this one.
    // Reset both the mock platform store and the singleton's in-memory
    // state before every test.
    SharedPreferences.setMockInitialValues({});
    await DeviceService.instance.onSessionInvalidated();
  });

  group('DeviceService.getStoredToken', () {
    test('returns null when nothing is stored', () async {
      expect(await DeviceService.instance.getStoredToken(), isNull);
    });

    test('returns the persisted token when present', () async {
      SharedPreferences.setMockInitialValues({
        _tokenPrefKey: 'device-token-abc',
      });

      expect(
        await DeviceService.instance.getStoredToken(),
        'device-token-abc',
      );
    });
  });

  group('DeviceService.onSessionInvalidated', () {
    test('clears the persisted token and the in-memory token', () async {
      SharedPreferences.setMockInitialValues({
        _tokenPrefKey: 'device-token-abc',
      });
      // Prime the in-memory cache the same way getStoredToken would.
      expect(
        await DeviceService.instance.getStoredToken(),
        'device-token-abc',
      );

      await DeviceService.instance.onSessionInvalidated();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_tokenPrefKey), isNull);
      expect(await DeviceService.instance.getStoredToken(), isNull);
    });

    test('is idempotent and never throws when called repeatedly', () async {
      await DeviceService.instance.onSessionInvalidated();
      await DeviceService.instance.onSessionInvalidated();
      await DeviceService.instance.onSessionInvalidated();

      expect(await DeviceService.instance.getStoredToken(), isNull);
    });

    test('makes no repository/backend call (no repository configured)', () async {
      // DeviceService.configure() is never called in this test, so if
      // onSessionInvalidated attempted any repository/backend interaction it
      // would throw a null-check error. It must not.
      SharedPreferences.setMockInitialValues({
        _tokenPrefKey: 'device-token-abc',
      });

      await expectLater(
        DeviceService.instance.onSessionInvalidated(),
        completes,
      );
    });
  });
}
