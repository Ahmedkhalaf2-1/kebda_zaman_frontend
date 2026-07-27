import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

enum NotificationType { orderStatus, promo, system }

@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    String? userId,
    required String title,
    required String body,
    required NotificationType type,
    String? relatedOrderId,
    @Default(false) bool isRead,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
