import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login(String email, String password);
  Future<Result<User>> adminLogin(String email, String password);

  /// Exchanges a verified Firebase ID token (obtained client-side via
  /// Google Sign-In) for the same backend JWT session normal login returns.
  /// Only the token is sent — the backend derives identity from it.
  Future<Result<User>> googleLogin(String firebaseIdToken);
  Future<Result<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });
  Future<Result<User>> guestLogin();
  Future<Result<void>> logout();
  Future<Result<User?>> getCurrentUser();
  Future<Result<User>> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? locale,
  });

  /// Permanently deletes the authenticated customer's own account.
  ///
  /// Backend contract: `DELETE /auth/account`, no request body. Succeeds
  /// with 204 No Content. Known failure codes: `GUEST_NOT_ELIGIBLE` (403,
  /// guests cannot delete an account they don't own), `ACTIVE_ORDER_EXISTS`
  /// (409, must wait for the order to complete/cancel), and
  /// `FIREBASE_DELETE_FAILED` (503, retryable service failure). Implementors
  /// must only clear local session state after a confirmed success — never
  /// on failure.
  Future<Result<void>> deleteAccount();

  /// `POST /auth/forgot-password` — public, unauthenticated. Always
  /// resolves to the same generic success on a real `200`, regardless of
  /// whether the email matches an account (PASSWORD_RESET_API_CONTRACT.md
  /// §`forgot-password`) — this method must never be used to infer account
  /// existence, and callers must show only the generic copy on success.
  ///
  /// Failure codes: `VALIDATION_ERROR` (400, malformed/missing email or
  /// over 255 chars), `PASSWORD_RESET_COOLDOWN`/`PASSWORD_RESET_RATE_LIMITED`
  /// (429, per-email throttle — see [PasswordResetRateLimitedFailure]), and
  /// a generic 429 for the per-IP route throttle (same failure type, no
  /// `code`).
  Future<Result<void>> forgotPassword(String email);

  /// `POST /auth/reset-password` — public, unauthenticated. Success (`200`)
  /// never returns tokens — this endpoint never logs the user in; the
  /// caller must send them to the normal login screen afterward.
  ///
  /// Failure codes: `VALIDATION_ERROR` (400, malformed token or a password
  /// outside the 8–72 char policy), `INVALID_RESET_TOKEN` /
  /// `RESET_TOKEN_ALREADY_USED` / `RESET_TOKEN_EXPIRED` (401 — surfaced via
  /// [AuthFailure.cause]'s `ApiException.code`, never as a local-session
  /// logout, since this token was never a session credential), and a
  /// generic 429 for the per-IP route throttle
  /// ([PasswordResetRateLimitedFailure]).
  Future<Result<void>> resetPassword({
    required String token,
    required String password,
  });
}

/// A `429` from `forgot-password`/`reset-password`'s shared per-IP route
/// throttle, or `forgot-password`'s own per-email cooldown/abuse-cap.
/// [retryAfterSeconds] carries the `Retry-After` response header when the
/// server actually sent one — callers must never fabricate a countdown
/// number when this is `null` (PASSWORD_RESET_API_CONTRACT.md §Throttling).
class PasswordResetRateLimitedFailure extends ValidationFailure {
  final int? retryAfterSeconds;

  const PasswordResetRateLimitedFailure(
    super.message,
    super.cause,
    this.retryAfterSeconds,
  );
}

/// Optional capability kept separate from [AuthRepository] so existing fake
/// repositories and tests do not need an Apple implementation. Production's
/// API repository implements both interfaces.
abstract interface class AppleAuthRepository {
  Future<Result<User>> appleLogin(String firebaseIdToken);
}
