import 'dart:async';
import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kebda_zaman/features/driver/domain/services/driver_location_source.dart';
import 'driver_location_task_handler.dart';

/// Picks the right [DriverLocationSource] for the current platform.
/// Desktop/web builds (customer/admin desktop targets) never construct
/// either implementation — the driver tracking coordinator itself only
/// ever runs for an authenticated DRIVER session, and this factory is only
/// ever called from there.
DriverLocationSource createDriverLocationSource() {
  if (Platform.isAndroid) return AndroidForegroundLocationSource();
  return IosBackgroundLocationSource();
}

/// Android: a genuine foreground Service (via `flutter_foreground_task`,
/// MIT-licensed) running the actual `Geolocator.getPositionStream` call
/// inside its own isolate (`startDriverLocationTask`) — this is what lets
/// GPS collection continue while the app is backgrounded or the screen is
/// locked. It does **not** survive the user force-stopping the app from
/// Android's App Info screen, nor a device reboot (this app does not
/// request `autoRunOnBoot`, since that would mean silently resuming
/// location collection for a delivery that may no longer even be
/// assigned — reconciliation on the next real app open is the intended
/// recovery path, not fully-unattended auto-restart).
class AndroidForegroundLocationSource implements DriverLocationSource {
  StreamController<RawLocationSample>? _controller;
  void Function(Object)? _dataCallback;

  @override
  Future<void> start() async {
    if (await isRunning()) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'kebda_zaman_driver_tracking',
        channelName: 'Delivery tracking',
        channelDescription:
            'Shown while you are delivering an order so your location can '
            'keep updating even if you switch apps or lock your screen.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
        // The service must not outlive the app being fully removed from
        // Recents — a force-stopped/force-quit app must not keep uploading
        // a delivery's location after the driver has, from their
        // perspective, closed the app.
        stopWithTask: true,
      ),
    );

    _controller = StreamController<RawLocationSample>.broadcast();
    _dataCallback = (data) {
      if (data is! Map) return;
      final capturedAtMs = data['capturedAtEpochMs'];
      if (capturedAtMs is! int) return;
      _controller?.add(
        RawLocationSample(
          latitude: (data['latitude'] as num).toDouble(),
          longitude: (data['longitude'] as num).toDouble(),
          accuracyMeters: (data['accuracyMeters'] as num?)?.toDouble(),
          headingDegrees: (data['headingDegrees'] as num?)?.toDouble(),
          speedMps: (data['speedMps'] as num?)?.toDouble(),
          capturedAt: DateTime.fromMillisecondsSinceEpoch(capturedAtMs),
        ),
      );
    };
    FlutterForegroundTask.addTaskDataCallback(_dataCallback!);

    await FlutterForegroundTask.startService(
      serviceId: 5100,
      serviceTypes: const [ForegroundServiceTypes.location],
      notificationTitle: 'Kebda Zaman — Delivering',
      notificationText: 'Sharing your location for an active delivery.',
      callback: startDriverLocationTask,
    );
  }

  @override
  Future<void> stop() async {
    final callback = _dataCallback;
    if (callback != null) {
      FlutterForegroundTask.removeTaskDataCallback(callback);
      _dataCallback = null;
    }
    await FlutterForegroundTask.stopService();
    await _controller?.close();
    _controller = null;
  }

  @override
  Stream<RawLocationSample> positions() =>
      _controller?.stream ?? const Stream.empty();

  @override
  Future<bool> isRunning() => FlutterForegroundTask.isRunningService;
}

/// iOS: no separate service — `CLLocationManager` (via `geolocator_apple`)
/// delivers positions directly to the running app process, in the
/// background too, as long as the user granted "Always" access and the
/// app declares the `location` background mode (see `Info.plist`). This is
/// a first-party OS capability, not something this plugin/app implements
/// itself: iOS decides how long it keeps the process alive, and a
/// force-quit (swiped away in the App Switcher) ends it immediately with
/// no way for any app-level code to prevent that.
class IosBackgroundLocationSource implements DriverLocationSource {
  StreamSubscription<Position>? _sub;
  final _controller = StreamController<RawLocationSample>.broadcast();

  @override
  Future<void> start() async {
    if (_sub != null) return;
    _sub =
        Geolocator.getPositionStream(
          locationSettings: AppleSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            activityType: ActivityType.automotiveNavigation,
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: true,
            allowBackgroundLocationUpdates: true,
          ),
        ).listen((position) {
          _controller.add(
            RawLocationSample(
              latitude: position.latitude,
              longitude: position.longitude,
              accuracyMeters: position.accuracy,
              headingDegrees: position.heading,
              speedMps: position.speed,
              capturedAt: position.timestamp,
            ),
          );
        });
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  @override
  Stream<RawLocationSample> positions() => _controller.stream;

  @override
  Future<bool> isRunning() async => _sub != null;
}
