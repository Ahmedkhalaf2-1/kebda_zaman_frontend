import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/date_formatter.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Quick-preset minutes offered next to "Custom" — Kitchen Ticket and Admin
/// Order Details both use the exact same list, per the task spec.
const List<int> kPreparationTimePresets = [10, 15, 20, 30, 45];

/// Statuses kitchen staff (or an admin override) may still set a
/// preparation time on — mirrors the backend's own validation
/// (422 ORDER_NOT_IN_PREPARATION for any other status). Shared by Kitchen
/// Ticket and Admin Order Details so the two surfaces never drift.
bool isPreparationTimeEditableStatus(OrderStatus status) =>
    status == OrderStatus.confirmed || status == OrderStatus.preparing;

/// Shared "Preparation Time" card used by both KitchenTicketScreen (primary
/// owner) and AdminOrderDetailsScreen (override, ADMIN only) — one place to
/// keep the preset/custom minutes UI and current-value/ETA display in sync
/// between the two surfaces that are allowed to call
/// `PATCH /kitchen/orders/:id/preparation-time`.
///
/// Purely presentational: callers own fetching, mutation, and the
/// submitting flag (matching this codebase's existing convention of
/// widget/screen-local submission state rather than notifier-level state).
class PreparationTimeSection extends StatelessWidget {
  final int? preparationTimeMinutes;
  final String? estimatedDeliveryTime;
  final FulfillmentType deliveryMethod;

  /// Whether this order's status currently allows editing (CONFIRMED or
  /// PREPARING). When `false`, only the current value/ETA (if any) is
  /// shown — no preset/custom controls, per the task spec.
  final bool editable;

  /// True while a PATCH is in flight — disables the controls and shows
  /// compact progress feedback without blanking the rest of the section.
  final bool submitting;

  final ValueChanged<int> onSetMinutes;

  const PreparationTimeSection({
    super.key,
    required this.preparationTimeMinutes,
    required this.estimatedDeliveryTime,
    required this.deliveryMethod,
    required this.editable,
    required this.submitting,
    required this.onSetMinutes,
  });

  bool get _isPickup => deliveryMethod == FulfillmentType.pickup;

  String get _etaLabel =>
      (_isPickup ? 'kitchen.prep_time_ready' : 'kitchen.prep_time_arrival')
          .tr();

  @override
  Widget build(BuildContext context) {
    final hasValue = preparationTimeMinutes != null;
    final etaText = formatEtaClockTime(estimatedDeliveryTime);

    return KZCard(
      padding: const EdgeInsets.all(KZ.sp16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'kitchen.prep_time_title'.tr(),
                  style: KZ.sectionTitle,
                ),
              ),
              if (submitting)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: KZ.primary,
                  ),
                ),
            ],
          ),
          if (hasValue) ...[
            const SizedBox(height: KZ.sp10),
            Text(
              'kitchen.prep_time_minutes_value'.tr(
                namedArgs: {'minutes': '$preparationTimeMinutes'},
              ),
              style: KZ.itemTitle,
            ),
            if (etaText != null) ...[
              const SizedBox(height: 2),
              Text(
                '$_etaLabel: $etaText',
                style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
              ),
            ],
          ],
          if (editable) ...[
            const SizedBox(height: KZ.sp12),
            Wrap(
              spacing: KZ.sp8,
              runSpacing: KZ.sp8,
              children: [
                for (final preset in kPreparationTimePresets)
                  KZChip(
                    label: 'kitchen.prep_time_minutes_value'.tr(
                      namedArgs: {'minutes': '$preset'},
                    ),
                    selected: preparationTimeMinutes == preset,
                    onTap: submitting ? null : () => onSetMinutes(preset),
                  ),
                KZChip(
                  label:
                      (hasValue &&
                              !kPreparationTimePresets.contains(
                                preparationTimeMinutes,
                              )
                          ? 'kitchen.prep_time_minutes_value'.tr(
                              namedArgs: {
                                'minutes': '$preparationTimeMinutes',
                              },
                            )
                          : 'kitchen.prep_time_custom'.tr()),
                  selected:
                      hasValue &&
                      !kPreparationTimePresets.contains(
                        preparationTimeMinutes,
                      ),
                  onTap: submitting
                      ? null
                      : () => showPreparationTimeCustomDialog(
                          context,
                          initialMinutes: preparationTimeMinutes,
                        ).then((minutes) {
                          if (minutes != null) onSetMinutes(minutes);
                        }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact dialog for entering a custom preparation time (1..180 minutes).
/// Returns the entered minutes, or `null` if cancelled.
Future<int?> showPreparationTimeCustomDialog(
  BuildContext context, {
  int? initialMinutes,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _PreparationTimeCustomDialog(initialMinutes: initialMinutes),
  );
}

class _PreparationTimeCustomDialog extends StatefulWidget {
  final int? initialMinutes;

  const _PreparationTimeCustomDialog({this.initialMinutes});

  @override
  State<_PreparationTimeCustomDialog> createState() =>
      _PreparationTimeCustomDialogState();
}

class _PreparationTimeCustomDialogState
    extends State<_PreparationTimeCustomDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialMinutes != null ? '${widget.initialMinutes}' : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final minutes = int.tryParse(value?.trim() ?? '');
    if (minutes == null || minutes < 1 || minutes > 180) {
      return 'kitchen.prep_time_range_error'.tr();
    }
    return null;
  }

  void _confirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final minutes = int.parse(_controller.text.trim());
    Navigator.of(context).pop(minutes);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: KZ.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KZ.radiusLg),
      ),
      title: Text('kitchen.prep_time_enter'.tr(), style: KZ.sectionTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'kitchen.prep_time_minutes_label'.tr(),
          ),
          validator: _validate,
          onFieldSubmitted: (_) => _confirm(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('common.cancel'.tr()),
        ),
        TextButton(
          onPressed: _confirm,
          child: Text('common.confirm'.tr()),
        ),
      ],
    );
  }
}
