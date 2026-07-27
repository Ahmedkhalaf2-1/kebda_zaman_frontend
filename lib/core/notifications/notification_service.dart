import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kebda_zaman/firebase_options.dart';
import 'package:kebda_zaman/features/admin/presentation/notifiers/admin_order_notification_notifier.dart';
import 'notification_model.dart';
import 'notification_navigation_service.dart';
import 'notification_permission_service.dart';

/// FCM `data.type` value the backend sends for the admin new-order push
/// (see Sprint 2 — Admin FCM Push Integration). Kept here, not added to the
/// customer-facing `NotificationType` enum, since it drives admin-only
/// side effects (refreshing the admin notification inbox) rather than
/// customer navigation.
const String _kNewOrderNotificationType = 'NEW_ORDER';

/// Top-level background message handler for FCM.
///
/// Runs in a separate isolate (Android), so it cannot rely on any state from
/// the main isolate's NotificationService instance — it must initialize
/// Firebase and flutter_local_notifications itself.
///
/// Every push from this backend is data-only (no `notification:` block — see
/// 08_NOTIFICATION_REFERENCE.md), so the OS will NOT auto-display anything
/// for a backgrounded app unless this handler explicitly shows a local
/// notification, exactly as the foreground handler does.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final payload = AppNotificationPayload.fromRemoteMessage(message);

    final localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    const androidChannel = AndroidNotificationChannel(
      'kebda_zaman_high_importance_channel',
      'Kebda Zaman Orders & Offers',
      description: 'Notifications for fresh order updates and exclusive deals.',
      importance: Importance.high,
    );
    await localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    await localNotifications.show(
      payload.id.hashCode,
      payload.title,
      payload.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'kebda_zaman_high_importance_channel',
          'Kebda Zaman Orders & Offers',
          channelDescription:
              'Notifications for fresh order updates and exclusive deals.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload.toJson(),
    );
  } catch (_) {}
}

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  late final NotificationPermissionService permissionService;

  bool _isFirebaseInitialized = false;
  bool _isInitialized = false;

  ProviderContainer? _container;

  bool get isFirebaseInitialized => _isFirebaseInitialized;

  /// Bridges this plain singleton to the Riverpod provider graph so incoming
  /// FCM messages can invalidate provider state (e.g. the admin notification
  /// inbox). Safe to call on every widget rebuild — it only reassigns a
  /// reference (same pattern as `NotificationNavigationService.setRouter`),
  /// it does not register any new listener.
  void attachProviderContainer(ProviderContainer container) {
    _container = container;
  }

  /// Initialize Firebase Core, Local Notifications, and FCM listeners safely
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Safe Firebase Core Initialization
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isFirebaseInitialized = true;
      permissionService = NotificationPermissionService(
        fcm: FirebaseMessaging.instance,
      );
    } catch (e) {
      debugPrint('⚠️ [NotificationService] Firebase init exception: $e');
      permissionService = NotificationPermissionService();
    }

    // 2. Initialize Local Notifications Plugin
    await _initLocalNotifications();

    if (!_isFirebaseInitialized) return;

    // 3. Register FCM Background Handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 4. Listen for Foreground Messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Listen for Background Tap Navigation
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final payload = AppNotificationPayload.fromRemoteMessage(message);
      NotificationNavigationService.instance.handleNotificationTap(payload);
    });

    // 6. Check Initial Terminated Launch Message
    _checkInitialMessage();

    // 7. Token Management & Refresh Listener
    _initTokenListeners();
  }

  /// Initialize Android & iOS local notification settings
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> map = Map<String, dynamic>.from(
              Map.castFrom(Map.from(details.payload as dynamic)),
            );
            final payload = AppNotificationPayload.fromMap(map);
            NotificationNavigationService.instance.handleNotificationTap(
              payload,
            );
          } catch (_) {}
        }
      },
    );

    // Create high importance channel for Android
    const androidChannel = AndroidNotificationChannel(
      'kebda_zaman_high_importance_channel',
      'Kebda Zaman Orders & Offers',
      description: 'Notifications for fresh order updates and exclusive deals.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle incoming foreground messages and show local notification banner
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final payload = AppNotificationPayload.fromRemoteMessage(message);

    const androidDetails = AndroidNotificationDetails(
      'kebda_zaman_high_importance_channel',
      'Kebda Zaman Orders & Offers',
      channelDescription:
          'Notifications for fresh order updates and exclusive deals.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      payload.id.hashCode,
      payload.title,
      payload.body,
      notificationDetails,
      payload: payload.toJson(),
    );

    handleAdminNewOrderRefresh(payload);
  }

  /// For an admin NEW_ORDER push received while the app is in the
  /// foreground, refresh the admin notification inbox (unread count + list)
  /// in place. The local notification banner above already covers user
  /// feedback — this only synchronizes state, no second notification.
  @visibleForTesting
  void handleAdminNewOrderRefresh(AppNotificationPayload payload) {
    if (payload.rawData['type'] != _kNewOrderNotificationType) return;

    final container = _container;
    if (container == null) return;

    container.invalidate(adminUnreadNotificationCountProvider);
    container.invalidate(adminOrderNotificationProvider);
  }

  /// Check if application was launched from terminated state by tapping a notification
  Future<void> _checkInitialMessage() async {
    try {
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        final payload = AppNotificationPayload.fromRemoteMessage(
          initialMessage,
        );
        NotificationNavigationService.instance.handleNotificationTap(payload);
      }
    } catch (_) {}
  }

  /// Listen for FCM Token and token refreshes
  void _initTokenListeners() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        syncTokenWithBackend(token);
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        syncTokenWithBackend(newToken);
      });
    } catch (_) {}
  }

  /// Retrieve current FCM device token
  Future<String?> getFcmToken() async {
    if (!_isFirebaseInitialized) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  /// NOTE: Backend device-token sync is now fully handled by DeviceService.
  /// This method is kept for legacy call-site compatibility but is a no-op.
  /// The DeviceService singleton is driven by AuthNotifier session lifecycle hooks.
  void syncTokenWithBackend(String token) {
    debugPrint(
      '🔔 [NotificationService] FCM Token ready — DeviceService handles backend sync',
    );
  }
}
