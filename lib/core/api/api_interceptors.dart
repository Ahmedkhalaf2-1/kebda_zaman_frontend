import 'package:dio/dio.dart';
import 'api_exceptions.dart';
import 'token_refresh_coordinator.dart';

class TokenStorage {
  String? accessToken;
}

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenRefreshCoordinator coordinator;

  static const String _retriedAfterRefreshKey = '__retriedAfterRefresh';

  AuthInterceptor(this.dio, {required this.coordinator});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Inject token if needed.
    final String? accessToken = coordinator.tokenStorage.accessToken;

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 1. Handle canonical backend error-envelope parsing
    if (err.response?.data != null &&
        err.response?.data is Map<String, dynamic>) {
      final responseData = err.response!.data as Map<String, dynamic>;
      if (responseData.containsKey('code')) {
        final apiException = ApiException.fromJson(responseData);
        // Attach domain-specific exception to DioException
        err = err.copyWith(error: apiException);
      }
    }

    // 2. Automatic 401 -> refresh token (single-flight) -> retry original request ONCE
    if (err.response?.statusCode == 401) {
      // Never attempt to refresh for the refresh endpoint's own failures —
      // that would recurse forever.
      if (err.requestOptions.path.contains('/auth/refresh')) {
        return handler.next(err);
      }

      // Prevent infinite retry loops: a request is only ever retried once
      // after a refresh, even if that retry also comes back 401.
      final alreadyRetried =
          err.requestOptions.extra[_retriedAfterRefreshKey] == true;
      if (alreadyRetried) {
        return handler.next(err);
      }

      final outcome = await coordinator.refresh();
      if (outcome is RefreshSuccess) {
        err.requestOptions.headers['Authorization'] =
            'Bearer ${outcome.accessToken}';
        err.requestOptions.extra[_retriedAfterRefreshKey] = true;
        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      }

      // RefreshRejected / RefreshNoToken / RefreshTransientFailure — none of
      // these produce a usable token, so the original 401 propagates as-is.
      return handler.next(err);
    }

    return handler.next(err);
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor(this.dio, {this.maxRetries = 3});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err)) {
      final int attempt = err.requestOptions.extra['retryAttempt'] as int? ?? 0;
      if (attempt < maxRetries) {
        err.requestOptions.extra['retryAttempt'] = attempt + 1;

        // Wait before retrying (exponential backoff)
        final delay = Duration(milliseconds: 500 * (attempt + 1));
        await Future.delayed(delay);

        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          if (e is DioException) {
            return onError(e, handler);
          }
        }
      }
    }

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      err = err.copyWith(
        error: ApiException(
          statusCode: 503,
          error: 'Service Unavailable',
          code: 'OFFLINE',
          message: 'You appear to be offline. Please check your connection.',
        ),
      );
    }
    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
