import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_lottie_add_button.dart';
import 'package:kebda_zaman/core/widgets/kz_lottie_heart_button.dart';
import 'package:kebda_zaman/core/widgets/kz_menu_item_meta.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

/// The one shared product grid card — used by both Home's Best Sellers and
/// Menu's catalog grid, so the two never drift into looking like separate
/// design systems. Fixed 70/30 image-to-info split (computed from the
/// tile's actual height via `LayoutBuilder`, so it holds at every
/// responsive breakpoint), RTL-aware badge/favorite/add positions via
/// `PositionedDirectional`, and the same KZCard surface/radius/border
/// everywhere a product is a grid tile.
///
/// [subtitle] and [showDiscountPricing] are the only content differences a
/// caller may opt into. Menu's catalog grid deliberately passes neither —
/// discount/compare-at pricing and description belong in item details only,
/// by design — while Home's Best Sellers keeps its existing richer content
/// (description, discounted-price strike-through, compare-at price, a
/// "Sale" badge). Everything else — image treatment, name/price typography,
/// button sizes, card chrome — is identical between the two callers.
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
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return KZCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: LayoutBuilder(
        builder: (_, constraints) {
          // Exact tile height from the grid's mainAxisExtent — always
          // finite and bounded, so division is safe.
          final cardH = constraints.maxHeight;
          final imageH = cardH * 0.70;
          // Real available width for the name/price block, matching the
          // 12/58 horizontal padding below. FittedBox measures its child
          // unconstrained, so without this the block's "natural" width
          // is dictated by whichever line is longest when laid out on one
          // line — typically the description — which drags the shrink
          // factor (and therefore every line's on-screen size, including
          // the title and price) down far more than actually needed.
          final infoW = constraints.maxWidth - 12 - 58;

          return Stack(
            children: [
              // ── Base: image column + info area ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: imageH,
                    child: KZFoodImage(
                      imageUrl: item.imageUrl,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(KZ.radiusLg),
                      ),
                    ),
                  ),
                  // Right/end inset of 58dp reserves space for the floating
                  // "+" button (44 wide + 10 end + 4 breathing gap = 58dp).
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        12,
                        8,
                        58,
                        6,
                      ),
                      // A single FittedBox around the whole name+price block
                      // — not split into separately-flexed pieces — is the
                      // only way to *guarantee* this info slot never trips
                      // a RenderFlex overflow, regardless of card extent,
                      // locale, font-scale, or which of the optional
                      // subtitle/discount/compare-at lines are present: it
                      // measures the block at its natural size and scales
                      // the whole thing down to fit, rather than each
                      // sub-piece independently claiming space that may not
                      // add up. Top-start alignment keeps every card's name
                      // starting at the same vertical position within a
                      // row, same as before.
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.topStart,
                        child: SizedBox(
                          width: infoW,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.localizedName(lang),
                                style: KZ.itemTitle,
                                maxLines: hasSubtitle ? 1 : 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (hasSubtitle) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  style: KZ.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 4),
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
                              Text(
                                formatCurrency(
                                  effectivePrice,
                                  locale: context.locale,
                                ),
                                style: KZ.price,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── "Sale" badge — only when a real discount is being shown.
              // Takes the top-start corner; the admin badge below moves to
              // bottom-start in that case to avoid colliding with it.
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
                      borderRadius: BorderRadius.circular(KZ.radiusSm),
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

              // ── Admin badge (BESTSELLER / TOP_RATED) ──
              if (item.badge != null)
                hasDiscount
                    ? PositionedDirectional(
                        bottom: 8,
                        start: 8,
                        child: MenuItemBadgeChip(badge: item.badge!),
                      )
                    : PositionedDirectional(
                        top: 8,
                        start: 8,
                        child: MenuItemBadgeChip(badge: item.badge!),
                      ),

              // ── Favourite — top-end, 36×36 frosted circle ──
              PositionedDirectional(
                top: 6,
                end: 6,
                child: KZLottieHeartButton(
                  isFavorite: isFavorite,
                  onTap: onToggleFavorite,
                  semanticsLabel: 'profile.my_favorites'.tr(),
                  size: 36,
                  iconSize: 18,
                  shadowOpacity: 0.14,
                ),
              ),

              // ── Circular add (+) — floating at the image/info boundary.
              // top = imageH − 22 places the button's vertical centre
              // exactly on the dividing line (half of 44dp = 22dp).
              PositionedDirectional(
                top: imageH - 22,
                end: 10,
                child: KZLottieAddButton(
                  onTap: onAdd,
                  semanticsLabel: 'home.add_to_cart'.tr(),
                  size: 44,
                  backgroundColor: KZ.primary,
                  iconColor: Colors.white,
                  iconSize: KZ.iconControl,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
