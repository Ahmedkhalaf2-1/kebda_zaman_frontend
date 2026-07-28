import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import '../notifiers/orders_notifier.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/theme/kz_motion.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';

final orderTrackingProvider = StreamProvider.family<Order, String>((ref, id) {
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
    // Duration resolved before the delay (not inside the closure) so this
    // never reads `context` after an async gap.
    final scrollDuration = KZMotion.durationFor(context, KZMotion.emphasized);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: scrollDuration,
          curve: KZMotion.enterExit,
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
                    Semantics(
                      button: true,
                      label: 'common.back'.tr(),
                      child: InkWell(
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
                    ),
                    Text(
                      'app_name'.tr(),
                      style: const TextStyle(
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
                child: AnimatedSwitcher(
                  duration: KZMotion.durationFor(context, KZMotion.standard),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: streamAsync.when(
                    loading: () => const Center(
                      key: ValueKey('loading'),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          OrderTrackingScreen.primaryColor,
                        ),
                      ),
                    ),
                    error: (e, st) => KZErrorState(
                      key: const ValueKey('error'),
                      message: 'tracking.load_error'.tr(),
                      retryLabel: 'common.retry'.tr(),
                      onRetry: () =>
                          ref.invalidate(orderTrackingProvider(widget.orderId)),
                    ),
                    data: (order) {
                      if (order.status == OrderStatus.cancelled) {
                        return _buildCancelledState(context);
                      }
                      return _buildTrackingContent(context, order);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingContent(BuildContext context, Order order) {
    final statusDescription = _getStatusDescription(order);

    return ListView(
      key: const ValueKey('content'),
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // 1. Status Highlight Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'orders.order_num'.tr(namedArgs: {'id': _orderDisplayId(order)}),
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
                  child: AnimatedSwitcher(
                    duration: KZMotion.durationFor(context, KZMotion.standard),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      statusDescription,
                      key: ValueKey(order.status),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: OrderTrackingScreen.onSurfaceVariantColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 2. Branded Status Card (no external image — offline-safe)
        _StatusBannerCard(order: order, onViewDetails: _scrollToSummary),
        const SizedBox(height: 32),

        // 3. Vertical Timeline Stepper
        Text(
          'tracking.tracking_status_title'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: OrderTrackingScreen.onSurfaceColor,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        _buildVerticalTimeline(context, order),
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
              Semantics(
                button: true,
                label: 'cart.order_summary'.tr(),
                expanded: _isSummaryExpanded,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isSummaryExpanded = !_isSummaryExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'cart.order_summary'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: OrderTrackingScreen.onSurfaceColor,
                          ),
                        ),
                        AnimatedRotation(
                          turns: _isSummaryExpanded ? 0.5 : 0.0,
                          duration: KZMotion.durationFor(
                            context,
                            KZMotion.fast,
                          ),
                          curve: KZMotion.stateChange,
                          child: const Icon(
                            Icons.expand_more,
                            color: OrderTrackingScreen.onSurfaceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedSize(
                duration: KZMotion.durationFor(context, KZMotion.standard),
                curve: KZMotion.stateChange,
                alignment: Alignment.topCenter,
                child: _isSummaryExpanded
                    ? _buildOrderSummaryDetails(context, order)
                    : const SizedBox(width: double.infinity, height: 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildOrderSummaryDetails(BuildContext context, Order order) {
    final locale = context.locale;
    final hasDiscount = order.discountTotal > 0;

    Widget priceRow(
      String label,
      String value, {
      Color? color,
      bool bold = false,
    }) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: color ?? OrderTrackingScreen.secondaryColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: color ?? OrderTrackingScreen.secondaryColor,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        const Divider(
          height: 1,
          color: OrderTrackingScreen.outlineVariantColor,
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              OrderTrackingScreen.surfaceContainerHighestColor,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: item.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.imageUrl,
                                fit: BoxFit.cover,
                                fadeInDuration: KZMotion.durationFor(
                                  context,
                                  KZMotion.standard,
                                ),
                                fadeInCurve: KZMotion.enterExit,
                                errorWidget: (c, u, e) => const Icon(
                                  Icons.fastfood,
                                  color: OrderTrackingScreen.secondaryColor,
                                ),
                              )
                            : const Icon(
                                Icons.fastfood,
                                color: OrderTrackingScreen.secondaryColor,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: OrderTrackingScreen.onSurfaceColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'tracking.item_quantity'.tr(
                                namedArgs: {'qty': '${item.quantity}'},
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: OrderTrackingScreen.secondaryColor,
                              ),
                            ),
                            if (item.formattedConfiguration.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
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
                        formatCurrency(item.lineTotal, locale: locale),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: OrderTrackingScreen.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                height: 24,
                color: OrderTrackingScreen.outlineVariantColor,
              ),
              priceRow(
                'cart.subtotal'.tr(),
                formatCurrency(order.subtotal, locale: locale),
              ),
              const SizedBox(height: 6),
              priceRow(
                'cart.delivery_fee'.tr(),
                formatCurrency(order.deliveryFee, locale: locale),
              ),
              // No authoritative tax field on the Order model — omit the row
              // entirely rather than deriving a fake tax amount from
              // rounding differences.
              if (hasDiscount) ...[
                const SizedBox(height: 6),
                priceRow(
                  'cart.discount'.tr(),
                  '-${formatCurrency(order.discountTotal, locale: locale)}',
                  color: OrderTrackingScreen.tertiaryColor,
                  bold: true,
                ),
              ],
              const SizedBox(height: 10),
              priceRow(
                'cart.total'.tr(),
                formatCurrency(order.grandTotal, locale: locale),
                color: OrderTrackingScreen.primaryColor,
                bold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _orderDisplayId(Order order) {
    return order.orderNumber.isNotEmpty
        ? order.orderNumber
        : (order.id.length >= 8 ? order.id.substring(0, 8) : order.id);
  }

  String _getStatusDescription(Order order) {
    final isPickup = order.fulfillmentType == FulfillmentType.pickup;
    switch (order.status) {
      case OrderStatus.pending:
        return 'tracking.status_desc_pending'.tr();
      case OrderStatus.confirmed:
        return 'tracking.confirmed_msg'.tr();
      case OrderStatus.preparing:
        return 'tracking.step_preparing_subtitle'.tr();
      case OrderStatus.outForDelivery:
        return isPickup
            ? 'tracking.status_desc_ready_pickup'.tr()
            : 'tracking.status_desc_out_for_delivery'.tr();
      case OrderStatus.delivered:
        return isPickup
            ? 'tracking.status_desc_picked_up'.tr()
            : 'tracking.status_desc_delivered'.tr();
      case OrderStatus.cancelled:
        return 'tracking.status_desc_cancelled'.tr();
      case OrderStatus.unknown:
        return 'tracking.status_desc_unknown'.tr();
    }
  }

  Widget _buildCancelledState(BuildContext context) {
    return Center(
      key: const ValueKey('cancelled'),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: KZ.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cancel, size: 64, color: KZ.error),
            ),
            const SizedBox(height: 20),
            Text(
              'tracking.cancelled_title'.tr(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: OrderTrackingScreen.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'tracking.cancelled_message'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: OrderTrackingScreen.secondaryColor,
              ),
            ),
            const SizedBox(height: 24),
            KZButton(
              label: 'order_success.back_to_home'.tr(),
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalTimeline(BuildContext context, Order order) {
    final isPickup = order.fulfillmentType == FulfillmentType.pickup;

    DateTime? timestampForStatus(OrderStatus status) {
      for (final entry in order.statusHistory) {
        if (entry.status == status) return entry.timestamp;
      }
      return null;
    }

    String formatStepTime(DateTime dt) {
      final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '$hour12:$minute $period';
    }

    final timelineSteps = [
      _TrackingStepData(
        status: OrderStatus.pending,
        title: 'tracking.step_received'.tr(),
        subtitleFallback: 'tracking.status_desc_pending'.tr(),
        icon: Icons.check_rounded,
      ),
      _TrackingStepData(
        status: OrderStatus.confirmed,
        title: 'tracking.step_confirmed'.tr(),
        subtitleFallback: 'tracking.confirmed_msg'.tr(),
        icon: Icons.check_rounded,
      ),
      _TrackingStepData(
        status: OrderStatus.preparing,
        title: 'tracking.step_preparing'.tr(),
        subtitleFallback: 'tracking.step_preparing_subtitle'.tr(),
        icon: Icons.soup_kitchen_rounded,
      ),
      _TrackingStepData(
        status: OrderStatus.outForDelivery,
        title: isPickup
            ? 'tracking.step_ready_pickup'.tr()
            : 'tracking.step_delivery'.tr(),
        subtitleFallback: isPickup
            ? 'tracking.status_desc_ready_pickup'.tr()
            : 'tracking.status_desc_out_for_delivery'.tr(),
        icon: isPickup
            ? Icons.storefront_rounded
            : Icons.delivery_dining_rounded,
      ),
      _TrackingStepData(
        status: OrderStatus.delivered,
        title: isPickup
            ? 'tracking.step_picked_up'.tr()
            : 'tracking.step_delivered'.tr(),
        subtitleFallback: isPickup
            ? 'tracking.status_desc_picked_up'.tr()
            : 'tracking.status_desc_delivered'.tr(),
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
        final realTimestamp = timestampForStatus(step.status);
        final subtitle = realTimestamp != null
            ? formatStepTime(realTimestamp)
            : step.subtitleFallback;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                if (isActive)
                  _ActiveStepEmphasis(
                    statusKey: order.status,
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
                            ? OrderTrackingScreen.onSurfaceColor
                            : (isCompleted
                                  ? OrderTrackingScreen.primaryColor
                                  : OrderTrackingScreen.secondaryColor
                                        .withValues(alpha: 0.7)),
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
  final String subtitleFallback;
  final IconData icon;

  _TrackingStepData({
    required this.status,
    required this.title,
    required this.subtitleFallback,
    required this.icon,
  });
}

/// A branded, offline-safe status card — replaces the old hardcoded
/// Unsplash photo banner. Shows the current status icon, description, real
/// estimated time (or a neutral fallback, never a fabricated one), and the
/// existing "View Details" action.
class _StatusBannerCard extends StatelessWidget {
  final Order order;
  final VoidCallback onViewDetails;

  const _StatusBannerCard({required this.order, required this.onViewDetails});

  IconData _statusIcon() {
    switch (order.status) {
      case OrderStatus.pending:
        return Icons.receipt_long_rounded;
      case OrderStatus.confirmed:
        return Icons.task_alt_rounded;
      case OrderStatus.preparing:
        return Icons.soup_kitchen_rounded;
      case OrderStatus.outForDelivery:
        return order.fulfillmentType == FulfillmentType.pickup
            ? Icons.storefront_rounded
            : Icons.delivery_dining_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
      case OrderStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estimatedArrival = order.estimatedTime?.trim().isNotEmpty == true
        ? order.estimatedTime!.trim()
        : null;

    return Container(
      height: 190,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            OrderTrackingScreen.primaryColor,
            OrderTrackingScreen.primaryContainerColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_statusIcon(), color: Colors.white, size: 36),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'tracking.estimated_arrival'.tr(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      estimatedArrival ?? 'tracking.estimate_unavailable'.tr(),
                      style: TextStyle(
                        fontSize: estimatedArrival != null ? 26 : 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              KZPressableScale(
                child: InkWell(
                  onTap: onViewDetails,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'tracking.view_details'.tr(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One-time visual emphasis for the active timeline step — plays once when
/// the status actually changes (keyed by [statusKey]), then settles into a
/// static active treatment. Replaces the old continuously-looping pulse,
/// which is not appropriate as a permanent decorative animation.
class _ActiveStepEmphasis extends StatelessWidget {
  final OrderStatus statusKey;
  final Widget child;

  const _ActiveStepEmphasis({required this.statusKey, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(statusKey),
      tween: Tween(begin: 0.8, end: 1.0),
      duration: KZMotion.durationFor(context, KZMotion.emphasized),
      curve: KZMotion.successEmphasis,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: child,
    );
  }
}
