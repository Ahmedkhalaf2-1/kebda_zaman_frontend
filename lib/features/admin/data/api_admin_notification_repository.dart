import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import '../domain/models/notification_campaign.dart';
import '../domain/repositories/admin_notification_repository.dart';

class ApiAdminNotificationRepository implements AdminNotificationRepository {
  final ApiClient _apiClient;

  ApiAdminNotificationRepository(this._apiClient);

  @override
  Future<Result<NotificationCampaign>> sendCampaign(
    NotificationCampaign campaign,
  ) async {
    try {
      final payload = <String, dynamic>{
        'campaignName': campaign.campaignName,
        'title': campaign.title,
        'body': campaign.body,
        if (campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty)
          'imageUrl': campaign.imageUrl,
        'type': campaign.type.toPayloadString(),
        'targetAudience': 'ALL',
        if (campaign.destinationRoute != null &&
            campaign.destinationRoute!.isNotEmpty)
          'destinationRoute': campaign.destinationRoute,
        if (campaign.entityId != null && campaign.entityId!.isNotEmpty)
          'entityId': campaign.entityId,
      };

      final response = await _apiClient.dio.post(
        '/admin/notifications/send',
        data: payload,
      );
      return Success(
        NotificationCampaign.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to send notification campaign'));
    } catch (e) {
      return const Err(
        UnknownFailure('Unknown error sending notification campaign'),
      );
    }
  }

  @override
  Future<Result<NotificationCampaign>> scheduleCampaign(
    NotificationCampaign campaign,
  ) async {
    try {
      final payload = <String, dynamic>{
        'campaignName': campaign.campaignName,
        'title': campaign.title,
        'body': campaign.body,
        if (campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty)
          'imageUrl': campaign.imageUrl,
        'type': campaign.type.toPayloadString(),
        'targetAudience': 'ALL',
        if (campaign.destinationRoute != null &&
            campaign.destinationRoute!.isNotEmpty)
          'destinationRoute': campaign.destinationRoute,
        if (campaign.entityId != null && campaign.entityId!.isNotEmpty)
          'entityId': campaign.entityId,
        'scheduledAt':
            campaign.scheduledAt?.toIso8601String() ??
            DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      };

      final response = await _apiClient.dio.post(
        '/admin/notifications/schedule',
        data: payload,
      );
      return Success(
        NotificationCampaign.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(
        NetworkFailure('Failed to schedule notification campaign'),
      );
    } catch (e) {
      return const Err(
        UnknownFailure('Unknown error scheduling notification campaign'),
      );
    }
  }

  @override
  Future<Result<List<NotificationCampaign>>> getCampaigns() async {
    try {
      final response = await _apiClient.dio.get(
        '/admin/notifications/campaigns',
      );
      final list = (response.data as List)
          .map(
            (json) =>
                NotificationCampaign.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      return Success(list);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to load campaigns'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading campaigns'));
    }
  }

  @override
  Future<Result<NotificationCampaign>> getCampaignDetails(String id) async {
    try {
      final response = await _apiClient.dio.get(
        '/admin/notifications/campaigns/$id',
      );
      return Success(
        NotificationCampaign.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to load campaign details'));
    } catch (e) {
      return const Err(
        UnknownFailure('Unknown error loading campaign details'),
      );
    }
  }

  @override
  Future<Result<void>> deleteCampaign(String id) async {
    try {
      await _apiClient.dio.delete('/admin/notifications/campaigns/$id');
      return const Success(null);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to delete campaign'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error deleting campaign'));
    }
  }
}
