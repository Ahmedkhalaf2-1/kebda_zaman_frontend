import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/notifications/device_service.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/device_repository.dart';

const String _tokenPrefKey = 'kz_fcm_device_token';

/// Records which backend call was made and can be told to fail, so tests
/// can assert both the success-persists and failure-does-not-persist paths.
class _FakeDeviceRepository implements DeviceRepository {
  final List<String> calls = [];
  bool shouldThrow = false;

  @override
  Future<void> registerToken({
    required String token,
    required String platform,
  }) async {
    calls.add('registerToken');
    if (shouldThrow) throw Exception('backend registerToken failed');
  }

  @override
  Future<void> rotateToken({
    String? oldToken,
    required String newToken,
    required String platform,
  }) async {
    calls.add('rotateToken');
    if (shouldThrow) throw Exception('backend rotateToken failed');
  }

  @override
  Future<void> deleteToken(String token) async {
    calls.add('deleteToken');
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DeviceService.instance.onSessionInvalidated();
    DeviceService.instance.debugReset();
  });

  group('DeviceService token rotation (Fix 8 regression)', () {
    test('no previous token -> registerToken is called (not rotateToken)', () async {
      final repo = _FakeDeviceRepository();
      DeviceService.instance.configure(repo);

      await DeviceService.instance.debugSendToBackend(
        token: 'new-token-1',
        previousToken: null,
        platform: 'ANDROID',
      );

      expect(repo.calls, ['registerToken']);
    });

    test('previous token present -> rotateToken is called (not registerToken)', () async {
      final repo = _FakeDeviceRepository();
      DeviceService.instance.configure(repo);

      await DeviceService.instance.debugSendToBackend(
        token: 'new-token-2',
        previousToken: 'old-token-1',
        platform: 'ANDROID',
      );

      expect(repo.calls, ['rotateToken']);
    });

    test('successful sync persists the new token locally', () async {
      final repo = _FakeDeviceRepository();
      DeviceService.instance.configure(repo);

      await DeviceService.instance.debugSendToBackend(
        token: 'persisted-token',
        previousToken: null,
        platform: 'ANDROID',
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_tokenPrefKey), 'persisted-token');
      expect(await DeviceService.instance.getStoredToken(), 'persisted-token');
    });

    test('failed sync does not persist the new token', () async {
      final repo = _FakeDeviceRepository()..shouldThrow = true;
      DeviceService.instance.configure(repo);

      await expectLater(
        DeviceService.instance.debugSendToBackend(
          token: 'should-not-persist',
          previousToken: null,
          platform: 'ANDROID',
        ),
        throwsException,
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(_tokenPrefKey), isNull);
      expect(await DeviceService.instance.getStoredToken(), isNull);
    });
  });

  group('DeviceService.configure idempotency / attach guard (Fix 8)', () {
    test('configure() is safe to call repeatedly and never throws', () async {
      final repo = _FakeDeviceRepository();

      expect(() => DeviceService.instance.configure(repo), returnsNormally);
      expect(() => DeviceService.instance.configure(repo), returnsNormally);
      expect(() => DeviceService.instance.configure(repo), returnsNormally);
    });

    test(
      'when Firebase is not initialized, configure() does not mark the '
      'refresh listener as attached — a later call after Firebase becomes '
      'ready must still be able to attach once',
      () async {
        // In this unit-test environment FirebaseMessaging platform channels
        // are not mocked, so NotificationService.instance.isFirebaseInitialized
        // is false — the exact "Firebase not ready" scenario this guard exists
        // for. The old buggy ordering set `_listenerAttached = true`
        // unconditionally before this check, which would have permanently
        // wedged the listener into "attached" here.
        final repo = _FakeDeviceRepository();

        DeviceService.instance.configure(repo);
        expect(
          DeviceService.instance.debugListenerAttached,
          isFalse,
          reason:
              'guard must not mark attached when Firebase is not initialized',
        );

        // A subsequent configure() call (simulating a later retry once
        // Firebase readiness might change) must still be permitted to try
        // again rather than being silently skipped.
        DeviceService.instance.configure(repo);
        expect(DeviceService.instance.debugListenerAttached, isFalse);
      },
    );
  });
}
