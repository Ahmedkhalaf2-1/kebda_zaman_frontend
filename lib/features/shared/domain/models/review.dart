// ignore_for_file: invalid_annotation_target
// (freezed's standard pattern for a @JsonKey on a constructor parameter —
// the generator itself places the annotation on the underlying field, this
// warning is about the source-level factory parameter only.)
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

/// A customer's review of a single purchased order item
/// (RATINGS_REVIEWS_API_CONTRACT.md — `POST/PATCH /reviews/items`).
@freezed
abstract class ItemReview with _$ItemReview {
  const factory ItemReview({
    required String id,
    required String orderItemId,
    String? menuItemId,
    required int rating,
    String? comment,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ItemReview;

  factory ItemReview.fromJson(Map<String, dynamic> json) =>
      _$ItemReviewFromJson(json);
}

/// A customer's overall order-experience feedback (packaging/service/order
/// as a whole) — distinct from per-item food reviews
/// (`POST/PATCH /reviews/orders`).
@freezed
abstract class OrderFeedback with _$OrderFeedback {
  const factory OrderFeedback({
    required String id,
    required String orderId,
    required int rating,
    String? comment,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _OrderFeedback;

  factory OrderFeedback.fromJson(Map<String, dynamic> json) =>
      _$OrderFeedbackFromJson(json);
}

/// One reviewable purchased line from `GET /reviews/me/orders/:orderId`.
/// Deliberately independent of the live [MenuItem]/`Order` models — the
/// backend snapshots the item's identity (name/image) at order time so a
/// review still works even if the catalog item was later changed or
/// deleted. [menuItemId] may be null; [orderItemId] is always the stable
/// key (two rows for the same menu item are two distinct reviewable lines,
/// never deduplicated by menuItemId).
@freezed
abstract class OrderReviewItem with _$OrderReviewItem {
  const factory OrderReviewItem({
    required String orderItemId,
    String? menuItemId,
    required String nameAr,
    required String nameEn,
    String? imageUrl,
    required int quantity,
    ItemReview? review,
  }) = _OrderReviewItem;

  factory OrderReviewItem.fromJson(Map<String, dynamic> json) =>
      _$OrderReviewItemFromJson(json);
}

/// Response body of `GET /reviews/me/orders/:orderId` — the source of truth
/// for what can be reviewed on this order. [eligible] is backend-authoritative;
/// the frontend must never submit review requests when it is false, even if
/// the order looks locally completed.
@freezed
abstract class OrderReviewDetails with _$OrderReviewDetails {
  const factory OrderReviewDetails({
    required String orderId,
    required String orderStatus,
    required bool eligible,
    required List<OrderReviewItem> items,
    OrderFeedback? orderFeedback,
  }) = _OrderReviewDetails;

  factory OrderReviewDetails.fromJson(Map<String, dynamic> json) =>
      _$OrderReviewDetailsFromJson(json);
}

extension OrderReviewItemX on OrderReviewItem {
  String localizedName(String languageCode) {
    if (languageCode == 'ar') {
      return nameAr.trim().isNotEmpty ? nameAr : nameEn;
    }
    return nameEn.trim().isNotEmpty ? nameEn : nameAr;
  }
}

// ── Admin (GET /admin/reviews/items | /orders | /summary) ──────────────
// Verified against RATINGS_REVIEWS_API_CONTRACT.md (Ahmedkhalaf2-1/kebda-zaman,
// feat/vo3-menu). Plain-array list responses (no pagination envelope),
// `from`/`to` date filters, min-5-reviews threshold for top/lowest-rated
// enforced server-side — the frontend renders whatever the backend returns
// without re-filtering.
//
// GET /admin/reviews/items' exact per-row shape is fully confirmed (used
// verbatim below). GET /admin/reviews/orders was described only as "same
// [pagination] convention ... contains the review/feedback data with
// customer + order context" — no local backend checkout exists to read the
// mapper directly, so [AdminOrderFeedback] is modeled as the confirmed
// item-review shape minus the `item` sub-object (order-level feedback has
// no single purchased item to reference), the direct reading of "same
// shape". Flag for verification against the live contract/backend if this
// ever mismatches.

@freezed
abstract class AdminReviewCustomer with _$AdminReviewCustomer {
  const factory AdminReviewCustomer({
    required String id,
    required String fullName,
    String? email,
    String? phone,
  }) = _AdminReviewCustomer;

  factory AdminReviewCustomer.fromJson(Map<String, dynamic> json) =>
      _$AdminReviewCustomerFromJson(json);
}

@freezed
abstract class AdminReviewOrderRef with _$AdminReviewOrderRef {
  const factory AdminReviewOrderRef({
    required String id,
    required String orderNumber,
  }) = _AdminReviewOrderRef;

  factory AdminReviewOrderRef.fromJson(Map<String, dynamic> json) =>
      _$AdminReviewOrderRefFromJson(json);
}

@freezed
abstract class AdminReviewItemRef with _$AdminReviewItemRef {
  const factory AdminReviewItemRef({
    required String orderItemId,
    String? menuItemId,
    required String nameAr,
    required String nameEn,
    String? imageUrl,
  }) = _AdminReviewItemRef;

  factory AdminReviewItemRef.fromJson(Map<String, dynamic> json) =>
      _$AdminReviewItemRefFromJson(json);
}

extension AdminReviewItemRefX on AdminReviewItemRef {
  String localizedName(String languageCode) {
    if (languageCode == 'ar') {
      return nameAr.trim().isNotEmpty ? nameAr : nameEn;
    }
    return nameEn.trim().isNotEmpty ? nameEn : nameAr;
  }
}

@freezed
abstract class AdminItemReview with _$AdminItemReview {
  const factory AdminItemReview({
    required String id,
    required int rating,
    String? comment,
    required DateTime createdAt,
    required DateTime updatedAt,
    required AdminReviewCustomer customer,
    required AdminReviewOrderRef order,
    required AdminReviewItemRef item,
  }) = _AdminItemReview;

  factory AdminItemReview.fromJson(Map<String, dynamic> json) =>
      _$AdminItemReviewFromJson(json);
}

@freezed
abstract class AdminOrderFeedback with _$AdminOrderFeedback {
  const factory AdminOrderFeedback({
    required String id,
    required int rating,
    String? comment,
    required DateTime createdAt,
    required DateTime updatedAt,
    required AdminReviewCustomer customer,
    required AdminReviewOrderRef order,
  }) = _AdminOrderFeedback;

  factory AdminOrderFeedback.fromJson(Map<String, dynamic> json) =>
      _$AdminOrderFeedbackFromJson(json);
}

/// [nameAr]/[nameEn] are nullable per the confirmed backend mapper
/// (`review-response.mapper.ts`) — a top/lowest-rated item can reference a
/// menu item whose name snapshot is missing. UI callers must fall back to a
/// neutral localized label (via [AdminTopRatedItemX.localizedName] returning
/// `null`) rather than crash or show an empty string.
@freezed
abstract class AdminTopRatedItem with _$AdminTopRatedItem {
  const factory AdminTopRatedItem({
    required String menuItemId,
    String? nameAr,
    String? nameEn,
    String? imageUrl,
    required double averageRating,
    required int reviewCount,
  }) = _AdminTopRatedItem;

  factory AdminTopRatedItem.fromJson(Map<String, dynamic> json) =>
      _$AdminTopRatedItemFromJson(json);
}

extension AdminTopRatedItemX on AdminTopRatedItem {
  /// Returns `null` when neither name is present/non-blank — callers must
  /// supply their own localized fallback label (e.g. "Unknown item") rather
  /// than rendering blank text.
  String? localizedName(String languageCode) {
    final ar = nameAr?.trim();
    final en = nameEn?.trim();
    if (languageCode == 'ar') {
      if (ar != null && ar.isNotEmpty) return ar;
      if (en != null && en.isNotEmpty) return en;
      return null;
    }
    if (en != null && en.isNotEmpty) return en;
    if (ar != null && ar.isNotEmpty) return ar;
    return null;
  }
}

@freezed
abstract class AdminRatingAggregate with _$AdminRatingAggregate {
  const factory AdminRatingAggregate({
    required double averageRating,
    required int reviewCount,
  }) = _AdminRatingAggregate;

  factory AdminRatingAggregate.fromJson(Map<String, dynamic> json) =>
      _$AdminRatingAggregateFromJson(json);
}

/// Parses the backend's `ratingDistribution` object (string star-rating
/// keys `"1".."5"` -> counts) into an int-keyed map for natural UI use.
/// Missing/malformed entries are skipped/defaulted rather than throwing.
Map<int, int> adminRatingDistributionFromApi(dynamic value) {
  if (value is! Map) return const {};
  final result = <int, int>{};
  for (final entry in value.entries) {
    final star = int.tryParse(entry.key.toString());
    if (star == null) continue;
    final count = entry.value;
    result[star] = count is num ? count.toInt() : 0;
  }
  return result;
}

Map<String, int> _adminRatingDistributionToApi(Map<int, int> value) =>
    value.map((star, count) => MapEntry(star.toString(), count));

/// `GET /admin/reviews/summary`. Top/lowest-rated lists only include items
/// with at least 5 reviews per the confirmed backend contract.
@freezed
abstract class AdminReviewsSummary with _$AdminReviewsSummary {
  const factory AdminReviewsSummary({
    required AdminRatingAggregate itemReviews,
    required AdminRatingAggregate orderFeedback,
    @JsonKey(
      fromJson: adminRatingDistributionFromApi,
      toJson: _adminRatingDistributionToApi,
    )
    @Default({})
    Map<int, int> ratingDistribution,
    @Default([]) List<AdminTopRatedItem> topRatedItems,
    @Default([]) List<AdminTopRatedItem> lowestRatedItems,
  }) = _AdminReviewsSummary;

  factory AdminReviewsSummary.fromJson(Map<String, dynamic> json) =>
      _$AdminReviewsSummaryFromJson(json);
}
