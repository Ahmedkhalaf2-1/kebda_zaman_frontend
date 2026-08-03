import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/category.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/menu_repository.dart';

class ApiMenuRepository implements MenuRepository {
  final ApiClient _apiClient;

  ApiMenuRepository(this._apiClient);

  @visibleForTesting
  static MenuItem mapMenuItemForTesting(Map<String, dynamic> json) =>
      _mapMenuItem(json);

  @visibleForTesting
  static Category mapCategoryForTesting(Map<String, dynamic> json) =>
      _mapCategory(json);

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('/categories');
      final data = response.data as List;
      final categories = data.map((json) => _mapCategory(json)).toList();
      return Success(categories);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to load categories'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading categories'));
    }
  }

  @override
  Future<Result<List<Category>>> getAdminCategories() async {
    try {
      final response = await _apiClient.dio.get('/admin/categories');
      final data = response.data as List;
      final categories = data.map((json) => _mapCategory(json)).toList();
      return Success(categories);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to load categories'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading categories'));
    }
  }

  @override
  Future<Result<List<MenuItem>>> getAdminMenuItems({
    String? categoryId,
    String? query,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      final response = await _apiClient.dio.get(
        '/admin/menu',
        queryParameters: queryParams,
      );
      final data = response.data as List;
      final items = data.map((json) => _mapMenuItem(json)).toList();
      return Success(items);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to load menu items'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading menu items'));
    }
  }

  @override
  Future<Result<Category>> getCategoryById(String id) async {
    try {
      final response = await _apiClient.dio.get('/categories/$id');
      return Success(_mapCategory(response.data));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to load category'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading category'));
    }
  }

  @override
  Future<Result<List<MenuItem>>> getMenuItems({String? categoryId}) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': 100, // Fetch up to 100 to simulate full list for now
      };
      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }
      final response = await _apiClient.dio.get(
        '/menu',
        queryParameters: queryParams,
      );
      final data = response.data as List;
      final items = data.map((json) => _mapMenuItem(json)).toList();
      return Success(items);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to load menu items'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading menu items'));
    }
  }

  @override
  Future<Result<MenuItem>> getMenuItemById(String id) async {
    try {
      final response = await _apiClient.dio.get('/menu/items/$id');
      return Success(_mapMenuItem(response.data));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to load menu item'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading menu item'));
    }
  }

  @override
  Future<Result<List<MenuItem>>> getFeaturedItems() async {
    try {
      final response = await _apiClient.dio.get('/home/featured');
      // Response shape: { featured: MenuItemResponseDto[], categories: CategoryResponseDto[] }
      final featuredData = response.data['featured'] as List;
      final items = featuredData.map((json) => _mapMenuItem(json)).toList();
      return Success(items);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to load featured items'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading featured items'));
    }
  }

  @override
  Future<Result<List<MenuItem>>> getBestSellers() async {
    // Backend doesn't have a specific best sellers endpoint, but /home/featured returns isPopular=true items.
    // For now, return featured items to satisfy UI.
    return getFeaturedItems();
  }

  @override
  Future<Result<List<MenuItem>>> searchItems(String query) async {
    if (query.trim().isEmpty) return const Success([]);
    try {
      final response = await _apiClient.dio.get(
        '/menu/search',
        queryParameters: {'q': query},
      );
      final data = response.data as List;
      final items = data.map((json) => _mapMenuItem(json)).toList();
      return Success(items);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to search items'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error searching items'));
    }
  }

  // --- Admin Methods ---
  @override
  Future<Result<void>> createMenuItem(MenuItem item) async {
    try {
      final payload = <String, dynamic>{
        'categoryId': item.categoryId,
        'nameAr': item.name,
        'nameEn': item.name,
        'descriptionAr': item.description,
        'descriptionEn': item.description,
        'basePrice': item.basePrice,
        'imageUrl': item.imageUrl,
        'isAvailable': item.isAvailable,
        'isPopular': item.isFeatured,
      };
      await _apiClient.dio.post('/admin/menu/items', data: payload);
      return const Success(null);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to create menu item'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error creating menu item'));
    }
  }

  @override
  Future<Result<void>> updateMenuItem(MenuItem item) async {
    try {
      final payload = <String, dynamic>{
        'categoryId': item.categoryId,
        'nameAr': item.name,
        'nameEn': item.name,
        'descriptionAr': item.description,
        'descriptionEn': item.description,
        'basePrice': item.basePrice,
        'imageUrl': item.imageUrl,
        'isAvailable': item.isAvailable,
        'isPopular': item.isFeatured,
      };
      await _apiClient.dio.put('/admin/menu/items/${item.id}', data: payload);
      return const Success(null);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to update menu item'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error updating menu item'));
    }
  }

  @override
  Future<Result<void>> deleteMenuItem(String id) async {
    try {
      await _apiClient.dio.delete('/admin/menu/items/$id');
      return const Success(null);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to delete menu item'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error deleting menu item'));
    }
  }

  @override
  Future<Result<void>> createCategory(Category category) async {
    try {
      final payload = <String, dynamic>{
        'nameAr': category.name,
        'nameEn': category.name,
        if (category.imageUrl != null && category.imageUrl!.isNotEmpty)
          'iconUrl': category.imageUrl,
      };
      await _apiClient.dio.post('/admin/categories', data: payload);
      return const Success(null);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to create category'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error creating category'));
    }
  }

  @override
  Future<Result<void>> updateCategory(Category category) async {
    try {
      final payload = <String, dynamic>{
        'nameAr': category.name,
        'nameEn': category.name,
        if (category.imageUrl != null && category.imageUrl!.isNotEmpty)
          'iconUrl': category.imageUrl,
      };
      await _apiClient.dio.put(
        '/admin/categories/${category.id}',
        data: payload,
      );
      return const Success(null);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to update category'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error updating category'));
    }
  }

  @override
  Future<Result<void>> deleteCategory(String id) async {
    try {
      await _apiClient.dio.delete('/admin/categories/$id');
      return const Success(null);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to delete category'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error deleting category'));
    }
  }

  // --- Mappers ---

  static Category _mapCategory(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['nameEn'] ?? json['nameAr'] ?? 'Unknown',
      imageUrl: json['iconUrl'],
      sortOrder: json['displayOrder'] ?? 0,
      isActive:
          json['isActive'] ??
          true, // public shape has no isActive field; admin shape does
    );
  }

  @override
  Future<Result<String>> uploadImage(List<int> bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final response = await _apiClient.dio.post(
        '/admin/uploads/image',
        data: formData,
      );
      final data = response.data as Map<String, dynamic>;
      final url = data['imageUrl'] as String;
      return Success(url);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(NetworkFailure((e.error as ApiException).message));
      }
      return const Err(NetworkFailure('Failed to upload image'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error uploading image'));
    }
  }

  static MenuItem _mapMenuItem(
    Map<String, dynamic> json, {
    bool includeRecommendations = true,
  }) {
    List<ModifierGroup> modifierGroups = [];

    // Map Variants into a mandatory ModifierGroup
    if (json['variants'] != null && (json['variants'] as List).isNotEmpty) {
      final variants = json['variants'] as List;
      modifierGroups.add(
        ModifierGroup(
          id: 'variants_group_${json['id']}',
          name: 'Size / Type',
          isRequired: true,
          selectionType: 'SINGLE',
          minSelections: 1,
          maxSelections: 1,
          options: variants
              .map(
                (v) => ModifierOption(
                  id: v['id'],
                  name: v['nameEn'] ?? v['nameAr'] ?? 'Unknown',
                  priceModifier: (v['priceDelta'] as num?)?.toDouble() ?? 0.0,
                  isDefault: v['isDefault'] ?? false,
                  isAvailable: true,
                ),
              )
              .toList(),
        ),
      );
    }

    // Map AddonGroups
    if (json['addonGroups'] != null &&
        (json['addonGroups'] as List).isNotEmpty) {
      final groups = json['addonGroups'] as List;
      for (var group in groups) {
        final addons = (group['addons'] as List?) ?? [];
        modifierGroups.add(
          ModifierGroup(
            id: group['id'],
            name: group['titleEn'] ?? group['titleAr'] ?? 'Add-ons',
            isRequired: group['isRequired'] ?? false,
            selectionType: ((group['maxSelect'] ?? 1) > 1)
                ? 'MULTIPLE'
                : 'SINGLE',
            minSelections: group['minSelect'] ?? 0,
            maxSelections: group['maxSelect'] ?? 1,
            options: addons
                .map(
                  (a) => ModifierOption(
                    id: a['id'],
                    name: a['nameEn'] ?? a['nameAr'] ?? 'Unknown',
                    priceModifier: (a['price'] as num?)?.toDouble() ?? 0.0,
                    isAvailable: true,
                  ),
                )
                .toList(),
          ),
        );
      }
    }

    // oftenOrderedWith is only present on the /menu/items/:id details
    // response; list/search/featured responses omit it entirely, so this
    // defaults to empty. Recommendation summaries are mapped with the same
    // mapper (they share the same field shape minus variants/addonGroups),
    // but recursion is disabled for them: nested oftenOrderedWith inside a
    // recommendation is intentionally ignored per the backend contract.
    List<MenuItem> oftenOrderedWith = const [];
    if (includeRecommendations) {
      final raw = json['oftenOrderedWith'];
      if (raw is List) {
        oftenOrderedWith = raw
            .map(
              (r) => _mapMenuItem(
                r as Map<String, dynamic>,
                includeRecommendations: false,
              ),
            )
            .toList();
      }
    }

    return MenuItem(
      id: json['id'],
      categoryId: json['categoryId'],
      name: json['nameEn'] ?? json['nameAr'] ?? 'Unknown',
      description: json['descriptionEn'] ?? json['descriptionAr'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] ?? true,
      isFeatured: json['isPopular'] ?? false,
      isBestSeller: json['isPopular'] ?? false,
      modifierGroups: modifierGroups,
      calories: menuItemCaloriesFromApi(json['calories']),
      compareAtPrice: menuItemCompareAtPriceFromApi(json['compareAtPrice']),
      badge: menuItemBadgeFromApi(json['badge'] as String?),
      oftenOrderedWith: oftenOrderedWith,
      nameAr: json['nameAr'] as String?,
      nameEn: json['nameEn'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
    );
  }
}
