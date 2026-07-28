import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import '../notifiers/orders_notifier.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';

final orderTrackingProvider = StreamProvider.autoDispose.family<Order, String>((ref, id) {
  final repo = ref.read(orderRepositoryProvider);
  return repo.watchOrder(id);
});

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  static const Color surfaceBg = KZ.surface;
  static const Color primaryColor = KZ.primary;
  static const Color primaryContainerColor = KZ.primaryContainer;
  static const Color onSurfaceColor = KZ.onSurface;
  static const Color onSurfaceVariantColor = KZ.onSurfaceVariant;
  static const Color secondaryColor = KZ.secondary;
  static const Color tertiaryColor = KZ.tertiary;
  static const Color surfaceContainerColor = KZ.surfaceContainer;
  static const Color surfaceContainerLowColor = KZ.surfaceContainerLow;
  static const Color surfaceContainerHighestColor = KZ.surfaceContainerHigh;
  static const Color outlineVariantColor = KZ.outlineVariant;

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  bool _isSummaryExpanded = false;
  final ScrollController _scrollController = ScrollController();

  void _scrollToSummary() {
    setState(() {
      _isSummaryExpanded = true;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Leaving the tracking screen — the order list may now be showing a
    // stale status for this order (it only fetches once, this screen polls
    // live), so refresh it on the way out rather than leaving it stale
    // until the next manual pull-to-refresh.
    ref.invalidate(ordersProvider);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamAsync = ref.watch(orderTrackingProvider(widget.orderId));

    // Also refresh the list the moment a status change is actually observed
    // here, rather than waiting for the screen to be left.
    ref.listen<AsyncValue<Order>>(orderTrackingProvider(widget.orderId), (
      previous,
      next,
    ) {
      final previousStatus = previous?.valueOrNull?.status;
      final nextStatus = next.valueOrNull?.status;
      if (nextStatus != null && nextStatus != previousStatus) {
        ref.invalidate(ordersProvider);
      }
    });

    return Scaffold(
      backgroundColor: OrderTrackingScreen.surfaceBg,
      body: ResponsiveContainer(
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/orders');
                        }
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.arrow_back,
                          color: OrderTrackingScreen.primaryColor,
                          size: 24,
                        ),
                      ),
                    ),
                    const Text(
                      'Kebda Zaman',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: OrderTrackingScreen.primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OrderTrackingScreen.surfaceContainerColor,
                        border: Border.all(
                          color: OrderTrackingScreen.outlineVariantColor,
                          width: 1,
                        ),
                      ),
                      child: const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        child: Icon(
                          Icons.person,
                          color: OrderTrackingScreen.secondaryColor,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content Area
              Expanded(
                child: streamAsync.when(
                  skipError: true,
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        OrderTrackingScreen.primaryColor,
                      ),
                    ),
                  ),
                  error: (e, st) => Center(
                    child: Text(
                      'Error loading order: $e',
                      style: const TextStyle(
                        color: OrderTrackingScreen.secondaryColor,
                      ),
                    ),
                  ),
                  data: (order) {
                    if (order.status == OrderStatus.cancelled) {
                      return _buildCancelledState(context, order);
                    }

                    final statusDescription = _getStatusDescription(order);
                    final estimatedArrival =
                        order.estimatedTime ??
                        (order.fulfillmentType == FulfillmentType.pickup
                            ? '15-20 mins'
                            : '12:45 PM');

                    return ListView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      children: [
                        // 1. Status Highlight Header
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order.orderNumber.isNotEmpty ? order.orderNumber : (order.id.length >= 8 ? order.id.substring(0, 8) : order.id)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: OrderTrackingScreen.onSurfaceColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: OrderTrackingScreen.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    statusDescription,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: OrderTrackingScreen
                                          .onSurfaceVariantColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 2. Featured Status Banner Card
                        Container(
                          height: 190,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: OrderTrackingScreen.secondaryColor,
                                  ),
                                  errorWidget: (context, url, err) => Container(
                                    color: OrderTrackingScreen.primaryColor,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.85),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 20,
                                right: 20,
                                bottom: 16,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'ESTIMATED ARRIVAL',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          estimatedArrival,
                                          style: const TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            height: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: _scrollToSummary,
                                      borderRadius: BorderRadius.circular(999),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: OrderTrackingScreen
                                              .primaryContainerColor,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.2,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Text(
                                          'View Details',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 3. Vertical Timeline Stepper
                        const Text(
                          'Tracking Status',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: OrderTrackingScreen.onSurfaceColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildVerticalTimeline(order),
                        const SizedBox(height: 28),

                        // 4. Order Summary Collapsible Card
                        Container(
                          decoration: BoxDecoration(
                            color: OrderTrackingScreen.surfaceContainerLowColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: OrderTrackingScreen.outlineVariantColor,
                              width: 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _isSummaryExpanded = !_isSummaryExpanded;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Order Summary',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: OrderTrackingScreen
                                              .onSurfaceColor,
                                        ),
                                      ),
                                      AnimatedRotation(
                                        turns: _isSummaryExpanded ? 0.5 : 0.0,
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: const Icon(
                                          Icons.expand_more,
                                          color: OrderTrackingScreen
                                              .onSurfaceColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_isSummaryExpanded) ...[
                                const Divider(
                                  height: 1,
                                  color:
                                      OrderTrackingScreen.outlineVariantColor,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      ...order.items.map(
                                        (item) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 12,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 56,
                                                height: 56,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: OrderTrackingScreen
                                                      .surfaceContainerHighestColor,
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: item.imageUrl.isNotEmpty
                                                    ? CachedNetworkImage(
                                                        imageUrl: item.imageUrl,
                                                        fit: BoxFit.cover,
                                                        errorWidget:
                                                            (
                                                              c,
                                                              u,
                                                              e,
                                                            ) => const Icon(
                                                              Icons.fastfood,
                                                              color: OrderTrackingScreen
                                                                  .secondaryColor,
                                                            ),
                                                      )
                                                    : const Icon(
                                                        Icons.fastfood,
                                                        color:
                                                            OrderTrackingScreen
                                                                .secondaryColor,
                                                      ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.name,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color:
                                                            OrderTrackingScreen
                                                                .onSurfaceColor,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'Quantity: ${item.quantity}',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color:
                                                            OrderTrackingScreen
                                                                .secondaryColor,
                                                      ),
                                                    ),
                                                    if (item
                                                        .formattedConfiguration
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 2,
                                                            ),
                                                        child: Text(
                                                          item.formattedConfiguration,
                                                          style: const TextStyle(
                                                            fontSize: 11,
                                                            color: OrderTrackingScreen
                                                                .onSurfaceVariantColor,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                '${item.lineTotal.toStringAsFixed(0)} EGP',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: OrderTrackingScreen
                                                      .primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Divider(
                                        height: 24,
                                        color: OrderTrackingScreen
                                            .outlineVariantColor,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Subtotal',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: OrderTrackingScreen
                                                  .secondaryColor,
                                            ),
                                          ),
                                          Text(
                                            '${order.subtotal.toStringAsFixed(0)} EGP',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: OrderTrackingScreen
                                                  .secondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Delivery Fee',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: OrderTrackingScreen
                                                  .secondaryColor,
                                            ),
                                          ),
                                          Text(
                                            '${order.deliveryFee.toStringAsFixed(0)} EGP',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: OrderTrackingScreen
                                                  .secondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if ((order.grandTotal -
                                              (order.subtotal +
                                                  order.deliveryFee -
                                                  order.discountTotal)) >
                                          0.05) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Tax',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: OrderTrackingScreen
                                                    .secondaryColor,
                                              ),
                                            ),
                                            Text(
                                              '${(order.grandTotal - (order.subtotal + order.deliveryFee - order.discountTotal)).toStringAsFixed(0)} EGP',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: OrderTrackingScreen
                                                    .secondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (order.discountTotal > 0) ...[
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Discount',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: OrderTrackingScreen
                                                    .tertiaryColor,
                                              ),
                                            ),
                                            Text(
                                              '-${order.discountTotal.toStringAsFixed(0)} EGP',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: OrderTrackingScreen
                                                    .tertiaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: OrderTrackingScreen
                                                  .onSurfaceColor,
                                            ),
                                          ),
                                          Text(
                                            '${order.grandTotal.toStringAsFixed(0)} EGP',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: OrderTrackingScreen
                                                  .primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 5. Contact Support & Customer Care Section
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Support chat is connecting...',
                                    ),
                                    backgroundColor:
                                        OrderTrackingScreen.primaryColor,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: OrderTrackingScreen.secondaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.headset_mic,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Contact Support',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Need to change your order? ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: OrderTrackingScreen.secondaryColor,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Opening live chat with support...',
                                        ),
                                        backgroundColor:
                                            OrderTrackingScreen.primaryColor,
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Chat with us',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: OrderTrackingScreen.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusDescription(Order order) {
    switch (order.status) {
      case OrderStatus.pending:
        return 'Order placed! Waiting for restaurant confirmation';
      case OrderStatus.confirmed:
        return 'Order confirmed by Kebda Zaman!';
      case OrderStatus.preparing:
        return 'Chef is preparing your meal';
      case OrderStatus.outForDelivery:
        return 'Driver is on the way to your location';
      case OrderStatus.delivered:
        return order.fulfillmentType == FulfillmentType.pickup
            ? 'Order picked up successfully!'
            : 'Order delivered successfully. Enjoy your meal!';
      case OrderStatus.cancelled:
        return 'Order has been cancelled';
      case OrderStatus.unknown:
        return 'Order status unavailable — please contact support';
    }
  }

  Widget _buildCancelledState(BuildContext context, Order order) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel, size: 64, color: Colors.red),
            ),
            const SizedBox(height: 20),
            const Text(
              'Order Cancelled',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: OrderTrackingScreen.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unfortunately, this order has been cancelled by the restaurant.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: OrderTrackingScreen.secondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: OrderTrackingScreen.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalTimeline(Order order) {
    final isPickup = order.fulfillmentType == FulfillmentType.pickup;
    final timelineSteps = [
      _TrackingStepData(
        status: OrderStatus.pending,
        title: 'Order Placed',
        subtitle: '12:10 PM',
        icon: Icons.check_rounded,
      ),
      _TrackingStepData(
        status: OrderStatus.confirmed,
        title: 'Confirmed',
        subtitle: '12:12 PM',
        icon: Icons.check_rounded,
      ),
      _TrackingStepData(
        status: OrderStatus.preparing,
        title: 'Preparing',
        subtitle: 'Our chef is crafting your meal',
        icon: Icons.soup_kitchen_rounded,
      ),
      _TrackingStepData(
        status: OrderStatus.outForDelivery,
        title: isPickup ? 'Ready for Pickup' : 'Out for Delivery',
        subtitle: 'Expected soon',
        icon: isPickup
            ? Icons.storefront_rounded
            : Icons.delivery_dining_rounded,
      ),
      _TrackingStepData(
        status: OrderStatus.delivered,
        title: isPickup ? 'Picked Up' : 'Delivered',
        subtitle: 'Order completed',
        icon: Icons.home_outlined,
      ),
    ];

    final currentStepIndex = _getStepIndex(order.status);

    return Column(
      children: List.generate(timelineSteps.length, (index) {
        final step = timelineSteps[index];
        final isCompleted = index < currentStepIndex;
        final isActive = index == currentStepIndex;
        final isLast = index == timelineSteps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                if (isActive)
                  _PulseRing(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: OrderTrackingScreen.primaryColor,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: OrderTrackingScreen.primaryColor.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        step.icon,
                        color: OrderTrackingScreen.primaryColor,
                        size: 22,
                      ),
                    ),
                  )
                else if (isCompleted)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: OrderTrackingScreen.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: OrderTrackingScreen.primaryColor.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  )
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: OrderTrackingScreen.surfaceContainerHighestColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: OrderTrackingScreen.outlineVariantColor
                            .withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      step.icon,
                      color: OrderTrackingScreen.secondaryColor.withValues(
                        alpha: 0.7,
                      ),
                      size: 20,
                    ),
                  ),
                if (!isLast)
                  Container(
                    width: 2.5,
                    height: 44,
                    color: isCompleted
                        ? OrderTrackingScreen.primaryColor
                        : OrderTrackingScreen.outlineVariantColor,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isActive ? 18 : 16,
                        fontWeight: isActive || isCompleted
                            ? FontWeight.w800
                            : FontWeight.w700,
                        color: isActive
                            ? OrderTrackingScreen
                                  .onSurfaceColor // Extra bold slate-900 when active!
                            : (isCompleted
                                  ? OrderTrackingScreen
                                        .primaryColor // Heritage orange when completed!
                                  : OrderTrackingScreen.secondaryColor
                                        .withValues(alpha: 0.7)),
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.subtitle,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isActive ? 14 : 13,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isActive
                            ? OrderTrackingScreen.onSurfaceVariantColor
                            : OrderTrackingScreen.secondaryColor.withValues(
                                alpha: 0.7,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  int _getStepIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.outForDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return 0;
      case OrderStatus.unknown:
        return -1;
    }
  }
}

class _TrackingStepData {
  final OrderStatus status;
  final String title;
  final String subtitle;
  final IconData icon;

  _TrackingStepData({
    required this.status,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _PulseRing extends StatefulWidget {
  final Widget child;
  const _PulseRing({required this.child});

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (0.08 * _controller.value),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: OrderTrackingScreen.primaryColor.withValues(
                    alpha: 0.2 + (0.25 * _controller.value),
                  ),
                  blurRadius: 10 + (10 * _controller.value),
                  spreadRadius: 1 + (3 * _controller.value),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
