import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/notifications/device_service.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/shared/data/fake_auth_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/device_repository.dart';
import 'package:kebda_zaman/core/errors/result.dart';

const String _devicePrefKey = 'kz_fcm_device_token';

/// Records the order in which device-repository / auth-repository calls
/// happen, so the manual-logout ordering regression (onBeforeLogout must
/// happen BEFORE authRepository.logout) can be asserted directly.
class _RecordingDeviceRepository implements DeviceRepository {
  _RecordingDeviceRepository([List<String>? sharedCalls])
    : calls = sharedCalls ?? [];

  final List<String> calls;

  @override
  Future<void> registerToken({
    required String token,
    required String platform,
  }) async {
    calls.add('registerToken');
  }

  @override
  Future<void> rotateToken({
    String? oldToken,
    required String newToken,
    required String platform,
  }) async {
    calls.add('rotateToken');
  }

  @override
  Future<void> deleteToken(String token) async {
    calls.add('deleteToken');
  }
}

class _RecordingAuthRepository extends FakeAuthRepository {
  final List<String> calls;
  _RecordingAuthRepository(this.calls);

  @override
  Future<Result<void>> logout() async {
    calls.add('authRepository.logout');
    return const Success(null);
  }

  @override
  Future<Result<User>> login(String email, String password) async {
    return Success(
      User(id: 'u1', name: 'Test User', createdAt: DateTime(2026, 1, 1)),
    );
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DeviceService.instance.onSessionInvalidated();
  });

  group('AuthNotifier.clearLocalSession', () {
    test(
      'clears user/session prefs and the local device token, without an '
      'authenticated backend DELETE /devices/token call',
      () async {
        // Seed a logged-in session and a locally stored device token.
        SharedPreferences.setMockInitialValues({
          AuthNotifier.isLoggedInKey: true,
          AuthNotifier.userKey: '{"id":"u1","name":"Test","createdAt":"2026-01-01T00:00:00.000"}',
          _devicePrefKey: 'stored-device-token',
        });

        final recordingRepo = _RecordingDeviceRepository();
        DeviceService.instance.configure(recordingRepo);

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              _RecordingAuthRepository([]),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(authNotifierProvider.notifier).clearLocalSession();

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(AuthNotifier.isLoggedInKey), isNull);
        expect(prefs.getString(AuthNotifier.userKey), isNull);
        expect(prefs.getString(_devicePrefKey), isNull);
        expect(await DeviceService.instance.getStoredToken(), isNull);

        // No authenticated DELETE /devices/token must have been fired.
        expect(recordingRepo.calls, isEmpty);

        final state = container.read(authNotifierProvider);
        expect(state.isLoggedIn, isFalse);
        expect(state.user, isNull);
      },
    );
  });

  group('Manual logout regression', () {
    test(
      'onBeforeLogout (device DELETE) still happens before authRepository.logout',
      () async {
        final callOrder = <String>[];
        final recordingDeviceRepo = _RecordingDeviceRepository(callOrder);
        DeviceService.instance.configure(recordingDeviceRepo);

        SharedPreferences.setMockInitialValues({
          _devicePrefKey: 'stored-device-token',
        });

        final authRepo = _RecordingAuthRepository(callOrder);
        final container = ProviderContainer(
          overrides: [authRepositoryProvider.overrideWithValue(authRepo)],
        );
        addTearDown(container.dispose);

        // Log in first so logout() has a session to tear down.
        await container
            .read(authNotifierProvider.notifier)
            .login(identifier: 'user@test.com', password: 'password');

        await container.read(authNotifierProvider.notifier).logout();

        // deleteToken (from onBeforeLogout) must be recorded before
        // authRepository.logout, in that exact relative order.
        expect(callOrder, contains('deleteToken'));
        expect(callOrder, contains('authRepository.logout'));
        expect(
          callOrder.indexOf('deleteToken') <
              callOrder.indexOf('authRepository.logout'),
          isTrue,
        );
      },
    );
  });
}
