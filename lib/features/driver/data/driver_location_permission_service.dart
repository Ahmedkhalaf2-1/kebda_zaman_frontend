import 'package:geolocator/geolocator.dart';

/// Outcome of a driver location-permission check, collapsed from
/// geolocator's platform enums into exactly the cases the tracking
/// coordinator and driver UI need to distinguish.
enum DriverLocationPermissionStatus {
  /// Device-wide location services are off — no app can get a fix
  /// regardless of its own permission grant.
  serviceDisabled,

  /// Never asked yet, or the user dismissed the dialog without choosing.
  notDetermined,

  /// The user explicitly denied it (not "permanently" — asking again is
  /// still possible).
  denied,

  /// Denied and the OS will no longer show the permission dialog at all;
  /// the only way forward is the device Settings app.
  deniedForever,

  /// Granted only while the app is in the foreground. Sufficient to show
  /// the driver's own position on-screen, but the OS will suspend updates
  /// the moment the app backgrounds/screen locks — not sufficient for the
  /// delivery-tracking use case this permission is being requested for.
  foregroundOnly,

  /// Full "Always"/background grant — required for tracking to survive
  /// backgrounding or a locked screen.
  always,
}

/// Wraps `geolocator`'s permission API with the specific two-step flow this
/// app's driver tracking needs: foreground access is requested first (a
/// single, unremarkable system dialog), and background/"Always" access is
/// only requested afterwards, with the app's own localized explanation
/// shown first — never a blanket request at app startup, and never
/// requested anywhere outside the driver delivery workflow (the customer
/// app never touches this class).
class DriverLocationPermissionService {
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  DriverLocationPermissionStatus _fromGeolocator(LocationPermission p) {
    switch (p) {
      case LocationPermission.denied:
        return DriverLocationPermissionStatus.denied;
      case LocationPermission.deniedForever:
        return DriverLocationPermissionStatus.deniedForever;
      case LocationPermission.whileInUse:
        return DriverLocationPermissionStatus.foregroundOnly;
      case LocationPermission.always:
        return DriverLocationPermissionStatus.always;
      case LocationPermission.unableToDetermine:
        return DriverLocationPermissionStatus.notDetermined;
    }
  }

  /// Checks current status without prompting.
  Future<DriverLocationPermissionStatus> checkStatus() async {
    if (!await isLocationServiceEnabled()) {
      return DriverLocationPermissionStatus.serviceDisabled;
    }
    return _fromGeolocator(await Geolocator.checkPermission());
  }

  /// Step 1: request ordinary foreground ("while in use") access. Callers
  /// should show the localized explanation dialog immediately before
  /// calling this — never call it unprompted on screen load.
  Future<DriverLocationPermissionStatus> requestForegroundAccess() async {
    if (!await isLocationServiceEnabled()) {
      return DriverLocationPermissionStatus.serviceDisabled;
    }
    final result = await Geolocator.requestPermission();
    return _fromGeolocator(result);
  }

  /// Step 2: request the "Always"/background upgrade, only meaningful once
  /// foreground access is already granted. On Android 11+ and iOS, the OS
  /// itself may not show a second in-app dialog at all — it can silently
  /// keep returning `whileInUse` until the user changes it from device
  /// Settings; that is an OS policy this app cannot override, only explain
  /// (see [DriverLocationPermissionStatus.foregroundOnly] handling in the
  /// UI, which should offer [openAppSettings] rather than re-prompting in
  /// a loop).
  Future<DriverLocationPermissionStatus> requestBackgroundAccess() async {
    final result = await Geolocator.requestPermission();
    return _fromGeolocator(result);
  }

  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();
}
