import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_image_picker.dart';
import 'package:kebda_zaman/features/admin/presentation/screens/admin_location_picker_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';

/// Shared building blocks for the three Restaurant/Operations settings
/// destinations (Restaurant Profile, Working Hours, Order Settings — see
/// admin_shell.dart's information architecture). Extracted from the former
/// single tabbed AdminSettingsScreen so each destination's screen file stays
/// a thin wrapper (its own controllers + save call) rather than a copy of
/// this UI. `PUT /admin/settings` is still full-replace — every screen must
/// `copyWith` only the fields it owns onto the freshly-loaded settings
/// object it received, never construct a bare `RestaurantSettings`.
///
/// All three share one visual language, established once here: a form
/// column capped at [kAdminSettingsFormMaxWidth] so fields never stretch
/// edge-to-edge on wide desktop windows, [AdminSettingsSectionHeading] for
/// every field group, and a single full-width Save action at the bottom.
/// Neutral surfaces (KZ.surface/surfaceContainerLow) dominate; red is
/// reserved for the Save button and meaningful state (open/closed,
/// selected, invalid).

/// Shared latitude/longitude range validity check for the raw text fields —
/// used both by the reactive configuration-error banner and by a save
/// action's pre-submit guard, so they never disagree about what counts as
/// valid.
bool hasValidCoordinateInputs(String latText, String lngText) {
  final lat = double.tryParse(latText.trim());
  final lng = double.tryParse(lngText.trim());
  return lat != null &&
      lng != null &&
      lat.isFinite &&
      lng.isFinite &&
      lat >= -90 &&
      lat <= 90 &&
      lng >= -180 &&
      lng <= 180;
}

/// Shared pricing-fields validity check for the raw text fields — same
/// validate-before-submit role as [hasValidCoordinateInputs], so an
/// obviously-invalid tax rate/minimum never reaches the full-replace
/// `PUT /admin/settings` call only to bounce off the backend's 400.
/// `deliveryFee` isn't included: real delivery pricing is distance-based
/// (Google Maps zone quote via `POST /delivery/quote`), so this flat
/// contract field is left untouched rather than exposed as editable here.
bool hasValidPricingInputs(
  String taxRateText,
  String minOrderAmountText,
  String currencyText,
) {
  final taxRate = double.tryParse(taxRateText.trim());
  final minOrderAmount = double.tryParse(minOrderAmountText.trim());
  return taxRate != null &&
      taxRate.isFinite &&
      taxRate >= 0 &&
      taxRate <= 100 &&
      minOrderAmount != null &&
      minOrderAmount.isFinite &&
      minOrderAmount >= 0 &&
      currencyText.trim().isNotEmpty &&
      currencyText.trim().length <= 10;
}

final RegExp _hhmmPattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

/// Shared `workingHours` validity check — same validate-before-submit role
/// as [hasValidCoordinateInputs]/[hasValidPricingInputs]. The contract
/// requires exactly 7 entries, one per `dayOfWeek` 0-6 with no duplicates,
/// and a well-formed `"HH:MM"` `openTime`/`closeTime` pair whenever a day is
/// open (`null` only allowed when closed) — the backend already rejects a
/// malformed list with a 400, this just gives an admin a clear reason
/// instead of a raw validation error.
bool hasValidWorkingHours(List<DayWorkingHours> hours) {
  if (hours.length != 7) return false;
  final days = hours.map((h) => h.dayOfWeek).toSet();
  if (days.length != 7 || !days.containsAll(const [0, 1, 2, 3, 4, 5, 6])) {
    return false;
  }
  for (final day in hours) {
    if (!day.isOpen) continue;
    final open = day.openTime;
    final close = day.closeTime;
    if (open == null || close == null) return false;
    if (!_hhmmPattern.hasMatch(open) || !_hhmmPattern.hasMatch(close)) {
      return false;
    }
  }
  return true;
}

/// Every Restaurant/Operations settings form is capped at this width and
/// centered, so text fields read comfortably instead of stretching across
/// a wide desktop window.
const double kAdminSettingsFormMaxWidth = 640;

/// Wraps a settings form body with the shared max-width/centering used by
/// all three destinations.
Widget adminSettingsFormWrap(Widget child) {
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: kAdminSettingsFormMaxWidth),
      child: child,
    ),
  );
}

/// The one repeated section-heading motif shared by every Restaurant/
/// Operations settings screen — a small red accent bar plus a title. Same
/// pattern already used across Dashboard/Orders/Menu/Marketing, applied
/// here too so this screen family reads as part of the same system.
class AdminSettingsSectionHeading extends StatelessWidget {
  final String title;
  const AdminSettingsSectionHeading(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: KZ.primary,
            borderRadius: BorderRadius.circular(KZ.radiusFull),
          ),
        ),
        const SizedBox(width: KZ.sp8),
        Expanded(
          child: Text(
            title,
            style: KZ.sectionTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Restaurant Profile section: Identity (name + logo), Contact (phone), and
/// Location (address, timezone, map-picked coordinates) — grouped as three
/// clear sub-sections on a neutral background rather than boxed cards, so
/// this doesn't read like the old tabbed Settings screen. Used by
/// RestaurantProfileScreen.
class AdminSettingsProfileSection extends StatelessWidget {
  final TextEditingController nameArCtrl;
  final TextEditingController nameEnCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController addressArCtrl;
  final TextEditingController addressEnCtrl;
  final TextEditingController timezoneCtrl;
  final TextEditingController logoUrlCtrl;
  final TextEditingController restaurantLatCtrl;
  final TextEditingController restaurantLngCtrl;
  final bool isSaving;
  final ValueChanged<XFile> onLogoPicked;
  final ValueChanged<String> onLogoUrlChanged;
  final VoidCallback onSave;

  const AdminSettingsProfileSection({
    super.key,
    required this.nameArCtrl,
    required this.nameEnCtrl,
    required this.phoneCtrl,
    required this.addressArCtrl,
    required this.addressEnCtrl,
    required this.timezoneCtrl,
    required this.logoUrlCtrl,
    required this.restaurantLatCtrl,
    required this.restaurantLngCtrl,
    required this.isSaving,
    required this.onLogoPicked,
    required this.onLogoUrlChanged,
    required this.onSave,
  });

  /// Opens the map picker seeded with whatever coordinate is currently in
  /// the fields (or `null` if blank/invalid, so the picker falls back to
  /// its own neutral map center — never the device's current location).
  /// Only updates the fields on an explicit confirm; a cancelled pick
  /// (`result == null`) leaves them exactly as they were.
  Future<void> _pickLocationOnMap(BuildContext context) async {
    final currentLat = double.tryParse(restaurantLatCtrl.text.trim());
    final currentLng = double.tryParse(restaurantLngCtrl.text.trim());
    final result = await Navigator.of(context).push<AdminLocationPickResult>(
      MaterialPageRoute(
        builder: (_) => AdminLocationPickerScreen(
          initialLat: currentLat,
          initialLng: currentLng,
        ),
      ),
    );
    if (result == null) return;
    restaurantLatCtrl.text = result.latitude.toString();
    restaurantLngCtrl.text = result.longitude.toString();
  }

  @override
  Widget build(BuildContext context) {
    return adminSettingsFormWrap(
      ListView(
        padding: const EdgeInsets.all(KZ.screenPadding),
        children: [
          // ─── Identity: name first, logo secondary underneath ──────────
          AdminSettingsSectionHeading('admin_settings.section_identity'.tr()),
          const SizedBox(height: KZ.sp12),
          TextFormField(
            controller: nameEnCtrl,
            decoration: KZ.inputDecoration(
              label: 'admin_settings.name_en'.tr(),
              prefixIcon: const Icon(
                Icons.storefront_outlined,
                color: KZ.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: KZ.sp12),
          TextFormField(
            controller: nameArCtrl,
            decoration: KZ.inputDecoration(
              label: 'admin_settings.name_ar'.tr(),
              prefixIcon: const Icon(
                Icons.storefront_outlined,
                color: KZ.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: KZ.sp16),
          Text('admin_settings.logo'.tr(), style: KZ.caption),
          const SizedBox(height: KZ.sp6),
          KZImagePickerWidget(
            currentImageUrl: logoUrlCtrl.text.trim().isNotEmpty
                ? logoUrlCtrl.text.trim()
                : null,
            onImageSelected: onLogoPicked,
            onUrlChanged: onLogoUrlChanged,
          ),

          const SizedBox(height: KZ.sp28),
          AdminSettingsSectionHeading('admin_settings.section_contact'.tr()),
          const SizedBox(height: KZ.sp12),
          TextFormField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: KZ.inputDecoration(
              label: 'admin_settings.phone'.tr(),
              prefixIcon: const Icon(
                Icons.call_outlined,
                color: KZ.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: KZ.sp28),
          AdminSettingsSectionHeading('admin_settings.section_location'.tr()),
          const SizedBox(height: KZ.sp12),
          TextFormField(
            controller: addressEnCtrl,
            decoration: KZ.inputDecoration(
              label: 'admin_settings.address_en'.tr(),
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: KZ.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: KZ.sp12),
          TextFormField(
            controller: addressArCtrl,
            decoration: KZ.inputDecoration(
              label: 'admin_settings.address_ar'.tr(),
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: KZ.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: KZ.sp12),
          TextFormField(
            controller: timezoneCtrl,
            decoration: KZ.inputDecoration(
              label: 'admin_settings.timezone'.tr(),
              hint: 'Africa/Cairo',
              prefixIcon: const Icon(
                Icons.public_rounded,
                color: KZ.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: KZ.sp16),

          // The map/coordinates portion of Location as one coherent block —
          // hint, live validity notice, read-only coordinate readouts, and
          // the map-picker action all together, not scattered controls.
          Text(
            'admin_settings.restaurant_location_hint'.tr(),
            style: KZ.bodySmall,
          ),
          ListenableBuilder(
            listenable: Listenable.merge([
              restaurantLatCtrl,
              restaurantLngCtrl,
            ]),
            builder: (context, _) {
              final isValid = hasValidCoordinateInputs(
                restaurantLatCtrl.text,
                restaurantLngCtrl.text,
              );
              if (isValid) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: KZ.sp8),
                child: Text(
                  'admin_settings.coordinates_missing_error'.tr(),
                  style: KZ.caption.copyWith(color: KZ.error),
                ),
              );
            },
          ),
          const SizedBox(height: KZ.sp10),
          Row(
            children: [
              Expanded(
                child: _CoordinateReadout(
                  label: 'admin_settings.restaurant_latitude'.tr(),
                  controller: restaurantLatCtrl,
                ),
              ),
              const SizedBox(width: KZ.sp12),
              Expanded(
                child: _CoordinateReadout(
                  label: 'admin_settings.restaurant_longitude'.tr(),
                  controller: restaurantLngCtrl,
                ),
              ),
            ],
          ),
          const SizedBox(height: KZ.sp10),
          KZButton(
            label: 'admin_settings.select_location_on_map'.tr(),
            icon: Icons.map_rounded,
            variant: KZButtonVariant.secondary,
            fullWidth: true,
            onPressed: () => _pickLocationOnMap(context),
          ),

          const SizedBox(height: KZ.sp28),
          KZButton(
            label: 'admin.save_settings'.tr(),
            icon: Icons.save_rounded,
            fullWidth: true,
            loading: isSaving,
            onPressed: onSave,
          ),
          const SizedBox(height: KZ.sp32),
        ],
      ),
    );
  }
}

/// Read-only verification display for a single coordinate — reflects
/// [controller]'s current value live (updated only by the map picker or the
/// initial load, never by direct typing) so the admin can confirm what will
/// actually be submitted without an editable-looking text field.
class _CoordinateReadout extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _CoordinateReadout({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final text = value.text.trim();
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KZ.sp12,
            vertical: KZ.sp10,
          ),
          decoration: BoxDecoration(
            color: KZ.surfaceContainerLow,
            borderRadius: BorderRadius.circular(KZ.radiusMd),
            border: Border.all(color: KZ.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: KZ.caption),
              const SizedBox(height: 2),
              Text(
                text.isEmpty ? '—' : text,
                style: KZ.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Working Hours section: the weekly open/close schedule as one repeated,
/// compact day row (Day | Open switch | times) inside a single lightweight
/// bordered list — not seven independent decorative cards — so the whole
/// week scans at a glance. Used by WorkingHoursScreen.
class AdminSettingsHoursSection extends StatelessWidget {
  final List<DayWorkingHours> workingHours;
  final String timezone;
  final bool isSaving;
  final ValueChanged<List<DayWorkingHours>> onChanged;
  final VoidCallback onSave;

  const AdminSettingsHoursSection({
    super.key,
    required this.workingHours,
    required this.timezone,
    required this.isSaving,
    required this.onChanged,
    required this.onSave,
  });

  static const _dayKeys = [
    'sunday',
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];

  Future<void> _pickTime(
    BuildContext context,
    String? current,
    ValueChanged<String> onPicked,
  ) async {
    TimeOfDay initial = const TimeOfDay(hour: 10, minute: 0);
    if (current != null && current.contains(':')) {
      final parts = current.split(':');
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) initial = TimeOfDay(hour: h, minute: m);
    }
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      onPicked('$hh:$mm');
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...workingHours]
      ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

    return adminSettingsFormWrap(
      ListView(
        padding: const EdgeInsets.all(KZ.screenPadding),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KZ.sp12,
              vertical: KZ.sp8,
            ),
            decoration: BoxDecoration(
              color: KZ.surfaceContainerLow,
              borderRadius: BorderRadius.circular(KZ.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.public_rounded,
                  color: KZ.onSurfaceVariant,
                  size: 18,
                ),
                const SizedBox(width: KZ.sp8),
                Expanded(
                  child: Text(
                    'admin_settings.hours_timezone_notice'.tr(
                      namedArgs: {'tz': timezone},
                    ),
                    style: KZ.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KZ.sp8),
          Text(
            'admin_settings.hours_informational_notice'.tr(),
            style: KZ.caption,
          ),
          const SizedBox(height: KZ.sp16),

          // One lightweight bordered list, not seven cards — each row is a
          // fixed height so every day aligns consistently top-to-bottom.
          Container(
            decoration: BoxDecoration(
              color: KZ.surface,
              borderRadius: BorderRadius.circular(KZ.radiusLg),
              border: Border.all(
                color: KZ.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < sorted.length; i++) ...[
                  _DayRow(
                    label: 'admin_settings.day_${_dayKeys[sorted[i].dayOfWeek]}'
                        .tr(),
                    day: sorted[i],
                    onToggle: (v) {
                      final updated = sorted
                          .map(
                            (d) => d.dayOfWeek == sorted[i].dayOfWeek
                                ? d.copyWith(
                                    isOpen: v,
                                    openTime: v ? (d.openTime ?? '10:00') : null,
                                    closeTime: v
                                        ? (d.closeTime ?? '22:00')
                                        : null,
                                  )
                                : d,
                          )
                          .toList();
                      onChanged(updated);
                    },
                    onPickOpen: () => _pickTime(context, sorted[i].openTime, (
                      t,
                    ) {
                      final updated = sorted
                          .map(
                            (d) => d.dayOfWeek == sorted[i].dayOfWeek
                                ? d.copyWith(openTime: t)
                                : d,
                          )
                          .toList();
                      onChanged(updated);
                    }),
                    onPickClose: () => _pickTime(context, sorted[i].closeTime, (
                      t,
                    ) {
                      final updated = sorted
                          .map(
                            (d) => d.dayOfWeek == sorted[i].dayOfWeek
                                ? d.copyWith(closeTime: t)
                                : d,
                          )
                          .toList();
                      onChanged(updated);
                    }),
                  ),
                  if (i != sorted.length - 1)
                    Divider(
                      height: 1,
                      color: KZ.outlineVariant.withValues(alpha: 0.35),
                      indent: KZ.sp14,
                      endIndent: KZ.sp14,
                    ),
                ],
              ],
            ),
          ),

          if (!hasValidWorkingHours(workingHours))
            Padding(
              padding: const EdgeInsets.only(top: KZ.sp10),
              child: Text(
                'admin_settings.invalid_working_hours_error'.tr(),
                style: KZ.caption.copyWith(color: KZ.error),
              ),
            ),

          const SizedBox(height: KZ.sp24),
          KZButton(
            label: 'admin.save_settings'.tr(),
            icon: Icons.save_rounded,
            fullWidth: true,
            loading: isSaving,
            onPressed: onSave,
          ),
          const SizedBox(height: KZ.sp32),
        ],
      ),
    );
  }
}

/// One compact row: Day | Open switch | times. Closed days show a muted
/// "Closed" label instead of time controls — the existing behavior, just
/// restyled (time pickers were already only rendered `if (day.isOpen)`).
class _DayRow extends StatelessWidget {
  final String label;
  final DayWorkingHours day;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickOpen;
  final VoidCallback onPickClose;

  const _DayRow({
    required this.label,
    required this.day,
    required this.onToggle,
    required this.onPickOpen,
    required this.onPickClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KZ.sp14,
        vertical: KZ.sp8,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: KZ.itemTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Transform.scale only affects paint, not layout — without this
          // SizedBox the Switch still reserves its full unscaled footprint,
          // which is exactly the few pixels this row can't spare on a
          // narrow phone with long (e.g. "23:59") times.
          SizedBox(
            width: 44,
            height: 30,
            child: Transform.scale(
              scale: 0.75,
              child: Switch(value: day.isOpen, onChanged: onToggle),
            ),
          ),
          const SizedBox(width: KZ.sp4),
          Expanded(
            child: day.isOpen
                // FittedBox guarantees this never overflows regardless of
                // exact time-text width (locale, digit widths, narrow
                // phones) — it only ever scales down as a last resort, the
                // row fits at its natural size on every width this app
                // actually ships to.
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TimePill(
                          label: day.openTime ?? '--:--',
                          onTap: onPickOpen,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: KZ.sp6),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: KZ.outline,
                          ),
                        ),
                        _TimePill(
                          label: day.closeTime ?? '--:--',
                          onTap: onPickClose,
                        ),
                      ],
                    ),
                  )
                : Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'admin_settings.day_closed'.tr(),
                      style: KZ.bodySmall.copyWith(
                        color: KZ.outline,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _TimePill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KZ.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KZ.sp10,
            vertical: KZ.sp6,
          ),
          decoration: BoxDecoration(
            color: KZ.surfaceContainerLow,
            borderRadius: BorderRadius.circular(KZ.radiusSm),
            border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Text(label, style: KZ.label),
        ),
      ),
    );
  }
}

/// Order Settings section: the manual order-acceptance gate as the
/// dominant, immediately-readable state, with the customer-facing closed
/// message as clearly secondary configuration underneath. Used by
/// OrderSettingsScreen.
class AdminSettingsAcceptanceSection extends StatelessWidget {
  final bool acceptingOrders;
  final TextEditingController closedMessageArCtrl;
  final TextEditingController closedMessageEnCtrl;
  final bool isSaving;
  final ValueChanged<bool> onToggle;
  final VoidCallback onSaveMessages;

  const AdminSettingsAcceptanceSection({
    super.key,
    required this.acceptingOrders,
    required this.closedMessageArCtrl,
    required this.closedMessageEnCtrl,
    required this.isSaving,
    required this.onToggle,
    required this.onSaveMessages,
  });

  @override
  Widget build(BuildContext context) {
    return adminSettingsFormWrap(
      ListView(
        padding: const EdgeInsets.all(KZ.screenPadding),
        children: [
          // The one dominant state on this screen — big enough to read in
          // seconds, semantic color (green/red) used deliberately, not as
          // decoration.
          Container(
            padding: const EdgeInsets.all(KZ.sp20),
            decoration: BoxDecoration(
              color: acceptingOrders
                  ? KZ.tertiary.withValues(alpha: 0.08)
                  : KZ.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(KZ.radiusLg),
              border: Border.all(
                color: acceptingOrders
                    ? KZ.tertiary.withValues(alpha: 0.3)
                    : KZ.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  acceptingOrders
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: acceptingOrders ? KZ.tertiary : KZ.error,
                  size: 32,
                ),
                const SizedBox(width: KZ.sp16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        acceptingOrders
                            ? 'admin_settings.accepting_orders_open'.tr()
                            : 'admin_settings.accepting_orders_closed'.tr(),
                        style: KZ.itemTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'admin_settings.accepting_orders_description'.tr(),
                        style: KZ.bodySmall,
                      ),
                    ],
                  ),
                ),
                Switch(value: acceptingOrders, onChanged: onToggle),
              ],
            ),
          ),

          const SizedBox(height: KZ.sp28),
          // Secondary configuration — visibly lighter weight than the state
          // banner above: a plain caption label, no card boundary.
          Text('admin_settings.closed_message'.tr(), style: KZ.labelLarge),
          const SizedBox(height: KZ.sp4),
          Text(
            'admin_settings.closed_message_hint'.tr(),
            style: KZ.caption,
          ),
          const SizedBox(height: KZ.sp12),
          TextFormField(
            controller: closedMessageEnCtrl,
            maxLines: 2,
            decoration: KZ.inputDecoration(
              label: 'admin_settings.closed_message_en'.tr(),
            ),
          ),
          const SizedBox(height: KZ.sp12),
          TextFormField(
            controller: closedMessageArCtrl,
            maxLines: 2,
            decoration: KZ.inputDecoration(
              label: 'admin_settings.closed_message_ar'.tr(),
            ),
          ),
          const SizedBox(height: KZ.sp16),
          KZButton(
            label: 'admin.save_settings'.tr(),
            icon: Icons.save_rounded,
            fullWidth: true,
            loading: isSaving,
            onPressed: onSaveMessages,
          ),
          const SizedBox(height: KZ.sp32),
        ],
      ),
    );
  }
}

/// Pricing section: tax rate, minimum order amount, and currency — the
/// order-economics fields every checkout total is computed from. Delivery
/// fee is deliberately not editable here: it's distance-based (Google Maps
/// zone quote via `POST /delivery/quote`), not this flat settings value.
/// Used by PricingSettingsScreen.
class AdminSettingsPricingSection extends StatelessWidget {
  final TextEditingController taxRatePercentCtrl;
  final TextEditingController minOrderAmountCtrl;
  final TextEditingController currencyCtrl;
  final bool isSaving;
  final VoidCallback onSave;

  const AdminSettingsPricingSection({
    super.key,
    required this.taxRatePercentCtrl,
    required this.minOrderAmountCtrl,
    required this.currencyCtrl,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return adminSettingsFormWrap(
      ListView(
        padding: const EdgeInsets.all(KZ.screenPadding),
        children: [
          AdminSettingsSectionHeading('admin_settings.section_pricing'.tr()),
          const SizedBox(height: KZ.sp8),
          Text('admin_settings.pricing_hint'.tr(), style: KZ.bodySmall),
          const SizedBox(height: KZ.sp16),
          TextFormField(
            controller: taxRatePercentCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: KZ.inputDecoration(
              label: 'admin_settings.tax_rate_percent'.tr(),
              prefixIcon: const Icon(
                Icons.percent_rounded,
                color: KZ.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: KZ.sp12),
          TextFormField(
            controller: minOrderAmountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: KZ.inputDecoration(
              label: 'admin_settings.min_order_amount'.tr(),
              prefixIcon: const Icon(
                Icons.shopping_bag_outlined,
                color: KZ.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: KZ.sp12),
          TextFormField(
            controller: currencyCtrl,
            textCapitalization: TextCapitalization.characters,
            decoration: KZ.inputDecoration(
              label: 'admin_settings.currency'.tr(),
              hint: 'SAR',
              prefixIcon: const Icon(
                Icons.attach_money_rounded,
                color: KZ.onSurfaceVariant,
              ),
            ),
          ),
          ListenableBuilder(
            listenable: Listenable.merge([
              taxRatePercentCtrl,
              minOrderAmountCtrl,
              currencyCtrl,
            ]),
            builder: (context, _) {
              final isValid = hasValidPricingInputs(
                taxRatePercentCtrl.text,
                minOrderAmountCtrl.text,
                currencyCtrl.text,
              );
              if (isValid) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: KZ.sp8),
                child: Text(
                  'admin_settings.invalid_pricing_error'.tr(),
                  style: KZ.caption.copyWith(color: KZ.error),
                ),
              );
            },
          ),
          const SizedBox(height: KZ.sp24),
          KZButton(
            label: 'admin.save_settings'.tr(),
            icon: Icons.save_rounded,
            fullWidth: true,
            loading: isSaving,
            onPressed: onSave,
          ),
          const SizedBox(height: KZ.sp32),
        ],
      ),
    );
  }
}
