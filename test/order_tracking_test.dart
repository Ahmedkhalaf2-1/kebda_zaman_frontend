import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/features/shared/data/api_order_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

class FakeApiClient implements ApiClient {
  int callCount = 0;
  List<dynamic> responses = [];
  
  @override
  Dio get dio => FakeDio(this);

  @override
  void addToken(String token) {}
  @override
  void removeToken() {}
  @override
  void setLanguage(String languageCode) {}
}

class FakeDio extends Fake implements Dio {
  final FakeApiClient client;
  FakeDio(this.client);

  @override
  Future<Response<T>> get<T>(String path, {Object? data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, void Function(int, int)? onReceiveProgress}) async {
    if (path.startsWith('/orders/')) {
      if (path.endsWith('/status')) {
         if (client.responses.isEmpty) {
           throw Exception('No more responses');
         }
         final next = client.responses.removeAt(0);
         if (next is Exception) {
           throw next;
         }
         return Response(requestOptions: RequestOptions(path: path), data: next as T);
      }
      return Response(requestOptions: RequestOptions(path: path), data: {
        'id': 'o1',
        'userId': 'u1',
        'items': [],
        'subtotal': 100,
        'taxTotal': 14,
        'deliveryFee': 20,
        'discountTotal': 0,
        'grandTotal': 134,
        'status': 'pending',
        'orderType': 'delivery',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      } as T);
    }
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('OrderTracking transient failures retry using fake time', (tester) async {
    final client = FakeApiClient();
    final repo = ApiOrderRepository(client);

    client.responses.add({'status': 'preparing', 'statusHistory': []});
    client.responses.add(DioException(
      requestOptions: RequestOptions(path: ''),
      error: ApiException(statusCode: 500, error: 'Server Error', message: 'Transient', code: 'SERVER_ERROR')
    ));
    client.responses.add({'status': 'delivering', 'statusHistory': []});
    client.responses.add({'status': 'delivered', 'statusHistory': []});

    final stream = repo.watchOrder('o1');
    final events = [];
    final subscription = stream.listen((order) => events.add(order.status), onError: (e) => events.add('error'));

    await tester.pump(const Duration(seconds: 1));
    expect(events.last, OrderStatus.pending);
    await tester.pump(const Duration(seconds: 10));
    expect(events.last, OrderStatus.preparing);
    await tester.pump(const Duration(seconds: 10));
    expect(events.last, 'error');
    await tester.pump(const Duration(seconds: 10));
    expect(events.last, OrderStatus.delivering);
    await tester.pump(const Duration(seconds: 10));
    expect(events.last, OrderStatus.delivered);

    subscription.cancel();
  });

  testWidgets('ORDER_NOT_FOUND stops polling permanently', (tester) async {
    final client = FakeApiClient();
    final repo = ApiOrderRepository(client);

    client.responses.add(DioException(
      requestOptions: RequestOptions(path: ''),
      response: Response(requestOptions: RequestOptions(path: ''), statusCode: 404),
    ));

    final stream = repo.watchOrder('o1');
    final events = [];
    final subscription = stream.listen((order) => events.add(order.status), onError: (e) => events.add('error'));

    await tester.pump(const Duration(seconds: 1));
    expect(events.last, OrderStatus.pending);
    await tester.pump(const Duration(seconds: 10));
    expect(events.last, 'error');
    
    // Should not request again, so if we pump another 10 seconds, client.responses doesn't need more elements
    // and no more events should be added.
    final eventCount = events.length;
    await tester.pump(const Duration(seconds: 10));
    expect(events.length, eventCount);

    subscription.cancel();
  });

  testWidgets('delivered or cancelled stops polling', (tester) async {
    final client = FakeApiClient();
    final repo = ApiOrderRepository(client);

    client.responses.add({'status': 'delivered', 'statusHistory': []});

    final stream = repo.watchOrder('o1');
    final events = [];
    final subscription = stream.listen((order) => events.add(order.status), onError: (e) => events.add('error'));

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 10));
    expect(events.last, OrderStatus.delivered);
    
    final eventCount = events.length;
    await tester.pump(const Duration(seconds: 10));
    expect(events.length, eventCount);

    subscription.cancel();
  });

  testWidgets('cancelling subscription stops polling immediately', (tester) async {
    final client = FakeApiClient();
    final repo = ApiOrderRepository(client);

    client.responses.add({'status': 'preparing', 'statusHistory': []});

    final stream = repo.watchOrder('o1');
    final events = [];
    final subscription = stream.listen((order) => events.add(order.status), onError: (e) => events.add('error'));

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 10));
    expect(events.last, OrderStatus.preparing);
    
    subscription.cancel();
    await tester.pump(const Duration(seconds: 10));
    
    // No more exceptions or events
  });
}
