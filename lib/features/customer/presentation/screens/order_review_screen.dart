import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_star_rating.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/order_reviews_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/review.dart';
import 'package:kebda_zaman/features/shared/domain/models/review_comment_patch.dart';

/// `/orders/review/:id` — functional review screen. Sources every purchased
/// item's identity (name/image/quantity) from the review endpoint's own
/// snapshot data, never from the live `MenuItem`/`Order` models, since an
/// item may have been changed or deleted since purchase.
class OrderReviewScreen extends ConsumerWidget {
  final String orderId;

  const OrderReviewScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isGuest = !authState.isLoggedIn || (authState.user?.isGuest ?? true);

    if (isGuest) {
      return Scaffold(
        appBar: AppBar(title: Text('reviews.title'.tr())),
        body: KZErrorState(
          message: 'reviews.guest_blocked'.tr(),
          onRetry: () => context.go('/home'),
          retryLabel: 'common.retry'.tr(),
        ),
      );
    }

    final asyncData = ref.watch(orderReviewsProvider(orderId));

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        title: Text('reviews.title'.tr()),
      ),
      body: SafeArea(
        child: asyncData.when(
          data: (data) => _OrderReviewBody(orderId: orderId, data: data),
          loading: () =>
              const Center(child: CircularProgressIndicator(color: KZ.primary)),
          error: (error, _) => KZErrorState(
            message: error is Failure
                ? error.message
                : 'reviews.load_error'.tr(),
            onRetry: () => ref.invalidate(orderReviewsProvider(orderId)),
            retryLabel: 'common.retry'.tr(),
          ),
        ),
      ),
    );
  }
}

class _OrderReviewBody extends StatelessWidget {
  final String orderId;
  final OrderReviewDetails data;

  const _OrderReviewBody({required this.orderId, required this.data});

  @override
  Widget build(BuildContext context) {
    if (!data.eligible) {
      return KZEmptyState(
        icon: Icons.star_outline_rounded,
        title: 'reviews.not_eligible'.tr(),
        message: 'reviews.not_eligible_sub'.tr(),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KZ.screenPadding,
        KZ.sp16,
        KZ.screenPadding,
        KZ.sp32,
      ),
      children: [
        Text('reviews.rate_items_heading'.tr(), style: KZ.sectionTitle),
        const SizedBox(height: KZ.sp12),
        for (final item in data.items) ...[
          _ItemReviewCard(orderId: orderId, item: item),
          const SizedBox(height: KZ.sp12),
        ],
        const SizedBox(height: KZ.sp16),
        Text('reviews.overall_experience'.tr(), style: KZ.sectionTitle),
        const SizedBox(height: 4),
        Text(
          'reviews.overall_experience_sub'.tr(),
          style: KZ.caption.copyWith(color: KZ.onSurfaceVariant),
        ),
        const SizedBox(height: KZ.sp12),
        _OrderFeedbackCard(orderId: orderId, existing: data.orderFeedback),
      ],
    );
  }
}

class _ItemReviewCard extends ConsumerStatefulWidget {
  final String orderId;
  final OrderReviewItem item;

  const _ItemReviewCard({required this.orderId, required this.item});

  @override
  ConsumerState<_ItemReviewCard> createState() => _ItemReviewCardState();
}

class _ItemReviewCardState extends ConsumerState<_ItemReviewCard> {
  late int _rating;
  late final TextEditingController _commentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.item.review?.rating ?? 0;
    _commentController = TextEditingController(
      text: widget.item.review?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _hasExistingReview => widget.item.review != null;

  Future<void> _submit() async {
    if (_rating < 1 || _rating > 5 || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final notifier = ref.read(orderReviewsProvider(widget.orderId).notifier);
    final comment = _commentController.text;
    final Failure? failure;
    if (_hasExistingReview) {
      failure = await notifier.editItemReview(
        widget.item.review!.id,
        rating: _rating,
        comment: ReviewCommentPatch.value(comment),
      );
    } else {
      failure = await notifier.submitItemReview(
        orderItemId: widget.item.orderItemId,
        rating: _rating,
        comment: comment,
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure.message.isNotEmpty
                ? failure.message
                : 'reviews.submit_error'.tr(),
          ),
          backgroundColor: KZ.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('reviews.thank_you'.tr()),
        backgroundColor: KZ.tertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;

    return KZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: KZFoodImage(
                  imageUrl: widget.item.imageUrl ?? '',
                  aspectRatio: 1,
                  borderRadius: BorderRadius.circular(KZ.radiusSm),
                ),
              ),
              const SizedBox(width: KZ.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.localizedName(lang),
                      style: KZ.itemTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'orders.items_summary'.tr(
                        namedArgs: {'count': '${widget.item.quantity}'},
                      ),
                      style: KZ.caption.copyWith(color: KZ.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KZ.sp12),
          Text('reviews.your_rating'.tr(), style: KZ.label),
          const SizedBox(height: 4),
          KZStarRating(
            rating: _rating,
            onChanged: (value) => setState(() => _rating = value),
          ),
          const SizedBox(height: KZ.sp12),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText:
                  '${'reviews.tell_us_about_food'.tr()} (${'reviews.optional'.tr()})',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KZ.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: KZ.sp12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: KZButton(
              label: _hasExistingReview
                  ? 'reviews.save_changes'.tr()
                  : 'reviews.submit_review'.tr(),
              loading: _isSubmitting,
              onPressed: _rating < 1 ? null : _submit,
              pill: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderFeedbackCard extends ConsumerStatefulWidget {
  final String orderId;
  final OrderFeedback? existing;

  const _OrderFeedbackCard({required this.orderId, required this.existing});

  @override
  ConsumerState<_OrderFeedbackCard> createState() => _OrderFeedbackCardState();
}

class _OrderFeedbackCardState extends ConsumerState<_OrderFeedbackCard> {
  late int _rating;
  late final TextEditingController _commentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existing?.rating ?? 0;
    _commentController = TextEditingController(
      text: widget.existing?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _hasExisting => widget.existing != null;

  Future<void> _submit() async {
    if (_rating < 1 || _rating > 5 || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final notifier = ref.read(orderReviewsProvider(widget.orderId).notifier);
    final comment = _commentController.text;
    final Failure? failure;
    if (_hasExisting) {
      failure = await notifier.editOrderFeedback(
        widget.existing!.id,
        rating: _rating,
        comment: ReviewCommentPatch.value(comment),
      );
    } else {
      failure = await notifier.submitOrderFeedback(
        rating: _rating,
        comment: comment,
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure.message.isNotEmpty
                ? failure.message
                : 'reviews.submit_error'.tr(),
          ),
          backgroundColor: KZ.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('reviews.thank_you'.tr()),
        backgroundColor: KZ.tertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KZStarRating(
            rating: _rating,
            onChanged: (value) => setState(() => _rating = value),
          ),
          const SizedBox(height: KZ.sp12),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText:
                  '${'reviews.overall_comment_hint'.tr()} (${'reviews.optional'.tr()})',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KZ.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: KZ.sp12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: KZButton(
              label: _hasExisting
                  ? 'reviews.save_changes'.tr()
                  : 'reviews.submit_review'.tr(),
              loading: _isSubmitting,
              onPressed: _rating < 1 ? null : _submit,
              variant: KZButtonVariant.secondary,
              pill: false,
            ),
          ),
        ],
      ),
    );
  }
}
