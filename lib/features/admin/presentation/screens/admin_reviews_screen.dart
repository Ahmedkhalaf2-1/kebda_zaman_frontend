import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_star_rating.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_reviews_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/review.dart';

/// `/admin/reviews` — data-layer foundation + a basic functional view.
/// Deliberately simple (no charts/animations): item/order rating
/// aggregates, top/lowest-rated items, recent item reviews. Visual polish
/// is a later pass.
class AdminReviewsScreen extends ConsumerWidget {
  const AdminReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSummary = ref.watch(adminReviewsSummaryProvider);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      body: SafeArea(
        child: asyncSummary.when(
          data: (summary) => _AdminReviewsContent(summary: summary),
          loading: () =>
              const Center(child: CircularProgressIndicator(color: KZ.primary)),
          error: (error, _) => KZErrorState(
            message: error is Failure
                ? error.message
                : 'reviews.load_error'.tr(),
            onRetry: () => ref.invalidate(adminReviewsSummaryProvider),
            retryLabel: 'common.retry'.tr(),
          ),
        ),
      ),
    );
  }
}

class _AdminReviewsContent extends ConsumerWidget {
  final AdminReviewsSummary summary;

  const _AdminReviewsContent({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncRecent = ref.watch(adminItemReviewsProvider);

    return ListView(
      padding: const EdgeInsets.all(KZ.screenPadding),
      children: [
        Text('admin_reviews.title'.tr(), style: KZ.pageTitle),
        const SizedBox(height: KZ.sp16),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'admin_reviews.item_reviews_average'.tr(),
                value: summary.itemReviews.averageRating.toStringAsFixed(1),
                subValue: 'admin_reviews.review_count'.tr(
                  namedArgs: {'count': '${summary.itemReviews.reviewCount}'},
                ),
                icon: Icons.rate_review_rounded,
              ),
            ),
            const SizedBox(width: KZ.sp12),
            Expanded(
              child: _MetricCard(
                label: 'admin_reviews.order_feedback_average'.tr(),
                value: summary.orderFeedback.averageRating.toStringAsFixed(1),
                subValue: 'admin_reviews.review_count'.tr(
                  namedArgs: {'count': '${summary.orderFeedback.reviewCount}'},
                ),
                icon: Icons.reviews_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: KZ.sp24),
        Text('admin_reviews.rating_distribution'.tr(), style: KZ.sectionTitle),
        const SizedBox(height: KZ.sp12),
        _RatingDistributionBars(distribution: summary.ratingDistribution),
        const SizedBox(height: KZ.sp24),
        Text('admin_reviews.top_rated'.tr(), style: KZ.sectionTitle),
        const SizedBox(height: KZ.sp12),
        if (summary.topRatedItems.isEmpty)
          _EmptyRow(text: 'admin_reviews.no_data'.tr())
        else
          for (final item in summary.topRatedItems) _TopRatedRow(item: item),
        const SizedBox(height: KZ.sp24),
        Text('admin_reviews.lowest_rated'.tr(), style: KZ.sectionTitle),
        const SizedBox(height: KZ.sp12),
        if (summary.lowestRatedItems.isEmpty)
          _EmptyRow(text: 'admin_reviews.no_data'.tr())
        else
          for (final item in summary.lowestRatedItems) _TopRatedRow(item: item),
        const SizedBox(height: KZ.sp24),
        Text('admin_reviews.recent_reviews'.tr(), style: KZ.sectionTitle),
        const SizedBox(height: KZ.sp12),
        asyncRecent.when(
          data: (reviews) {
            final recent = [...reviews]
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final top = recent.take(10).toList();
            if (top.isEmpty) {
              return _EmptyRow(text: 'admin_reviews.no_data'.tr());
            }
            return Column(
              children: [
                for (final review in top) _RecentReviewRow(review: review),
              ],
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: KZ.sp16),
            child: Center(child: CircularProgressIndicator(color: KZ.primary)),
          ),
          error: (_, __) => _EmptyRow(text: 'admin_reviews.no_data'.tr()),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.subValue,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return KZCard(
      padding: const EdgeInsets.all(KZ.sp16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: KZ.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: KZ.label.copyWith(color: KZ.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: KZ.sp12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(value, style: KZ.display.copyWith(fontSize: 32)),
              const SizedBox(width: 6),
              const Icon(
                Icons.star_rounded,
                size: 24,
                color: Color(0xFFF6A609),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subValue, style: KZ.caption),
        ],
      ),
    );
  }
}

class _RatingDistributionBars extends StatelessWidget {
  final Map<int, int> distribution;

  const _RatingDistributionBars({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final maxCount = distribution.values.isEmpty
        ? 0
        : distribution.values.reduce((a, b) => a > b ? a : b);

    return KZCard(
      child: Column(
        children: [
          for (int star = 5; star >= 1; star--) ...[
            _DistributionRow(
              star: star,
              count: distribution[star] ?? 0,
              maxCount: maxCount,
            ),
            if (star > 1) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  final int star;
  final int count;
  final int maxCount;

  const _DistributionRow({
    required this.star,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = maxCount <= 0 ? 0.0 : count / maxCount;
    return Row(
      children: [
        Text('$star', style: KZ.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF6A609)),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(KZ.radiusSm),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 10,
              backgroundColor: KZ.surfaceContainer, // or highest
              color: KZ.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 32,
          child: Text(
            '$count',
            style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _TopRatedRow extends StatelessWidget {
  final AdminTopRatedItem item;

  const _TopRatedRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    // Item names are nullable in the backend mapper (a top/lowest-rated
    // row can reference a menu item whose name snapshot is missing) — fall
    // back to a neutral localized label rather than showing blank text.
    final name = item.localizedName(lang) ?? 'admin_reviews.unknown_item'.tr();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: KZCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              height: 36,
              child: KZFoodImage(
                imageUrl: item.imageUrl ?? '',
                aspectRatio: 1,
                borderRadius: BorderRadius.circular(KZ.radiusSm),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: KZ.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFF6A609),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.averageRating.toStringAsFixed(1),
                      style: KZ.body.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Text(
                  '(${item.reviewCount})',
                  style: KZ.caption.copyWith(color: KZ.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentReviewRow extends StatelessWidget {
  final AdminItemReview review;

  const _RecentReviewRow({required this.review});

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final name = review.item.localizedName(lang);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: KZCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: KZ.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                KZStarRating(rating: review.rating, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'admin_reviews.order_ref'.tr(
                    namedArgs: {
                      'orderNumber': review.order.orderNumber,
                      'customerName': review.customer.fullName,
                    },
                  ),
                  style: KZ.caption.copyWith(color: KZ.onSurfaceVariant),
                ),
                Text(
                  DateFormat.yMMMd(
                    context.locale.languageCode,
                  ).add_jm().format(review.createdAt),
                  style: KZ.caption.copyWith(color: KZ.onSurfaceVariant),
                ),
              ],
            ),
            if (review.comment != null &&
                review.comment!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KZ.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(KZ.radiusSm),
                  border: Border.all(color: KZ.outline.withOpacity(0.3)),
                ),
                child: Text(
                  review.comment!,
                  style: KZ.bodySmall.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String text;

  const _EmptyRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: KZ.caption.copyWith(color: KZ.onSurfaceVariant));
  }
}
