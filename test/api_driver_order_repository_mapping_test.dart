import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/driver/data/api_driver_order_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Focused mapping tests for [ApiDriverOrderRepository]'s private
/// `_mapDriverOrder`, exercised via the `@visibleForTesting` seam
/// `mapDriverOrderForTesting`. Fixtures mirror the exact
/// `DriverOrderResponseDto` shape from DRIVER_DELIVERY_API_CONTRACT.md,
/// including the array-pagination-free single-order shape, nullable
/// `customerPhone` (stripped on history), and the additive
/// `assignmentVersion` field the later tracking phase depends on.
void main() {
  Map<String, dynamic> baseDriverOrderJson({
    Object? customerPhone = '0500000000',
    Object? deliveryAddress = const {
      'title': 'Home',
      'street': 'Al Amir St',
      'latitude': 21.5433,
      'longitude': 39.1728,
    },
    String status = 'preparing',
    double amountToCollect = 55.0,
    int assignmentVersion = 3,
  }) {
    return {
      'id': 'order-1',
      'orderNumber': 'ORD-1',
      'status': status,
      'items': [
        {
          'id': 'item-1',
          'menuItemId': 'menu-1',
          'menuItem': {
            'nameAr': 'كبدة',
            'nameEn': 'Liver',
            'imageUrl': 'https://example.test/liver.png',
          },
          'selectedVariant': null,
          'selectedAddons': [],
          'quantity': 2,
          'specialInstructions': 'No onions',
          'unitPrice': 20.0,
          'totalPrice': 40.0,
        },
      ],
      'deliveryAddress': deliveryAddress,
      'deliveryMethod': 'DELIVERY',
      'customerName': 'Ahmed Customer',
      'customerPhone': customerPhone,
      'paymentMethod': 'cash',
      'paymentStatus': 'PENDING',
      'amountToCollect': amountToCollect,
      'totalAmount': 55.0,
      'createdAt': '2026-01-01T12:00:00.000Z',
      'assignmentVersion': assignmentVersion,
    };
  }

  test('maps every field from the DriverOrderResponseDto shape', () {
    final order = ApiDriverOrderRepository.mapDriverOrderForTesting(
      baseDriverOrderJson(),
    );

    expect(order.id, 'order-1');
    expect(order.orderNumber, 'ORD-1');
    expect(order.status, OrderStatus.preparing);
    expect(order.items, hasLength(1));
    expect(order.items.first.quantity, 2);
    expect(order.items.first.specialInstructions, 'No onions');
    expect(order.deliveryMethod, FulfillmentType.delivery);
    expect(order.customerName, 'Ahmed Customer');
    expect(order.customerPhone, '0500000000');
    expect(order.paymentMethod, 'cash');
    expect(order.paymentStatus, 'PENDING');
    expect(order.amountToCollect, 55.0);
    expect(order.totalAmount, 55.0);
    expect(order.assignmentVersion, 3);
    expect(order.deliveryAddress?.hasValidCoordinates, isTrue);
    expect(order.deliveryAddress?.lat, 21.5433);
    expect(order.deliveryAddress?.lng, 39.1728);
  });

  test(
    'outForDelivery status string maps to OrderStatus.outForDelivery (the one irregular casing)',
    () {
      final order = ApiDriverOrderRepository.mapDriverOrderForTesting(
        baseDriverOrderJson(status: 'outForDelivery'),
      );
      expect(order.status, OrderStatus.outForDelivery);
    },
  );

  test(
    'history view: a null customerPhone (stripped by the backend) never crashes and stays null',
    () {
      final order = ApiDriverOrderRepository.mapDriverOrderForTesting(
        baseDriverOrderJson(customerPhone: null),
      );
      expect(order.customerPhone, isNull);
    },
  );

  test('a null deliveryAddress never crashes and stays null', () {
    final order = ApiDriverOrderRepository.mapDriverOrderForTesting(
      baseDriverOrderJson(deliveryAddress: null),
    );
    expect(order.deliveryAddress, isNull);
  });

  test(
    'missing coordinates on an otherwise-present address are treated as unavailable, not (0,0)',
    () {
      final order = ApiDriverOrderRepository.mapDriverOrderForTesting(
        baseDriverOrderJson(
          deliveryAddress: const {'title': 'Home', 'street': 'Al Amir St'},
        ),
      );
      expect(order.deliveryAddress?.hasValidCoordinates, isFalse);
    },
  );

  test(
    'amountToCollect of 0 for an already-settled order is preserved as 0, never inferred from totalAmount',
    () {
      final order = ApiDriverOrderRepository.mapDriverOrderForTesting(
        baseDriverOrderJson(amountToCollect: 0.0),
      );
      expect(order.amountToCollect, 0.0);
      expect(order.totalAmount, 55.0);
    },
  );

  test(
    'assignmentVersion is preserved verbatim for the later tracking phase',
    () {
      final order = ApiDriverOrderRepository.mapDriverOrderForTesting(
        baseDriverOrderJson(assignmentVersion: 7),
      );
      expect(order.assignmentVersion, 7);
    },
  );
}
