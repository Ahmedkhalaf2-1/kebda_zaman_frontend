import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_card.dart';
import 'package:kebda_zaman/core/widgets/kz_image_picker.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_settings_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/screens/admin_location_picker_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';

/// Shared latitude/longitude range validity check for the raw text fields —
/// used both by the reactive configuration-error banner and by [_save]'s
/// pre-submit guard, so they never disagree about what counts as valid.
bool _hasValidCoordinateInputs(String latText, String lngText) {
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

/// Settings Center — one organized area for restaurant profile, weekly
/// operating hours, and the manual order-acceptance gate
/// (PHASE_8_RESTAURANT_SETTINGS_API_CONTRACT.md). `PUT /admin/settings` is
/// full-replace, so all three tabs edit one shared in-memory draft and a
/// single Save action submits it — there is no separate local copy per tab.
class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late TextEditingController _nameArCtrl;
  late TextEditingController _nameEnCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressArCtrl;
  late TextEditingController _addressEnCtrl;
  late TextEditingController _timezoneCtrl;
  late TextEditingController _logoUrlCtrl;
  late TextEditingController _restaurantLatCtrl;
  late TextEditingController _restaurantLngCtrl;
  late TextEditingController _closedMessageArCtrl;
  late TextEditingController _closedMessageEnCtrl;

  XFile? _pickedLogoFile;
  List<DayWorkingHours> _workingHours = [];
  bool _acceptingOrders = true;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_initialized) {
      _nameArCtrl.dispose();
      _nameEnCtrl.dispose();
      _phoneCtrl.dispose();
      _addressArCtrl.dispose();
      _addressEnCtrl.dispose();
      _timezoneCtrl.dispose();
      _logoUrlCtrl.dispose();
      _restaurantLatCtrl.dispose();
      _restaurantLngCtrl.dispose();
      _closedMessageArCtrl.dispose();
      _closedMessageEnCtrl.dispose();
    }
    super.dispose();
  }

  void _initFields(RestaurantSettings settings) {
    if (_initialized) return;
    _nameArCtrl = TextEditingController(text: settings.restaurantNameAr);
    _nameEnCtrl = TextEditingController(text: settings.restaurantNameEn);
    _phoneCtrl = TextEditingController(text: settings.phone);
    _addressArCtrl = TextEditingController(text: settings.addressAr);
    _addressEnCtrl = TextEditingController(text: settings.addressEn);
    _timezoneCtrl = TextEditingController(text: settings.timezone);
    _logoUrlCtrl = TextEditingController(text: settings.logoUrl ?? '');
    // Blank (never the literal "null") when the backend didn't return a
    // valid coordinate — the admin sees an empty field plus the
    // configuration-error notice, not a fabricated value.
    _restaurantLatCtrl = TextEditingController(
      text: settings.restaurantLatitude?.toString() ?? '',
    );
    _restaurantLngCtrl = TextEditingController(
      text: settings.restaurantLongitude?.toString() ?? '',
    );
    _closedMessageArCtrl = TextEditingController(
      text: settings.closedMessageAr ?? '',
    );
    _closedMessageEnCtrl = TextEditingController(
      text: settings.closedMessageEn ?? '',
    );
    _workingHours = List.of(settings.workingHours);
    _acceptingOrders = settings.acceptingOrders;
    _initialized = true;
  }

  Future<void> _save(
    RestaurantSettings current, {
    bool? overrideAccepting,
  }) async {
    // Validate before touching network/state — a missing or invalid pair
    // blocks the save entirely rather than silently substituting 0, the
    // production coordinates, or dropping the fields; they keep showing
    // exactly what the admin typed (or left blank) so it can be fixed.
    if (!_hasValidCoordinateInputs(
      _restaurantLatCtrl.text,
      _restaurantLngCtrl.text,
    )) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('admin_settings.invalid_coordinates_error'.tr()),
            backgroundColor: KZ.error,
          ),
        );
      }
      return;
    }
    final restaurantLatitude = double.parse(_restaurantLatCtrl.text.trim());
    final restaurantLongitude = double.parse(_restaurantLngCtrl.text.trim());

    setState(() => _isSaving = true);
    try {
      String? logoUrl = _logoUrlCtrl.text.trim().isEmpty
          ? null
          : _logoUrlCtrl.text.trim();
      if (_pickedLogoFile != null) {
        final bytes = await _pickedLogoFile!.readAsBytes();
        final menuRepo = ref.read(menuRepositoryProvider);
        final uploadResult = await menuRepo.uploadImage(
          bytes,
          _pickedLogoFile!.name,
        );
        logoUrl = uploadResult.fold((f) => logoUrl, (url) => url);
      }

      final updated = current.copyWith(
        restaurantNameAr: _nameArCtrl.text.trim(),
        restaurantNameEn: _nameEnCtrl.text.trim(),
        logoUrl: logoUrl,
        phone: _phoneCtrl.text.trim(),
        addressAr: _addressArCtrl.text.trim(),
        addressEn: _addressEnCtrl.text.trim(),
        restaurantLatitude: restaurantLatitude,
        restaurantLongitude: restaurantLongitude,
        timezone: _timezoneCtrl.text.trim(),
        workingHours: _workingHours,
        acceptingOrders: overrideAccepting ?? _acceptingOrders,
        closedMessageAr: _closedMessageArCtrl.text.trim().isEmpty
            ? null
            : _closedMessageArCtrl.text.trim(),
        closedMessageEn: _closedMessageEnCtrl.text.trim().isEmpty
            ? null
            : _closedMessageEnCtrl.text.trim(),
      );

      await ref.read(adminSettingsProvider.notifier).updateSettings(updated);
      _pickedLogoFile = null;
      _logoUrlCtrl.text = logoUrl ?? '';

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('admin.settings_saved'.tr())));
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

  Future<void> _confirmAndSaveAcceptance(
    RestaurantSettings current,
    bool newValue,
  ) async {
    if (newValue == false) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('admin_settings.close_restaurant_title'.tr()),
          content: Text('admin_settings.close_restaurant_body'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('common.cancel'.tr()),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: KZ.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('admin_settings.close_restaurant_confirm'.tr()),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    setState(() => _acceptingOrders = newValue);
    await _save(current, overrideAccepting: newValue);
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(adminSettingsProvider);

    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('admin_settings.center_title'.tr(), style: KZ.pageTitle),
        bottom: TabBar(
          controller: _tabController,
          labelColor: KZ.primary,
          unselectedLabelColor: KZ.secondary,
          indicatorColor: KZ.primary,
          isScrollable: true,
          tabs: [
            Tab(text: 'admin_settings.tab_profile'.tr()),
            Tab(text: 'admin_settings.tab_hours'.tr()),
            Tab(text: 'admin_settings.tab_acceptance'.tr()),
          ],
        ),
      ),
      body: stateAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: KZ.primary)),
        error: (e, st) => KZErrorState(
          message: 'common.something_wrong'.tr(),
          retryLabel: 'common.retry'.tr(),
          onRetry: () => ref.invalidate(adminSettingsProvider),
        ),
        data: (settings) {
          _initFields(settings);
          return TabBarView(
            controller: _tabController,
            children: [
              _ProfileTab(
                nameArCtrl: _nameArCtrl,
                nameEnCtrl: _nameEnCtrl,
                phoneCtrl: _phoneCtrl,
                addressArCtrl: _addressArCtrl,
                addressEnCtrl: _addressEnCtrl,
                timezoneCtrl: _timezoneCtrl,
                logoUrlCtrl: _logoUrlCtrl,
                restaurantLatCtrl: _restaurantLatCtrl,
                restaurantLngCtrl: _restaurantLngCtrl,
                isSaving: _isSaving,
                onLogoPicked: (xFile) =>
                    setState(() => _pickedLogoFile = xFile),
                onLogoUrlChanged: (url) => setState(() {
                  _pickedLogoFile = null;
                  _logoUrlCtrl.text = url;
                }),
                onSave: () => _save(settings),
              ),
              _HoursTab(
                workingHours: _workingHours,
                timezone: settings.timezone,
                isSaving: _isSaving,
                onChanged: (hours) => setState(() => _workingHours = hours),
                onSave: () => _save(settings),
              ),
              _AcceptanceTab(
                acceptingOrders: _acceptingOrders,
                closedMessageArCtrl: _closedMessageArCtrl,
                closedMessageEnCtrl: _closedMessageEnCtrl,
                isSaving: _isSaving,
                onToggle: (v) => _confirmAndSaveAcceptance(settings, v),
                onSaveMessages: () => _save(settings),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
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

  const _ProfileTab({
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
    return ListView(
      padding: const EdgeInsets.all(KZ.screenPadding),
      children: [
        KZCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('admin_settings.logo'.tr(), style: KZ.labelLarge),
              const SizedBox(height: KZ.sp8),
              KZImagePickerWidget(
                currentImageUrl: logoUrlCtrl.text.trim().isNotEmpty
                    ? logoUrlCtrl.text.trim()
                    : null,
                onImageSelected: onLogoPicked,
                onUrlChanged: onLogoUrlChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: KZ.sp16),
        KZCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'admin_settings.restaurant_profile'.tr(),
                style: KZ.labelLarge,
              ),
              const SizedBox(height: KZ.sp12),
              TextFormField(
                controller: nameEnCtrl,
                decoration: KZ.inputDecoration(
                  label: 'admin_settings.name_en'.tr(),
                  prefixIcon: const Icon(Icons.storefront, color: KZ.primary),
                ),
              ),
              const SizedBox(height: KZ.sp12),
              TextFormField(
                controller: nameArCtrl,
                decoration: KZ.inputDecoration(
                  label: 'admin_settings.name_ar'.tr(),
                  prefixIcon: const Icon(Icons.storefront, color: KZ.primary),
                ),
              ),
              const SizedBox(height: KZ.sp12),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: KZ.inputDecoration(
                  label: 'admin_settings.phone'.tr(),
                  prefixIcon: const Icon(
                    Icons.call_outlined,
                    color: KZ.primary,
                  ),
                ),
              ),
              const SizedBox(height: KZ.sp12),
              TextFormField(
                controller: addressEnCtrl,
                decoration: KZ.inputDecoration(
                  label: 'admin_settings.address_en'.tr(),
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: KZ.primary,
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
                    color: KZ.primary,
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
                    color: KZ.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KZ.sp16),
        KZCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'admin_settings.restaurant_location'.tr(),
                style: KZ.labelLarge,
              ),
              const SizedBox(height: KZ.sp4),
              Text(
                'admin_settings.restaurant_location_hint'.tr(),
                style: KZ.caption,
              ),
              // Reactive, not a one-time snapshot: reflects the current
              // field contents, so it's present the moment the backend
              // returns missing/malformed coordinates and clears the moment
              // the admin has typed a valid replacement pair — never a
              // silently-accepted fallback in either direction.
              ListenableBuilder(
                listenable: Listenable.merge([
                  restaurantLatCtrl,
                  restaurantLngCtrl,
                ]),
                builder: (context, _) {
                  final isValid = _hasValidCoordinateInputs(
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
              const SizedBox(height: KZ.sp12),
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
              const SizedBox(height: KZ.sp12),
              KZButton(
                label: 'admin_settings.select_location_on_map'.tr(),
                icon: Icons.map_rounded,
                variant: KZButtonVariant.secondary,
                fullWidth: true,
                onPressed: () => _pickLocationOnMap(context),
              ),
            ],
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

class _HoursTab extends StatelessWidget {
  final List<DayWorkingHours> workingHours;
  final String timezone;
  final bool isSaving;
  final ValueChanged<List<DayWorkingHours>> onChanged;
  final VoidCallback onSave;

  const _HoursTab({
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

    return ListView(
      padding: const EdgeInsets.all(KZ.screenPadding),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KZ.sp12,
            vertical: KZ.sp8,
          ),
          decoration: BoxDecoration(
            color: KZ.primaryFixed.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(KZ.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.public_rounded, color: KZ.primary, size: 18),
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
        for (final day in sorted) ...[
          KZCard(
            padding: const EdgeInsets.symmetric(
              horizontal: KZ.sp16,
              vertical: KZ.sp12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'admin_settings.day_${_dayKeys[day.dayOfWeek]}'.tr(),
                        style: KZ.itemTitle,
                      ),
                    ),
                    Switch(
                      value: day.isOpen,
                      onChanged: (v) {
                        final updated = sorted
                            .map(
                              (d) => d.dayOfWeek == day.dayOfWeek
                                  ? d.copyWith(
                                      isOpen: v,
                                      openTime: v
                                          ? (d.openTime ?? '10:00')
                                          : null,
                                      closeTime: v
                                          ? (d.closeTime ?? '22:00')
                                          : null,
                                    )
                                  : d,
                            )
                            .toList();
                        onChanged(updated);
                      },
                    ),
                  ],
                ),
                if (day.isOpen)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.schedule_rounded, size: 16),
                          label: Text(day.openTime ?? '--:--'),
                          onPressed: () =>
                              _pickTime(context, day.openTime, (t) {
                                final updated = sorted
                                    .map(
                                      (d) => d.dayOfWeek == day.dayOfWeek
                                          ? d.copyWith(openTime: t)
                                          : d,
                                    )
                                    .toList();
                                onChanged(updated);
                              }),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: KZ.sp8),
                        child: Icon(Icons.arrow_forward_rounded, size: 16),
                      ),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.schedule_rounded, size: 16),
                          label: Text(day.closeTime ?? '--:--'),
                          onPressed: () =>
                              _pickTime(context, day.closeTime, (t) {
                                final updated = sorted
                                    .map(
                                      (d) => d.dayOfWeek == day.dayOfWeek
                                          ? d.copyWith(closeTime: t)
                                          : d,
                                    )
                                    .toList();
                                onChanged(updated);
                              }),
                        ),
                      ),
                    ],
                  )
                else
                  Text('admin_settings.day_closed'.tr(), style: KZ.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: KZ.sp10),
        ],
        const SizedBox(height: KZ.sp16),
        KZButton(
          label: 'admin.save_settings'.tr(),
          icon: Icons.save_rounded,
          fullWidth: true,
          loading: isSaving,
          onPressed: onSave,
        ),
        const SizedBox(height: KZ.sp32),
      ],
    );
  }
}

class _AcceptanceTab extends StatelessWidget {
  final bool acceptingOrders;
  final TextEditingController closedMessageArCtrl;
  final TextEditingController closedMessageEnCtrl;
  final bool isSaving;
  final ValueChanged<bool> onToggle;
  final VoidCallback onSaveMessages;

  const _AcceptanceTab({
    required this.acceptingOrders,
    required this.closedMessageArCtrl,
    required this.closedMessageEnCtrl,
    required this.isSaving,
    required this.onToggle,
    required this.onSaveMessages,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(KZ.screenPadding),
      children: [
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
        const SizedBox(height: KZ.sp16),
        KZCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          ),
        ),
        const SizedBox(height: KZ.sp32),
      ],
    );
  }
}
