import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
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
import 'package:kebda_zaman/core/widgets/kz_order_status.dart';
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
  void deactivate() {
    // Leaving the tracking screen — the order list may now be showing a
    // stale status for this order (it only fetches once, this screen polls
    // live), so refresh it on the way out rather than leaving it stale
    // until the next manual pull-to-refresh. Done in deactivate() rather
    // than dispose(): `ref` is no longer safe to use for invalidate() once
    // dispose() runs (the element is already tearing down by then, which
    // asserts in debug/test builds), but deactivate() still runs while the
    // widget is a valid part of the tree.
    ref.invalidate(ordersProvider);
    super.deactivate();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
                      style: KZ.pageTitle.copyWith(
                        color: OrderTrackingScreen.primaryColor,
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
                      if (order.hasCrossMethodStatusMismatch) {
                        // Malformed cross-method data (should never happen
                        // with a well-formed backend response) — show a
                        // safe generic state rather than a misleading
                        // Delivery/Pickup timeline.
                        return _buildUnknownStatusState(context);
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
    final statusColor = orderStatusVisual(order.status).color;

    return ListView(
      key: const ValueKey('content'),
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      children: [
        // 1. Sleek Status Header — dot/text color matches the same
        // status→color language as Orders History's KZStatusBadge, so
        // "delivered" reads the same (green) in both places.
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: AnimatedSwitcher(
                    duration: KZMotion.durationFor(
                      context,
                      KZMotion.standard,
                    ),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      statusDescription,
                      key: ValueKey(order.status),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: KZ.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Order number — kept identifiable but not dominant, since real
        // order numbers can be long; a single ellipsized line rather than
        // a huge headline that could wrap or overflow.
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'orders.order_num'.tr(
                namedArgs: {'id': _orderDisplayId(order)},
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: KZ.sectionTitle.copyWith(
                fontSize: 20,
                color: OrderTrackingScreen.onSurfaceColor,
              ),
            ),
          ),
        ),
        // Fulfillment info — only real, already-known data (fulfillment
        // type + the delivery-address snapshot or pickup location already
        // on the order); grouped as one compact line, not a separate card.
        if (_fulfillmentSummary(order) != null) ...[
          const SizedBox(height: 6),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    order.fulfillmentType == FulfillmentType.pickup
                        ? Icons.storefront_rounded
                        : Icons.delivery_dining_rounded,
                    size: 14,
                    color: OrderTrackingScreen.secondaryColor,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _fulfillmentSummary(order)!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KZ.bodySmall.copyWith(
                        color: OrderTrackingScreen.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),

        // 2. Branded Status Card (no external image — offline-safe)
        _StatusBannerCard(order: order, onViewDetails: _scrollToSummary),
        const SizedBox(height: 28),

        // 3. Vertical Timeline Stepper
        Text(
          'tracking.tracking_status_title'.tr(),
          style: KZ.sectionTitle,
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
                          style: KZ.sectionTitle.copyWith(fontSize: 16),
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
              // Distance-based delivery pricing snapshot — nullable for
              // PICKUP and pre-migration orders; the route estimate captured
              // at checkout time, never the actual delivered time.
              if (order.fulfillmentType == FulfillmentType.delivery &&
                  order.deliveryDistanceKm != null) ...[
                const SizedBox(height: 6),
                priceRow(
                  'checkout.distance'.tr(),
                  '${order.deliveryDistanceKm!.toStringAsFixed(2)} km',
                ),
              ],
              if (order.fulfillmentType == FulfillmentType.delivery &&
                  order.deliveryDurationSeconds != null) ...[
                const SizedBox(height: 6),
                priceRow(
                  'checkout.estimated_time'.tr(),
                  '${(order.deliveryDurationSeconds! / 60).round()} min',
                ),
              ],
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

  /// One-line fulfillment summary from data the order already carries —
  /// the delivery-address snapshot for DELIVERY orders, or the pickup
  /// location for PICKUP orders. `null` when neither is available (older
  /// orders, or a snapshot that was never captured) rather than inventing
  /// placeholder text.
  String? _fulfillmentSummary(Order order) {
    if (order.fulfillmentType == FulfillmentType.pickup) {
      final loc = order.pickupLocation?.trim();
      return (loc != null && loc.isNotEmpty) ? loc : null;
    }
    final addr = order.deliveryAddress;
    if (addr == null) return null;
    final parts = <String>[
      if (addr.street != null && addr.street!.trim().isNotEmpty) addr.street!.trim(),
      if (addr.building != null && addr.building!.trim().isNotEmpty)
        addr.building!.trim(),
      if (addr.city != null && addr.city!.trim().isNotEmpty) addr.city!.trim(),
    ];
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  String _getStatusDescription(Order order) {
    // Defense against malformed cross-method data (e.g. a Pickup order
    // somehow carrying a Delivery-only status, or vice versa): show a safe
    // generic status presentation instead of pretending the mismatched
    // status fits this order's fulfillment type.
    if (order.hasCrossMethodStatusMismatch) {
      return 'tracking.status_desc_unknown'.tr();
    }
    switch (order.status) {
      case OrderStatus.pending:
        // Card orders are authorize-only: the restaurant hasn't accepted
        // the order (and the hold hasn't been captured) yet, even though
        // the payment itself already succeeded — say so explicitly rather
        // than the generic "order placed" copy, and never imply the order
        // is confirmed.
        if (order.paymentMethod == 'CARD' &&
            order.paymentStatus == 'AUTHORIZED') {
          return 'tracking.status_desc_pending_card_authorized'.tr();
        }
        return 'tracking.status_desc_pending'.tr();
      case OrderStatus.confirmed:
        return 'tracking.confirmed_msg'.tr();
      case OrderStatus.preparing:
        return 'tracking.step_preparing_subtitle'.tr();
      case OrderStatus.outForDelivery:
        return 'tracking.status_desc_out_for_delivery'.tr();
      case OrderStatus.delivered:
        return 'tracking.status_desc_delivered'.tr();
      case OrderStatus.readyForPickup:
        return 'tracking.status_desc_ready_pickup'.tr();
      case OrderStatus.pickedUp:
        return 'tracking.status_desc_picked_up'.tr();
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

  Widget _buildUnknownStatusState(BuildContext context) {
    return Center(
      key: const ValueKey('status_unavailable'),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: OrderTrackingScreen.secondaryColor.withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_outline_rounded,
                size: 64,
                color: OrderTrackingScreen.secondaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'tracking.status_unavailable_title'.tr(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: OrderTrackingScreen.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'tracking.status_desc_unknown'.tr(),
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

  Widget _buildStepIndicator(
    BuildContext context, {
    required _TrackingStepData step,
    required bool isActive,
    required bool isCompleted,
    required OrderStatus statusKey,
  }) {
    final lottieAsset = step.lottieAsset;
    if (lottieAsset != null) {
      // Once a step has been reached (active or already completed), its
      // animation keeps looping rather than freezing on the first frame —
      // only steps still ahead in the timeline are paused/dimmed.
      final isReached = isActive || isCompleted;
      final indicator = SizedBox(
        width: 48,
        height: 48,
        child: Opacity(
          opacity: isReached ? 1.0 : 0.4,
          child: Lottie.asset(
            lottieAsset,
            animate: isReached,
            repeat: isReached,
            fit: BoxFit.contain,
          ),
        ),
      );
      return isActive
          ? _ActiveStepEmphasis(statusKey: statusKey, child: indicator)
          : indicator;
    }

    if (isActive) {
      return _ActiveStepEmphasis(
        statusKey: statusKey,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: OrderTrackingScreen.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: OrderTrackingScreen.primaryColor.withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(step.icon, color: Colors.white, size: 16),
          ),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isCompleted
              ? OrderTrackingScreen.primaryColor
              : OrderTrackingScreen.surfaceContainerHighestColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          step.icon,
          color: isCompleted
              ? Colors.white
              : OrderTrackingScreen.secondaryColor.withValues(alpha: 0.6),
          size: 16,
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

    final timelineSteps = isPickup
        ? [
            _TrackingStepData(
              status: OrderStatus.pending,
              title: 'tracking.step_received'.tr(),
              subtitleFallback: 'tracking.status_desc_pending'.tr(),
              icon: Icons.check_rounded,
              lottieAsset: 'assets/lottie/received.json',
            ),
            _TrackingStepData(
              status: OrderStatus.confirmed,
              title: 'tracking.step_confirmed'.tr(),
              subtitleFallback: 'tracking.confirmed_msg'.tr(),
              icon: Icons.check_rounded,
              lottieAsset: 'assets/lottie/received.json',
            ),
            _TrackingStepData(
              status: OrderStatus.preparing,
              title: 'tracking.step_preparing'.tr(),
              subtitleFallback: 'tracking.step_preparing_subtitle'.tr(),
              icon: Icons.soup_kitchen_rounded,
              lottieAsset: 'assets/lottie/preparing_in_kitchen.json',
            ),
            _TrackingStepData(
              status: OrderStatus.readyForPickup,
              title: 'tracking.step_ready_pickup'.tr(),
              subtitleFallback: 'tracking.ready_pickup_subtitle'.tr(),
              icon: Icons.storefront_rounded,
              lottieAsset: 'assets/lottie/ready.json',
            ),
            _TrackingStepData(
              status: OrderStatus.pickedUp,
              title: 'tracking.step_picked_up'.tr(),
              subtitleFallback: 'tracking.picked_up_subtitle'.tr(),
              icon: Icons.check_circle_rounded,
              lottieAsset: 'assets/lottie/delivered.json',
            ),
          ]
        : [
            _TrackingStepData(
              status: OrderStatus.pending,
              title: 'tracking.step_received'.tr(),
              subtitleFallback: 'tracking.status_desc_pending'.tr(),
              icon: Icons.check_rounded,
              lottieAsset: 'assets/lottie/received.json',
            ),
            _TrackingStepData(
              status: OrderStatus.confirmed,
              title: 'tracking.step_confirmed'.tr(),
              subtitleFallback: 'tracking.confirmed_msg'.tr(),
              icon: Icons.check_rounded,
              lottieAsset: 'assets/lottie/received.json',
            ),
            _TrackingStepData(
              status: OrderStatus.preparing,
              title: 'tracking.step_preparing'.tr(),
              subtitleFallback: 'tracking.step_preparing_subtitle'.tr(),
              icon: Icons.soup_kitchen_rounded,
              lottieAsset: 'assets/lottie/preparing_in_kitchen.json',
            ),
            _TrackingStepData(
              status: OrderStatus.outForDelivery,
              title: 'tracking.step_delivery'.tr(),
              subtitleFallback: 'tracking.status_desc_out_for_delivery'.tr(),
              icon: Icons.delivery_dining_rounded,
              lottieAsset: 'assets/lottie/delivery_riding.json',
            ),
            _TrackingStepData(
              status: OrderStatus.delivered,
              title: 'tracking.step_delivered'.tr(),
              subtitleFallback: 'tracking.status_desc_delivered'.tr(),
              icon: Icons.home_outlined,
              lottieAsset: 'assets/lottie/delivered.json',
            ),
          ];

    final currentStepIndex = timelineSteps.indexWhere(
      (s) => s.status == order.status,
    );

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
                _buildStepIndicator(
                  context,
                  step: step,
                  isActive: isActive,
                  isCompleted: isCompleted,
                  statusKey: order.status,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: isCompleted
                        ? OrderTrackingScreen.primaryColor
                        : OrderTrackingScreen.outlineVariantColor.withValues(
                            alpha: 0.4,
                          ),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 12, bottom: isLast ? 0 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isActive || isCompleted
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: isActive || isCompleted
                            ? OrderTrackingScreen.onSurfaceColor
                            : OrderTrackingScreen.secondaryColor.withValues(
                                alpha: 0.7,
                              ),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: isActive
                            ? OrderTrackingScreen.onSurfaceVariantColor
                            : OrderTrackingScreen.secondaryColor.withValues(
                                alpha: 0.6,
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
}

class _TrackingStepData {
  final OrderStatus status;
  final String title;
  final String subtitleFallback;
  final IconData icon;
  final String? lottieAsset;

  _TrackingStepData({
    required this.status,
    required this.title,
    required this.subtitleFallback,
    required this.icon,
    this.lottieAsset,
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
        return Icons.delivery_dining_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.readyForPickup:
        return Icons.storefront_rounded;
      case OrderStatus.pickedUp:
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

    // A single flat, compact brand-colored row — progress (the timeline
    // below) is the actual focus of this screen; this card's job is just
    // to surface the current status icon + estimated arrival + a way to
    // jump to the summary, not to be a decorative hero. No rotated ghost
    // icon, no background blob — those never carried information.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrderTrackingScreen.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: OrderTrackingScreen.primaryColor.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_statusIcon(), color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'tracking.estimated_arrival'.tr(),
                  style: KZ.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  estimatedArrival ?? 'tracking.estimate_unavailable'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KZ.sectionTitle.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onViewDetails,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'tracking.view_details'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KZ.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
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
