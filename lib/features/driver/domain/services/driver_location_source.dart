import 'dart:async';

/// A single raw position sample, decoupled from `package:geolocator`'s own
/// `Position` type so the tracking coordinator (and its tests) never need
/// to construct a real platform `Position` object.
class RawLocationSample {
  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final double? headingDegrees;
  final double? speedMps;
  final DateTime capturedAt;

  const RawLocationSample({
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    this.accuracyMeters,
    this.headingDegrees,
    this.speedMps,
  });
}

/// Abstraction over "where do live positions come from", so the tracking
/// coordinator depends on neither `geolocator` nor `flutter_foreground_task`
/// directly and can be tested with a fake stream. Exactly one device-wide
/// subscription exists at a time (see `DriverTrackingCoordinator`) — this
/// interface is deliberately not per-order.
abstract class DriverLocationSource {
  /// Starts collecting positions. On Android this starts the genuine
  /// foreground Service (survives backgrounding/screen lock, does not
  /// survive force-stop/force-quit/reboot/OS kill — see class docs on the
  /// concrete implementation). On iOS this starts a standard
  /// `CLLocationManager` stream configured for background delivery, which
  /// only actually keeps delivering in the background if "Always"
  /// permission was granted; foreground-only permission still works but
  /// stops the instant the app backgrounds (an OS limitation, not a bug).
  Future<void> start();

  /// Stops collection and releases the platform resource (foreground
  /// service / location manager). Idempotent.
  Future<void> stop();

  /// Positions as they arrive. A new [start] call after [stop] must yield a
  /// stream that only emits samples captured after that new start — never
  /// a buffered sample from a previous, already-stopped session.
  Stream<RawLocationSample> positions();

  /// Whether the underlying platform mechanism (Android foreground
  /// service; on iOS this is always `false` since there is no separate
  /// service to query) is currently running. Used only for the driver's
  /// own status display, never for correctness — correctness is entirely
  /// driven by [positions] actually emitting.
  Future<bool> isRunning();
}
