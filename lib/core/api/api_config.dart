class ApiConfig {
  // Override for local dev with --dart-define=API_BASE_URL=http://192.168.1.51:3000/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.kebdazaman.cloud/api/v1',
  );
}
