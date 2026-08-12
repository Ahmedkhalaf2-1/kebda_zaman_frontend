import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/menu_offers_admin_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_person_card.dart'
    show AdminStatusPill;
import 'package:kebda_zaman/features/shared/domain/models/menu_offer.dart';

class MenuOffersScreen extends ConsumerWidget {
  const MenuOffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(menuOffersAdminProvider);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('menu_offers.title'.tr(), style: KZ.pageTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: KZ.sp16),
            child: _AddOfferButton(
              onPressed: () => context.push('/admin/menu-offers/add'),
            ),
          ),
        ],
      ),
      body: stateAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: KZ.primary)),
        error: (e, st) => KZErrorState(
          message: 'offers.load_error'.tr(),
          retryLabel: 'common.retry'.tr(),
          onRetry: () => ref.invalidate(menuOffersAdminProvider),
        ),
        data: (offers) {
          if (offers.isEmpty) {
            return KZEmptyState(
              icon: Icons.local_offer_outlined,
              title: 'menu_offers.empty_title'.tr(),
              message: 'menu_offers.empty_message'.tr(),
              actionLabel: 'menu_offers.add_offer'.tr(),
              onAction: () => context.push('/admin/menu-offers/add'),
            );
          }
          final sorted = [...offers]
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          return RefreshIndicator(
            color: KZ.primary,
            onRefresh: () async => ref.invalidate(menuOffersAdminProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: sorted.length,
              itemBuilder: (context, index) => _OfferCard(
                offer: sorted[index],
                onEdit: () => context.push(
                  '/admin/menu-offers/edit',
                  extra: sorted[index],
                ),
                onToggle: () => ref
                    .read(menuOffersAdminProvider.notifier)
                    .toggleOfferActive(sorted[index]),
                onDelete: () => _confirmDelete(context, ref, sorted[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, MenuOffer offer) {
    final label = _primaryLabel(offer);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('menu_offers.delete_title'.tr()),
        content: Text(
          'menu_offers.delete_body'.tr(namedArgs: {'name': label}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KZ.error),
            onPressed: () {
              ref
                  .read(menuOffersAdminProvider.notifier)
                  .deleteMenuOffer(offer.id);
              Navigator.pop(ctx);
            },
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
  }
}

String _primaryLabel(MenuOffer offer) {
  final title = offer.title?.trim();
  if (title != null && title.isNotEmpty) return title;
  return offer.menuItem?.name ?? 'menu_offers.untitled_offer'.tr();
}

/// The one dominant primary action for this screen — same compact
/// header-button pattern as Menu Items/Promo Codes, not a FAB.
class _AddOfferButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddOfferButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text(
          'menu_offers.add_offer'.tr(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: KZ.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: KZ.sp14),
          textStyle: KZ.buttonLabel.copyWith(fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KZ.radiusMd),
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final MenuOffer offer;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _OfferCard({
    required this.offer,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  String _scheduleText() {
    if (offer.startAt != null && offer.endAt != null) {
      return 'menu_offers.schedule_range'.tr(
        namedArgs: {
          'start': formatShortDate(offer.startAt!),
          'end': formatShortDate(offer.endAt!),
        },
      );
    }
    if (offer.startAt != null) {
      return 'menu_offers.schedule_from'.tr(
        namedArgs: {'date': formatShortDate(offer.startAt!)},
      );
    }
    if (offer.endAt != null) {
      return 'menu_offers.schedule_until'.tr(
        namedArgs: {'date': formatShortDate(offer.endAt!)},
      );
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final status = deriveMenuOfferStatus(offer);
    final (statusLabel, statusColor) = switch (status) {
      MenuOfferStatus.active => ('offers.active'.tr(), KZ.tertiary),
      MenuOfferStatus.inactive => ('offers.inactive'.tr(), KZ.secondary),
      MenuOfferStatus.scheduled => (
        'menu_offers.scheduled'.tr(),
        KZ.primary,
      ),
      MenuOfferStatus.expired => ('offers.expired'.tr(), KZ.secondary),
    };

    final itemName = offer.menuItem?.name;
    final hasTitle = offer.title != null && offer.title!.trim().isNotEmpty;
    final primaryText = _primaryLabel(offer);
    final schedule = _scheduleText();

    return Container(
      margin: const EdgeInsets.only(bottom: KZ.sp10),
      decoration: BoxDecoration(
        color: KZ.surface,
        borderRadius: BorderRadius.circular(KZ.radiusMd),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(KZ.sp10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(KZ.radiusSm),
              child: SizedBox(
                width: 64,
                height: 64,
                child: offer.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: offer.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: KZ.surfaceContainerLow,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: KZ.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      )
                    : Container(
                        color: KZ.surfaceContainerLow,
                        child: const Icon(
                          Icons.local_offer_outlined,
                          color: KZ.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: KZ.sp12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          primaryText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: KZ.itemTitle,
                        ),
                      ),
                      const SizedBox(width: KZ.sp6),
                      AdminStatusPill(label: statusLabel, color: statusColor),
                    ],
                  ),
                  if (hasTitle && itemName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'menu_offers.linked_item'.tr(
                        namedArgs: {'name': itemName},
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KZ.bodySmall,
                    ),
                  ],
                  const SizedBox(height: KZ.sp4),
                  Wrap(
                    spacing: KZ.sp10,
                    runSpacing: 2,
                    children: [
                      if (schedule.isNotEmpty)
                        Text(schedule, style: KZ.caption),
                      Text(
                        'menu_offers.sort_order_value'.tr(
                          namedArgs: {'value': '${offer.sortOrder}'},
                        ),
                        style: KZ.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: KZ.sp8),
            SizedBox(
              height: 32,
              width: 32,
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: KZ.onSurfaceVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KZ.radiusMd),
                ),
                onSelected: (val) {
                  if (val == 'edit') {
                    onEdit();
                  } else if (val == 'toggle') {
                    onToggle();
                  } else if (val == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_outlined,
                          color: KZ.onSurfaceVariant,
                          size: 18,
                        ),
                        const SizedBox(width: KZ.sp8),
                        Text('common.edit'.tr()),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          offer.isActive
                              ? Icons.toggle_off_outlined
                              : Icons.toggle_on_rounded,
                          color: offer.isActive ? KZ.error : KZ.tertiary,
                          size: 18,
                        ),
                        const SizedBox(width: KZ.sp8),
                        Text(
                          offer.isActive
                              ? 'offers.deactivate'.tr()
                              : 'offers.activate'.tr(),
                          style: TextStyle(
                            color: offer.isActive ? KZ.error : KZ.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: KZ.error,
                          size: 18,
                        ),
                        const SizedBox(width: KZ.sp8),
                        Text(
                          'common.delete'.tr(),
                          style: const TextStyle(color: KZ.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
