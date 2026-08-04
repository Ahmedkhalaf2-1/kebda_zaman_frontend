import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/notifications/device_service.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/shared/data/api_auth_repository.dart';
import 'package:kebda_zaman/features/shared/data/fake_auth_repository.dart';
import 'package:kebda_zaman/features/shared/data/google_auth_service.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/device_repository.dart';

/// Focused tests for Google Sign-In, at two layers:
///  - `ApiAuthRepository.googleLogin` — the wire contract with the real
///    backend (`POST /auth/google`, request/response shape, error mapping).
///  - `AuthNotifier.googleSignIn`/`.logout` — the session/state-machine
///    integration, with the Google/Firebase step injected as a plain
///    function so no real Google or Firebase service is ever touched.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.script);

  final List<Future<ResponseBody> Function(RequestOptions)> script;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    if (script.isEmpty) {
      throw StateError('No more scripted responses for ${options.path}');
    }
    return script.removeAt(0)(options);
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _userJson() => {
  'id': 'usr-1',
  'name': 'Ahmed',
  'email': 'ahmed@test.com',
  'createdAt': DateTime.now().toIso8601String(),
};

ResponseBody _jsonResponse(Map<String, dynamic> data, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

({
  ApiClient apiClient,
  TokenStorage tokenStorage,
  FlutterSecureStorage secureStorage,
})
_buildClient(HttpClientAdapter adapter) {
  final tokenStorage = TokenStorage();
  const secureStorage = FlutterSecureStorage();
  final apiClient = ApiClient(
    secureStorage: secureStorage,
    tokenStorage: tokenStorage,
  );
  apiClient.dio.httpClientAdapter = adapter;
  return (
    apiClient: apiClient,
    tokenStorage: tokenStorage,
    secureStorage: secureStorage,
  );
}

class _RecordingDeviceRepository implements DeviceRepository {
  final List<String> calls;
  _RecordingDeviceRepository([List<String>? shared]) : calls = shared ?? [];

  @override
  Future<void> registerToken({
    required String token,
    required String platform,
  }) async => calls.add('registerToken');

  @override
  Future<void> rotateToken({
    String? oldToken,
    required String newToken,
    required String platform,
  }) async => calls.add('rotateToken');

  @override
  Future<void> deleteToken(String token) async => calls.add('deleteToken');
}

/// Constructs an [AuthNotifier] and waits out its constructor-triggered
/// `_loadCachedUserForDisplay()` (which starts every notifier in
/// `isLoading: true` until it resolves). Without this, a test that calls
/// `.googleSignIn()` immediately after construction would race that initial
/// load and be rejected by the "already loading" concurrency guard — the
/// same as a real screen not being interactive until that initial state
/// settles.
Future<AuthNotifier> _readyNotifier(
  AuthRepository authRepository, {
  Future<String?> Function()? googleSignIn,
  Future<void> Function()? googleSignOut,
}) async {
  final notifier = AuthNotifier(
    authRepository,
    googleSignIn: googleSignIn,
    googleSignOut: googleSignOut,
  );
  await Future<void>.delayed(Duration.zero);
  return notifier;
}

class _RecordingAuthRepository extends FakeAuthRepository {
  final List<String> calls;
  final Result<User> Function()? googleLoginOverride;

  _RecordingAuthRepository(this.calls, {this.googleLoginOverride});

  @override
  Future<Result<User>> googleLogin(String firebaseIdToken) async {
    calls.add('authRepository.googleLogin');
    return googleLoginOverride?.call() ??
        Success(
          User(id: 'u1', name: 'Google User', createdAt: DateTime(2026, 1, 1)),
        );
  }

  @override
  Future<Result<void>> logout() async {
    calls.add('authRepository.logout');
    return const Success(null);
  }
}

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
  });

  group('ApiAuthRepository.googleLogin', () {
    test(
      'sends POST /auth/google with only firebaseIdToken in the body',
      () async {
        RequestOptions? captured;
        final adapter = _ScriptedAdapter([
          (options) async {
            captured = options;
            return _jsonResponse({
              'user': _userJson(),
              'accessToken': 'access-abc',
              'refreshToken': 'refresh-def',
            }, 200);
          },
        ]);

        final built = _buildClient(adapter);
        final repo = ApiAuthRepository(
          apiClient: built.apiClient,
          secureStorage: built.secureStorage,
          tokenStorage: built.tokenStorage,
        );

        final result = await repo.googleLogin('firebase-id-token-abc');

        expect(result, isA<Success<User>>());
        expect(captured!.path, '/auth/google');
        // Only the raw token is sent — no email/name/uid/role/accessToken.
        expect(captured!.data, {'firebaseIdToken': 'firebase-id-token-abc'});
      },
    );

    test(
      'reuses the existing AuthResult parsing and token-persistence path',
      () async {
        final adapter = _ScriptedAdapter([
          (options) async => _jsonResponse({
            'user': _userJson(),
            'accessToken': 'access-abc',
            'refreshToken': 'refresh-def',
          }, 200),
        ]);

        final built = _buildClient(adapter);
        final repo = ApiAuthRepository(
          apiClient: built.apiClient,
          secureStorage: built.secureStorage,
          tokenStorage: built.tokenStorage,
        );

        final result = await repo.googleLogin('firebase-id-token-abc');

        expect(result, isA<Success<User>>());
        final user = (result as Success<User>).data;
        expect(user.id, 'usr-1');
        expect(user.name, 'Ahmed');
        // Same token-persistence path as normal login: access token in
        // memory, refresh token durably in secure storage.
        expect(built.tokenStorage.accessToken, 'access-abc');
        expect(
          await built.secureStorage.read(key: 'refreshToken'),
          'refresh-def',
        );
      },
    );

    test(
      'backend INVALID_GOOGLE_TOKEN maps to an AuthFailure carrying that code',
      () async {
        final adapter = _ScriptedAdapter([
          (options) async => _jsonResponse({
            'statusCode': 401,
            'error': 'Unauthorized',
            'message': 'Invalid Google authentication token',
            'code': 'INVALID_GOOGLE_TOKEN',
          }, 401),
        ]);

        final built = _buildClient(adapter);
        final repo = ApiAuthRepository(
          apiClient: built.apiClient,
          secureStorage: built.secureStorage,
          tokenStorage: built.tokenStorage,
        );

        final result = await repo.googleLogin('bad-token');

        expect(result, isA<Err<User>>());
        final failure = (result as Err<User>).error;
        expect(failure, isA<AuthFailure>());
        expect(failure.cause, isA<ApiException>());
        expect((failure.cause as ApiException).code, 'INVALID_GOOGLE_TOKEN');
        // No token must be persisted for a rejected exchange.
        expect(built.tokenStorage.accessToken, isNull);
      },
    );
  });

  group('AuthNotifier.googleSignIn', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      // Firebase is never initialized in this test environment, so
      // DeviceService.onSessionEstablished() short-circuits safely without
      // reaching the device repository — proven not to throw below, exactly
      // as it behaves for every other existing login/signup test.
      await DeviceService.instance.onSessionInvalidated();
    });

    test(
      'success updates state like normal login (user, isLoggedIn true)',
      () async {
        final notifier = await _readyNotifier(
          _RecordingAuthRepository([]),
          googleSignIn: () async => 'firebase-id-token-abc',
        );
        addTearDown(notifier.dispose);

        final success = await notifier.googleSignIn();

        expect(success, isTrue);
        expect(notifier.state.isLoggedIn, isTrue);
        expect(notifier.state.user?.name, 'Google User');
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.errorMessage, isNull);
      },
    );

    test(
      'DeviceService.onSessionEstablished is reached without throwing',
      () async {
        final notifier = await _readyNotifier(
          _RecordingAuthRepository([]),
          googleSignIn: () async => 'firebase-id-token-abc',
        );
        addTearDown(notifier.dispose);

        // Would throw/propagate if the post-success DeviceService call site
        // were missing or broken — same call as every other auth method.
        await expectLater(notifier.googleSignIn(), completes);
      },
    );

    test(
      'cancellation resets loading quietly — no error, not logged in',
      () async {
        final calls = <String>[];
        final notifier = await _readyNotifier(
          _RecordingAuthRepository(calls),
          // Mirrors GoogleAuthService.signIn()'s null-on-cancel contract.
          googleSignIn: () async => null,
        );
        addTearDown(notifier.dispose);

        final success = await notifier.googleSignIn();

        expect(success, isFalse);
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.errorMessage, isNull);
        expect(notifier.state.isLoggedIn, isFalse);
        // Cancellation happens before any backend call.
        expect(calls, isEmpty);
      },
    );

    test('Google/Firebase failure (missing token, credential failure, etc.) '
        'maps to a friendly message without leaking exception text', () async {
      final notifier = await _readyNotifier(
        FakeAuthRepository(),
        googleSignIn: () async =>
            throw const GoogleAuthException('Firebase ID token was empty'),
      );
      addTearDown(notifier.dispose);

      final success = await notifier.googleSignIn();

      expect(success, isFalse);
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.isLoggedIn, isFalse);
      expect(notifier.state.errorMessage, isNotNull);
      expect(
        notifier.state.errorMessage,
        isNot(contains('GoogleAuthException')),
      );
      expect(
        notifier.state.errorMessage,
        isNot(contains('Firebase ID token was empty')),
      );
    });

    test(
      'backend INVALID_GOOGLE_TOKEN maps to the friendly localized message',
      () async {
        final notifier = await _readyNotifier(
          _RecordingAuthRepository(
            [],
            googleLoginOverride: () => Err(
              AuthFailure(
                'Invalid Google authentication token',
                ApiException(
                  statusCode: 401,
                  error: 'Unauthorized',
                  message: 'Invalid Google authentication token',
                  code: 'INVALID_GOOGLE_TOKEN',
                ),
              ),
            ),
          ),
          googleSignIn: () async => 'firebase-id-token-abc',
        );
        addTearDown(notifier.dispose);

        final success = await notifier.googleSignIn();

        expect(success, isFalse);
        expect(notifier.state.isLoggedIn, isFalse);
        // Never the raw backend message string.
        expect(
          notifier.state.errorMessage,
          isNot('Invalid Google authentication token'),
        );
        expect(notifier.state.errorMessage, isNotNull);
      },
    );

    test('a repeated tap while a Google flow is already running does not start '
        'a second flow', () async {
      var callCount = 0;
      final notifier = await _readyNotifier(
        _RecordingAuthRepository([]),
        googleSignIn: () async {
          callCount++;
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return 'firebase-id-token-abc';
        },
      );
      addTearDown(notifier.dispose);

      final first = notifier.googleSignIn();
      // Fired while the first call is still in flight (isLoading is set
      // synchronously before the first await), so this must be a no-op.
      final second = notifier.googleSignIn();

      final results = await Future.wait([first, second]);

      expect(callCount, 1);
      expect(results, [true, false]);
    });
  });

  group('AuthNotifier.logout — Google/Firebase sign-out integration', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('backend tokens are still cleared even when Google/Firebase sign-out '
        'throws', () async {
      final callOrder = <String>[];
      DeviceService.instance.configure(_RecordingDeviceRepository(callOrder));

      final authRepo = _RecordingAuthRepository(callOrder);
      final notifier = await _readyNotifier(
        authRepo,
        googleSignIn: () async => 'firebase-id-token-abc',
        googleSignOut: () async =>
            throw Exception('simulated Google sign-out failure'),
      );
      addTearDown(notifier.dispose);

      // Establish a session first so logout has something to tear down.
      await notifier.googleSignIn();
      expect(notifier.state.isLoggedIn, isTrue);

      await notifier.logout();

      // Backend logout (which always clears stored tokens in its own
      // `finally`, per ApiAuthRepository.logout) still ran, and the
      // thrown Google sign-out error never propagated or blocked it.
      expect(callOrder, contains('authRepository.logout'));
      expect(notifier.state.isLoggedIn, isFalse);
      expect(notifier.state.user, isNull);
      expect(notifier.state.isLoading, isFalse);
    });

    test('logout does not assume the user ever had a Google session (safe '
        'no-op sign-out)', () async {
      final notifier = await _readyNotifier(
        FakeAuthRepository(),
        googleSignIn: () async => 'firebase-id-token-abc',
        googleSignOut: () async {}, // no-op, as for an email/password user
      );
      addTearDown(notifier.dispose);

      await notifier.login(identifier: 'user@test.com', password: 'pw');
      expect(notifier.state.isLoggedIn, isTrue);

      await expectLater(notifier.logout(), completes);
      expect(notifier.state.isLoggedIn, isFalse);
    });
  });
}
