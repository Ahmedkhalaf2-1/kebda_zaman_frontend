import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
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
          : GridView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: KZ.screenPadding,
                vertical: KZ.sp16,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: KZ.sp16,
                crossAxisSpacing: KZ.sp16,
                childAspectRatio: 0.76,
              ),
              itemCount: favState.favoriteItems.length,
              itemBuilder: (context, index) {
                final item = favState.favoriteItems[index];
                return _FavoriteItemCard(item: item);
              },
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

    return Container(
      decoration: KZ.cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/home/item/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
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
                          final err = ref.read(customerFavoritesProvider).errorMessage;
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
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(KZ.sp12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: KZ.cardTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${hasDiscount ? item.discountPrice : item.basePrice} ${'common.egp'.tr()}',
                      style: KZ.price,
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
