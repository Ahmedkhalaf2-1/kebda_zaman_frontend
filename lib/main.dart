import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'generated/codegen_loader.g.dart';
import 'core/notifications/notification_service.dart';
import 'core/api/api_config.dart';
import 'app.dart';

import 'dart:async';
import 'package:flutter/foundation.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await EasyLocalization.ensureInitialized();
      await NotificationService.instance.initialize();

      debugPrint('Running with API_BASE_URL: ${ApiConfig.baseUrl}');

      FlutterError.onError = (FlutterErrorDetails details) {
        debugPrint('Flutter Error: ${details.exceptionAsString()}');
        // In production, send to Crashlytics or Sentry here
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('Platform Error: $error');
        // In production, send to Crashlytics or Sentry here
        return true;
      };

      runApp(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          startLocale: const Locale('en'),
          useOnlyLangCode: true,
          useFallbackTranslations: true,
          assetLoader: const CodegenLoader(),
          child: const ProviderScope(child: KebdaZamanApp()),
        ),
      );
    },
    (error, stackTrace) {
      debugPrint('Uncaught Error: $error');
      // In production, send to Crashlytics or Sentry here
    },
  );
}
