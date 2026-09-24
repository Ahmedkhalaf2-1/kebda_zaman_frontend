import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_lottie_add_button.dart';
import 'package:kebda_zaman/core/widgets/kz_lottie_heart_button.dart';
import 'package:kebda_zaman/core/widgets/kz_menu_item_meta.dart';
import 'package:kebda_zaman/core/widgets/kz_star_rating.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

/// The one shared product grid card — used by Home's Best Sellers, Menu's
/// catalog grid and Search results, so they never drift into looking like
/// separate design systems.
///
/// The card sizes to its content: a fixed-ratio photo on top, then the full
/// item name (never truncated — long names wrap onto more lines), rating and
/// price. Lay cards out with [SliverProductRows] (or give them a bounded
/// height) so every card in a row gets the same height, with the price
/// pinned to the bottom so prices line up across the row.
///
/// [subtitle] and [showDiscountPricing] are the only content differences a
/// caller may opt into. Menu's catalog grid deliberately passes neither —
/// discount/compare-at pricing and description belong in item details only,
/// by design — while Home's Best Sellers keeps its richer content
/// (description, discounted-price strike-through, compare-at price, a
/// "Sale" badge). Everything else is identical between callers.
class ProductGridCard extends StatelessWidget {
  final MenuItem item;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAdd;
  final String? subtitle;
  final bool showDiscountPricing;

  const ProductGridCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onAdd,
    this.subtitle,
    this.showDiscountPricing = false,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final hasDiscount = showDiscountPricing && item.discountPrice != null;
    final effectivePrice = item.discountPrice ?? item.basePrice;
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KZ.radiusXl),
        side: BorderSide(color: KZ.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Photo, with badge / favorite / add overlaid on it ──
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.15,
                  child: KZFoodImage(
                    imageUrl: item.imageUrl,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                // "Sale" badge — only when a real discount is being shown.
                // Takes the top-start corner; the admin badge below moves
                // to bottom-start in that case to avoid colliding with it.
                if (hasDiscount)
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: KZ.error,
                        borderRadius: BorderRadius.circular(KZ.radiusFull),
                      ),
                      child: Text(
                        'home.sale'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                // Admin badge (BESTSELLER / TOP_RATED).
                if (item.badge != null)
                  PositionedDirectional(
                    top: hasDiscount ? null : 8,
                    bottom: hasDiscount ? 8 : null,
                    start: 8,
                    child: MenuItemBadgeChip(badge: item.badge!),
                  ),
                PositionedDirectional(
                  top: 6,
                  end: 6,
                  child: KZLottieHeartButton(
                    isFavorite: isFavorite,
                    onTap: onToggleFavorite,
                    semanticsLabel: 'profile.my_favorites'.tr(),
                    size: 36,
                    iconSize: 18,
                  ),
                ),
                // Add sits fully on the photo so the text below can use
                // the card's whole width.
                PositionedDirectional(
                  bottom: 8,
                  end: 8,
                  child: KZLottieAddButton(
                    onTap: onAdd,
                    semanticsLabel: 'home.add_to_cart'.tr(),
                    size: 40,
                    backgroundColor: KZ.primary,
                    iconColor: Colors.white,
                    iconSize: KZ.iconControl,
                  ),
                ),
              ],
            ),
            // ── Name, rating, price ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.localizedName(lang), style: KZ.itemTitle),
                    if (hasSubtitle) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!.trim(),
                        style: KZ.bodySmall.copyWith(
                          color: KZ.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    KZMenuItemRatingBadge(
                      averageRating: item.averageRating,
                      reviewCount: item.reviewCount,
                      noRatingsLabel: 'reviews.no_ratings_yet'.tr(),
                      ratedLabelBuilder: (rating, count) =>
                          'reviews.rating_compact'.tr(
                            namedArgs: {
                              'rating': rating.toStringAsFixed(1),
                              'count': count.toString(),
                            },
                          ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 8),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Text(
                          formatCurrency(effectivePrice, locale: context.locale),
                          style: KZ.price,
                        ),
                        if (hasDiscount)
                          MenuItemComparePriceText(
                            compareAtPrice: item.basePrice,
                            style: KZ.bodySmall.copyWith(color: KZ.error),
                          ),
                        if (showDiscountPricing &&
                            item.compareAtPrice != null &&
                            item.compareAtPrice! > item.basePrice)
                          MenuItemComparePriceText(
                            compareAtPrice: item.compareAtPrice!,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lays product cards out in rows of [columns]. Unlike a fixed-extent grid,
/// each row is exactly as tall as its tallest card, so names are never cut
/// off or shrunk, while cards within a row still share one height.
class SliverProductRows extends StatelessWidget {
  final int itemCount;
  final int columns;
  final double spacing;
  final IndexedWidgetBuilder itemBuilder;

  const SliverProductRows({
    super.key,
    required this.itemCount,
    required this.columns,
    required this.itemBuilder,
    this.spacing = 14,
  });

  @override
  Widget build(BuildContext context) {
    final rowCount = (itemCount / columns).ceil();
    return SliverList.separated(
      itemCount: rowCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (context, row) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var col = 0; col < columns; col++) ...[
              if (col > 0) SizedBox(width: spacing),
              Expanded(
                child: row * columns + col < itemCount
                    ? itemBuilder(context, row * columns + col)
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
