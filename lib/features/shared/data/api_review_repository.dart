import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/review.dart';
import 'package:kebda_zaman/features/shared/domain/models/review_comment_patch.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/review_repository.dart';

class ApiReviewRepository implements ReviewRepository {
  final ApiClient _apiClient;

  ApiReviewRepository(this._apiClient);

  @visibleForTesting
  static Map<String, dynamic> buildItemReviewCreatePayloadForTesting({
    required String orderItemId,
    required int rating,
    String? comment,
  }) => _buildItemReviewCreatePayload(
    orderItemId: orderItemId,
    rating: rating,
    comment: comment,
  );

  @visibleForTesting
  static Map<String, dynamic> buildOrderFeedbackCreatePayloadForTesting({
    required String orderId,
    required int rating,
    String? comment,
  }) => _buildOrderFeedbackCreatePayload(
    orderId: orderId,
    rating: rating,
    comment: comment,
  );

  @visibleForTesting
  static Map<String, dynamic> buildPatchPayloadForTesting({
    int? rating,
    ReviewCommentPatch comment = ReviewCommentPatch.absent,
  }) => _buildPatchPayload(rating: rating, comment: comment);

  static Map<String, dynamic> _buildItemReviewCreatePayload({
    required String orderItemId,
    required int rating,
    String? comment,
  }) {
    final trimmed = comment?.trim();
    return {
      'orderItemId': orderItemId,
      'rating': rating,
      if (trimmed != null && trimmed.isNotEmpty) 'comment': trimmed,
    };
  }

  static Map<String, dynamic> _buildOrderFeedbackCreatePayload({
    required String orderId,
    required int rating,
    String? comment,
  }) {
    final trimmed = comment?.trim();
    return {
      'orderId': orderId,
      'rating': rating,
      if (trimmed != null && trimmed.isNotEmpty) 'comment': trimmed,
    };
  }

  /// Builds a PATCH body honoring tri-state comment semantics — `rating` is
  /// only included when explicitly provided, and `comment` is only included
  /// when [comment] is not [ReviewCommentPatch.absent] (see
  /// [ReviewCommentPatch] doc comment for the full omit/clear/set rules).
  static Map<String, dynamic> _buildPatchPayload({
    int? rating,
    ReviewCommentPatch comment = ReviewCommentPatch.absent,
  }) {
    final body = <String, dynamic>{};
    if (rating != null) body['rating'] = rating;
    comment.applyTo(body);
    return body;
  }

  /// Formats a UTC date as the date-only `"YYYY-MM-DD"` string the backend
  /// expects for `from`/`to` query params — same format as
  /// `reports_filter.dart`'s `formatUtcDateOnly`, kept as a local copy here
  /// rather than importing across the shared/admin feature boundary.
  static String _formatUtcDateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Map<String, dynamic> _rangeParams(DateTime? from, DateTime? to) {
    return {
      if (from != null) 'from': _formatUtcDateOnly(from),
      if (to != null) 'to': _formatUtcDateOnly(to),
    };
  }

  Failure _handleError(dynamic e, String defaultMsg) {
    if (e is DioException) {
      if (e.error is ApiException) {
        final apiEx = e.error as ApiException;
        if (e.response?.statusCode == 404) {
          return NotFoundFailure(apiEx.message, apiEx);
        }
        if (e.response?.statusCode == 409) {
          return ValidationFailure(apiEx.message, apiEx);
        }
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          return AuthFailure(apiEx.message, apiEx);
        }
        return NetworkFailure(apiEx.message, apiEx);
      }
      return NetworkFailure(e.message ?? defaultMsg);
    }
    return UnknownFailure(e.toString());
  }

  @override
  Future<Result<OrderReviewDetails>> getOrderReviews(String orderId) async {
    try {
      final response = await _apiClient.dio.get('/reviews/me/orders/$orderId');
      return Success(
        OrderReviewDetails.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to load order reviews'));
    }
  }

  @override
  Future<Result<ItemReview>> createItemReview({
    required String orderItemId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/reviews/items',
        data: _buildItemReviewCreatePayload(
          orderItemId: orderItemId,
          rating: rating,
          comment: comment,
        ),
      );
      return Success(
        ItemReview.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to submit review'));
    }
  }

  @override
  Future<Result<ItemReview>> updateItemReview(
    String reviewId, {
    int? rating,
    ReviewCommentPatch comment = ReviewCommentPatch.absent,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '/reviews/items/$reviewId',
        data: _buildPatchPayload(rating: rating, comment: comment),
      );
      return Success(
        ItemReview.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to update review'));
    }
  }

  @override
  Future<Result<OrderFeedback>> createOrderFeedback({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/reviews/orders',
        data: _buildOrderFeedbackCreatePayload(
          orderId: orderId,
          rating: rating,
          comment: comment,
        ),
      );
      return Success(
        OrderFeedback.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to submit feedback'));
    }
  }

  @override
  Future<Result<OrderFeedback>> updateOrderFeedback(
    String feedbackId, {
    int? rating,
    ReviewCommentPatch comment = ReviewCommentPatch.absent,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '/reviews/orders/$feedbackId',
        data: _buildPatchPayload(rating: rating, comment: comment),
      );
      return Success(
        OrderFeedback.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to update feedback'));
    }
  }

  @override
  Future<Result<List<AdminItemReview>>> getAdminItemReviews({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/admin/reviews/items',
        queryParameters: _rangeParams(from, to),
      );
      final data = response.data as List;
      return Success(
        data
            .map((e) => AdminItemReview.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to load item reviews'));
    }
  }

  @override
  Future<Result<List<AdminOrderFeedback>>> getAdminOrderFeedback({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/admin/reviews/orders',
        queryParameters: _rangeParams(from, to),
      );
      final data = response.data as List;
      return Success(
        data
            .map((e) => AdminOrderFeedback.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to load order feedback'));
    }
  }

  @override
  Future<Result<AdminReviewsSummary>> getAdminReviewsSummary({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/admin/reviews/summary',
        queryParameters: _rangeParams(from, to),
      );
      return Success(
        AdminReviewsSummary.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to load reviews summary'));
    }
  }
}
