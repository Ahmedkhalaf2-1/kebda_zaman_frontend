import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/errors/result.dart';
import 'package:kebda_zaman/features/shared/data/api_auth_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';

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

class _ThrowingSecureStoragePlatform extends TestFlutterSecureStoragePlatform {
  _ThrowingSecureStoragePlatform(super.values);

  @override
  Future<void> write({
    required String key,
    required String value,
    required Map<String, String> options,
  }) async {
    if (key == 'refreshToken') {
      throw Exception('Simulated secure storage failure');
    }
    return super.write(key: key, value: value, options: options);
  }
}

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
  });

  group('ApiAuthRepository Atomic Token Persistence', () {
    test(
      'secure token persistence finishes before login returns success',
      () async {
        final adapter = _ScriptedAdapter([
          _jsonSuccess({
            'user': {
              'id': 'usr-1',
              'name': 'Ahmed',
              'email': 'ahmed@test.com',
              'createdAt': DateTime.now().toIso8601String(),
            },
            'accessToken': 'access-123',
            'refreshToken': 'refresh-456',
          }),
        ]);

        final tokenStorage = TokenStorage();
        const secureStorage = FlutterSecureStorage();
        final apiClient = ApiClient(
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );
        apiClient.dio.httpClientAdapter = adapter;

        final repo = ApiAuthRepository(
          apiClient: apiClient,
          secureStorage: secureStorage,
          tokenStorage: tokenStorage,
        );

        final result = await repo.login('ahmed@test.com', 'secret');

        expect(result, isA<Success<User>>());
        // Access token exposed in memory
        expect(tokenStorage.accessToken, 'access-123');
        // Refresh token durably stored in secure storage
        expect(await secureStorage.read(key: 'refreshToken'), 'refresh-456');
      },
    );

    test('storage failure does not expose an authenticated session', () async {
      // Configure secure storage platform to throw when writing refreshToken
      FlutterSecureStoragePlatform.instance = _ThrowingSecureStoragePlatform(
        {},
      );

      final adapter = _ScriptedAdapter([
        _jsonSuccess({
          'user': {
            'id': 'usr-1',
            'name': 'Ahmed',
            'email': 'ahmed@test.com',
            'createdAt': DateTime.now().toIso8601String(),
          },
          'accessToken': 'access-123',
          'refreshToken': 'refresh-456',
        }),
      ]);

      final tokenStorage = TokenStorage()..accessToken = 'pre-existing-token';
      const secureStorage = FlutterSecureStorage();
      final apiClient = ApiClient(
        secureStorage: secureStorage,
        tokenStorage: tokenStorage,
      );
      apiClient.dio.httpClientAdapter = adapter;

      final repo = ApiAuthRepository(
        apiClient: apiClient,
        secureStorage: secureStorage,
        tokenStorage: tokenStorage,
      );

      final result = await repo.login('ahmed@test.com', 'secret');

      // Must return failure because storage write failed
      expect(result, isA<Err<User>>());
      // Both access token and refresh token must be cleared so we do not expose an authenticated session
      expect(tokenStorage.accessToken, isNull);
    });
  });
}
