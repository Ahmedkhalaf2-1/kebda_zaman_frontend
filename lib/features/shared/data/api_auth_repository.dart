import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/api/api_interceptors.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;
  final TokenStorage tokenStorage;

  ApiAuthRepository({
    required this.apiClient,
    required this.secureStorage,
    required this.tokenStorage,
  });

  /// Atomically persists both tokens.
  ///
  /// The refresh token is written to durable storage FIRST. Only after that
  /// succeeds is the access token exposed in the in-memory [TokenStorage].
  /// This ordering means: if the process dies between the two writes, the
  /// next cold-start still has a valid refresh token to exchange — it will
  /// never be left with an in-memory access token and no stored refresh token.
  ///
  /// Returns normally on success, throws on storage failure so callers can
  /// treat a write error as a login failure rather than silently proceeding.
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await secureStorage.write(key: 'refreshToken', value: refreshToken);
    // Access token exposed in memory only after the durable write succeeds.
    tokenStorage.accessToken = accessToken;
  }

  Future<void> _clearTokens() async {
    tokenStorage.accessToken = null;
    await secureStorage.delete(key: 'refreshToken');
  }

  /// Parses an auth response, atomically persists tokens, and returns the User.
  ///
  /// If secure-storage persistence fails the tokens are cleared and an
  /// [AuthFailure] is returned — the UI must never enter an authenticated
  /// state without a durably stored refresh token.
  Future<Result<User>> _handleAuthResult(Response response) async {
    try {
      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data['user']);
      final accessToken = data['accessToken'] as String;
      final refreshToken = data['refreshToken'] as String;

      try {
        await _saveTokens(accessToken, refreshToken);
      } catch (_) {
        // Secure storage write failed — clear any partial state and surface a
        // proper failure so the UI does not navigate into an authenticated screen.
        await _clearTokens();
        return const Err(
          AuthFailure('Failed to persist session. Please try again.'),
        );
      }

      return Success(user);
    } catch (e) {
      return const Err(AuthFailure('Failed to parse user data'));
    }
  }

  Failure _handleError(dynamic e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      if (e.error is ApiException) {
        final apiException = e.error as ApiException;
        // Only genuine auth rejections (invalid/expired/missing credentials) should be
        // treated as AuthFailure — a transient network/server error must not be conflated
        // with "the session is invalid" (see auth_notifier._loadSavedUser, which logs the
        // user out on AuthFailure but preserves the session on NetworkFailure).
        if (statusCode == 401 || statusCode == 403) {
          return AuthFailure(apiException.message, apiException);
        }
        return NetworkFailure(apiException.message, apiException);
      }
      return NetworkFailure(e.message ?? 'Network error');
    }
    return UnknownFailure(e.toString());
  }

  @override
  Future<Result<User>> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return await _handleAuthResult(response);
    } catch (e) {
      return Err(_handleError(e));
    }
  }

  @override
  Future<Result<User>> googleLogin(String firebaseIdToken) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/google',
        // Only the verified Firebase ID token is sent — the backend derives
        // every identity value (email, name, uid) from it server-side.
        data: {'firebaseIdToken': firebaseIdToken},
      );
      return await _handleAuthResult(response);
    } catch (e) {
      return Err(_handleError(e));
    }
  }

  @override
  Future<Result<User>> adminLogin(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/admin/auth/login',
        data: {'email': email, 'password': password},
      );
      return await _handleAuthResult(response);
    } catch (e) {
      return Err(_handleError(e));
    }
  }

  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );
      return await _handleAuthResult(response);
    } catch (e) {
      return Err(_handleError(e));
    }
  }

  @override
  Future<Result<User>> guestLogin() async {
    try {
      final response = await apiClient.dio.post('/auth/guest', data: {});
      return await _handleAuthResult(response);
    } catch (e) {
      return Err(_handleError(e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final refreshToken = await secureStorage.read(key: 'refreshToken');
      await apiClient.dio.post(
        '/auth/logout',
        data: {if (refreshToken != null) 'refreshToken': refreshToken},
      );
    } catch (e) {
      // Even if backend fails, clear locally
    } finally {
      await _clearTokens();
    }
    return const Success(null);
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final response = await apiClient.dio.get('/users/me');
      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data);
      return Success(user);
    } catch (e) {
      return Err(_handleError(e));
    }
  }

  @override
  Future<Result<User>> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? locale,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
      if (locale != null) data['locale'] = locale;

      final response = await apiClient.dio.patch('/users/me', data: data);
      final responseData = response.data as Map<String, dynamic>;
      final user = User.fromJson(responseData);
      return Success(user);
    } catch (e) {
      return Err(_handleError(e));
    }
  }

  /// [_handleError] maps 401/403 alike to [AuthFailure], which
  /// [AuthNotifier] treats as "the session is invalid, log out". That fits
  /// every other endpoint here, but not this one: a 403 on this endpoint
  /// specifically means `GUEST_NOT_ELIGIBLE` — a guest account is real and
  /// its session is fine, it's just not eligible to delete itself. Forcing a
  /// logout on that response would be wrong, so deletion gets its own
  /// mapping that only ever treats a genuine 401 as an auth failure.
  Failure _handleDeleteAccountError(dynamic e) {
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      if (e.error is ApiException) {
        final apiException = e.error as ApiException;
        if (statusCode == 401) {
          return AuthFailure(apiException.message, apiException);
        }
        // 403 GUEST_NOT_ELIGIBLE, 409 ACTIVE_ORDER_EXISTS: real, actionable
        // preconditions on an otherwise-valid session — not a session
        // problem, so ValidationFailure (not AuthFailure) preserves that
        // distinction for AuthNotifier/UI. The machine-readable `code` is
        // preserved on the failure's `cause` either way.
        if (statusCode == 403 || statusCode == 409) {
          return ValidationFailure(apiException.message, apiException);
        }
        // 503 FIREBASE_DELETE_FAILED and anything else unexpected: a
        // service-side failure, not a rejection of the request itself —
        // retryable, so NetworkFailure (never logs the user out).
        return NetworkFailure(apiException.message, apiException);
      }
      return NetworkFailure(e.message ?? 'Network error');
    }
    return UnknownFailure(e.toString());
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      // 204 No Content on success — nothing to decode from the response
      // body, so unlike every other call in this file there is no
      // `response.data` parsing step at all.
      await apiClient.dio.delete('/auth/account');
      // Tokens are only ever cleared here, after a confirmed 204 — any
      // exception above skips this line entirely, so a failed deletion
      // never touches the stored session.
      await _clearTokens();
      return const Success(null);
    } catch (e) {
      return Err(_handleDeleteAccountError(e));
    }
  }
}
