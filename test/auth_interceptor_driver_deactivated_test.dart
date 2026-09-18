import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart'
    hide Options;
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/api/token_refresh_coordinator.dart';

/// A deactivated driver's still-valid access token is rejected by the
/// backend's `ActiveDriverGuard` with `401 DRIVER_DEACTIVATED`
/// (DRIVER_DELIVERY_API_CONTRACT.md) even though it hasn't expired — the
/// server has already revoked every refresh-token session for that account.
/// This must be handled distinctly from an ordinary expired-token 401:
/// no refresh attempt (it would only fail after a wasted round-trip), and
/// both tokens cleared locally right away so the app can't keep sending
/// requests with a token the server will reject on every re-check.
class _RoutedScriptedAdapter implements HttpClientAdapter {
  final Map<String, List<Future<ResponseBody> Function(RequestOptions)>>
  scriptsByPath;
  final Map<String, int> callCounts = {};

  _RoutedScriptedAdapter(this.scriptsByPath);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    callCounts[options.path] = (callCounts[options.path] ?? 0) + 1;
    final script = scriptsByPath[options.path];
    if (script == null || script.isEmpty) {
      throw StateError('No more scripted responses for ${options.path}');
    }
    return script.removeAt(0)(options);
  }

  @override
  void close({bool force = false}) {}
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

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
  });

  ({Dio dio, _RoutedScriptedAdapter adapter, TokenStorage tokenStorage})
  buildStack(
    Map<String, List<Future<ResponseBody> Function(RequestOptions)>> scripts,
  ) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    final adapter = _RoutedScriptedAdapter(scripts);
    dio.httpClientAdapter = adapter;

    const secureStorage = FlutterSecureStorage();
    final tokenStorage = TokenStorage()..accessToken = 'driver-access-token';
    final coordinator = TokenRefreshCoordinator(
      dio: dio,
      secureStorage: secureStorage,
      tokenStorage: tokenStorage,
    );
    dio.interceptors.add(AuthInterceptor(dio, coordinator: coordinator));
    return (dio: dio, adapter: adapter, tokenStorage: tokenStorage);
  }

  test('DRIVER_DEACTIVATED never triggers a refresh attempt', () async {
    const secureStorage = FlutterSecureStorage();
    await secureStorage.write(
      key: TokenRefreshCoordinator.refreshTokenKey,
      value: 'still-technically-present-refresh-token',
    );

    final stack = buildStack({
      '/driver/orders': [
        _statusError(401, {
          'statusCode': 401,
          'message': 'This driver account has been deactivated',
          'code': 'DRIVER_DEACTIVATED',
        }),
      ],
    });

    await expectLater(
      stack.dio.get('/driver/orders'),
      throwsA(isA<DioException>()),
    );

    expect(stack.adapter.callCounts['/driver/orders'], 1);
    // The whole point: no refresh round-trip for this specific code.
    expect(stack.adapter.callCounts['/auth/refresh'], isNull);
  });

  test(
    'DRIVER_DEACTIVATED clears both the in-memory access token and the stored refresh token',
    () async {
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(
        key: TokenRefreshCoordinator.refreshTokenKey,
        value: 'still-technically-present-refresh-token',
      );

      final stack = buildStack({
        '/driver/orders/order-1/pickup': [
          _statusError(401, {
            'message': 'This driver account has been deactivated',
            'code': 'DRIVER_DEACTIVATED',
          }),
        ],
      });

      await expectLater(
        stack.dio.patch('/driver/orders/order-1/pickup'),
        throwsA(isA<DioException>()),
      );

      expect(stack.tokenStorage.accessToken, isNull);
      expect(
        await secureStorage.read(key: TokenRefreshCoordinator.refreshTokenKey),
        isNull,
      );
    },
  );

  test(
    'an ordinary TOKEN_EXPIRED 401 on a driver route still goes through the normal refresh-and-retry path',
    () async {
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(
        key: TokenRefreshCoordinator.refreshTokenKey,
        value: 'old-refresh-token',
      );

      final stack = buildStack({
        '/driver/orders': [
          _statusError(401, {'code': 'TOKEN_EXPIRED'}),
          (options) async => ResponseBody.fromString(
            jsonEncode([]),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ),
        ],
        '/auth/refresh': [
          (options) async => ResponseBody.fromString(
            jsonEncode({
              'accessToken': 'fresh-access-token',
              'refreshToken': 'rotated-refresh-token',
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          ),
        ],
      });

      final response = await stack.dio.get('/driver/orders');

      expect(response.statusCode, 200);
      expect(stack.adapter.callCounts['/auth/refresh'], 1);
      expect(stack.tokenStorage.accessToken, 'fresh-access-token');
    },
  );
}
