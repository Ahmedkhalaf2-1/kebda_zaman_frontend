import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/theme/kz_motion.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/domain/models/report_models.dart';
import 'package:kebda_zaman/features/admin/domain/models/reports_filter.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/reports_dashboard_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/kz_sales_chart.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Breakpoints shared by every responsive section on this screen.
const double _kMobileBreakpoint = 700;
const double _kDesktopBreakpoint = 1100;
const double _kMaxContentWidth = 1280;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(reportsDashboardProvider);
    final filter = ref.watch(reportsFilterProvider);

    Widget body;
    // Keyed by state kind only (not by data), so a background refresh that
    // keeps showing stale data (`isRefreshing`) never re-triggers this
    // fade — only the loading->content->error transition should animate.
    final String stateKey;
    if (asyncData.hasValue) {
      body = _DashboardContent(
        data: asyncData.value!,
        filter: filter,
        isRefreshing: asyncData.isLoading,
      );
      stateKey = 'data';
    } else if (asyncData.hasError) {
      body = KZErrorState(
        message: 'dashboard.failed_to_load'.tr(),
        onRetry: () => ref.read(reportsDashboardProvider.notifier).refresh(),
        retryLabel: 'common.retry'.tr(),
      );
      stateKey = 'error';
    } else {
      body = const Center(child: CircularProgressIndicator(color: KZ.primary));
      stateKey = 'loading';
    }

    return Scaffold(
      backgroundColor: KZ.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
            child: AnimatedSwitcher(
              duration: KZMotion.durationFor(context, KZMotion.standard),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: KeyedSubtree(key: ValueKey(stateKey), child: body),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  final ReportsDashboardData data;
  final ReportsFilter filter;
  final bool isRefreshing;

  const _DashboardContent({
    required this.data,
    required this.filter,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: KZ.primary,
      onRefresh: () => ref.read(reportsDashboardProvider.notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _DashboardHeader(filter: filter, isRefreshing: isRefreshing),
          const SizedBox(height: KZ.sp20),
          _DateRangeControls(filter: filter),
          const SizedBox(height: KZ.sp24),
          _SectionTitle('dashboard.primary_metrics'.tr()),
          const SizedBox(height: KZ.sp12),
          _KpiSection(overview: data.overview),
          const SizedBox(height: KZ.sp28),
          _SectionTitle('dashboard.sales_performance'.tr()),
          const SizedBox(height: KZ.sp12),
          _SalesPerformanceCard(sales: data.sales, groupBy: filter.groupBy),
          const SizedBox(height: KZ.sp28),
          _SectionTitle('dashboard.orders_operations'.tr()),
          const SizedBox(height: KZ.sp12),
          _OrdersOperationsSection(breakdown: data.ordersBreakdown),
          const SizedBox(height: KZ.sp28),
          _SectionTitle('dashboard.customer_insights'.tr()),
          const SizedBox(height: KZ.sp12),
          _CustomerInsightsCard(overview: data.overview),
          const SizedBox(height: KZ.sp28),
          _SectionTitle('dashboard.top_selling_items'.tr()),
          const SizedBox(height: KZ.sp12),
          _TopItemsSection(items: data.topItems),
          const SizedBox(height: KZ.sp32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: KZ.sectionTitle);
  }
}

// ─── 1. Header ────────────────────────────────────────────────────────────

class _DashboardHeader extends ConsumerWidget {
  final ReportsFilter filter;
  final bool isRefreshing;

  const _DashboardHeader({required this.filter, required this.isRefreshing});

  String _periodLabel() {
    switch (filter.preset) {
      case DateRangePreset.last7Days:
        return 'dashboard.last_7_days'.tr();
      case DateRangePreset.last30Days:
        return 'dashboard.last_30_days'.tr();
      case DateRangePreset.thisMonth:
        return 'dashboard.this_month'.tr();
      case DateRangePreset.custom:
        final (from, to) = filter.resolvedRange();
        return '${from.day}/${from.month} – ${to.day}/${to.month}/${to.year}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('dashboard.title'.tr(), style: KZ.pageTitle),
              const SizedBox(height: 2),
              Text('dashboard.subtitle'.tr(), style: KZ.bodySmall),
              const SizedBox(height: KZ.sp8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: KZ.sp10,
                  vertical: KZ.sp4,
                ),
                decoration: BoxDecoration(
                  color: KZ.primaryFixed.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(KZ.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.event_rounded,
                      size: KZ.iconInline,
                      color: KZ.primary,
                    ),
                    const SizedBox(width: KZ.sp4),
                    Text(
                      _periodLabel(),
                      style: KZ.label.copyWith(color: KZ.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: KZMotion.durationFor(context, KZMotion.fast),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: isRefreshing
              ? const Padding(
                  key: ValueKey('refreshing'),
                  padding: EdgeInsets.all(KZ.sp12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: KZ.primary,
                    ),
                  ),
                )
              : KZIconButton(
                  key: const ValueKey('idle'),
                  icon: Icons.refresh_rounded,
                  tooltip: 'dashboard.refresh'.tr(),
                  onPressed: () =>
                      ref.read(reportsDashboardProvider.notifier).refresh(),
                ),
        ),
      ],
    );
  }
}

// ─── 2. Date range controls ───────────────────────────────────────────────

class _DateRangeControls extends ConsumerWidget {
  final ReportsFilter filter;
  const _DateRangeControls({required this.filter});

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 6)),
        end: now,
      ),
    );
    if (picked == null) return;
    ref
        .read(reportsFilterProvider.notifier)
        .selectCustomRange(
          DateTime.utc(picked.start.year, picked.start.month, picked.start.day),
          DateTime.utc(picked.end.year, picked.end.month, picked.end.day),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(reportsFilterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: KZ.sp8,
          runSpacing: KZ.sp8,
          children: [
            KZChip(
              label: 'dashboard.last_7_days'.tr(),
              selected: filter.preset == DateRangePreset.last7Days,
              onTap: () => notifier.selectPreset(DateRangePreset.last7Days),
            ),
            KZChip(
              label: 'dashboard.last_30_days'.tr(),
              selected: filter.preset == DateRangePreset.last30Days,
              onTap: () => notifier.selectPreset(DateRangePreset.last30Days),
            ),
            KZChip(
              label: 'dashboard.this_month'.tr(),
              selected: filter.preset == DateRangePreset.thisMonth,
              onTap: () => notifier.selectPreset(DateRangePreset.thisMonth),
            ),
            KZChip(
              label: 'dashboard.custom_range'.tr(),
              selected: filter.preset == DateRangePreset.custom,
              icon: Icons.date_range_rounded,
              onTap: () => _pickCustomRange(context, ref),
            ),
          ],
        ),
        const SizedBox(height: KZ.sp12),
        Row(
          children: [
            Text('dashboard.group_by'.tr(), style: KZ.label),
            const SizedBox(width: KZ.sp10),
            Wrap(
              spacing: KZ.sp6,
              children: [
                _GroupByChip(
                  label: 'dashboard.group_day'.tr(),
                  value: ReportGroupBy.day,
                  filter: filter,
                  notifier: notifier,
                ),
                _GroupByChip(
                  label: 'dashboard.group_week'.tr(),
                  value: ReportGroupBy.week,
                  filter: filter,
                  notifier: notifier,
                ),
                _GroupByChip(
                  label: 'dashboard.group_month'.tr(),
                  value: ReportGroupBy.month,
                  filter: filter,
                  notifier: notifier,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _GroupByChip extends StatelessWidget {
  final String label;
  final ReportGroupBy value;
  final ReportsFilter filter;
  final ReportsFilterNotifier notifier;

  const _GroupByChip({
    required this.label,
    required this.value,
    required this.filter,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final selected = filter.groupBy == value;
    return Material(
      color: selected ? KZ.primary : KZ.surfaceContainerLow,
      borderRadius: BorderRadius.circular(KZ.radiusFull),
      child: InkWell(
        borderRadius: BorderRadius.circular(KZ.radiusFull),
        onTap: () => notifier.selectGroupBy(value),
        child: Container(
          constraints: const BoxConstraints(minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: KZ.sp12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: KZ.label.copyWith(
              color: selected ? Colors.white : KZ.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 3. Primary KPI cards ─────────────────────────────────────────────────

class _KpiSpec {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KpiSpec(this.label, this.value, this.icon, this.color);
}

class _KpiSection extends StatelessWidget {
  final ReportsOverview overview;
  const _KpiSection({required this.overview});

  @override
  Widget build(BuildContext context) {
    final primary = [
      _KpiSpec(
        'dashboard.total_revenue'.tr(),
        formatCurrency(overview.totalRevenue, locale: context.locale),
        Icons.payments_rounded,
        KZ.primary,
      ),
      _KpiSpec(
        'dashboard.total_orders'.tr(),
        '${overview.totalOrders}',
        Icons.shopping_basket_rounded,
        KZ.primaryContainer,
      ),
      _KpiSpec(
        'dashboard.average_order_value'.tr(),
        formatCurrency(overview.averageOrderValue, locale: context.locale),
        Icons.bar_chart_rounded,
        const Color(0xFF00838F),
      ),
      _KpiSpec(
        'dashboard.delivered_orders'.tr(),
        '${overview.deliveredOrders}',
        Icons.check_circle_rounded,
        KZ.tertiary,
      ),
    ];
    final secondary = [
      _KpiSpec(
        'dashboard.cancelled_orders'.tr(),
        '${overview.cancelledOrders}',
        Icons.cancel_rounded,
        KZ.error,
      ),
      _KpiSpec(
        'dashboard.new_customers'.tr(),
        '${overview.newCustomers}',
        Icons.person_add_alt_1_rounded,
        const Color(0xFF6A4DFF),
      ),
      _KpiSpec(
        'dashboard.active_customers'.tr(),
        '${overview.activeCustomers}',
        Icons.groups_rounded,
        const Color(0xFF00838F),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= _kDesktopBreakpoint
            ? 4
            : width >= _kMobileBreakpoint
            ? 2
            : width >= 380
            ? 2
            : 1;
        return Column(
          children: [
            _ResponsiveCardGrid(columns: columns, specs: primary),
            const SizedBox(height: KZ.sp12),
            _ResponsiveCardGrid(columns: columns, specs: secondary),
          ],
        );
      },
    );
  }
}

class _ResponsiveCardGrid extends StatelessWidget {
  final int columns;
  final List<_KpiSpec> specs;
  const _ResponsiveCardGrid({required this.columns, required this.specs});

  @override
  Widget build(BuildContext context) {
    const spacing = KZ.sp12;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: specs
              .map(
                (spec) => SizedBox(
                  width: itemWidth,
                  child: _KpiCard(spec: spec),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final _KpiSpec spec;
  const _KpiCard({required this.spec});

  @override
  Widget build(BuildContext context) {
    return KZCard(
      padding: const EdgeInsets.all(KZ.sp16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(KZ.sp8),
            decoration: BoxDecoration(
              color: spec.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(KZ.radiusMd),
            ),
            child: Icon(spec.icon, color: spec.color, size: KZ.iconControl),
          ),
          const SizedBox(height: KZ.sp12),
          Text(
            spec.label,
            style: KZ.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: KZ.sp4),
          Text(
            spec.value,
            style: KZ.display.copyWith(fontSize: 22),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── 4. Sales performance ──────────────────────────────────────────────────

class _SalesPerformanceCard extends StatelessWidget {
  final List<SalesPeriodPoint> sales;
  final ReportGroupBy groupBy;

  const _SalesPerformanceCard({required this.sales, required this.groupBy});

  @override
  Widget build(BuildContext context) {
    return KZCard(
      padding: const EdgeInsets.all(KZ.sp16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LegendDot(color: KZ.primary, label: 'dashboard.revenue'.tr()),
              const SizedBox(width: KZ.sp16),
              _LegendDot(
                color: KZ.primaryContainer,
                label: 'dashboard.orders_volume'.tr(),
              ),
            ],
          ),
          const SizedBox(height: KZ.sp12),
          if (sales.isEmpty)
            _InlineEmpty(message: 'dashboard.no_analytics_data'.tr())
          else
            KZSalesChart(points: sales, groupBy: groupBy),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: KZ.sp6),
        Text(label, style: KZ.bodySmall),
      ],
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  final String message;
  const _InlineEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.show_chart_rounded, size: 36, color: KZ.outline),
            const SizedBox(height: KZ.sp8),
            Text(message, style: KZ.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ─── 5. Orders & operations ────────────────────────────────────────────────

class _OrdersOperationsSection extends StatelessWidget {
  final OrdersBreakdown breakdown;
  const _OrdersOperationsSection({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _kMobileBreakpoint;
        final left = _OrderStatusCard(byStatus: breakdown.byStatus);
        final right = _OperationsMixCard(breakdown: breakdown);

        if (!isWide) {
          return Column(
            children: [
              left,
              const SizedBox(height: KZ.sp16),
              right,
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: left),
              const SizedBox(width: KZ.sp16),
              Expanded(child: right),
            ],
          ),
        );
      },
    );
  }
}

IconData _statusIcon(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return Icons.hourglass_top_rounded;
    case OrderStatus.confirmed:
      return Icons.fact_check_rounded;
    case OrderStatus.preparing:
      return Icons.soup_kitchen_rounded;
    case OrderStatus.outForDelivery:
      return Icons.local_shipping_rounded;
    case OrderStatus.delivered:
      return Icons.check_circle_rounded;
    case OrderStatus.cancelled:
      return Icons.cancel_rounded;
    case OrderStatus.unknown:
      return Icons.help_outline_rounded;
  }
}

Color _statusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return KZ.error;
    case OrderStatus.confirmed:
      return const Color(0xFF00ACC1);
    case OrderStatus.preparing:
      return KZ.primaryContainer;
    case OrderStatus.outForDelivery:
      return Colors.blue.shade700;
    case OrderStatus.delivered:
      return KZ.tertiary;
    case OrderStatus.cancelled:
      return Colors.grey.shade600;
    case OrderStatus.unknown:
      return Colors.grey.shade500;
  }
}

String _statusLabel(OrderStatus status) {
  final key = switch (status) {
    OrderStatus.pending => 'pending',
    OrderStatus.confirmed => 'confirmed',
    OrderStatus.preparing => 'preparing',
    OrderStatus.outForDelivery => 'out_for_delivery',
    OrderStatus.delivered => 'delivered',
    OrderStatus.cancelled => 'cancelled',
    OrderStatus.unknown => 'unknown',
  };
  return 'orders.status.$key'.tr();
}

class _OrderStatusCard extends StatelessWidget {
  final List<EnumCount<OrderStatus>> byStatus;
  const _OrderStatusCard({required this.byStatus});

  @override
  Widget build(BuildContext context) {
    final maxCount = byStatus
        .map((e) => e.count)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return KZCard(
      padding: const EdgeInsets.all(KZ.sp16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('dashboard.order_status_breakdown'.tr(), style: KZ.cardTitle),
          const SizedBox(height: KZ.sp14),
          for (final entry in byStatus) ...[
            _StatusProgressRow(
              icon: _statusIcon(entry.key),
              color: _statusColor(entry.key),
              label: _statusLabel(entry.key),
              count: entry.count,
              maxCount: maxCount,
            ),
            const SizedBox(height: KZ.sp10),
          ],
        ],
      ),
    );
  }
}

class _StatusProgressRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count;
  final int maxCount;

  const _StatusProgressRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxCount > 0 ? count / maxCount : 0.0;
    return Row(
      children: [
        Icon(icon, size: KZ.iconInline, color: color),
        const SizedBox(width: KZ.sp8),
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: KZ.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(KZ.radiusFull),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: KZ.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: KZ.sp8),
        SizedBox(
          width: 28,
          child: Text('$count', textAlign: TextAlign.end, style: KZ.label),
        ),
      ],
    );
  }
}

class _OperationsMixCard extends StatelessWidget {
  final OrdersBreakdown breakdown;
  const _OperationsMixCard({required this.breakdown});

  int _countFor(List<EnumCount<String>> list, String key) {
    return list.where((e) => e.key == key).fold<int>(0, (a, b) => a + b.count);
  }

  @override
  Widget build(BuildContext context) {
    final delivery = breakdown.byFulfillmentType
        .where((e) => e.key == FulfillmentType.delivery)
        .fold<int>(0, (a, b) => a + b.count);
    final pickup = breakdown.byFulfillmentType
        .where((e) => e.key == FulfillmentType.pickup)
        .fold<int>(0, (a, b) => a + b.count);
    final cash = _countFor(breakdown.byPaymentMethod, 'CASH');
    final card = _countFor(breakdown.byPaymentMethod, 'CARD');
    final wallet = _countFor(breakdown.byPaymentMethod, 'WALLET');
    final maxPayment = [
      cash,
      card,
      wallet,
    ].fold<int>(0, (a, b) => a > b ? a : b);

    return KZCard(
      padding: const EdgeInsets.all(KZ.sp16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('dashboard.operations_mix'.tr(), style: KZ.cardTitle),
          const SizedBox(height: KZ.sp14),
          Text('checkout.order_type'.tr(), style: KZ.bodySmall),
          const SizedBox(height: KZ.sp8),
          _SplitBar(
            leftLabel: 'checkout.delivery'.tr(),
            leftValue: delivery,
            leftColor: KZ.primary,
            rightLabel: 'checkout.pickup'.tr(),
            rightValue: pickup,
            rightColor: KZ.primaryContainer,
          ),
          const SizedBox(height: KZ.sp16),
          Text('checkout.payment_method'.tr(), style: KZ.bodySmall),
          const SizedBox(height: KZ.sp8),
          _StatusProgressRow(
            icon: Icons.payments_rounded,
            color: KZ.tertiary,
            label: 'admin.payment_cash'.tr(),
            count: cash,
            maxCount: maxPayment,
          ),
          const SizedBox(height: KZ.sp10),
          _StatusProgressRow(
            icon: Icons.credit_card_rounded,
            color: const Color(0xFF00ACC1),
            label: 'admin.payment_card'.tr(),
            count: card,
            maxCount: maxPayment,
          ),
          const SizedBox(height: KZ.sp10),
          _StatusProgressRow(
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFF6A4DFF),
            label: 'admin.payment_wallet'.tr(),
            count: wallet,
            maxCount: maxPayment,
          ),
        ],
      ),
    );
  }
}

class _SplitBar extends StatelessWidget {
  final String leftLabel;
  final int leftValue;
  final Color leftColor;
  final String rightLabel;
  final int rightValue;
  final Color rightColor;

  const _SplitBar({
    required this.leftLabel,
    required this.leftValue,
    required this.leftColor,
    required this.rightLabel,
    required this.rightValue,
    required this.rightColor,
  });

  @override
  Widget build(BuildContext context) {
    final total = leftValue + rightValue;
    final leftFlex = total > 0 ? leftValue : 1;
    final rightFlex = total > 0 ? rightValue : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(KZ.radiusFull),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                Expanded(
                  flex: leftFlex == 0 ? 1 : leftFlex,
                  child: Container(color: leftColor),
                ),
                Expanded(
                  flex: rightFlex == 0 ? 1 : rightFlex,
                  child: Container(color: rightColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: KZ.sp8),
        Row(
          children: [
            _LegendDot(color: leftColor, label: '$leftLabel · $leftValue'),
            const SizedBox(width: KZ.sp16),
            _LegendDot(color: rightColor, label: '$rightLabel · $rightValue'),
          ],
        ),
      ],
    );
  }
}

// ─── 6. Customer insights ───────────────────────────────────────────────────

class _CustomerInsightsCard extends StatelessWidget {
  final ReportsOverview overview;
  const _CustomerInsightsCard({required this.overview});

  @override
  Widget build(BuildContext context) {
    return KZCard(
      padding: const EdgeInsets.all(KZ.sp16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _kMobileBreakpoint;
          final active = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(KZ.sp10),
                    decoration: BoxDecoration(
                      color: KZ.primaryFixed.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.groups_rounded, color: KZ.primary),
                  ),
                  const SizedBox(width: KZ.sp12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${overview.activeCustomers}',
                          style: KZ.display.copyWith(fontSize: 26),
                        ),
                        Text(
                          'dashboard.active_customers'.tr(),
                          style: KZ.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
          final newC = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(KZ.sp10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A4DFF).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Color(0xFF6A4DFF),
                ),
              ),
              const SizedBox(width: KZ.sp12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${overview.newCustomers}',
                    style: KZ.display.copyWith(fontSize: 26),
                  ),
                  Text('dashboard.new_customers'.tr(), style: KZ.bodySmall),
                ],
              ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('dashboard.customer_insights'.tr(), style: KZ.cardTitle),
              const SizedBox(height: KZ.sp14),
              isWide
                  ? Row(
                      children: [
                        Expanded(child: active),
                        const SizedBox(width: KZ.sp20),
                        Expanded(child: newC),
                      ],
                    )
                  : Column(
                      children: [
                        active,
                        const SizedBox(height: KZ.sp16),
                        newC,
                      ],
                    ),
              const SizedBox(height: KZ.sp14),
              Text(
                'dashboard.customer_insights_summary'.tr(
                  namedArgs: {'count': '${overview.newCustomers}'},
                ),
                style: KZ.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── 7. Top-selling items ────────────────────────────────────────────────────

class _TopItemsSection extends StatelessWidget {
  final List<TopSellingItem> items;
  const _TopItemsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return KZCard(
        padding: const EdgeInsets.all(KZ.sp16),
        child: _InlineEmpty(message: 'dashboard.no_analytics_data'.tr()),
      );
    }

    final isArabic = context.locale.languageCode == 'ar';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _kMobileBreakpoint;
        return KZCard(
          padding: const EdgeInsets.all(KZ.sp16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _TopItemRow(
                  rank: i + 1,
                  item: items[i],
                  isArabic: isArabic,
                  isWide: isWide,
                ),
                if (i != items.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: KZ.sp8),
                    child: Divider(height: 1, color: KZ.outlineVariant),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TopItemRow extends StatelessWidget {
  final int rank;
  final TopSellingItem item;
  final bool isArabic;
  final bool isWide;

  const _TopItemRow({
    required this.rank,
    required this.item,
    required this.isArabic,
    required this.isWide,
  });

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFC9A227);
      case 2:
        return const Color(0xFF9AA0A6);
      case 3:
        return const Color(0xFFB5651D);
      default:
        return KZ.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = isArabic ? item.nameAr : item.nameEn;
    final rankBadge = Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: rank <= 3
            ? _rankColor.withValues(alpha: 0.15)
            : KZ.surfaceContainerLow,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$rank',
        style: KZ.label.copyWith(
          color: rank <= 3 ? _rankColor : KZ.onSurfaceVariant,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    if (isWide) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: KZ.sp4),
        child: Row(
          children: [
            rankBadge,
            const SizedBox(width: KZ.sp12),
            Expanded(
              flex: 4,
              child: Text(
                name,
                style: KZ.itemTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${item.quantitySold} ${'dashboard.quantity_sold'.tr()}',
                style: KZ.bodySmall,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                formatCurrency(item.revenue, locale: context.locale),
                textAlign: TextAlign.end,
                style: KZ.price,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KZ.sp4),
      child: Row(
        children: [
          rankBadge,
          const SizedBox(width: KZ.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: KZ.itemTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.quantitySold} ${'dashboard.quantity_sold'.tr()}',
                  style: KZ.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(item.revenue, locale: context.locale),
            style: KZ.price,
          ),
        ],
      ),
    );
  }
}
