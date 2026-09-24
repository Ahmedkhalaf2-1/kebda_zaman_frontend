import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_product_card.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_menu_item_meta.dart';
import 'package:kebda_zaman/core/widgets/kz_star_rating.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

import 'package:kebda_zaman/features/customer/presentation/notifiers/favorites_notifier.dart';

final favoritesProvider = customerFavoritesProvider;

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favState = ref.watch(customerFavoritesProvider);

    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: KZ.formAppBar(context: context, title: 'favorites.title'.tr()),
      body: favState.isLoading && favState.favoriteItems.isEmpty
          ? const Center(child: CircularProgressIndicator(color: KZ.primary))
          : favState.errorMessage != null && favState.favoriteItems.isEmpty
          ? KZErrorState(
              message: 'home.failed_load'.tr(),
              retryLabel: 'home.retry'.tr(),
              onRetry: () =>
                  ref.read(customerFavoritesProvider.notifier).loadFavorites(),
            )
          : favState.favoriteItems.isEmpty
          ? KZEmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'favorites.empty'.tr(),
              message: 'favorites.empty_sub'.tr(),
              actionLabel: 'favorites.browse_menu'.tr(),
              onAction: () => context.go('/menu'),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KZ.screenPadding,
                    vertical: KZ.sp16,
                  ),
                  sliver: SliverProductRows(
                    columns: 2,
                    spacing: KZ.sp16,
                    itemCount: favState.favoriteItems.length,
                    itemBuilder: (context, index) => _FavoriteItemCard(
                      item: favState.favoriteItems[index],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _FavoriteItemCard extends ConsumerWidget {
  final MenuItem item;

  const _FavoriteItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDiscount = item.discountPrice != null;

    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KZ.radiusXl),
        side: BorderSide(color: KZ.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: () => context.push('/home/item/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.15,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (ctx, url, err) => Container(
                        color: KZ.surfaceContainer,
                        child: const Icon(
                          Icons.fastfood,
                          color: KZ.outline,
                          size: 36,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: KZ.surfaceContainer,
                      child: const Icon(
                        Icons.fastfood,
                        color: KZ.outline,
                        size: 36,
                      ),
                    ),
                  Positioned(
                    top: KZ.sp4,
                    right: KZ.sp4,
                    child: KZIconButton(
                      icon: Icons.favorite_rounded,
                      onPressed: () async {
                        final success = await ref
                            .read(customerFavoritesProvider.notifier)
                            .toggleFavorite(item.id);
                        if (!success && context.mounted) {
                          final err = ref
                              .read(customerFavoritesProvider)
                              .errorMessage;
                          if (err != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(err),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                      tooltip: 'profile.my_favorites'.tr(),
                      background: Colors.white.withValues(alpha: 0.9),
                      foreground: KZ.error,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full name — never truncated; rows grow to fit it.
                    Text(
                      item.localizedName(context.locale.languageCode),
                      style: KZ.itemTitle,
                    ),
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
                      children: [
                        Text(
                          formatCurrency(
                            hasDiscount ? item.discountPrice! : item.basePrice,
                            locale: context.locale,
                          ),
                          style: KZ.price,
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          MenuItemComparePriceText(
                            compareAtPrice: item.basePrice,
                            style: KZ.bodySmall.copyWith(color: KZ.error),
                          ),
                        ],
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
