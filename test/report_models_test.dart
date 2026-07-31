import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/admin/domain/models/report_models.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

void main() {
  group('OrdersBreakdown.fromJson fulfillment type mapping', () {
    test('maps DELIVERY to FulfillmentType.delivery', () {
      final result = OrdersBreakdown.fromJson({
        'byStatus': [],
        'byFulfillmentType': [
          {'type': 'DELIVERY', 'count': 5},
        ],
        'byPaymentMethod': [],
      });

      expect(result.byFulfillmentType.single.key, FulfillmentType.delivery);
      expect(result.byFulfillmentType.single.count, 5);
    });

    test('maps PICKUP to FulfillmentType.pickup', () {
      final result = OrdersBreakdown.fromJson({
        'byStatus': [],
        'byFulfillmentType': [
          {'type': 'PICKUP', 'count': 3},
        ],
        'byPaymentMethod': [],
      });

      expect(result.byFulfillmentType.single.key, FulfillmentType.pickup);
      expect(result.byFulfillmentType.single.count, 3);
    });

    test('throws FormatException when type is missing', () {
      expect(
        () => OrdersBreakdown.fromJson({
          'byStatus': [],
          'byFulfillmentType': [
            {'count': 1},
          ],
          'byPaymentMethod': [],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException for an unknown type value', () {
      expect(
        () => OrdersBreakdown.fromJson({
          'byStatus': [],
          'byFulfillmentType': [
            {'type': 'DRONE', 'count': 1},
          ],
          'byPaymentMethod': [],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('maps READY_FOR_PICKUP to OrderStatus.readyForPickup', () {
      final result = OrdersBreakdown.fromJson({
        'byStatus': [
          {'status': 'READY_FOR_PICKUP', 'count': 4},
        ],
        'byFulfillmentType': [],
        'byPaymentMethod': [],
      });

      expect(result.byStatus.single.key, OrderStatus.readyForPickup);
      expect(result.byStatus.single.count, 4);
    });

    test('maps PICKED_UP to OrderStatus.pickedUp', () {
      final result = OrdersBreakdown.fromJson({
        'byStatus': [
          {'status': 'PICKED_UP', 'count': 6},
        ],
        'byFulfillmentType': [],
        'byPaymentMethod': [],
      });

      expect(result.byStatus.single.key, OrderStatus.pickedUp);
      expect(result.byStatus.single.count, 6);
    });

    test('unknown lifecycle status still falls back to OrderStatus.unknown', () {
      final result = OrdersBreakdown.fromJson({
        'byStatus': [
          {'status': 'SOME_NEW_STATUS', 'count': 7},
        ],
        'byFulfillmentType': [],
        'byPaymentMethod': [],
      });

      expect(result.byStatus.single.key, OrderStatus.unknown);
      expect(result.byStatus.single.count, 7);
    });

    test('counts remain unchanged by the fulfillment type fix', () {
      final result = OrdersBreakdown.fromJson({
        'byStatus': [
          {'status': 'DELIVERED', 'count': 10},
        ],
        'byFulfillmentType': [
          {'type': 'DELIVERY', 'count': 8},
          {'type': 'PICKUP', 'count': 2},
        ],
        'byPaymentMethod': [],
      });

      expect(result.byStatus.single.count, 10);
      expect(result.byFulfillmentType[0].count, 8);
      expect(result.byFulfillmentType[1].count, 2);
    });

    test('payment method mapping is unchanged (passthrough string)', () {
      final result = OrdersBreakdown.fromJson({
        'byStatus': [],
        'byFulfillmentType': [],
        'byPaymentMethod': [
          {'method': 'CASH', 'count': 4},
          {'method': null, 'count': 1},
        ],
      });

      expect(result.byPaymentMethod[0].key, 'CASH');
      expect(result.byPaymentMethod[0].count, 4);
      expect(result.byPaymentMethod[1].key, '');
      expect(result.byPaymentMethod[1].count, 1);
    });
  });
}
