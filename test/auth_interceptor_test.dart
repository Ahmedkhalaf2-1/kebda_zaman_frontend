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

/// Scripted adapter keyed by request path, so a single Dio instance can
/// simulate both a protected endpoint (that 401s until a fresh token shows
/// up) and the /auth/refresh endpoint at once — needed to exercise the
/// interceptor's retry-after-refresh behavior end-to-end.
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
    final tokenStorage = TokenStorage();
    final coordinator = TokenRefreshCoordinator(
      dio: dio,
      secureStorage: secureStorage,
      tokenStorage: tokenStorage,
    );
    dio.interceptors.add(AuthInterceptor(dio, coordinator: coordinator));
    return (dio: dio, adapter: adapter, tokenStorage: tokenStorage);
  }

  group('AuthInterceptor', () {
    test(
      'a 401 triggers exactly one refresh and the original request is retried once with the new token',
      () async {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'old-refresh-token',
        );

        final stack = buildStack({
          '/orders': [
            _statusError(401, {'code': 'TOKEN_EXPIRED'}),
            _jsonSuccess({'items': []}),
          ],
          '/auth/refresh': [
            _jsonSuccess({
              'accessToken': 'fresh-access-token',
              'refreshToken': 'rotated-refresh-token',
            }),
          ],
        });

        final response = await stack.dio.get('/orders');

        expect(response.statusCode, 200);
        expect(stack.adapter.callCounts['/auth/refresh'], 1);
        expect(
          stack.adapter.callCounts['/orders'],
          2,
        ); // original 401 + one retry
        expect(stack.tokenStorage.accessToken, 'fresh-access-token');
      },
    );

    test(
      'several simultaneous 401 responses share exactly one refresh call and all succeed',
      () async {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'old-refresh-token',
        );

        final stack = buildStack({
          '/orders': [
            _statusError(401, {'code': 'TOKEN_EXPIRED'}),
            _jsonSuccess({'items': []}),
          ],
          '/menu': [
            _statusError(401, {'code': 'TOKEN_EXPIRED'}),
            _jsonSuccess({'items': []}),
          ],
          '/profile': [
            _statusError(401, {'code': 'TOKEN_EXPIRED'}),
            _jsonSuccess({'name': 'Ahmed'}),
          ],
          '/auth/refresh': [
            _jsonSuccess({
              'accessToken': 'fresh-access-token',
              'refreshToken': 'rotated-refresh-token',
            }),
          ],
        });

        final responses = await Future.wait([
          stack.dio.get('/orders'),
          stack.dio.get('/menu'),
          stack.dio.get('/profile'),
        ]);

        for (final response in responses) {
          expect(response.statusCode, 200);
        }
        expect(stack.adapter.callCounts['/auth/refresh'], 1);
        expect(stack.tokenStorage.accessToken, 'fresh-access-token');
      },
    );

    test(
      'a retried request that gets 401 again does not loop — fails cleanly after one retry',
      () async {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'old-refresh-token',
        );

        final stack = buildStack({
          '/orders': [
            _statusError(401, {'code': 'TOKEN_EXPIRED'}),
            _statusError(401, {
              'code': 'TOKEN_EXPIRED',
            }), // still 401 even with the new token
          ],
          '/auth/refresh': [
            _jsonSuccess({
              'accessToken': 'fresh-access-token',
              'refreshToken': 'rotated-refresh-token',
            }),
          ],
        });

        await expectLater(
          stack.dio.get('/orders'),
          throwsA(isA<DioException>()),
        );

        // Exactly one refresh call, exactly two attempts at /orders (original +
        // the single permitted retry) — no infinite loop, no second refresh.
        expect(stack.adapter.callCounts['/auth/refresh'], 1);
        expect(stack.adapter.callCounts['/orders'], 2);
      },
    );

    test(
      'never attempts a refresh for the refresh endpoint\'s own 401',
      () async {
        const secureStorage = FlutterSecureStorage();
        await secureStorage.write(
          key: TokenRefreshCoordinator.refreshTokenKey,
          value: 'dead-refresh-token',
        );

        final stack = buildStack({
          '/auth/refresh': [
            _statusError(401, {'code': 'REFRESH_TOKEN_INVALID'}),
          ],
        });

        await expectLater(
          stack.dio.post(
            '/auth/refresh',
            data: {'refreshToken': 'dead-refresh-token'},
          ),
          throwsA(isA<DioException>()),
        );

        // Only the one call we made ourselves — the interceptor must not have
        // tried to "refresh" in response to /auth/refresh's own failure.
        expect(stack.adapter.callCounts['/auth/refresh'], 1);
      },
    );

    test('login 401 does not call /auth/refresh', () async {
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(
        key: TokenRefreshCoordinator.refreshTokenKey,
        value: 'valid-refresh-token',
      );

      final stack = buildStack({
        '/auth/login': [
          _statusError(401, {'code': 'INVALID_CREDENTIALS'}),
        ],
      });

      await expectLater(
        stack.dio.post('/auth/login', data: {'email': 'a', 'password': 'b'}),
        throwsA(isA<DioException>()),
      );
      expect(stack.adapter.callCounts['/auth/refresh'], isNull);
      expect(stack.adapter.callCounts['/auth/login'], 1);
    });

    test('admin login 401 does not call /auth/refresh', () async {
      const secureStorage = FlutterSecureStorage();
      await secureStorage.write(
        key: TokenRefreshCoordinator.refreshTokenKey,
        value: 'valid-refresh-token',
      );

      final stack = buildStack({
        '/admin/auth/login': [
          _statusError(401, {'code': 'INVALID_CREDENTIALS'}),
        ],
      });

      await expectLater(
        stack.dio.post('/admin/auth/login', data: {'email': 'admin', 'password': 'b'}),
        throwsA(isA<DioException>()),
      );
      expect(stack.adapter.callCounts['/auth/refresh'], isNull);
      expect(stack.adapter.callCounts['/admin/auth/login'], 1);
    });
  });

  group('RetryInterceptor', () {
    ({Dio dio, _RoutedScriptedAdapter adapter}) buildRetryStack(
      Map<String, List<Future<ResponseBody> Function(RequestOptions)>> scripts,
    ) {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      final adapter = _RoutedScriptedAdapter(scripts);
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(RetryInterceptor(dio, maxRetries: 2));
      return (dio: dio, adapter: adapter);
    }

    test('GET requests may retry on 503 or network errors', () async {
      final stack = buildRetryStack({
        '/menu': [
          _statusError(503, {'error': 'Service Unavailable'}),
          _jsonSuccess({'items': []}),
        ],
      });

      final response = await stack.dio.get('/menu');
      expect(response.statusCode, 200);
      expect(stack.adapter.callCounts['/menu'], 2); // 1 initial + 1 retry
    });

    test('/auth/refresh is never retried even on 503', () async {
      final stack = buildRetryStack({
        '/auth/refresh': [
          _statusError(503, {'error': 'Service Unavailable'}),
          _statusError(503, {'error': 'Service Unavailable'}),
        ],
      });

      await expectLater(
        stack.dio.post('/auth/refresh', data: {'refreshToken': 'abc'}),
        throwsA(isA<DioException>()),
      );
      expect(
        stack.adapter.callCounts['/auth/refresh'],
        1,
      ); // exactly 1 attempt, 0 retries
    });

    test('unsafe POST/PUT/PATCH/DELETE are not retried even on 503', () async {
      final stack = buildRetryStack({
        '/cart/items': [
          _statusError(503, {'error': 'Service Unavailable'}),
        ],
        '/me/favorites': [
          _statusError(503, {'error': 'Service Unavailable'}),
        ],
        '/orders/123': [
          _statusError(503, {'error': 'Service Unavailable'}),
        ],
      });

      await expectLater(
        stack.dio.post('/cart/items', data: {'id': '1'}),
        throwsA(isA<DioException>()),
      );
      expect(stack.adapter.callCounts['/cart/items'], 1);

      await expectLater(
        stack.dio.put('/me/favorites', data: {'id': '1'}),
        throwsA(isA<DioException>()),
      );
      expect(stack.adapter.callCounts['/me/favorites'], 1);

      await expectLater(
        stack.dio.delete('/orders/123'),
        throwsA(isA<DioException>()),
      );
      expect(stack.adapter.callCounts['/orders/123'], 1);
    });

    test(
      'checkout retries only with exact approved path and stable Idempotency-Key',
      () async {
        final stack = buildRetryStack({
          '/checkout': [
            _statusError(503, {'error': 'Service Unavailable'}),
            _jsonSuccess({'id': 'ord-123'}),
          ],
          '/orders': [
            _statusError(503, {'error': 'Service Unavailable'}),
            _jsonSuccess({'id': 'ord-999'}),
          ],
        });

        // POST /checkout should retry
        final checkoutRes = await stack.dio.post(
          '/checkout',
          data: {'total': 100},
          options: Options(headers: {'Idempotency-Key': 'key-123'}),
        );
        expect(checkoutRes.statusCode, 200);
        expect(stack.adapter.callCounts['/checkout'], 2); // 1 initial + 1 retry

        // POST /orders (different path) even with Idempotency-Key must NOT retry
        await expectLater(
          stack.dio.post(
            '/orders',
            data: {'total': 100},
            options: Options(headers: {'Idempotency-Key': 'key-456'}),
          ),
          throwsA(isA<DioException>()),
        );
        expect(stack.adapter.callCounts['/orders'], 1); // exactly 1 attempt
      },
    );

    test('POST /checkout without Idempotency-Key header never retries', () async {
      final stack = buildRetryStack({
        '/checkout': [
          _statusError(503, {'error': 'Service Unavailable'}),
          _jsonSuccess({'id': 'ord-123'}),
        ],
      });

      await expectLater(
        stack.dio.post('/checkout', data: {'total': 100}),
        throwsA(isA<DioException>()),
      );
      expect(stack.adapter.callCounts['/checkout'], 1);
    });

    test('POST /checkout with an empty Idempotency-Key header never retries', () async {
      final stack = buildRetryStack({
        '/checkout': [
          _statusError(503, {'error': 'Service Unavailable'}),
          _jsonSuccess({'id': 'ord-123'}),
        ],
      });

      await expectLater(
        stack.dio.post(
          '/checkout',
          data: {'total': 100},
          options: Options(headers: {'Idempotency-Key': '   '}),
        ),
        throwsA(isA<DioException>()),
      );
      expect(stack.adapter.callCounts['/checkout'], 1);
    });
  });
}
