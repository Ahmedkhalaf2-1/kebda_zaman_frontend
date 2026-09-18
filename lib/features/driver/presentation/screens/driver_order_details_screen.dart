import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/core/utils/maps_launcher.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/driver/domain/models/driver_order.dart';
import 'package:kebda_zaman/features/driver/presentation/notifiers/driver_orders_notifier.dart';
import 'package:kebda_zaman/features/driver/presentation/widgets/driver_order_card.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Maps the backend's raw payment method string ('cash'/'card'/'wallet') to
/// a localized label — same convention as the admin order details screen's
/// `paymentMethodLabel`, kept as its own small copy here since the driver
/// feature has no dependency on the admin screen file.
String _driverPaymentMethodLabel(String method) {
  switch (method.toLowerCase()) {
    case 'cash':
      return 'admin.payment_cash'.tr();
    case 'card':
      return 'admin.payment_card'.tr();
    case 'wallet':
      return 'admin.payment_wallet'.tr();
    default:
      return method;
  }
}

class DriverOrderDetailsScreen extends ConsumerStatefulWidget {
  final String orderId;

  const DriverOrderDetailsScreen({super.key, required this.orderId});

  @override
  ConsumerState<DriverOrderDetailsScreen> createState() =>
      _DriverOrderDetailsScreenState();
}

class _DriverOrderDetailsScreenState
    extends ConsumerState<DriverOrderDetailsScreen> {
  bool _submitting = false;

  Future<void> _handlePickup() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final message = await ref
        .read(driverOrderDetailProvider(widget.orderId).notifier)
        .pickup();
    if (!mounted) return;
    setState(() => _submitting = false);
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _handleDelivered() async {
    if (_submitting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('driver_app.confirm_delivered_title'.tr()),
        content: Text('driver_app.confirm_delivered_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          KZButton(
            label: 'driver_app.action_delivered'.tr(),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    final message = await ref
        .read(driverOrderDetailProvider(widget.orderId).notifier)
        .delivered();
    if (!mounted) return;
    setState(() => _submitting = false);
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _callCustomer(String phone) async {
    final launched = await launchPhoneCall(phone);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('driver_app.call_unavailable'.tr())),
      );
    }
  }

  Future<void> _openDirections(double lat, double lng) async {
    final launched = await launchGoogleMapsDirections(lat, lng);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('admin.location_unavailable'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(driverOrderDetailProvider(widget.orderId));

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: AppBar(title: Text('driver_app.order_details_title'.tr())),
      body: orderAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: KZ.primary)),
        error: (e, st) => KZErrorState(
          message: 'common.something_wrong'.tr(),
          retryLabel: 'common.retry'.tr(),
          onRetry: () =>
              ref.invalidate(driverOrderDetailProvider(widget.orderId)),
        ),
        data: (order) => _buildDetails(context, order),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, DriverOrder order) {
    final address = order.deliveryAddress;
    final canNavigate = address?.hasValidCoordinates ?? false;
    final hasPhone =
        order.customerPhone != null && order.customerPhone!.trim().isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('#${order.orderNumber}', style: KZ.pageTitle),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: driverOrderStatusColor(
                  order.status,
                ).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                driverOrderStatusLabel(order.status),
                style: KZ.statusLabel.copyWith(
                  color: driverOrderStatusColor(order.status),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(formatOrderTimestamp(order.createdAt), style: KZ.caption),
        const SizedBox(height: 16),

        _SectionCard(
          title: 'driver_app.section_customer'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.customerName, style: KZ.itemTitle),
              if (hasPhone) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _callCustomer(order.customerPhone!),
                    icon: const Icon(Icons.call_rounded),
                    label: Text('driver_app.call_customer'.tr()),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        _SectionCard(
          title: 'admin.delivery_address'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (address != null && _hasAnyAddressText(address))
                ..._addressLines(address)
              else
                const Text('—', style: KZ.body),
              const SizedBox(height: 12),
              if (canNavigate)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _openDirections(address!.lat!, address.lng!),
                    icon: const Icon(Icons.directions_rounded),
                    label: Text('admin.open_in_maps'.tr()),
                  ),
                )
              else
                Text('admin.location_unavailable'.tr(), style: KZ.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 12),

        _SectionCard(
          title: 'driver_app.section_items'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: order.items.map((item) => _ItemRow(item: item)).toList(),
          ),
        ),
        const SizedBox(height: 12),

        _SectionCard(
          title: 'driver_app.section_payment'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PaymentRow(
                label: 'driver_app.payment_method'.tr(),
                value: _driverPaymentMethodLabel(order.paymentMethod),
              ),
              _PaymentRow(
                label: 'driver_app.payment_status'.tr(),
                value: order.paymentStatus,
              ),
              const Divider(height: 20),
              _PaymentRow(
                label: 'driver_app.amount_to_collect'.tr(),
                value: formatCurrency(
                  order.amountToCollect,
                  locale: context.locale,
                ),
                bold: true,
                highlight: order.amountToCollect > 0,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildActionButton(order),
      ],
    );
  }

  Widget _buildActionButton(DriverOrder order) {
    if (order.status == OrderStatus.preparing) {
      return KZButton(
        label: 'driver_app.action_pickup'.tr(),
        fullWidth: true,
        loading: _submitting,
        onPressed: _submitting ? null : _handlePickup,
      );
    }
    if (order.status == OrderStatus.outForDelivery) {
      return KZButton(
        label: 'driver_app.action_delivered'.tr(),
        fullWidth: true,
        loading: _submitting,
        onPressed: _submitting ? null : _handleDelivered,
      );
    }
    return const SizedBox.shrink();
  }

  bool _hasAnyAddressText(OrderDeliveryAddress address) {
    return [
      address.street,
      address.area,
      address.city,
      address.building,
      address.floor,
      address.apartment,
      address.notes,
    ].any((v) => v != null && v.trim().isNotEmpty);
  }

  List<Widget> _addressLines(OrderDeliveryAddress address) {
    final rows = <Widget>[];
    void addRow(String label, String? value) {
      if (value == null || value.trim().isEmpty) return;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text('$label: $value', style: KZ.body),
        ),
      );
    }

    addRow('admin.address_street'.tr(), address.street);
    addRow('admin.address_area'.tr(), address.area);
    addRow('admin.address_city'.tr(), address.city);
    addRow('admin.address_building'.tr(), address.building);
    addRow('admin.address_floor'.tr(), address.floor);
    addRow('admin.address_apartment'.tr(), address.apartment);
    addRow('admin.address_notes'.tr(), address.notes);
    return rows;
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
        color: KZ.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: KZ.caption.copyWith(
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

class _ItemRow extends StatelessWidget {
  final OrderItem item;

  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text('${item.quantity}x ${item.name}', style: KZ.body),
              ),
              Text(
                formatCurrency(item.lineTotal, locale: context.locale),
                style: KZ.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (item.specialInstructions.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(item.specialInstructions, style: KZ.caption),
            ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final bool highlight;

  const _PaymentRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: KZ.bodySmall.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: KZ.bodySmall.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: highlight ? KZ.primary : KZ.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
