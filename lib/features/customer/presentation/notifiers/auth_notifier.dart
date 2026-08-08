import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/features/shared/data/google_auth_service.dart';
import 'package:kebda_zaman/features/shared/data/apple_auth_service.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/notifications/device_service.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isLoggedIn;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    bool? isLoggedIn,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  static const String userKey = 'kz_current_user_json';
  static const String isLoggedInKey = 'kz_is_logged_in';
  final AuthRepository _authRepository;

  /// Obtains a fresh Firebase ID token via Google Sign-In, or `null` if the
  /// user cancelled account selection. Injected as a plain function (rather
  /// than the concrete [GoogleAuthService]) so tests can substitute it
  /// without touching real Google/Firebase platform channels.
  final Future<String?> Function() _googleSignIn;

  /// Best-effort Firebase/Google sign-out, called during [logout]. Same
  /// injection pattern as [_googleSignIn] — a plain function so tests never
  /// touch real platform channels.
  final Future<void> Function() _googleSignOut;
  final Future<String?> Function() _appleSignIn;

  AuthNotifier(
    this._authRepository, {
    Future<String?> Function()? googleSignIn,
    Future<void> Function()? googleSignOut,
    Future<String?> Function()? appleSignIn,
  }) : _googleSignIn = googleSignIn ?? _lazyGoogleSignIn,
       _googleSignOut = googleSignOut ?? _lazyGoogleSignOut,
       _appleSignIn = appleSignIn ?? _lazyAppleSignIn,
       super(const AuthState(isLoading: true)) {
    _loadCachedUserForDisplay();
  }

  // Tear-offs rather than a shared instance field: constructing
  // GoogleAuthService() touches FirebaseAuth.instance immediately, which
  // throws if Firebase hasn't been initialized (e.g. in tests that inject
  // only one of the two callbacks and never invoke the other). Deferring
  // construction to actual invocation keeps the untouched default lazy.
  static Future<String?> _lazyGoogleSignIn() => GoogleAuthService().signIn();
  static Future<void> _lazyGoogleSignOut() => GoogleAuthService().signOut();
  static Future<String?> _lazyAppleSignIn() => AppleAuthService().signIn();

  /// Loads the cached user (if any) purely for presentation — e.g. so the
  /// UI can show a name while SessionBootstrapNotifier's cold-start token
  /// refresh is still in flight. This deliberately never sets
  /// `isLoggedIn: true`: a cached profile is not a verified active session.
  /// `isLoggedIn` only becomes true via [confirmRestoredSession] (after a
  /// real access-token refresh succeeds) or a fresh login/signup.
  Future<void> _loadCachedUserForDisplay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSavedSession = prefs.getBool(isLoggedInKey) ?? false;
      final userJsonStr = prefs.getString(userKey);

      if (hasSavedSession && userJsonStr != null) {
        final Map<String, dynamic> userMap = jsonDecode(userJsonStr);
        final user = User.fromJson(userMap);
        state = AuthState(user: user, isLoggedIn: false, isLoading: false);
        return;
      }
    } catch (_) {}

    // Default guest/unauthenticated user state
    state = const AuthState(user: null, isLoggedIn: false, isLoading: false);
  }

  /// Called by SessionBootstrapNotifier once the cold-start access-token
  /// refresh has actually succeeded. This is the only place a *restored*
  /// session (as opposed to a fresh login) is allowed to mark `isLoggedIn`
  /// true, and it only does so after confirming the profile with the
  /// backend using the now-valid access token.
  Future<void> confirmRestoredSession() async {
    final result = await _authRepository.getCurrentUser();
    if (result.isSuccess && result.value != null) {
      final user = result.value!;
      await _saveUserSession(user);
      state = AuthState(user: user, isLoggedIn: true, isLoading: false);
      DeviceService.instance.onSessionEstablished();
    } else if (result.isFailure && result.failure is AuthFailure) {
      // Only a genuine auth rejection (expired/invalid credentials) should
      // force a logout here — a transient network/server error must not
      // sign the user out over a momentary hiccup right after a successful
      // token refresh.
      await logout();
    } else {
      // Transient failure fetching the profile. The access token itself is
      // valid — the refresh already succeeded — so keep the session logged
      // in using whatever cached user we have rather than punishing a
      // momentary network blip with a forced logout.
      final cachedUser = state.user;
      if (cachedUser != null) {
        state = state.copyWith(isLoggedIn: true, isLoading: false);
      }
    }
  }

  /// Called by SessionBootstrapNotifier when the refresh endpoint
  /// definitively rejects the stored refresh token. Clears the locally
  /// cached session without another backend round-trip — the session is
  /// already dead server-side (TokenRefreshCoordinator already cleared the
  /// stored refresh token and in-memory access token).
  Future<void> clearLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(isLoggedInKey);
      await prefs.remove(userKey);
    } catch (_) {}
    // Local-only device token cleanup — by this point the access token has
    // already been rejected/cleared by TokenRefreshCoordinator, so an
    // authenticated DELETE /devices/token request (onBeforeLogout) is no
    // longer reliable. This never calls the backend.
    await DeviceService.instance.onSessionInvalidated();
    state = const AuthState(user: null, isLoggedIn: false, isLoading: false);
  }

  Future<bool> login({
    required String identifier, // Email or Username
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (identifier.trim().isEmpty || password.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please enter valid credentials',
      );
      return false;
    }

    // The backend account model has no username concept — only a real email
    // authenticates (see 06_AUTH_REFERENCE.md). Sending anything else always
    // fails with 401 INVALID_CREDENTIALS, so the identifier is used verbatim.
    final result = await _authRepository.login(identifier.trim(), password);

    if (result.isSuccess) {
      final user = result.value;
      await _saveUserSession(user);
      state = AuthState(user: user, isLoggedIn: true, isLoading: false);
      // Register/confirm device token after login
      DeviceService.instance.onSessionEstablished();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
      return false;
    }
  }

  Future<bool> adminLogin({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (identifier.trim().isEmpty || password.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please enter valid credentials',
      );
      return false;
    }

    final result = await _authRepository.adminLogin(
      identifier.trim(),
      password,
    );

    if (result.isSuccess) {
      final user = result.value;
      await _saveUserSession(user);
      state = AuthState(user: user, isLoggedIn: true, isLoading: false);
      DeviceService.instance.onSessionEstablished();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
      return false;
    }
  }

  /// Google Sign-In, integrated into the same session flow as email/password
  /// login: obtain a Firebase ID token client-side, exchange it for the
  /// normal backend session, persist tokens through the existing path, and
  /// register the FCM device exactly as every other auth method does.
  Future<bool> googleSignIn() async {
    // Guards both a double-tap racing ahead of the disabled-button rebuild
    // and any other auth mutation already in flight.
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    String? idToken;
    try {
      idToken = await _googleSignIn();
    } catch (_) {
      // Never surface raw Google/Firebase exception text to the user.
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'auth.google_signin_failed'.tr(),
      );
      return false;
    }

    if (idToken == null) {
      // User cancelled account selection — reset quietly. No error message,
      // no navigation (callers only navigate when this returns true).
      state = state.copyWith(isLoading: false);
      return false;
    }

    final result = await _authRepository.googleLogin(idToken);

    if (result.isSuccess) {
      final user = result.value;
      await _saveUserSession(user);
      state = AuthState(user: user, isLoggedIn: true, isLoading: false);
      DeviceService.instance.onSessionEstablished();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _mapGoogleLoginErrorMessage(result.failure),
      );
      return false;
    }
  }

  Future<bool> appleSignIn() async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, errorMessage: null);

    String? idToken;
    try {
      idToken = await _appleSignIn();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'auth.apple_signin_failed'.tr(),
      );
      return false;
    }

    if (idToken == null) {
      state = state.copyWith(isLoading: false);
      return false;
    }

    final repository = _authRepository;
    if (repository is! AppleAuthRepository) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'auth.apple_signin_failed'.tr(),
      );
      return false;
    }

    final appleRepository = repository as AppleAuthRepository;
    final result = await appleRepository.appleLogin(idToken);
    if (result.isSuccess) {
      final user = result.value;
      await _saveUserSession(user);
      state = AuthState(user: user, isLoggedIn: true, isLoading: false);
      DeviceService.instance.onSessionEstablished();
      return true;
    }

    final cause = result.failure.cause;
    state = state.copyWith(
      isLoading: false,
      errorMessage: cause is ApiException && cause.code == 'INVALID_APPLE_TOKEN'
          ? 'auth.apple_token_invalid'.tr()
          : result.failure is NetworkFailure
          ? 'common.something_wrong'.tr()
          : 'auth.apple_signin_failed'.tr(),
    );
    return false;
  }

  /// Backend `INVALID_GOOGLE_TOKEN` maps to a friendly localized message;
  /// network failures reuse the app's existing generic network-error copy;
  /// anything else falls back to the same generic Google failure message
  /// used for pre-backend failures — never the raw backend/Dio text.
  String _mapGoogleLoginErrorMessage(Failure failure) {
    final cause = failure.cause;
    if (cause is ApiException && cause.code == 'INVALID_GOOGLE_TOKEN') {
      return 'auth.google_token_invalid'.tr();
    }
    if (failure is NetworkFailure) {
      return 'common.something_wrong'.tr();
    }
    return 'auth.google_signin_failed'.tr();
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Please fill in all required fields',
      );
      return false;
    }

    final result = await _authRepository.register(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim().isNotEmpty ? phone.trim() : '01000000000',
      password: password,
    );

    if (result.isSuccess) {
      final user = result.value;
      await _saveUserSession(user);
      state = AuthState(user: user, isLoggedIn: true, isLoading: false);
      // Register/confirm device token after sign-up
      DeviceService.instance.onSessionEstablished();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
      return false;
    }
  }

  Future<bool> continueAsGuest() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.guestLogin();

    if (result.isSuccess) {
      final user = result.value;
      await _saveUserSession(user);
      state = AuthState(user: user, isLoggedIn: true, isLoading: false);
      // Register/confirm device token for guest session too
      DeviceService.instance.onSessionEstablished();
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? locale,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.updateProfile(
      name: name,
      phone: phone,
      avatarUrl: avatarUrl,
      locale: locale,
    );

    if (result.isSuccess) {
      final user = result.value;
      await _saveUserSession(user);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
      return false;
    }
  }

  Future<void> _saveUserSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(isLoggedInKey, true);
      await prefs.setString(userKey, jsonEncode(user.toJson()));
    } catch (_) {}
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    // 1. Delete device token BEFORE invalidating the backend session
    //    (must happen while the access token is still valid)
    await DeviceService.instance.onBeforeLogout();

    // 2. Call the backend to invalidate the refresh token. This always
    //    clears the locally stored backend accessToken/refreshToken in its
    //    own `finally` block (see ApiAuthRepository.logout), even if the
    //    backend call itself fails.
    await _authRepository.logout();

    // 3. Best-effort Firebase/Google sign-out. Backend tokens are already
    //    cleared by step 2 regardless of outcome here — a Google/Firebase
    //    sign-out failure must never leave the app in a locally
    //    authenticated state, and this never assumes the user actually
    //    signed in via Google (safe no-op if they didn't).
    try {
      await _googleSignOut();
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(isLoggedInKey);
      await prefs.remove(userKey);
    } catch (_) {}

    state = const AuthState(user: null, isLoggedIn: false, isLoading: false);
  }

  /// Permanently deletes the signed-in customer's own account.
  ///
  /// Unlike [logout], this never calls the backend `/auth/logout` endpoint —
  /// once the account is deleted/anonymized server-side, that endpoint has
  /// nothing valid left to invalidate. Only the *local* portions of the
  /// logout sequence are reused: device-token cleanup (while the access
  /// token is still valid, mirroring [logout]'s ordering), best-effort
  /// Google/Firebase sign-out, and clearing the cached session.
  ///
  /// Returns the repository [Result] directly (rather than folding it into
  /// [AuthState.errorMessage] like the other methods) so the caller can
  /// distinguish `ACTIVE_ORDER_EXISTS` / `GUEST_NOT_ELIGIBLE` /
  /// `FIREBASE_DELETE_FAILED` and show the correct specific message —
  /// reusing the shared error banner field here would either lose that
  /// detail or bleed a deletion-specific message into unrelated auth UI.
  ///
  /// Guards against duplicate submissions the same way [googleSignIn] does:
  /// a call that arrives while one is already in flight is a no-op.
  Future<Result<void>> deleteAccount() async {
    if (state.isLoading) {
      return const Err(UnknownFailure('A request is already in progress.'));
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    // Device-token cleanup while the access token is still valid — same
    // ordering logout() uses. Best-effort/non-blocking by design.
    await DeviceService.instance.onBeforeLogout();

    final result = await _authRepository.deleteAccount();

    if (result.isFailure) {
      // Preserve the session on any failure: reset isLoading only, leave
      // user/isLoggedIn/tokens exactly as they were.
      state = state.copyWith(isLoading: false);
      return result;
    }

    // Success: local-only session teardown (no backend /auth/logout call —
    // the account no longer exists to log out of).
    try {
      await _googleSignOut();
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(isLoggedInKey);
      await prefs.remove(userKey);
    } catch (_) {}

    state = const AuthState(user: null, isLoggedIn: false, isLoading: false);
    return result;
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
