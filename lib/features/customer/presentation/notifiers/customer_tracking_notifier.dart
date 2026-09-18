import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/order_tracking.dart';

/// Polls `GET /orders/:id/tracking` roughly every 10s — but only while this
/// provider is actually being watched (autoDispose stops the poll instantly
/// on navigation away/logout, same guarantee every other polling provider
/// in this app gives) and only while the app is foregrounded (a
/// [WidgetsBindingObserver] pauses the timer on background and forces one
/// immediate re-fetch on resume, mirroring `PollingNotifierMixin`'s
/// convention elsewhere in this app — not reused directly here since that
/// mixin targets non-family `AutoDisposeAsyncNotifier`, not a family
/// notifier, and this provider additionally needs to *stop* polling
/// entirely once the state is [TrackingState.ended] rather than polling
/// forever).
///
/// A failed poll is swallowed (kept showing the last-known [OrderTracking])
/// rather than surfaced as [AsyncError] — the whole point of
/// [kTrackingFreshnessThresholdSeconds]-based local aging (computed by the
/// UI from `location.receivedAt`, not by this notifier) is that a stale
/// marker becomes visibly stale even without another successful response;
/// this notifier does not need to "know" that on the network's behalf.
class CustomerTrackingNotifier
    extends AutoDisposeFamilyAsyncNotifier<OrderTracking, String> {
  Timer? _pollTimer;
  bool _inFlight = false;
  bool _disposed = false;
  _TrackingLifecycleObserver? _observer;

  static const Duration _pollInterval = Duration(seconds: 10);

  @override
  Future<OrderTracking> build(String orderId) async {
    final tracking = await _fetch(orderId);
    _armPolling(tracking.state);

    final observer = _TrackingLifecycleObserver(
      onResume: () => _tick(force: true),
      onPause: _cancelTimer,
    );
    WidgetsBinding.instance.addObserver(observer);
    _observer = observer;

    ref.onDispose(() {
      _disposed = true;
      _cancelTimer();
      final obs = _observer;
      if (obs != null) {
        WidgetsBinding.instance.removeObserver(obs);
        _observer = null;
      }
    });

    return tracking;
  }

  Future<OrderTracking> _fetch(String orderId) async {
    final repo = ref.read(trackingRepositoryProvider);
    final result = await repo.getCustomerTracking(orderId);
    return result.fold((f) => throw f, (data) => data);
  }

  /// Starts (or leaves stopped) the periodic timer based on the
  /// most-recently-observed state — never keeps a tight poll loop running
  /// once the backend says tracking has ended. [refresh] (wired to the
  /// screen's own order-status refresh / pull-to-refresh) is the only way
  /// to check again afterwards, e.g. after a reassignment.
  void _armPolling(TrackingState state) {
    _cancelTimer();
    if (state == TrackingState.ended || _disposed) return;
    _pollTimer = Timer.periodic(_pollInterval, (_) => _tick());
  }

  void _cancelTimer() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _tick({bool force = false}) async {
    if (_disposed || (_inFlight && !force)) return;
    _inFlight = true;
    try {
      final latest = await _fetch(arg);
      if (_disposed) return;
      state = AsyncData(latest);
      _armPolling(latest.state);
    } catch (_) {
      // Swallowed — see class doc. The next timer tick (if still armed)
      // retries; `refresh()` is the only path that surfaces an error.
    } finally {
      _inFlight = false;
    }
  }

  /// Explicit refresh (pull-to-refresh, or called after the order-status
  /// stream reports a change) — unlike a background tick, a failure here
  /// is allowed to surface as [AsyncError].
  Future<void> refresh() async {
    state = const AsyncLoading<OrderTracking>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(arg));
    final value = state.valueOrNull;
    if (value != null) _armPolling(value.state);
  }

  @visibleForTesting
  bool get hasActiveTimerForTesting => _pollTimer != null;

  @visibleForTesting
  Future<void> debugTick() => _tick(force: true);
}

class _TrackingLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  final VoidCallback onPause;

  _TrackingLifecycleObserver({required this.onResume, required this.onPause});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResume();
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        onPause();
    }
  }
}

final customerTrackingProvider =
    AutoDisposeAsyncNotifierProvider.family<
      CustomerTrackingNotifier,
      OrderTracking,
      String
    >(CustomerTrackingNotifier.new);
