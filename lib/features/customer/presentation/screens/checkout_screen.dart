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
import 'package:kebda_zaman/features/customer/presentation/notifiers/delivery_quote_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/models/address.dart';
import 'package:kebda_zaman/features/shared/domain/models/delivery_quote.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
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
  _LoyaltyReward(id: 'discount-10', name: 'Discount Tier 10', pointsCost: 150),
  _LoyaltyReward(id: 'discount-25', name: 'Discount Tier 25', pointsCost: 350),
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
  // Guards the address picker sheet + its follow-up navigation against
  // rapid double-taps opening/pushing more than once concurrently.
  bool _isAddressPickerBusy = false;
  // Last (method, lat, lng) the delivery quote was requested for — lets
  // [_maybeRequestQuote] skip re-dispatching on every rebuild and only fire
  // when the actual target changed (address swap, coordinate change, or a
  // PICKUP<->DELIVERY flip). The [DeliveryQuoteNotifier] itself also dedupes,
  // this is just to avoid scheduling a redundant microtask each frame.
  ({FulfillmentType method, double? lat, double? lng})? _lastQuoteTriggerKey;

  /// Schedules a delivery-quote request for [method]/[lat]/[lng] after the
  /// current frame, but only when the target actually changed since the
  /// last call — never synchronously during build (Riverpod forbids
  /// mutating provider state mid-build) and never repeatedly for an
  /// unchanged target.
  void _maybeRequestQuote(FulfillmentType method, double? lat, double? lng) {
    final key = (method: method, lat: lat, lng: lng);
    if (_lastQuoteTriggerKey == key) return;
    _lastQuoteTriggerKey = key;
    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(deliveryQuoteProvider.notifier)
          .requestQuote(deliveryMethod: method, latitude: lat, longitude: lng);
    });
  }

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
  ///
  /// [quoteDeliveryFee] is the current distance-based delivery quote's fee
  /// (0 for PICKUP, or while no deliverable quote is available yet) —
  /// `cart.deliveryFee` is always `0` (the real fee is distance-based and
  /// only resolved via `POST /delivery/quote`/checkout), so it is never used
  /// here.
  ({double deliveryFee, double discount, double tax, double grandTotal})
  _previewTotals(Cart cart, double quoteDeliveryFee) {
    final effectiveRewardId = _effectiveRewardId(cart);
    final rewardSubtotalDiscount = _rewardSubtotalDiscount(
      effectiveRewardId,
      cart.subtotal,
    );
    final rewardWaivesDelivery = effectiveRewardId == 'free-delivery';

    final baseDeliveryFee = _orderType == 'pickup' ? 0.0 : quoteDeliveryFee;
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

  /// Localization key for the footer notice explaining why DELIVERY
  /// checkout is currently blocked by the address/quote state — `null` when
  /// there's nothing to say (no address picked yet — the address card above
  /// already covers that — or a deliverable quote is in hand).
  String? _deliveryBlockReasonKey(
    Address? address,
    AsyncValue<DeliveryQuote?> quoteAsync,
  ) {
    if (address == null) return null;
    if (!address.hasValidCoordinates) {
      return 'checkout.address_missing_coordinates_error';
    }
    if (quoteAsync.isLoading) {
      return 'checkout.calculating_delivery_fee';
    }
    if (quoteAsync.hasError) {
      return 'checkout.delivery_fee_calc_error';
    }
    final quote = quoteAsync.valueOrNull;
    if (quote == null) {
      return 'checkout.calculating_delivery_fee';
    }
    if (!quote.deliverable) {
      return 'checkout.address_outside_range';
    }
    return null;
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

    final deliveryMethodForQuote = _orderType == 'delivery'
        ? FulfillmentType.delivery
        : FulfillmentType.pickup;
    _maybeRequestQuote(
      deliveryMethodForQuote,
      effectiveAddress?.lat,
      effectiveAddress?.lng,
    );
    final quoteAsync = ref.watch(deliveryQuoteProvider);
    final quote = quoteAsync.valueOrNull;
    // Never a fake/stale fee while a fresh quote is loading or failed — 0
    // until a deliverable quote is actually in hand.
    final quoteDeliveryFee =
        (_orderType == 'delivery' &&
            !quoteAsync.isLoading &&
            quote != null &&
            quote.deliverable)
        ? (quote.deliveryFee ?? 0.0)
        : 0.0;

    ref.listen(checkoutProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          String message = 'checkout.checkout_failed_generic'.tr();
          bool guideToSignIn = false;
          bool guideToEditAddress = false;

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
              case 'RESTAURANT_NOT_ACCEPTING_ORDERS':
                {
                  final details = cause.details;
                  final localizedClosed = context.locale.languageCode == 'ar'
                      ? (details?['closedMessageAr'] as String?)
                      : (details?['closedMessageEn'] as String?);
                  message =
                      localizedClosed ?? 'checkout.restaurant_closed'.tr();
                }
                break;
              // Distance-based delivery pricing errors (POST /checkout and
              // POST /delivery/quote share this code space) — the user stays
              // on checkout in every case here, never auto-retried.
              case 'DELIVERY_COORDINATES_REQUIRED':
                message = 'checkout.delivery_coordinates_required_error'.tr();
                guideToEditAddress = effectiveAddress != null;
                break;
              case 'OUTSIDE_DELIVERY_RANGE':
                message = 'checkout.outside_delivery_range_error'.tr();
                break;
              case 'ROUTES_TIMEOUT':
                message = 'checkout.routes_timeout_error'.tr();
                break;
              case 'ROUTES_QUOTA_EXCEEDED':
                message = 'checkout.routes_quota_exceeded_error'.tr();
                break;
              case 'ROUTES_PROVIDER_CONFIG_ERROR':
                message = 'checkout.routes_provider_error'.tr();
                break;
              case 'ROUTES_TEMPORARY_ERROR':
                message = 'checkout.routes_temporary_error'.tr();
                break;
              case 'ROUTES_NO_ROUTE_FOUND':
                message = 'checkout.routes_no_route_error'.tr();
                break;
              case 'RESTAURANT_LOCATION_NOT_CONFIGURED':
                message = 'checkout.restaurant_location_error'.tr();
                break;
              case 'MINIMUM_ORDER_NOT_MET':
                {
                  final minimumOrder = cause.details?['minimumOrder'] as num?;
                  message = 'checkout.zone_minimum_order_error'.tr(
                    namedArgs: {
                      'min': minimumOrder != null
                          ? formatCurrency(minimumOrder, locale: context.locale)
                          : '',
                    },
                  );
                }
                break;
              case 'BELOW_MIN_ORDER':
                message = 'checkout.below_min_order_error'.tr();
                break;
              case 'PROMO_ALREADY_USED':
                message = 'cart.promo_already_used'.tr();
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
                  : guideToEditAddress
                  ? SnackBarAction(
                      label: 'checkout.update_address_location'.tr(),
                      textColor: Colors.white,
                      onPressed: () => _editAddressLocation(effectiveAddress!),
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
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CheckoutScreen.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            border: Border.all(
                              color: CheckoutScreen.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: CheckoutScreen.onSurfaceVariantColor,
                            size: 22,
                          ),
                        ),
                        Text(
                          'checkout.title'.tr(),
                          style: KZ.pageTitle.copyWith(
                            color: CheckoutScreen.primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'common.back'.tr(),
                          child: InkWell(
                            onTap: () => context.pop(),
                            customBorder: const CircleBorder(),
                            child: const SizedBox(
                              width: 44,
                              height: 44,
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: CheckoutScreen.onSurfaceColor,
                                size: 24,
                              ),
                            ),
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
                        final totals = _previewTotals(cart, quoteDeliveryFee);
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
                              height: 58,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: CheckoutScreen.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
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
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: CheckoutScreen.primaryColor
                                        .withValues(alpha: 0.1),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
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
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'checkout.delivery_address'.tr(),
                                              style: KZ.itemTitle.copyWith(
                                                color:
                                                    CheckoutScreen.primaryColor,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              _showAddressPicker(context),
                                          style: TextButton.styleFrom(
                                            minimumSize: Size.zero,
                                            padding: EdgeInsets.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            'checkout.change_address'.tr(),
                                            style: KZ.labelLarge.copyWith(
                                              color:
                                                  CheckoutScreen.primaryColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      displayAddress,
                                      style: KZ.body.copyWith(
                                        color: CheckoutScreen
                                            .onSurfaceVariantColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _DeliveryQuoteCard(
                                address: effectiveAddress,
                                quoteAsync: quoteAsync,
                                onEditAddressLocation: () =>
                                    _editAddressLocation(effectiveAddress!),
                                onRetry: () => ref
                                    .read(deliveryQuoteProvider.notifier)
                                    .retry(),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Estimated Arrival Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: CheckoutScreen.primaryColor.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'checkout.estimated_arrival'.tr(),
                                        style: KZ.label.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: CheckoutScreen.onSurfaceColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _orderType == 'delivery'
                                            ? '25-35 دقيقة'
                                            : '15-20 دقيقة',
                                        style: KZ.priceLarge.copyWith(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: CheckoutScreen.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: CheckoutScreen.primaryColor
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.schedule_rounded,
                                      color: CheckoutScreen.primaryColor,
                                      size: 26,
                                    ),
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
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedPaymentMethod == 0
                                        ? CheckoutScreen.primaryColor
                                        : CheckoutScreen.primaryColor
                                              .withValues(alpha: 0.1),
                                    width: _selectedPaymentMethod == 0 ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.03,
                                      ),
                                      blurRadius: 10,
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
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.payments_rounded,
                                            color: Colors.white,
                                            size: 24,
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
                                            const SizedBox(height: 2),
                                            Text(
                                              'checkout.pay_upon_receipt'
                                                  .tr()
                                                  .toUpperCase(),
                                              style: KZ.bodySmall.copyWith(
                                                fontSize: 12,
                                                color: CheckoutScreen
                                                    .onSurfaceVariantColor,
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
                                        formatCurrency(
                                          cart.subtotal,
                                          locale: context.locale,
                                        ),
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
                                            : formatCurrency(
                                                effectiveDeliveryFee,
                                                locale: context.locale,
                                              ),
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
                                          formatCurrency(
                                            effectiveTax,
                                            locale: context.locale,
                                          ),
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
                                          '-${formatCurrency(totalDiscount, locale: context.locale)}',
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
                                        formatCurrency(
                                          grandTotal,
                                          locale: context.locale,
                                        ),
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
                final grandTotal = _previewTotals(
                  cart,
                  quoteDeliveryFee,
                ).grandTotal;
                final deliveryBlockReasonKey = _orderType == 'delivery'
                    ? _deliveryBlockReasonKey(effectiveAddress, quoteAsync)
                    : null;
                final deliveryNotReady =
                    _orderType == 'delivery' &&
                    (effectiveAddress == null ||
                        !effectiveAddress.hasValidCoordinates ||
                        quoteAsync.isLoading ||
                        quoteAsync.hasError ||
                        quote == null ||
                        !quote.deliverable);

                return settingsAsync.when(
                  loading: () => _CheckoutFooterShell(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Center(child: CircularProgressIndicator()),
                        const SizedBox(height: 10),
                        Text(
                          'checkout.settings_loading'.tr(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  error: (error, stackTrace) => _CheckoutFooterShell(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: CheckoutScreen.errorColor,
                              semanticLabel: 'Error',
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'checkout.settings_error'.tr(),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: CheckoutScreen.errorColor,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        KZButton(
                          fullWidth: true,
                          pill: false,
                          variant: KZButtonVariant.secondary,
                          label: 'common.retry'.tr(),
                          loading: settingsAsync.isLoading,
                          onPressed: () =>
                              ref.invalidate(restaurantSettingsProvider),
                        ),
                      ],
                    ),
                  ),
                  data: (settings) {
                    final isBelowMinOrder =
                        cart.subtotal < settings.minOrderAmount;
                    final remaining = (settings.minOrderAmount - cart.subtotal)
                        .clamp(0.0, double.infinity);

                    return _CheckoutFooterShell(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!settings.acceptingOrders)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                (context.locale.languageCode == 'ar'
                                        ? settings.closedMessageAr
                                        : settings.closedMessageEn) ??
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
                                    'remaining': formatCurrency(
                                      remaining,
                                      locale: context.locale,
                                    ),
                                    'min': formatCurrency(
                                      settings.minOrderAmount,
                                      locale: context.locale,
                                    ),
                                  },
                                ),
                                style: KZ.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: CheckoutScreen.errorColor,
                                ),
                              ),
                            )
                          else if (deliveryBlockReasonKey != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text(
                                deliveryBlockReasonKey.tr(),
                                style: KZ.body.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: CheckoutScreen.errorColor,
                                ),
                              ),
                            ),
                          KZButton(
                            fullWidth: true,
                            pill: true,
                            loading: checkoutState.isLoading,
                            label: 'checkout.place_order_total'.tr(
                              namedArgs: {
                                'amount': formatCurrency(
                                  grandTotal,
                                  locale: context.locale,
                                ),
                              },
                            ),
                            onPressed:
                                (checkoutState.isLoading ||
                                    !settings.acceptingOrders ||
                                    isBelowMinOrder ||
                                    deliveryNotReady)
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
                                              'checkout.address_required'.tr(),
                                            ),
                                            backgroundColor:
                                                CheckoutScreen.errorColor,
                                          ),
                                        );
                                        return;
                                      }
                                      // Defensive re-check — the Place Order
                                      // button is already disabled whenever
                                      // this would fail, but coordinates and
                                      // the current quote are never trusted
                                      // implicitly right before submitting.
                                      if (!effectiveAddress
                                          .hasValidCoordinates) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'checkout.delivery_coordinates_required_error'
                                                  .tr(),
                                            ),
                                            backgroundColor:
                                                CheckoutScreen.errorColor,
                                          ),
                                        );
                                        return;
                                      }
                                      final currentQuote = quote;
                                      if (quoteAsync.isLoading ||
                                          quoteAsync.hasError ||
                                          currentQuote == null ||
                                          !currentQuote.deliverable) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'checkout.address_outside_range'
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
                                            effectiveAddress.floor!.isNotEmpty)
                                          'floor': effectiveAddress.floor,
                                        if (effectiveAddress.apartment !=
                                                null &&
                                            effectiveAddress
                                                .apartment!
                                                .isNotEmpty)
                                          'apartment':
                                              effectiveAddress.apartment,
                                        'city': effectiveAddress.city,
                                        'latitude': effectiveAddress.lat,
                                        'longitude': effectiveAddress.lng,
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
                                        '/orders/tracking/${order.id}',
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

  /// Lets the user pick from their saved addresses, or add/edit one if they
  /// need to — the picked address becomes the one actually sent at checkout.
  /// "Update address location on map" action on the delivery-quote card's
  /// missing-coordinates/error states — pushes the same edit route the
  /// address-picker sheet's edit action uses, then clears the explicit pick
  /// so the (now-updated) address is picked up fresh from the backend.
  Future<void> _editAddressLocation(Address address) async {
    await context.push('/profile/addresses/edit', extra: address);
    if (mounted) setState(() => _selectedAddressId = null);
  }

  void _showAddressPicker(BuildContext context) async {
    // Guard against rapid double-taps opening a second sheet (or pushing a
    // second follow-up route) while the first one is still in flight.
    if (_isAddressPickerBusy) return;
    _isAddressPickerBusy = true;

    // Don't pop the sheet AND push the new route from inside the same tap
    // callback — Navigator.pop() only *starts* the sheet's closing transition,
    // it doesn't wait for the route to actually be removed. Pushing a new
    // route immediately after (context.push) can then run while the sheet's
    // route is still mid-removal, so GoRouter ends up briefly reconciling two
    // page entries in the same Navigator with colliding keys, which trips the
    // `!keyReservation.contains(key)` assertion. Instead, let the sheet pop
    // itself with a typed result and only navigate once that pop has fully
    // completed (i.e. after `showModalBottomSheet`'s own Future resolves),
    // using the parent Checkout context — never the sheet's own context,
    // which is gone by then.
    try {
      final result = await showModalBottomSheet<_AddressSheetResult>(
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'checkout.delivery_address'.tr(),
                          style: KZ.sectionTitle,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (addressState.addresses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                trailing: IconButton(
                                  onPressed: () => Navigator.pop(
                                    sheetContext,
                                    _AddressSheetResult.edit(address),
                                  ),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: CheckoutScreen.secondaryColor,
                                    size: KZ.iconControl,
                                  ),
                                ),
                                onTap: () => Navigator.pop(
                                  sheetContext,
                                  _AddressSheetResult.select(address.id),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: KZButton(
                          variant: KZButtonVariant.secondary,
                          fullWidth: true,
                          icon: Icons.add_location_alt_rounded,
                          label: 'checkout.add_new_address'.tr(),
                          onPressed: () => Navigator.pop(
                            sheetContext,
                            const _AddressSheetResult.add(),
                          ),
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

      // Only navigate once the sheet's route has actually finished closing,
      // and always via the parent Checkout `context` — the sheet's own
      // `sheetContext` is no longer valid once the sheet has popped.
      if (result == null || !mounted) return;
      switch (result.action) {
        case _AddressSheetAction.select:
          setState(() => _selectedAddressId = result.selectedId);
          break;
        case _AddressSheetAction.add:
          await context.push('/profile/addresses/add');
          // A new address invalidates any explicit prior pick — fall back to
          // whichever address the backend now reports as default.
          if (mounted) setState(() => _selectedAddressId = null);
          break;
        case _AddressSheetAction.edit:
          await context.push(
            '/profile/addresses/edit',
            extra: result.editAddress,
          );
          if (mounted) setState(() => _selectedAddressId = null);
          break;
      }
    } finally {
      _isAddressPickerBusy = false;
    }
  }
}

enum _AddressSheetAction { select, add, edit }

/// Typed result the address-picker bottom sheet pops with — replaces the old
/// bare `String?` so add/edit/select are unambiguous and carry their payload
/// without the caller needing to touch the (by-then-invalid) sheet context.
class _AddressSheetResult {
  final _AddressSheetAction action;
  final String? selectedId;
  final Address? editAddress;

  const _AddressSheetResult.select(this.selectedId)
    : action = _AddressSheetAction.select,
      editAddress = null;

  const _AddressSheetResult.add()
    : action = _AddressSheetAction.add,
      selectedId = null,
      editAddress = null;

  const _AddressSheetResult.edit(Address address)
    : action = _AddressSheetAction.edit,
      selectedId = null,
      editAddress = address;
}

/// DELIVERY-only distance-based delivery quote card
/// (`POST /delivery/quote`). Purely advisory display — checkout always
/// re-prices authoritatively, this never submits anything itself. Renders
/// nothing when [address] is `null`: the address card above already covers
/// "no address selected" via `checkout.no_address_notice`.
class _DeliveryQuoteCard extends StatelessWidget {
  final Address? address;
  final AsyncValue<DeliveryQuote?> quoteAsync;
  final VoidCallback onEditAddressLocation;
  final VoidCallback onRetry;

  const _DeliveryQuoteCard({
    required this.address,
    required this.quoteAsync,
    required this.onEditAddressLocation,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final address = this.address;
    if (address == null) return const SizedBox.shrink();

    return KZCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_shipping_rounded,
                color: CheckoutScreen.primaryColor,
                size: KZ.iconControl,
              ),
              const SizedBox(width: 8),
              Text(
                'checkout.delivery_fee'.tr(),
                style: KZ.itemTitle.copyWith(
                  color: CheckoutScreen.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              if (!address.hasValidCoordinates) {
                return _DeliveryQuoteNotice(
                  message: 'checkout.address_missing_coordinates_error'.tr(),
                  actionLabel: 'checkout.update_address_location'.tr(),
                  onAction: onEditAddressLocation,
                );
              }
              if (quoteAsync.isLoading) {
                return Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'checkout.calculating_delivery_fee'.tr(),
                        style: KZ.body.copyWith(
                          color: CheckoutScreen.onSurfaceVariantColor,
                        ),
                      ),
                    ),
                  ],
                );
              }
              if (quoteAsync.hasError) {
                return _DeliveryQuoteNotice(
                  message: 'checkout.delivery_fee_calc_error'.tr(),
                  actionLabel: 'common.retry'.tr(),
                  onAction: onRetry,
                );
              }
              final quote = quoteAsync.valueOrNull;
              if (quote == null) {
                return Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'checkout.calculating_delivery_fee'.tr(),
                        style: KZ.body.copyWith(
                          color: CheckoutScreen.onSurfaceVariantColor,
                        ),
                      ),
                    ),
                  ],
                );
              }
              if (!quote.deliverable) {
                return _DeliveryQuoteNotice(
                  message: 'checkout.address_outside_range'.tr(),
                  actionLabel: 'checkout.update_address_location'.tr(),
                  onAction: onEditAddressLocation,
                );
              }
              final fee = quote.deliveryFee;
              final distanceKm = quote.distanceKm;
              final durationMinutes = quote.durationMinutes;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('checkout.delivery_fee'.tr(), style: KZ.bodyLarge),
                      Text(
                        fee != null
                            ? formatCurrency(fee, locale: context.locale)
                            : '—',
                        style: KZ.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: CheckoutScreen.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (distanceKm != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('checkout.distance'.tr(), style: KZ.caption),
                        Text(
                          '${distanceKm.toStringAsFixed(2)} km',
                          style: KZ.caption,
                        ),
                      ],
                    ),
                  ],
                  if (durationMinutes != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('checkout.estimated_time'.tr(), style: KZ.caption),
                        Text('$durationMinutes min', style: KZ.caption),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Shared layout for the quote card's non-happy-path states — a short
/// message plus a single action (retry, or edit the address's map pin).
class _DeliveryQuoteNotice extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _DeliveryQuoteNotice({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: KZ.body.copyWith(color: CheckoutScreen.errorColor),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionLabel,
            style: KZ.labelLarge.copyWith(
              color: CheckoutScreen.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutFooterShell extends StatelessWidget {
  final Widget child;

  const _CheckoutFooterShell({required this.child});

  @override
  Widget build(BuildContext context) {
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
          color: CheckoutScreen.surfaceBg.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: CheckoutScreen.outlineVariantColor.withValues(alpha: 0.2),
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
        child: child,
      ),
    );
  }
}
