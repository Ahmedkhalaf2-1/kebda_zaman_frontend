import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/data/api_auth_repository.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';

/// Covers `ApiAuthRepository.forgotPassword`/`resetPassword` against the
/// contract in PASSWORD_RESET_API_CONTRACT.md: success shape, every
/// documented failure code, Retry-After parsing, and that neither request
/// ever carries whatever access token happens to be in memory.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.script);

  final List<Future<ResponseBody> Function(RequestOptions)> script;
  final List<RequestOptions> recordedRequests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    recordedRequests.add(options);
    if (script.isEmpty) {
      throw StateError('No more scripted responses for ${options.path}');
    }
    return script.removeAt(0)(options);
  }

  @override
  void close({bool force = false}) {}
}

Future<ResponseBody> Function(RequestOptions) _jsonResponse(
  dynamic data,
  int statusCode, {
  Map<String, List<String>>? headers,
}) {
  return (options) async => ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      ...?headers,
    },
  );
}

Future<ResponseBody> Function(RequestOptions) _errorThrow(
  int statusCode,
  Map<String, dynamic> data, {
  Map<String, List<String>>? headers,
}) {
  return (options) async => throw DioException(
    requestOptions: options,
    response: Response(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...?headers,
      }),
    ),
  );
}

ApiClient _buildClient(_ScriptedAdapter adapter) {
  final apiClient = ApiClient(
    secureStorage: const FlutterSecureStorage(),
    tokenStorage: TokenStorage()..accessToken = 'some-unrelated-access-token',
  );
  apiClient.dio.httpClientAdapter = adapter;
  return apiClient;
}

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
  });

  group('ApiAuthRepository.forgotPassword', () {
    test('200 maps to Success(null) and sends {email}', () async {
      final adapter = _ScriptedAdapter([
        _jsonResponse({
          'message':
              'If an account exists for this email, a password reset link has been sent.',
        }, 200),
      ]);
      final repo = ApiAuthRepository(
        apiClient: _buildClient(adapter),
        secureStorage: const FlutterSecureStorage(),
        tokenStorage: TokenStorage(),
      );

      final result = await repo.forgotPassword('customer@example.com');

      expect(result.isSuccess, isTrue);
      final request = adapter.recordedRequests.single;
      expect(request.path, '/auth/forgot-password');
      expect(request.data, {'email': 'customer@example.com'});
    });

    test(
      'never attaches whatever access token happens to be in memory',
      () async {
        final adapter = _ScriptedAdapter([
          _jsonResponse({'message': 'ok'}, 200),
        ]);
        final repo = ApiAuthRepository(
          apiClient: _buildClient(adapter),
          secureStorage: const FlutterSecureStorage(),
          tokenStorage: TokenStorage(),
        );

        await repo.forgotPassword('customer@example.com');

        final request = adapter.recordedRequests.single;
        expect(request.headers.containsKey('Authorization'), isFalse);
      },
    );

    test('400 VALIDATION_ERROR maps to ValidationFailure', () async {
      final adapter = _ScriptedAdapter([
        _errorThrow(400, {
          'statusCode': 400,
          'error': 'Bad Request',
          'message': 'email must be an email',
          'code': 'VALIDATION_ERROR',
        }),
      ]);
      final repo = ApiAuthRepository(
        apiClient: _buildClient(adapter),
        secureStorage: const FlutterSecureStorage(),
        tokenStorage: TokenStorage(),
      );

      final result = await repo.forgotPassword('not-an-email');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
    });

    test(
      '429 PASSWORD_RESET_COOLDOWN maps to PasswordResetRateLimitedFailure with the code preserved',
      () async {
        final adapter = _ScriptedAdapter([
          _errorThrow(429, {
            'statusCode': 429,
            'error': 'Too Many Requests',
            'message':
                'Please wait before requesting another reset link for this email.',
            'code': 'PASSWORD_RESET_COOLDOWN',
          }),
        ]);
        final repo = ApiAuthRepository(
          apiClient: _buildClient(adapter),
          secureStorage: const FlutterSecureStorage(),
          tokenStorage: TokenStorage(),
        );

        final result = await repo.forgotPassword('customer@example.com');

        expect(result.isFailure, isTrue);
        final failure = result.failure;
        expect(failure, isA<PasswordResetRateLimitedFailure>());
        final apiEx = failure.cause;
        expect(apiEx, isA<ApiException>());
        expect((apiEx as ApiException).code, 'PASSWORD_RESET_COOLDOWN');
      },
    );

    test(
      '429 with a Retry-After header parses retryAfterSeconds; without one it stays null',
      () async {
        final adapterWithHeader = _ScriptedAdapter([
          _errorThrow(
            429,
            {
              'statusCode': 429,
              'error': 'Too Many Requests',
              'message': 'Rate limited',
              'code': 'PASSWORD_RESET_RATE_LIMITED',
            },
            headers: {
              'retry-after': ['42'],
            },
          ),
        ]);
        final repoWithHeader = ApiAuthRepository(
          apiClient: _buildClient(adapterWithHeader),
          secureStorage: const FlutterSecureStorage(),
          tokenStorage: TokenStorage(),
        );
        final resultWithHeader = await repoWithHeader.forgotPassword(
          'customer@example.com',
        );
        final failureWithHeader =
            resultWithHeader.failure as PasswordResetRateLimitedFailure;
        expect(failureWithHeader.retryAfterSeconds, 42);

        final adapterNoHeader = _ScriptedAdapter([
          _errorThrow(429, {
            'statusCode': 429,
            'error': 'Too Many Requests',
            'message': 'Rate limited',
          }),
        ]);
        final repoNoHeader = ApiAuthRepository(
          apiClient: _buildClient(adapterNoHeader),
          secureStorage: const FlutterSecureStorage(),
          tokenStorage: TokenStorage(),
        );
        final resultNoHeader = await repoNoHeader.forgotPassword(
          'customer@example.com',
        );
        final failureNoHeader =
            resultNoHeader.failure as PasswordResetRateLimitedFailure;
        // Must never be a guessed/invented value.
        expect(failureNoHeader.retryAfterSeconds, isNull);
      },
    );

    test('a connection error maps to NetworkFailure', () async {
      final adapter = _ScriptedAdapter([
        (options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'Failed host lookup',
        ),
      ]);
      final repo = ApiAuthRepository(
        apiClient: _buildClient(adapter),
        secureStorage: const FlutterSecureStorage(),
        tokenStorage: TokenStorage(),
      );

      final result = await repo.forgotPassword('customer@example.com');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NetworkFailure>());
    });
  });

  group('ApiAuthRepository.resetPassword', () {
    test('200 maps to Success(null) and sends {token, password}', () async {
      final adapter = _ScriptedAdapter([
        _jsonResponse({
          'message':
              'Your password has been reset. Please log in again with your new password.',
        }, 200),
      ]);
      final repo = ApiAuthRepository(
        apiClient: _buildClient(adapter),
        secureStorage: const FlutterSecureStorage(),
        tokenStorage: TokenStorage(),
      );

      final result = await repo.resetPassword(
        token: 'raw-token-value',
        password: 'newPassword123',
      );

      expect(result.isSuccess, isTrue);
      final request = adapter.recordedRequests.single;
      expect(request.path, '/auth/reset-password');
      expect(request.data, {
        'token': 'raw-token-value',
        'password': 'newPassword123',
      });
      expect(request.headers.containsKey('Authorization'), isFalse);
    });

    for (final code in [
      'INVALID_RESET_TOKEN',
      'RESET_TOKEN_ALREADY_USED',
      'RESET_TOKEN_EXPIRED',
    ]) {
      test(
        '401 $code maps to AuthFailure with the code preserved on cause',
        () async {
          final adapter = _ScriptedAdapter([
            _errorThrow(401, {
              'statusCode': 401,
              'error': 'Unauthorized',
              'message': 'This reset link is no longer valid.',
              'code': code,
            }),
          ]);
          final repo = ApiAuthRepository(
            apiClient: _buildClient(adapter),
            secureStorage: const FlutterSecureStorage(),
            tokenStorage: TokenStorage(),
          );

          final result = await repo.resetPassword(
            token: 'some-token',
            password: 'newPassword123',
          );

          expect(result.isFailure, isTrue);
          expect(result.failure, isA<AuthFailure>());
        },
      );
    }

    test('400 VALIDATION_ERROR (bad password length) maps to ValidationFailure', () async {
      final adapter = _ScriptedAdapter([
        _errorThrow(400, {
          'statusCode': 400,
          'error': 'Bad Request',
          'message': 'password must be longer than or equal to 8 characters',
          'code': 'VALIDATION_ERROR',
        }),
      ]);
      final repo = ApiAuthRepository(
        apiClient: _buildClient(adapter),
        secureStorage: const FlutterSecureStorage(),
        tokenStorage: TokenStorage(),
      );

      final result = await repo.resetPassword(
        token: 'some-token',
        password: 'short',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
    });

    test('generic 429 maps to PasswordResetRateLimitedFailure', () async {
      final adapter = _ScriptedAdapter([
        _errorThrow(429, {
          'statusCode': 429,
          'error': 'Too Many Requests',
          'message': 'ThrottlerException: Too Many Requests',
        }),
      ]);
      final repo = ApiAuthRepository(
        apiClient: _buildClient(adapter),
        secureStorage: const FlutterSecureStorage(),
        tokenStorage: TokenStorage(),
      );

      final result = await repo.resetPassword(
        token: 'some-token',
        password: 'newPassword123',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<PasswordResetRateLimitedFailure>());
    });
  });
}
