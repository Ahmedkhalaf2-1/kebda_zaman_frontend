import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_order_status.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/domain/models/kitchen_order.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/kitchen_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Single ticket detail — item names, quantities, variants/addons, special
/// instructions only. No status-change controls: kitchen staff view, they
/// don't act on the order from here. Not restricted to CONFIRMED/PREPARING
/// like the queue list is (see kitchen_notifier.dart), so an already-open
/// ticket keeps rendering even once the order moves past that.
class KitchenTicketScreen extends ConsumerWidget {
  final String orderId;

  const KitchenTicketScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(kitchenOrderProvider(orderId));

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('kitchen.ticket_title'.tr(), style: KZ.pageTitle),
      ),
      body: RefreshIndicator(
        color: KZ.primary,
        onRefresh: () =>
            ref.refresh(kitchenOrderProvider(orderId).future),
        child: orderAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: KZ.primary),
          ),
          error: (e, st) => KZErrorState(
            message: 'common.something_wrong'.tr(),
            retryLabel: 'common.retry'.tr(),
            onRetry: () => ref.invalidate(kitchenOrderProvider(orderId)),
          ),
          data: (order) => _TicketDetail(order: order),
        ),
      ),
    );
  }
}

class _TicketDetail extends StatelessWidget {
  final KitchenOrder order;

  const _TicketDetail({required this.order});

  @override
  Widget build(BuildContext context) {
    final visual = adminOrderStatusVisual(order.status);
    final lang = context.locale.languageCode;

    return ListView(
      padding: const EdgeInsets.all(KZ.screenPadding),
      children: [
        KZCard(
          padding: const EdgeInsets.all(KZ.sp16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('#${order.orderNumber}', style: KZ.pageTitle),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: visual.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(KZ.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(visual.icon, size: 15, color: visual.color),
                        const SizedBox(width: 5),
                        Text(
                          visual.label,
                          style: KZ.label.copyWith(
                            color: visual.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KZ.sp8),
              Row(
                children: [
                  Icon(
                    order.deliveryMethod == FulfillmentType.pickup
                        ? Icons.storefront_rounded
                        : Icons.delivery_dining_rounded,
                    size: 16,
                    color: KZ.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    order.deliveryMethod == FulfillmentType.pickup
                        ? 'checkout.pickup'.tr()
                        : 'checkout.delivery'.tr(),
                    style: KZ.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: KZ.sp16),
        Text('kitchen.items_section'.tr(), style: KZ.sectionTitle),
        const SizedBox(height: KZ.sp10),
        for (final item in order.items) ...[
          _TicketItemCard(item: item, lang: lang),
          const SizedBox(height: KZ.sp10),
        ],
      ],
    );
  }
}

/// Compact row (thumbnail + name + qty + a quick-glance hint of what's
/// customized) that expands into [_ItemDetailSheet] on tap — the full
/// variant/addon/special-instructions breakdown reads far more clearly at
/// that larger size than crammed into every row of a long ticket.
class _TicketItemCard extends StatelessWidget {
  final KitchenOrderItem item;
  final String lang;

  const _TicketItemCard({required this.item, required this.lang});

  bool get _hasNote =>
      item.specialInstructions != null &&
      item.specialInstructions!.trim().isNotEmpty;

  List<KitchenCustomizationSnapshot> get _customizations => [
    if (item.selectedVariant != null) item.selectedVariant!,
    ...item.selectedAddons,
  ];

  @override
  Widget build(BuildContext context) {
    final customizations = _customizations;
    final hintParts = [
      if (customizations.isNotEmpty)
        customizations.map((c) => c.localizedName(lang)).join(', '),
    ];

    return KZCard(
      padding: EdgeInsets.zero,
      onTap: () => _showItemDetail(context),
      child: Padding(
        padding: const EdgeInsets.all(KZ.sp12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: KZFoodImage(
                imageUrl: item.imageUrl ?? '',
                borderRadius: BorderRadius.circular(KZ.radiusMd),
              ),
            ),
            const SizedBox(width: KZ.sp12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.localizedName(lang),
                          style: KZ.itemTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: KZ.primary,
                          borderRadius: BorderRadius.circular(KZ.radiusSm),
                        ),
                        child: Text(
                          '${item.quantity}×',
                          style: KZ.label.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hintParts.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      hintParts.join(' · '),
                      style: KZ.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (_hasNote) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.sticky_note_2_outlined,
                          size: 13,
                          color: KZ.error,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.specialInstructions!.trim(),
                            style: KZ.caption.copyWith(
                              color: KZ.error,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: KZ.outline,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: KZ.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ItemDetailSheet(item: item, lang: lang),
    );
  }
}

/// The "pop-in" full-detail view of a single ticket item — a big image
/// plus clearly-labeled Variant / Add-ons / Special Instructions sections,
/// each shown only when the item actually has one, rather than a flat
/// chip row where "large" and "no onions" read as the same kind of thing.
class _ItemDetailSheet extends StatelessWidget {
  final KitchenOrderItem item;
  final String lang;

  const _ItemDetailSheet({required this.item, required this.lang});

  @override
  Widget build(BuildContext context) {
    final hasNote =
        item.specialInstructions != null &&
        item.specialInstructions!.trim().isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: KZ.outlineVariant,
                  borderRadius: BorderRadius.circular(KZ.radiusFull),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(KZ.radiusLg),
              child: KZFoodImage(
                imageUrl: item.imageUrl ?? '',
                aspectRatio: 16 / 9,
              ),
            ),
            const SizedBox(height: KZ.sp16),
            Row(
              children: [
                Expanded(
                  child: Text(item.localizedName(lang), style: KZ.pageTitle),
                ),
                const SizedBox(width: KZ.sp8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: KZ.primary,
                    borderRadius: BorderRadius.circular(KZ.radiusSm),
                  ),
                  child: Text(
                    '${item.quantity}×',
                    style: KZ.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (item.selectedVariant != null) ...[
              const SizedBox(height: KZ.sp16),
              _DetailSection(
                label: 'kitchen.variant'.tr(),
                child: Text(
                  item.selectedVariant!.localizedName(lang),
                  style: KZ.body.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
            if (item.selectedAddons.isNotEmpty) ...[
              const SizedBox(height: KZ.sp16),
              _DetailSection(
                label: 'kitchen.addons'.tr(),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: item.selectedAddons
                      .map(
                        (a) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: KZ.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(
                              KZ.radiusFull,
                            ),
                            border: Border.all(color: KZ.outlineVariant),
                          ),
                          child: Text(
                            a.localizedName(lang),
                            style: KZ.body,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
            if (hasNote) ...[
              const SizedBox(height: KZ.sp16),
              _DetailSection(
                label: 'kitchen.special_instructions'.tr(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(KZ.sp12),
                  decoration: BoxDecoration(
                    color: KZ.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(KZ.radiusMd),
                    border: Border.all(color: KZ.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.sticky_note_2_rounded,
                        size: 18,
                        color: KZ.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.specialInstructions!.trim(),
                          style: KZ.body.copyWith(
                            color: KZ.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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

class _DetailSection extends StatelessWidget {
  final String label;
  final Widget child;

  const _DetailSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: KZ.caption.copyWith(
            color: KZ.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
