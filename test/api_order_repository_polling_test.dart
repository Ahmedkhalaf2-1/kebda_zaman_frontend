import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart'
    hide Options;
import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/data/api_order_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Fix 14 — order-tracking polling resilience tests for
/// [ApiOrderRepository.watchOrder]. Runs entirely against a scripted Dio
/// adapter (no live backend) and an injected zero-wait delay function (no
/// real multi-second sleeps), so the retry/backoff control flow itself is
/// exercised deterministically and fast.
typedef _ScriptStep = Future<ResponseBody> Function(RequestOptions options);

class _ScriptedAdapter implements HttpClientAdapter {
  final Map<String, List<_ScriptStep>> scripts;
  final Map<String, int> callCounts = {};

  /// Tracks concurrently in-flight requests per adapter instance, so tests
  /// can assert `watchOrder` never issues overlapping polling requests.
  int _inFlight = 0;
  int maxInFlight = 0;

  _ScriptedAdapter(this.scripts);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    _inFlight++;
    if (_inFlight > maxInFlight) maxInFlight = _inFlight;
    callCounts[options.path] = (callCounts[options.path] ?? 0) + 1;
    try {
      final list = scripts[options.path];
      if (list == null || list.isEmpty) {
        throw StateError('No more scripted responses for ${options.path}');
      }
      final step = list.removeAt(0);
      return await step(options);
    } finally {
      _inFlight--;
    }
  }

  @override
  void close({bool force = false}) {}
}

_ScriptStep _jsonSuccess(Map<String, dynamic> data) {
  return (options) async => ResponseBody.fromString(
    jsonEncode(data),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

_ScriptStep _statusError(int statusCode, [Map<String, dynamic>? data]) {
  return (options) async => ResponseBody.fromString(
    jsonEncode(data ?? {}),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

_ScriptStep _dioError(DioExceptionType type) {
  return (options) async {
    throw DioException(
      requestOptions: options,
      type: type,
      message: 'simulated $type',
    );
  };
}

Map<String, dynamic> _orderJson({
  String status = 'pending',
  String deliveryMethod = 'DELIVERY',
}) {
  return {
    'id': 'order-1',
    'orderNumber': 'ORD-1',
    'userId': 'user-1',
    'items': [],
    'deliveryMethod': deliveryMethod,
    'status': status,
    'subtotal': 10.0,
    'deliveryFee': 0.0,
    'discount': 0.0,
    'totalAmount': 10.0,
    'paymentStatus': 'PENDING',
    'paymentMethod': 'CASH',
    'createdAt': '2026-07-01T12:00:00.000Z',
  };
}

Map<String, dynamic> _pollJson({
  String status = 'pending',
  List<Map<String, dynamic>> statusHistory = const [],
}) {
  return {'status': status, 'statusHistory': statusHistory};
}

void main() {
  setUp(() {
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      {},
    );
  });

  ({ApiOrderRepository repo, _ScriptedAdapter adapter, List<Duration> delays})
  buildRepo(Map<String, List<_ScriptStep>> scripts) {
    const secureStorage = FlutterSecureStorage();
    final apiClient = ApiClient(
      secureStorage: secureStorage,
      tokenStorage: TokenStorage(),
    );
    final adapter = _ScriptedAdapter(scripts);
    // Isolated from the Dio-level AuthInterceptor/RetryInterceptor — this
    // suite exercises ApiOrderRepository's own retry policy in isolation
    // (interceptor-level retry is already covered by auth_interceptor_test).
    apiClient.dio.interceptors.clear();
    apiClient.dio.httpClientAdapter = adapter;

    final delays = <Duration>[];
    final repo = ApiOrderRepository(
      apiClient,
      delay: (d) async {
        delays.add(d);
      },
    );
    return (repo: repo, adapter: adapter, delays: delays);
  }

  /// Drains [stream] fully, capturing every emitted order and (at most) the
  /// terminating error, without ever waiting on a real timer.
  Future<({List<Order> orders, Object? error})> collect(
    Stream<Order> stream,
  ) async {
    final orders = <Order>[];
    Object? error;
    final done = Completer<void>();
    final sub = stream.listen(
      orders.add,
      onError: (Object e) {
        error = e;
        if (!done.isCompleted) done.complete();
      },
      onDone: () {
        if (!done.isCompleted) done.complete();
      },
    );
    await done.future;
    await sub.cancel();
    return (orders: orders, error: error);
  }

  group('watchOrder — initial load', () {
    test('1. successful initial fetch emits the initial order', () async {
      final stack = buildRepo({
        '/orders/order-1': [_jsonSuccess(_orderJson(status: 'pending'))],
      });
      final first = await stack.repo.watchOrder('order-1').first;
      expect(first.status, OrderStatus.pending);
    });

    test(
      '16. transient initial-load failure retries and later succeeds',
      () async {
        final stack = buildRepo({
          '/orders/order-1': [
            _dioError(DioExceptionType.connectionTimeout),
            _jsonSuccess(_orderJson(status: 'pending')),
          ],
        });
        final first = await stack.repo.watchOrder('order-1').first;
        expect(first.status, OrderStatus.pending);
        expect(stack.adapter.callCounts['/orders/order-1'], 2);
        expect(stack.delays, [const Duration(seconds: 2)]);
      },
    );

    test(
      '17. permanent initial-load failure emits one error and terminates',
      () async {
        final stack = buildRepo({
          '/orders/order-1': [_statusError(404)],
        });
        final result = await collect(stack.repo.watchOrder('order-1'));
        expect(result.orders, isEmpty);
        expect(result.error, isA<NetworkFailure>());
        // Never retried — permanent failures are not retried.
        expect(stack.adapter.callCounts['/orders/order-1'], 1);
      },
    );

    test(
      '18. exhausted initial-load retries emit one error and terminate',
      () async {
        final stack = buildRepo({
          '/orders/order-1': List.generate(
            5,
            (_) => _dioError(DioExceptionType.connectionTimeout),
          ),
        });
        final result = await collect(stack.repo.watchOrder('order-1'));
        expect(result.orders, isEmpty);
        expect(result.error, isA<NetworkFailure>());
        expect(stack.adapter.callCounts['/orders/order-1'], 5);
        // 4 backoff waits between the 5 failed attempts: 2s, 4s, 8s, 8s.
        expect(stack.delays, [
          const Duration(seconds: 2),
          const Duration(seconds: 4),
          const Duration(seconds: 8),
          const Duration(seconds: 8),
        ]);
      },
    );
  });

  group('watchOrder — terminal initial status (no polling)', () {
    test(
      '2. an initially terminal delivered order emits once and performs no polling',
      () async {
        final stack = buildRepo({
          '/orders/order-1': [_jsonSuccess(_orderJson(status: 'delivered'))],
        });
        final result = await collect(stack.repo.watchOrder('order-1'));
        expect(result.orders.map((o) => o.status).toList(), [
          OrderStatus.delivered,
        ]);
        expect(result.error, isNull);
        expect(stack.adapter.callCounts['/orders/order-1/status'], isNull);
      },
    );

    test(
      '3. an initially terminal pickedUp order emits once and performs no polling',
      () async {
        final stack = buildRepo({
          '/orders/order-1': [
            _jsonSuccess(
              _orderJson(status: 'pickedUp', deliveryMethod: 'PICKUP'),
            ),
          ],
        });
        final result = await collect(stack.repo.watchOrder('order-1'));
        expect(result.orders.map((o) => o.status).toList(), [
          OrderStatus.pickedUp,
        ]);
        expect(result.error, isNull);
        expect(stack.adapter.callCounts['/orders/order-1/status'], isNull);
      },
    );

    test(
      '4. an initially terminal cancelled order emits once and performs no polling',
      () async {
        final stack = buildRepo({
          '/orders/order-1': [_jsonSuccess(_orderJson(status: 'cancelled'))],
        });
        final result = await collect(stack.repo.watchOrder('order-1'));
        expect(result.orders.map((o) => o.status).toList(), [
          OrderStatus.cancelled,
        ]);
        expect(result.error, isNull);
        expect(stack.adapter.callCounts['/orders/order-1/status'], isNull);
      },
    );
  });

  group('watchOrder — polling', () {
    test('5. a non-terminal order polls and emits a changed status', () async {
      final stack = buildRepo({
        '/orders/order-1': [_jsonSuccess(_orderJson(status: 'pending'))],
        '/orders/order-1/status': [
          _jsonSuccess(_pollJson(status: 'confirmed')),
        ],
      });
      final orders = await stack.repo.watchOrder('order-1').take(2).toList();
      expect(orders.map((o) => o.status).toList(), [
        OrderStatus.pending,
        OrderStatus.confirmed,
      ]);
    });

    test(
      '6. an unchanged successful poll does not emit a duplicate order',
      () async {
        final stack = buildRepo({
          '/orders/order-1': [_jsonSuccess(_orderJson(status: 'pending'))],
          '/orders/order-1/status': [
            _jsonSuccess(_pollJson(status: 'pending')), // unchanged
            _jsonSuccess(_pollJson(status: 'confirmed')), // changed
          ],
        });
        final orders = await stack.repo
            .watchOrder('order-1')
            .take(2)
            .toList();
        // Exactly 2 emissions total: the initial order, then the *changed*
        // poll — the unchanged poll never produced a 3rd/duplicate event.
        expect(orders.map((o) => o.status).toList(), [
          OrderStatus.pending,
          OrderStatus.confirmed,
        ]);
        expect(stack.adapter.callCounts['/orders/order-1/status'], 2);
      },
    );

    test(
      '7. a single transient polling failure does not emit Stream.error',
      () async {
        final stack = buildRepo({
          '/orders/order-1': [_jsonSuccess(_orderJson(status: 'pending'))],
          '/orders/order-1/status': [
            _dioError(DioExceptionType.connectionTimeout),
            _jsonSuccess(_pollJson(status: 'confirmed')),
          ],
        });
        final orders = await stack.repo
            .watchOrder('order-1')
            .take(2)
            .toList();
        expect(orders.map((o) => o.status).toList(), [
          OrderStatus.pending,
          OrderStatus.confirmed,
        ]);
      },
    );

    test('8. polling resumes after a transient failure', () async {
      final stack = buildRepo({
        '/orders/order-1': [_jsonSuccess(_orderJson(status: 'pending'))],
        '/orders/order-1/status': [
          _dioError(DioExceptionType.connectionTimeout),
          _jsonSuccess(_pollJson(status: 'confirmed')),
          _jsonSuccess(_pollJson(status: 'outForDelivery')),
        ],
      });
      final orders = await stack.repo.watchOrder('order-1').take(3).toList();
      expect(orders.map((o) => o.status).toList(), [
        OrderStatus.pending,
        OrderStatus.confirmed,
        OrderStatus.outForDelivery,
      ]);
      // 10s poll wait, 2s retry backoff after the one failure, then back to
      // the normal 10s poll wait for the next cycle — confirms the normal
      // interval resumes rather than staying at the retry cadence.
      expect(stack.delays, [
        const Duration(seconds: 10),
        const Duration(seconds: 2),
        const Duration(seconds: 10),
      ]);
    });

    test('9. retry counter resets after a successful poll', () async {
      final stack = buildRepo({
        '/orders/order-1': [_jsonSuccess(_orderJson(status: 'pending'))],
        '/orders/order-1/status': [
          _dioError(DioExceptionType.connectionTimeout),
          _jsonSuccess(_pollJson(status: 'confirmed')),
          _dioError(DioExceptionType.connectionTimeout),
          _jsonSuccess(_pollJson(status: 'outForDelivery')),
        ],
      });
      final orders = await stack.repo.watchOrder('order-1').take(3).toList();
      expect(orders.map((o) => o.status).toList(), [
        OrderStatus.pending,
        OrderStatus.confirmed,
        OrderStatus.outForDelivery,
      ]);
      // Both poll cycles hit exactly one transient failure — if the retry
      // counter didn't reset after the first cycle's success, the second
      // cycle's backoff would start at 4s instead of 2s.
      expect(stack.delays, [
        const Duration(seconds: 10),
        const Duration(seconds: 2),
        const Duration(seconds: 10),
        const Duration(seconds: 2),
      ]);
    });

    test(
      '11. after five consecutive transient polling failures, one '
      'NetworkFailure is emitted and the stream terminates',
      () async {
        final stack = buildRepo({
          '/orders/order-1': [_jsonSuccess(_orderJson(status: 'pending'))],
          '/orders/order-1/status': List.generate(
            5,
            (_) => _dioError(DioExceptionType.connectionTimeout),
          ),
        });
        final result = await collect(stack.repo.watchOrder('order-1'));
        expect(result.orders.map((o) => o.status).toList(), [
          OrderStatus.pending,
        ]);
        expect(result.error, isA<NetworkFailure>());
        expect(stack.adapter.callCounts['/orders/order-1/status'], 5);
      },
    );

    test('14. permanent polling failure emits one error and terminates', () async {
      final stack = buildRepo({
        '/orders/order-1': [_jsonSuccess(_orderJson(status: 'pending'))],
        '/orders/order-1/status': [_statusError(404)],
      });
      final result = await collect(stack.repo.watchOrder('order-1'));
      expect(result.orders.map((o) => o.status).toList(), [
        OrderStatus.pending,
      ]);
      expect(result.error, isA<NetworkFailure>());
      // Never retried.
      expect(stack.adapter.callCounts['/orders/order-1/status'], 1);
    });

    test(
      '15. malformed poll payload emits one appropriate failure and terminates',
      () async {
        final stack = buildRepo({
          '/orders/order-1': [_jsonSuccess(_orderJson(status: 'pending'))],
          '/orders/order-1/status': [
            _jsonSuccess({
              'status': 'confirmed',
              'statusHistory': [
                {'status': 'confirmed', 'changedAt': 'not-a-real-date'},
              ],
            }),
          ],
        });
        final result = await collect(stack.repo.watchOrder('order-1'));
        expect(result.orders.map((o) => o.status).toList(), [
          OrderStatus.pending,
        ]);
        expect(result.error, isNotNull);
        // Malformed payloads are never retried as if they were network
        // interruptions.
        expect(stack.adapter.callCounts['/orders/order-1/status'], 1);
      },
    );

    test('22. readyForPickup remains actively polled', () async {
      final stack = buildRepo({
        '/orders/order-1': [
          _jsonSuccess(
            _orderJson(status: 'readyForPickup', deliveryMethod: 'PICKUP'),
          ),
        ],
        '/orders/order-1/status': [
          _jsonSuccess(_pollJson(status: 'pickedUp')),
        ],
      });
      final orders = await stack.repo.watchOrder('order-1').take(2).toList();
      expect(orders.map((o) => o.status).toList(), [
        OrderStatus.readyForPickup,
        OrderStatus.pickedUp,
      ]);
      expect(stack.adapter.callCounts['/orders/order-1/status'], 1);
    });

    test('24. no overlapping status requests occur', () async {
      final stack = buildRepo({
        '/orders/order-1': [_jsonSuccess(_orderJson(status: 'pending'))],
        '/orders/order-1/status': [
          _jsonSuccess(_pollJson(status: 'confirmed')),
          _jsonSuccess(_pollJson(status: 'outForDelivery')),
          _jsonSuccess(_pollJson(status: 'delivered')),
        ],
      });
      final orders = await stack.repo.watchOrder('order-1').take(4).toList();
      expect(orders, hasLength(4));
      expect(stack.adapter.maxInFlight, 1);
    });
  });

  group('watchOrder — terminal transitions mid-poll', () {
    test('19. transition to delivered emits once and stops', () async {
      final stack = buildRepo({
        '/orders/order-1': [_jsonSuccess(_orderJson(status: 'outForDelivery'))],
        '/orders/order-1/status': [
          _jsonSuccess(_pollJson(status: 'delivered')),
        ],
      });
      final result = await collect(stack.repo.watchOrder('order-1'));
      expect(result.orders.map((o) => o.status).toList(), [
        OrderStatus.outForDelivery,
        OrderStatus.delivered,
      ]);
      expect(result.error, isNull);
      expect(stack.adapter.callCounts['/orders/order-1/status'], 1);
    });

    test('20. transition to pickedUp emits once and stops', () async {
      final stack = buildRepo({
        '/orders/order-1': [
          _jsonSuccess(
            _orderJson(status: 'readyForPickup', deliveryMethod: 'PICKUP'),
          ),
        ],
        '/orders/order-1/status': [
          _jsonSuccess(_pollJson(status: 'pickedUp')),
        ],
      });
      final result = await collect(stack.repo.watchOrder('order-1'));
      expect(result.orders.map((o) => o.status).toList(), [
        OrderStatus.readyForPickup,
        OrderStatus.pickedUp,
      ]);
      expect(result.error, isNull);
      expect(stack.adapter.callCounts['/orders/order-1/status'], 1);
    });

    test('21. transition to cancelled emits once and stops', () async {
      final stack = buildRepo({
        '/orders/order-1': [_jsonSuccess(_orderJson(status: 'preparing'))],
        '/orders/order-1/status': [
          _jsonSuccess(_pollJson(status: 'cancelled')),
        ],
      });
      final result = await collect(stack.repo.watchOrder('order-1'));
      expect(result.orders.map((o) => o.status).toList(), [
        OrderStatus.preparing,
        OrderStatus.cancelled,
      ]);
      expect(result.error, isNull);
      expect(stack.adapter.callCounts['/orders/order-1/status'], 1);
    });
  });

  group('watchOrder — cancellation', () {
    test('23. stream cancellation stops future polling/retries', () async {
      final stack = buildRepo({
        '/orders/order-1': [_jsonSuccess(_orderJson(status: 'pending'))],
        '/orders/order-1/status': [
          _jsonSuccess(_pollJson(status: 'confirmed')),
          // Deliberately no further scripted responses — if watchOrder
          // kept polling after cancellation, it would hit this and throw.
        ],
      });

      final received = <Order>[];
      final gotSecond = Completer<void>();
      final sub = stack.repo.watchOrder('order-1').listen((order) {
        received.add(order);
        if (received.length == 2 && !gotSecond.isCompleted) {
          gotSecond.complete();
        }
      });
      await gotSecond.future;
      await sub.cancel();

      final countAfterCancel =
          stack.adapter.callCounts['/orders/order-1/status'];
      // Pump several event-loop turns — with the zero-wait test delay, a
      // still-running poll loop would have made another request by now.
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(
        stack.adapter.callCounts['/orders/order-1/status'],
        countAfterCancel,
      );
    });
  });

  group('failure classification', () {
    DioException statusException(int code) => DioException(
      requestOptions: RequestOptions(path: '/orders/x/status'),
      response: Response(
        requestOptions: RequestOptions(path: '/orders/x/status'),
        statusCode: code,
      ),
      type: DioExceptionType.badResponse,
    );

    DioException typeException(DioExceptionType type) => DioException(
      requestOptions: RequestOptions(path: '/orders/x/status'),
      type: type,
    );

    test('12. HTTP 500/502/503/504 are retryable', () {
      for (final code in [500, 502, 503, 504]) {
        expect(
          ApiOrderRepository.isTransientDioErrorForTesting(
            statusException(code),
          ),
          isTrue,
          reason: '$code should be transient',
        );
      }
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        expect(
          ApiOrderRepository.isTransientDioErrorForTesting(typeException(type)),
          isTrue,
          reason: '$type should be transient',
        );
      }
    });

    test('13. HTTP 400/401/403/404/409/422 are not retried', () {
      for (final code in [400, 401, 403, 404, 409, 422]) {
        expect(
          ApiOrderRepository.isTransientDioErrorForTesting(
            statusException(code),
          ),
          isFalse,
          reason: '$code should be permanent',
        );
      }
    });
  });

  group('retry backoff curve', () {
    test('10. consecutive retry delays follow: 2s -> 4s -> 8s -> 8s -> 8s', () {
      expect(
        ApiOrderRepository.retryDelayForTesting(1),
        const Duration(seconds: 2),
      );
      expect(
        ApiOrderRepository.retryDelayForTesting(2),
        const Duration(seconds: 4),
      );
      expect(
        ApiOrderRepository.retryDelayForTesting(3),
        const Duration(seconds: 8),
      );
      expect(
        ApiOrderRepository.retryDelayForTesting(4),
        const Duration(seconds: 8),
      );
      expect(
        ApiOrderRepository.retryDelayForTesting(5),
        const Duration(seconds: 8),
      );
    });
  });
}
