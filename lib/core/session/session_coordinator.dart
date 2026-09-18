import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/favorites_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/address_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/orders_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/loyalty_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/checkout_notifier.dart';
import 'package:kebda_zaman/features/driver/presentation/notifiers/driver_orders_notifier.dart';
import 'package:kebda_zaman/features/driver/presentation/notifiers/driver_tracking_coordinator.dart';

/// A root-level provider that watches [authNotifierProvider] and reacts to
/// auth-state transitions by clearing or reloading user-scoped providers.
///
/// Rules implemented here:
///   • unauthenticated → authenticated : reload Favorites, Addresses; invalidate Cart, Orders, Loyalty, Checkout
///   • authenticated → unauthenticated : invalidate all user-scoped providers
///   • User A → User B (different user IDs) : treat as a full session switch (clear then reload)
///
/// This is the ONE place that coordinates session lifecycle. AuthNotifier and
/// SessionBootstrapNotifier do NOT call this directly — they only change
/// authNotifierProvider state, and this listener reacts.
///
/// Initialized once from app.dart via [ref.watch(sessionLifecycleProvider)].
/// Favorites/Addresses/Cart/Orders/Loyalty/Checkout are all CUSTOMER-only
/// (`/me/*`) resources server-side. Guests are issued role `CUSTOMER` too
/// (per KZ_API_CONTRACT_FOR_FLUTTER.md), so they're included here — only
/// ADMIN and CASHIER sessions must never trigger these providers.
bool _isCustomerRole(String? role) => role == null || role == 'CUSTOMER';

/// DRIVER-scoped resources (`/driver/*`) — same "never let one account see
/// another's cached data" requirement as the customer block below, but
/// gated on the DRIVER role instead: only ever populated for a DRIVER
/// session, so no other role's login/logout should touch them.
bool _isDriverRole(String? role) => role == 'DRIVER';

final sessionLifecycleProvider = Provider<void>((ref) {
  AuthState? _previous;

  ref.listen<AuthState>(authNotifierProvider, (previous, next) {
    // Ignore the very first emission that runs before the listener receives
    // a "previous" value — the notifier constructor handles initial loading.
    final prev = previous ?? _previous;
    _previous = next;
    if (prev == null) return;

    final wasLoggedIn = prev.isLoggedIn;
    final nowLoggedIn = next.isLoggedIn;
    final prevUserId = prev.user?.id;
    final nextUserId = next.user?.id;
    final wasCustomer = wasLoggedIn && _isCustomerRole(prev.user?.role);
    final nowCustomer = nowLoggedIn && _isCustomerRole(next.user?.role);
    final wasDriver = wasLoggedIn && _isDriverRole(prev.user?.role);
    final nowDriver = nowLoggedIn && _isDriverRole(next.user?.role);

    // ── authenticated → unauthenticated ─────────────────────────────────
    if (wasLoggedIn && !nowLoggedIn) {
      // An ADMIN/CASHIER session never loaded these providers in the first
      // place (see below), so there's nothing customer-scoped to clear.
      if (wasCustomer) _clearUserScopedState(ref);
      if (wasDriver) {
        _clearDriverScopedState(ref);
        if (ref.exists(driverTrackingCoordinatorProvider)) {
          ref.read(driverTrackingCoordinatorProvider).endSession();
        }
      }
      return;
    }

    // ── unauthenticated → authenticated ─────────────────────────────────
    if (!wasLoggedIn && nowLoggedIn) {
      // Only a CUSTOMER (incl. guest) session may fetch /me/* customer data.
      if (nowCustomer) {
        _reloadUserScopedState(ref, isGuest: next.user?.isGuest ?? true);
      }
      // No coordinator `reconcile()` call here: the router sends a freshly
      // authenticated DRIVER straight to the driver orders screen, whose
      // own first fetch (`DriverActiveOrdersNotifier.fetchLatest`) already
      // calls `syncFromActiveOrders` — a second fetch here would just
      // double the network call for the same reconciliation.
      if (nowDriver) _clearDriverScopedState(ref);
      return;
    }

    // ── authenticated → authenticated, different user (account switch) ──
    if (wasLoggedIn &&
        nowLoggedIn &&
        prevUserId != null &&
        nextUserId != null &&
        prevUserId != nextUserId) {
      if (wasCustomer) _clearUserScopedState(ref);
      if (nowCustomer) {
        _reloadUserScopedState(ref, isGuest: next.user?.isGuest ?? true);
      }
      if (wasDriver || nowDriver) {
        // A previous driver session's tracking must never survive into the
        // next account, even when the next account is also a driver — end
        // it unconditionally, then start fresh only if the new session is
        // itself a driver.
        if (ref.exists(driverTrackingCoordinatorProvider)) {
          ref.read(driverTrackingCoordinatorProvider).endSession();
        }
        // Same reasoning as above: the newly routed driver screen's own
        // fetch will sync the coordinator — no separate reconcile() here.
        _clearDriverScopedState(ref);
      }
      return;
    }
  }, fireImmediately: false);
});

/// Invalidates every driver/order provider so a freshly (re)authenticated
/// DRIVER session always fetches fresh — and a previous DRIVER session's
/// cached orders can never leak into whatever logs in next, staff or
/// another driver alike.
///
/// Each call is guarded by [Ref.exists]: invalidating an autoDispose
/// provider that has never been built is a harmless no-op in terms of final
/// state, but it can still eagerly instantiate-then-immediately-invalidate
/// the provider, racing a caller's very next `container.read(...future)`
/// into building it a second time (observed directly via instrumented
/// `PollingNotifierMixin` tracing: two `fetchLatest()` calls, only one
/// `startPolling()` timer path each, no timer/lifecycle event between
/// them). Skipping the invalidate when nothing has read the provider yet —
/// the normal case, since the driver screen never mounts before login
/// resolves — removes that race entirely instead of masking it.
void _clearDriverScopedState(Ref ref) {
  if (ref.exists(driverActiveOrdersProvider)) {
    ref.invalidate(driverActiveOrdersProvider);
  }
  if (ref.exists(driverHistoryProvider)) {
    ref.invalidate(driverHistoryProvider);
  }
  // `driverOrderDetailProvider` is a family — `Ref.exists` only accepts a
  // concrete provider instance (a specific `.family(id)`), not the bare
  // family, so there's no cheap "does any instance exist" check here. An
  // unconditional invalidate of an entirely-unbuilt family has no
  // observable effect (there is nothing to tear down or rebuild), unlike
  // the plain providers above.
  ref.invalidate(driverOrderDetailProvider);
}

/// Immediately clears all user-scoped provider state.
///
/// AutoDispose providers are invalidated so they are disposed; when the UI
/// next reads them they will rebuild with the auth-guard check preventing any
/// protected API call.
///
/// For non-AutoDispose notifiers that have already been initialized (Favorites,
/// Addresses), we call [loadFavorites]/[loadAddresses] — which internally
/// checks [isLoggedIn] and resets to an empty state when unauthenticated —
/// rather than trying to read a possibly-uninitialized notifier.
void _clearUserScopedState(Ref ref) {
  ref.invalidate(customerFavoritesProvider);
  ref.invalidate(addressNotifierProvider);
  ref.invalidate(cartProvider);
  ref.invalidate(ordersProvider);
  ref.invalidate(loyaltyProvider);
  ref.invalidate(checkoutProvider);
}

/// Reloads user-scoped state for the freshly authenticated session.
void _reloadUserScopedState(Ref ref, {required bool isGuest}) {
  ref.invalidate(customerFavoritesProvider);
  ref.invalidate(addressNotifierProvider);
  ref.invalidate(cartProvider);
  ref.invalidate(ordersProvider);
  ref.invalidate(loyaltyProvider);
  ref.invalidate(checkoutProvider);
}
