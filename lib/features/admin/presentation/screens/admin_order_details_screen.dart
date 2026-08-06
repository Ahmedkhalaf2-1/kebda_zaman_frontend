import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_order_details_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/maps_launcher.dart';

/// Maps the backend's raw payment method string ('CASH'/'CARD'/'WALLET',
/// case-insensitive) to a localized display label, falling back to the raw
/// value for any method the app doesn't recognize yet.
String paymentMethodLabel(String? method) {
  switch (method?.toUpperCase()) {
    case 'CASH':
      return 'admin.payment_cash'.tr();
    case 'CARD':
      return 'admin.payment_card'.tr();
    case 'WALLET':
      return 'admin.payment_wallet'.tr();
    default:
      return method ?? '';
  }
}

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
        data: (order) => _buildOrderDetails(context, order),
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, Order order) {
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

        if (order.fulfillmentType == FulfillmentType.delivery) ...[
          _buildDeliveryAddressCard(
            context,
            order.deliveryAddress,
            distanceKm: order.deliveryDistanceKm,
            durationSeconds: order.deliveryDurationSeconds,
          ),
          const SizedBox(height: 12),
        ],

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
                          formatCurrency(
                            item.lineTotal,
                            locale: context.locale,
                          ),
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
              _buildTotalRow(context, 'Subtotal', order.subtotal),
              if (order.deliveryFee > 0)
                _buildTotalRow(context, 'Delivery Fee', order.deliveryFee),
              if (order.discountTotal > 0)
                _buildTotalRow(context, 'Discount', -order.discountTotal),
              const Divider(height: 20),
              _buildTotalRow(context, 'Total', order.grandTotal, bold: true),
              if (order.paymentMethod != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Payment method: ${paymentMethodLabel(order.paymentMethod)}',
                  style: const TextStyle(fontSize: 13, color: KZ.secondary),
                ),
              ],
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

  Widget _buildDeliveryAddressCard(
    BuildContext context,
    OrderDeliveryAddress? address, {
    double? distanceKm,
    int? durationSeconds,
  }) {
    final rows = <Widget?>[
      _buildAddressRow('admin.address_street'.tr(), address?.street),
      _buildAddressRow('admin.address_area'.tr(), address?.area),
      _buildAddressRow('admin.address_city'.tr(), address?.city),
      _buildAddressRow('admin.address_building'.tr(), address?.building),
      _buildAddressRow('admin.address_floor'.tr(), address?.floor),
      _buildAddressRow('admin.address_apartment'.tr(), address?.apartment),
      _buildAddressRow('admin.address_notes'.tr(), address?.notes),
      // Distance-based delivery pricing snapshot — nullable for PICKUP and
      // pre-migration orders; the route estimate captured at checkout time,
      // never the actual delivered time.
      if (distanceKm != null)
        _buildAddressRow(
          'admin.delivery_distance'.tr(),
          '${distanceKm.toStringAsFixed(2)} km',
        ),
      if (durationSeconds != null)
        _buildAddressRow(
          'admin.delivery_duration'.tr(),
          '${(durationSeconds / 60).round()} min',
        ),
    ].whereType<Widget>().toList();

    final canNavigate = address?.hasValidCoordinates ?? false;

    return _buildSectionCard(
      title: 'admin.delivery_address'.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rows.isNotEmpty)
            ...rows
          else
            const Text(
              '—',
              style: TextStyle(fontSize: 14, color: onSurfaceColor),
            ),
          const SizedBox(height: 12),
          if (canNavigate)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: const BorderSide(color: primaryColor),
                  shape: const StadiumBorder(),
                ),
                onPressed: () async {
                  final launched = await launchGoogleMapsDirections(
                    address!.lat!,
                    address.lng!,
                  );
                  if (!launched && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('admin.location_unavailable'.tr()),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.directions_rounded),
                label: Text('admin.open_in_maps'.tr()),
              ),
            )
          else
            Text(
              'admin.location_unavailable'.tr(),
              style: const TextStyle(fontSize: 13, color: KZ.secondary),
            ),
        ],
      ),
    );
  }

  Widget? _buildAddressRow(String label, String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: KZ.secondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: onSurfaceColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    double amount, {
    bool bold = false,
  }) {
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
            formatCurrency(amount, locale: context.locale),
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
