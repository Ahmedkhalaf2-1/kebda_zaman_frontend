import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

enum NotificationType {
  general,
  promotion,
  offer,
  newProduct,
  category,
  orderCreated,
  orderConfirmed,
  orderPreparing,
  orderReady,
  orderOutForDelivery,
  orderDelivered,
  orderCancelled,
  paymentSuccess,
  paymentFailed,
  unknown;

  static NotificationType fromString(String? type) {
    if (type == null) return NotificationType.general;
    switch (type.toLowerCase().trim()) {
      case 'general':
        return NotificationType.general;
      case 'promotion':
        return NotificationType.promotion;
      case 'offer':
        return NotificationType.offer;
      case 'new_product':
      case 'newproduct':
        return NotificationType.newProduct;
      case 'category':
        return NotificationType.category;
      case 'order_created':
        return NotificationType.orderCreated;
      case 'order_confirmed':
        return NotificationType.orderConfirmed;
      case 'order_preparing':
        return NotificationType.orderPreparing;
      case 'order_ready':
        return NotificationType.orderReady;
      case 'order_out_for_delivery':
        return NotificationType.orderOutForDelivery;
      case 'order_delivered':
        return NotificationType.orderDelivered;
      case 'order_cancelled':
        return NotificationType.orderCancelled;
      case 'payment_success':
        return NotificationType.paymentSuccess;
      case 'payment_failed':
        return NotificationType.paymentFailed;
      default:
        return NotificationType.unknown;
    }
  }

  String toPayloadString() {
    switch (this) {
      case NotificationType.general:
        return 'general';
      case NotificationType.promotion:
        return 'promotion';
      case NotificationType.offer:
        return 'offer';
      case NotificationType.newProduct:
        return 'new_product';
      case NotificationType.category:
        return 'category';
      case NotificationType.orderCreated:
        return 'order_created';
      case NotificationType.orderConfirmed:
        return 'order_confirmed';
      case NotificationType.orderPreparing:
        return 'order_preparing';
      case NotificationType.orderReady:
        return 'order_ready';
      case NotificationType.orderOutForDelivery:
        return 'order_out_for_delivery';
      case NotificationType.orderDelivered:
        return 'order_delivered';
      case NotificationType.orderCancelled:
        return 'order_cancelled';
      case NotificationType.paymentSuccess:
        return 'payment_success';
      case NotificationType.paymentFailed:
        return 'payment_failed';
      case NotificationType.unknown:
        return 'general';
    }
  }
}

class AppNotificationPayload {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final String? route;
  final String? entityId;
  final DateTime timestamp;
  final Map<String, dynamic> rawData;

  const AppNotificationPayload({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    this.route,
    this.entityId,
    required this.timestamp,
    this.rawData = const {},
  });

  /// Safe factory constructor parsing dynamic Map safely without crashing on missing/malformed fields
  factory AppNotificationPayload.fromMap(
    Map<String, dynamic> map, {
    String? fallbackId,
  }) {
    try {
      final dataMap = Map<String, dynamic>.from(
        map['data'] is Map ? map['data'] : map,
      );

      final String id =
          (map['id'] ??
                  dataMap['id'] ??
                  fallbackId ??
                  DateTime.now().millisecondsSinceEpoch.toString())
              .toString();
      final String title = (map['title'] ?? dataMap['title'] ?? 'كبدة زمان')
          .toString();
      final String body = (map['body'] ?? dataMap['body'] ?? '').toString();
      final String? imageUrl =
          map['imageUrl'] ??
          dataMap['imageUrl'] ??
          map['image'] ??
          dataMap['image'];
      final String? route = map['route'] ?? dataMap['route'];
      final String? entityId =
          map['entityId'] ??
          dataMap['entityId'] ??
          map['entity_id'] ??
          dataMap['entity_id'];

      final String rawType = (map['type'] ?? dataMap['type'] ?? 'general')
          .toString();
      final NotificationType type = NotificationType.fromString(rawType);

      DateTime ts = DateTime.now();
      if (map['timestamp'] != null) {
        final rawTimestamp = map['timestamp'].toString();
        // Backend FCM data payloads send epoch milliseconds as a string (e.g. "1784910670401"),
        // not ISO-8601 — see 08_NOTIFICATION_REFERENCE.md. Try that first, then fall back to
        // ISO-8601 for any other source (e.g. locally-constructed payloads).
        final epochMs = int.tryParse(rawTimestamp);
        if (epochMs != null) {
          ts = DateTime.fromMillisecondsSinceEpoch(epochMs);
        } else {
          try {
            ts = DateTime.parse(rawTimestamp);
          } catch (_) {}
        }
      }

      return AppNotificationPayload(
        id: id,
        type: type,
        title: title,
        body: body,
        imageUrl: imageUrl?.toString(),
        route: route?.toString(),
        entityId: entityId?.toString(),
        timestamp: ts,
        rawData: dataMap,
      );
    } catch (_) {
      // Emergency fallback payload
      return AppNotificationPayload(
        id: fallbackId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        type: NotificationType.general,
        title: map['title']?.toString() ?? 'كبدة زمان',
        body: map['body']?.toString() ?? '',
        timestamp: DateTime.now(),
        rawData: map,
      );
    }
  }

  /// Create payload from Firebase RemoteMessage safely
  factory AppNotificationPayload.fromRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final Map<String, dynamic> combinedMap = Map<String, dynamic>.from(
      message.data,
    );

    if (notification != null) {
      if (notification.title != null) combinedMap['title'] = notification.title;
      if (notification.body != null) combinedMap['body'] = notification.body;
      if (notification.android?.imageUrl != null)
        combinedMap['imageUrl'] = notification.android?.imageUrl;
      if (notification.apple?.imageUrl != null)
        combinedMap['imageUrl'] = notification.apple?.imageUrl;
    }

    return AppNotificationPayload.fromMap(
      combinedMap,
      fallbackId: message.messageId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toPayloadString(),
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'route': route,
      'entityId': entityId,
      'timestamp': timestamp.toIso8601String(),
      'data': rawData,
    };
  }

  String toJson() => jsonEncode(toMap());
}
