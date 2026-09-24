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
///
/// [initialRating] pre-fills the overall rating when the user tapped a star
/// on the tracking screen's "How was your order?" prompt.
class OrderReviewScreen extends ConsumerWidget {
  final String orderId;
  final int? initialRating;

  const OrderReviewScreen({
    super.key,
    required this.orderId,
    this.initialRating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isGuest = !authState.isLoggedIn || (authState.user?.isGuest ?? true);

    if (isGuest) {
      return Scaffold(
        appBar: KZ.formAppBar(context: context, title: 'reviews.title'.tr()),
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
      appBar: KZ.formAppBar(context: context, title: 'reviews.title'.tr()),
      body: asyncData.when(
        data: (data) => _OrderReviewBody(
          orderId: orderId,
          data: data,
          initialRating: initialRating,
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: KZ.primary)),
        error: (error, _) => KZErrorState(
          message: error is Failure ? error.message : 'reviews.load_error'.tr(),
          onRetry: () => ref.invalidate(orderReviewsProvider(orderId)),
          retryLabel: 'common.retry'.tr(),
        ),
      ),
    );
  }
}

/// Editable rating + comment for one review target (an item or the order).
class _Draft {
  int rating;
  final TextEditingController comment;
  bool showComment;

  _Draft({required this.rating, required String comment})
    : comment = TextEditingController(text: comment),
      showComment = comment.isNotEmpty;

  /// Whether this draft should be sent: rated, and either new or different
  /// from what's already saved.
  bool isDirty({required int? savedRating, required String? savedComment}) {
    if (rating < 1) return false;
    if (savedRating == null) return true;
    return rating != savedRating || comment.text != (savedComment ?? '');
  }
}

/// Holds every draft so the whole page is submitted with one button. The
/// provider refreshes in place after each save (no loading state), so this
/// state survives the refreshes triggered mid-submit.
class _OrderReviewBody extends ConsumerStatefulWidget {
  final String orderId;
  final OrderReviewDetails data;
  final int? initialRating;

  const _OrderReviewBody({
    required this.orderId,
    required this.data,
    this.initialRating,
  });

  @override
  ConsumerState<_OrderReviewBody> createState() => _OrderReviewBodyState();
}

class _OrderReviewBodyState extends ConsumerState<_OrderReviewBody> {
  late final _Draft _overall;
  late final Map<String, _Draft> _items;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final feedback = widget.data.orderFeedback;
    final initial = widget.initialRating;
    _overall = _Draft(
      rating:
          feedback?.rating ??
          (initial != null && initial >= 1 && initial <= 5 ? initial : 0),
      comment: feedback?.comment ?? '',
    );
    _items = {
      for (final item in widget.data.items)
        item.orderItemId: _Draft(
          rating: item.review?.rating ?? 0,
          comment: item.review?.comment ?? '',
        ),
    };
    for (final draft in [_overall, ..._items.values]) {
      draft.comment.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    for (final draft in [_overall, ..._items.values]) {
      draft.comment.dispose();
    }
    super.dispose();
  }

  void _onChanged() => setState(() {});

  bool _overallDirty(OrderReviewDetails data) => _overall.isDirty(
    savedRating: data.orderFeedback?.rating,
    savedComment: data.orderFeedback?.comment,
  );

  bool _itemDirty(OrderReviewItem item) => _items[item.orderItemId]!.isDirty(
    savedRating: item.review?.rating,
    savedComment: item.review?.comment,
  );

  bool get _hasChanges =>
      _overallDirty(widget.data) || widget.data.items.any(_itemDirty);

  bool get _hasSavedReviews =>
      widget.data.orderFeedback != null ||
      widget.data.items.any((item) => item.review != null);

  Future<void> _submit() async {
    if (_isSubmitting || !_hasChanges) return;
    setState(() => _isSubmitting = true);

    final notifier = ref.read(orderReviewsProvider(widget.orderId).notifier);
    // Snapshot before saving: each save refreshes [widget.data].
    final data = widget.data;
    Failure? firstFailure;

    for (final item in data.items) {
      if (!_itemDirty(item)) continue;
      final draft = _items[item.orderItemId]!;
      final existing = item.review;
      final failure = existing != null
          ? await notifier.editItemReview(
              existing.id,
              rating: draft.rating,
              comment: ReviewCommentPatch.value(draft.comment.text),
            )
          : await notifier.submitItemReview(
              orderItemId: item.orderItemId,
              rating: draft.rating,
              comment: draft.comment.text,
            );
      firstFailure ??= failure;
    }

    if (_overallDirty(data)) {
      final existing = data.orderFeedback;
      final failure = existing != null
          ? await notifier.editOrderFeedback(
              existing.id,
              rating: _overall.rating,
              comment: ReviewCommentPatch.value(_overall.comment.text),
            )
          : await notifier.submitOrderFeedback(
              rating: _overall.rating,
              comment: _overall.comment.text,
            );
      firstFailure ??= failure;
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final messenger = ScaffoldMessenger.of(context);
    if (firstFailure != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            firstFailure.message.isNotEmpty
                ? firstFailure.message
                : 'reviews.submit_error'.tr(),
          ),
          backgroundColor: KZ.error,
        ),
      );
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text('reviews.thank_you'.tr()),
        backgroundColor: KZ.tertiary,
      ),
    );
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    if (!data.eligible) {
      return KZEmptyState(
        icon: Icons.star_outline_rounded,
        title: 'reviews.not_eligible'.tr(),
        message: 'reviews.not_eligible_sub'.tr(),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              KZ.screenPadding,
              KZ.sp16,
              KZ.screenPadding,
              KZ.sp24,
            ),
            children: [
              _OverallCard(
                draft: _overall,
                saved: data.orderFeedback != null,
                onRatingChanged: (v) => setState(() => _overall.rating = v),
                onShowComment: () =>
                    setState(() => _overall.showComment = true),
              ),
              if (data.items.isNotEmpty) ...[
                const SizedBox(height: KZ.sp24),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4),
                  child: Text(
                    'reviews.rate_items_heading'.tr(),
                    style: KZ.sectionTitle,
                  ),
                ),
                const SizedBox(height: KZ.sp12),
                for (final item in data.items) ...[
                  _ItemCard(
                    item: item,
                    draft: _items[item.orderItemId]!,
                    onRatingChanged: (v) =>
                        setState(() => _items[item.orderItemId]!.rating = v),
                    onShowComment: () => setState(
                      () => _items[item.orderItemId]!.showComment = true,
                    ),
                  ),
                  const SizedBox(height: KZ.sp12),
                ],
              ],
            ],
          ),
        ),
        _SubmitBar(
          label: _hasSavedReviews
              ? 'reviews.update_review'.tr()
              : 'reviews.submit_review'.tr(),
          loading: _isSubmitting,
          onPressed: _hasChanges ? _submit : null,
        ),
      ],
    );
  }
}

/// Top card: the order as a whole — the most important rating, so it's
/// first and gets the largest stars.
class _OverallCard extends StatelessWidget {
  final _Draft draft;
  final bool saved;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onShowComment;

  const _OverallCard({
    required this.draft,
    required this.saved,
    required this.onRatingChanged,
    required this.onShowComment,
  });

  @override
  Widget build(BuildContext context) {
    return _ReviewSurface(
      child: Column(
        children: [
          if (saved) ...[const _SavedBadge(), const SizedBox(height: KZ.sp8)],
          Text(
            'reviews.overall_experience'.tr(),
            style: KZ.sectionTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KZ.sp4),
          Text(
            'reviews.overall_experience_sub'.tr(),
            style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KZ.sp12),
          KZStarRating(
            rating: draft.rating,
            size: 44,
            onChanged: onRatingChanged,
          ),
          const SizedBox(height: KZ.sp8),
          _CommentField(
            draft: draft,
            hint: 'reviews.overall_comment_hint'.tr(),
            onShow: onShowComment,
            center: true,
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final OrderReviewItem item;
  final _Draft draft;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onShowComment;

  const _ItemCard({
    required this.item,
    required this.draft,
    required this.onRatingChanged,
    required this.onShowComment,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    return _ReviewSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: KZFoodImage(
                  imageUrl: item.imageUrl ?? '',
                  aspectRatio: 1,
                  borderRadius: BorderRadius.circular(KZ.radiusMd),
                ),
              ),
              const SizedBox(width: KZ.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.localizedName(lang),
                      style: KZ.itemTitle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '×${item.quantity}',
                      style: KZ.caption.copyWith(color: KZ.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (item.review != null) const _SavedBadge(),
            ],
          ),
          const SizedBox(height: KZ.sp8),
          KZStarRating(
            rating: draft.rating,
            size: 30,
            onChanged: onRatingChanged,
          ),
          _CommentField(
            draft: draft,
            hint: 'reviews.tell_us_about_food'.tr(),
            onShow: onShowComment,
          ),
        ],
      ),
    );
  }
}

/// Collapsed to an "Add a comment" link until opened, so the page isn't a
/// wall of empty text boxes. Starts open when a saved comment exists.
class _CommentField extends StatelessWidget {
  final _Draft draft;
  final String hint;
  final VoidCallback onShow;
  final bool center;

  const _CommentField({
    required this.draft,
    required this.hint,
    required this.onShow,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!draft.showComment) {
      return Align(
        alignment: center ? Alignment.center : AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: onShow,
          icon: const Icon(Icons.edit_note_rounded, size: 20),
          label: Text('reviews.add_comment'.tr()),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: KZ.sp8),
      child: TextField(
        controller: draft.comment,
        autofocus: draft.comment.text.isEmpty,
        minLines: 2,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: '$hint (${'reviews.optional'.tr()})',
          fillColor: KZ.surfaceContainerLow,
        ),
      ),
    );
  }
}

class _ReviewSurface extends StatelessWidget {
  final Widget child;
  const _ReviewSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KZ.sp16),
      decoration: KZ.flatCardDecoration(),
      child: child,
    );
  }
}

class _SavedBadge extends StatelessWidget {
  const _SavedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: KZ.tertiary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KZ.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 14, color: KZ.tertiary),
          const SizedBox(width: 4),
          Text(
            'reviews.saved'.tr(),
            style: KZ.caption.copyWith(
              color: KZ.tertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Single submit for the whole page, pinned above the home indicator.
class _SubmitBar extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const _SubmitBar({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: KZ.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          KZ.screenPadding,
          KZ.sp12,
          KZ.screenPadding,
          KZ.sp12,
        ),
        child: KZButton(
          label: label,
          loading: loading,
          onPressed: onPressed,
          fullWidth: true,
          pill: true,
        ),
      ),
    );
  }
}
