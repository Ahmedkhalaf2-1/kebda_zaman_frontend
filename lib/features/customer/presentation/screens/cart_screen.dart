import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/features/shared/domain/models/cart.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';

import '../notifiers/cart_notifier.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_quantity_stepper.dart';
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

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _runCartAction(Future<void> Function() action) {
    action().catchError((Object e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('common.something_wrong'.tr())));
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
                        Text(
                          'cart.title'.tr(),
                          style: KZ.pageTitle.copyWith(
                            color: CartScreen.primaryColor,
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
                            icon: Icons.shopping_cart_outlined,
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
                                onEdit: () => context.push(
                                  '/item/${item.menuItemId}',
                                  extra: {'cartItemId': item.id},
                                ),
                                onRemove: () => _runCartAction(
                                  () => ref
                                      .read(cartProvider.notifier)
                                      .removeItem(item.id),
                                ),
                                onQuantityChanged: (newQuantity) {
                                  if (newQuantity == 0) {
                                    _runCartAction(
                                      () => ref
                                          .read(cartProvider.notifier)
                                          .removeItem(item.id),
                                    );
                                  } else {
                                    _runCartAction(
                                      () => ref
                                          .read(cartProvider.notifier)
                                          .updateItem(item.id, newQuantity),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: _innerGap),
                            ],

                            const SizedBox(height: _blockGap),
                            _buildPromoSection(cart),
                            const SizedBox(height: _blockGap),
                            _buildOrderSummarySection(cart),
                            const SizedBox(height: _blockGap),
                            _buildRecommendationsSection(),
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

  // ── Promo Code Section matching Stitch HTML ──
  Widget _buildPromoSection(Cart cart) {
    final hasPromo = cart.promoCodeId != null && cart.promoCodeId!.isNotEmpty;

    if (hasPromo) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CartScreen.outlineVariantColor.withValues(alpha: 0.6),
            width: 1.5,
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
            const Icon(
              Icons.sell_rounded,
              color: CartScreen.primaryColor,
              size: KZ.iconControl,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${'cart.applied'.tr()} ${cart.promoCodeId}',
                style: KZ.itemTitle.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Semantics(
              button: true,
              label: 'cart.remove'.tr(),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    'cart.remove'.tr().toUpperCase(),
                    style: KZ.labelLarge.copyWith(
                      color: CartScreen.errorColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CartScreen.outlineVariantColor.withValues(alpha: 0.6),
          width: 1.5,
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
          const Icon(
            Icons.sell_rounded,
            color: CartScreen.primaryColor,
            size: KZ.iconControl,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _promoController,
              style: KZ.bodyLarge,
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
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'cart.apply'.tr(),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
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
                  final errorMsg = e.toString().replaceAll('Exception: ', '');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMsg),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: KZ.error,
                    ),
                  );
                }
              },
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: KZ.iconTapTargetMin,
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'cart.apply'.tr().toUpperCase(),
                  style: KZ.labelLarge.copyWith(
                    color: CartScreen.primaryColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Order Summary Section matching Stitch HTML ──
  Widget _buildOrderSummarySection(Cart cart) {
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
            Text(
              value,
              style: KZ.bodyLarge.copyWith(
                color: color ?? CartScreen.onSurfaceVariantColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
            '${cart.subtotal.toStringAsFixed(0)} ${'common.egp'.tr()}',
          ),
          if (cart.discountTotal > 0)
            row(
              'cart.discount'.tr(),
              '-${cart.discountTotal.toStringAsFixed(0)} ${'common.egp'.tr()}',
              color: KZ.error,
            ),
          row(
            'cart.delivery_fee'.tr(),
            // Cart-stage deliveryFee is always 0 (zone-specific pricing is
            // resolved at checkout, not before a zone is chosen) — showing
            // "0 EGP" here would read as "free delivery", which it isn't.
            'cart.delivery_fee_at_checkout'.tr(),
          ),
          if (cart.taxTotal > 0)
            row(
              'common.tax'.tr(),
              '${cart.taxTotal.toStringAsFixed(0)} ${'common.egp'.tr()}',
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
                    '${cart.grandTotal.toStringAsFixed(0)} ${'common.egp'.tr()}',
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

  // ── Recommendations Section matching Stitch HTML ──
  Widget _buildRecommendationsSection() {
    final recommendations = [
      {'name': 'Mint Lemonade', 'price': 45.0},
      {'name': 'Lava Cake', 'price': 85.0},
      {'name': 'Crispy Fries', 'price': 35.0},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'cart.often_ordered_with'.tr(),
              style: KZ.sectionTitle.copyWith(
                fontSize: 18,
                color: CartScreen.onSurfaceColor,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/menu'),
              style: TextButton.styleFrom(
                minimumSize: const Size(0, KZ.iconTapTargetMin),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                'home.view_all'.tr(),
                style: KZ.labelLarge.copyWith(
                  color: CartScreen.secondaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recommendations.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final rec = recommendations[index];
              return _RecommendationCard(
                name: rec['name'] as String,
                price: rec['price'] as double,
                onAdd: () {
                  final cartItem = CartItem(
                    id: 'ci_${DateTime.now().millisecondsSinceEpoch}',
                    menuItemId: 'rec_$index',
                    productName: rec['name'] as String,
                    productImage: '',
                    basePrice: rec['price'] as double,
                    quantity: 1,
                    selectedOptions: const {},
                    extraQuantities: const {},
                    specialInstructions: '',
                    unitPrice: rec['price'] as double,
                    lineTotal: rec['price'] as double,
                  );
                  ref.read(cartProvider.notifier).addItem(cartItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'home.added_to_cart'.tr(
                          namedArgs: {'name': rec['name'] as String},
                        ),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Cart item card matching Stitch HTML ──
class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  const _CartItemCard({
    required this.item,
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
          color: CartScreen.outlineVariantColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8C2B00).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: KZFoodImage(
              imageUrl: item.productImage,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and Price Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: KZ.itemTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CartScreen.onSurfaceColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          '${item.lineTotal.toStringAsFixed(0)} ${'common.egp'.tr()}',
                          style: KZ.priceLarge.copyWith(
                            fontSize: 18,
                            color: CartScreen.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Edit and Remove Actions
                Row(
                  children: [
                    InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 4,
                        ),
                        child: Text(
                          'common.edit'.tr(),
                          style: KZ.labelLarge.copyWith(
                            color: CartScreen.secondaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 4,
                        ),
                        child: Text(
                          'cart.remove'.tr(),
                          style: KZ.labelLarge.copyWith(
                            color: CartScreen.errorColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Quantity Stepper matching Stitch HTML
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CartScreen.surfaceContainerColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          button: true,
                          label: 'Decrease quantity',
                          child: InkWell(
                            onTap: () => onQuantityChanged(item.quantity - 1),
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.remove_rounded,
                                size: 18,
                                color: CartScreen.secondaryColor,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(minWidth: 36),
                          alignment: Alignment.center,
                          child: Text(
                            '${item.quantity}',
                            style: KZ.priceLarge.copyWith(
                              fontSize: 18,
                              color: CartScreen.onSurfaceColor,
                            ),
                          ),
                        ),
                        Semantics(
                          button: true,
                          label: 'Increase quantity',
                          child: InkWell(
                            onTap: () => onQuantityChanged(item.quantity + 1),
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: CartScreen.primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: CartScreen.primaryColor.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recommendation card matching Stitch HTML ──
class _RecommendationCard extends StatelessWidget {
  final String name;
  final double price;
  final VoidCallback onAdd;

  const _RecommendationCard({
    required this.name,
    required this.price,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CartScreen.outlineVariantColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 112,
              width: double.infinity,
              child: KZFoodImage(
                imageUrl: '',
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: KZ.labelLarge.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: CartScreen.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${price.toStringAsFixed(0)} ${'common.egp'.tr()}',
                    style: KZ.priceLarge.copyWith(
                      fontSize: 14,
                      color: CartScreen.primaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'menu.add'.tr(),
                  child: InkWell(
                    onTap: onAdd,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: CartScreen.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: CartScreen.primaryColor.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sticky checkout CTA matching Stitch HTML ──
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(KZ.radiusFull),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CartScreen.primaryColor,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: CartScreen.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
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
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '•',
                        style: KZ.buttonLabel.copyWith(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    Text(
                      '${widget.total.toStringAsFixed(0)} ${'common.egp'.tr()}',
                      style: KZ.buttonLabel.copyWith(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: KZ.iconInline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
