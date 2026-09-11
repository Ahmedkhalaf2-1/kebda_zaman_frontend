import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/admin/domain/models/kitchen_order.dart';

void main() {
  Map<String, dynamic> baseJson({
    int? preparationTimeMinutes,
    String? estimatedDeliveryTime,
  }) {
    return {
      'id': 'order-1',
      'orderNumber': 'ORD-1',
      'status': 'preparing',
      // KitchenOrder.fromJson's generated enum decoder matches on the Dart
      // enum name (lowercase) — unlike ApiKitchenRepository's manual
      // mapper, which handles the backend's real uppercase wire format.
      'deliveryMethod': 'pickup',
      'createdAt': '2026-01-01T12:00:00.000Z',
      'items': [],
      'preparationTimeMinutes': preparationTimeMinutes,
      'estimatedDeliveryTime': estimatedDeliveryTime,
    };
  }

  group('KitchenOrder.fromJson preparation-time fields', () {
    test('both fields absent/null parse as null', () {
      final order = KitchenOrder.fromJson(baseJson());

      expect(order.preparationTimeMinutes, isNull);
      expect(order.estimatedDeliveryTime, isNull);
    });

    test('populated fields parse correctly', () {
      final order = KitchenOrder.fromJson(
        baseJson(
          preparationTimeMinutes: 20,
          estimatedDeliveryTime: '2026-01-01T12:20:00.000Z',
        ),
      );

      expect(order.preparationTimeMinutes, 20);
      expect(order.estimatedDeliveryTime, '2026-01-01T12:20:00.000Z');
    });
  });
}
