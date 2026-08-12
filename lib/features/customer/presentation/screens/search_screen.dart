import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_product_card.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/menu_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/favorites_notifier.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../notifiers/search_notifier.dart';

import 'package:kebda_zaman/core/responsive/responsive_breakpoints.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';

int _searchColumnCount(BuildContext context) {
  if (context.isDesktop) return 4;
  if (context.isTablet) return 3;
  return 2;
}

// Same tuning as Menu's catalog grid (menu_screen.dart's _cardExtent) — kept
// in sync deliberately so a card looks pixel-identical whether it's reached
// from Menu or from a Search result.
double _searchCardExtent(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w >= 600) return 272.0;
  if (w >= 390) return 265.0;
  return 260.0;
}

void _handleSearchResultAdd(BuildContext context, WidgetRef ref, MenuItem item) {
  if (!item.isAvailable) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('menu.item_unavailable'.tr()),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  final hasRequired = item.modifierGroups.any((g) => g.isRequired);
  if (hasRequired) {
    context.push('/menu/item/${item.id}');
  } else {
    final cartItem = CartItem(
      id: 'ci_${DateTime.now().millisecondsSinceEpoch}',
      menuItemId: item.id,
      productName: item.name,
      productImage: item.imageUrl,
      basePrice: item.discountPrice ?? item.basePrice,
      quantity: 1,
      selectedOptions: {},
      extraQuantities: {},
      unitPrice: item.discountPrice ?? item.basePrice,
      lineTotal: item.discountPrice ?? item.basePrice,
    );
    ref.read(cartProvider.notifier).addItem(cartItem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('home.added_to_cart'.tr(namedArgs: {'name': item.name})),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final searchNotifier = ref.read(searchProvider.notifier);

    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: KZ.primary,
            size: 26,
          ),
        ),
        title: TextField(
          autofocus: true,
          decoration: KZ.searchInputDecoration(hint: 'search.hint'.tr()),
          onChanged: (val) {
            searchNotifier.updateQuery(val);
          },
          onSubmitted: (val) {
            searchNotifier.addRecentSearch(val);
          },
        ),
      ),
      body: ResponsiveContainer(
        child: searchState.query.isEmpty
            ? _buildIdleState(context, searchState, searchNotifier, ref)
            : _buildResultsState(context, ref, searchState),
      ),
    );
  }

  Widget _buildIdleState(
    BuildContext context,
    SearchState state,
    SearchNotifier notifier,
    WidgetRef ref,
  ) {
    final menuState = ref.watch(menuNotifierProvider);
    final lang = context.locale.languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KZ.screenPadding,
        vertical: KZ.sp16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('search.recent'.tr(), style: KZ.labelLarge),
                TextButton(
                  onPressed: () => notifier.clearRecentSearches(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Clear All',
                    style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KZ.sp8),
            Wrap(
              spacing: KZ.sp8,
              runSpacing: KZ.sp8,
              children: state.recentSearches.map((s) {
                return InkWell(
                  onTap: () => notifier.updateQuery(s),
                  borderRadius: BorderRadius.circular(KZ.radiusFull),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(KZ.radiusFull),
                      border: Border.all(
                        color: KZ.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s,
                          style: KZ.label.copyWith(
                            color: KZ.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => notifier.removeRecentSearch(s),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: KZ.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: KZ.sp24),
          ],

          if (menuState.value != null && menuState.value!.categories.isNotEmpty) ...[
            Text('search.popular'.tr(), style: KZ.labelLarge),
            const SizedBox(height: KZ.sp16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: menuState.value!.categories.take(8).map((cat) {
                return InkWell(
                  onTap: () => notifier.selectCategory(
                    cat.localizedName(lang),
                    cat.id,
                    menuState.value!.items,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: KZ.outlineVariant.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: cat.imageUrl ?? '',
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorWidget:
                              (c, u, e) =>
                                  const Icon(Icons.fastfood, color: KZ.outlineVariant),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            cat.localizedName(lang),
                            style: KZ.caption.copyWith(
                              color: KZ.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Same `ProductGridCard` grid Menu's catalog uses (see
  // menu_screen.dart) — a search result reads identically to reaching the
  // same item through Menu, not as a separate, bespoke list design.
  Widget _buildResultsState(BuildContext context, WidgetRef ref, SearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: KZ.primary));
    }

    if (state.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KZ.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(KZ.sp20),
                decoration: const BoxDecoration(
                  color: KZ.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: KZ.secondary,
                ),
              ),
              const SizedBox(height: KZ.sp16),
              Text(
                'search.no_results'.tr(namedArgs: {'query': state.query}),
                style: KZ.sectionTitle.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final favorites = ref.watch(customerFavoritesProvider).favoriteIds;
    final columnCount = _searchColumnCount(context);
    final extent = _searchCardExtent(context);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: extent,
      ),
      itemCount: state.results.length,
      itemBuilder: (context, index) {
        final item = state.results[index];
        final isFav = favorites.contains(item.id);
        return ProductGridCard(
          item: item,
          isFavorite: isFav,
          onTap: () => context.push('/home/item/${item.id}'),
          onAdd: () => _handleSearchResultAdd(context, ref, item),
          onToggleFavorite: () async {
            final success = await ref
                .read(customerFavoritesProvider.notifier)
                .toggleFavorite(item.id);
            if (!success && context.mounted) {
              final err = ref.read(customerFavoritesProvider).errorMessage;
              if (err != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(err)));
              }
            }
          },
        );
      },
    );
  }
}
