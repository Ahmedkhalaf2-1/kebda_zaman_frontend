/// Abstract contract for device token registration with the backend.
abstract class DeviceRepository {
  /// Register (upsert) a FCM token for the current authenticated session.
  /// [token] — raw FCM token (≤4096 chars).
  /// [platform] — one of: ANDROID, IOS, WEB, MACOS, WINDOWS.
  Future<void> registerToken({required String token, required String platform});

  /// Atomically rotate an old token to a new one.
  /// When [oldToken] is null the call behaves like [registerToken].
  Future<void> rotateToken({
    String? oldToken,
    required String newToken,
    required String platform,
  });

  /// Remove the current token from the backend on logout / opt-out.
  /// Failure (e.g. 404, network) must not throw — return silently.
  Future<void> deleteToken(String token);
}
