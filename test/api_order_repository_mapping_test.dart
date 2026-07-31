import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/shared/data/api_order_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Focused mapping tests for [ApiOrderRepository]'s private `_mapOrder`
/// (and its delivery-method / payment-status sub-mappers), exercised via the
/// `@visibleForTesting` seam `mapOrderForTesting`. This is the single mapper
/// used by every endpoint on this repository — customer getOrders/
/// getOrderById, checkout, and admin getAllOrders/updateOrderStatus — so
/// these cases cover all of them without hitting a live backend.
void main() {
  Map<String, dynamic> baseOrderJson({
    Object? deliveryMethod = 'DELIVERY',
    Object? paymentStatus = 'PENDING',
    String status = 'pending',
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
      'paymentStatus': paymentStatus,
      'paymentMethod': 'CASH',
      'createdAt': '2026-07-01T12:00:00.000Z',
    };
  }

  group('ApiOrderRepository fulfillmentType mapping', () {
    test('deliveryMethod DELIVERY maps to FulfillmentType.delivery', () {
      final order = ApiOrderRepository.mapOrderForTesting(
        baseOrderJson(deliveryMethod: 'DELIVERY'),
      );
      expect(order.fulfillmentType, FulfillmentType.delivery);
    });

    test('deliveryMethod PICKUP maps to FulfillmentType.pickup', () {
      final order = ApiOrderRepository.mapOrderForTesting(
        baseOrderJson(deliveryMethod: 'PICKUP'),
      );
      expect(order.fulfillmentType, FulfillmentType.pickup);
    });

    test('missing deliveryMethod does NOT silently map to delivery', () {
      expect(
        () => ApiOrderRepository.mapOrderForTesting(
          baseOrderJson(deliveryMethod: null),
        ),
        throwsFormatException,
      );
    });

    test('unknown deliveryMethod does NOT silently map to delivery', () {
      expect(
        () => ApiOrderRepository.mapOrderForTesting(
          baseOrderJson(deliveryMethod: 'CARRIER_PIGEON'),
        ),
        throwsFormatException,
      );
    });
  });

  group('ApiOrderRepository paymentStatus mapping', () {
    test('paymentStatus PENDING maps to the wire format expected by the UI', () {
      final order = ApiOrderRepository.mapOrderForTesting(
        baseOrderJson(paymentStatus: 'PENDING'),
      );
      // The only current UI call site (admin order details screen) just
      // interpolates order.paymentStatus directly for display, so the
      // mapper preserves the backend's canonical uppercase wire value
      // rather than inventing a different casing/enum.
      expect(order.paymentStatus, 'PENDING');
    });

    test('paymentStatus PAID maps correctly', () {
      final order = ApiOrderRepository.mapOrderForTesting(
        baseOrderJson(paymentStatus: 'PAID'),
      );
      expect(order.paymentStatus, 'PAID');
    });

    test('missing paymentStatus from a live API response is rejected', () {
      expect(
        () => ApiOrderRepository.mapOrderForTesting(
          baseOrderJson(paymentStatus: null),
        ),
        throwsFormatException,
      );
    });

    test('unknown paymentStatus is rejected', () {
      expect(
        () => ApiOrderRepository.mapOrderForTesting(
          baseOrderJson(paymentStatus: 'MYSTERY'),
        ),
        throwsFormatException,
      );
    });
  });

  test('customer list mapping preserves Pickup', () {
    final order = ApiOrderRepository.mapOrderForTesting(
      baseOrderJson(deliveryMethod: 'PICKUP'),
    );
    expect(order.fulfillmentType, FulfillmentType.pickup);
  });

  test('admin list mapping preserves Pickup (same _mapOrder as admin getAllOrders)', () {
    // ApiOrderRepository.getAllOrders() maps '/admin/orders' list items
    // through the exact same _mapOrder used here — there is no separate
    // admin fallback mapper.
    final order = ApiOrderRepository.mapOrderForTesting(
      baseOrderJson(deliveryMethod: 'PICKUP', paymentStatus: 'PAID'),
    );
    expect(order.fulfillmentType, FulfillmentType.pickup);
    expect(order.paymentStatus, 'PAID');
  });

  test(
    'checkout response mapping preserves Pickup and payment status '
    '(same _mapOrder as checkout())',
    () {
      final order = ApiOrderRepository.mapOrderForTesting(
        baseOrderJson(deliveryMethod: 'PICKUP', paymentStatus: 'PENDING'),
      );
      expect(order.fulfillmentType, FulfillmentType.pickup);
      expect(order.paymentStatus, 'PENDING');
    },
  );

  test(
    'unknown order lifecycle status still falls back to OrderStatus.unknown '
    '(regression)',
    () {
      final order = ApiOrderRepository.mapOrderForTesting(
        baseOrderJson(status: 'some_new_status_the_app_does_not_know'),
      );
      expect(order.status, OrderStatus.unknown);
    },
  );

  group('ApiOrderRepository pickup-specific status mapping (Fix 9D)', () {
    test("'readyForPickup' maps to OrderStatus.readyForPickup", () {
      final order = ApiOrderRepository.mapOrderForTesting(
        baseOrderJson(deliveryMethod: 'PICKUP', status: 'readyForPickup'),
      );
      expect(order.status, OrderStatus.readyForPickup);
    });

    test("'pickedUp' maps to OrderStatus.pickedUp", () {
      final order = ApiOrderRepository.mapOrderForTesting(
        baseOrderJson(deliveryMethod: 'PICKUP', status: 'pickedUp'),
      );
      expect(order.status, OrderStatus.pickedUp);
    });
  });

  group(
    'ApiOrderRepository status-polling mapper '
    '(GET /orders/:id/status via watchOrder)',
    () {
      test('maps current status readyForPickup', () {
        final result = ApiOrderRepository.mapStatusPollResponseForTesting({
          'status': 'readyForPickup',
          'statusHistory': [],
        });
        expect(result.status, OrderStatus.readyForPickup);
      });

      test('maps current status pickedUp', () {
        final result = ApiOrderRepository.mapStatusPollResponseForTesting({
          'status': 'pickedUp',
          'statusHistory': [],
        });
        expect(result.status, OrderStatus.pickedUp);
      });

      test('maps statusHistory entries containing pickedUp', () {
        final result = ApiOrderRepository.mapStatusPollResponseForTesting({
          'status': 'pickedUp',
          'statusHistory': [
            {'status': 'pending', 'changedAt': '2026-07-01T10:00:00.000Z'},
            {'status': 'readyForPickup', 'changedAt': '2026-07-01T10:20:00.000Z'},
            {'status': 'pickedUp', 'changedAt': '2026-07-01T10:30:00.000Z'},
          ],
        });
        expect(result.statusHistory.map((e) => e.status).toList(), [
          OrderStatus.pending,
          OrderStatus.readyForPickup,
          OrderStatus.pickedUp,
        ]);
      });

      test('unknown status in the polling response falls back to unknown', () {
        final result = ApiOrderRepository.mapStatusPollResponseForTesting({
          'status': 'some_new_status_the_app_does_not_know',
          'statusHistory': [],
        });
        expect(result.status, OrderStatus.unknown);
      });
    },
  );
}
