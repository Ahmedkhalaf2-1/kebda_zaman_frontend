import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/driver/data/driver_location_permission_service.dart';
import 'package:kebda_zaman/features/driver/data/platform_driver_location_source.dart';
import 'package:kebda_zaman/features/driver/domain/models/driver_order.dart';
import 'package:kebda_zaman/features/driver/domain/repositories/driver_order_repository.dart';
import 'package:kebda_zaman/features/driver/domain/services/driver_location_source.dart';
import 'package:kebda_zaman/features/driver/domain/services/upload_rate_limiter.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// What the driver UI should tell the driver right now — distinct from
/// "is a timer/service running", since a running service with no
/// successful uploads yet is not the same thing as actually delivering
/// updates.
enum DriverTrackingStatus {
  /// No eligible (OUT_FOR_DELIVERY, assigned) order — nothing is running.
  stopped,

  /// An eligible order exists but location permission isn't sufficient yet.
  permissionRequired,

  /// The location source is starting/has not produced a first fix yet.
  acquiringGps,

  /// At least one upload has succeeded recently.
  sendingUpdates,

  /// A fix exists but the last upload attempt failed for a
  /// network/5xx/rate-limit reason — retrying, not stopped.
  offline,
}

final driverTrackingStatusProvider = StateProvider<DriverTrackingStatus>(
  (ref) => DriverTrackingStatus.stopped,
);

class _TrackedOrder {
  int assignmentVersion;
  DateTime? lastUploadAt;
  bool inFlight = false;
  int consecutiveFailures = 0;

  _TrackedOrder(this.assignmentVersion);

  Duration get backoffInterval {
    // Bounded backoff: each consecutive failure widens the per-order
    // interval (never below the 5-10s aim, never above 60s), independent
    // of the aggregate rate limiter's own budget.
    final seconds = (5 * (1 << consecutiveFailures)).clamp(5, 60);
    return Duration(seconds: seconds);
  }
}

/// Session-scoped (not screen-scoped) coordinator for driver GPS uploads —
/// constructed once via [driverTrackingCoordinatorProvider] and driven by
/// auth-state and active-order changes, never by a screen's lifecycle. See
/// `DRIVER_DELIVERY_API_CONTRACT.md` Phase 2 for the wire contract this
/// implements.
///
/// One device-location subscription is shared across every currently
/// eligible (OUT_FOR_DELIVERY, still assigned) order; each order keeps only
/// its own [_TrackedOrder] bookkeeping (assignmentVersion, last-upload
/// time, in-flight flag, failure count) — never a queue of past samples.
/// [_latestSample] is the single "current" position everything uploads
/// from; there is no GPS history anywhere in this class.
class DriverTrackingCoordinator with WidgetsBindingObserver {
  DriverTrackingCoordinator(
    this._ref, {
    DriverLocationSource? locationSource,
    Future<DriverLocationPermissionStatus> Function()? checkPermission,
    DateTime Function()? now,
  }) : _locationSource = locationSource ?? createDriverLocationSource(),
       _checkPermission =
           checkPermission ?? DriverLocationPermissionService().checkStatus,
       _now = now ?? DateTime.now;

  final Ref _ref;
  final DriverLocationSource _locationSource;
  final Future<DriverLocationPermissionStatus> Function() _checkPermission;
  final DateTime Function() _now;

  StreamSubscription<RawLocationSample>? _positionSub;
  RawLocationSample? _latestSample;
  final Map<String, _TrackedOrder> _tracked = {};
  Timer? _schedulerTimer;
  late final _rateLimiter = UploadRateLimiter(now: _now);

  /// Bumped every time the session ends (logout/deactivation/account
  /// switch). Captured by value at the start of every async operation;
  /// any callback that resolves after the epoch has moved on is a no-op —
  /// this is what stops a late callback from a previous account restarting
  /// tracking or uploading to the next driver's session.
  int _sessionEpoch = 0;
  bool _sourceStarting = false;
  bool _observing = false;

  static const Duration _schedulerTick = Duration(seconds: 2);
  static const Duration _minUploadInterval = Duration(seconds: 5);

  void _setStatus(DriverTrackingStatus s) {
    // `endSession` runs from this provider's own `onDispose`, which can
    // fire as part of the whole `ProviderContainer` tearing down (app
    // shutdown, or a test disposing its container) — at that point sibling
    // providers are no longer readable. That specific failure mode
    // (`Bad state: ... already disposed`) is swallowed here rather than
    // propagated, since there is no UI left to show a status to anyway.
    try {
      _ref.read(driverTrackingStatusProvider.notifier).state = s;
    } catch (_) {
      // Container disposed mid-teardown — nothing to update.
    }
  }

  void _ensureObserving() {
    if (_observing) return;
    WidgetsBinding.instance.addObserver(this);
    _observing = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Covers "app resume" reconciliation: a delivery may have been
      // reassigned, delivered, or cancelled by an admin while this device
      // was backgrounded.
      reconcile();
    }
  }

  /// Call once, after login/session-restore confirms a DRIVER session (or
  /// after each `driverActiveOrdersProvider` refresh) — fetches the
  /// authoritative active-order list directly from the repository (never
  /// trusts a possibly-stale cached provider value) so a just-completed
  /// pickup's `assignmentVersion` is correct before the first upload for
  /// that order.
  Future<void> reconcile() async {
    final epoch = _sessionEpoch;
    _ensureObserving();
    final repo = _ref.read(driverOrderRepositoryProvider);
    final result = await repo.getActiveOrders(limit: 100);
    if (epoch != _sessionEpoch) return; // session ended while awaiting
    result.fold((f) => null, syncFromActiveOrders);
  }

  /// Same reconciliation as [reconcile], but fed an already-fetched active-
  /// orders list instead of triggering a separate network call — used by
  /// `DriverActiveOrdersNotifier` (which already polls `getActiveOrders`
  /// every cycle) so the coordinator stays in sync without doubling that
  /// request. Safe to call from a stale/late poll tick: nothing here reads
  /// or bumps [_sessionEpoch] itself, since there is no async gap — the
  /// caller's own guard already covers session-epoch safety.
  void syncFromActiveOrders(List<DriverOrder> orders) {
    _ensureObserving();
    final eligible = <String, DriverOrder>{
      for (final o in orders)
        if (o.status == OrderStatus.outForDelivery) o.id: o,
    };
    _tracked.removeWhere((id, _) => !eligible.containsKey(id));
    for (final entry in eligible.entries) {
      final existing = _tracked[entry.key];
      if (existing == null) {
        _tracked[entry.key] = _TrackedOrder(entry.value.assignmentVersion);
      } else if (existing.assignmentVersion != entry.value.assignmentVersion) {
        // A genuinely new assignment epoch for the same order id (e.g.
        // reassigned away and back) — reset failure/backoff state along
        // with the version.
        existing.assignmentVersion = entry.value.assignmentVersion;
        existing.consecutiveFailures = 0;
      }
    }
    _applyTrackedOrdersChanged();
  }

  /// Called right after a pickup PATCH succeeds, with the authoritative
  /// [DriverOrder] returned by that call — starts tracking this order
  /// immediately rather than waiting for the next [reconcile], since the
  /// driver may start moving right away.
  void onPickupConfirmed(DriverOrder order) {
    if (order.status != OrderStatus.outForDelivery) return;
    _tracked[order.id] = _TrackedOrder(order.assignmentVersion);
    _applyTrackedOrdersChanged();
  }

  /// Called when a mutation elsewhere (delivered, or a detail fetch that
  /// discovered reassignment/404) already knows an order is no longer
  /// eligible — stops it immediately without waiting for the next
  /// reconcile.
  void stopTracking(String orderId) {
    if (_tracked.remove(orderId) != null) {
      _applyTrackedOrdersChanged();
    }
  }

  void _applyTrackedOrdersChanged() {
    if (_tracked.isEmpty) {
      _stopEverything();
      return;
    }
    _ensureLocationSourceStarted();
  }

  Future<void> _ensureLocationSourceStarted() async {
    if (_sourceStarting || _positionSub != null) return;
    final epoch = _sessionEpoch;
    _sourceStarting = true;

    final status = await _checkPermission();
    if (epoch != _sessionEpoch) return;

    if (status != DriverLocationPermissionStatus.always &&
        status != DriverLocationPermissionStatus.foregroundOnly) {
      _setStatus(DriverTrackingStatus.permissionRequired);
      _sourceStarting = false;
      return;
    }

    _setStatus(DriverTrackingStatus.acquiringGps);
    await _locationSource.start();
    if (epoch != _sessionEpoch) {
      await _locationSource.stop();
      return;
    }
    _positionSub = _locationSource.positions().listen(_onPosition);
    _startScheduler();
    _sourceStarting = false;
  }

  /// Called by the driver UI's permission dialog after the user grants
  /// access — the coordinator itself never prompts.
  Future<void> onPermissionGranted() => _ensureLocationSourceStarted();

  void _onPosition(RawLocationSample sample) {
    _latestSample = sample;
    if (_ref.read(driverTrackingStatusProvider) ==
        DriverTrackingStatus.acquiringGps) {
      // A fix now exists; whether it actually counts as "sending" is set
      // by the first successful upload, not by GPS acquisition alone.
    }
  }

  void _startScheduler() {
    _schedulerTimer?.cancel();
    _schedulerTimer = Timer.periodic(_schedulerTick, (_) => _schedulerTick_());
  }

  void _schedulerTick_() {
    final sample = _latestSample;
    if (sample == null) return; // still acquiring first fix

    final now = _now();
    // Fair scheduling: process the order that has waited longest first, so
    // no single order can starve the others of the shared budget.
    final due =
        _tracked.entries.where((e) {
          final t = e.value;
          if (t.inFlight) return false;
          final last = t.lastUploadAt;
          final interval = t.consecutiveFailures > 0
              ? t.backoffInterval
              : _minUploadInterval;
          return last == null || now.difference(last) >= interval;
        }).toList()..sort(
          (a, b) => (a.value.lastUploadAt ?? DateTime(0)).compareTo(
            b.value.lastUploadAt ?? DateTime(0),
          ),
        );

    for (final entry in due) {
      if (!_rateLimiter.tryConsume()) break; // aggregate budget exhausted
      _upload(entry.key, entry.value, sample);
    }
  }

  Future<void> _upload(
    String orderId,
    _TrackedOrder tracked,
    RawLocationSample sample,
  ) async {
    final epoch = _sessionEpoch;
    tracked.inFlight = true;
    tracked.lastUploadAt = _now();

    final repo = _ref.read(driverOrderRepositoryProvider);
    final result = await repo.uploadLocation(
      orderId,
      latitude: sample.latitude,
      longitude: sample.longitude,
      capturedAt: sample.capturedAt,
      assignmentVersion: tracked.assignmentVersion,
      accuracyMeters: sample.accuracyMeters,
      headingDegrees: sample.headingDegrees,
      speedMps: sample.speedMps,
    );

    if (epoch != _sessionEpoch) return; // session ended mid-upload
    tracked.inFlight = false;

    await result.fold(
      (failure) async {
        await _handleUploadFailure(orderId, tracked, failure);
      },
      (ack) async {
        // `accepted: false` is a normal outcome (a duplicate/superseded
        // sample) — never treated as a failure; it still proves the
        // connection and auth are fine.
        tracked.consecutiveFailures = 0;
        _setStatus(DriverTrackingStatus.sendingUpdates);
      },
    );
  }

  Future<void> _handleUploadFailure(
    String orderId,
    _TrackedOrder tracked,
    Failure failure,
  ) async {
    final code = failure.cause is ApiException
        ? (failure.cause as ApiException).code
        : null;

    switch (code) {
      case 'ORDER_NOT_ASSIGNED':
      case 'NOT_A_DELIVERY_ORDER':
      case 'ORDER_NOT_OUT_FOR_DELIVERY':
        stopTracking(orderId);
        return;

      case 'ASSIGNMENT_VERSION_MISMATCH':
        // Discard this pending sample for this order and refetch its
        // current assignment before ever trying again — resume only if
        // it's still genuinely eligible.
        await _refetchAssignment(orderId);
        return;

      case 'LOCATION_TOO_OLD':
      case 'LOCATION_TIMESTAMP_IN_FUTURE':
        // Discard the sample; the next fresh fix from the stream is used
        // next tick. Repeated `LOCATION_TIMESTAMP_IN_FUTURE` most likely
        // means the device clock is wrong — surfaced to the driver via
        // the offline status rather than a silent infinite retry loop.
        tracked.consecutiveFailures = (tracked.consecutiveFailures + 1).clamp(
          0,
          4,
        );
        _setStatus(DriverTrackingStatus.offline);
        return;
    }

    if (failure is RateLimitedFailure) {
      final retryAfter = failure.retryAfterSeconds;
      if (retryAfter != null) {
        _rateLimiter.blockUntil(_now().add(Duration(seconds: retryAfter)));
      }
      tracked.consecutiveFailures = (tracked.consecutiveFailures + 1).clamp(
        0,
        4,
      );
      _setStatus(DriverTrackingStatus.offline);
      return;
    }

    if (failure is AuthFailure) {
      // `DRIVER_DEACTIVATED` (no refresh) or a definitively rejected
      // refresh — either way the session is over. The driver repository
      // layer already triggers `endDriverSessionIfAuthFailure` for reads;
      // this upload path does the same so a background upload's own
      // deactivation detection can't lag behind.
      await _ref.read(authNotifierProvider.notifier).clearLocalSession();
      return;
    }

    // NetworkFailure / UnknownFailure / anything else: bounded backoff via
    // the widened per-order interval, then retry with whatever the
    // *latest* position is at that time — never a replay of this same
    // stale sample.
    tracked.consecutiveFailures = (tracked.consecutiveFailures + 1).clamp(0, 4);
    _setStatus(DriverTrackingStatus.offline);
  }

  Future<void> _refetchAssignment(String orderId) async {
    final epoch = _sessionEpoch;
    final repo = _ref.read(driverOrderRepositoryProvider);
    final result = await repo.getOrderById(orderId);
    if (epoch != _sessionEpoch) return;
    result.fold(
      (f) => stopTracking(orderId), // 404 ORDER_NOT_ASSIGNED etc.
      (order) {
        if (order.status != OrderStatus.outForDelivery) {
          stopTracking(orderId);
          return;
        }
        final tracked = _tracked[orderId];
        if (tracked != null) {
          tracked.assignmentVersion = order.assignmentVersion;
          tracked.consecutiveFailures = 0;
        }
      },
    );
  }

  void _stopScheduler() {
    _schedulerTimer?.cancel();
    _schedulerTimer = null;
  }

  Future<void> _stopLocationSource() async {
    await _positionSub?.cancel();
    _positionSub = null;
    _latestSample = null;
    await _locationSource.stop();
  }

  void _stopEverything() {
    _stopScheduler();
    unawaited(_stopLocationSource());
    _setStatus(DriverTrackingStatus.stopped);
  }

  /// Ends the session: cancels location collection, uploads, retries, and
  /// the native background service/subscription, and clears all tracked
  /// state. Bumps [_sessionEpoch] so any already-in-flight callback from
  /// this session (a pending permission check, upload response, or
  /// reconcile fetch) becomes a no-op instead of restarting tracking or
  /// touching the next account's session. Called from `session_coordinator`
  /// on logout, deactivation, and account switch — never from a screen.
  void endSession() {
    _sessionEpoch++;
    _tracked.clear();
    _stopScheduler();
    unawaited(_stopLocationSource());
    _setStatus(DriverTrackingStatus.stopped);
    if (_observing) {
      WidgetsBinding.instance.removeObserver(this);
      _observing = false;
    }
  }

  @visibleForTesting
  Map<String, int> get trackedOrderVersionsForTesting => {
    for (final e in _tracked.entries) e.key: e.value.assignmentVersion,
  };

  @visibleForTesting
  int? consecutiveFailuresForTesting(String orderId) =>
      _tracked[orderId]?.consecutiveFailures;

  @visibleForTesting
  bool isTrackedForTesting(String orderId) => _tracked.containsKey(orderId);

  @visibleForTesting
  bool get isSchedulerRunningForTesting => _schedulerTimer != null;

  @visibleForTesting
  void debugSchedulerTick() => _schedulerTick_();

  @visibleForTesting
  Future<void> debugEnsureLocationSourceStarted() =>
      _ensureLocationSourceStarted();

  @visibleForTesting
  int get sessionEpochForTesting => _sessionEpoch;
}

final driverTrackingCoordinatorProvider = Provider<DriverTrackingCoordinator>((
  ref,
) {
  final coordinator = DriverTrackingCoordinator(ref);
  ref.onDispose(coordinator.endSession);
  return coordinator;
});
