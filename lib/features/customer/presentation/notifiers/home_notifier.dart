import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';

/// Home screen data — aggregates categories, featured, and best sellers.
class HomeData {
  final List<Category> categories;
  final List<MenuItem> featuredItems;
  final List<MenuItem> bestSellers;
  final List<MenuItem> offers;
  final List<MenuItem> recommended;
  final List<MenuItem> popular;
  final bool acceptingOrders;
  final String? closedMessageAr;
  final String? closedMessageEn;

  const HomeData({
    required this.categories,
    required this.featuredItems,
    required this.bestSellers,
    required this.offers,
    required this.recommended,
    required this.popular,
    required this.acceptingOrders,
    this.closedMessageAr,
    this.closedMessageEn,
  });
}

final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final menuRepo = ref.watch(menuRepositoryProvider);
  final settings = await ref.watch(restaurantSettingsProvider.future);

  final categoriesResult = await menuRepo.getCategories();
  final featuredResult = await menuRepo.getFeaturedItems();
  final allItemsResult = await menuRepo.getMenuItems();

  final categories = categoriesResult.fold(
    (f) => throw Exception(f.message),
    (data) => data,
  );
  final featured = featuredResult.fold(
    (f) => throw Exception(f.message),
    (data) => data,
  );
  final allItems = allItemsResult.fold(
    (f) => <MenuItem>[], // default to empty if fails
    (data) => data,
  );

  // Best sellers = items the admin explicitly badged as BESTSELLER in the menu.
  // This is the same source of truth as the menu screen badges — no separate
  // /best-sellers endpoint is needed and the list stays perfectly in sync.
  final bestSellers = allItems
      .where((item) => item.badge == MenuItemBadge.bestseller)
      .toList();

  // Derived sections
  final offers = allItems.where((item) => item.discountPrice != null).toList();
  // Shuffle allItems for recommended/popular so it looks dynamic (pseudo-random)
  final recommended = [...allItems]..shuffle();
  final popular = [...allItems.where((i) => !i.isBestSeller && !i.isFeatured)]
    ..shuffle();

  return HomeData(
    categories: categories,
    featuredItems: featured,
    bestSellers: bestSellers,
    offers: offers,
    recommended: recommended.take(5).toList(),
    popular: popular.take(5).toList(),
    acceptingOrders: settings.acceptingOrders,
    closedMessageAr: settings.closedMessageAr,
    closedMessageEn: settings.closedMessageEn,
  );
});
