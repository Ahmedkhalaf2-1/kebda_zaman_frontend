import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// `GET /admin/reports/overview` response
/// (PHASE_7_REPORTS_ANALYTICS_API_CONTRACT.md §1). All values come straight
/// from the backend — never recomputed client-side.
class ReportsOverview {
  final double totalRevenue;
  final int totalOrders;
  final int deliveredOrders;
  final int cancelledOrders;
  final double averageOrderValue;
  final int activeCustomers;
  final int newCustomers;
  final int deliveryOrders;
  final int pickupOrders;
  final int cashOrders;
  final int cardOrders;

  const ReportsOverview({
    required this.totalRevenue,
    required this.totalOrders,
    required this.deliveredOrders,
    required this.cancelledOrders,
    required this.averageOrderValue,
    required this.activeCustomers,
    required this.newCustomers,
    required this.deliveryOrders,
    required this.pickupOrders,
    required this.cashOrders,
    required this.cardOrders,
  });

  factory ReportsOverview.fromJson(Map<String, dynamic> json) {
    return ReportsOverview(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      deliveredOrders: (json['deliveredOrders'] as num?)?.toInt() ?? 0,
      cancelledOrders: (json['cancelledOrders'] as num?)?.toInt() ?? 0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0,
      activeCustomers: (json['activeCustomers'] as num?)?.toInt() ?? 0,
      newCustomers: (json['newCustomers'] as num?)?.toInt() ?? 0,
      deliveryOrders: (json['deliveryOrders'] as num?)?.toInt() ?? 0,
      pickupOrders: (json['pickupOrders'] as num?)?.toInt() ?? 0,
      cashOrders: (json['cashOrders'] as num?)?.toInt() ?? 0,
      cardOrders: (json['cardOrders'] as num?)?.toInt() ?? 0,
    );
  }
}

/// One bucket of `GET /admin/reports/sales` (§2) — the array itself arrives
/// ascending and gap-filled; never re-sort/interpolate it client-side.
class SalesPeriodPoint {
  final String period;
  final double revenue;
  final int orderCount;
  final int deliveredOrderCount;

  const SalesPeriodPoint({
    required this.period,
    required this.revenue,
    required this.orderCount,
    required this.deliveredOrderCount,
  });

  factory SalesPeriodPoint.fromJson(Map<String, dynamic> json) {
    return SalesPeriodPoint(
      period: json['period'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      orderCount: (json['orderCount'] as num?)?.toInt() ?? 0,
      deliveredOrderCount: (json['deliveredOrderCount'] as num?)?.toInt() ?? 0,
    );
  }
}

enum ReportGroupBy { day, week, month }

extension ReportGroupByApi on ReportGroupBy {
  String get apiValue => switch (this) {
    ReportGroupBy.day => 'day',
    ReportGroupBy.week => 'week',
    ReportGroupBy.month => 'month',
  };
}

/// One `{status, count}` / `{type, count}` / `{method, count}` row of
/// `GET /admin/reports/orders` (§3). Every known enum value is always
/// present with `count: 0`, so this is safe to index by enum without an
/// existence check.
class EnumCount<T> {
  final T key;
  final int count;

  const EnumCount({required this.key, required this.count});
}

class OrdersBreakdown {
  final List<EnumCount<OrderStatus>> byStatus;
  final List<EnumCount<FulfillmentType>> byFulfillmentType;
  final List<EnumCount<String>> byPaymentMethod;

  const OrdersBreakdown({
    required this.byStatus,
    required this.byFulfillmentType,
    required this.byPaymentMethod,
  });

  factory OrdersBreakdown.fromJson(Map<String, dynamic> json) {
    OrderStatus mapStatus(String s) => switch (s) {
      'PENDING' => OrderStatus.pending,
      'CONFIRMED' => OrderStatus.confirmed,
      'PREPARING' => OrderStatus.preparing,
      'OUT_FOR_DELIVERY' => OrderStatus.outForDelivery,
      'DELIVERED' => OrderStatus.delivered,
      'CANCELLED' => OrderStatus.cancelled,
      _ => OrderStatus.unknown,
    };
    FulfillmentType mapFulfillment(String s) =>
        s == 'PICKUP' ? FulfillmentType.pickup : FulfillmentType.delivery;

    final byStatusJson = (json['byStatus'] as List?) ?? const [];
    final byFulfillmentJson = (json['byFulfillmentType'] as List?) ?? const [];
    final byPaymentJson = (json['byPaymentMethod'] as List?) ?? const [];

    return OrdersBreakdown(
      byStatus: byStatusJson
          .map(
            (e) => EnumCount<OrderStatus>(
              key: mapStatus(e['status'] as String? ?? ''),
              count: (e['count'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList(),
      byFulfillmentType: byFulfillmentJson
          .map(
            (e) => EnumCount<FulfillmentType>(
              key: mapFulfillment(e['type'] as String? ?? ''),
              count: (e['count'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList(),
      byPaymentMethod: byPaymentJson
          .map(
            (e) => EnumCount<String>(
              key: e['method'] as String? ?? '',
              count: (e['count'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList(),
    );
  }
}

/// One row of `GET /admin/reports/top-items` (§4).
class TopSellingItem {
  final String menuItemId;
  final String nameAr;
  final String nameEn;
  final int quantitySold;
  final double revenue;

  const TopSellingItem({
    required this.menuItemId,
    required this.nameAr,
    required this.nameEn,
    required this.quantitySold,
    required this.revenue,
  });

  factory TopSellingItem.fromJson(Map<String, dynamic> json) {
    return TopSellingItem(
      menuItemId: json['menuItemId'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      quantitySold: (json['quantitySold'] as num?)?.toInt() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Combined result of all four report endpoints, loaded together by the
/// dashboard notifier for a single selected date range.
class ReportsDashboardData {
  final ReportsOverview overview;
  final List<SalesPeriodPoint> sales;
  final OrdersBreakdown ordersBreakdown;
  final List<TopSellingItem> topItems;

  const ReportsDashboardData({
    required this.overview,
    required this.sales,
    required this.ordersBreakdown,
    required this.topItems,
  });
}
