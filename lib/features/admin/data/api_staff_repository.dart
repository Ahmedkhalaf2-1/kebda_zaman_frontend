import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/staff_account.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/staff_repository.dart';

class ApiStaffRepository implements StaffRepository {
  final ApiClient _apiClient;

  ApiStaffRepository(this._apiClient);

  Failure _handleError(dynamic e, String defaultMsg) {
    if (e is DioException) {
      if (e.error is ApiException) {
        final apiEx = e.error as ApiException;
        if (apiEx.code == 'EMAIL_ALREADY_EXISTS' ||
            e.response?.statusCode == 409) {
          return ValidationFailure(apiEx.message, apiEx);
        }
        if (apiEx.code == 'STAFF_NOT_FOUND' || e.response?.statusCode == 404) {
          return NotFoundFailure(apiEx.message, apiEx);
        }
        return NetworkFailure(apiEx.message, apiEx);
      }
      return NetworkFailure(e.message ?? defaultMsg);
    }
    return UnknownFailure(e.toString());
  }

  @override
  Future<Result<List<StaffAccount>>> getStaff() async {
    try {
      final response = await _apiClient.dio.get('/admin/staff');
      final list = (response.data as List)
          .map((json) => StaffAccount.fromJson(json as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Err(_handleError(e, 'Failed to load staff'));
    }
  }

  @override
  Future<Result<StaffAccount>> createStaff({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/admin/staff',
        data: {
          'role': role,
          'name': name,
          'email': email,
          'password': password,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      return Success(
        StaffAccount.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to create staff account'));
    }
  }

  @override
  Future<Result<StaffAccount>> updateStaff(
    String id, {
    String? name,
    String? email,
    String? phone,
    bool? isActive,
    String? password,
  }) async {
    try {
      final payload = <String, dynamic>{
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (isActive != null) 'isActive': isActive,
        if (password != null && password.isNotEmpty) 'password': password,
      };
      final response = await _apiClient.dio.patch(
        '/admin/staff/$id',
        data: payload,
      );
      return Success(
        StaffAccount.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to update staff account'));
    }
  }
}
