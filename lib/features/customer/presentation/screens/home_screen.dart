import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';

import '../notifiers/home_notifier.dart';
import '../notifiers/cart_notifier.dart';
import '../notifiers/auth_notifier.dart';
import '../notifiers/favorites_notifier.dart';
import '../notifiers/address_notifier.dart';
import '../notifiers/orders_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/core/responsive/responsive_breakpoints.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/theme/kz_motion.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_lottie_add_button.dart';
import 'package:kebda_zaman/core/widgets/kz_menu_item_meta.dart';
import 'package:kebda_zaman/core/widgets/kz_product_card.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';

/// Shared elevation tier for the page's two full-bleed promotional
/// surfaces (dynamic hero, Featured Meals showcase cards) — kept identical
/// so both read as the same visual weight instead of two slightly
/// different one-off shadows.
List<BoxShadow> get _kzElevatedShadow => [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.12),
    blurRadius: 20,
    offset: const Offset(0, 8),
  ),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Design Tokens matching Stitch design
  static const Color surfaceBg = KZ.surface;
  static const Color primaryColor = KZ.primary;
  static const Color primaryContainerColor = KZ.primaryContainer;
  static const Color onSurfaceColor = KZ.onSurface;
  static const Color onSurfaceVariantColor = KZ.onSurfaceVariant;
  static const Color surfaceContainerColor = KZ.surfaceContainer;
  static const Color surfaceContainerHighestColor = Color(0xFFE3E2DF);
  static const Color outlineVariantColor = KZ.outlineVariant;
  static const Color activeChipColor = KZ.onSurface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeDataProvider);
    final favorites = ref.watch(customerFavoritesProvider).favoriteIds;

    return Scaffold(
      backgroundColor: surfaceBg,
      body: homeAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
        error: (e, st) => KZErrorState(
          message: 'home.failed_load'.tr(),
          retryLabel: 'home.retry'.tr(),
          onRetry: () => ref.invalidate(homeDataProvider),
        ),
        data: (data) {
          final bestSellers = data.bestSellers;

          // Recently ordered: most recent distinct items from past orders.
          final ordersAsync = ref.watch(ordersProvider);
          final recentOrderItems = ordersAsync.maybeWhen(
            data: (d) {
              final seen = <String>{};
              final result = <OrderItem>[];
              for (final order in d.previousOrders) {
                for (final item in order.items) {
                  if (result.length >= 8) break;
                  if (seen.add(item.menuItemId)) result.add(item);
                }
                if (result.length >= 8) break;
              }
              return result;
            },
            orElse: () => const <OrderItem>[],
          );

          return RefreshIndicator(
            color: primaryColor,
            onRefresh: () async => ref.invalidate(homeDataProvider),
            child: ResponsiveContainer(
              child: CustomScrollView(
                slivers: [
                  // ── 1. Top Navigation Shell (App Bar) ──
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    backgroundColor: surfaceBg.withValues(alpha: 0.9),
                    elevation: 0,
                    scrolledUnderElevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.05),
                    toolbarHeight: 64,
                    titleSpacing: 16,
                    title: const _AppBarAddressSelector(),
                    centerTitle: false,
                    actions: [
                      // Cart Button (with item-count badge)
                      Consumer(
                        builder: (context, ref, child) {
                          final cartAsync = ref.watch(cartProvider);
                          final itemCount =
                              cartAsync.valueOrNull?.items.fold<int>(
                                0,
                                (sum, i) => sum + i.quantity,
                              ) ??
                              0;

                          return Semantics(
                            button: true,
                            label: 'nav.cart'.tr(),
                            child: InkWell(
                              onTap: () => context.push('/cart'),
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: KZ.iconTapTargetMin,
                                height: KZ.iconTapTargetMin,
                                alignment: Alignment.center,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      color: primaryColor,
                                      size: KZ.iconAction,
                                    ),
                                    if (itemCount > 0)
                                      Positioned(
                                        top: -4,
                                        right: -6,
                                        child: Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: const BoxDecoration(
                                            color: KZ.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 17,
                                            minHeight: 17,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$itemCount',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                height: 1.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),

                  // ── 2. Greeting ──
                  const SliverToBoxAdapter(child: _GreetingHeader()),

                  // Closed Notice Banner (if applicable)
                  if (!data.acceptingOrders)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: KZ.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: Color(0xFF93000A),
                              size: KZ.iconControl,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                (context.locale.languageCode == 'ar'
                                        ? data.closedMessageAr
                                        : data.closedMessageEn) ??
                                    'home.closed_notice'.tr(),
                                style: KZ.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF93000A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── 4. Search Bar — same KZ.cardDecoration() treatment as
                  // Menu's sticky search bar, instead of a one-off pill
                  // shape unique to this screen. ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Semantics(
                        button: true,
                        label: 'home.search_hint'.tr(),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(KZ.radiusLg),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(KZ.radiusLg),
                            onTap: () => context.go('/search'),
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: KZ.cardDecoration(),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.search_rounded,
                                    color: onSurfaceVariantColor,
                                    size: KZ.iconControl,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'home.search_hint'.tr(),
                                      style: KZ.bodyLarge,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── 5. Dynamic Promotional Hero ──
                  // Driven entirely by real menu data (the current top offer,
                  // or the top featured item when nothing is discounted right
                  // now) — never static artwork. Hidden if neither exists.
                  if (data.offers.isNotEmpty || data.featuredItems.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _PromoHero(
                          item: data.offers.isNotEmpty
                              ? data.offers.first
                              : data.featuredItems.first,
                        ),
                      ),
                    ),

                  // ── 7. Featured Meals — large showcase cards ──
                  if (data.featuredItems.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                        child: Text(
                          'home.featured_meals'.tr(),
                          style: KZ.sectionTitle,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 240,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: data.featuredItems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final item = data.featuredItems[index];
                            return _ShowcaseTile(item: item);
                          },
                        ),
                      ),
                    ),
                  ],

                  // ── 8. Best Sellers Section ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'home.best_sellers'.tr(),
                              style: KZ.sectionTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/home/menu'),
                            child: Text(
                              'home.view_all'.tr(),
                              style: KZ.labelLarge.copyWith(
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (context.isMobile)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 325,
                        child: bestSellers.isEmpty
                            ? KZEmptyState(
                                icon: Icons.restaurant_menu_rounded,
                                title: 'home.no_best_sellers'.tr(),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                scrollDirection: Axis.horizontal,
                                itemCount: bestSellers.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final item = bestSellers[index];
                                  final isFav = favorites.contains(item.id);
                                  return SizedBox(
                                    width: 270,
                                    child: ProductGridCard(
                                      item: item,
                                      isFavorite: isFav,
                                      showDiscountPricing: true,
                                      subtitle: item.localizedDescription(
                                        context.locale.languageCode,
                                      ),
                                      onTap: () =>
                                          context.push('/home/item/${item.id}'),
                                      onAdd: () =>
                                          _handleHomeAdd(context, ref, item),
                                      onToggleFavorite: () async {
                                        final success = await ref
                                            .read(
                                              customerFavoritesProvider
                                                  .notifier,
                                            )
                                            .toggleFavorite(item.id);
                                        if (!success && context.mounted) {
                                          final err = ref
                                              .read(customerFavoritesProvider)
                                              .errorMessage;
                                          if (err != null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(err),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: context.isDesktop ? 4 : 3,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: 325,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = bestSellers[index];
                          final isFav = favorites.contains(item.id);
                          return ProductGridCard(
                            item: item,
                            isFavorite: isFav,
                            showDiscountPricing: true,
                            subtitle: item.localizedDescription(
                              context.locale.languageCode,
                            ),
                            onTap: () => context.push('/home/item/${item.id}'),
                            onAdd: () => _handleHomeAdd(context, ref, item),
                            onToggleFavorite: () async {
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
                          );
                        }, childCount: bestSellers.length),
                      ),
                    ),

                  // ── 9. Promotions — premium horizontal deal strip ──
                  if (data.offers.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                        child: Text(
                          'home.featured'.tr(),
                          style: KZ.sectionTitle,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 132,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: data.offers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 300,
                              child: _RecommendedTile(
                                item: data.offers[index],
                                isGrid: true,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // ── 10. Recently Ordered — only if data exists ──
                  if (recentOrderItems.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                        child: Text(
                          'home.recently_ordered'.tr(),
                          style: KZ.sectionTitle,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 168,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: recentOrderItems.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 14),
                          itemBuilder: (context, index) =>
                              _RecentOrderTile(item: recentOrderItems[index]),
                        ),
                      ),
                    ),
                  ],

                  // ── 11. Popular Items ──
                  if (data.popular.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                        child: Text(
                          'home.recommended'.tr(),
                          style: KZ.sectionTitle,
                        ),
                      ),
                    ),
                    if (context.isMobile)
                      // A bare SliverList gives each child unbounded height,
                      // but _RecommendedTile's price row uses Flexible,
                      // which requires a bounded height to resolve — fixed
                      // extent here, matching the grid variant's
                      // mainAxisExtent below so both breakpoints render the
                      // row at the same height.
                      SliverFixedExtentList(
                        itemExtent: 136,
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = data.popular[index];
                          return _RecommendedTile(item: item);
                        }, childCount: data.popular.length),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: context.isDesktop ? 3 : 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                mainAxisExtent: 136,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = data.popular[index];
                            return _RecommendedTile(item: item, isGrid: true);
                          }, childCount: data.popular.length),
                        ),
                      ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Component Widgets matching Stitch design specs ──

// Shared by every Home product tile that can add straight to cart
// (Best Sellers' ProductGridCard, Popular Items' _RecommendedTile) — kept
// as one function so the same exact logic isn't duplicated per card type.
void _handleHomeAdd(BuildContext context, WidgetRef ref, MenuItem item) {
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
    context.push('/home/item/${item.id}');
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


/// A large full-bleed showcase card for Featured Meals — image with a
/// gradient overlay carrying the name and real price, editorial in feel
/// rather than another product-grid card, so the section reads as a
/// deliberate visual beat instead of a repeat of Best Sellers.
class _ShowcaseTile extends StatelessWidget {
  final MenuItem item;

  const _ShowcaseTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = item.discountPrice != null;

    return SizedBox(
      width: 260,
      child: GestureDetector(
        onTap: () => context.push('/home/item/${item.id}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KZ.radiusXl),
            boxShadow: _kzElevatedShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(KZ.radiusXl),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // StackFit.expand gives this a tight size, so the
                // AspectRatio inside KZFoodImage defers to it and simply
                // fills the tile — the shared placeholder/error styling is
                // the reason to use it here, not the ratio itself.
                KZFoodImage(imageUrl: item.imageUrl),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.35, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.78),
                      ],
                    ),
                  ),
                ),
                if (item.badge != null)
                  Positioned(
                    top: KZ.sp12,
                    left: KZ.sp12,
                    child: MenuItemBadgeChip(badge: item.badge!),
                  ),
                Positioned(
                  left: KZ.sp16,
                  right: KZ.sp16,
                  bottom: KZ.sp16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.localizedName(context.locale.languageCode),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KZ.sectionTitle.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: KZ.sp4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            formatCurrency(
                              hasDiscount
                                  ? item.discountPrice!
                                  : item.basePrice,
                              locale: context.locale,
                            ),
                            style: KZ.price.copyWith(color: Colors.white),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: KZ.sp8),
                            Text(
                              formatCurrency(
                                item.basePrice,
                                locale: context.locale,
                              ),
                              style: KZ.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          if (item.compareAtPrice != null &&
                              item.compareAtPrice! > item.basePrice) ...[
                            const SizedBox(width: KZ.sp8),
                            MenuItemComparePriceText(
                              compareAtPrice: item.compareAtPrice!,
                              style: KZ.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendedTile extends ConsumerWidget {
  final MenuItem item;
  final bool isGrid;

  const _RecommendedTile({required this.item, this.isGrid = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDiscount = item.discountPrice != null;

    final tileContent = InkWell(
      onTap: () => context.push('/home/item/${item.id}'),
      borderRadius: BorderRadius.circular(KZ.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(KZ.radiusLg),
          border: Border.all(
            color: HomeScreen.surfaceContainerHighestColor.withValues(
              alpha: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: KZFoodImage(
                imageUrl: item.imageUrl,
                borderRadius: BorderRadius.circular(KZ.radiusMd),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.localizedName(context.locale.languageCode),
                    style: KZ.itemTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.localizedDescription(context.locale.languageCode),
                    style: KZ.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.badge != null || item.calories != null) ...[
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (item.badge != null)
                          MenuItemBadgeChip(badge: item.badge!),
                        if (item.calories != null)
                          MenuItemCaloriesText(calories: item.calories!),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            formatCurrency(
                              hasDiscount
                                  ? item.discountPrice!
                                  : item.basePrice,
                              locale: context.locale,
                            ),
                            style: KZ.price,
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 6),
                            Text(
                              formatCurrency(
                                item.basePrice,
                                locale: context.locale,
                              ),
                              style: KZ.bodySmall.copyWith(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                          if (item.compareAtPrice != null &&
                              item.compareAtPrice! > item.basePrice) ...[
                            const SizedBox(width: 6),
                            MenuItemComparePriceText(
                              compareAtPrice: item.compareAtPrice!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            KZLottieAddButton(
              onTap: () => _handleHomeAdd(context, ref, item),
              semanticsLabel: 'home.add_to_cart'.tr(),
              size: KZ.iconTapTargetMin,
              // Solid primary / white icon — same add-action weight as
              // Best Sellers and the Menu catalog grid, instead of the
              // lighter tinted treatment this tile used to have.
              backgroundColor: HomeScreen.primaryColor,
              iconColor: Colors.white,
              iconSize: KZ.iconControl,
            ),
          ],
        ),
      ),
    );

    if (isGrid) return tileContent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: tileContent,
    );
  }
}

// ── Greeting, delivery, hero & category components (Sprint 1) ──

/// Which translation key + icon greets the user, purely a function of the
/// wall-clock hour — no backend field for this, and none is needed.
String _greetingTextKey(int hour) {
  if (hour < 12) return 'home.greeting_morning';
  if (hour < 18) return 'home.greeting_afternoon';
  return 'home.greeting_evening';
}

IconData _greetingIcon(int hour) {
  if (hour < 12) return Icons.wb_sunny_rounded;
  if (hour < 18) return Icons.wb_twilight_rounded;
  return Icons.nights_stay_rounded;
}

/// Opening beat of the page: a quiet, typographic greeting — no card, no
/// border — followed by the user's first name at hero scale and a soft
/// prompt into the catalog below. Fades/slides in once on mount.
class _GreetingHeader extends ConsumerWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final hasName =
        user != null && user.name.trim().isNotEmpty && !user.isGuest;
    final hour = DateTime.now().hour;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 10),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _greetingIcon(hour),
                  size: 18,
                  color: HomeScreen.primaryColor,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _greetingTextKey(hour).tr(),
                    style: KZ.labelLarge.copyWith(
                      color: HomeScreen.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              hasName
                  ? user.name.trim().split(' ').first
                  : 'home.guest_greeting'.tr(),
              style: KZ.display.copyWith(
                fontSize: 32,
                height: 1.2,
                color: HomeScreen.onSurfaceColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Delivery destination, promoted to a proper KZ card — the second beat of
/// the story, immediately grounding "what happens when I order" before the
/// catalog begins. Reuses [KZCard] rather than a bespoke container.
class _AppBarAddressSelector extends ConsumerWidget {
  const _AppBarAddressSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressNotifierProvider);
    final address = addressState.defaultAddress;

    final subtitle = address != null
        ? '${address.label.isNotEmpty ? address.label : address.street}'
        : 'home.add_address'.tr();

    return GestureDetector(
      onTap: () => context.push('/profile/addresses'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'home.delivery_to'.tr(),
                style: KZ.label.copyWith(
                  color: HomeScreen.onSurfaceVariantColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: HomeScreen.primaryColor,
              ),
            ],
          ),
          Text(
            subtitle,
            style: KZ.cardTitle.copyWith(
              color: HomeScreen.onSurfaceColor,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// The dynamic promotional hero — reusable and entirely data-driven: the
/// real top offer (or top featured item, when nothing is discounted right
/// now) supplies the image, name and price. No static artwork, no
/// hand-written marketing copy tied to a specific campaign.
class _PromoHero extends StatelessWidget {
  final MenuItem item;

  const _PromoHero({required this.item});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = item.discountPrice != null;
    final percentOff = hasDiscount
        ? (((item.basePrice - item.discountPrice!) / item.basePrice) * 100)
              .round()
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () => context.push('/home/item/${item.id}'),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KZ.radiusXl),
            boxShadow: _kzElevatedShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(KZ.radiusXl),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                    // Fixed-height hero container (above) already prevents
                    // layout shift; fade-in just avoids a hard flicker once
                    // the image arrives.
                    fadeInDuration: KZMotion.standard,
                    fadeInCurve: KZMotion.enterExit,
                    placeholder: (context, url) => Container(
                      color: HomeScreen.surfaceContainerHighestColor,
                    ),
                    errorWidget: (context, url, err) =>
                        Container(color: KZ.primary),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          KZ.primary.withValues(alpha: 0.92),
                          KZ.primary.withValues(alpha: 0.65),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(KZ.radiusFull),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          percentOff != null
                              ? '$percentOff% ${'home.sale'.tr()}'
                              : 'home.limited_time'.tr(),
                          style: KZ.statusLabel.copyWith(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 220,
                        child: Text(
                          item.localizedName(context.locale.languageCode),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: KZ.sectionTitle.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      KZButton(
                        label: 'home.claim_now'.tr(),
                        pill: true,
                        onPressed: () => context.push('/home/item/${item.id}'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A compact tile for the Recently Ordered strip — deliberately smaller and
/// quieter than the Best Seller/Showcase cards so it reads as a personal
/// aside, not another catalog grid. Taps through to item details rather
/// than re-adding to cart directly, since price/options may have changed
/// since the order was placed.
class _RecentOrderTile extends StatelessWidget {
  final OrderItem item;

  const _RecentOrderTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124,
      child: GestureDetector(
        onTap: () => context.push('/home/item/${item.menuItemId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              width: double.infinity,
              child: KZFoodImage(
                imageUrl: item.imageUrl,
                borderRadius: BorderRadius.circular(KZ.radiusLg),
              ),
            ),
            const SizedBox(height: KZ.sp8),
            Text(
              item.name,
              style: KZ.itemTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              formatCurrency(item.unitPrice, locale: context.locale),
              style: KZ.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
