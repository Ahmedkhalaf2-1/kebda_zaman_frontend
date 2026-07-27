class ApiException implements Exception {
  final int statusCode;
  final String error;
  final String message;
  final String code;
  final Map<String, dynamic>? details;

  ApiException({
    required this.statusCode,
    required this.error,
    required this.message,
    required this.code,
    this.details,
  });

  factory ApiException.fromJson(Map<String, dynamic> json) {
    return ApiException(
      statusCode: json['statusCode'] as int? ?? 500,
      error: json['error'] as String? ?? 'Unknown',
      message: json['message'] as String? ?? 'An unknown error occurred.',
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() => 'ApiException(code: $code, message: $message)';
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
