import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/notifications/notification_service.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/device_repository.dart';

/// Orchestrates the full FCM device-token lifecycle:
///  1. On session start  → request permission → obtain token → POST /devices/register
///  2. On token refresh  → PUT /devices/token (old→new)
///  3. On logout         → DELETE /devices/token then call onPostDelete()
///
/// It is a plain singleton so it can be started without a Riverpod context and
/// driven from AuthNotifier lifecycle hooks.
class DeviceService {
  static final DeviceService instance = DeviceService._();
  DeviceService._();

  // ── Internal state ─────────────────────────────────────────────────────────
  DeviceRepository? _deviceRepository;

  /// The FCM token most recently confirmed with the backend.
  String? _currentToken;

  bool _listenerAttached = false;

  static const String _tokenPrefKey = 'kz_fcm_device_token';

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Wire in the repository once the DI graph is ready.
  void configure(DeviceRepository repository) {
    _deviceRepository = repository;
    _attachRefreshListener();
  }

  /// Call once after a valid authenticated session is established:
  ///   - login (customer or guest)
  ///   - restored session at app start
  ///
  /// Requests notification permission, obtains the FCM token, registers it
  /// with the backend, and persists it locally.
  Future<void> onSessionEstablished() async {
    if (!NotificationService.instance.isFirebaseInitialized) {
      debugPrint(
        '🔕 [DeviceService] Firebase not initialized — skipping device registration',
      );
      return;
    }

    try {
      // 1. Request notification permission (idempotent — will only prompt once)
      await NotificationService.instance.permissionService.requestPermission();

      // 2. Obtain current FCM token
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        debugPrint(
          '⚠️ [DeviceService] FCM returned null token — skipping registration',
        );
        return;
      }

      final platform = _resolvePlatform();
      final previousToken = await _loadStoredToken();

      if (token == previousToken) {
        debugPrint(
          '✅ [DeviceService] Token unchanged — re-confirming with backend',
        );
        // Still register to re-attach the token to the current user
        // (e.g., different user logs in on same device)
      }

      await _sendToBackend(
        token: token,
        previousToken: previousToken,
        platform: platform,
      );
    } catch (e) {
      debugPrint(
        '⚠️ [DeviceService] onSessionEstablished error (non-blocking): $e',
      );
    }
  }

  /// Call before session teardown (logout).
  ///
  /// Attempts DELETE /devices/token for the currently known token.
  /// Never throws — if deletion fails the logout still proceeds.
  Future<void> onBeforeLogout() async {
    try {
      final token = _currentToken ?? await _loadStoredToken();
      if (token != null && token.isNotEmpty) {
        await _deviceRepository?.deleteToken(token);
      }
    } catch (e) {
      debugPrint(
        '⚠️ [DeviceService] onBeforeLogout cleanup error (non-blocking): $e',
      );
    } finally {
      await _clearStoredToken();
      _currentToken = null;
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _attachRefreshListener() {
    if (_listenerAttached) return;
    _listenerAttached = true;

    if (!NotificationService.instance.isFirebaseInitialized) return;

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint('🔄 [DeviceService] FCM token refreshed');
      try {
        final platform = _resolvePlatform();
        final oldToken = _currentToken ?? await _loadStoredToken();
        await _sendToBackend(
          token: newToken,
          previousToken: oldToken,
          platform: platform,
        );
      } catch (e) {
        debugPrint('⚠️ [DeviceService] Token refresh sync error: $e');
      }
    });
  }

  Future<void> _sendToBackend({
    required String token,
    required String? previousToken,
    required String platform,
  }) async {
    if (_deviceRepository == null) {
      debugPrint('⚠️ [DeviceService] Repository not configured yet');
      return;
    }

    final hasPrevious =
        previousToken != null &&
        previousToken.isNotEmpty &&
        previousToken != token;

    if (hasPrevious) {
      await _deviceRepository!.rotateToken(
        oldToken: previousToken,
        newToken: token,
        platform: platform,
      );
    } else {
      await _deviceRepository!.registerToken(token: token, platform: platform);
    }

    _currentToken = token;
    await _storeToken(token);
  }

  String _resolvePlatform() {
    if (kIsWeb) return 'WEB';
    if (defaultTargetPlatform == TargetPlatform.android) return 'ANDROID';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'IOS';
    if (defaultTargetPlatform == TargetPlatform.macOS) return 'MACOS';
    if (defaultTargetPlatform == TargetPlatform.windows) return 'WINDOWS';
    return 'ANDROID'; // safe default
  }

  Future<String?> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenPrefKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> _storeToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenPrefKey, token);
    } catch (_) {}
  }

  Future<void> _clearStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenPrefKey);
    } catch (_) {}
  }
}
