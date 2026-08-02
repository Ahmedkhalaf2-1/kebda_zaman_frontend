import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_order_notification_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/order_management_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
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

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(orderManagementProvider);

    return Scaffold(
      backgroundColor: KZ.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top AppBar
            _buildAppBar(),

            // Segmented Control Tabs
            _buildSegmentedTabs(),

            // Order List Section
            Expanded(
              child: stateAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: KZ.primary),
                ),
                error: (e, st) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Could not load orders',
                        style: TextStyle(color: KZ.onSurface, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KZ.primary,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () => ref
                            .read(orderManagementProvider.notifier)
                            .refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
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
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'orders.no_orders'.tr(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return _buildOrderCard(context, order);
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(color: KZ.surface),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: KZ.primary,
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'app_name'.tr(),
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: KZ.primary,
                ),
              ),
            ],
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => context.push('/admin/order-notifications'),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: KZ.primary,
                  size: 26,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: KZ.surfaceContainerLow,
                  shape: const CircleBorder(),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
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
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: KZ.surface, width: 1.5),
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

  Widget _buildSegmentedTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: KZ.surfaceContainerLow,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: KZ.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _buildTabButton('menu.all'.tr(), 'all'),
          _buildTabButton('admin.tab_new'.tr(), 'new'),
          _buildTabButton('admin.tab_active'.tr(), 'active'),
          _buildTabButton('admin.tab_history'.tr(), 'history'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    final isSelected = _selectedTab == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? KZ.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: KZ.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : KZ.secondary,
            ),
          ),
        ),
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

  Widget _buildOrderCard(BuildContext context, Order order) {
    final itemsSummary = order.items.map((i) => i.name).join(', ');
    final itemCount = order.items.fold(0, (sum, item) => sum + item.quantity);
    final timeStr = formatOrderTimestamp(order.placedAt);
    final thumbUrl =
        order.items.isNotEmpty && order.items.first.imageUrl.isNotEmpty
        ? order.items.first.imageUrl
        : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=80';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order number badge + status chip. The order number is the only
          // unbounded-length field here, so it is the one that shrinks
          // (Flexible + ellipsis) — the status chip must always stay fully
          // visible per the design requirements.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: KZ.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '#${order.orderNumber}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: KZ.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Current status badge pill — never shrunk/truncated.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _getStatusDotColor(order.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.name.toLowerCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _getStatusDotColor(order.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            order.customerName?.isNotEmpty == true
                ? order.customerName!
                : order.userId,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: KZ.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          // Price / item count / timestamp / payment method — a Wrap so
          // narrow phones fall onto a second line instead of overflowing.
          Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                formatCurrency(order.grandTotal, locale: context.locale),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: KZ.onSurface,
                ),
              ),
              Text(
                '$itemCount items • $timeStr',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: KZ.secondary,
                ),
              ),
              if (order.paymentMethod != null)
                Text(
                  paymentMethodLabel(order.paymentMethod),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: KZ.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Items Row
          const Text(
            'Items:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: KZ.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  thumbUrl,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 44,
                    height: 44,
                    color: KZ.surfaceContainerLow,
                    child: const Icon(Icons.restaurant, color: KZ.secondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  itemsSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: KZ.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          const Divider(height: 1, color: Color(0xFFE2DFE0)),
          const SizedBox(height: 12),

          // Update Status Section (Direct Chips Selector)
          const Text(
            'Update Status:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: KZ.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            // Only statuses valid for this order's fulfillment type are ever
            // shown — a Pickup order must never be offered
            // outForDelivery/delivered, and a Delivery order must never be
            // offered readyForPickup/pickedUp.
            children: _selectableStatuses(order.fulfillmentType).map((status) {
              final isSelected = order.status == status;
              final isLegal = order.status
                  .allowedNextStatuses(order.fulfillmentType)
                  .contains(status);
              final statusName = status.name.toUpperCase();

              return Opacity(
                opacity: (isSelected || isLegal) ? 1.0 : 0.4,
                child: ChoiceChip(
                  label: Text(statusName),
                  selected: isSelected,
                  showCheckmark: true,
                  checkmarkColor: KZ.primary,
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF390C00)
                        : const Color(0xFF474647),
                  ),
                  selectedColor: KZ.primaryFixed,
                  backgroundColor: KZ.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? KZ.primary : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  elevation: isSelected ? 1 : 0,
                  // Only legal transitions (per the backend's ALLOWED_TRANSITIONS table) are tappable —
                  // attempting an illegal one always fails server-side with 422 INVALID_STATUS_TRANSITION.
                  onSelected: !isLegal
                      ? null
                      : (selected) async {
                          if (selected && order.status != status) {
                            final error = await ref
                                .read(orderManagementProvider.notifier)
                                .updateOrderStatus(order.id, status);
                            if (error != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to update status: $error',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Every status the admin/cashier UI may ever present for an order of this
  /// fulfillment type — the normal in-progress/terminal sequence plus
  /// cancellation. Never includes the other fulfillment type's steps.
  List<OrderStatus> _selectableStatuses(FulfillmentType type) => [
    ...type.statusSequence,
    OrderStatus.cancelled,
  ];

  Color _getStatusDotColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return KZ.error; // Red (New)
      case OrderStatus.confirmed:
        return const Color(0xFF00ACC1); // Cyan (Confirmed)
      case OrderStatus.preparing:
        return KZ.primaryContainer; // Orange (Preparing)
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
}
