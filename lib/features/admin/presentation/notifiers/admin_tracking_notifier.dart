import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/order_tracking.dart';

/// Admin/staff equivalent of `CustomerTrackingNotifier` — same polling,
/// pause-on-background, and stop-on-ended rules, against
/// `GET /admin/orders/:id/tracking` instead of the customer endpoint. Kept
/// as its own small notifier rather than a shared generic: the two screens
/// have different lifecycles (this one lives on Admin Order Details, which
/// staff may keep open far longer than a customer's tracking screen) and
/// sharing a single family provider across roles would let one role's
/// staleness/permission assumptions leak into the other.
class AdminTrackingNotifier
    extends AutoDisposeFamilyAsyncNotifier<OrderTracking, String> {
  Timer? _pollTimer;
  bool _inFlight = false;
  bool _disposed = false;
  _AdminTrackingLifecycleObserver? _observer;

  static const Duration _pollInterval = Duration(seconds: 10);

  @override
  Future<OrderTracking> build(String orderId) async {
    final tracking = await _fetch(orderId);
    _armPolling(tracking.state);

    final observer = _AdminTrackingLifecycleObserver(
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
    final result = await repo.getAdminTracking(orderId);
    return result.fold((f) => throw f, (data) => data);
  }

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
      // Swallowed — same convention as CustomerTrackingNotifier.
    } finally {
      _inFlight = false;
    }
  }

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

class _AdminTrackingLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  final VoidCallback onPause;

  _AdminTrackingLifecycleObserver({
    required this.onResume,
    required this.onPause,
  });

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

final adminTrackingProvider =
    AutoDisposeAsyncNotifierProvider.family<
      AdminTrackingNotifier,
      OrderTracking,
      String
    >(AdminTrackingNotifier.new);
