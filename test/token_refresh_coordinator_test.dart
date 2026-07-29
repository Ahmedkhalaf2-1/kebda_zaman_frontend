import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/api/token_refresh_coordinator.dart';
import 'package:kebda_zaman/core/notifications/device_service.dart';

const String _devicePrefKey = 'kz_fcm_device_token';

/// A scripted HttpClientAdapter: each call to fetch() consumes the next
/// entry from [script], so tests can precisely dictate what the
/// /auth/refresh endpoint "returns" without touching the network.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.script);

  final List<Future<ResponseBody> Function(RequestOptions)> script;
  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    callCount++;
    if (script.isEmpty) {
      throw StateError('No more scripted responses for ${options.path}');
    }
    return script.removeAt(0)(options);
  }

  @override
  void close({bool force = false}) {}
}

Future<ResponseBody> Function(RequestOptions) _jsonSuccess(
  Map<String, dynamic> data,
) {
  return (options) async => ResponseBody.fromString(
    jsonEncode(data),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Future<ResponseBody> Function(RequestOptions) _statusError(
  int statusCode, [
  Map<String, dynamic>? data,
]) {
  return (options) async => ResponseBody.fromString(
    jsonEncode(data ?? {}),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Future<ResponseBody> Function(RequestOptions) _transportError(
  DioExceptionType type,
) {
  return (options) async =>
      throw DioException(requestOptions: options, type: type);
}

Dio _dioWith(_ScriptedAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'https://example.test'))
    ..httpClientAdapter = adapter;
}

void main() {
  setUp(() async {
    // Officially-bundled in-memory fake for FlutterSecureStorage — avoids
    // hitting a real platform channel in plain `test()` runs.
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
    // DeviceService.instance is a process-wide singleton — reset its
    // in-memory + persisted state before every test so tests don't leak
    // into each other.
    SharedPreferences.setMockInitialValues({});
    await DeviceService.instance.onSessionInvalidated();
  });

  group('TokenRefreshCoordinator', () {
    test(
      'cold start with a valid refresh token: exactly one refresh call, access token populated, '
      'rotated refresh token persisted',
      () async {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'old-refresh-token',
        );

        final adapter = _ScriptedAdapter([
          _jsonSuccess({
            'accessToken': 'new-access-token',
            'refreshToken': 'new-refresh-token',
          }),
        ]);
        final tokenStorage = TokenStorage();
        final coordinator = TokenRefreshCoordinator(
          dio: _dioWith(adapter),
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );

        final outcome = await coordinator.refresh();

        expect(outcome, isA<RefreshSuccess>());
        expect((outcome as RefreshSuccess).accessToken, 'new-access-token');
        expect(tokenStorage.accessToken, 'new-access-token');
        expect(adapter.callCount, 1);
        expect(
          await secureStorage.read(
            key: TokenRefreshCoordinator.refreshTokenKey,
          ),
          'new-refresh-token',
        );
      },
    );

    test(
      'cold start with no refresh token: no refresh request, RefreshNoToken result',
      () async {
        const secureStorage = FlutterSecureStorage(); // nothing written
        final adapter = _ScriptedAdapter([]); // must never be called
        final tokenStorage = TokenStorage();
        final coordinator = TokenRefreshCoordinator(
          dio: _dioWith(adapter),
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );

        final outcome = await coordinator.refresh();

        expect(outcome, isA<RefreshNoToken>());
        expect(adapter.callCount, 0);
        expect(tokenStorage.accessToken, isNull);
      },
    );

    test(
      'several simultaneous refresh() calls: exactly one HTTP call, all callers reuse the result',
      () async {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'old-refresh-token',
        );

        final adapter = _ScriptedAdapter([
          _jsonSuccess({
            'accessToken': 'shared-access-token',
            'refreshToken': 'rotated-refresh-token',
          }),
        ]);
        final tokenStorage = TokenStorage();
        final coordinator = TokenRefreshCoordinator(
          dio: _dioWith(adapter),
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );

        final results = await Future.wait([
          coordinator.refresh(),
          coordinator.refresh(),
          coordinator.refresh(),
        ]);

        expect(adapter.callCount, 1);
        for (final outcome in results) {
          expect(outcome, isA<RefreshSuccess>());
          expect(
            (outcome as RefreshSuccess).accessToken,
            'shared-access-token',
          );
        }
      },
    );

    test(
      'refresh endpoint returns 401: access token cleared, refresh token deleted, session unauthenticated',
      () async {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'reused-refresh-token',
        );

        final adapter = _ScriptedAdapter([
          _statusError(401, {'code': 'REFRESH_TOKEN_INVALID'}),
        ]);
        final tokenStorage = TokenStorage()..accessToken = 'stale-access-token';
        final coordinator = TokenRefreshCoordinator(
          dio: _dioWith(adapter),
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );

        final outcome = await coordinator.refresh();

        expect(outcome, isA<RefreshRejected>());
        expect(tokenStorage.accessToken, isNull);
        expect(
          await secureStorage.read(
            key: TokenRefreshCoordinator.refreshTokenKey,
          ),
          isNull,
        );
      },
    );

    test(
      'refresh request times out: refresh token remains stored, outcome is recoverable/retryable',
      () async {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'still-valid-refresh-token',
        );

        final adapter = _ScriptedAdapter([
          _transportError(DioExceptionType.connectionTimeout),
        ]);
        final tokenStorage = TokenStorage();
        final coordinator = TokenRefreshCoordinator(
          dio: _dioWith(adapter),
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );

        final outcome = await coordinator.refresh();

        expect(outcome, isA<RefreshTransientFailure>());
        expect(tokenStorage.accessToken, isNull);
        expect(
          await secureStorage.read(
            key: TokenRefreshCoordinator.refreshTokenKey,
          ),
          'still-valid-refresh-token',
        );
      },
    );

    test(
      'refresh endpoint returns 503: also treated as recoverable, refresh token kept',
      () async {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'still-valid-refresh-token',
        );

        final adapter = _ScriptedAdapter([_statusError(503)]);
        final tokenStorage = TokenStorage();
        final coordinator = TokenRefreshCoordinator(
          dio: _dioWith(adapter),
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );

        final outcome = await coordinator.refresh();

        expect(outcome, isA<RefreshTransientFailure>());
        expect(
          await secureStorage.read(
            key: TokenRefreshCoordinator.refreshTokenKey,
          ),
          'still-valid-refresh-token',
        );
      },
    );

    test(
      'the in-flight reference is cleared after completion, so a later refresh() runs again',
      () async {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'token-1',
        );

        final adapter = _ScriptedAdapter([
          _jsonSuccess({'accessToken': 'access-1', 'refreshToken': 'token-2'}),
          _jsonSuccess({'accessToken': 'access-2', 'refreshToken': 'token-3'}),
        ]);
        final tokenStorage = TokenStorage();
        final coordinator = TokenRefreshCoordinator(
          dio: _dioWith(adapter),
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );

        final first = await coordinator.refresh();
        final second = await coordinator.refresh();

        expect(adapter.callCount, 2);
        expect((first as RefreshSuccess).accessToken, 'access-1');
        expect((second as RefreshSuccess).accessToken, 'access-2');
      },
    );

    test(
      'a stored device token is included in the /auth/refresh request body',
      () async {
        SharedPreferences.setMockInitialValues({
          _devicePrefKey: 'stored-device-token',
        });

        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'old-refresh-token',
        );

        RequestOptions? captured;
        final adapter = _ScriptedAdapter([
          (options) async {
            captured = options;
            return ResponseBody.fromString(
              jsonEncode({
                'accessToken': 'new-access-token',
                'refreshToken': 'new-refresh-token',
              }),
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          },
        ]);
        final tokenStorage = TokenStorage();
        final coordinator = TokenRefreshCoordinator(
          dio: _dioWith(adapter),
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );

        final outcome = await coordinator.refresh();

        expect(outcome, isA<RefreshSuccess>());
        final body = captured!.data as Map<String, dynamic>;
        expect(body['refreshToken'], 'old-refresh-token');
        expect(body['deviceToken'], 'stored-device-token');
      },
    );

    test(
      'no stored device token: /auth/refresh request body omits deviceToken',
      () async {
        // Nothing stored under the device-token key (setUp already reset it).
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'old-refresh-token',
        );

        RequestOptions? captured;
        final adapter = _ScriptedAdapter([
          (options) async {
            captured = options;
            return ResponseBody.fromString(
              jsonEncode({
                'accessToken': 'new-access-token',
                'refreshToken': 'new-refresh-token',
              }),
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          },
        ]);
        final tokenStorage = TokenStorage();
        final coordinator = TokenRefreshCoordinator(
          dio: _dioWith(adapter),
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );

        final outcome = await coordinator.refresh();

        expect(outcome, isA<RefreshSuccess>());
        final body = captured!.data as Map<String, dynamic>;
        expect(body.containsKey('deviceToken'), isFalse);
      },
    );

    test(
      'successful refresh leaves the locally stored device token untouched',
      () async {
        SharedPreferences.setMockInitialValues({
          _devicePrefKey: 'stored-device-token',
        });

        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'old-refresh-token',
        );

        final adapter = _ScriptedAdapter([
          _jsonSuccess({
            'accessToken': 'new-access-token',
            'refreshToken': 'new-refresh-token',
          }),
        ]);
        final tokenStorage = TokenStorage();
        final coordinator = TokenRefreshCoordinator(
          dio: _dioWith(adapter),
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );

        final outcome = await coordinator.refresh();

        expect(outcome, isA<RefreshSuccess>());
        expect(
          await DeviceService.instance.getStoredToken(),
          'stored-device-token',
        );
      },
    );

    test(
      'refresh endpoint returns 401: DeviceService local device token is also cleared',
      () async {
        SharedPreferences.setMockInitialValues({
          _devicePrefKey: 'stored-device-token',
        });

        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'reused-refresh-token',
        );

        final adapter = _ScriptedAdapter([
          _statusError(401, {'code': 'REFRESH_TOKEN_INVALID'}),
        ]);
        final tokenStorage = TokenStorage()..accessToken = 'stale-access-token';
        final coordinator = TokenRefreshCoordinator(
          dio: _dioWith(adapter),
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );

        final outcome = await coordinator.refresh();

        expect(outcome, isA<RefreshRejected>());
        expect(tokenStorage.accessToken, isNull);
        expect(await DeviceService.instance.getStoredToken(), isNull);
      },
    );

    test(
      'transient failure (timeout): device token is preserved untouched',
      () async {
        SharedPreferences.setMockInitialValues({
          _devicePrefKey: 'stored-device-token',
        });

        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'still-valid-refresh-token',
        );

        final adapter = _ScriptedAdapter([
          _transportError(DioExceptionType.connectionTimeout),
        ]);
        final tokenStorage = TokenStorage();
        final coordinator = TokenRefreshCoordinator(
          dio: _dioWith(adapter),
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );

        final outcome = await coordinator.refresh();

        expect(outcome, isA<RefreshTransientFailure>());
        expect(
          await DeviceService.instance.getStoredToken(),
          'stored-device-token',
        );
      },
    );
  });
}
