import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_interceptors.dart';

/// Result of a single refresh attempt. Mirrors the sealed Result/Failure
/// style already used in core/errors, kept local to core/api since this is
/// transport-layer concern, not a domain-level Result<T>.
sealed class RefreshOutcome {
  const RefreshOutcome();
}

/// The refresh succeeded — [accessToken] is the new access token, already
/// written into TokenStorage, and the rotated refresh token has already been
/// durably persisted to secure storage before this outcome is produced.
class RefreshSuccess extends RefreshOutcome {
  final String accessToken;
  const RefreshSuccess(this.accessToken);
}

/// The refresh endpoint definitively rejected the stored refresh token
/// (expired, revoked, reused, or otherwise invalid — a real 401 from
/// /auth/refresh itself). The session is genuinely over: TokenStorage and
/// the persisted refresh token have already been cleared.
class RefreshRejected extends RefreshOutcome {
  const RefreshRejected();
}

/// There was no refresh token to attempt a refresh with.
class RefreshNoToken extends RefreshOutcome {
  const RefreshNoToken();
}

/// The refresh call failed for a transient/infrastructure reason (timeout,
/// connection error, DNS failure, 5xx, ...) — not a rejection of the token.
/// The stored refresh token is deliberately left untouched so a later
/// attempt can retry.
class RefreshTransientFailure extends RefreshOutcome {
  final Object error;
  const RefreshTransientFailure(this.error);
}

/// Coordinates every /auth/refresh attempt across the whole app through a
/// single in-flight Future, so concurrent callers (multiple 401s firing at
/// once, or a cold-start bootstrap racing a reactive 401) can never issue
/// more than one refresh call against the same single-use, rotating refresh
/// token at a time.
///
/// One instance is owned by ApiClient and shared by AuthInterceptor and the
/// session bootstrap flow — never construct a second instance.
class TokenRefreshCoordinator {
  static const String refreshTokenKey = 'refreshToken';

  final Dio dio;
  final FlutterSecureStorage secureStorage;
  final TokenStorage tokenStorage;

  TokenRefreshCoordinator({
    required this.dio,
    required this.secureStorage,
    required this.tokenStorage,
  });

  Future<RefreshOutcome>? _inFlight;

  /// Performs (or joins an already-running) single-flight refresh.
  Future<RefreshOutcome> refresh() {
    return _inFlight ??= _doRefresh().whenComplete(() {
      _inFlight = null;
    });
  }

  Future<RefreshOutcome> _doRefresh() async {
    final refreshToken = await secureStorage.read(key: refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      return const RefreshNoToken();
    }

    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;

      tokenStorage.accessToken = newAccessToken;
      // Must be awaited: refresh tokens are single-use and rotate on every
      // successful refresh, so this write must be durable before the
      // refresh is considered complete — a lost write here would strand
      // the session on the very next restart.
      await secureStorage.write(key: refreshTokenKey, value: newRefreshToken);

      return RefreshSuccess(newAccessToken);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Definitive rejection: the refresh token itself was invalid,
        // expired, revoked, or reused (reuse detection) — end the session.
        tokenStorage.accessToken = null;
        await secureStorage.delete(key: refreshTokenKey);
        return const RefreshRejected();
      }
      // Timeout, connection error, DNS failure, 5xx, etc. — transient
      // infrastructure trouble, not a rejection of the token. Leave the
      // stored refresh token intact so a later attempt can retry.
      return RefreshTransientFailure(e);
    } catch (e) {
      return RefreshTransientFailure(e);
    }
  }
}
