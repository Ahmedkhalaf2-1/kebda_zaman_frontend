import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Focused domain-level tests for the pickup-specific status flow added on
/// top of the existing Delivery flow (backend commit 51393d0):
/// [OrderStatus.readyForPickup] / [OrderStatus.pickedUp], the
/// [OrderStatusX.isTerminal] terminal-status helper, the fulfillment-aware
/// [FulfillmentTypeStatusX.statusSequence], and the
/// [OrderCrossMethodX.hasCrossMethodStatusMismatch] cross-method defense.
void main() {
  Order buildOrder({
    required FulfillmentType fulfillmentType,
    required OrderStatus status,
  }) {
    return Order(
      id: 'order-1',
      orderNumber: 'ORD-1',
      userId: 'user-1',
      items: const [],
      fulfillmentType: fulfillmentType,
      status: status,
      subtotal: 10.0,
      grandTotal: 10.0,
      placedAt: DateTime(2026, 7, 1),
    );
  }

  group('OrderStatus.isTerminal', () {
    test('delivered is terminal', () {
      expect(OrderStatus.delivered.isTerminal, isTrue);
    });

    test('pickedUp is terminal', () {
      expect(OrderStatus.pickedUp.isTerminal, isTrue);
    });

    test('cancelled is terminal', () {
      expect(OrderStatus.cancelled.isTerminal, isTrue);
    });

    test('readyForPickup is NOT terminal (still active/in-progress)', () {
      expect(OrderStatus.readyForPickup.isTerminal, isFalse);
    });

    test('in-progress statuses are not terminal', () {
      expect(OrderStatus.pending.isTerminal, isFalse);
      expect(OrderStatus.confirmed.isTerminal, isFalse);
      expect(OrderStatus.preparing.isTerminal, isFalse);
      expect(OrderStatus.outForDelivery.isTerminal, isFalse);
    });
  });

  group('FulfillmentType.statusSequence', () {
    test('Delivery sequence is exactly pending/confirmed/preparing/'
        'outForDelivery/delivered', () {
      expect(FulfillmentType.delivery.statusSequence, [
        OrderStatus.pending,
        OrderStatus.confirmed,
        OrderStatus.preparing,
        OrderStatus.outForDelivery,
        OrderStatus.delivered,
      ]);
    });

    test('Pickup sequence is exactly pending/confirmed/preparing/'
        'readyForPickup/pickedUp', () {
      expect(FulfillmentType.pickup.statusSequence, [
        OrderStatus.pending,
        OrderStatus.confirmed,
        OrderStatus.preparing,
        OrderStatus.readyForPickup,
        OrderStatus.pickedUp,
      ]);
    });

    test('Delivery sequence never contains readyForPickup or pickedUp', () {
      expect(
        FulfillmentType.delivery.statusSequence,
        isNot(contains(OrderStatus.readyForPickup)),
      );
      expect(
        FulfillmentType.delivery.statusSequence,
        isNot(contains(OrderStatus.pickedUp)),
      );
    });

    test('Pickup sequence never contains outForDelivery or delivered', () {
      expect(
        FulfillmentType.pickup.statusSequence,
        isNot(contains(OrderStatus.outForDelivery)),
      );
      expect(
        FulfillmentType.pickup.statusSequence,
        isNot(contains(OrderStatus.delivered)),
      );
    });
  });

  group('OrderStatus.allowedNextStatuses (admin next-status actions)', () {
    test('Pickup preparing offers readyForPickup, not outForDelivery', () {
      final next = OrderStatus.preparing.allowedNextStatuses(
        FulfillmentType.pickup,
      );
      expect(next, contains(OrderStatus.readyForPickup));
      expect(next, isNot(contains(OrderStatus.outForDelivery)));
    });

    test('Pickup readyForPickup offers pickedUp, not delivered', () {
      final next = OrderStatus.readyForPickup.allowedNextStatuses(
        FulfillmentType.pickup,
      );
      expect(next, contains(OrderStatus.pickedUp));
      expect(next, isNot(contains(OrderStatus.delivered)));
    });

    test('Delivery preparing offers outForDelivery, not readyForPickup', () {
      final next = OrderStatus.preparing.allowedNextStatuses(
        FulfillmentType.delivery,
      );
      expect(next, contains(OrderStatus.outForDelivery));
      expect(next, isNot(contains(OrderStatus.readyForPickup)));
    });

    test('Delivery outForDelivery offers delivered, not pickedUp', () {
      final next = OrderStatus.outForDelivery.allowedNextStatuses(
        FulfillmentType.delivery,
      );
      expect(next, contains(OrderStatus.delivered));
      expect(next, isNot(contains(OrderStatus.pickedUp)));
    });

    test('terminal statuses never offer a next status', () {
      expect(
        OrderStatus.delivered.allowedNextStatuses(FulfillmentType.delivery),
        isEmpty,
      );
      expect(
        OrderStatus.pickedUp.allowedNextStatuses(FulfillmentType.pickup),
        isEmpty,
      );
      expect(
        OrderStatus.cancelled.allowedNextStatuses(FulfillmentType.delivery),
        isEmpty,
      );
    });

    test('pending and confirmed always allow cancellation for either type', () {
      expect(
        OrderStatus.pending.allowedNextStatuses(FulfillmentType.pickup),
        contains(OrderStatus.cancelled),
      );
      expect(
        OrderStatus.confirmed.allowedNextStatuses(FulfillmentType.delivery),
        contains(OrderStatus.cancelled),
      );
    });
  });

  group('Order.hasCrossMethodStatusMismatch (cross-method defense)', () {
    test('Pickup order with outForDelivery status is flagged as a mismatch', () {
      final order = buildOrder(
        fulfillmentType: FulfillmentType.pickup,
        status: OrderStatus.outForDelivery,
      );
      expect(order.hasCrossMethodStatusMismatch, isTrue);
    });

    test('Delivery order with pickedUp status is flagged as a mismatch', () {
      final order = buildOrder(
        fulfillmentType: FulfillmentType.delivery,
        status: OrderStatus.pickedUp,
      );
      expect(order.hasCrossMethodStatusMismatch, isTrue);
    });

    test('Pickup order with readyForPickup status is NOT a mismatch', () {
      final order = buildOrder(
        fulfillmentType: FulfillmentType.pickup,
        status: OrderStatus.readyForPickup,
      );
      expect(order.hasCrossMethodStatusMismatch, isFalse);
    });

    test('Delivery order with outForDelivery status is NOT a mismatch', () {
      final order = buildOrder(
        fulfillmentType: FulfillmentType.delivery,
        status: OrderStatus.outForDelivery,
      );
      expect(order.hasCrossMethodStatusMismatch, isFalse);
    });

    test('cancelled is never a mismatch, for either fulfillment type', () {
      expect(
        buildOrder(
          fulfillmentType: FulfillmentType.pickup,
          status: OrderStatus.cancelled,
        ).hasCrossMethodStatusMismatch,
        isFalse,
      );
      expect(
        buildOrder(
          fulfillmentType: FulfillmentType.delivery,
          status: OrderStatus.cancelled,
        ).hasCrossMethodStatusMismatch,
        isFalse,
      );
    });
  });
}
