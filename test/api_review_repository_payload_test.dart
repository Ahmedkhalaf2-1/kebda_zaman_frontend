import 'package:flutter_test/flutter_test.dart';
import 'package:kebda_zaman/features/shared/data/api_review_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/review_comment_patch.dart';

/// Wire-shape tests for review request bodies, exercised via the
/// `@visibleForTesting` seams on [ApiReviewRepository] — mirrors the style
/// of api_menu_repository_payload_test.dart. The critical contract here is
/// tri-state PATCH semantics (RATINGS_REVIEWS_API_CONTRACT.md): omitted vs.
/// explicit-null vs. set must never collapse into the same wire shape.
void main() {
  group('create payloads', () {
    test('item review create omits comment key when not given', () {
      final payload =
          ApiReviewRepository.buildItemReviewCreatePayloadForTesting(
            orderItemId: 'oi-1',
            rating: 5,
          );
      expect(payload['orderItemId'], 'oi-1');
      expect(payload['rating'], 5);
      expect(payload.containsKey('comment'), isFalse);
    });

    test('item review create trims and includes non-empty comment', () {
      final payload =
          ApiReviewRepository.buildItemReviewCreatePayloadForTesting(
            orderItemId: 'oi-1',
            rating: 4,
            comment: '  Great food!  ',
          );
      expect(payload['comment'], 'Great food!');
    });

    test('item review create omits whitespace-only comment', () {
      final payload =
          ApiReviewRepository.buildItemReviewCreatePayloadForTesting(
            orderItemId: 'oi-1',
            rating: 4,
            comment: '   ',
          );
      expect(payload.containsKey('comment'), isFalse);
    });

    test('order feedback create body shape', () {
      final payload =
          ApiReviewRepository.buildOrderFeedbackCreatePayloadForTesting(
            orderId: 'o-1',
            rating: 3,
            comment: 'Packaging was fine',
          );
      expect(payload['orderId'], 'o-1');
      expect(payload['rating'], 3);
      expect(payload['comment'], 'Packaging was fine');
    });
  });

  group('PATCH tri-state semantics', () {
    test('rating-only PATCH does not send comment key at all', () {
      final payload = ApiReviewRepository.buildPatchPayloadForTesting(
        rating: 4,
      );
      expect(payload['rating'], 4);
      expect(payload.containsKey('comment'), isFalse);
    });

    test('comment-only PATCH does not send rating key at all', () {
      final payload = ApiReviewRepository.buildPatchPayloadForTesting(
        comment: ReviewCommentPatch.value('Updated comment'),
      );
      expect(payload.containsKey('rating'), isFalse);
      expect(payload['comment'], 'Updated comment');
    });

    test('explicit clear sends comment: null', () {
      final payload = ApiReviewRepository.buildPatchPayloadForTesting(
        comment: ReviewCommentPatch.clear,
      );
      expect(payload.containsKey('comment'), isTrue);
      expect(payload['comment'], isNull);
    });

    test('whitespace-only comment value also clears (sends null)', () {
      final payload = ApiReviewRepository.buildPatchPayloadForTesting(
        comment: ReviewCommentPatch.value('   '),
      );
      expect(payload.containsKey('comment'), isTrue);
      expect(payload['comment'], isNull);
    });

    test('empty-string comment value also clears (sends null)', () {
      final payload = ApiReviewRepository.buildPatchPayloadForTesting(
        comment: ReviewCommentPatch.value(''),
      );
      expect(payload.containsKey('comment'), isTrue);
      expect(payload['comment'], isNull);
    });

    test('non-empty comment value is trimmed and saved', () {
      final payload = ApiReviewRepository.buildPatchPayloadForTesting(
        comment: ReviewCommentPatch.value('  spaced  '),
      );
      expect(payload['comment'], 'spaced');
    });

    test('rating + explicit clear together sends both keys correctly', () {
      final payload = ApiReviewRepository.buildPatchPayloadForTesting(
        rating: 2,
        comment: ReviewCommentPatch.clear,
      );
      expect(payload['rating'], 2);
      expect(payload['comment'], isNull);
      expect(payload.length, 2);
    });

    test('neither rating nor comment given sends an empty body', () {
      final payload = ApiReviewRepository.buildPatchPayloadForTesting();
      expect(payload, isEmpty);
    });
  });
}
