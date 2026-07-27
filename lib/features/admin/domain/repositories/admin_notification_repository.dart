import 'package:kebda_zaman/core/errors/errors.dart';
import '../models/notification_campaign.dart';

/// Clean repository interface for Admin Push Notification Campaigns.
/// This interface isolates the frontend from future Backend API implementation.
abstract class AdminNotificationRepository {
  /// Send a notification campaign immediately
  /// Future Backend API: POST /admin/notifications/send
  Future<Result<NotificationCampaign>> sendCampaign(
    NotificationCampaign campaign,
  );

  /// Schedule a notification campaign for future dispatch
  /// Future Backend API: POST /admin/notifications/schedule
  Future<Result<NotificationCampaign>> scheduleCampaign(
    NotificationCampaign campaign,
  );

  /// Retrieve campaign history list
  /// Future Backend API: GET /admin/notifications/campaigns
  Future<Result<List<NotificationCampaign>>> getCampaigns();

  /// Retrieve details of a specific campaign
  /// Future Backend API: GET /admin/notifications/campaigns/:id
  Future<Result<NotificationCampaign>> getCampaignDetails(String id);

  /// Delete or cancel a campaign
  /// Future Backend API: DELETE /admin/notifications/campaigns/:id
  Future<Result<void>> deleteCampaign(String id);
}
