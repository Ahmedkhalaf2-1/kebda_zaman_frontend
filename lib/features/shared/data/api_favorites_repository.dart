import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_item.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/favorites_repository.dart';

class ApiFavoritesRepository implements FavoritesRepository {
  final ApiClient _apiClient;

  ApiFavoritesRepository(this._apiClient);

  Failure _handleError(dynamic e, String defaultMsg) {
    if (e is DioException) {
      if (e.error is ApiException) {
        final apiEx = e.error as ApiException;
        if (apiEx.code == 'MENU_ITEM_NOT_FOUND' ||
            e.response?.statusCode == 404) {
          return NotFoundFailure(apiEx.message, apiEx);
        }
        if (apiEx.code == 'FAVORITE_ALREADY_EXISTS' ||
            e.response?.statusCode == 409) {
          return ValidationFailure(apiEx.message, apiEx);
        }
        return NetworkFailure(apiEx.message, apiEx);
      }
      return NetworkFailure(e.message ?? defaultMsg);
    }
    return UnknownFailure(e.toString());
  }

  MenuItem _mapMenuItem(Map<String, dynamic> json) {
    List<ModifierGroup> modifierGroups = [];

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

    return MenuItem(
      id: json['id'],
      categoryId: json['categoryId'] ?? '',
      name: json['nameEn'] ?? json['nameAr'] ?? 'Unknown',
      description: json['descriptionEn'] ?? json['descriptionAr'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      isAvailable: json['isAvailable'] ?? true,
      isFeatured: json['isPopular'] ?? false,
      isBestSeller: json['isPopular'] ?? false,
      modifierGroups: modifierGroups,
    );
  }

  @override
  Future<Result<List<MenuItem>>> getFavorites() async {
    try {
      final response = await _apiClient.dio.get('/me/favorites');
      final list = (response.data as List)
          .map((item) => _mapMenuItem(item as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Err(_handleError(e, 'Failed to fetch favorites'));
    }
  }

  @override
  Future<Result<List<MenuItem>>> addFavorite(String menuItemId) async {
    try {
      final response = await _apiClient.dio.post(
        '/me/favorites',
        data: {'menuItemId': menuItemId},
      );
      final list = (response.data as List)
          .map((item) => _mapMenuItem(item as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Err(_handleError(e, 'Failed to add favorite'));
    }
  }

  @override
  Future<Result<void>> removeFavorite(String menuItemId) async {
    try {
      await _apiClient.dio.delete('/me/favorites/$menuItemId');
      return const Success(null);
    } catch (e) {
      return Err(_handleError(e, 'Failed to remove favorite'));
    }
  }
}
