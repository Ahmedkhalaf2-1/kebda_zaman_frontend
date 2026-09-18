import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/driver_account.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/driver_repository.dart';

class ApiDriverRepository implements DriverRepository {
  final ApiClient _apiClient;

  ApiDriverRepository(this._apiClient);

  Failure _handleError(dynamic e, String defaultMsg) {
    if (e is DioException) {
      if (e.error is ApiException) {
        final apiEx = e.error as ApiException;
        if (apiEx.code == 'EMAIL_ALREADY_EXISTS' ||
            e.response?.statusCode == 409) {
          return ValidationFailure(apiEx.message, apiEx);
        }
        if (apiEx.code == 'DRIVER_NOT_FOUND' || e.response?.statusCode == 404) {
          return NotFoundFailure(apiEx.message, apiEx);
        }
        return NetworkFailure(apiEx.message, apiEx);
      }
      return NetworkFailure(e.message ?? defaultMsg);
    }
    return UnknownFailure(e.toString());
  }

  @override
  Future<Result<List<DriverAccount>>> getDrivers({
    String? query,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (isActive != null) queryParams['isActive'] = isActive;

      final response = await _apiClient.dio.get(
        '/admin/drivers',
        queryParameters: queryParams,
      );
      final list = (response.data as List)
          .map((json) => DriverAccount.fromJson(json as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Err(_handleError(e, 'Failed to load drivers'));
    }
  }

  @override
  Future<Result<DriverAccount>> getDriverById(String id) async {
    try {
      final response = await _apiClient.dio.get('/admin/drivers/$id');
      return Success(
        DriverAccount.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to load driver'));
    }
  }

  @override
  Future<Result<DriverAccount>> createDriver({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/admin/drivers',
        data: {
          'name': name,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      return Success(
        DriverAccount.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to create driver account'));
    }
  }

  @override
  Future<Result<DriverAccount>> updateDriver(
    String id, {
    String? name,
    String? email,
    String? phone,
    String? password,
    bool? isActive,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (password != null && password.isNotEmpty) 'password': password,
        if (isActive != null) 'isActive': isActive,
      };
      final response = await _apiClient.dio.patch(
        '/admin/drivers/$id',
        data: payload,
      );
      return Success(
        DriverAccount.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to update driver account'));
    }
  }
}
