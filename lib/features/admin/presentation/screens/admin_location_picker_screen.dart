import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';

/// Result returned by [AdminLocationPickerScreen] on confirm.
typedef AdminLocationPickResult = ({double latitude, double longitude});

/// Map-based restaurant-location picker for Admin Settings (distance-based
/// delivery pricing migration) — replaces manual latitude/longitude typing.
///
/// Deliberately much simpler than the customer-facing
/// [MapAddressPickerScreen] (`lib/features/customer/presentation/screens/map_address_picker_screen.dart`),
/// whose center-pin/`GoogleMap`/confirm-button pattern this reuses: no
/// reverse geocoding (the admin only needs coordinates, never a street
/// address) and, critically, no automatic device-location fallback on open
/// — the restaurant's location must never be silently replaced by whatever
/// device happens to open this screen. When no valid saved coordinate
/// exists yet, the map opens at the same neutral fallback center the
/// customer picker already uses, and nothing is returned until the admin
/// explicitly taps Confirm.
class AdminLocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const AdminLocationPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<AdminLocationPickerScreen> createState() =>
      _AdminLocationPickerScreenState();
}

class _AdminLocationPickerScreenState extends State<AdminLocationPickerScreen> {
  // Same safe neutral fallback used by the customer address picker
  // (MapAddressPickerScreen._fallbackCenter) — never the device's current
  // location.
  static const LatLng _fallbackCenter = LatLng(30.0444, 31.2357); // Cairo

  late LatLng _target;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _target = (widget.initialLat != null && widget.initialLng != null)
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : _fallbackCenter;
  }

  void _confirm() {
    final lat = _target.latitude;
    final lng = _target.longitude;
    // Unreachable in practice — a GoogleMap camera target is always a
    // valid coordinate — kept as a defensive guard so an invalid pair can
    // never be returned to the caller.
    if (!lat.isFinite ||
        !lng.isFinite ||
        lat < -90 ||
        lat > 90 ||
        lng < -180 ||
        lng > 180) {
      return;
    }
    Navigator.of(
      context,
    ).pop<AdminLocationPickResult>((latitude: lat, longitude: lng));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: KZ.formAppBar(
        context: context,
        title: 'admin_settings.select_location_on_map'.tr(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _target,
                      zoom: 15,
                    ),
                    onMapCreated: (_) => setState(() => _mapReady = true),
                    onCameraMove: (position) => _target = position.target,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                  const IgnorePointer(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: KZ.sp32),
                      child: Icon(
                        Icons.location_pin,
                        size: 44,
                        color: KZ.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KZ.screenPadding,
                KZ.sp12,
                KZ.screenPadding,
                KZ.sp16,
              ),
              child: KZButton(
                label: 'map_picker.confirm'.tr(),
                icon: Icons.check_circle_outline_rounded,
                fullWidth: true,
                onPressed: _mapReady ? _confirm : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
