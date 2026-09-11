import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/review.dart';
import 'package:kebda_zaman/features/shared/domain/models/review_comment_patch.dart';

/// Order-scoped review state, keyed by orderId. `autoDispose` (rather than
/// wiring into `session_coordinator.dart`'s fixed invalidate list) because
/// this provider is never watched outside the review screen for that one
/// order — it's naturally cleaned up when the screen is popped, and a fresh
/// instance always re-fetches from `GET /reviews/me/orders/:orderId` (the
/// backend-authoritative source) rather than ever caching across users.
class OrderReviewsNotifier
    extends AutoDisposeFamilyAsyncNotifier<OrderReviewDetails, String> {
  @override
  Future<OrderReviewDetails> build(String orderId) => _fetch(orderId);

  Future<OrderReviewDetails> _fetch(String orderId) async {
    final repo = ref.read(reviewRepositoryProvider);
    final result = await repo.getOrderReviews(orderId);
    return result.fold((f) => throw f, (data) => data);
  }

  /// Re-fetches order review state from the backend. Used after every
  /// successful mutation (never an optimistic local patch), and also after
  /// a 409 duplicate-submission error so the UI reconciles with whatever the
  /// server actually has instead of staying stuck showing a failed attempt.
  Future<void> refresh() async {
    try {
      final data = await _fetch(arg);
      state = AsyncData(data);
    } catch (f) {
      state = AsyncError(f, StackTrace.current);
    }
  }

  /// Returns `null` on success, or the [Failure] on error. Callers keep
  /// their own in-flight/duplicate-tap guard (matching this codebase's
  /// existing convention of a widget-local `bool` loading flag rather than
  /// notifier-level submission state).
  Future<Failure?> submitItemReview({
    required String orderItemId,
    required int rating,
    String? comment,
  }) async {
    final repo = ref.read(reviewRepositoryProvider);
    final result = await repo.createItemReview(
      orderItemId: orderItemId,
      rating: rating,
      comment: comment,
    );
    return result.fold(
      (f) {
        // A 409 means a review already exists server-side (e.g. a retried
        // request) — refresh so the UI shows the real, current review
        // instead of leaving the form stuck on a failed "create".
        if (f is ValidationFailure) refresh();
        return f;
      },
      (_) {
        refresh();
        return null;
      },
    );
  }

  Future<Failure?> editItemReview(
    String reviewId, {
    int? rating,
    ReviewCommentPatch comment = ReviewCommentPatch.absent,
  }) async {
    final repo = ref.read(reviewRepositoryProvider);
    final result = await repo.updateItemReview(
      reviewId,
      rating: rating,
      comment: comment,
    );
    return result.fold((f) => f, (_) {
      refresh();
      return null;
    });
  }

  Future<Failure?> submitOrderFeedback({
    required int rating,
    String? comment,
  }) async {
    final repo = ref.read(reviewRepositoryProvider);
    final result = await repo.createOrderFeedback(
      orderId: arg,
      rating: rating,
      comment: comment,
    );
    return result.fold(
      (f) {
        if (f is ValidationFailure) refresh();
        return f;
      },
      (_) {
        refresh();
        return null;
      },
    );
  }

  Future<Failure?> editOrderFeedback(
    String feedbackId, {
    int? rating,
    ReviewCommentPatch comment = ReviewCommentPatch.absent,
  }) async {
    final repo = ref.read(reviewRepositoryProvider);
    final result = await repo.updateOrderFeedback(
      feedbackId,
      rating: rating,
      comment: comment,
    );
    return result.fold((f) => f, (_) {
      refresh();
      return null;
    });
  }
}

final orderReviewsProvider =
    AutoDisposeAsyncNotifierProvider.family<
      OrderReviewsNotifier,
      OrderReviewDetails,
      String
    >(OrderReviewsNotifier.new);
