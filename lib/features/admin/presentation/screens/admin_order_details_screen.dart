import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_order_details_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

class AdminOrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const AdminOrderDetailsScreen({super.key, required this.orderId});

  static const Color primaryColor = KZ.primary;
  static const Color surfaceBg = KZ.surface;
  static const Color onSurfaceColor = KZ.onSurface;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(adminOrderDetailsProvider(orderId));

    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: surfaceBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: primaryColor),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.w700),
        ),
      ),
      body: orderAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: primaryColor)),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Could not load this order',
                style: TextStyle(color: onSurfaceColor, fontSize: 14),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                onPressed: () =>
                    ref.invalidate(adminOrderDetailsProvider(orderId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (order) => _buildOrderDetails(order),
      ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '#${order.orderNumber}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: onSurfaceColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.status.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          formatOrderTimestamp(order.placedAt),
          style: const TextStyle(fontSize: 13, color: KZ.secondary),
        ),
        const SizedBox(height: 20),

        _buildSectionCard(
          title: 'Customer',
          child: Text(
            order.customerName?.isNotEmpty == true
                ? order.customerName!
                : order.userId,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: onSurfaceColor,
            ),
          ),
        ),
        const SizedBox(height: 12),

        _buildSectionCard(
          title: 'Fulfillment',
          child: Text(
            order.fulfillmentType == FulfillmentType.pickup
                ? 'Pickup${order.pickupLocation != null ? ' — ${order.pickupLocation}' : ''}'
                : 'Delivery',
            style: const TextStyle(fontSize: 15, color: onSurfaceColor),
          ),
        ),
        const SizedBox(height: 12),

        _buildSectionCard(
          title: 'Items',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: order.items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.name}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: onSurfaceColor,
                            ),
                          ),
                        ),
                        Text(
                          '${item.lineTotal.toStringAsFixed(0)} EGP',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 12),

        _buildSectionCard(
          title: 'Payment',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalRow('Subtotal', order.subtotal),
              if (order.deliveryFee > 0)
                _buildTotalRow('Delivery Fee', order.deliveryFee),
              if (order.discountTotal > 0)
                _buildTotalRow('Discount', -order.discountTotal),
              const Divider(height: 20),
              _buildTotalRow('Total', order.grandTotal, bold: true),
              if (order.paymentStatus != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Payment status: ${order.paymentStatus}',
                  style: const TextStyle(fontSize: 13, color: KZ.secondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? onSurfaceColor : KZ.secondary,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(0)} EGP',
            style: TextStyle(
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? onSurfaceColor : KZ.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
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
              fontSize: 12,
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
