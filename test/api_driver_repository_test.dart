import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/data/api_driver_repository.dart';
import 'package:kebda_zaman/features/admin/domain/models/driver_account.dart';

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
  int statusCode,
) {
  return (options) async => ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

ApiClient _buildClient(_ScriptedAdapter adapter) {
  final apiClient = ApiClient(
    secureStorage: const FlutterSecureStorage(),
    tokenStorage: TokenStorage()..accessToken = 'test-token',
  );
  apiClient.dio.httpClientAdapter = adapter;
  return apiClient;
}

Map<String, dynamic> _driverJson({
  String id = 'driver-1',
  String name = 'Ahmed Driver',
  String? email = 'driver1@example.com',
  String? phone = '0500000000',
  bool isActive = true,
}) {
  return {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'isActive': isActive,
    'createdAt': '2026-01-01T12:00:00.000Z',
  };
}

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
  });

  group('ApiDriverRepository.getDrivers', () {
    test(
      'GET /admin/drivers returns a plain array (no total envelope) mapped to DriverAccount list',
      () async {
        final adapter = _ScriptedAdapter([
          _jsonResponse([
            _driverJson(id: 'driver-1'),
            _driverJson(id: 'driver-2', isActive: false),
          ], 200),
        ]);
        final repo = ApiDriverRepository(_buildClient(adapter));

        final result = await repo.getDrivers();

        expect(result.isSuccess, isTrue);
        expect(result.value, hasLength(2));
        expect(result.value[0].id, 'driver-1');
        expect(result.value[0].isActive, isTrue);
        expect(result.value[1].isActive, isFalse);
      },
    );

    test('passes q/isActive/page/limit as query parameters', () async {
      final adapter = _ScriptedAdapter([_jsonResponse([], 200)]);
      final repo = ApiDriverRepository(_buildClient(adapter));

      await repo.getDrivers(query: 'ahmed', isActive: true, page: 2, limit: 10);

      final request = adapter.recordedRequests.single;
      expect(request.path, '/admin/drivers');
      expect(request.queryParameters['q'], 'ahmed');
      expect(request.queryParameters['isActive'], true);
      expect(request.queryParameters['page'], 2);
      expect(request.queryParameters['limit'], 10);
    });

    test(
      'an empty page (fewer than the limit) is a normal success, not an error',
      () async {
        final adapter = _ScriptedAdapter([_jsonResponse([], 200)]);
        final repo = ApiDriverRepository(_buildClient(adapter));

        final result = await repo.getDrivers(page: 5, limit: 20);

        expect(result.isSuccess, isTrue);
        expect(result.value, isEmpty);
      },
    );

    test('parses server-calculated availability and activeOrderId', () async {
      final adapter = _ScriptedAdapter([
        _jsonResponse([
          {
            ..._driverJson(id: 'driver-1'),
            'availability': 'AVAILABLE',
            'activeOrderId': null,
          },
          {
            ..._driverJson(id: 'driver-2'),
            'availability': 'BUSY',
            'activeOrderId': 'order-99',
          },
        ], 200),
      ]);
      final repo = ApiDriverRepository(_buildClient(adapter));

      final result = await repo.getDrivers();

      expect(result.value[0].availability, DriverAvailability.available);
      expect(result.value[0].activeOrderId, isNull);
      expect(result.value[1].availability, DriverAvailability.busy);
      expect(result.value[1].activeOrderId, 'order-99');
    });

    test(
      'a missing/unrecognized availability value falls back to unknown, never available',
      () async {
        final adapter = _ScriptedAdapter([
          _jsonResponse([_driverJson(id: 'driver-1')], 200),
        ]);
        final repo = ApiDriverRepository(_buildClient(adapter));

        final result = await repo.getDrivers();

        expect(result.value.single.availability, DriverAvailability.unknown);
      },
    );
  });

  group('ApiDriverRepository.createDriver', () {
    test('POSTs name/email/password/phone and maps the 201 response', () async {
      final adapter = _ScriptedAdapter([_jsonResponse(_driverJson(), 201)]);
      final repo = ApiDriverRepository(_buildClient(adapter));

      final result = await repo.createDriver(
        name: 'Ahmed Driver',
        email: 'driver1@example.com',
        password: 'password123',
        phone: '0500000000',
      );

      final request = adapter.recordedRequests.single;
      expect(request.method, 'POST');
      expect(request.path, '/admin/drivers');
      expect(request.data, {
        'name': 'Ahmed Driver',
        'email': 'driver1@example.com',
        'password': 'password123',
        'phone': '0500000000',
      });
      expect(result.isSuccess, isTrue);
      expect(result.value.name, 'Ahmed Driver');
    });

    test('omits phone entirely when not supplied', () async {
      final adapter = _ScriptedAdapter([
        _jsonResponse(_driverJson(phone: null), 201),
      ]);
      final repo = ApiDriverRepository(_buildClient(adapter));

      await repo.createDriver(
        name: 'Ahmed Driver',
        email: 'driver1@example.com',
        password: 'password123',
      );

      final request = adapter.recordedRequests.single;
      expect(request.data, {
        'name': 'Ahmed Driver',
        'email': 'driver1@example.com',
        'password': 'password123',
      });
    });

    test('EMAIL_ALREADY_EXISTS (409) maps to ValidationFailure', () async {
      final adapter = _ScriptedAdapter([
        (options) async => throw DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 409,
            data: {
              'statusCode': 409,
              'error': 'Conflict',
              'message': 'An account with this email already exists',
              'code': 'EMAIL_ALREADY_EXISTS',
            },
          ),
        ),
      ]);
      final repo = ApiDriverRepository(_buildClient(adapter));

      final result = await repo.createDriver(
        name: 'Ahmed Driver',
        email: 'dup@example.com',
        password: 'password123',
      );

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<ValidationFailure>());
    });
  });

  group('ApiDriverRepository.updateDriver', () {
    test('PATCHes only the supplied fields', () async {
      final adapter = _ScriptedAdapter([
        _jsonResponse(_driverJson(isActive: false), 200),
      ]);
      final repo = ApiDriverRepository(_buildClient(adapter));

      final result = await repo.updateDriver('driver-1', isActive: false);

      final request = adapter.recordedRequests.single;
      expect(request.method, 'PATCH');
      expect(request.path, '/admin/drivers/driver-1');
      expect(request.data, {'isActive': false});
      expect(result.isSuccess, isTrue);
      expect(result.value.isActive, isFalse);
    });

    test('never sends an empty password field', () async {
      final adapter = _ScriptedAdapter([_jsonResponse(_driverJson(), 200)]);
      final repo = ApiDriverRepository(_buildClient(adapter));

      await repo.updateDriver('driver-1', name: 'New Name', password: '');

      final request = adapter.recordedRequests.single;
      expect(request.data, {'name': 'New Name'});
    });

    test('DRIVER_NOT_FOUND (404) maps to NotFoundFailure', () async {
      final adapter = _ScriptedAdapter([
        (options) async => throw DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 404,
            data: {
              'statusCode': 404,
              'error': 'Not Found',
              'message': 'Driver not found',
              'code': 'DRIVER_NOT_FOUND',
            },
          ),
        ),
      ]);
      final repo = ApiDriverRepository(_buildClient(adapter));

      final result = await repo.updateDriver('missing-driver', isActive: true);

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NotFoundFailure>());
    });
  });
}
