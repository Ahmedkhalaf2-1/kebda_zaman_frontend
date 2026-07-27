class ApiConfig {
  // Using --dart-define=API_BASE_URL=http://192.168.1.51:3000/api/v1
  // Fallback to dev value if not defined
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.51:3000/api/v1',
  );
}
