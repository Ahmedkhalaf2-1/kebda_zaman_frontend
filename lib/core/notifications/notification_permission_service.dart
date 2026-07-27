import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppNotificationPermissionStatus {
  authorized,
  denied,
  notDetermined,
  provisional;

  static AppNotificationPermissionStatus fromAuthorizationStatus(
    AuthorizationStatus status,
  ) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return AppNotificationPermissionStatus.authorized;
      case AuthorizationStatus.denied:
        return AppNotificationPermissionStatus.denied;
      case AuthorizationStatus.notDetermined:
        return AppNotificationPermissionStatus.notDetermined;
      case AuthorizationStatus.provisional:
        return AppNotificationPermissionStatus.provisional;
    }
  }
}

class NotificationPermissionService {
  static const String _requestedKey = 'kz_notification_permission_requested';

  final FirebaseMessaging _fcm;

  NotificationPermissionService({FirebaseMessaging? fcm})
    : _fcm = fcm ?? FirebaseMessaging.instance;

  /// Check current permission status without prompting
  Future<AppNotificationPermissionStatus> checkPermissionStatus() async {
    try {
      final settings = await _fcm.getNotificationSettings();
      return AppNotificationPermissionStatus.fromAuthorizationStatus(
        settings.authorizationStatus,
      );
    } catch (_) {
      return AppNotificationPermissionStatus.notDetermined;
    }
  }

  /// Request permission if not requested before, or force request
  Future<AppNotificationPermissionStatus> requestPermission({
    bool forcePrompt = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyRequested = prefs.getBool(_requestedKey) ?? false;

      // Avoid repeatedly asking every launch unless forcePrompt is true
      if (alreadyRequested && !forcePrompt) {
        return checkPermissionStatus();
      }

      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: true,
        sound: true,
      );

      await prefs.setBool(_requestedKey, true);

      return AppNotificationPermissionStatus.fromAuthorizationStatus(
        settings.authorizationStatus,
      );
    } catch (_) {
      return AppNotificationPermissionStatus.denied;
    }
  }
}
