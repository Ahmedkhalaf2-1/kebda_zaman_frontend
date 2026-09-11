import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/review.dart';

/// `GET /admin/reviews/summary` — the data foundation for the basic
/// "Reviews & Ratings" admin screen. No date-range filtering UI yet (Phase
/// 11 asks for a foundation, not a full dashboard) — always fetches
/// all-time; `from`/`to` are already wired through the repository for when
/// that filter bar is added.
final adminReviewsSummaryProvider =
    FutureProvider.autoDispose<AdminReviewsSummary>((ref) async {
      final repo = ref.watch(reviewRepositoryProvider);
      final result = await repo.getAdminReviewsSummary();
      return result.fold((f) => throw f, (data) => data);
    });

final adminItemReviewsProvider =
    FutureProvider.autoDispose<List<AdminItemReview>>((ref) async {
      final repo = ref.watch(reviewRepositoryProvider);
      final result = await repo.getAdminItemReviews();
      return result.fold((f) => throw f, (data) => data);
    });

final adminOrderFeedbackProvider =
    FutureProvider.autoDispose<List<AdminOrderFeedback>>((ref) async {
      final repo = ref.watch(reviewRepositoryProvider);
      final result = await repo.getAdminOrderFeedback();
      return result.fold((f) => throw f, (data) => data);
    });
