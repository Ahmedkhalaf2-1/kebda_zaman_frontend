import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/checkout_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/address_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/loyalty_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/models/address.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';

/// Fixed loyalty reward catalog — the backend has no `GET /me/loyalty/rewards`
/// endpoint, so this list must be duplicated client-side (see 02_API_REFERENCE.md
/// / 09_FRONTEND_INTEGRATION.md). Keep in sync with the backend's hardcoded catalog.
class _LoyaltyReward {
  final String id;
  final String name;
  final int pointsCost;
  final bool deliveryOnly;

  const _LoyaltyReward({
    required this.id,
    required this.name,
    required this.pointsCost,
    this.deliveryOnly = false,
  });
}

const List<_LoyaltyReward> _kLoyaltyRewards = [
  _LoyaltyReward(
    id: 'free-delivery',
    name: 'Free Delivery',
    pointsCost: 100,
    deliveryOnly: true,
  ),
  _LoyaltyReward(id: 'discount-10', name: '10 EGP Off', pointsCost: 150),
  _LoyaltyReward(id: 'discount-25', name: '25 EGP Off', pointsCost: 350),
];

/// Localized display name for a [_LoyaltyReward] — the reward catalog's
/// `name` field stays a stable English identifier (mirrors the backend's
/// hardcoded catalog), this maps it to the translated label shown on screen.
String _rewardDisplayName(String rewardId) {
  switch (rewardId) {
    case 'free-delivery':
      return 'checkout.reward_free_delivery'.tr();
    case 'discount-10':
      return 'checkout.reward_discount_10'.tr();
    case 'discount-25':
      return 'checkout.reward_discount_25'.tr();
    default:
      return rewardId;
  }
}

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  // Exact Design Tokens from Stitch Checkout HTML
  static const Color surfaceBg = KZ.surface;
  static const Color primaryColor = KZ.primary;
  static const Color primaryFixedColor = KZ.primaryFixed;
  static const Color onSurfaceColor = KZ.onSurface;
  static const Color onSurfaceVariantColor = KZ.onSurfaceVariant;
  static const Color secondaryColor = KZ.secondary;
  static const Color surfaceContainerColor = KZ.surfaceContainer;
  static const Color surfaceContainerLowColor = KZ.surfaceContainerLow;
  static const Color outlineVariantColor = KZ.outlineVariant;
  static const Color tertiaryColor = KZ.tertiary;
  static const Color errorColor = KZ.error;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _orderType = 'delivery'; // 'delivery' or 'pickup'
  int _selectedPaymentMethod = 0; // 0 = Cash on Delivery, 1 = Credit/Debit Card
  // Explicit address pick made in this checkout session via the address picker.
  // Falls back to the user's saved default address when null.
  String? _selectedAddressId;
  // Selected loyalty reward id, mutually exclusive with an applied promo code
  // (enforced below via `effectiveRewardId`, never both sent to the server).
  String? _selectedRewardId;

  /// Client-side preview of a reward's flat subtotal discount — mirrors the
  /// backend's exact rule (02_API_REFERENCE.md): capped at the subtotal.
  double _rewardSubtotalDiscount(String? rewardId, double subtotal) {
    switch (rewardId) {
      case 'discount-10':
        return subtotal < 10 ? subtotal : 10.0;
      case 'discount-25':
        return subtotal < 25 ? subtotal : 25.0;
      default:
        return 0.0;
    }
  }

  /// A promo already applied to the cart always wins over a locally-selected
  /// loyalty reward — mirrors the server's mutual-exclusivity rule and is the
  /// single source of truth both the Summary and the submit button use.
  String? _effectiveRewardId(Cart cart) {
    final hasPromoApplied =
        cart.promoCodeId != null && cart.promoCodeId!.isNotEmpty;
    return hasPromoApplied ? null : _selectedRewardId;
  }

  /// Live preview of delivery fee / discount / tax / grand total for the
  /// current order-type + promo/reward selection. The server always re-prices
  /// authoritatively at checkout — this only drives what's shown on screen.
  ({double deliveryFee, double discount, double tax, double grandTotal})
  _previewTotals(Cart cart) {
    final effectiveRewardId = _effectiveRewardId(cart);
    final rewardSubtotalDiscount = _rewardSubtotalDiscount(
      effectiveRewardId,
      cart.subtotal,
    );
    final rewardWaivesDelivery = effectiveRewardId == 'free-delivery';

    final baseDeliveryFee = _orderType == 'pickup' ? 0.0 : cart.deliveryFee;
    final deliveryFee = rewardWaivesDelivery ? 0.0 : baseDeliveryFee;
    final discount = cart.discountTotal + rewardSubtotalDiscount;

    final taxableBaseBefore = cart.subtotal - cart.discountTotal;
    final impliedTaxRate = taxableBaseBefore > 0
        ? cart.taxTotal / taxableBaseBefore
        : 0.0;
    final taxableBaseAfter = (cart.subtotal - discount).clamp(
      0.0,
      double.infinity,
    );
    final tax = taxableBaseAfter * impliedTaxRate;

    return (
      deliveryFee: deliveryFee,
      discount: discount,
      tax: tax,
      grandTotal: taxableBaseAfter + deliveryFee + tax,
    );
  }

  String _formatAddress(Address a) {
    final parts = <String>[
      a.street,
      a.building,
      if (a.floor != null && a.floor!.isNotEmpty)
        'addresses.floor_prefix'.tr(namedArgs: {'floor': a.floor!}),
      if (a.apartment != null && a.apartment!.isNotEmpty)
        'addresses.apartment_prefix'.tr(namedArgs: {'apartment': a.apartment!}),
      a.city,
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  /// Loyalty Rewards section — mutually exclusive with an applied cart promo
  /// code. Guests never see selectable rewards (403 GUEST_NOT_ELIGIBLE server-side)
  /// and are guided to sign in instead.
  Widget _buildLoyaltySection({
    required bool isGuest,
    required int pointsBalance,
    required bool hasPromoApplied,
    required String? promoCode,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: KZ.cardDecoration(color: Colors.white),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -16,
            bottom: -16,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: CheckoutScreen.secondaryColor.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.card_giftcard_rounded,
                    color: CheckoutScreen.secondaryColor,
                    size: KZ.iconControl,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'checkout.loyalty_rewards'.tr(),
                    style: KZ.labelLarge.copyWith(
                      color: CheckoutScreen.secondaryColor,
                      fontSize: 15,
                    ),
                  ),
                  if (!isGuest) ...[
                    const Spacer(),
                    Text(
                      'checkout.loyalty_points_suffix'.tr(
                        namedArgs: {'points': '$pointsBalance'},
                      ),
                      style: KZ.label.copyWith(
                        color: CheckoutScreen.secondaryColor,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              if (isGuest) ...[
                Text(
                  'checkout.guest_loyalty_notice'.tr(),
                  style: KZ.body.copyWith(
                    color: CheckoutScreen.onSurfaceVariantColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.push('/login'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CheckoutScreen.primaryColor,
                    side: const BorderSide(
                      color: CheckoutScreen.primaryColor,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'checkout.sign_in'.tr(),
                    style: KZ.labelLarge.copyWith(
                      color: CheckoutScreen.primaryColor,
                    ),
                  ),
                ),
              ] else if (hasPromoApplied) ...[
                Text(
                  'checkout.promo_blocks_loyalty'.tr(
                    namedArgs: {
                      'code': promoCode != null ? ' ($promoCode)' : '',
                    },
                  ),
                  style: KZ.bodySmall,
                ),
              ] else
                ..._kLoyaltyRewards.map((reward) {
                  final blockedForPickup =
                      reward.deliveryOnly && _orderType == 'pickup';
                  final insufficientPoints = pointsBalance < reward.pointsCost;
                  final disabled = blockedForPickup || insufficientPoints;
                  final isSelected = _selectedRewardId == reward.id;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Opacity(
                      opacity: disabled ? 0.45 : 1.0,
                      child: InkWell(
                        onTap: disabled
                            ? () {
                                final reason = blockedForPickup
                                    ? 'checkout.pickup_blocks_free_delivery'
                                          .tr()
                                    : 'checkout.reward_insufficient_points'
                                          .tr();
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(reason)));
                              }
                            : () => setState(
                                () => _selectedRewardId = isSelected
                                    ? null
                                    : reward.id,
                              ),
                        borderRadius: BorderRadius.circular(KZ.radiusMd),
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: KZ.iconTapTargetMin,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? CheckoutScreen.primaryFixedColor.withValues(
                                    alpha: 0.4,
                                  )
                                : CheckoutScreen.surfaceContainerLowColor,
                            borderRadius: BorderRadius.circular(KZ.radiusMd),
                            border: Border.all(
                              color: isSelected
                                  ? CheckoutScreen.primaryColor
                                  : CheckoutScreen.surfaceContainerColor,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: isSelected
                                    ? CheckoutScreen.primaryColor
                                    : CheckoutScreen.outlineVariantColor,
                                size: KZ.iconControl,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _rewardDisplayName(reward.id),
                                  style: KZ.itemTitle,
                                ),
                              ),
                              Text(
                                'checkout.loyalty_points_suffix'.tr(
                                  namedArgs: {'points': '${reward.pointsCost}'},
                                ),
                                style: KZ.label,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final addressState = ref.watch(addressNotifierProvider);
    final authState = ref.watch(authNotifierProvider);
    final isGuest = !authState.isLoggedIn || (authState.user?.isGuest ?? true);
    final loyaltyAsync = isGuest ? null : ref.watch(loyaltyProvider);
    final pointsBalance = loyaltyAsync?.valueOrNull?.account.pointsBalance ?? 0;
    Address? selectedAddress;
    if (_selectedAddressId != null) {
      for (final a in addressState.addresses) {
        if (a.id == _selectedAddressId) {
          selectedAddress = a;
          break;
        }
      }
    }
    final effectiveAddress = selectedAddress ?? addressState.defaultAddress;
    final displayAddress = effectiveAddress != null
        ? _formatAddress(effectiveAddress)
        : 'checkout.no_address_notice'.tr();

    ref.listen(checkoutProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          String message = 'checkout.checkout_failed_generic'.tr();
          bool guideToSignIn = false;

          final cause = error is Failure ? error.cause : null;
          if (cause is ApiException) {
            switch (cause.code) {
              case 'PROMO_AND_LOYALTY_MUTUALLY_EXCLUSIVE':
                message = 'checkout.promo_loyalty_exclusive_error'.tr();
                break;
              case 'GUEST_NOT_ELIGIBLE':
                message = 'checkout.guest_not_eligible_error'.tr();
                guideToSignIn = true;
                break;
              case 'INSUFFICIENT_POINTS':
                message = 'checkout.reward_insufficient_points'.tr();
                break;
              case 'REWARD_NOT_APPLICABLE':
                message = 'checkout.reward_not_applicable_error'.tr();
                break;
              default:
                message = cause.message;
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: CheckoutScreen.errorColor,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(20),
              action: guideToSignIn
                  ? SnackBarAction(
                      label: 'checkout.sign_in'.tr(),
                      textColor: Colors.white,
                      onPressed: () => context.push('/login'),
                    )
                  : null,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: CheckoutScreen.surfaceBg,
      body: ResponsiveContainer(
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
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
                            onTap: () => context.pop(),
                            customBorder: const CircleBorder(),
                            child: const SizedBox(
                              width: KZ.iconTapTargetMin,
                              height: KZ.iconTapTargetMin,
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: CheckoutScreen.onSurfaceColor,
                                size: KZ.iconAction,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          'checkout.title'.tr(),
                          style: KZ.pageTitle.copyWith(
                            color: CheckoutScreen.primaryColor,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CheckoutScreen.surfaceContainerColor,
                            border: Border.all(
                              color: CheckoutScreen.outlineVariantColor,
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: CheckoutScreen.secondaryColor,
                            size: KZ.iconControl,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Checkout Content
                  Expanded(
                    child: cartAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            CheckoutScreen.primaryColor,
                          ),
                        ),
                      ),
                      error: (e, st) => KZErrorState(
                        message: 'cart.load_error'.tr(),
                        retryLabel: 'home.retry'.tr(),
                        onRetry: () => ref.invalidate(cartProvider),
                      ),
                      data: (cart) {
                        if (cart == null || cart.items.isEmpty) {
                          return KZEmptyState(
                            icon: Icons.shopping_cart_outlined,
                            title: 'cart.empty'.tr(),
                            actionLabel: 'cart.browse_menu'.tr(),
                            onAction: () => context.go('/menu'),
                          );
                        }

                        // Promo (applied via the Cart screen) and a loyalty reward (selected
                        // here) are mutually exclusive — a promo already applied always wins
                        // and the reward selection is ignored/disabled until it's removed.
                        final hasPromoApplied =
                            cart.promoCodeId != null &&
                            cart.promoCodeId!.isNotEmpty;
                        final effectiveRewardId = _effectiveRewardId(cart);
                        final totals = _previewTotals(cart);
                        final effectiveDeliveryFee = totals.deliveryFee;
                        final totalDiscount = totals.discount;
                        final effectiveTax = totals.tax;
                        final grandTotal = totals.grandTotal;

                        return ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 180),
                          children: [
                            // 1. Order Type Toggle (Delivery vs Pickup)
                            Container(
                              height: 52,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: CheckoutScreen.surfaceContainerColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _orderType = 'delivery';
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        height: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: _orderType == 'delivery'
                                              ? CheckoutScreen.primaryColor
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: _orderType == 'delivery'
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.08,
                                                        ),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.delivery_dining_rounded,
                                              size: KZ.iconControl,
                                              color: _orderType == 'delivery'
                                                  ? Colors.white
                                                  : CheckoutScreen
                                                        .onSurfaceVariantColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'checkout.delivery'.tr(),
                                              style: KZ.labelLarge.copyWith(
                                                color: _orderType == 'delivery'
                                                    ? Colors.white
                                                    : CheckoutScreen
                                                          .onSurfaceVariantColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _orderType = 'pickup';
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        height: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: _orderType == 'pickup'
                                              ? CheckoutScreen.primaryColor
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: _orderType == 'pickup'
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.08,
                                                        ),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : [],
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.storefront_rounded,
                                              size: KZ.iconControl,
                                              color: _orderType == 'pickup'
                                                  ? Colors.white
                                                  : CheckoutScreen
                                                        .onSurfaceVariantColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'checkout.pickup'.tr(),
                                              style: KZ.labelLarge.copyWith(
                                                color: _orderType == 'pickup'
                                                    ? Colors.white
                                                    : CheckoutScreen
                                                          .onSurfaceVariantColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 2. Address & Time Group Cards
                            if (_orderType == 'delivery') ...[
                              KZCard(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.home_rounded,
                                              color:
                                                  CheckoutScreen.primaryColor,
                                              size: KZ.iconControl,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'checkout.delivery_address'.tr(),
                                              style: KZ.itemTitle.copyWith(
                                                color:
                                                    CheckoutScreen.primaryColor,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              _showAddressPicker(context),
                                          style: TextButton.styleFrom(
                                            minimumSize: const Size(
                                              0,
                                              KZ.iconTapTargetMin,
                                            ),
                                          ),
                                          child: Text(
                                            'checkout.change_address'.tr(),
                                            style: KZ.labelLarge.copyWith(
                                              color:
                                                  CheckoutScreen.primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      displayAddress,
                                      style: KZ.body.copyWith(
                                        color: CheckoutScreen
                                            .onSurfaceVariantColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // Estimated Arrival Card
                            KZCard(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: CheckoutScreen.primaryColor
                                          .withValues(alpha: 0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.schedule_rounded,
                                      color: CheckoutScreen.primaryColor,
                                      size: KZ.iconAction,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'checkout.estimated_arrival'.tr(),
                                        style: KZ.label.copyWith(
                                          fontSize: 12,
                                          letterSpacing: 0.5,
                                          color: CheckoutScreen
                                              .onSurfaceVariantColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _orderType == 'delivery'
                                            ? 'checkout.delivery_eta'.tr()
                                            : 'checkout.pickup_eta'.tr(),
                                        style: KZ.priceLarge.copyWith(
                                          fontSize: 24,
                                          color: CheckoutScreen.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 3. Payment Method Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'checkout.payment_method'.tr(),
                                  style: KZ.sectionTitle.copyWith(fontSize: 18),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(
                                      0,
                                      KZ.iconTapTargetMin,
                                    ),
                                  ),
                                  child: Text(
                                    'checkout.add_new'.tr(),
                                    style: KZ.labelLarge.copyWith(
                                      color: CheckoutScreen.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Payment Option 0: Digital Pay / Cash
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPaymentMethod = 0;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedPaymentMethod == 0
                                        ? CheckoutScreen.primaryColor
                                        : CheckoutScreen.surfaceContainerColor,
                                    width: _selectedPaymentMethod == 0 ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.04,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color:
                                                CheckoutScreen.onSurfaceColor,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.payments_rounded,
                                            color: Colors.white,
                                            size: KZ.iconAction,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'checkout.cash'.tr(),
                                              style: KZ.itemTitle.copyWith(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              'checkout.pay_upon_receipt'
                                                  .tr()
                                                  .toUpperCase(),
                                              style: KZ.bodySmall.copyWith(
                                                fontSize: 12,
                                                color: CheckoutScreen
                                                    .onSurfaceVariantColor,
                                                letterSpacing: -0.2,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    _selectedPaymentMethod == 0
                                        ? Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              color:
                                                  CheckoutScreen.primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          )
                                        : Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: CheckoutScreen
                                                    .outlineVariantColor,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Payment Option 1: Credit / Debit Card
                            // Disabled — the backend has no working card/wallet gateway
                            // (POST /payments/intent always returns 501 PAYMENT_PROVIDER_NOT_CONFIGURED
                            // for CARD/WALLET; only CASH settles end-to-end). See 01_PROJECT_OVERVIEW.md.
                            InkWell(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'checkout.card_coming_soon_notice'.tr(),
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Opacity(
                                opacity: 0.6,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: CheckoutScreen.surfaceContainerColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: CheckoutScreen.outlineVariantColor
                                          .withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: CheckoutScreen
                                                  .outlineVariantColor
                                                  .withValues(alpha: 0.4),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.credit_card_rounded,
                                              color: CheckoutScreen
                                                  .onSurfaceVariantColor,
                                              size: KZ.iconAction,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'checkout.card'.tr(),
                                                style: KZ.itemTitle.copyWith(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: CheckoutScreen
                                                      .onSurfaceVariantColor,
                                                ),
                                              ),
                                              Text(
                                                'checkout.coming_soon'
                                                    .tr()
                                                    .toUpperCase(),
                                                style: KZ.bodySmall.copyWith(
                                                  fontSize: 12,
                                                  color: CheckoutScreen
                                                      .onSurfaceVariantColor,
                                                  letterSpacing: -0.2,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: CheckoutScreen
                                                .outlineVariantColor,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 3.5 Loyalty Rewards Section — mutually exclusive with an applied promo code
                            _buildLoyaltySection(
                              isGuest: isGuest,
                              pointsBalance: pointsBalance,
                              hasPromoApplied: hasPromoApplied,
                              promoCode: cart.promoCodeId,
                            ),
                            const SizedBox(height: 24),

                            // 4. Summary Card matching Stitch HTML
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: CheckoutScreen.surfaceContainerLowColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: CheckoutScreen.outlineVariantColor
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'checkout.summary'.tr(),
                                    style: KZ.sectionTitle.copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'cart.subtotal'.tr(),
                                        style: KZ.bodyLarge,
                                      ),
                                      Text(
                                        '${cart.subtotal.toStringAsFixed(0)} ${'common.egp'.tr()}',
                                        style: KZ.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'cart.delivery_fee'.tr(),
                                        style: KZ.bodyLarge,
                                      ),
                                      Text(
                                        effectiveDeliveryFee == 0
                                            ? 'checkout.free'.tr().toUpperCase()
                                            : '${effectiveDeliveryFee.toStringAsFixed(0)} ${'common.egp'.tr()}',
                                        style: effectiveDeliveryFee == 0
                                            ? KZ.bodyLarge.copyWith(
                                                fontWeight: FontWeight.w800,
                                                color: CheckoutScreen
                                                    .tertiaryColor,
                                              )
                                            : KZ.bodyLarge.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                      ),
                                    ],
                                  ),
                                  if (effectiveTax > 0) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'common.tax'.tr(),
                                          style: KZ.bodyLarge,
                                        ),
                                        Text(
                                          '${effectiveTax.toStringAsFixed(0)} ${'common.egp'.tr()}',
                                          style: KZ.bodyLarge.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (totalDiscount > 0) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          effectiveRewardId != null
                                              ? 'checkout.loyalty_reward_label'
                                                    .tr()
                                              : 'cart.discount'.tr(),
                                          style: KZ.bodyLarge.copyWith(
                                            color: CheckoutScreen.errorColor,
                                          ),
                                        ),
                                        Text(
                                          '-${totalDiscount.toStringAsFixed(0)} ${'common.egp'.tr()}',
                                          style: KZ.body.copyWith(
                                            color: CheckoutScreen.errorColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      top: 16,
                                      bottom: 16,
                                    ),
                                    child: Divider(
                                      color: CheckoutScreen.outlineVariantColor,
                                      height: 1,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'checkout.total_label'.tr(),
                                        style: KZ.sectionTitle.copyWith(
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        '${grandTotal.toStringAsFixed(0)} ${'common.egp'.tr()}',
                                        style: KZ.priceLarge.copyWith(
                                          fontSize: 28,
                                          color: CheckoutScreen.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // 5. Applied Discount Banner — reflects the real applied promo or
                            // selected loyalty reward (mutually exclusive, at most one shown).
                            if (hasPromoApplied ||
                                effectiveRewardId != null) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: CheckoutScreen.onSurfaceColor,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.15,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            hasPromoApplied
                                                ? 'checkout.promo_applied_label'
                                                      .tr()
                                                : 'checkout.loyalty_reward_applied_label'
                                                      .tr(),
                                            style: KZ.label.copyWith(
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            hasPromoApplied
                                                ? cart.promoCodeId!
                                                : _rewardDisplayName(
                                                    effectiveRewardId!,
                                                  ),
                                            style: KZ.sectionTitle.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (hasPromoApplied) {
                                          ref
                                              .read(cartProvider.notifier)
                                              .removePromoCode()
                                              .catchError((Object e) {
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'checkout.promo_remove_failed'
                                                          .tr(),
                                                    ),
                                                  ),
                                                );
                                              });
                                        } else {
                                          setState(
                                            () => _selectedRewardId = null,
                                          );
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white70,
                                        minimumSize: const Size(
                                          0,
                                          KZ.iconTapTargetMin,
                                        ),
                                      ),
                                      child: Text('cart.remove'.tr()),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Fixed Actions Layer (Sticky Footer CTA)
            Consumer(
              builder: (context, ref, child) {
                final settingsAsync = ref.watch(restaurantSettingsProvider);
                final cart = cartAsync.valueOrNull;
                if (cart == null || cart.items.isEmpty)
                  return const SizedBox.shrink();

                final effectiveRewardId = _effectiveRewardId(cart);
                final grandTotal = _previewTotals(cart).grandTotal;

                return settingsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, st) => const SizedBox.shrink(),
                  data: (settings) {
                    final isBelowMinOrder =
                        cart.subtotal < settings.minOrderValue;
                    final remaining = (settings.minOrderValue - cart.subtotal)
                        .clamp(0.0, double.infinity);

                    return Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          16,
                          20,
                          MediaQuery.of(context).padding.bottom + 16,
                        ),
                        decoration: BoxDecoration(
                          color: CheckoutScreen.surfaceBg.withValues(
                            alpha: 0.95,
                          ),
                          border: Border(
                            top: BorderSide(
                              color: CheckoutScreen.outlineVariantColor
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, -6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!settings.isOpen)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'checkout.restaurant_closed'.tr(),
                                  style: KZ.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: CheckoutScreen.errorColor,
                                  ),
                                ),
                              )
                            else if (isBelowMinOrder)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'checkout.min_order_notice'.tr(
                                    namedArgs: {
                                      'remaining': remaining.toStringAsFixed(0),
                                      'min': settings.minOrderValue
                                          .toStringAsFixed(0),
                                    },
                                  ),
                                  style: KZ.body.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: CheckoutScreen.errorColor,
                                  ),
                                ),
                              ),
                            KZButton(
                              fullWidth: true,
                              pill: false,
                              loading: checkoutState.isLoading,
                              icon: Icons.arrow_forward_rounded,
                              label: 'checkout.place_order_total'.tr(
                                namedArgs: {
                                  'amount': grandTotal.toStringAsFixed(0),
                                },
                              ),
                              onPressed:
                                  (checkoutState.isLoading ||
                                      !settings.isOpen ||
                                      isBelowMinOrder)
                                  ? null
                                  : () async {
                                      final deliveryMethod =
                                          _orderType == 'delivery'
                                          ? FulfillmentType.delivery
                                          : FulfillmentType.pickup;
                                      final paymentMethod =
                                          _selectedPaymentMethod == 0
                                          ? 'CASH'
                                          : 'CARD';

                                      Map<String, dynamic>? deliveryAddress;
                                      if (deliveryMethod ==
                                          FulfillmentType.delivery) {
                                        if (effectiveAddress == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'checkout.address_required'
                                                    .tr(),
                                              ),
                                              backgroundColor:
                                                  CheckoutScreen.errorColor,
                                            ),
                                          );
                                          return;
                                        }
                                        deliveryAddress = {
                                          'title': effectiveAddress.label,
                                          'street': effectiveAddress.street,
                                          'building': effectiveAddress.building,
                                          if (effectiveAddress.floor != null &&
                                              effectiveAddress
                                                  .floor!
                                                  .isNotEmpty)
                                            'floor': effectiveAddress.floor,
                                          if (effectiveAddress.apartment !=
                                                  null &&
                                              effectiveAddress
                                                  .apartment!
                                                  .isNotEmpty)
                                            'apartment':
                                                effectiveAddress.apartment,
                                          'city': effectiveAddress.city,
                                        };
                                      }

                                      final order = await ref
                                          .read(checkoutProvider.notifier)
                                          .placeOrder(
                                            deliveryMethod: deliveryMethod,
                                            paymentMethod: paymentMethod,
                                            deliveryAddress: deliveryAddress,
                                            promoCode: effectiveRewardId == null
                                                ? cart.promoCodeId
                                                : null,
                                            redeemRewardId: effectiveRewardId,
                                          );
                                      if (order != null) {
                                        if (!context.mounted) return;
                                        context.go(
                                          '/checkout/success',
                                          extra: order,
                                        );
                                      }
                                    },
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'checkout.terms_agree'.tr(),
                              style: KZ.caption.copyWith(
                                color: CheckoutScreen.onSurfaceVariantColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Lets the user pick from their saved addresses, or add a new one if they
  /// have none — the picked address becomes the one actually sent at checkout.
  void _showAddressPicker(BuildContext context) async {
    // Don't pop the sheet AND push the new route from inside the same tap
    // callback — Navigator.pop() only *starts* the sheet's closing transition,
    // it doesn't wait for the route to actually be removed. Pushing a new
    // route immediately after (context.push) can then run while the sheet's
    // route is still mid-removal, so GoRouter ends up briefly reconciling two
    // page entries in the same Navigator with colliding keys, which trips the
    // `!keyReservation.contains(key)` assertion. Instead, let the sheet pop
    // itself with a result and only push once that pop has fully completed
    // (i.e. after `showModalBottomSheet`'s own Future resolves).
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Consumer(
              builder: (context, ref, child) {
                final addressState = ref.watch(addressNotifierProvider);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'checkout.delivery_address'.tr(),
                        style: KZ.sectionTitle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (addressState.addresses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'checkout.no_saved_addresses'.tr(),
                          style: KZ.body,
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: addressState.addresses.length,
                          itemBuilder: (context, index) {
                            final address = addressState.addresses[index];
                            final effectiveSelectedId =
                                _selectedAddressId ??
                                addressState.defaultAddress?.id;
                            final isSelected =
                                address.id == effectiveSelectedId;
                            return ListTile(
                              leading: Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: isSelected
                                    ? CheckoutScreen.primaryColor
                                    : CheckoutScreen.outlineVariantColor,
                              ),
                              title: Text(
                                address.label.isNotEmpty
                                    ? address.label
                                    : 'checkout.address_fallback_label'.tr(),
                                style: KZ.itemTitle,
                              ),
                              subtitle: Text(
                                _formatAddress(address),
                                style: KZ.bodySmall,
                              ),
                              onTap: () {
                                setState(() => _selectedAddressId = address.id);
                                Navigator.pop(sheetContext);
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: KZButton(
                        variant: KZButtonVariant.secondary,
                        fullWidth: true,
                        icon: Icons.add_location_alt_rounded,
                        label: 'checkout.add_new_address'.tr(),
                        onPressed: () => Navigator.pop(sheetContext, 'add'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    // Only navigate once the sheet's route has actually finished closing.
    if (result == 'add' && mounted) {
      await context.push('/profile/addresses/add');
      // A new address invalidates any explicit prior pick — fall back to
      // whichever address the backend now reports as default.
      if (mounted) setState(() => _selectedAddressId = null);
    }
  }
}
