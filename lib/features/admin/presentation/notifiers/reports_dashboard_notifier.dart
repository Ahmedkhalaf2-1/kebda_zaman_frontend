import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/admin/domain/models/report_models.dart';
import 'package:kebda_zaman/features/admin/domain/models/reports_filter.dart';

class ReportsFilterNotifier extends Notifier<ReportsFilter> {
  @override
  ReportsFilter build() => const ReportsFilter();

  void selectPreset(DateRangePreset preset) {
    state = state.copyWith(preset: preset);
  }

  void selectCustomRange(DateTime from, DateTime to) {
    state = state.copyWith(
      preset: DateRangePreset.custom,
      customFrom: from,
      customTo: to,
    );
  }

  void selectGroupBy(ReportGroupBy groupBy) {
    state = state.copyWith(groupBy: groupBy);
  }
}

final reportsFilterProvider =
    NotifierProvider<ReportsFilterNotifier, ReportsFilter>(
      ReportsFilterNotifier.new,
    );

/// Loads all four Phase 7 report endpoints together for the currently
/// selected date range/grouping. Rebuilds only when the filter actually
/// changes (not on unrelated widget rebuilds), and keeps the previous data
/// visible while a refresh is in flight.
class ReportsDashboardNotifier
    extends AutoDisposeAsyncNotifier<ReportsDashboardData> {
  @override
  Future<ReportsDashboardData> build() async {
    final filter = ref.watch(reportsFilterProvider);
    return _load(filter);
  }

  Future<ReportsDashboardData> _load(ReportsFilter filter) async {
    final repo = ref.read(reportsRepositoryProvider);
    final (from, to) = filter.resolvedRange();

    // Kick off all four requests concurrently, then await each in turn.
    final overviewFuture = repo.getOverview(from: from, to: to);
    final salesFuture = repo.getSales(
      from: from,
      to: to,
      groupBy: filter.groupBy,
    );
    final ordersFuture = repo.getOrdersBreakdown(from: from, to: to);
    final topItemsFuture = repo.getTopItems(from: from, to: to, limit: 10);

    final overviewResult = await overviewFuture;
    final salesResult = await salesFuture;
    final ordersResult = await ordersFuture;
    final topItemsResult = await topItemsFuture;

    return ReportsDashboardData(
      overview: overviewResult.fold((f) => throw f, (v) => v),
      sales: salesResult.fold((f) => throw f, (v) => v),
      ordersBreakdown: ordersResult.fold((f) => throw f, (v) => v),
      topItems: topItemsResult.fold((f) => throw f, (v) => v),
    );
  }

  Future<void> refresh() async {
    final filter = ref.read(reportsFilterProvider);
    state = const AsyncLoading<ReportsDashboardData>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _load(filter));
  }
}

final reportsDashboardProvider =
    AutoDisposeAsyncNotifierProvider<
      ReportsDashboardNotifier,
      ReportsDashboardData
    >(ReportsDashboardNotifier.new);
