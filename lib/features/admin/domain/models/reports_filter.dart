import 'package:kebda_zaman/features/admin/domain/models/report_models.dart';

enum DateRangePreset { last7Days, last30Days, thisMonth, custom }

/// Selected dashboard filters: which date-range preset (or explicit custom
/// range) and which sales-chart grouping is active. `from`/`to` are always
/// resolved as UTC-date-only instants, matching the backend contract's
/// UTC-explicit semantics (PHASE_7_REPORTS_ANALYTICS_API_CONTRACT.md).
class ReportsFilter {
  final DateRangePreset preset;
  final DateTime? customFrom;
  final DateTime? customTo;
  final ReportGroupBy groupBy;

  const ReportsFilter({
    this.preset = DateRangePreset.last7Days,
    this.customFrom,
    this.customTo,
    this.groupBy = ReportGroupBy.day,
  });

  ReportsFilter copyWith({
    DateRangePreset? preset,
    DateTime? customFrom,
    DateTime? customTo,
    ReportGroupBy? groupBy,
  }) {
    return ReportsFilter(
      preset: preset ?? this.preset,
      customFrom: customFrom ?? this.customFrom,
      customTo: customTo ?? this.customTo,
      groupBy: groupBy ?? this.groupBy,
    );
  }

  static DateTime _todayUtc() {
    final now = DateTime.now().toUtc();
    return DateTime.utc(now.year, now.month, now.day);
  }

  /// Resolves the active preset into concrete UTC date-only bounds. `to` is
  /// inclusive, matching the backend's day-boundary semantics.
  (DateTime from, DateTime to) resolvedRange() {
    final today = _todayUtc();
    switch (preset) {
      case DateRangePreset.last7Days:
        return (today.subtract(const Duration(days: 6)), today);
      case DateRangePreset.last30Days:
        return (today.subtract(const Duration(days: 29)), today);
      case DateRangePreset.thisMonth:
        return (DateTime.utc(today.year, today.month, 1), today);
      case DateRangePreset.custom:
        final from = customFrom ?? today.subtract(const Duration(days: 6));
        final to = customTo ?? today;
        return (from, to);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is ReportsFilter &&
      other.preset == preset &&
      other.customFrom == customFrom &&
      other.customTo == customTo &&
      other.groupBy == groupBy;

  @override
  int get hashCode => Object.hash(preset, customFrom, customTo, groupBy);
}

/// Formats a UTC date as the date-only `"YYYY-MM-DD"` string the backend
/// expects for `from`/`to` query params.
String formatUtcDateOnly(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
