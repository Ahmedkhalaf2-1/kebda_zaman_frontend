import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/admin/domain/models/driver_account.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_order_details_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/driver_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Admin Order Details' driver-assignment card — shown only for DELIVERY
/// orders. Assign/reassign/unassign all go through
/// [AdminOrderDetailsNotifier], which always refreshes from the backend's
/// authoritative response (never an optimistic local update), so a rejected
/// mutation (wrong order type, terminal status, inactive driver, or a lost
/// `409 ASSIGNMENT_CHANGED` race) never shows a false success.
class AdminOrderDriverSection extends ConsumerStatefulWidget {
  final String orderId;
  final Order order;

  const AdminOrderDriverSection({
    super.key,
    required this.orderId,
    required this.order,
  });

  @override
  ConsumerState<AdminOrderDriverSection> createState() =>
      _AdminOrderDriverSectionState();
}

class _AdminOrderDriverSectionState
    extends ConsumerState<AdminOrderDriverSection> {
  bool _submitting = false;

  Future<void> _submit(Future<String?> Function() action) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final message = await action();
    if (!mounted) return;
    setState(() => _submitting = false);
    if (message != null) {
      // A rejected assignment (e.g. `409 DRIVER_ALREADY_BUSY`) means the
      // driver directory shown to the admin is now stale — refresh it so
      // the next attempt picks from current availability rather than the
      // same snapshot that just got rejected.
      ref.invalidate(activeDriversForAssignmentProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _openPicker() async {
    final selected = await showDialog<DriverAccount>(
      context: context,
      builder: (ctx) =>
          _DriverPickerDialog(excludeDriverId: widget.order.driverId),
    );
    if (selected == null || !mounted) return;
    await _submit(
      () => ref
          .read(adminOrderDetailsProvider(widget.orderId).notifier)
          .assignDriver(selected.id),
    );
  }

  Future<void> _confirmUnassign() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('admin.driver_unassign_title'.tr()),
        content: Text('admin.driver_unassign_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('common.cancel'.tr()),
          ),
          KZButton(
            label: 'admin.driver_unassign'.tr(),
            variant: KZButtonVariant.destructive,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _submit(
      () => ref
          .read(adminOrderDetailsProvider(widget.orderId).notifier)
          .unassignDriver(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isTerminal = order.status.isTerminal;
    final driversAsync = ref.watch(activeDriversForAssignmentProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'admin.driver_section_title'.tr(),
            style: KZ.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: KZ.secondary,
            ),
          ),
          const SizedBox(height: 8),
          if (order.driverId == null)
            Text('admin.driver_unassigned'.tr(), style: KZ.body)
          else
            driversAsync.when(
              loading: () => const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, st) =>
                  Text('admin.driver_assigned_unknown'.tr(), style: KZ.body),
              data: (drivers) {
                final match = drivers.where((d) => d.id == order.driverId);
                final name = match.isNotEmpty
                    ? match.first.name
                    : 'admin.driver_assigned_unknown'.tr();
                return Text(name, style: KZ.body);
              },
            ),
          const SizedBox(height: 12),
          if (isTerminal)
            Text(
              'admin.driver_terminal_note'.tr(),
              style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
            )
          else
            Row(
              children: [
                Expanded(
                  child: KZButton(
                    label: order.driverId == null
                        ? 'admin.driver_assign'.tr()
                        : 'admin.driver_reassign'.tr(),
                    variant: KZButtonVariant.secondary,
                    loading: _submitting,
                    onPressed: _submitting ? null : _openPicker,
                  ),
                ),
                if (order.driverId != null) ...[
                  const SizedBox(width: KZ.sp8),
                  Expanded(
                    child: KZButton(
                      label: 'admin.driver_unassign'.tr(),
                      variant: KZButtonVariant.destructive,
                      loading: _submitting,
                      onPressed: _submitting ? null : _confirmUnassign,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _DriverPickerDialog extends ConsumerWidget {
  final String? excludeDriverId;

  const _DriverPickerDialog({this.excludeDriverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(activeDriversForAssignmentProvider);

    return AlertDialog(
      title: Text('admin.driver_pick_title'.tr()),
      content: SizedBox(
        width: double.maxFinite,
        child: driversAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(color: KZ.primary)),
          ),
          error: (e, st) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('common.something_wrong'.tr()),
          ),
          data: (drivers) {
            final available = drivers
                .where((d) => d.id != excludeDriverId)
                .toList();
            if (available.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text('admin.driver_none_available'.tr()),
              );
            }
            return SizedBox(
              height: 320,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: available.length,
                itemBuilder: (context, index) {
                  final driver = available[index];
                  // BUSY is the only availability value that blocks
                  // selection — `unknown` (older backend responses that
                  // don't carry the field yet, or a value this build
                  // doesn't recognize) stays selectable rather than being
                  // treated as AVAILABLE *or* locked out, preserving the
                  // pre-availability picker behavior for those cases. The
                  // backend's own `409 DRIVER_ALREADY_BUSY` remains the
                  // real enforcement for any race between this list
                  // loading and the assign tap.
                  final isBusy = driver.availability == DriverAvailability.busy;
                  return ListTile(
                    title: Text(driver.name),
                    subtitle: driver.phone != null ? Text(driver.phone!) : null,
                    trailing: switch (driver.availability) {
                      DriverAvailability.available => Text(
                        'admin.driver_available'.tr(),
                        style: KZ.caption.copyWith(color: KZ.tertiary),
                      ),
                      DriverAvailability.busy => Text(
                        'admin.driver_busy'.tr(),
                        style: KZ.caption.copyWith(color: KZ.error),
                      ),
                      DriverAvailability.unknown => null,
                    },
                    enabled: !isBusy,
                    onTap: isBusy
                        ? null
                        : () => Navigator.of(context).pop(driver),
                  );
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.cancel'.tr()),
        ),
      ],
    );
  }
}
