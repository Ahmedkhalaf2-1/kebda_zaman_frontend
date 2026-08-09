import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/promo_code.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/promo_repository.dart';

class ApiPromoRepository implements PromoRepository {
  final ApiClient _apiClient;

  ApiPromoRepository(this._apiClient);

  @override
  Future<Result<PromoCode?>> getPromoByCode(String code) async {
    final listRes = await getAllPromos();
    return listRes.fold((err) => Err(err), (promos) {
      try {
        final found = promos.firstWhere(
          (p) => p.code.toLowerCase() == code.trim().toLowerCase(),
        );
        return Success(found);
      } catch (_) {
        return const Success(null);
      }
    });
  }

  @override
  Future<Result<List<PromoCode>>> getAllPromos() async {
    try {
      final response = await _apiClient.dio.get('/admin/promos');
      final list = (response.data as List)
          .map((json) => _mapPromo(json as Map<String, dynamic>))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to load promo codes'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading promo codes'));
    }
  }

  @override
  Future<Result<bool>> validatePromo(String code, double orderSubtotal) async {
    try {
      final response = await _apiClient.dio.post(
        '/promos/validate',
        data: {'code': code.trim()},
      );
      final isValid = response.data['valid'] as bool? ?? true;
      return Success(isValid);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Promo validation failed'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error validating promo'));
    }
  }

  @override
  Future<Result<void>> createPromo(PromoCode promo) async {
    try {
      final payload = _buildPayload(promo);
      await _apiClient.dio.post('/admin/promos', data: payload);
      return const Success(null);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to create promo code'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error creating promo code'));
    }
  }

  @override
  Future<Result<void>> updatePromo(PromoCode promo) async {
    try {
      final payload = _buildPayload(promo);
      await _apiClient.dio.put('/admin/promos/${promo.id}', data: payload);
      return const Success(null);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to update promo code'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error updating promo code'));
    }
  }

  @override
  Future<Result<void>> deletePromo(String id) async {
    try {
      await _apiClient.dio.delete('/admin/promos/$id');
      return const Success(null);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to delete promo code'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error deleting promo code'));
    }
  }

  Map<String, dynamic> _buildPayload(PromoCode promo) {
    return {
      'code': promo.code.trim().toUpperCase(),
      'discountType': promo.discountType == DiscountType.fixed
          ? 'FIXED'
          : 'PERCENT',
      'value': promo.value,
      'minOrderAmount': promo.minOrderValue,
      // `maxUsage`/`perUserLimit` are optional on the backend (`int>=1` when
      // present) — null means unlimited. Previously this defaulted to 100/1
      // whenever the admin left them unset, silently capping every promo
      // regardless of what was actually chosen. Send exactly what's on the
      // model — including null — so "leave empty for unlimited" in the admin
      // form actually reaches the backend as unlimited.
      'maxUsage': promo.usageLimit,
      'perUserLimit': promo.perUserLimit,
      'isActive': promo.isActive,
      'startsAt': promo.startDate.toUtc().toIso8601String(),
      'expiresAt': promo.endDate.toUtc().toIso8601String(),
    };
  }

  PromoCode _mapPromo(Map<String, dynamic> json) {
    final typeStr = (json['discountType'] as String? ?? 'PERCENT')
        .toUpperCase();
    DiscountType type = DiscountType.percentage;
    if (typeStr == 'FIXED') {
      type = DiscountType.fixed;
    }

    return PromoCode(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      discountType: type,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      minOrderValue: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startsAt'] != null
          ? DateTime.parse(json['startsAt'])
          : DateTime.now(),
      endDate: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : DateTime.now().add(const Duration(days: 30)),
      usageLimit: (json['maxUsage'] as num?)?.toInt(),
      perUserLimit: (json['perUserLimit'] as num?)?.toInt(),
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }
}
