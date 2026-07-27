import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/address.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/address_repository.dart';

/// Real API repository for Customer Addresses (/me/addresses).
class ApiAddressRepository implements AddressRepository {
  final ApiClient _apiClient;

  ApiAddressRepository(this._apiClient);

  Failure _handleError(dynamic e, String defaultMessage) {
    if (e is DioException) {
      if (e.error is ApiException) {
        final apiEx = e.error as ApiException;
        if (apiEx.code == 'ADDRESS_NOT_FOUND' ||
            e.response?.statusCode == 404) {
          return NotFoundFailure(apiEx.message, apiEx);
        }
        if (apiEx.code == 'FORBIDDEN' || e.response?.statusCode == 403) {
          return AuthFailure(apiEx.message, apiEx);
        }
        return ValidationFailure(apiEx.message, apiEx);
      }
      if (e.response?.statusCode == 404) {
        return const NotFoundFailure('Address not found');
      }
      if (e.response?.statusCode == 403) {
        return const AuthFailure('Access denied for address operation');
      }
      return NetworkFailure(e.message ?? defaultMessage);
    }
    return UnknownFailure(e.toString());
  }

  @override
  Future<Result<List<Address>>> getAddresses() async {
    try {
      final response = await _apiClient.dio.get('/me/addresses');
      final list = (response.data as List<dynamic>)
          .map((json) => Address.fromBackendJson(json as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Err(_handleError(e, 'Failed to fetch addresses'));
    }
  }

  @override
  Future<Result<Address>> createAddress(Address address) async {
    try {
      final response = await _apiClient.dio.post(
        '/me/addresses',
        data: address.toBackendJson(),
      );
      return Success(
        Address.fromBackendJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to create address'));
    }
  }

  @override
  Future<Result<Address>> updateAddress(String id, Address address) async {
    try {
      final response = await _apiClient.dio.put(
        '/me/addresses/$id',
        data: address.toBackendJson(),
      );
      return Success(
        Address.fromBackendJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to update address'));
    }
  }

  @override
  Future<Result<void>> deleteAddress(String id) async {
    try {
      await _apiClient.dio.delete('/me/addresses/$id');
      return const Success(null);
    } catch (e) {
      return Err(_handleError(e, 'Failed to delete address'));
    }
  }

  @override
  Future<Result<Address>> setDefaultAddress(String id) async {
    try {
      final response = await _apiClient.dio.patch('/me/addresses/$id/default');
      return Success(
        Address.fromBackendJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to set default address'));
    }
  }
}
