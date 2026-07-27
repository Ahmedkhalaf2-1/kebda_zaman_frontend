import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/device_repository.dart';

/// Real implementation that communicates with:
///   POST  /devices/register  — upsert by token
///   PUT   /devices/token     — atomic rotate old→new
///   DELETE /devices/token    — remove on logout
class ApiDeviceRepository implements DeviceRepository {
  final ApiClient _apiClient;

  ApiDeviceRepository(this._apiClient);

  @override
  Future<void> registerToken({
    required String token,
    required String platform,
  }) async {
    try {
      await _apiClient.dio.post(
        '/devices/register',
        data: {'token': token, 'platform': platform},
      );
      debugPrint('📲 [DeviceRepo] Token registered — platform=$platform');
    } catch (e) {
      // Log but never throw — device registration failure must not crash the app
      debugPrint('⚠️ [DeviceRepo] registerToken failed: $e');
    }
  }

  @override
  Future<void> rotateToken({
    String? oldToken,
    required String newToken,
    required String platform,
  }) async {
    try {
      final body = <String, dynamic>{'token': newToken, 'platform': platform};
      if (oldToken != null && oldToken.isNotEmpty) {
        body['oldToken'] = oldToken;
      }

      await _apiClient.dio.put('/devices/token', data: body);
      debugPrint('🔄 [DeviceRepo] Token rotated — platform=$platform');
    } catch (e) {
      debugPrint('⚠️ [DeviceRepo] rotateToken failed: $e');
      // Fallback: try a fresh register so backend has the new token
      if (e is DioException && e.response?.statusCode == 404) {
        // oldToken was unknown — just register the new one
        await registerToken(token: newToken, platform: platform);
      }
    }
  }

  @override
  Future<void> deleteToken(String token) async {
    try {
      await _apiClient.dio.delete('/devices/token', data: {'token': token});
      debugPrint('🗑️ [DeviceRepo] Token deleted from backend');
    } catch (e) {
      // 404 means token was never registered on the backend — not an error.
      debugPrint('⚠️ [DeviceRepo] deleteToken failed (non-blocking): $e');
    }
  }
}
