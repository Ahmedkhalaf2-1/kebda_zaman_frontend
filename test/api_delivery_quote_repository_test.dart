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
import 'package:kebda_zaman/features/shared/data/api_delivery_quote_repository.dart';

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

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
  });

  group('ApiDeliveryQuoteRepository', () {
    test(
      'sends POST /delivery/quote with numeric lat/lng and parses a deliverable quote',
      () async {
        final adapter = _ScriptedAdapter([
          _jsonResponse({
            'deliverable': true,
            'distanceMeters': 13420,
            'distanceKm': '13.42',
            'durationSeconds': 1260,
            'durationMinutes': 21,
            'deliveryFee': '10.00',
            'minimumOrder': '0.00',
            'currency': 'SAR',
            'tier': {
              'id': 'tier-1',
              'minDistanceKm': '0.00',
              'maxDistanceKm': '15.00',
            },
          }, 200),
        ]);
        final repo = ApiDeliveryQuoteRepository(_buildClient(adapter));

        final result = await repo.getQuote(latitude: 21.57, longitude: 39.16);

        expect(adapter.recordedRequests.length, 1);
        final request = adapter.recordedRequests.first;
        expect(request.method, 'POST');
        expect(request.path, '/delivery/quote');
        expect(request.data, {'latitude': 21.57, 'longitude': 39.16});

        expect(result.isSuccess, isTrue);
        expect(result.value.deliverable, isTrue);
        expect(result.value.deliveryFee, equals(10.0));
        expect(result.value.tier!.id, equals('tier-1'));
      },
    );

    test(
      'parses an out-of-range response as a successful, non-deliverable quote',
      () async {
        final adapter = _ScriptedAdapter([
          _jsonResponse({
            'deliverable': false,
            'distanceMeters': 30500,
            'distanceKm': '30.50',
            'durationSeconds': 2400,
            'durationMinutes': 40,
            'currency': 'SAR',
            'reason': 'OUTSIDE_DELIVERY_RANGE',
          }, 200),
        ]);
        final repo = ApiDeliveryQuoteRepository(_buildClient(adapter));

        final result = await repo.getQuote(latitude: 25.0, longitude: 40.0);

        expect(result.isSuccess, isTrue);
        expect(result.value.deliverable, isFalse);
        expect(result.value.reason, equals('OUTSIDE_DELIVERY_RANGE'));
      },
    );

    test(
      'maps a backend error envelope to a Failure carrying the ApiException',
      () async {
        final adapter = _ScriptedAdapter([
          (options) async => throw DioException(
            requestOptions: options,
            error: ApiException(
              statusCode: 422,
              error: 'Unprocessable Entity',
              message: 'The restaurant location is not configured correctly',
              code: 'RESTAURANT_LOCATION_NOT_CONFIGURED',
            ),
            type: DioExceptionType.badResponse,
          ),
        ]);
        final repo = ApiDeliveryQuoteRepository(_buildClient(adapter));

        final result = await repo.getQuote(latitude: 21.57, longitude: 39.16);

        expect(result.isFailure, isTrue);
        final cause = result.failure.cause;
        expect(cause, isA<ApiException>());
        expect(
          (cause as ApiException).code,
          equals('RESTAURANT_LOCATION_NOT_CONFIGURED'),
        );
      },
    );
  });
}
