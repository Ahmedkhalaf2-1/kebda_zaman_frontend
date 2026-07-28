import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/favorites_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/address_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/cart_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/orders_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/loyalty_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/checkout_notifier.dart';

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

    // ── authenticated → unauthenticated ─────────────────────────────────
    if (wasLoggedIn && !nowLoggedIn) {
      _clearUserScopedState(ref);
      return;
    }

    // ── unauthenticated → authenticated ─────────────────────────────────
    if (!wasLoggedIn && nowLoggedIn) {
      _reloadUserScopedState(ref, isGuest: next.user?.isGuest ?? true);
      return;
    }

    // ── authenticated → authenticated, different user (account switch) ──
    if (wasLoggedIn &&
        nowLoggedIn &&
        prevUserId != null &&
        nextUserId != null &&
        prevUserId != nextUserId) {
      _clearUserScopedState(ref);
      _reloadUserScopedState(ref, isGuest: next.user?.isGuest ?? true);
      return;
    }
  }, fireImmediately: false);
});

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
