import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';

/// Result returned by [MapAddressPickerScreen] on confirm.
class MapAddressPickResult {
  final double lat;
  final double lng;
  final String street;
  final String city;
  final String area;

  const MapAddressPickResult({
    required this.lat,
    required this.lng,
    this.street = '',
    this.city = '',
    this.area = '',
  });
}

enum MapPickerLocationStatus {
  idle,
  locating,
  located,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
}

/// Pure mapping from a location status to its translation key, kept
/// side-effect free so it can be unit tested without instantiating the
/// [GoogleMap] platform view.
String? mapPickerStatusMessageKey(MapPickerLocationStatus status) {
  switch (status) {
    case MapPickerLocationStatus.serviceDisabled:
      return 'map_picker.service_disabled';
    case MapPickerLocationStatus.permissionDenied:
      return 'map_picker.permission_denied';
    case MapPickerLocationStatus.permissionDeniedForever:
      return 'map_picker.permission_denied_forever';
    case MapPickerLocationStatus.idle:
    case MapPickerLocationStatus.locating:
    case MapPickerLocationStatus.located:
      return null;
  }
}

/// Google Maps address picker: drag the map under a fixed center pin,
/// optionally center on the device's current location first, then confirm
/// to reverse-geocode the chosen coordinates into street/city/area
/// suggestions. Delivery zone is never auto-selected here (VO2.1 scope).
class MapAddressPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapAddressPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<MapAddressPickerScreen> createState() => _MapAddressPickerScreenState();
}

class _MapAddressPickerScreenState extends State<MapAddressPickerScreen> {
  static const LatLng _fallbackCenter = LatLng(30.0444, 31.2357); // Cairo

  GoogleMapController? _mapController;
  late LatLng _target;
  MapPickerLocationStatus _locationStatus = MapPickerLocationStatus.idle;
  bool _isGeocoding = false;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _target = (widget.initialLat != null && widget.initialLng != null)
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : _fallbackCenter;
    if (widget.initialLat == null) {
      _locateCurrentPosition();
    }
  }

  Future<void> _locateCurrentPosition() async {
    setState(() => _locationStatus = MapPickerLocationStatus.locating);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() => _locationStatus = MapPickerLocationStatus.serviceDisabled);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      setState(
        () => _locationStatus = MapPickerLocationStatus.permissionDenied,
      );
      return;
    }
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      setState(
        () => _locationStatus = MapPickerLocationStatus.permissionDeniedForever,
      );
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      final newTarget = LatLng(position.latitude, position.longitude);
      setState(() {
        _target = newTarget;
        _locationStatus = MapPickerLocationStatus.located;
      });
      _mapController?.animateCamera(CameraUpdate.newLatLng(newTarget));
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _locationStatus = MapPickerLocationStatus.permissionDenied,
      );
    }
  }

  Future<void> _confirm() async {
    setState(() => _isGeocoding = true);

    String street = '';
    String city = '';
    String area = '';
    try {
      final placemarks = await placemarkFromCoordinates(
        _target.latitude,
        _target.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        street = [
          p.street,
          p.thoroughfare,
        ].firstWhere((v) => v != null && v.isNotEmpty, orElse: () => '')!;
        city = p.locality ?? p.administrativeArea ?? '';
        area = p.subLocality ?? p.subAdministrativeArea ?? '';
      }
    } catch (_) {
      // Reverse geocoding unavailable — return coordinates only and let
      // the address form stay manually editable.
    }

    if (!mounted) return;
    setState(() => _isGeocoding = false);

    Navigator.of(context).pop(
      MapAddressPickResult(
        lat: _target.latitude,
        lng: _target.longitude,
        street: street,
        city: city,
        area: area,
      ),
    );
  }

  Widget? _statusBanner() {
    final messageKey = mapPickerStatusMessageKey(_locationStatus);
    if (messageKey == null) return null;
    final message = messageKey.tr();
    final icon = _locationStatus == MapPickerLocationStatus.serviceDisabled
        ? Icons.location_off_rounded
        : Icons.location_disabled_rounded;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        KZ.screenPadding,
        KZ.sp12,
        KZ.screenPadding,
        0,
      ),
      padding: const EdgeInsets.all(KZ.sp12),
      decoration: BoxDecoration(
        color: KZ.primaryFixed.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(KZ.radiusMd),
        border: Border.all(color: KZ.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: KZ.primary, size: KZ.iconControl),
          const SizedBox(width: KZ.sp10),
          Expanded(
            child: Text(
              message,
              style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
            ),
          ),
          if (_locationStatus == MapPickerLocationStatus.permissionDenied)
            TextButton(
              onPressed: _locateCurrentPosition,
              child: Text('map_picker.retry'.tr()),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: KZ.formAppBar(context: context, title: 'map_picker.title'.tr()),
      body: SafeArea(
        child: Column(
          children: [
            _statusBanner() ?? const SizedBox.shrink(),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _target,
                      zoom: 16,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      setState(() => _mapReady = true);
                    },
                    onCameraMove: (position) {
                      _target = position.target;
                    },
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
                  if (_locationStatus == MapPickerLocationStatus.locating)
                    Positioned(
                      top: KZ.sp16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KZ.sp16,
                          vertical: KZ.sp10,
                        ),
                        decoration: BoxDecoration(
                          color: KZ.surface,
                          borderRadius: BorderRadius.circular(KZ.radiusFull),
                          boxShadow: KZ.cardShadow,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: KZ.primary,
                              ),
                            ),
                            const SizedBox(width: KZ.sp8),
                            Text(
                              'map_picker.locating'.tr(),
                              style: KZ.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    right: KZ.sp16,
                    bottom: KZ.sp16,
                    child: FloatingActionButton.small(
                      heroTag: 'map_picker_locate',
                      backgroundColor: KZ.surface,
                      foregroundColor: KZ.primary,
                      onPressed: _locateCurrentPosition,
                      child: const Icon(Icons.my_location_rounded),
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
                loading: _isGeocoding,
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
