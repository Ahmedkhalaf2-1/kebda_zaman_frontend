import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/delivery_zone_admin_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/delivery_zone.dart';

const double _kMobileBreakpoint = 700;

class DeliveryZonesScreen extends ConsumerWidget {
  const DeliveryZonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(deliveryZoneAdminProvider);

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
                        Text('delivery_zones.title'.tr(), style: KZ.pageTitle),
                        const SizedBox(height: 2),
                        Text(
                          'delivery_zones.subtitle'.tr(),
                          style: KZ.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  KZButton(
                    label: 'delivery_zones.add_zone'.tr(),
                    icon: Icons.add_rounded,
                    onPressed: () => _openZoneForm(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: KZ.sp16),
              Expanded(
                child: zonesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: KZ.primary),
                  ),
                  error: (e, st) => KZErrorState(
                    message: 'delivery_zones.load_error'.tr(),
                    retryLabel: 'common.retry'.tr(),
                    onRetry: () => ref.invalidate(deliveryZoneAdminProvider),
                  ),
                  data: (zones) {
                    if (zones.isEmpty) {
                      return KZEmptyState(
                        icon: Icons.map_outlined,
                        title: 'delivery_zones.empty'.tr(),
                        actionLabel: 'delivery_zones.add_zone'.tr(),
                        onAction: () => _openZoneForm(context, ref),
                      );
                    }
                    final sorted = [...zones]
                      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                    return RefreshIndicator(
                      color: KZ.primary,
                      onRefresh: () async =>
                          ref.invalidate(deliveryZoneAdminProvider),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide =
                              constraints.maxWidth >= _kMobileBreakpoint;
                          return ListView.separated(
                            itemCount: sorted.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: KZ.sp10),
                            itemBuilder: (context, index) => _ZoneRow(
                              zone: sorted[index],
                              isWide: isWide,
                              onEdit: () => _openZoneForm(
                                context,
                                ref,
                                zone: sorted[index],
                              ),
                              onToggleActive: () => ref
                                  .read(deliveryZoneAdminProvider.notifier)
                                  .toggleActive(sorted[index]),
                              onDelete: () =>
                                  _confirmDelete(context, ref, sorted[index]),
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

  void _openZoneForm(
    BuildContext context,
    WidgetRef ref, {
    DeliveryZone? zone,
  }) {
    showDialog(
      context: context,
      builder: (_) => _ZoneFormDialog(zone: zone),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, DeliveryZone zone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delivery_zones.delete_title'.tr()),
        content: Text(
          'delivery_zones.delete_body'.tr(namedArgs: {'name': zone.nameEn}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('common.cancel'.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: KZ.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(deliveryZoneAdminProvider.notifier)
                    .deleteZone(zone.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('delivery_zones.delete_success'.tr()),
                    ),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('common.something_wrong'.tr()),
                      backgroundColor: KZ.error,
                    ),
                  );
                }
              }
            },
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
  }
}

class _ZoneRow extends StatelessWidget {
  final DeliveryZone zone;
  final bool isWide;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _ZoneRow({
    required this.zone,
    required this.isWide,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusBadge = KZStatusBadge(
      label: zone.isActive
          ? 'delivery_zones.active'.tr()
          : 'delivery_zones.inactive'.tr(),
      icon: zone.isActive
          ? Icons.check_circle_rounded
          : Icons.pause_circle_rounded,
      color: zone.isActive ? KZ.tertiary : KZ.secondary,
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(value: zone.isActive, onChanged: (_) => onToggleActive()),
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

    if (isWide) {
      return KZCard(
        padding: const EdgeInsets.symmetric(
          horizontal: KZ.sp16,
          vertical: KZ.sp10,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text('#${zone.sortOrder}', style: KZ.bodySmall),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '${zone.nameEn} · ${zone.nameAr}',
                style: KZ.itemTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${'delivery_zones.delivery_fee'.tr()}: ${formatCurrency(zone.deliveryFee, locale: context.locale)}',
                style: KZ.bodySmall,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                '${'delivery_zones.minimum_order'.tr()}: ${formatCurrency(zone.minimumOrder, locale: context.locale)}',
                style: KZ.bodySmall,
              ),
            ),
            statusBadge,
            actions,
          ],
        ),
      );
    }

    return KZCard(
      padding: const EdgeInsets.all(KZ.sp14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${zone.nameEn} · ${zone.nameAr}',
                  style: KZ.itemTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              statusBadge,
            ],
          ),
          const SizedBox(height: KZ.sp8),
          Wrap(
            spacing: KZ.sp12,
            runSpacing: KZ.sp4,
            children: [
              Text(
                '${'delivery_zones.delivery_fee'.tr()}: ${formatCurrency(zone.deliveryFee, locale: context.locale)}',
                style: KZ.bodySmall,
              ),
              Text(
                '${'delivery_zones.minimum_order'.tr()}: ${formatCurrency(zone.minimumOrder, locale: context.locale)}',
                style: KZ.bodySmall,
              ),
              Text(
                '${'delivery_zones.sort_order'.tr()}: ${zone.sortOrder}',
                style: KZ.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: KZ.sp4),
          Align(alignment: AlignmentDirectional.centerEnd, child: actions),
        ],
      ),
    );
  }
}

class _ZoneFormDialog extends ConsumerStatefulWidget {
  final DeliveryZone? zone;
  const _ZoneFormDialog({this.zone});

  @override
  ConsumerState<_ZoneFormDialog> createState() => _ZoneFormDialogState();
}

class _ZoneFormDialogState extends ConsumerState<_ZoneFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameArCtrl;
  late final TextEditingController _nameEnCtrl;
  late final TextEditingController _feeCtrl;
  late final TextEditingController _minOrderCtrl;
  late final TextEditingController _sortOrderCtrl;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final z = widget.zone;
    _nameArCtrl = TextEditingController(text: z?.nameAr ?? '');
    _nameEnCtrl = TextEditingController(text: z?.nameEn ?? '');
    _feeCtrl = TextEditingController(text: z?.deliveryFee.toString() ?? '0');
    _minOrderCtrl = TextEditingController(
      text: z?.minimumOrder.toString() ?? '0',
    );
    _sortOrderCtrl = TextEditingController(text: '${z?.sortOrder ?? 0}');
    _isActive = z?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameArCtrl.dispose();
    _nameEnCtrl.dispose();
    _feeCtrl.dispose();
    _minOrderCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final notifier = ref.read(deliveryZoneAdminProvider.notifier);
      final fee = double.tryParse(_feeCtrl.text) ?? 0;
      final minOrder = double.tryParse(_minOrderCtrl.text) ?? 0;
      final sortOrder = int.tryParse(_sortOrderCtrl.text) ?? 0;

      if (widget.zone == null) {
        await notifier.createZone(
          nameAr: _nameArCtrl.text.trim(),
          nameEn: _nameEnCtrl.text.trim(),
          deliveryFee: fee,
          minimumOrder: minOrder,
          isActive: _isActive,
          sortOrder: sortOrder,
        );
      } else {
        await notifier.updateZone(
          widget.zone!.id,
          nameAr: _nameArCtrl.text.trim(),
          nameEn: _nameEnCtrl.text.trim(),
          deliveryFee: fee,
          minimumOrder: minOrder,
          isActive: _isActive,
          sortOrder: sortOrder,
        );
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('delivery_zones.save_success'.tr())),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('common.something_wrong'.tr()),
            backgroundColor: KZ.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.zone == null;
    return AlertDialog(
      title: Text(
        isNew
            ? 'delivery_zones.add_zone'.tr()
            : 'delivery_zones.edit_zone'.tr(),
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameEnCtrl,
                  decoration: KZ.inputDecoration(
                    label: 'delivery_zones.name_en'.tr(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'form.value_required'.tr()
                      : null,
                ),
                const SizedBox(height: KZ.sp12),
                TextFormField(
                  controller: _nameArCtrl,
                  decoration: KZ.inputDecoration(
                    label: 'delivery_zones.name_ar'.tr(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'form.value_required'.tr()
                      : null,
                ),
                const SizedBox(height: KZ.sp12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _feeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: KZ.inputDecoration(
                          label: 'delivery_zones.delivery_fee'.tr(),
                          suffixText: 'common.egp'.tr(),
                        ),
                        validator: (v) {
                          final val = double.tryParse(v ?? '');
                          return val == null || val < 0
                              ? 'form.value_required'.tr()
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: KZ.sp12),
                    Expanded(
                      child: TextFormField(
                        controller: _minOrderCtrl,
                        keyboardType: TextInputType.number,
                        decoration: KZ.inputDecoration(
                          label: 'delivery_zones.minimum_order'.tr(),
                          suffixText: 'common.egp'.tr(),
                        ),
                        validator: (v) {
                          final val = double.tryParse(v ?? '');
                          return val == null || val < 0
                              ? 'form.value_required'.tr()
                              : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KZ.sp12),
                TextFormField(
                  controller: _sortOrderCtrl,
                  keyboardType: TextInputType.number,
                  decoration: KZ.inputDecoration(
                    label: 'delivery_zones.sort_order'.tr(),
                  ),
                ),
                const SizedBox(height: KZ.sp12),
                KZ.toggleRow(
                  label: 'delivery_zones.active'.tr(),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('common.cancel'.tr()),
        ),
        KZButton(
          label: isNew ? 'delivery_zones.add_zone'.tr() : 'common.save'.tr(),
          loading: _isSaving,
          onPressed: _isSaving ? null : _save,
        ),
      ],
    );
  }
}
