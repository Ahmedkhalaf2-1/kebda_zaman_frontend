import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/customer_summary.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/customer_repository.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

class ApiCustomerRepository implements CustomerRepository {
  final ApiClient _apiClient;

  ApiCustomerRepository(this._apiClient);

  Failure _handleError(dynamic e, String defaultMsg) {
    if (e is DioException) {
      if (e.error is ApiException) {
        final apiEx = e.error as ApiException;
        if (apiEx.code == 'CUSTOMER_NOT_FOUND' ||
            e.response?.statusCode == 404) {
          return NotFoundFailure(apiEx.message, apiEx);
        }
        return NetworkFailure(apiEx.message, apiEx);
      }
      return NetworkFailure(e.message ?? defaultMsg);
    }
    return UnknownFailure(e.toString());
  }

  CustomerSummary _mapSummary(Map<String, dynamic> json) {
    return CustomerSummary(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      isGuest: json['isGuest'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
    );
  }

  RecentOrderSummary _mapRecentOrder(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'pending';
    final status = OrderStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => OrderStatus.unknown,
    );
    final fulfillmentStr = json['fulfillmentType'] as String?;
    final fulfillmentType = fulfillmentStr == 'pickup'
        ? FulfillmentType.pickup
        : FulfillmentType.delivery;

    return RecentOrderSummary(
      id: json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: status,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'],
      fulfillmentType: fulfillmentType,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
    );
  }

  CustomerDetail _mapDetail(Map<String, dynamic> json) {
    final recentOrdersList = (json['recentOrders'] as List?) ?? [];
    return CustomerDetail(
      summary: _mapSummary(json),
      recentOrders: recentOrdersList
          .map((o) => _mapRecentOrder(o as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<Result<List<CustomerSummary>>> getCustomers({
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
        '/admin/customers',
        queryParameters: queryParams,
      );
      final list = (response.data as List)
          .map((json) => _mapSummary(json as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Err(_handleError(e, 'Failed to load customers'));
    }
  }

  @override
  Future<Result<CustomerDetail>> getCustomerDetail(String id) async {
    try {
      final response = await _apiClient.dio.get('/admin/customers/$id');
      return Success(_mapDetail(response.data as Map<String, dynamic>));
    } catch (e) {
      return Err(_handleError(e, 'Failed to load customer'));
    }
  }

  @override
  Future<Result<CustomerDetail>> updateCustomerStatus(
    String id, {
    required bool isActive,
  }) async {
    try {
      final response = await _apiClient.dio.patch(
        '/admin/customers/$id/status',
        data: {'isActive': isActive},
      );
      return Success(_mapDetail(response.data as Map<String, dynamic>));
    } catch (e) {
      return Err(_handleError(e, 'Failed to update customer status'));
    }
  }
}
