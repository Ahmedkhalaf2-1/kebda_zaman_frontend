import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/offers_admin_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/promo_code.dart';

class OffersManagementScreen extends ConsumerWidget {
  const OffersManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(offersAdminProvider);

    return Scaffold(
      backgroundColor: KZ.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KZ.screenPadding,
            vertical: KZ.sp16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('offers.title'.tr(), style: KZ.pageTitle),
                        const SizedBox(height: 2),
                        Text('offers.subtitle'.tr(), style: KZ.bodySmall),
                      ],
                    ),
                  ),
                  KZButton(
                    label: 'offers.add_promo'.tr(),
                    icon: Icons.add_rounded,
                    onPressed: () => context.push('/admin/offers/add'),
                  ),
                ],
              ),
              const SizedBox(height: KZ.sp16),
              Expanded(
                child: stateAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: KZ.primary),
                  ),
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
                      onRefresh: () async =>
                          ref.invalidate(offersAdminProvider),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 700;
                          return ListView.separated(
                            itemCount: promos.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: KZ.sp10),
                            itemBuilder: (context, index) => _PromoRow(
                              promo: promos[index],
                              isWide: isWide,
                              onEdit: () => context.push(
                                '/admin/offers/edit',
                                extra: promos[index],
                              ),
                              onToggle: () => ref
                                  .read(offersAdminProvider.notifier)
                                  .togglePromoAvailability(promos[index]),
                              onDelete: () =>
                                  _confirmDelete(context, ref, promos[index]),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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

class _PromoRow extends StatelessWidget {
  final PromoCode promo;
  final bool isWide;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _PromoRow({
    required this.promo,
    required this.isWide,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  String _discountLabel() {
    return promo.discountType == DiscountType.percentage
        ? '${promo.value.toStringAsFixed(0)}%'
        : '${promo.value.toStringAsFixed(0)} ${'common.egp'.tr()}';
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final statusBadge = KZStatusBadge(
      label: promo.isActive ? 'offers.active'.tr() : 'offers.inactive'.tr(),
      icon: promo.isActive
          ? Icons.check_circle_rounded
          : Icons.pause_circle_rounded,
      color: promo.isActive ? KZ.tertiary : KZ.secondary,
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(value: promo.isActive, onChanged: (_) => onToggle()),
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: KZ.primary),
          tooltip: 'common.edit'.tr(),
          onPressed: onEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: KZ.error),
          tooltip: 'common.delete'.tr(),
          onPressed: onDelete,
        ),
      ],
    );
    final metaLine =
        '${'offers.validity'.tr()}: ${_formatDate(promo.startDate)} – '
        '${_formatDate(promo.endDate)}'
        '${promo.usageLimit != null ? ' · ${'offers.usage_limit'.tr()}: ${promo.usageLimit}' : ''}';

    return KZCard(
      padding: EdgeInsets.symmetric(
        horizontal: KZ.sp16,
        vertical: isWide ? KZ.sp10 : KZ.sp14,
      ),
      child: isWide
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(KZ.sp8),
                  decoration: BoxDecoration(
                    color: KZ.primaryFixed.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(KZ.radiusMd),
                  ),
                  child: const Icon(Icons.local_offer, color: KZ.primary),
                ),
                const SizedBox(width: KZ.sp12),
                Expanded(
                  flex: 2,
                  child: Text(
                    promo.code,
                    style: KZ.itemTitle.copyWith(letterSpacing: 1),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(_discountLabel(), style: KZ.body),
                ),
                Expanded(flex: 3, child: Text(metaLine, style: KZ.bodySmall)),
                statusBadge,
                actions,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      promo.code,
                      style: KZ.itemTitle.copyWith(letterSpacing: 1),
                    ),
                    statusBadge,
                  ],
                ),
                const SizedBox(height: KZ.sp4),
                Text(_discountLabel(), style: KZ.body),
                const SizedBox(height: 2),
                Text(metaLine, style: KZ.bodySmall),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: actions,
                ),
              ],
            ),
    );
  }
}
