import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';

/// Runs inside the Android foreground service's own isolate (started via
/// `FlutterForegroundTask.startService(callback: startDriverLocationTask)`)
/// — this is what actually keeps GPS collection alive while the driver's
/// app is backgrounded or the screen is locked on Android; the main
/// isolate's Dart code (including this app's own Timers) is not guaranteed
/// to keep running at all once Android suspends the Activity.
///
/// This handler does the absolute minimum: read positions and forward each
/// one to the main isolate via [FlutterForegroundTask.sendDataToMain]. All
/// actual business logic (which orders are eligible, the upload scheduler,
/// rate limiting, auth, HTTP) intentionally stays in the main isolate,
/// where the existing `ApiClient`/`TokenRefreshCoordinator`/session state
/// already live — duplicating that machinery into a second isolate would
/// be substantial, error-prone surface this phase does not need.
@pragma('vm:entry-point')
void startDriverLocationTask() {
  FlutterForegroundTask.setTaskHandler(_DriverLocationTaskHandler());
}

class _DriverLocationTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _sub;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Medium-high accuracy with a time-based interval (not the maximum
    // "best"/"bestForNavigation" accuracy tier, and not a pure
    // distance-filter): this is the documented battery/freshness
    // trade-off for this feature — `LocationAccuracy.high` (~10m, GPS-based
    // but not the most power-hungry fusion mode) keeps a *stationary*
    // delivery's last-known point from silently going stale purely because
    // the driver hasn't physically moved, while never forcing the highest
    // possible GPS duty cycle continuously.
    _sub =
        Geolocator.getPositionStream(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            intervalDuration: const Duration(seconds: 5),
          ),
        ).listen((position) {
          FlutterForegroundTask.sendDataToMain(<String, dynamic>{
            'latitude': position.latitude,
            'longitude': position.longitude,
            'accuracyMeters': position.accuracy,
            'headingDegrees': position.heading,
            'speedMps': position.speed,
            'capturedAtEpochMs': position.timestamp.millisecondsSinceEpoch,
          });
        });
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Not used — position delivery is driven entirely by the geolocator
    // stream's own callbacks, not a fixed onRepeatEvent tick.
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _sub?.cancel();
    _sub = null;
  }
}
