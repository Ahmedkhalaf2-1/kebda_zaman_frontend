import 'package:kebda_zaman/core/notifications/notification_model.dart';

enum CampaignStatus {
  draft,
  scheduled,
  sending,
  sent,
  failed,
  cancelled;

  String get label {
    switch (this) {
      case CampaignStatus.draft:
        return 'Draft';
      case CampaignStatus.scheduled:
        return 'Scheduled';
      case CampaignStatus.sending:
        return 'Sending...';
      case CampaignStatus.sent:
        return 'Sent';
      case CampaignStatus.failed:
        return 'Failed';
      case CampaignStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class NotificationCampaign {
  final String id;
  final String campaignName;
  final String title;
  final String body;
  final String? imageUrl;
  final NotificationType type;
  final String targetAudience;
  final String? destinationRoute;
  final String? entityId;
  final CampaignStatus status;
  final bool isScheduled;
  final DateTime? scheduledAt;
  final DateTime? sentAt;
  final int totalRecipients;
  final int deliveredCount;
  final int openedCount;
  final double clickRate;

  const NotificationCampaign({
    required this.id,
    required this.campaignName,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.type,
    required this.targetAudience,
    this.destinationRoute,
    this.entityId,
    required this.status,
    this.isScheduled = false,
    this.scheduledAt,
    this.sentAt,
    this.totalRecipients = 0,
    this.deliveredCount = 0,
    this.openedCount = 0,
    this.clickRate = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignName': campaignName,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'type': type.toPayloadString(),
      'targetAudience': targetAudience,
      'destinationRoute': destinationRoute,
      'entityId': entityId,
      'status': status.name,
      'isScheduled': isScheduled,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'totalRecipients': totalRecipients,
      'deliveredCount': deliveredCount,
      'openedCount': openedCount,
      'clickRate': clickRate,
    };
  }

  factory NotificationCampaign.fromJson(Map<String, dynamic> json) {
    return NotificationCampaign(
      id: json['id'] as String,
      campaignName: json['campaignName'] as String? ?? 'Untitled Campaign',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      type: NotificationType.fromString(json['type'] as String?),
      targetAudience: json['targetAudience'] as String? ?? 'All Users',
      destinationRoute: json['destinationRoute'] as String?,
      entityId: json['entityId'] as String?,
      status: CampaignStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CampaignStatus.draft,
      ),
      isScheduled: json['isScheduled'] as bool? ?? false,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      totalRecipients: json['totalRecipients'] as int? ?? 0,
      deliveredCount: json['deliveredCount'] as int? ?? 0,
      openedCount: json['openedCount'] as int? ?? 0,
      clickRate: (json['clickRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
