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
}
