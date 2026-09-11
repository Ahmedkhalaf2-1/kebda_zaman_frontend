import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// [OrderStatusX.isReviewable] gates whether the frontend offers review UI
/// at all — per spec, only delivered/pickedUp orders qualify; every other
/// status (including cancelled, which is terminal but not reviewable) must
/// not.
void main() {
  test('delivered is reviewable', () {
    expect(OrderStatus.delivered.isReviewable, isTrue);
  });

  test('pickedUp is reviewable', () {
    expect(OrderStatus.pickedUp.isReviewable, isTrue);
  });

  test('every other status is not reviewable', () {
    final nonReviewable = OrderStatus.values.where(
      (s) => s != OrderStatus.delivered && s != OrderStatus.pickedUp,
    );
    for (final status in nonReviewable) {
      expect(
        status.isReviewable,
        isFalse,
        reason: '$status should not be reviewable',
      );
    }
  });

  test('cancelled is terminal but not reviewable', () {
    expect(OrderStatus.cancelled.isTerminal, isTrue);
    expect(OrderStatus.cancelled.isReviewable, isFalse);
  });
}
