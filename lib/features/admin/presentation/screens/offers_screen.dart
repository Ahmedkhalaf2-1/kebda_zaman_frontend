import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/offers_admin_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_person_card.dart';
import 'package:kebda_zaman/features/shared/domain/models/promo_code.dart';

class OffersManagementScreen extends ConsumerWidget {
  const OffersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(offersAdminProvider);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('offers.title'.tr(), style: KZ.pageTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: KZ.sp16),
            child: _AddPromoButton(
              onPressed: () => context.push('/admin/offers/add'),
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
          onRetry: () => ref.invalidate(offersAdminProvider),
        ),
        data: (promos) {
          if (promos.isEmpty) {
            return KZEmptyState(
              icon: Icons.local_offer_outlined,
              title: 'offers.empty'.tr(),
              actionLabel: 'offers.add_promo'.tr(),
              onAction: () => context.push('/admin/offers/add'),
            );
          }
          return RefreshIndicator(
            color: KZ.primary,
            onRefresh: () async => ref.invalidate(offersAdminProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: promos.length,
              itemBuilder: (context, index) => _PromoCard(
                promo: promos[index],
                onEdit: () => context.push(
                  '/admin/offers/edit',
                  extra: promos[index],
                ),
                onToggle: () => ref
                    .read(offersAdminProvider.notifier)
                    .togglePromoAvailability(promos[index]),
                onDelete: () => _confirmDelete(context, ref, promos[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, PromoCode promo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('offers.delete_title'.tr()),
        content: Text('offers.delete_body'.tr(namedArgs: {'code': promo.code})),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KZ.error),
            onPressed: () {
              ref.read(offersAdminProvider.notifier).deletePromo(promo.id);
              Navigator.pop(ctx);
            },
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
  }
}

/// The one dominant primary action for this screen — matches the compact
/// header-button pattern already established on Menu Items/Staff.
class _AddPromoButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddPromoButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: Text(
          'offers.add_promo'.tr(),
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

/// Derived, presentation-only state — never a new backend concept. Exhausted
/// takes priority over Expired, which takes priority over the manually-set
/// Inactive flag, since those explain *why* a promo can't be used even if an
/// admin never touched its Active toggle; Active is the fallback when none
/// of the disqualifying conditions hold.
enum _PromoState { active, inactive, expired, exhausted }

_PromoState _deriveState(PromoCode promo) {
  final limit = promo.usageLimit;
  if (limit != null && promo.usageCount >= limit) return _PromoState.exhausted;
  if (DateTime.now().isAfter(promo.endDate)) return _PromoState.expired;
  if (!promo.isActive) return _PromoState.inactive;
  return _PromoState.active;
}

class _PromoCard extends StatelessWidget {
  final PromoCode promo;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _PromoCard({
    required this.promo,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  String _discountLabel(BuildContext context) {
    return promo.discountType == DiscountType.percentage
        ? '${promo.value.toStringAsFixed(0)}%'
        : formatCurrency(promo.value, locale: context.locale);
  }

  String _usageText() {
    final limit = promo.usageLimit;
    if (limit == null) {
      return 'offers.used_unlimited'.tr(
        namedArgs: {'used': '${promo.usageCount}'},
      );
    }
    return 'offers.used_of_limit'.tr(
      namedArgs: {'used': '${promo.usageCount}', 'limit': '$limit'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = _deriveState(promo);
    final (stateLabel, stateColor) = switch (state) {
      _PromoState.active => ('offers.active'.tr(), KZ.tertiary),
      _PromoState.inactive => ('offers.inactive'.tr(), KZ.secondary),
      _PromoState.expired => ('offers.expired'.tr(), KZ.secondary),
      _PromoState.exhausted => ('offers.exhausted'.tr(), KZ.error),
    };

    return AdminPersonCard(
      // The code is the strongest identity element on the card, so it uses
      // the same slot/typography as a person's name in the other
      // People-management-style cards.
      name: promo.code,
      badges: [AdminStatusPill(label: stateLabel, color: stateColor)],
      subtitle: _discountLabel(context),
      metaLine: Wrap(
        spacing: KZ.sp10,
        runSpacing: 2,
        children: [
          Text(
            'offers.valid_until'.tr(
              namedArgs: {'date': formatShortDate(promo.endDate)},
            ),
            style: KZ.caption,
          ),
          Text(_usageText(), style: KZ.caption),
        ],
      ),
      trailing: SizedBox(
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
                    promo.isActive
                        ? Icons.toggle_off_outlined
                        : Icons.toggle_on_rounded,
                    color: promo.isActive ? KZ.error : KZ.tertiary,
                    size: 18,
                  ),
                  const SizedBox(width: KZ.sp8),
                  Text(
                    promo.isActive
                        ? 'offers.deactivate'.tr()
                        : 'offers.activate'.tr(),
                    style: TextStyle(
                      color: promo.isActive ? KZ.error : KZ.tertiary,
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
    );
  }
}
