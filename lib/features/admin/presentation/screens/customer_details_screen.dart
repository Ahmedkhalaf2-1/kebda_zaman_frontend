import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/admin/domain/models/customer_summary.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/customer_management_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/screens/admin_order_details_screen.dart'
    show paymentMethodLabel;
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

Color _statusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return KZ.error;
    case OrderStatus.confirmed:
      return const Color(0xFF00ACC1);
    case OrderStatus.preparing:
      return KZ.primaryContainer;
    case OrderStatus.outForDelivery:
      return Colors.blue;
    case OrderStatus.delivered:
      return KZ.tertiary;
    case OrderStatus.readyForPickup:
      return Colors.deepPurple.shade400;
    case OrderStatus.pickedUp:
      return KZ.tertiary;
    case OrderStatus.cancelled:
      return Colors.red.shade800;
    case OrderStatus.unknown:
      return Colors.grey.shade600;
  }
}

class CustomerDetailsScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailsScreen({super.key, required this.customerId});

  Future<void> _toggleActive(
    BuildContext context,
    WidgetRef ref,
    bool nextIsActive,
  ) async {
    final repo = ref.read(customerRepositoryProvider);
    final result = await repo.updateCustomerStatus(
      customerId,
      isActive: nextIsActive,
    );
    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('customers.error_generic'.tr())));
      },
      (detail) {
        ref.invalidate(customerDetailProvider(customerId));
        ref.invalidate(customerListProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nextIsActive
                  ? 'customers.activated_success'.tr()
                  : 'customers.deactivated_success'.tr(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(customerDetailProvider(customerId));

    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: KZ.primary),
        ),
        title: Text(
          'customers.details_title'.tr(),
          style: const TextStyle(
            color: KZ.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: detailAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: KZ.primary)),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                'common.something_wrong'.tr(),
                style: const TextStyle(color: KZ.onSurface),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: KZ.primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                onPressed: () =>
                    ref.invalidate(customerDetailProvider(customerId)),
                icon: const Icon(Icons.refresh),
                label: Text('common.retry'.tr()),
              ),
            ],
          ),
        ),
        data: (detail) => _buildDetail(context, ref, detail),
      ),
    );
  }

  Widget _buildDetail(
    BuildContext context,
    WidgetRef ref,
    CustomerDetail detail,
  ) {
    final customer = detail.summary;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: KZ.onSurface,
                          ),
                        ),
                      ),
                      if (customer.isGuest)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: KZ.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'customers.guest'.tr(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: KZ.secondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (customer.email != null)
                    Text(
                      customer.email!,
                      style: const TextStyle(fontSize: 13, color: KZ.secondary),
                    ),
                  if (customer.phone != null)
                    Text(
                      customer.phone!,
                      style: const TextStyle(fontSize: 13, color: KZ.secondary),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${'customers.customer_since'.tr()}: ${formatOrderTimestamp(customer.createdAt)}',
          style: const TextStyle(fontSize: 13, color: KZ.secondary),
        ),
        const SizedBox(height: 20),

        _SectionCard(
          title: 'customers.status'.tr(),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: (customer.isActive ? KZ.tertiary : KZ.error)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  customer.isActive
                      ? 'customers.active'.tr()
                      : 'customers.inactive'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: customer.isActive ? KZ.tertiary : KZ.error,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    _toggleActive(context, ref, !customer.isActive),
                child: Text(
                  customer.isActive
                      ? 'customers.deactivate'.tr()
                      : 'customers.activate'.tr(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'customers.orders'.tr(),
                value: '${customer.orderCount}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                label: 'customers.total_spent'.tr(),
                value: formatCurrency(
                  customer.totalSpent,
                  locale: context.locale,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        _SectionCard(
          title: 'customers.recent_orders'.tr(),
          child: detail.recentOrders.isEmpty
              ? Text(
                  'customers.no_recent_orders'.tr(),
                  style: const TextStyle(fontSize: 13, color: KZ.secondary),
                )
              : Column(
                  children: detail.recentOrders
                      .map((order) => _RecentOrderTile(order: order))
                      .toList(),
                ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: KZ.secondary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: KZ.secondary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: KZ.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  final RecentOrderSummary order;

  const _RecentOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${order.orderNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: KZ.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(
                          order.status,
                        ).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        order.status.name.toLowerCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(order.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${paymentMethodLabel(order.paymentMethod)} • '
                  '${order.fulfillmentType == FulfillmentType.pickup ? 'checkout.pickup'.tr() : 'checkout.delivery'.tr()} • '
                  '${formatOrderTimestamp(order.createdAt)}',
                  style: const TextStyle(fontSize: 12, color: KZ.secondary),
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(order.totalAmount, locale: context.locale),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: KZ.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
