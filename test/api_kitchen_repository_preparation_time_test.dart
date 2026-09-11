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
import 'package:kebda_zaman/features/admin/data/api_kitchen_repository.dart';

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

Map<String, dynamic> _kitchenOrderJson({
  int? preparationTimeMinutes,
  String? estimatedDeliveryTime,
}) {
  return {
    'id': 'order-1',
    'orderNumber': 'ORD-1',
    'status': 'preparing',
    'deliveryMethod': 'PICKUP',
    'createdAt': '2026-01-01T12:00:00.000Z',
    'items': [],
    'preparationTimeMinutes': preparationTimeMinutes,
    'estimatedDeliveryTime': estimatedDeliveryTime,
  };
}

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
  });

  group('ApiKitchenRepository.setPreparationTime', () {
    test('PATCHes the correct URL with {"minutes": minutes}', () async {
      final adapter = _ScriptedAdapter([
        _jsonResponse(
          _kitchenOrderJson(
            preparationTimeMinutes: 20,
            estimatedDeliveryTime: '2026-01-01T12:20:00.000Z',
          ),
          200,
        ),
      ]);
      final repo = ApiKitchenRepository(_buildClient(adapter));

      await repo.setPreparationTime('order-1', 20);

      expect(adapter.recordedRequests.length, 1);
      final request = adapter.recordedRequests.first;
      expect(request.method, 'PATCH');
      expect(request.path, '/kitchen/orders/order-1/preparation-time');
      expect(request.data, {'minutes': 20});
    });

    test(
      'maps preparationTimeMinutes and estimatedDeliveryTime from the response',
      () async {
        final adapter = _ScriptedAdapter([
          _jsonResponse(
            _kitchenOrderJson(
              preparationTimeMinutes: 27,
              estimatedDeliveryTime: '2026-01-01T12:27:00.000Z',
            ),
            200,
          ),
        ]);
        final repo = ApiKitchenRepository(_buildClient(adapter));

        final result = await repo.setPreparationTime('order-1', 27);

        expect(result.isSuccess, isTrue);
        expect(result.value.preparationTimeMinutes, 27);
        expect(
          result.value.estimatedDeliveryTime,
          '2026-01-01T12:27:00.000Z',
        );
      },
    );

    test(
      'a null preparationTimeMinutes/estimatedDeliveryTime maps to null',
      () async {
        final adapter = _ScriptedAdapter([_jsonResponse(_kitchenOrderJson(), 200)]);
        final repo = ApiKitchenRepository(_buildClient(adapter));

        final result = await repo.setPreparationTime('order-1', 20);

        expect(result.value.preparationTimeMinutes, isNull);
        expect(result.value.estimatedDeliveryTime, isNull);
      },
    );

    test('a 422 API failure returns a Failure, not a thrown exception', () async {
      final adapter = _ScriptedAdapter([
        (options) async => throw DioException(
          requestOptions: options,
          error: ApiException(
            statusCode: 422,
            error: 'Unprocessable Entity',
            message: 'Order is not in a preparation status',
            code: 'ORDER_NOT_IN_PREPARATION',
          ),
        ),
      ]);
      final repo = ApiKitchenRepository(_buildClient(adapter));

      final result = await repo.setPreparationTime('order-1', 20);

      expect(result.isFailure, isTrue);
      expect(
        result.failure.message,
        'Order is not in a preparation status',
      );
    });
  });
}
