import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_settings_notifier.dart';
import 'package:kebda_zaman/features/admin/presentation/widgets/admin_settings_sections.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';

/// Restaurant group destination: logo, name/phone/address, timezone, and
/// map location. Owns only the profile-shaped fields on [RestaurantSettings]
/// — saving here `copyWith`s just those fields onto the freshly-loaded
/// settings object, so Working Hours / Order Settings values already on the
/// backend are always preserved untouched (see admin_settings_sections.dart).
class RestaurantProfileScreen extends ConsumerStatefulWidget {
  const RestaurantProfileScreen({super.key});

  @override
  ConsumerState<RestaurantProfileScreen> createState() =>
      _RestaurantProfileScreenState();
}

class _RestaurantProfileScreenState
    extends ConsumerState<RestaurantProfileScreen> {
  late TextEditingController _nameArCtrl;
  late TextEditingController _nameEnCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressArCtrl;
  late TextEditingController _addressEnCtrl;
  late TextEditingController _timezoneCtrl;
  late TextEditingController _logoUrlCtrl;
  late TextEditingController _restaurantLatCtrl;
  late TextEditingController _restaurantLngCtrl;

  XFile? _pickedLogoFile;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
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
    _restaurantLatCtrl = TextEditingController(
      text: settings.restaurantLatitude?.toString() ?? '',
    );
    _restaurantLngCtrl = TextEditingController(
      text: settings.restaurantLongitude?.toString() ?? '',
    );
    _initialized = true;
  }

  Future<void> _save(RestaurantSettings current) async {
    if (!hasValidCoordinateInputs(
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

      // Only the fields this screen owns — every other field on `current`
      // (working hours, order acceptance, closed message) is left exactly
      // as loaded.
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

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(adminSettingsProvider);

    return Scaffold(
      backgroundColor: KZ.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text('nav.restaurant_profile'.tr(), style: KZ.pageTitle),
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
          return AdminSettingsProfileSection(
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
            onLogoPicked: (xFile) => setState(() => _pickedLogoFile = xFile),
            onLogoUrlChanged: (url) => setState(() {
              _pickedLogoFile = null;
              _logoUrlCtrl.text = url;
            }),
            onSave: () => _save(settings),
          );
        },
      ),
    );
  }
}
