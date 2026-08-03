import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../notifiers/menu_notifier.dart';
import '../notifiers/cart_notifier.dart';
import '../notifiers/auth_notifier.dart';
import '../notifiers/favorites_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/core/responsive/responsive_breakpoints.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/core/widgets/kz_menu_item_meta.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';

// Whether the compact weekly-special strip has been dismissed this session.
final menuHeroDismissedProvider = StateProvider<bool>((ref) => false);

int _menuColumnCount(BuildContext context) {
  if (context.isDesktop) return 4;
  if (context.isTablet) return 3;
  return 2;
}

class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  // Design Tokens matching the KZ design system
  static const Color surfaceBg = KZ.surface;
  static const Color primaryColor = KZ.primary;
  static const Color onSurfaceVariantColor = KZ.onSurfaceVariant;
  static const Color surfaceContainerColor = KZ.surfaceContainer;
  static const Color surfaceContainerHighestColor = Color(0xFFE3E2DF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(menuNotifierProvider);
    final favoritesState = ref.watch(customerFavoritesProvider);
    final favorites = favoritesState.favoriteIds;
    final heroDismissed = ref.watch(menuHeroDismissedProvider);

    return Scaffold(
      backgroundColor: surfaceBg,
      body: menuAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
        error: (e, st) => KZErrorState(
          message: 'home.failed_load'.tr(),
          retryLabel: 'home.retry'.tr(),
          onRetry: () => ref.invalidate(menuNotifierProvider),
        ),
        data: (data) {
          final columnCount = _menuColumnCount(context);

          return CustomScrollView(
            slivers: [
              // ── 1. Compact Branded Header ──
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: surfaceBg.withValues(alpha: 0.9),
                elevation: 0,
                shadowColor: Colors.black.withValues(alpha: 0.05),
                toolbarHeight: 64,
                titleSpacing: 16,
                title: Text(
                  'menu.title'.tr(),
                  style: KZ.pageTitle.copyWith(color: primaryColor),
                ),
                centerTitle: false,
                actions: [
                  Consumer(
                    builder: (context, ref, child) {
                      final authState = ref.watch(authNotifierProvider);
                      final user = authState.user;
                      final hasName =
                          user != null && user.name.trim().isNotEmpty;
                      final initial = hasName
                          ? user.name.trim()[0].toUpperCase()
                          : '';

                      return Semantics(
                        button: true,
                        label: 'nav.profile'.tr(),
                        child: InkWell(
                          onTap: () => context.go('/profile'),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: KZ.iconTapTargetMin,
                            height: KZ.iconTapTargetMin,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: surfaceContainerColor,
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.5),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: hasName
                                  ? Text(
                                      initial,
                                      style: KZ.labelLarge.copyWith(
                                        color: primaryColor,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person_outline_rounded,
                                      color: primaryColor,
                                      size: KZ.iconAction,
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              // ── 2. Sticky Search + Category Selector ──
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyMenuHeaderDelegate(
                  categories: data.categories,
                  selectedCategoryId: data.selectedCategoryId,
                  onSelectCategory: (id) => ref
                      .read(menuNotifierProvider.notifier)
                      .selectCategory(id),
                ),
              ),

              // ── 3. Compact Dismissible Weekly-Special Strip ──
              if (!heroDismissed)
                SliverToBoxAdapter(
                  child: _WeeklySpecialStrip(
                    onDismiss: () =>
                        ref.read(menuHeroDismissedProvider.notifier).state =
                            true,
                  ),
                ),

              // ── 4. Product Grid ──
              if (data.items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: KZEmptyState(
                      icon: Icons.restaurant_menu_rounded,
                      title: 'menu.no_items'.tr(),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columnCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: 312,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = data.items[index];
                      final isFav = favorites.contains(item.id);
                      return _MenuProductCard(
                        item: item,
                        isFavorite: isFav,
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
                    }, childCount: data.items.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }
}

// ── Sticky header: search bar + category chips, pinned together ──

class _StickyMenuHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onSelectCategory;

  _StickyMenuHeaderDelegate({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelectCategory,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: MenuScreen.surfaceBg.withValues(alpha: 0.97),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Semantics(
              button: true,
              label: 'home.search_hint'.tr(),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(KZ.radiusLg),
                child: InkWell(
                  borderRadius: BorderRadius.circular(KZ.radiusLg),
                  onTap: () => context.push('/search'),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: KZ.cardDecoration(),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: MenuScreen.onSurfaceVariantColor,
                          size: KZ.iconControl,
                        ),
                        const SizedBox(width: 12),
                        Text('home.search_hint'.tr(), style: KZ.bodyLarge),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = selectedCategoryId == null;
                  return KZChip(
                    label: 'menu.all'.tr(),
                    selected: isSelected,
                    onTap: () => onSelectCategory(null),
                  );
                }
                final cat = categories[index - 1];
                final isSelected = selectedCategoryId == cat.id;
                return KZChip(
                  label: cat.name,
                  selected: isSelected,
                  onTap: () => onSelectCategory(isSelected ? null : cat.id),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 50 + 20 + 48 + 8;

  @override
  double get minExtent => 50 + 20 + 48 + 8;

  @override
  bool shouldRebuild(covariant _StickyMenuHeaderDelegate oldDelegate) {
    return oldDelegate.categories != categories ||
        oldDelegate.selectedCategoryId != selectedCategoryId;
  }
}

// ── Compact, dismissible weekly-special strip (no stock photography) ──

class _WeeklySpecialStrip extends StatelessWidget {
  final VoidCallback onDismiss;

  const _WeeklySpecialStrip({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: KZ.primaryFixed,
          borderRadius: BorderRadius.circular(KZ.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: KZ.primary,
                size: KZ.iconControl,
              ),
            ),
            const SizedBox(width: KZ.sp12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'menu.weekly_special'.tr(),
                    style: KZ.statusLabel.copyWith(color: KZ.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'menu.banner_title'.tr(),
                    style: KZ.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Semantics(
              button: true,
              label: 'common.close'.tr(),
              child: InkWell(
                onTap: onDismiss,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(KZ.sp8),
                  child: Icon(
                    Icons.close_rounded,
                    color: KZ.primary,
                    size: KZ.iconControl,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Product card: image-top, built for fast scanning ──

class _MenuProductCard extends ConsumerWidget {
  final MenuItem item;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _MenuProductCard({
    required this.item,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  void _handleAdd(BuildContext context, WidgetRef ref) {
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
          content: Text(
            'home.added_to_cart'.tr(namedArgs: {'name': item.name}),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDiscount = item.discountPrice != null;

    return KZCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('/menu/item/${item.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 140,
                width: double.infinity,
                child: KZFoodImage(imageUrl: item.imageUrl, aspectRatio: 1),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Semantics(
                  button: true,
                  label: 'profile.my_favorites'.tr(),
                  child: InkWell(
                    onTap: onToggleFavorite,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: KZ.iconTapTargetMin,
                      height: KZ.iconTapTargetMin,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedScale(
                          scale: isFavorite ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: KZ.primary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (hasDiscount)
                Positioned(
                  top: 10,
                  left: 10,
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
              if (item.badge != null)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: MenuItemBadgeChip(badge: item.badge!),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.name,
                        style: KZ.itemTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.description,
                        style: KZ.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.calories != null) ...[
                        const SizedBox(height: 3),
                        MenuItemCaloriesText(calories: item.calories!),
                      ],
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasDiscount)
                              Text(
                                formatCurrency(
                                  item.basePrice,
                                  locale: context.locale,
                                ),
                                style: KZ.bodySmall.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (item.compareAtPrice != null &&
                                item.compareAtPrice! > item.basePrice)
                              MenuItemComparePriceText(
                                compareAtPrice: item.compareAtPrice!,
                              ),
                            Text(
                              formatCurrency(
                                hasDiscount
                                    ? item.discountPrice!
                                    : item.basePrice,
                                locale: context.locale,
                              ),
                              style: KZ.price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Flexible + FittedBox: if the translated label or a
                      // long price ever leaves less room than expected, the
                      // button scales down instead of overflowing the row —
                      // same defensive pattern as the price row above.
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Semantics(
                            button: true,
                            label: 'home.add_to_cart'.tr(),
                            child: InkWell(
                              onTap: () => _handleAdd(context, ref),
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: KZ.iconTapTargetMin,
                                height: KZ.iconTapTargetMin,
                                decoration: BoxDecoration(
                                  color: KZ.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: KZ.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: KZ.iconControl,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
