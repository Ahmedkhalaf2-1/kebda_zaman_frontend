import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/shared/domain/models/review.dart';

/// Parsing tests for the admin Ratings & Reviews models against the
/// confirmed RATINGS_REVIEWS_API_CONTRACT.md shapes for
/// `GET /admin/reviews/items` and `GET /admin/reviews/summary`.
void main() {
  group('AdminItemReview (GET /admin/reviews/items)', () {
    Map<String, dynamic> itemReviewJson({String? comment}) => {
      'id': 'rev-1',
      'rating': 2,
      'comment': comment,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-02T00:00:00.000Z',
      'customer': {
        'id': 'cust-1',
        'fullName': 'Jane Doe',
        'email': 'jane@example.com',
        'phone': null,
      },
      'order': {'id': 'order-1', 'orderNumber': 'KZ-1001'},
      'item': {
        'orderItemId': 'oi-1',
        'menuItemId': 'mi-1',
        'nameAr': 'اسم',
        'nameEn': 'Name',
        'imageUrl': null,
      },
    };

    test('parses the full confirmed contract shape', () {
      final review = AdminItemReview.fromJson(itemReviewJson(comment: 'Meh'));
      expect(review.id, 'rev-1');
      expect(review.rating, 2);
      expect(review.comment, 'Meh');
      expect(review.customer.id, 'cust-1');
      expect(review.customer.fullName, 'Jane Doe');
      expect(review.customer.email, 'jane@example.com');
      expect(review.customer.phone, isNull);
      expect(review.order.id, 'order-1');
      expect(review.order.orderNumber, 'KZ-1001');
      expect(review.item.orderItemId, 'oi-1');
      expect(review.item.menuItemId, 'mi-1');
      expect(review.item.nameAr, 'اسم');
      expect(review.item.nameEn, 'Name');
      expect(review.item.imageUrl, isNull);
    });

    test('null comment parses cleanly', () {
      final review = AdminItemReview.fromJson(itemReviewJson(comment: null));
      expect(review.comment, isNull);
    });

    test('null menuItemId on the item ref still parses', () {
      final json = itemReviewJson();
      (json['item'] as Map<String, dynamic>)['menuItemId'] = null;
      final review = AdminItemReview.fromJson(json);
      expect(review.item.menuItemId, isNull);
    });
  });

  group('AdminReviewsSummary (GET /admin/reviews/summary)', () {
    Map<String, dynamic> summaryJson() => {
      'itemReviews': {'averageRating': 4.4, 'reviewCount': 420},
      'orderFeedback': {'averageRating': 4.2, 'reviewCount': 290},
      'ratingDistribution': {'1': 2, '2': 3, '3': 10, '4': 20, '5': 92},
      'topRatedItems': [
        {
          'menuItemId': 'mi-top',
          'nameAr': 'اسم',
          'nameEn': 'Top Item',
          'imageUrl': null,
          'averageRating': 4.9,
          'reviewCount': 40,
        },
      ],
      'lowestRatedItems': <Map<String, dynamic>>[],
    };

    test('parses the full confirmed contract shape', () {
      final summary = AdminReviewsSummary.fromJson(summaryJson());
      expect(summary.itemReviews.averageRating, 4.4);
      expect(summary.itemReviews.reviewCount, 420);
      expect(summary.orderFeedback.averageRating, 4.2);
      expect(summary.orderFeedback.reviewCount, 290);
      expect(summary.topRatedItems, hasLength(1));
      expect(summary.topRatedItems.single.nameEn, 'Top Item');
      expect(summary.lowestRatedItems, isEmpty);
    });

    test('string-keyed ratingDistribution parses to an int-keyed map', () {
      final summary = AdminReviewsSummary.fromJson(summaryJson());
      expect(summary.ratingDistribution, {1: 2, 2: 3, 3: 10, 4: 20, 5: 92});
    });

    test('missing ratingDistribution defaults to empty map', () {
      final json = summaryJson();
      json.remove('ratingDistribution');
      final summary = AdminReviewsSummary.fromJson(json);
      expect(summary.ratingDistribution, isEmpty);
    });

    test('missing top/lowest rated lists default to empty', () {
      final json = summaryJson();
      json.remove('topRatedItems');
      json.remove('lowestRatedItems');
      final summary = AdminReviewsSummary.fromJson(json);
      expect(summary.topRatedItems, isEmpty);
      expect(summary.lowestRatedItems, isEmpty);
    });
  });

  group('AdminTopRatedItem localizedName', () {
    test('falls back to the other language when blank', () {
      final item = AdminTopRatedItem.fromJson({
        'menuItemId': 'mi-1',
        'nameAr': '',
        'nameEn': 'Only English',
        'imageUrl': null,
        'averageRating': 4.5,
        'reviewCount': 10,
      });
      expect(item.localizedName('ar'), 'Only English');
      expect(item.localizedName('en'), 'Only English');
    });

    test('both names null parses cleanly and localizedName returns null', () {
      final item = AdminTopRatedItem.fromJson({
        'menuItemId': 'mi-2',
        'nameAr': null,
        'nameEn': null,
        'imageUrl': null,
        'averageRating': 3.0,
        'reviewCount': 6,
      });
      expect(item.nameAr, isNull);
      expect(item.nameEn, isNull);
      expect(item.localizedName('ar'), isNull);
      expect(item.localizedName('en'), isNull);
    });

    test('missing name keys default to null (not a parse error)', () {
      final item = AdminTopRatedItem.fromJson({
        'menuItemId': 'mi-3',
        'averageRating': 3.5,
        'reviewCount': 7,
      });
      expect(item.nameAr, isNull);
      expect(item.nameEn, isNull);
    });
  });

  group('AdminOrderFeedback (GET /admin/reviews/orders)', () {
    test('parses the confirmed item-review-minus-item shape', () {
      final feedback = AdminOrderFeedback.fromJson({
        'id': 'fb-1',
        'rating': 5,
        'comment': 'Great service',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-01T00:00:00.000Z',
        'customer': {
          'id': 'cust-1',
          'fullName': 'Jane Doe',
          'email': null,
          'phone': '0100000000',
        },
        'order': {'id': 'order-1', 'orderNumber': 'KZ-1001'},
      });
      expect(feedback.id, 'fb-1');
      expect(feedback.rating, 5);
      expect(feedback.customer.fullName, 'Jane Doe');
      expect(feedback.customer.phone, '0100000000');
      expect(feedback.order.orderNumber, 'KZ-1001');
    });
  });
}
