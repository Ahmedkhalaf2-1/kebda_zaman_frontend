import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/review.dart';
import 'package:kebda_zaman/features/shared/domain/models/review_comment_patch.dart';

/// Customer + admin Ratings & Reviews (RATINGS_REVIEWS_API_CONTRACT.md).
abstract class ReviewRepository {
  /// `GET /reviews/me/orders/:orderId` — source of truth for what's
  /// reviewable on this order, including any existing reviews/feedback.
  Future<Result<OrderReviewDetails>> getOrderReviews(String orderId);

  /// `POST /reviews/items`.
  Future<Result<ItemReview>> createItemReview({
    required String orderItemId,
    required int rating,
    String? comment,
  });

  /// `PATCH /reviews/items/:reviewId`. [rating] omitted (`null`) leaves the
  /// rating unchanged; [comment] defaults to
  /// [ReviewCommentPatch.absent] (unchanged) — pass
  /// [ReviewCommentPatch.clear] or `ReviewCommentPatch.value(text)`
  /// explicitly to change it.
  Future<Result<ItemReview>> updateItemReview(
    String reviewId, {
    int? rating,
    ReviewCommentPatch comment = ReviewCommentPatch.absent,
  });

  /// `POST /reviews/orders`.
  Future<Result<OrderFeedback>> createOrderFeedback({
    required String orderId,
    required int rating,
    String? comment,
  });

  /// `PATCH /reviews/orders/:feedbackId`. Same tri-state comment semantics
  /// as [updateItemReview].
  Future<Result<OrderFeedback>> updateOrderFeedback(
    String feedbackId, {
    int? rating,
    ReviewCommentPatch comment = ReviewCommentPatch.absent,
  });

  /// `GET /admin/reviews/items`.
  Future<Result<List<AdminItemReview>>> getAdminItemReviews({
    DateTime? from,
    DateTime? to,
  });

  /// `GET /admin/reviews/orders`.
  Future<Result<List<AdminOrderFeedback>>> getAdminOrderFeedback({
    DateTime? from,
    DateTime? to,
  });

  /// `GET /admin/reviews/summary`.
  Future<Result<AdminReviewsSummary>> getAdminReviewsSummary({
    DateTime? from,
    DateTime? to,
  });
}
