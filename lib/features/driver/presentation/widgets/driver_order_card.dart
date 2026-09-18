import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/features/driver/domain/models/driver_order.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// A backend order status ('preparing', 'outForDelivery', ...) mapped to a
/// short localized driver-facing label — the app's [OrderStatus] enum names
/// aren't meant for display as-is.
String driverOrderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return 'driver_app.status_pending'.tr();
    case OrderStatus.confirmed:
      return 'driver_app.status_confirmed'.tr();
    case OrderStatus.preparing:
      return 'driver_app.status_preparing'.tr();
    case OrderStatus.outForDelivery:
      return 'driver_app.status_out_for_delivery'.tr();
    case OrderStatus.delivered:
      return 'driver_app.status_delivered'.tr();
    case OrderStatus.cancelled:
      return 'driver_app.status_cancelled'.tr();
    case OrderStatus.readyForPickup:
    case OrderStatus.pickedUp:
    case OrderStatus.unknown:
      return status.name;
  }
}

Color driverOrderStatusColor(OrderStatus status) {
  switch (status) {
    case OrderStatus.outForDelivery:
      return KZ.primary;
    case OrderStatus.delivered:
      return KZ.tertiary;
    case OrderStatus.cancelled:
      return KZ.error;
    default:
      return KZ.secondary;
  }
}

class DriverOrderCard extends StatelessWidget {
  final DriverOrder order;
  final VoidCallback onTap;

  const DriverOrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: KZ.sp10),
      decoration: BoxDecoration(
        color: KZ.surface,
        borderRadius: BorderRadius.circular(KZ.radiusMd),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KZ.sp14,
            vertical: KZ.sp12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.orderNumber}',
                      style: KZ.itemTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KZ.sp8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: driverOrderStatusColor(
                        order.status,
                      ).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(KZ.radiusSm),
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
              Text(
                order.customerName,
                style: KZ.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatOrderTimestamp(order.createdAt),
                    style: KZ.caption,
                  ),
                  if (order.amountToCollect > 0)
                    Text(
                      formatCurrency(
                        order.amountToCollect,
                        locale: context.locale,
                      ),
                      style: KZ.label.copyWith(
                        color: KZ.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
