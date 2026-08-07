import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';

import '../notifiers/cart_notifier.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/theme/kz_motion.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';

/// Two-tier spacing rhythm for the whole screen: [_blockGap] between major
/// sections (cart items / promo / summary / recommendations), [_innerGap]
/// between elements within the same section. Kept as constants here rather
/// than inline magic numbers so the two tiers stay visibly distinct and
/// consistent — both pull from the existing KZ.sp* scale, nothing new.
const double _blockGap = KZ.sp24;
const double _innerGap = KZ.sp10;

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  static const Color surfaceBg = KZ.surface;
  static const Color primaryColor = KZ.primary;
  static const Color onSurfaceColor = KZ.onSurface;
  static const Color onSurfaceVariantColor = KZ.onSurfaceVariant;
  static const Color secondaryColor = KZ.secondary;
  static const Color surfaceContainerColor = KZ.surfaceContainer;
  static const Color surfaceContainerLowColor = KZ.surfaceContainerLow;
  static const Color outlineVariantColor = KZ.outlineVariant;
  static const Color errorColor = KZ.error;

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  // Keyed by cart item id — blocks a second quantity/remove tap on the same
  // row while its previous mutation is still in flight (rapid double-taps
  // must not fire two overlapping updateItem/removeItem calls).
  final Set<String> _pendingItemIds = {};

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _runCartAction(Future<void> Function() action, {String? itemId}) {
    if (itemId != null) {
      if (_pendingItemIds.contains(itemId)) return;
      setState(() => _pendingItemIds.add(itemId));
    }
    action()
        .catchError((Object e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('common.something_wrong'.tr())),
          );
        })
        .whenComplete(() {
          if (itemId != null && mounted) {
            setState(() => _pendingItemIds.remove(itemId));
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: CartScreen.surfaceBg,
      body: ResponsiveContainer(
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ── Top Bar Header matching Menu Screen level & size ──
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: KZ.outlineVariant.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Semantics(
                                button: true,
                                label: 'common.back'.tr(),
                                child: InkWell(
                                  onTap: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go('/home');
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(30),
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: CartScreen.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  'cart.title'.tr(),
                                  style: KZ.pageTitle.copyWith(
                                    color: CartScreen.primaryColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (cartAsync.valueOrNull != null &&
                            (cartAsync.valueOrNull?.items.isNotEmpty ?? false))
                          InkWell(
                            onTap: () => _runCartAction(
                              () => ref.read(cartProvider.notifier).clearCart(),
                            ),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: Text(
                                'cart.clear_cart'.tr().toUpperCase(),
                                style: KZ.labelLarge.copyWith(
                                  color: CartScreen.onSurfaceVariantColor,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: cartAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            CartScreen.primaryColor,
                          ),
                        ),
                      ),
                      error: (e, st) => KZErrorState(
                        message: 'cart.load_error'.tr(),
                        retryLabel: 'common.retry'.tr(),
                        onRetry: () => ref.invalidate(cartProvider),
                      ),
                      data: (cart) {
                        if (cart == null || cart.items.isEmpty) {
                          return KZEmptyState(
                            lottieAsset: 'assets/lottie/shopping_loader.json',
                            title: 'cart.empty'.tr(),
                            message: 'cart.empty_sub'.tr(),
                            actionLabel: 'cart.browse_menu'.tr(),
                            onAction: () => context.go('/menu'),
                          );
                        }

                        return ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 160),
                          children: [
                            // Cart Items — grouped together, small gaps
                            // between each card since they're one section.
                            for (final item in cart.items) ...[
                              _CartItemCard(
                                item: item,
                                isPending: _pendingItemIds.contains(item.id),
                                onEdit: () => context.push(
                                  '/item/${item.menuItemId}',
                                  extra: {'cartItemId': item.id},
                                ),
                                onRemove: () => _runCartAction(
                                  () => ref
                                      .read(cartProvider.notifier)
                                      .removeItem(item.id),
                                  itemId: item.id,
                                ),
                                onQuantityChanged: (newQuantity) {
                                  if (newQuantity == 0) {
                                    _runCartAction(
                                      () => ref
                                          .read(cartProvider.notifier)
                                          .removeItem(item.id),
                                      itemId: item.id,
                                    );
                                  } else {
                                    _runCartAction(
                                      () => ref
                                          .read(cartProvider.notifier)
                                          .updateItem(item.id, newQuantity),
                                      itemId: item.id,
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: _innerGap),
                            ],

                            const SizedBox(height: _blockGap),
                            _buildPromoSection(cart),
                            const SizedBox(height: _blockGap),
                            _buildOrderSummarySection(context, cart),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Sticky Checkout CTA — the one floating element on the
            // page; every other surface below is intentionally flat. A
            // non-interactive fade behind it keeps scrolled-under content
            // readable without adding a second bottom bar or changing the
            // button's own position. ──
            if (cartAsync.valueOrNull != null &&
                (cartAsync.valueOrNull?.items.isNotEmpty ?? false)) ...[
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          CartScreen.surfaceBg,
                          CartScreen.surfaceBg.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: SafeArea(
                  child: _CheckoutButton(
                    total: cartAsync.valueOrNull!.grandTotal,
                    onTap: () => context.push('/checkout'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Promo Code Section ──
  Widget _buildPromoSection(Cart cart) {
    final hasPromo = cart.promoCodeId != null && cart.promoCodeId!.isNotEmpty;

    if (hasPromo) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: CartScreen.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CartScreen.primaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_offer_rounded,
              color: CartScreen.primaryColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'cart.applied'.tr(),
                    style: KZ.caption.copyWith(
                      color: CartScreen.onSurfaceVariantColor,
                    ),
                  ),
                  Text(
                    cart.promoCodeId!,
                    style: KZ.itemTitle.copyWith(
                      fontWeight: FontWeight.w800,
                      color: CartScreen.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                try {
                  await ref.read(cartProvider.notifier).removePromoCode();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('common.something_wrong'.tr()),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: CartScreen.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'cart.remove'.tr(),
                  style: KZ.labelLarge.copyWith(
                    color: CartScreen.errorColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CartScreen.outlineVariantColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(
            Icons.local_offer_outlined,
            color: CartScreen.onSurfaceVariantColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _promoController,
              textAlign: TextAlign.start,
              style: KZ.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'cart.promo_hint'.tr(),
                hintStyle: KZ.bodyLarge.copyWith(
                  color: CartScreen.onSurfaceVariantColor.withValues(
                    alpha: 0.5,
                  ),
                ),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              final code = _promoController.text.trim();
              if (code.isEmpty) return;
              try {
                await ref.read(cartProvider.notifier).applyPromoCode(code);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${'cart.applied'.tr()} "$code"'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                String errorMsg;
                final cause = e is Failure ? e.cause : null;
                if (cause is ApiException &&
                    cause.code == 'PROMO_ALREADY_USED') {
                  errorMsg = 'cart.promo_already_used'.tr();
                } else if (e is Failure) {
                  errorMsg = e.message;
                } else {
                  errorMsg = e.toString().replaceAll('Exception: ', '');
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMsg),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: KZ.error,
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'cart.apply'.tr(),
                style: KZ.labelLarge.copyWith(
                  color: CartScreen.primaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Order Summary Section matching Stitch HTML ──
  Widget _buildOrderSummarySection(BuildContext context, Cart cart) {
    Widget row(String label, String value, {Color? color}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: KZ.bodyLarge.copyWith(
                  color: color ?? CartScreen.onSurfaceVariantColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                value,
                style: KZ.bodyLarge.copyWith(
                  color: color ?? CartScreen.onSurfaceVariantColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CartScreen.surfaceContainerLowColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'cart.order_summary'.tr(),
            style: KZ.sectionTitle.copyWith(
              fontSize: 18,
              color: CartScreen.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: CartScreen.outlineVariantColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          row(
            'cart.subtotal'.tr(),
            formatCurrency(cart.subtotal, locale: context.locale),
          ),
          if (cart.discountTotal > 0)
            row(
              'cart.discount'.tr(),
              '-${formatCurrency(cart.discountTotal, locale: context.locale)}',
              color: KZ.error,
            ),
          row(
            'cart.delivery_fee'.tr(),
            // Cart-stage deliveryFee is always 0 (zone-specific pricing is
            // resolved at checkout, not before a zone is chosen) — showing
            // "0 SAR" here would read as "free delivery", which it isn't.
            'cart.delivery_fee_at_checkout'.tr(),
          ),
          if (cart.taxTotal > 0)
            row(
              'common.tax'.tr(),
              formatCurrency(cart.taxTotal, locale: context.locale),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16),
            child: Divider(
              height: 1,
              color: CartScreen.outlineVariantColor.withValues(alpha: 0.3),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'cart.total'.tr(),
                  style: KZ.sectionTitle.copyWith(
                    fontSize: 20,
                    color: CartScreen.onSurfaceColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    formatCurrency(cart.grandTotal, locale: context.locale),
                    style: KZ.priceLarge.copyWith(
                      fontSize: 32,
                      color: CartScreen.primaryColor,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // No real recommendation source exists for the Cart screen (CartRepository
  // exposes no recommendation data, unlike item details' oftenOrderedWith).
  // Per project rules, the section is hidden entirely rather than backed by
  // fake/random/featured/popular fallback data.
}

// ── Cart item card ──
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final bool isPending;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  const _CartItemCard({
    required this.item,
    this.isPending = false,
    required this.onEdit,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CartScreen.outlineVariantColor.withValues(alpha: 0.4),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: KZFoodImage(
              imageUrl: item.productImage,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: KZ.itemTitle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: CartScreen.onSurfaceColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onRemove,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: CartScreen.onSurfaceVariantColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(item.lineTotal, locale: context.locale),
                  style: KZ.priceLarge.copyWith(
                    fontSize: 16,
                    color: CartScreen.primaryColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Flexible so the fixed-width quantity stepper always
                    // keeps its full tap targets — the label shrinks/ellipsizes
                    // first on narrow cards instead of overflowing the row.
                    Flexible(
                      child: InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.edit_rounded,
                                size: 16,
                                color: CartScreen.secondaryColor,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'common.edit'.tr(),
                                  style: KZ.labelLarge.copyWith(
                                    color: CartScreen.secondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Quantity Stepper
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: CartScreen.surfaceContainerColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KZPressableScale(
                            enabled: !isPending,
                            child: InkWell(
                              onTap: isPending
                                  ? null
                                  : () => onQuantityChanged(item.quantity - 1),
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                width: 36,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.remove_rounded,
                                  size: 18,
                                  color: isPending
                                      ? CartScreen.outlineVariantColor
                                      : CartScreen.onSurfaceColor,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 32),
                            alignment: Alignment.center,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                '${item.quantity}',
                                key: ValueKey<int>(item.quantity),
                                style: KZ.cardTitle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          KZPressableScale(
                            enabled: !isPending,
                            child: InkWell(
                              onTap: isPending
                                  ? null
                                  : () => onQuantityChanged(item.quantity + 1),
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                width: 36,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 18,
                                  color: isPending
                                      ? CartScreen.outlineVariantColor
                                      : CartScreen.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sticky checkout CTA ──
class _CheckoutButton extends StatefulWidget {
  final double total;
  final VoidCallback onTap;

  const _CheckoutButton({required this.total, required this.onTap});

  @override
  State<_CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<_CheckoutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: CartScreen.primaryColor,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: CartScreen.primaryColor.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'cart.checkout'.tr(),
                  style: KZ.buttonLabel.copyWith(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '•',
                    style: KZ.buttonLabel.copyWith(
                      fontSize: 17,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                Text(
                  formatCurrency(widget.total, locale: context.locale),
                  style: KZ.buttonLabel.copyWith(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
