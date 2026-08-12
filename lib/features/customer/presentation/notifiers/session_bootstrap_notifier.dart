import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/api/token_refresh_coordinator.dart';
import 'package:kebda_zaman/core/services/biometric_preference_store.dart';
import 'package:kebda_zaman/core/services/biometric_service.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'auth_notifier.dart';

/// Authoritative outcome of the one-time, per-process cold-start session
/// bootstrap. `loading` is represented by Riverpod's own AsyncLoading state
/// (i.e. before [SessionBootstrapNotifier.build] resolves) rather than as a
/// fourth value here, since `build()` never throws — it always settles into
/// exactly one of these four.
enum SessionBootstrapStatus {
  authenticated,
  unauthenticated,
  recoverableError,

  /// A saved session exists and biometric login is enabled for that same
  /// cached user, and the device currently has enrolled biometrics — but the
  /// refresh token has deliberately NOT been touched yet. The caller (Login
  /// screen) must obtain a successful biometric check and then call
  /// [SessionBootstrapNotifier.confirmAfterBiometric] before the session is
  /// actually restored. See that method's doc for why the refresh is
  /// deferred rather than done eagerly.
  biometricRequired,
}

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

    // Biometric gate check — deliberately BEFORE any refresh-token network
    // call. If this session is biometric-gated, the refresh token must stay
    // completely untouched (no rotation, no access token materialized in
    // TokenStorage) until a biometric check actually succeeds: TokenStorage
    // is read by AuthInterceptor on every request regardless of
    // AuthState.isLoggedIn, so refreshing first would create a window where
    // a "logged out"-looking screen could silently fire authenticated
    // requests before the user ever proved presence.
    final cachedUserId = _readCachedUserId(prefs);
    if (cachedUserId != null &&
        await BiometricPreferenceStore.isEnabledFor(cachedUserId)) {
      final biometricService = ref.read(biometricServiceProvider);
      if (await biometricService.hasEnrolledBiometrics()) {
        return SessionBootstrapStatus.biometricRequired;
      }
      // Preference says enabled, but the device no longer has enrolled
      // biometrics (removed since it was turned on) — gracefully fall back
      // to the normal restore path below rather than gating on something
      // the user can no longer satisfy.
    }

    return _refreshAndConfirm();
  }

  String? _readCachedUserId(SharedPreferences prefs) {
    final userJsonStr = prefs.getString(AuthNotifier.userKey);
    if (userJsonStr == null) return null;
    try {
      final Map<String, dynamic> userMap = jsonDecode(userJsonStr);
      return User.fromJson(userMap).id;
    } catch (_) {
      return null;
    }
  }

  /// Performs the actual refresh-token network call and, on success,
  /// confirms the restored session through [AuthNotifier.confirmRestoredSession]
  /// — i.e. the point at which the session becomes "live"
  /// (`AuthState.isLoggedIn == true`). Shared by the non-gated bootstrap path
  /// and by [confirmAfterBiometric].
  Future<SessionBootstrapStatus> _refreshAndConfirm() async {
    final coordinator = ref.read(tokenRefreshCoordinatorProvider);
    final outcome = await coordinator.refresh();

    switch (outcome) {
      case RefreshSuccess():
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

  /// Called by the Login screen after a biometric check succeeds while
  /// `state == biometricRequired`. Only now does the refresh token actually
  /// get used — biometric success unlocks reuse of the *existing*
  /// backend-revalidated session flow (refresh -> confirmRestoredSession),
  /// it never fabricates or bypasses it. If the token turns out to be
  /// expired/rejected by the backend at this point, the outcome is exactly
  /// the same as any other expired-session case: local session cleared,
  /// normal login required — biometric success never overrides that.
  Future<void> confirmAfterBiometric() async {
    state = const AsyncLoading<SessionBootstrapStatus>().copyWithPrevious(
      state,
    );
    state = await AsyncValue.guard(_refreshAndConfirm);
  }
}

final sessionBootstrapProvider =
    AsyncNotifierProvider<SessionBootstrapNotifier, SessionBootstrapStatus>(
      () => SessionBootstrapNotifier(),
    );
