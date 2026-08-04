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
}
