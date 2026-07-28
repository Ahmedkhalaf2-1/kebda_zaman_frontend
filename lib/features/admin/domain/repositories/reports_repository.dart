import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/report_models.dart';

/// Admin analytics reports (PHASE_7_REPORTS_ANALYTICS_API_CONTRACT.md).
/// Every method is a read-only report view — no aggregation happens client
/// side, the backend is the sole source of truth for these numbers.
abstract class ReportsRepository {
  Future<Result<ReportsOverview>> getOverview({DateTime? from, DateTime? to});

  Future<Result<List<SalesPeriodPoint>>> getSales({
    DateTime? from,
    DateTime? to,
    required ReportGroupBy groupBy,
  });

  Future<Result<OrdersBreakdown>> getOrdersBreakdown({
    DateTime? from,
    DateTime? to,
  });

  Future<Result<List<TopSellingItem>>> getTopItems({
    DateTime? from,
    DateTime? to,
    int limit = 10,
  });
}
