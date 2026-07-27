import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';

class OrderSuccessScreen extends StatelessWidget {
  final Order order;

  const OrderSuccessScreen({super.key, required this.order});

  // Exact Design Tokens from Stitch Order Confirmed HTML
  static const Color surfaceBg = KZ.surface;
  static const Color primaryColor = KZ.primary;
  static const Color primaryContainerColor = KZ.primaryContainer;
  static const Color onSurfaceColor = KZ.onSurface;
  static const Color onSurfaceVariantColor = KZ.onSurfaceVariant;
  static const Color secondaryColor = KZ.secondary;
  static const Color surfaceContainerColor = KZ.surfaceContainer;
  static const Color tertiaryColor = KZ.tertiary;

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final otherItemsCount = order.items.length - 1;
    final itemTitle = firstItem != null
        ? (otherItemsCount > 0
              ? '${firstItem.name} & $otherItemsCount ${otherItemsCount == 1 ? 'order_success.item_other'.tr() : 'order_success.items_others'.tr()}'
              : firstItem.name)
        : 'order_success.default_meal_name'.tr();

    final orderNumDisplay = order.id.length >= 4
        ? '#${order.id.substring(order.id.length - 4)}'
        : '#${order.id}';

    final estimatedTimeDisplay = order.fulfillmentType == FulfillmentType.pickup
        ? 'order_success.pickup_eta'.tr()
        : 'order_success.delivery_eta'.tr();

    return Scaffold(
      backgroundColor: OrderSuccessScreen.surfaceBg,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'app_name'.tr(),
                        style: KZ.pageTitle.copyWith(color: OrderSuccessScreen.primaryColor),
                      ),
                      Semantics(
                        button: true,
                        label: 'common.back'.tr(),
                        child: InkWell(
                          onTap: () => context.go('/home'),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: KZ.iconTapTargetMin,
                            height: KZ.iconTapTargetMin,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: OrderSuccessScreen.surfaceContainerColor,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: OrderSuccessScreen.secondaryColor,
                              size: KZ.iconControl,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Body Content
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    children: [
                      const SizedBox(height: 10),

                      // Success Animation Hero Section
                      Column(
                        children: [
                          Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: OrderSuccessScreen.tertiaryColor
                                    .withValues(alpha: 0.2),
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 58,
                                height: 58,
                                decoration: const BoxDecoration(
                                  color: OrderSuccessScreen.tertiaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('order_success.title'.tr(), style: KZ.display.copyWith(fontSize: 28)),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'order_success.subtitle'.tr(),
                              textAlign: TextAlign.center,
                              style: KZ.bodyLarge.copyWith(color: OrderSuccessScreen.secondaryColor, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Bento Order Details Cards (Grid 2 columns + 1 full row)
                      Row(
                        children: [
                          // Order Number Card
                          Expanded(
                            child: KZCard(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                              child: Column(
                                children: [
                                  Text('order_success.order_number_label'.tr(), style: KZ.statusLabel.copyWith(color: OrderSuccessScreen.secondaryColor)),
                                  const SizedBox(height: 6),
                                  Text(orderNumDisplay, style: KZ.priceLarge),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Delivery Time Card
                          Expanded(
                            child: KZCard(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                              child: Column(
                                children: [
                                  Text('order_success.estimated_time_label'.tr(), style: KZ.statusLabel.copyWith(color: OrderSuccessScreen.secondaryColor)),
                                  const SizedBox(height: 6),
                                  Text(
                                    estimatedTimeDisplay,
                                    style: KZ.priceLarge.copyWith(color: OrderSuccessScreen.tertiaryColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Featured Dish Preview Card
                      KZCard(
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: OrderSuccessScreen.surfaceContainerColor,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child:
                                  (firstItem != null &&
                                      firstItem.imageUrl.isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: firstItem.imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: OrderSuccessScreen
                                            .surfaceContainerColor,
                                      ),
                                      errorWidget: (context, url, err) =>
                                          Container(
                                            color: OrderSuccessScreen
                                                .primaryColor
                                                .withValues(alpha: 0.1),
                                            child: const Icon(
                                              Icons.fastfood_rounded,
                                              color: OrderSuccessScreen
                                                  .primaryColor,
                                            ),
                                          ),
                                    )
                                  : Container(
                                      color: OrderSuccessScreen.primaryColor
                                          .withValues(alpha: 0.1),
                                      child: const Icon(
                                        Icons.fastfood_rounded,
                                        color: OrderSuccessScreen.primaryColor,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    itemTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: KZ.itemTitle,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'order_success.kitchen_location'.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: KZ.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Area Buttons
                      KZButton(
                        fullWidth: true,
                        pill: true,
                        icon: Icons.local_shipping_rounded,
                        label: 'order_success.track_order'.tr(),
                        onPressed: () {
                          context.push('/orders/tracking/${order.id}');
                        },
                      ),
                      const SizedBox(height: 12),
                      KZButton(
                        fullWidth: true,
                        pill: true,
                        variant: KZButtonVariant.tertiary,
                        icon: Icons.home_outlined,
                        label: 'order_success.back_to_home'.tr(),
                        onPressed: () {
                          context.go('/home');
                        },
                      ),
                      const SizedBox(height: 32),

                      // Points / Loyalty Rewards Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: OrderSuccessScreen.tertiaryColor.withValues(
                            alpha: 0.06,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: OrderSuccessScreen.tertiaryColor.withValues(
                              alpha: 0.15,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: OrderSuccessScreen.tertiaryColor
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.card_giftcard_rounded,
                                color: OrderSuccessScreen.tertiaryColor,
                                size: KZ.iconAction,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'order_success.earned_points_notice'.tr(
                                      namedArgs: {'points': '${order.loyaltyPointsEarned}'},
                                    ),
                                    style: KZ.bodyLarge.copyWith(fontWeight: FontWeight.w700, color: KZ.onSurface),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'order_success.earned_points_sub'.tr(),
                                    style: KZ.bodySmall.copyWith(height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Gradient Line Decoration
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    OrderSuccessScreen.primaryColor,
                    OrderSuccessScreen.primaryContainerColor,
                    OrderSuccessScreen.tertiaryColor,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
