import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/api/token_refresh_coordinator.dart';
import 'auth_notifier.dart';

/// Authoritative outcome of the one-time, per-process cold-start session
/// bootstrap. `loading` is represented by Riverpod's own AsyncLoading state
/// (i.e. before [SessionBootstrapNotifier.build] resolves) rather than as a
/// fourth value here, since `build()` never throws — it always settles into
/// exactly one of these three.
enum SessionBootstrapStatus { authenticated, unauthenticated, recoverableError }

/// Runs exactly once per app process, before any authenticated request is
/// allowed to fire: checks whether a session was saved, and if so performs
/// exactly one awaited refresh (via the single, app-wide
/// TokenRefreshCoordinator) before anything else touches the network.
///
/// Deliberately NOT autoDispose — this must persist for the lifetime of the
/// app regardless of who is watching it (e.g. after SplashScreen navigates
/// away and stops watching), so it never re-runs on a whim.
class SessionBootstrapNotifier extends AsyncNotifier<SessionBootstrapStatus> {
  @override
  Future<SessionBootstrapStatus> build() => _bootstrap();

  Future<SessionBootstrapStatus> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSavedSession = prefs.getBool(AuthNotifier.isLoggedInKey) ?? false;

    if (!hasSavedSession) {
      return SessionBootstrapStatus.unauthenticated;
    }

    final secureStorage = ref.read(secureStorageProvider);
    final storedRefreshToken = await secureStorage.read(
      key: TokenRefreshCoordinator.refreshTokenKey,
    );
    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      // A saved-session flag with no refresh token is unrecoverable locally
      // — do not call /auth/refresh with nothing to send.
      return SessionBootstrapStatus.unauthenticated;
    }

    final coordinator = ref.read(tokenRefreshCoordinatorProvider);
    final outcome = await coordinator.refresh();

    switch (outcome) {
      case RefreshSuccess():
        // Optionally confirm/refresh the cached user now that a valid
        // access token exists, through the existing AuthNotifier flow.
        await ref.read(authNotifierProvider.notifier).confirmRestoredSession();
        return SessionBootstrapStatus.authenticated;
      case RefreshRejected():
        await ref.read(authNotifierProvider.notifier).clearLocalSession();
        return SessionBootstrapStatus.unauthenticated;
      case RefreshNoToken():
        return SessionBootstrapStatus.unauthenticated;
      case RefreshTransientFailure():
        // Do not touch the session or the stored refresh token — this is
        // recoverable, the caller (SplashScreen) should offer a retry.
        return SessionBootstrapStatus.recoverableError;
    }
  }

  /// Re-runs the bootstrap, e.g. from a "Retry" action after a
  /// recoverableError. Safe to call repeatedly.
  Future<void> retry() async {
    state = const AsyncLoading<SessionBootstrapStatus>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(_bootstrap);
  }
}

final sessionBootstrapProvider =
    AsyncNotifierProvider<SessionBootstrapNotifier, SessionBootstrapStatus>(
      () => SessionBootstrapNotifier(),
    );
