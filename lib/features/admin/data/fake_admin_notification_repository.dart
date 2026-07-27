import 'package:uuid/uuid.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/notifications/notification_model.dart';
import '../domain/models/notification_campaign.dart';
import '../domain/repositories/admin_notification_repository.dart';

class FakeAdminNotificationRepository implements AdminNotificationRepository {
  final List<NotificationCampaign> _campaigns = [
    NotificationCampaign(
      id: 'camp_001',
      campaignName: 'Weekend Kebda Special Deal',
      title: 'خصم 20% على سندوتشات الكبدة!',
      body: 'استمتع بأقوى عروض الويك إند مع كبدة زمان، اطلب الآن واستلم طازة!',
      type: NotificationType.offer,
      targetAudience: 'All Users',
      destinationRoute: '/menu',
      status: CampaignStatus.sent,
      sentAt: DateTime.now().subtract(const Duration(days: 2)),
      totalRecipients: 1450,
      deliveredCount: 1420,
      openedCount: 890,
      clickRate: 62.6,
    ),
    NotificationCampaign(
      id: 'camp_002',
      campaignName: 'New Menu Items Launch',
      title: 'جرّب حواوشي زمان الجديد 🔥',
      body: 'طعم الشارع الأصيل بالخلطة السرية، متاح الآن في جميع الفروع.',
      type: NotificationType.newProduct,
      targetAudience: 'Active Customers (Last 30 Days)',
      destinationRoute: '/menu',
      status: CampaignStatus.scheduled,
      isScheduled: true,
      scheduledAt: DateTime.now().add(const Duration(days: 1, hours: 3)),
      totalRecipients: 2100,
    ),
    NotificationCampaign(
      id: 'camp_003',
      campaignName: 'Heliopolis Branch Opening',
      title: 'افتتاح فرع مصر الجديدة! 🎉',
      body: 'زورنا في فرعنا الجديد واستمتع بخصم خاص لكل الأكيلة.',
      type: NotificationType.promotion,
      targetAudience: 'City: Cairo',
      destinationRoute: '/offers',
      status: CampaignStatus.draft,
      totalRecipients: 0,
    ),
  ];

  @override
  Future<Result<NotificationCampaign>> sendCampaign(
    NotificationCampaign campaign,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: Replace with future Backend API integration:
    // Endpoint: POST /admin/notifications/send
    // Headers: Authorization: Bearer <admin_token>
    // Body: campaign.toJson()

    final newCampaign = NotificationCampaign(
      id: const Uuid().v4(),
      campaignName: campaign.campaignName,
      title: campaign.title,
      body: campaign.body,
      imageUrl: campaign.imageUrl,
      type: campaign.type,
      targetAudience: campaign.targetAudience,
      destinationRoute: campaign.destinationRoute,
      entityId: campaign.entityId,
      status: CampaignStatus.sent,
      sentAt: DateTime.now(),
      totalRecipients: 1500, // Will be returned from backend
      deliveredCount: 1480,
      openedCount: 0,
      clickRate: 0.0,
    );

    _campaigns.insert(0, newCampaign);
    return Success(newCampaign);
  }

  @override
  Future<Result<NotificationCampaign>> scheduleCampaign(
    NotificationCampaign campaign,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: Replace with future Backend API integration:
    // Endpoint: POST /admin/notifications/schedule
    // Headers: Authorization: Bearer <admin_token>
    // Body: campaign.toJson()

    final newCampaign = NotificationCampaign(
      id: const Uuid().v4(),
      campaignName: campaign.campaignName,
      title: campaign.title,
      body: campaign.body,
      imageUrl: campaign.imageUrl,
      type: campaign.type,
      targetAudience: campaign.targetAudience,
      destinationRoute: campaign.destinationRoute,
      entityId: campaign.entityId,
      status: CampaignStatus.scheduled,
      isScheduled: true,
      scheduledAt:
          campaign.scheduledAt ?? DateTime.now().add(const Duration(hours: 1)),
      totalRecipients: 1500,
    );

    _campaigns.insert(0, newCampaign);
    return Success(newCampaign);
  }

  @override
  Future<Result<List<NotificationCampaign>>> getCampaigns() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // TODO: Replace with future Backend API integration:
    // Endpoint: GET /admin/notifications/campaigns

    return Success(List.unmodifiable(_campaigns));
  }

  @override
  Future<Result<NotificationCampaign>> getCampaignDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // TODO: Replace with future Backend API integration:
    // Endpoint: GET /admin/notifications/campaigns/:id

    final found = _campaigns.firstWhere(
      (c) => c.id == id,
      orElse: () => _campaigns.first,
    );
    return Success(found);
  }

  @override
  Future<Result<void>> deleteCampaign(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // TODO: Replace with future Backend API integration:
    // Endpoint: DELETE /admin/notifications/campaigns/:id

    _campaigns.removeWhere((c) => c.id == id);
    return const Success(null);
  }
}
