import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_offer.dart';

/// Menu repository interface per md1 §25/§31.
/// FakeMenuRepository (Phase 1) → ApiMenuRepository (Phase 3).
abstract class MenuRepository {
  Future<Result<List<Category>>> getCategories();
  Future<Result<Category>> getCategoryById(String id);
  Future<Result<List<MenuItem>>> getMenuItems({String? categoryId});

  /// Admin-only: hits `/admin/categories`, includes inactive categories.
  Future<Result<List<Category>>> getAdminCategories();

  /// Admin-only: hits `/admin/menu`, includes unavailable items.
  Future<Result<List<MenuItem>>> getAdminMenuItems({
    String? categoryId,
    String? query,
  });
  Future<Result<MenuItem>> getMenuItemById(String id);
  Future<Result<List<MenuItem>>> getFeaturedItems();
  Future<Result<List<MenuItem>>> getBestSellers();
  Future<Result<List<MenuItem>>> searchItems(String query);

  /// Public, customer-facing: hits `GET /menu-offers`. The backend already
  /// filters to currently-visible offers (active + in-schedule + linked item
  /// not soft-deleted) — this never re-derives that filtering client-side.
  Future<Result<List<MenuOffer>>> getMenuOffers();

  // Admin CRUD
  Future<Result<void>> createMenuItem(MenuItem item);
  Future<Result<void>> updateMenuItem(MenuItem item);
  Future<Result<void>> deleteMenuItem(String id);
  Future<Result<void>> createCategory(Category category);
  Future<Result<void>> updateCategory(Category category);
  Future<Result<void>> deleteCategory(String id);
  Future<Result<String>> uploadImage(List<int> bytes, String filename);
}
