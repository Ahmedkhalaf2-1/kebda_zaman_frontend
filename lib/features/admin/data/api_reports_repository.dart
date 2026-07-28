import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/report_models.dart';
import 'package:kebda_zaman/features/admin/domain/models/reports_filter.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/reports_repository.dart';

class ApiReportsRepository implements ReportsRepository {
  final ApiClient _apiClient;

  ApiReportsRepository(this._apiClient);

  Failure _handleError(dynamic e, String defaultMsg) {
    if (e is DioException) {
      if (e.error is ApiException) {
        final apiEx = e.error as ApiException;
        return NetworkFailure(apiEx.message, apiEx);
      }
      return NetworkFailure(e.message ?? defaultMsg);
    }
    return UnknownFailure(e.toString());
  }

  Map<String, dynamic> _rangeParams(DateTime? from, DateTime? to) {
    return {
      if (from != null) 'from': formatUtcDateOnly(from),
      if (to != null) 'to': formatUtcDateOnly(to),
    };
  }

  @override
  Future<Result<ReportsOverview>> getOverview({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/admin/reports/overview',
        queryParameters: _rangeParams(from, to),
      );
      return Success(
        ReportsOverview.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to load dashboard overview'));
    }
  }

  @override
  Future<Result<List<SalesPeriodPoint>>> getSales({
    DateTime? from,
    DateTime? to,
    required ReportGroupBy groupBy,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/admin/reports/sales',
        queryParameters: {
          ..._rangeParams(from, to),
          'groupBy': groupBy.apiValue,
        },
      );
      final list = (response.data as List)
          .map((e) => SalesPeriodPoint.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Err(_handleError(e, 'Failed to load sales performance'));
    }
  }

  @override
  Future<Result<OrdersBreakdown>> getOrdersBreakdown({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/admin/reports/orders',
        queryParameters: _rangeParams(from, to),
      );
      return Success(
        OrdersBreakdown.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Err(_handleError(e, 'Failed to load orders breakdown'));
    }
  }

  @override
  Future<Result<List<TopSellingItem>>> getTopItems({
    DateTime? from,
    DateTime? to,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/admin/reports/top-items',
        queryParameters: {..._rangeParams(from, to), 'limit': limit},
      );
      final list = (response.data as List)
          .map((e) => TopSellingItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } catch (e) {
      return Err(_handleError(e, 'Failed to load top-selling items'));
    }
  }
}
