import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/menu_offer_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_offer.dart';

class ApiMenuOfferRepository implements MenuOfferRepository {
  final ApiClient _apiClient;

  ApiMenuOfferRepository(this._apiClient);

  @override
  Future<Result<List<MenuOffer>>> getMenuOffers() async {
    try {
      final response = await _apiClient.dio.get('/admin/menu-offers');
      final data = response.data as List;
      final offers = data
          .map((json) => _mapMenuOffer(json as Map<String, dynamic>))
          .toList();
      return Success(offers);
    } on DioException catch (e) {
      return Err(_mapError(e, 'Failed to load menu offers'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading menu offers'));
    }
  }

  @override
  Future<Result<void>> createMenuOffer(MenuOffer offer) async {
    try {
      await _apiClient.dio.post(
        '/admin/menu-offers',
        data: _buildPayload(offer),
      );
      return const Success(null);
    } on DioException catch (e) {
      return Err(_mapError(e, 'Failed to create menu offer'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error creating menu offer'));
    }
  }

  @override
  Future<Result<void>> updateMenuOffer(MenuOffer offer) async {
    try {
      await _apiClient.dio.put(
        '/admin/menu-offers/${offer.id}',
        data: _buildPayload(offer),
      );
      return const Success(null);
    } on DioException catch (e) {
      return Err(_mapError(e, 'Failed to update menu offer'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error updating menu offer'));
    }
  }

  @override
  Future<Result<void>> deleteMenuOffer(String id) async {
    try {
      await _apiClient.dio.delete('/admin/menu-offers/$id');
      return const Success(null);
    } on DioException catch (e) {
      return Err(_mapError(e, 'Failed to delete menu offer'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error deleting menu offer'));
    }
  }

  Failure _mapError(DioException e, String fallback) {
    if (e.error is ApiException) {
      return NetworkFailure(
        (e.error as ApiException).message,
        e.error as ApiException,
      );
    }
    return NetworkFailure(fallback);
  }

  Map<String, dynamic> _buildPayload(MenuOffer offer) {
    return {
      'menuItemId': offer.menuItemId,
      'imageUrl': offer.imageUrl,
      if (offer.title != null && offer.title!.trim().isNotEmpty)
        'title': offer.title!.trim(),
      if (offer.description != null && offer.description!.trim().isNotEmpty)
        'description': offer.description!.trim(),
      'isActive': offer.isActive,
      'startAt': offer.startAt?.toUtc().toIso8601String(),
      'endAt': offer.endAt?.toUtc().toIso8601String(),
      'sortOrder': offer.sortOrder,
    };
  }

  MenuOffer _mapMenuOffer(Map<String, dynamic> json) {
    return MenuOffer(
      id: json['id'] as String,
      menuItemId: json['menuItemId'] as String,
      imageUrl: json['imageUrl'] as String? ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      startAt: _parseDate(json['startAt']),
      endAt: _parseDate(json['endAt']),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
      menuItem: json['menuItem'] is Map<String, dynamic>
          ? _mapMenuItemSummary(json['menuItem'] as Map<String, dynamic>)
          : null,
    );
  }

  MenuOfferMenuItemSummary _mapMenuItemSummary(Map<String, dynamic> json) {
    return MenuOfferMenuItemSummary(
      id: json['id'] as String,
      name:
          json['name'] as String? ??
          json['nameEn'] as String? ??
          json['nameAr'] as String?,
      imageUrl: json['imageUrl'] as String?,
      basePrice: _parseDouble(json['basePrice']),
      isAvailable: json['isAvailable'] as bool?,
      categoryId: json['categoryId'] as String?,
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
