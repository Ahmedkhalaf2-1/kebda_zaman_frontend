import 'package:flutter/foundation.dart';

/// A continuous-refill token bucket shared across every active delivery
/// order on this device, enforcing the backend's aggregate throttle
/// (`DRIVER_LOCATION_THROTTLE`: 60 requests / 60 seconds per driver,
/// DRIVER_DELIVERY_API_CONTRACT.md Phase 2) with real headroom rather than
/// racing right up to the server's own limit.
///
/// [capacityPerMinute] defaults to 40 — well under the server's 60, so a
/// client-side miscount, a retried request, or a brief burst (e.g. two
/// orders both becoming due in the same tick) never actually reaches a
/// backend `429`. The clock is injectable so tests can drive it
/// deterministically without real `sleep`s.
class UploadRateLimiter {
  final int capacityPerMinute;
  final DateTime Function() _now;

  double _tokens;
  DateTime _lastRefill;

  UploadRateLimiter({this.capacityPerMinute = 40, DateTime Function()? now})
    : _now = now ?? DateTime.now,
      _tokens = capacityPerMinute.toDouble(),
      _lastRefill = (now ?? DateTime.now)();

  double get _refillPerMs => capacityPerMinute / 60000.0;

  void _refill() {
    final current = _now();
    final elapsedMs = current.difference(_lastRefill).inMilliseconds;
    if (elapsedMs <= 0) return;
    _tokens = (_tokens + elapsedMs * _refillPerMs).clamp(
      0.0,
      capacityPerMinute.toDouble(),
    );
    _lastRefill = current;
  }

  /// Returns `true` and consumes one token if the budget allows an upload
  /// right now; returns `false` (consuming nothing) otherwise.
  bool tryConsume() {
    _refill();
    if (_tokens < 1.0) return false;
    _tokens -= 1.0;
    return true;
  }

  /// Applies a server-communicated backoff (e.g. a `429`'s `Retry-After`,
  /// or a fixed cooldown after repeated network failures) by zeroing the
  /// budget until [until] — every [tryConsume] call fails until then,
  /// regardless of how much time-based refill would otherwise have
  /// accrued.
  void blockUntil(DateTime until) {
    _refill();
    final msRemaining = until.difference(_now()).inMilliseconds;
    if (msRemaining <= 0) return;
    // Move the refill anchor into the future and drain current tokens —
    // the next _refill() call will correctly compute a negative elapsed
    // time as "no refill yet" once clamped, since `_lastRefill` is now
    // ahead of "now" until the block expires.
    _tokens = 0.0;
    _lastRefill = until;
  }

  @visibleForTesting
  double get tokensForTesting {
    _refill();
    return _tokens;
  }
}
