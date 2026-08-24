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
import 'package:kebda_zaman/core/widgets/kz_menu_item_meta.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';

/// Two-tier spacing rhythm for the whole screen: [_blockGap] between major
/// sections (cart items / promo / summary), [_innerGap] between elements
/// within the same section. Kept as constants here rather than inline magic
/// numbers so the two tiers stay visibly distinct and consistent — both pull
/// from the existing KZ.sp* scale, nothing new.
const double _blockGap = KZ.sp20;
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
  bool _promoSubmitting = false;

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
          _showSnack('common.something_wrong'.tr());
        })
        .whenComplete(() {
          if (itemId != null && mounted) {
            setState(() => _pendingItemIds.remove(itemId));
          }
        });
  }

  // Floating with an explicit bottom margin so a snackbar always clears the
  // sticky checkout CTA instead of sitting underneath/behind it.
  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? KZ.error : null,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      ),
    );
  }

  Future<void> _submitPromo(Cart cart) async {
    final code = _promoController.text.trim();
    if (code.isEmpty || _promoSubmitting) return;
    setState(() => _promoSubmitting = true);
    try {
      await ref.read(cartProvider.notifier).applyPromoCode(code);
      if (!context.mounted) return;
      _promoController.clear();
      _showSnack('${'cart.applied'.tr()} "$code"');
    } catch (e) {
      if (!context.mounted) return;
      String errorMsg;
      final cause = e is Failure ? e.cause : null;
      if (cause is ApiException && cause.code == 'PROMO_ALREADY_USED') {
        errorMsg = 'cart.promo_already_used'.tr();
      } else if (e is Failure) {
        errorMsg = e.message;
      } else {
        errorMsg = e.toString().replaceAll('Exception: ', '');
      }
      _showSnack(errorMsg, isError: true);
    } finally {
      if (mounted) setState(() => _promoSubmitting = false);
    }
  }

  Future<void> _removePromo() async {
    try {
      await ref.read(cartProvider.notifier).removePromoCode();
    } catch (e) {
      if (!context.mounted) return;
      _showSnack('common.something_wrong'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final hasItems = cartAsync.valueOrNull?.items.isNotEmpty ?? false;

    return Scaffold(
      backgroundColor: CartScreen.surfaceBg,
      body: ResponsiveContainer(
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _CartHeader(
                    showClear: hasItems,
                    onClear: () => _runCartAction(
                      () => ref.read(cartProvider.notifier).clearCart(),
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
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),
                          children: [
                            // Cart items — grouped together, small gaps
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

                            const SizedBox(height: _blockGap - _innerGap),
                            _PromoSection(
                              cart: cart,
                              controller: _promoController,
                              submitting: _promoSubmitting,
                              onApply: () => _submitPromo(cart),
                              onRemove: _removePromo,
                            ),
                            const SizedBox(height: _blockGap),
                            _OrderSummarySection(cart: cart),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Sticky checkout CTA — the one floating element on the
            // page; every other surface below is intentionally flat. A
            // non-interactive fade behind it keeps scrolled-under content
            // readable without adding a second bottom bar or changing the
            // button's own position. ──
            if (hasItems) ...[
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
}

// ── Header: one clear title, Clear Cart kept visually secondary so it
// never competes with the checkout CTA below. ──
class _CartHeader extends StatelessWidget {
  final bool showClear;
  final VoidCallback onClear;

  const _CartHeader({required this.showClear, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: KZ.sp16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: KZ.outlineVariant, width: 1),
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
                      padding: EdgeInsets.only(right: KZ.sp8),
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
                    style: KZ.pageTitle.copyWith(color: CartScreen.primaryColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (showClear)
            InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(KZ.radiusSm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KZ.sp8,
                  vertical: KZ.sp8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: CartScreen.onSurfaceVariantColor,
                    ),
                    const SizedBox(width: KZ.sp4),
                    Text(
                      'cart.clear_cart'.tr(),
                      style: KZ.bodySmall.copyWith(
                        color: CartScreen.onSurfaceVariantColor,
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
}

// ── Cart item card — image, name, price and the quantity stepper carry
// the row; Edit/Remove are compact icon affordances that never outweigh
// them. ──
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
    final hasNote = item.specialInstructions.trim().isNotEmpty;

    return KZCard(
      padding: const EdgeInsets.all(KZ.sp12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: KZFoodImage(
              imageUrl: item.productImage,
              borderRadius: BorderRadius.circular(KZ.radiusMd),
            ),
          ),
          const SizedBox(width: KZ.sp12),
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
                        style: KZ.itemTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _RowIconAction(
                      icon: Icons.edit_outlined,
                      tooltip: 'common.edit'.tr(),
                      onTap: onEdit,
                    ),
                    _RowIconAction(
                      icon: Icons.close_rounded,
                      tooltip: 'cart.remove'.tr(),
                      onTap: onRemove,
                    ),
                  ],
                ),
                if (hasNote) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.specialInstructions.trim(),
                    style: KZ.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: KZ.sp8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            formatCurrency(
                              item.lineTotal,
                              locale: context.locale,
                            ),
                            style: KZ.priceLarge.copyWith(fontSize: 17),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // "Was" line total — the original (pre-discount)
                          // unit price snapshot times quantity, purely
                          // informational. `item.lineTotal` above remains
                          // the actual, server-computed charged amount.
                          if (item.menuItemDiscountPrice != null &&
                              item.menuItemBasePrice != null) ...[
                            const SizedBox(width: 6),
                            MenuItemComparePriceText(
                              compareAtPrice:
                                  item.menuItemBasePrice! * item.quantity,
                              style: KZ.bodySmall.copyWith(color: KZ.error),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: KZ.sp8),
                    _QuantityStepper(
                      quantity: item.quantity,
                      isPending: isPending,
                      onChanged: onQuantityChanged,
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

/// A small, muted icon affordance for a card's secondary actions (Edit,
/// Remove) — deliberately quieter than the row's primary content so it
/// never competes with the price/quantity stepper below it.
class _RowIconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RowIconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: KZ.iconTapTargetMin,
          height: KZ.iconTapTargetMin,
          child: Icon(
            icon,
            size: 18,
            color: CartScreen.onSurfaceVariantColor,
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final bool isPending;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({
    required this.quantity,
    required this.isPending,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: CartScreen.surfaceContainerColor,
        borderRadius: BorderRadius.circular(KZ.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          KZPressableScale(
            enabled: !isPending,
            child: InkWell(
              onTap: isPending ? null : () => onChanged(quantity - 1),
              borderRadius: BorderRadius.circular(KZ.radiusFull),
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
            constraints: const BoxConstraints(minWidth: 28),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                '$quantity',
                key: ValueKey<int>(quantity),
                style: KZ.cardTitle.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          KZPressableScale(
            enabled: !isPending,
            child: InkWell(
              onTap: isPending ? null : () => onChanged(quantity + 1),
              borderRadius: BorderRadius.circular(KZ.radiusFull),
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
    );
  }
}

// ── Promo code — a quiet secondary utility, not a competing form. ──
class _PromoSection extends StatelessWidget {
  final Cart cart;
  final TextEditingController controller;
  final bool submitting;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _PromoSection({
    required this.cart,
    required this.controller,
    required this.submitting,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasPromo = cart.promoCodeId != null && cart.promoCodeId!.isNotEmpty;
    return hasPromo ? _appliedState() : _inputState();
  }

  Widget _appliedState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KZ.sp14,
        vertical: KZ.sp12,
      ),
      decoration: BoxDecoration(
        color: CartScreen.surfaceContainerLowColor,
        borderRadius: BorderRadius.circular(KZ.radiusMd),
        border: Border.all(color: CartScreen.outlineVariantColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: KZ.tertiary, size: 20),
          const SizedBox(width: KZ.sp10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'cart.applied'.tr(),
                  style: KZ.caption.copyWith(color: KZ.tertiary),
                ),
                Text(
                  cart.promoCodeId!,
                  style: KZ.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: KZ.sp8),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(KZ.radiusSm),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KZ.sp8,
                vertical: KZ.sp6,
              ),
              child: Text(
                'cart.remove'.tr(),
                style: KZ.labelLarge.copyWith(color: CartScreen.errorColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputState() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: KZ.sp12),
      decoration: BoxDecoration(
        color: CartScreen.surfaceContainerLowColor,
        borderRadius: BorderRadius.circular(KZ.radiusMd),
        border: Border.all(color: CartScreen.outlineVariantColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer_outlined,
            color: CartScreen.onSurfaceVariantColor,
            size: 18,
          ),
          const SizedBox(width: KZ.sp10),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !submitting,
              style: KZ.body.copyWith(fontWeight: FontWeight.w600),
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => onApply(),
              decoration: InputDecoration(
                hintText: 'cart.promo_hint'.tr(),
                hintStyle: KZ.body.copyWith(
                  color: CartScreen.onSurfaceVariantColor.withValues(
                    alpha: 0.6,
                  ),
                ),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          const SizedBox(width: KZ.sp8),
          SizedBox(
            height: 28,
            child: submitting
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: KZ.sp8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CartScreen.primaryColor,
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: onApply,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: KZ.sp8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
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
}

// ── Order summary — existing values only, spacing/typography carry the
// hierarchy before any extra decoration. ──
class _OrderSummarySection extends StatelessWidget {
  final Cart cart;

  const _OrderSummarySection({required this.cart});

  Widget _row(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KZ.sp6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: KZ.body.copyWith(
                color: color ?? CartScreen.onSurfaceVariantColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: KZ.sp8),
          Flexible(
            child: Text(
              value,
              style: KZ.body.copyWith(
                color: color ?? CartScreen.onSurfaceColor,
                fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KZ.sp20),
      decoration: KZ.sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'cart.order_summary'.tr(),
            style: KZ.sectionTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: KZ.sp10),
          _row(
            context,
            'cart.subtotal'.tr(),
            formatCurrency(cart.subtotal, locale: context.locale),
          ),
          if (cart.discountTotal > 0)
            _row(
              context,
              'cart.discount'.tr(),
              '-${formatCurrency(cart.discountTotal, locale: context.locale)}',
              color: KZ.tertiary,
            ),
          _row(
            context,
            'cart.delivery_fee'.tr(),
            // Cart-stage deliveryFee is always 0 (zone-specific pricing is
            // resolved at checkout, not before a zone is chosen) — showing
            // "0 SAR" here would read as "free delivery", which it isn't.
            'cart.delivery_fee_at_checkout'.tr(),
          ),
          if (cart.taxTotal > 0)
            _row(
              context,
              'common.tax'.tr(),
              formatCurrency(cart.taxTotal, locale: context.locale),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: KZ.sp12),
            child: Divider(
              height: 1,
              color: CartScreen.outlineVariantColor.withValues(alpha: 0.6),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'cart.total'.tr(),
                  style: KZ.sectionTitle.copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: KZ.sp8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    formatCurrency(cart.grandTotal, locale: context.locale),
                    style: KZ.priceLarge.copyWith(
                      fontSize: 28,
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
