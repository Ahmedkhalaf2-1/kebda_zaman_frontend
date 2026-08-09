import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_order_notification_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/order_management_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/admin/presentation/screens/admin_order_details_screen.dart'
    show paymentMethodLabel;

class OrderManagementScreen extends ConsumerStatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  ConsumerState<OrderManagementScreen> createState() =>
      _OrderManagementScreenState();
}

class _OrderManagementScreenState extends ConsumerState<OrderManagementScreen> {
  String _selectedTab = 'all'; // 'all', 'new', 'active', 'history'

  // Guards against pushing the details route twice from a rapid double tap
  // on the same card (GoRouter has no built-in debounce for this).
  String? _navigatingToOrderId;

  void _openOrderDetails(BuildContext context, Order order) {
    if (_navigatingToOrderId == order.id) return;
    _navigatingToOrderId = order.id;
    debugPrint(
      '[OrderManagement] tapped orderId=${order.id} -> /admin/orders/${order.id}',
    );
    context.push('/admin/orders/${order.id}').whenComplete(() {
      if (mounted) _navigatingToOrderId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(orderManagementProvider);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: stateAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: KZ.primary),
                ),
                error: (e, st) => KZErrorState(
                  message: 'common.something_wrong'.tr(),
                  retryLabel: 'common.retry'.tr(),
                  onRetry: () =>
                      ref.read(orderManagementProvider.notifier).refresh(),
                ),
                data: (orders) {
                  final filteredOrders = _filterOrders(orders, _selectedTab);

                  if (filteredOrders.isEmpty) {
                    return RefreshIndicator(
                      color: KZ.primary,
                      onRefresh: () =>
                          ref.read(orderManagementProvider.notifier).refresh(),
                      child: ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: KZEmptyState(
                              icon: Icons.receipt_long_outlined,
                              title: 'orders.no_orders'.tr(),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: KZ.primary,
                    onRefresh: () =>
                        ref.read(orderManagementProvider.notifier).refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return _OrderCard(
                          order: order,
                          onOpen: () => _openOrderDetails(context, order),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quick Order creation modal')),
          );
        },
        backgroundColor: KZ.primaryContainer,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  /// Page title only — the Kebda Zaman brand mark already lives in the
  /// admin shell's sidebar/drawer, so repeating it here was redundant.
  /// Notification access stays, but visually secondary (plain muted icon,
  /// no filled circular chrome) rather than competing with the page title.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'admin.orders'.tr(),
              style: KZ.pageTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => context.push('/admin/order-notifications'),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: KZ.onSurfaceVariant,
                  size: 22,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Consumer(
                  builder: (context, ref, _) {
                    final unreadCount =
                        ref
                            .watch(adminUnreadNotificationCountProvider)
                            .valueOrNull ??
                        0;
                    if (unreadCount <= 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      decoration: BoxDecoration(
                        color: KZ.error,
                        borderRadius: BorderRadius.circular(KZ.radiusFull),
                        border: Border.all(color: KZ.surfaceContainerLow, width: 1.5),
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Status filter, reusing the same [KZChip] pill used for filters
  /// elsewhere in the admin panel (Dashboard's date-range presets) instead
  /// of a bespoke segmented control — one consistent "active filter" visual
  /// language across the app.
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Wrap(
        spacing: KZ.sp8,
        runSpacing: KZ.sp8,
        children: [
          KZChip(
            label: 'menu.all'.tr(),
            selected: _selectedTab == 'all',
            onTap: () => setState(() => _selectedTab = 'all'),
          ),
          KZChip(
            label: 'admin.tab_new'.tr(),
            selected: _selectedTab == 'new',
            onTap: () => setState(() => _selectedTab = 'new'),
          ),
          KZChip(
            label: 'admin.tab_active'.tr(),
            selected: _selectedTab == 'active',
            onTap: () => setState(() => _selectedTab = 'active'),
          ),
          KZChip(
            label: 'admin.tab_history'.tr(),
            selected: _selectedTab == 'history',
            onTap: () => setState(() => _selectedTab = 'history'),
          ),
        ],
      ),
    );
  }

  List<Order> _filterOrders(List<Order> orders, String tab) {
    if (tab == 'all') {
      return orders;
    } else if (tab == 'new') {
      return orders.where((o) => o.status == OrderStatus.pending).toList();
    } else if (tab == 'active') {
      return orders
          .where(
            (o) =>
                o.status == OrderStatus.confirmed ||
                o.status == OrderStatus.preparing ||
                o.status == OrderStatus.outForDelivery ||
                o.status == OrderStatus.readyForPickup,
          )
          .toList();
    } else {
      return orders.where((o) => o.status.isTerminal).toList();
    }
  }
}

/// icon/color/translated-label for a status — the single source of truth
/// this screen uses for both the status badge and the primary action's
/// label, so "what state is this order in" and "what does tapping the
/// button do" always agree.
class _StatusMeta {
  final IconData icon;
  final Color color;
  final String label;
  const _StatusMeta(this.icon, this.color, this.label);
}

_StatusMeta _statusMeta(OrderStatus status) {
  IconData icon;
  Color color;
  switch (status) {
    case OrderStatus.pending:
      icon = Icons.hourglass_top_rounded;
      color = KZ.error;
    case OrderStatus.confirmed:
      icon = Icons.fact_check_rounded;
      color = const Color(0xFF00ACC1);
    case OrderStatus.preparing:
      icon = Icons.soup_kitchen_rounded;
      color = KZ.primaryContainer;
    case OrderStatus.outForDelivery:
      icon = Icons.local_shipping_rounded;
      color = Colors.blue.shade700;
    case OrderStatus.delivered:
      icon = Icons.check_circle_rounded;
      color = KZ.tertiary;
    case OrderStatus.readyForPickup:
      icon = Icons.storefront_rounded;
      color = Colors.deepPurple.shade400;
    case OrderStatus.pickedUp:
      icon = Icons.check_circle_rounded;
      color = KZ.tertiary;
    case OrderStatus.cancelled:
      icon = Icons.cancel_rounded;
      color = Colors.grey.shade600;
    case OrderStatus.unknown:
      icon = Icons.help_outline_rounded;
      color = Colors.grey.shade500;
  }
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
  return _StatusMeta(icon, color, 'orders.status.$key'.tr());
}

/// One order, redesigned for fast scanning: order number + status up top,
/// customer/type/chevron next, then a compact price/time/payment meta line.
/// Non-terminal orders get exactly one primary action (advance to the next
/// legal status) plus a small secondary Cancel control — `allowedNextStatuses`
/// only ever returns {next, cancelled} or nothing, so this covers every
/// reachable transition without listing every possible status as a button.
class _OrderCard extends ConsumerWidget {
  final Order order;
  final VoidCallback onOpen;

  const _OrderCard({required this.order, required this.onOpen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeStr = formatOrderTimestamp(order.placedAt);
    final statusMeta = _statusMeta(order.status);
    final allowed = order.status.allowedNextStatuses(order.fulfillmentType);
    final nextCandidates = allowed.where((s) => s != OrderStatus.cancelled);
    final nextStatus = nextCandidates.isEmpty ? null : nextCandidates.first;
    final canCancel = allowed.contains(OrderStatus.cancelled);

    Future<void> updateStatus(OrderStatus status) async {
      final error = await ref
          .read(orderManagementProvider.notifier)
          .updateOrderStatus(order.id, status);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $error')),
        );
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: KZ.sp10),
      decoration: BoxDecoration(
        color: KZ.surface,
        borderRadius: BorderRadius.circular(KZ.radiusMd),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                KZ.sp12,
                KZ.sp10,
                KZ.sp12,
                KZ.sp10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // The order number is the only unbounded-length field
                      // here, so it's the one that shrinks — the status
                      // badge must always stay fully visible.
                      Flexible(
                        child: Text(
                          '#${order.orderNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: KZ.label.copyWith(color: KZ.secondary),
                        ),
                      ),
                      const Spacer(),
                      _StatusBadge(meta: statusMeta),
                    ],
                  ),
                  const SizedBox(height: KZ.sp6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.customerName?.isNotEmpty == true
                              ? order.customerName!
                              : order.userId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: KZ.itemTitle,
                        ),
                      ),
                      const SizedBox(width: KZ.sp8),
                      _FulfillmentTag(type: order.fulfillmentType),
                      const SizedBox(width: KZ.sp4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: KZ.outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: KZ.sp6),
                  Wrap(
                    spacing: KZ.sp10,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        formatCurrency(order.grandTotal, locale: context.locale),
                        style: KZ.price,
                      ),
                      Text(timeStr, style: KZ.bodySmall),
                      if (order.paymentMethod != null)
                        Text(
                          paymentMethodLabel(order.paymentMethod),
                          style: KZ.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (nextStatus != null || canCancel) ...[
            const Divider(height: 1, color: KZ.outlineVariant),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KZ.sp12,
                KZ.sp8,
                KZ.sp12,
                KZ.sp8,
              ),
              child: Row(
                children: [
                  if (nextStatus != null)
                    Expanded(
                      child: _PrimaryStatusAction(
                        label: _statusMeta(nextStatus).label,
                        onPressed: () => updateStatus(nextStatus),
                      ),
                    ),
                  if (nextStatus != null && canCancel)
                    const SizedBox(width: KZ.sp8),
                  if (canCancel)
                    _CancelAction(
                      onPressed: () => updateStatus(OrderStatus.cancelled),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _StatusMeta meta;
  const _StatusBadge({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: KZ.sp8, vertical: 3),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KZ.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 12, color: meta.color),
          const SizedBox(width: 4),
          Text(
            meta.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KZ.statusLabel.copyWith(color: meta.color),
          ),
        ],
      ),
    );
  }
}

class _FulfillmentTag extends StatelessWidget {
  final FulfillmentType type;
  const _FulfillmentTag({required this.type});

  @override
  Widget build(BuildContext context) {
    final isDelivery = type == FulfillmentType.delivery;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isDelivery
              ? Icons.local_shipping_outlined
              : Icons.storefront_outlined,
          size: 13,
          color: KZ.onSurfaceVariant,
        ),
        const SizedBox(width: 3),
        Text(
          isDelivery ? 'checkout.delivery'.tr() : 'checkout.pickup'.tr(),
          style: KZ.caption,
        ),
      ],
    );
  }
}

/// The one recommended next step, shown as a compact filled button — never
/// competes with the (smaller, outlined) Cancel control beside it.
class _PrimaryStatusAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryStatusAction({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: KZ.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: KZ.sp12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KZ.radiusSm),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: KZ.buttonLabel.copyWith(fontSize: 13),
        ),
      ),
    );
  }
}

class _CancelAction extends StatelessWidget {
  final VoidCallback onPressed;
  const _CancelAction({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      width: 34,
      child: IconButton(
        onPressed: onPressed,
        tooltip: 'orders.status.cancelled'.tr(),
        icon: const Icon(Icons.close_rounded, size: 18),
        style: IconButton.styleFrom(
          foregroundColor: KZ.secondary,
          backgroundColor: KZ.surfaceContainerLow,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KZ.radiusSm),
          ),
        ),
      ),
    );
  }
}
