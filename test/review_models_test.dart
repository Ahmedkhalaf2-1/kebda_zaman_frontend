import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/shared/domain/models/review.dart';

/// Parsing tests for the Ratings & Reviews domain models against the
/// confirmed RATINGS_REVIEWS_API_CONTRACT.md response shape for
/// `GET /reviews/me/orders/:orderId`.
void main() {
  Map<String, dynamic> itemReviewJson({String? comment}) => {
    'id': 'rev-1',
    'orderItemId': 'oi-1',
    'menuItemId': 'mi-1',
    'rating': 5,
    'comment': comment,
    'createdAt': '2026-01-01T00:00:00.000Z',
    'updatedAt': '2026-01-02T00:00:00.000Z',
  };

  group('ItemReview', () {
    test('parses full backend shape', () {
      final review = ItemReview.fromJson(itemReviewJson(comment: 'Great!'));
      expect(review.id, 'rev-1');
      expect(review.orderItemId, 'oi-1');
      expect(review.menuItemId, 'mi-1');
      expect(review.rating, 5);
      expect(review.comment, 'Great!');
    });

    test('null comment parses cleanly', () {
      final review = ItemReview.fromJson(itemReviewJson(comment: null));
      expect(review.comment, isNull);
    });
  });

  group('OrderFeedback', () {
    test('parses full backend shape', () {
      final feedback = OrderFeedback.fromJson({
        'id': 'fb-1',
        'orderId': 'o-1',
        'rating': 4,
        'comment': null,
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
      });
      expect(feedback.id, 'fb-1');
      expect(feedback.orderId, 'o-1');
      expect(feedback.rating, 4);
      expect(feedback.comment, isNull);
    });
  });

  group('OrderReviewItem', () {
    test('menuItemId null still parses (deleted/changed catalog item)', () {
      final item = OrderReviewItem.fromJson({
        'orderItemId': 'oi-2',
        'menuItemId': null,
        'nameAr': 'اسم',
        'nameEn': 'Name',
        'imageUrl': null,
        'quantity': 2,
        'review': null,
      });
      expect(item.menuItemId, isNull);
      expect(item.review, isNull);
      expect(item.quantity, 2);
    });

    test('embeds an existing review when present', () {
      final item = OrderReviewItem.fromJson({
        'orderItemId': 'oi-3',
        'menuItemId': 'mi-3',
        'nameAr': 'اسم',
        'nameEn': 'Name',
        'imageUrl': 'https://example.com/img.png',
        'quantity': 1,
        'review': itemReviewJson(comment: 'Nice'),
      });
      expect(item.review, isNotNull);
      expect(item.review!.rating, 5);
    });

    test('localizedName falls back to the other language when blank', () {
      final item = OrderReviewItem.fromJson({
        'orderItemId': 'oi-4',
        'menuItemId': null,
        'nameAr': '',
        'nameEn': 'Only English',
        'imageUrl': null,
        'quantity': 1,
        'review': null,
      });
      expect(item.localizedName('ar'), 'Only English');
      expect(item.localizedName('en'), 'Only English');
    });
  });

  group('OrderReviewDetails', () {
    test('parses full response with items and orderFeedback', () {
      final details = OrderReviewDetails.fromJson({
        'orderId': 'o-1',
        'orderStatus': 'delivered',
        'eligible': true,
        'items': [
          {
            'orderItemId': 'oi-1',
            'menuItemId': 'mi-1',
            'nameAr': 'اسم',
            'nameEn': 'Name',
            'imageUrl': null,
            'quantity': 2,
            'review': null,
          },
        ],
        'orderFeedback': {
          'id': 'fb-1',
          'orderId': 'o-1',
          'rating': 4,
          'comment': 'Good service',
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-01T00:00:00.000Z',
        },
      });
      expect(details.eligible, isTrue);
      expect(details.items, hasLength(1));
      expect(details.orderFeedback, isNotNull);
      expect(details.orderFeedback!.comment, 'Good service');
    });

    test('eligible false with null orderFeedback parses cleanly', () {
      final details = OrderReviewDetails.fromJson({
        'orderId': 'o-2',
        'orderStatus': 'pending',
        'eligible': false,
        'items': [],
        'orderFeedback': null,
      });
      expect(details.eligible, isFalse);
      expect(details.items, isEmpty);
      expect(details.orderFeedback, isNull);
    });

    test('two order items referencing the same menuItemId stay distinct', () {
      final details = OrderReviewDetails.fromJson({
        'orderId': 'o-3',
        'orderStatus': 'delivered',
        'eligible': true,
        'items': [
          {
            'orderItemId': 'oi-a',
            'menuItemId': 'mi-shared',
            'nameAr': 'اسم',
            'nameEn': 'Name',
            'imageUrl': null,
            'quantity': 1,
            'review': null,
          },
          {
            'orderItemId': 'oi-b',
            'menuItemId': 'mi-shared',
            'nameAr': 'اسم',
            'nameEn': 'Name',
            'imageUrl': null,
            'quantity': 1,
            'review': null,
          },
        ],
        'orderFeedback': null,
      });
      expect(details.items, hasLength(2));
      expect(details.items.map((e) => e.orderItemId).toSet(), {'oi-a', 'oi-b'});
    });
  });
}
