import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/delivery_quote.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';

/// Coordinate/method pair a quote was last requested for — used to dedupe
/// repeat calls (e.g. widget rebuilds) for the exact same destination.
typedef _RequestKey = ({FulfillmentType method, double lat, double lng});

/// Pre-checkout delivery-fee estimate for the current order type + selected
/// address. `null` state means "no quote applicable" (PICKUP, or no valid
/// delivery coordinates yet) — never a loading/error placeholder.
///
/// Checkout screen drives this by calling [requestQuote] when the delivery
/// method, selected address, or its coordinates change — never on every
/// rebuild. See PHASE checkout distance-pricing migration.
class DeliveryQuoteNotifier extends AutoDisposeAsyncNotifier<DeliveryQuote?> {
  _RequestKey? _lastRequestKey;

  @override
  FutureOr<DeliveryQuote?> build() => null;

  bool _validCoordinates(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (!lat.isFinite || !lng.isFinite) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    if (lat == 0.0 && lng == 0.0) return false;
    return true;
  }

  /// Requests a fresh quote for [deliveryMethod] + [latitude]/[longitude].
  ///
  /// No-ops (clearing to `AsyncData(null)`) for PICKUP or invalid/missing
  /// coordinates — the delivery quote endpoint is never called in either
  /// case. Repeat calls with the same method+coordinates while a previous
  /// call already succeeded or is in flight are ignored; a previously
  /// failed request for the same coordinates is retried.
  Future<void> requestQuote({
    required FulfillmentType deliveryMethod,
    double? latitude,
    double? longitude,
  }) async {
    if (deliveryMethod == FulfillmentType.pickup ||
        !_validCoordinates(latitude, longitude)) {
      _lastRequestKey = null;
      state = const AsyncData(null);
      return;
    }

    final key = (method: deliveryMethod, lat: latitude!, lng: longitude!);
    if (_lastRequestKey == key && !state.hasError) {
      return;
    }
    _lastRequestKey = key;

    state = const AsyncLoading<DeliveryQuote?>().copyWithPrevious(state);
    final repo = ref.read(deliveryQuoteRepositoryProvider);
    final result = await repo.getQuote(
      latitude: latitude,
      longitude: longitude,
    );

    // Ignore a stale in-flight response if the target has since moved on
    // (a newer request already changed the key while this one was pending).
    if (_lastRequestKey != key) return;

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (quote) => AsyncData(quote),
    );
  }

  /// Explicit retry for the last-attempted destination (e.g. the "Try
  /// again" action on a failed quote card).
  Future<void> retry() async {
    final key = _lastRequestKey;
    if (key == null) return;
    _lastRequestKey = null;
    await requestQuote(
      deliveryMethod: key.method,
      latitude: key.lat,
      longitude: key.lng,
    );
  }

  /// Clears any current/pending quote — called when the selected address is
  /// removed or the delivery method changes to PICKUP.
  void clear() {
    _lastRequestKey = null;
    state = const AsyncData(null);
  }
}

final deliveryQuoteProvider =
    AutoDisposeAsyncNotifierProvider<DeliveryQuoteNotifier, DeliveryQuote?>(
      DeliveryQuoteNotifier.new,
    );
