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
import 'package:kebda_zaman/features/shared/data/api_order_repository.dart';

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

Map<String, dynamic> _adminOrderJson({String? driverId}) {
  return {
    'id': 'order-1',
    'orderNumber': 'ORD-1',
    'userId': 'user-1',
    'items': [],
    'deliveryMethod': 'DELIVERY',
    'status': 'confirmed',
    'subtotal': 10.0,
    'deliveryFee': 0.0,
    'discount': 0.0,
    'totalAmount': 10.0,
    'paymentStatus': 'PENDING',
    'paymentMethod': 'CASH',
    'createdAt': '2026-01-01T12:00:00.000Z',
    'driverId': driverId,
  };
}

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
  });

  group('driverId mapping', () {
    test('parses an assigned driverId from an admin order response', () {
      final order = ApiOrderRepository.mapOrderForTesting(
        _adminOrderJson(driverId: 'driver-1'),
      );
      expect(order.driverId, 'driver-1');
    });

    test('a null driverId (unassigned / PICKUP order) maps to null', () {
      final order = ApiOrderRepository.mapOrderForTesting(_adminOrderJson());
      expect(order.driverId, isNull);
    });

    test('a missing driverId key never crashes and maps to null', () {
      final json = _adminOrderJson()..remove('driverId');
      final order = ApiOrderRepository.mapOrderForTesting(json);
      expect(order.driverId, isNull);
    });
  });

  group('ApiOrderRepository.assignDriver', () {
    test('PATCHes the correct URL with {"driverId": driverId}', () async {
      final adapter = _ScriptedAdapter([
        _jsonResponse(_adminOrderJson(driverId: 'driver-1'), 200),
      ]);
      final repo = ApiOrderRepository(_buildClient(adapter));

      final result = await repo.assignDriver('order-1', 'driver-1');

      expect(adapter.recordedRequests.length, 1);
      final request = adapter.recordedRequests.first;
      expect(request.method, 'PATCH');
      expect(request.path, '/admin/orders/order-1/driver');
      expect(request.data, {'driverId': 'driver-1'});
      expect(result.isSuccess, isTrue);
      expect(result.value.driverId, 'driver-1');
    });

    test(
      'NOT_A_DELIVERY_ORDER (422) maps to ValidationFailure, never a false success',
      () async {
        final adapter = _ScriptedAdapter([
          (options) async => throw DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 422,
              data: {
                'statusCode': 422,
                'error': 'Unprocessable Entity',
                'message': 'Order is not a delivery order',
                'code': 'NOT_A_DELIVERY_ORDER',
              },
            ),
          ),
        ]);
        final repo = ApiOrderRepository(_buildClient(adapter));

        final result = await repo.assignDriver('order-1', 'driver-1');

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ValidationFailure>());
        expect(
          (result.failure.cause as ApiException).code,
          'NOT_A_DELIVERY_ORDER',
        );
      },
    );

    test(
      'ASSIGNMENT_CHANGED (409, lost race) maps to ValidationFailure',
      () async {
        final adapter = _ScriptedAdapter([
          (options) async => throw DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 409,
              data: {
                'statusCode': 409,
                'error': 'Conflict',
                'message': 'The order was reassigned by someone else',
                'code': 'ASSIGNMENT_CHANGED',
              },
            ),
          ),
        ]);
        final repo = ApiOrderRepository(_buildClient(adapter));

        final result = await repo.assignDriver('order-1', 'driver-1');

        expect(result.isFailure, isTrue);
        expect(result.failure, isA<ValidationFailure>());
        expect(
          (result.failure.cause as ApiException).code,
          'ASSIGNMENT_CHANGED',
        );
      },
    );

    test('a 404 (unknown order) maps to NotFoundFailure', () async {
      final adapter = _ScriptedAdapter([
        (options) async => throw DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 404,
            data: {
              'statusCode': 404,
              'error': 'Not Found',
              'message': 'Order not found',
              'code': 'ORDER_NOT_FOUND',
            },
          ),
        ),
      ]);
      final repo = ApiOrderRepository(_buildClient(adapter));

      final result = await repo.assignDriver('order-1', 'driver-1');

      expect(result.isFailure, isTrue);
      expect(result.failure, isA<NotFoundFailure>());
    });
  });

  group('ApiOrderRepository.unassignDriver', () {
    test('DELETEs the correct URL and maps driverId back to null', () async {
      final adapter = _ScriptedAdapter([
        _jsonResponse(_adminOrderJson(driverId: null), 200),
      ]);
      final repo = ApiOrderRepository(_buildClient(adapter));

      final result = await repo.unassignDriver('order-1');

      expect(adapter.recordedRequests.length, 1);
      final request = adapter.recordedRequests.first;
      expect(request.method, 'DELETE');
      expect(request.path, '/admin/orders/order-1/driver');
      expect(result.isSuccess, isTrue);
      expect(result.value.driverId, isNull);
    });
  });
}
