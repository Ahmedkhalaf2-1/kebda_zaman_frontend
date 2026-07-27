import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<ProviderContainer> bootstrap() async {
  // Add initialization logic here (e.g. shared preferences, local DB)
  final container = ProviderContainer();
  return container;
}
