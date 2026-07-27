import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A secure logging interceptor for Dio that redacts sensitive information such as:
/// - Passwords, Access Tokens, Refresh Tokens, FCM Tokens
/// - Authorization Headers
/// - Sensitive endpoint payloads (Device token registration & Refresh endpoints)
///
/// In Release mode ([kDebugMode] == false), request/response body and header logging is disabled.
class SafeLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!kDebugMode) {
      return handler.next(options);
    }

    final path = options.path;
    final method = options.method.toUpperCase();
    debugPrint('--> $method ${options.uri}');

    final sanitizedHeaders = _sanitizeHeaders(options.headers);
    debugPrint('Headers: $sanitizedHeaders');

    if (options.data != null) {
      if (_isFullyRedactedPath(path)) {
        debugPrint('Body: [REDACTED_SENSITIVE_PAYLOAD]');
      } else {
        final sanitizedBody = _sanitizeData(options.data);
        debugPrint('Body: $sanitizedBody');
      }
    }

    debugPrint('--> END $method');
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!kDebugMode) {
      return handler.next(response);
    }

    final path = response.requestOptions.path;
    final method = response.requestOptions.method.toUpperCase();
    debugPrint(
      '<-- ${response.statusCode} $method ${response.requestOptions.uri}',
    );

    if (response.data != null) {
      if (_isFullyRedactedPath(path)) {
        debugPrint('Response: [REDACTED_SENSITIVE_PAYLOAD]');
      } else {
        final sanitizedData = _sanitizeData(response.data);
        debugPrint('Response: $sanitizedData');
      }
    }

    debugPrint('<-- END HTTP');
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kDebugMode) {
      return handler.next(err);
    }

    final method = err.requestOptions.method.toUpperCase();
    debugPrint(
      '<-- ERROR ${err.response?.statusCode ?? 'NETWORK_ERROR'} $method ${err.requestOptions.uri}',
    );
    debugPrint('Message: ${err.message}');
    if (err.response?.data != null) {
      final sanitizedData = _sanitizeData(err.response!.data);
      debugPrint('Error Data: $sanitizedData');
    }
    debugPrint('<-- END ERROR');
    return handler.next(err);
  }

  bool _isFullyRedactedPath(String path) {
    final lower = path.toLowerCase();
    return lower.contains('/devices/register') ||
        lower.contains('/devices/token') ||
        lower.contains('/auth/refresh');
  }

  Map<String, String> _sanitizeHeaders(Map<String, dynamic> headers) {
    final Map<String, String> result = {};
    headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') {
        result[key] = 'Bearer [REDACTED]';
      } else {
        result[key] = value.toString();
      }
    });
    return result;
  }

  dynamic _sanitizeData(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final Map<String, dynamic> result = {};
      data.forEach((key, value) {
        final k = key.toString();
        final lowerKey = k.toLowerCase();
        if (lowerKey.contains('password') ||
            lowerKey == 'accesstoken' ||
            lowerKey == 'refreshtoken' ||
            lowerKey == 'token' ||
            lowerKey == 'oldtoken' ||
            lowerKey == 'fcmtoken' ||
            lowerKey == 'authorization') {
          result[k] = '[REDACTED]';
        } else {
          result[k] = _sanitizeData(value);
        }
      });
      return result;
    } else if (data is List) {
      return data.map((item) => _sanitizeData(item)).toList();
    }
    return data;
  }
}
