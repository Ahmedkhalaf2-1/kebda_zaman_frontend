import 'package:dio/dio.dart';
import 'package:kebda_zaman/core/api/api_client.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/order_notification.dart';
import 'package:kebda_zaman/features/admin/domain/repositories/admin_order_notification_repository.dart';

/// Confirmed backend contract (do not add fallback/alternative parsing —
/// if the response doesn't match this shape, let the cast/parse fail so the
/// failure surfaces through the normal Result -> AsyncError -> Retry UI path):
///
/// - `GET /admin/notifications` -> raw JSON array of notification objects,
///   no pagination envelope, already sorted newest first.
/// - `GET /admin/notifications/unread-count` -> `{ "count": number }`.
/// - `PATCH /admin/notifications/:id/read` -> the updated notification object.
/// - `PATCH /admin/notifications/read-all` -> `{ "updated": number }`.
/// - `DELETE /admin/notifications` -> 204 No Content.
class ApiAdminOrderNotificationRepository
    implements AdminOrderNotificationRepository {
  final ApiClient _apiClient;

  ApiAdminOrderNotificationRepository(this._apiClient);

  @override
  Future<Result<List<OrderNotification>>> getNotifications({
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.dio.get(
        '/admin/notifications',
        queryParameters: queryParams,
      );
      final list = response.data as List;
      return Success(
        list
            .map((json) => _mapNotification(json as Map<String, dynamic>))
            .toList(),
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
      return const Err(NetworkFailure('Failed to load notifications'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading notifications'));
    }
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get(
        '/admin/notifications/unread-count',
      );
      final data = response.data as Map<String, dynamic>;
      return Success((data['count'] as num).toInt());
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to load unread count'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error loading unread count'));
    }
  }

  @override
  Future<Result<OrderNotification>> markAsRead(String id) async {
    try {
      final response = await _apiClient.dio.patch(
        '/admin/notifications/$id/read',
      );
      return Success(_mapNotification(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      if (e.error is ApiException) {
        return Err(
          NetworkFailure(
            (e.error as ApiException).message,
            e.error as ApiException,
          ),
        );
      }
      return const Err(NetworkFailure('Failed to mark notification as read'));
    } catch (e) {
      return const Err(
        UnknownFailure('Unknown error marking notification as read'),
      );
    }
  }

  @override
  Future<Result<int>> markAllAsRead() async {
    try {
      final response = await _apiClient.dio.patch(
        '/admin/notifications/read-all',
      );
      final data = response.data as Map<String, dynamic>;
      return Success((data['updated'] as num).toInt());
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
        NetworkFailure('Failed to mark all notifications as read'),
      );
    } catch (e) {
      return const Err(
        UnknownFailure('Unknown error marking all notifications as read'),
      );
    }
  }

  @override
  Future<Result<void>> clearAll() async {
    try {
      await _apiClient.dio.delete('/admin/notifications');
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
      return const Err(NetworkFailure('Failed to clear notifications'));
    } catch (e) {
      return const Err(UnknownFailure('Unknown error clearing notifications'));
    }
  }

  OrderNotification _mapNotification(Map<String, dynamic> json) {
    return OrderNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      orderId: json['orderId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      orderNumber: json['orderNumber'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal(),
    );
  }
}
