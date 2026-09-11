import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared background-polling behavior for admin list providers (Order
/// Management, Kitchen Queue) that need near-real-time updates without a
/// websocket/SSE connection.
///
/// A fixed-interval timer silently re-fetches and replaces [state] with the
/// latest server list while the provider has an active listener —
/// `autoDispose` tears the timer down the moment nothing watches it
/// anymore, so leaving the screen stops polling. A single in-flight guard
/// prevents overlapping requests; an app-lifecycle observer pauses the
/// timer while the app is backgrounded and forces one immediate re-fetch on
/// resume.
///
/// A failed background poll is swallowed — [state] keeps showing whatever
/// data it already had, and the next tick just tries again. Only the
/// notifier's own explicit `refresh()` (pull-to-refresh / retry button)
/// should surface an error to the UI; this mixin never does.
mixin PollingNotifierMixin<T> on AutoDisposeAsyncNotifier<T> {
  Timer? _pollTimer;
  bool _isPolling = false;
  bool _disposed = false;
  _PollingLifecycleObserver? _lifecycleObserver;

  /// How often to poll. Keep at 5s or above — matches the admin UX
  /// requirement and avoids hammering the backend.
  Duration get pollInterval => const Duration(seconds: 5);

  /// Fetches the current authoritative list from the server — the same
  /// call [build] itself makes for the initial load.
  Future<T> fetchLatest();

  /// Override to return `true` while a foreground mutation (e.g. an
  /// optimistic status update awaiting its server response) is in flight,
  /// so a same-moment background poll tick doesn't overwrite it with
  /// stale/pre-mutation data. Defaults to never skipping.
  bool get skipNextPollApply => false;

  /// Starts the periodic background poll and the app-lifecycle observer.
  /// Call once from [build], after the first synchronous fetch. Cleans
  /// itself up automatically via `ref.onDispose`.
  void startPolling() {
    _disposed = false;
    _schedule();

    final observer = _PollingLifecycleObserver(
      onResume: () => _schedule(immediate: true),
      onPause: _cancelTimer,
    );
    WidgetsBinding.instance.addObserver(observer);
    _lifecycleObserver = observer;

    ref.onDispose(() {
      _disposed = true;
      _cancelTimer();
      final obs = _lifecycleObserver;
      if (obs != null) {
        WidgetsBinding.instance.removeObserver(obs);
        _lifecycleObserver = null;
      }
    });
  }

  void _schedule({bool immediate = false}) {
    _cancelTimer();
    if (immediate) _tick();
    _pollTimer = Timer.periodic(pollInterval, (_) => _tick());
  }

  void _cancelTimer() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Exposes whether the periodic timer is currently armed, so tests can
  /// assert it starts on [startPolling] and stops on disposal without
  /// depending on real wall-clock delays.
  @visibleForTesting
  bool get hasActiveTimerForTesting => _pollTimer != null;

  /// Runs exactly one poll tick synchronously with the timer's own logic
  /// (in-flight guard, error-swallowing, [skipNextPollApply] check) — lets
  /// tests exercise a "tick" deterministically instead of waiting for the
  /// real [pollInterval].
  @visibleForTesting
  Future<void> debugTick() => _tick();

  Future<void> _tick() async {
    if (_isPolling || _disposed) return; // never overlap requests
    _isPolling = true;
    try {
      final latest = await fetchLatest();
      if (!_disposed && !skipNextPollApply) {
        state = AsyncData(latest);
      }
    } catch (_) {
      // Transient background failure — keep showing current data, let the
      // next tick retry. Never surface this as AsyncError.
    } finally {
      _isPolling = false;
    }
  }
}

class _PollingLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  final VoidCallback onPause;

  _PollingLifecycleObserver({required this.onResume, required this.onPause});

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
