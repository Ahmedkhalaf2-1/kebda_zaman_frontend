import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Icon + color + short label for an [OrderStatus] — the single source of
/// truth both Orders History's per-card badge and Order Tracking's status
/// indicator draw from, so "delivered" (for example) is the same green
/// icon/color/word in both places instead of two screens inventing their
/// own status language.
class OrderStatusVisual {
  final IconData icon;
  final Color color;
  final String label;

  const OrderStatusVisual({
    required this.icon,
    required this.color,
    required this.label,
  });
}

OrderStatusVisual orderStatusVisual(OrderStatus status) {
  switch (status) {
    case OrderStatus.pending:
      return OrderStatusVisual(
        icon: Icons.schedule_rounded,
        color: KZ.primary,
        label: 'orders.status.pending'.tr(),
      );
    case OrderStatus.confirmed:
      return OrderStatusVisual(
        icon: Icons.task_alt_rounded,
        color: KZ.primary,
        label: 'orders.status.confirmed'.tr(),
      );
    case OrderStatus.preparing:
      return OrderStatusVisual(
        icon: Icons.soup_kitchen_rounded,
        color: KZ.primary,
        label: 'orders.status.preparing'.tr(),
      );
    case OrderStatus.outForDelivery:
      return OrderStatusVisual(
        icon: Icons.delivery_dining_rounded,
        color: KZ.primary,
        label: 'orders.status.out_for_delivery'.tr(),
      );
    case OrderStatus.delivered:
      return OrderStatusVisual(
        icon: Icons.check_circle_rounded,
        color: KZ.tertiary,
        label: 'orders.status.delivered'.tr(),
      );
    case OrderStatus.readyForPickup:
      return OrderStatusVisual(
        icon: Icons.storefront_rounded,
        color: KZ.primary,
        label: 'tracking.step_ready_pickup'.tr(),
      );
    case OrderStatus.pickedUp:
      return OrderStatusVisual(
        icon: Icons.check_circle_rounded,
        color: KZ.tertiary,
        label: 'tracking.step_picked_up'.tr(),
      );
    case OrderStatus.cancelled:
      return OrderStatusVisual(
        icon: Icons.cancel_rounded,
        color: KZ.error,
        label: 'orders.status.cancelled'.tr(),
      );
    case OrderStatus.unknown:
      return OrderStatusVisual(
        icon: Icons.help_outline_rounded,
        color: KZ.onSurfaceVariant,
        label: 'orders.status.unknown'.tr(),
      );
  }
}

/// The admin-side status visual — a richer, more differentiated palette
/// than the customer-facing [orderStatusVisual] (admin triages many orders
/// at once and benefits from more color separation between states), but
/// still one single source of truth: Dashboard, Order Management, and
/// Customer Details all draw from this instead of each keeping its own
/// copy. Previously each screen had a near-identical private copy that had
/// drifted out of sync — most notably `cancelled` rendering as grey in two
/// of them and red in the third for the exact same status.
OrderStatusVisual adminOrderStatusVisual(OrderStatus status) {
  final key = switch (status) {
    OrderStatus.pending => 'pending',
    OrderStatus.confirmed => 'confirmed',
    OrderStatus.preparing => 'preparing',
    OrderStatus.outForDelivery => 'out_for_delivery',
    OrderStatus.delivered => 'delivered',
    OrderStatus.readyForPickup => 'ready_for_pickup',
    OrderStatus.pickedUp => 'picked_up',
    OrderStatus.cancelled => 'cancelled',
    OrderStatus.unknown => 'unknown',
  };
  final label = 'orders.status.$key'.tr();

  switch (status) {
    case OrderStatus.pending:
      return OrderStatusVisual(
        icon: Icons.hourglass_top_rounded,
        color: KZ.error,
        label: label,
      );
    case OrderStatus.confirmed:
      return OrderStatusVisual(
        icon: Icons.fact_check_rounded,
        color: const Color(0xFF00ACC1),
        label: label,
      );
    case OrderStatus.preparing:
      return OrderStatusVisual(
        icon: Icons.soup_kitchen_rounded,
        color: KZ.primaryContainer,
        label: label,
      );
    case OrderStatus.outForDelivery:
      return OrderStatusVisual(
        icon: Icons.local_shipping_rounded,
        color: Colors.blue.shade700,
        label: label,
      );
    case OrderStatus.delivered:
      return OrderStatusVisual(
        icon: Icons.check_circle_rounded,
        color: KZ.tertiary,
        label: label,
      );
    case OrderStatus.readyForPickup:
      return OrderStatusVisual(
        icon: Icons.storefront_rounded,
        color: Colors.deepPurple.shade400,
        label: label,
      );
    case OrderStatus.pickedUp:
      return OrderStatusVisual(
        icon: Icons.check_circle_rounded,
        color: KZ.tertiary,
        label: label,
      );
    case OrderStatus.cancelled:
      return OrderStatusVisual(
        icon: Icons.cancel_rounded,
        color: KZ.error,
        label: label,
      );
    case OrderStatus.unknown:
      return OrderStatusVisual(
        icon: Icons.help_outline_rounded,
        color: KZ.onSurfaceVariant,
        label: label,
      );
  }
}
