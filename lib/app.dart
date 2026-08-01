import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/router/router.dart';
import 'core/theme/kz_design_system.dart';
import 'core/widgets/kz_responsive_wrapper.dart';
import 'core/di/providers.dart';
import 'core/session/session_coordinator.dart';
import 'features/customer/presentation/notifiers/session_bootstrap_notifier.dart';

import 'core/notifications/notification_navigation_service.dart';
import 'core/notifications/notification_service.dart';

class KebdaZamanApp extends ConsumerWidget {
  const KebdaZamanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);
    // Locale-driven type system: Arabic renders in Alexandria, everything
    // else in Plus Jakarta Sans. Applying it via ThemeData.fontFamily lets
    // every TextTheme role (and any KZ.* style that leaves fontFamily unset)
    // resolve the correct family automatically — no per-widget overrides.
    final arabicLocale = context.locale.languageCode == 'ar';
    final fontFamily = arabicLocale ? 'Alexandria' : 'Plus Jakarta Sans';
    // Eagerly initialize device repository so DeviceService is configured
    // before AuthNotifier restores the session and calls onSessionEstablished()
    ref.watch(deviceRepositoryProvider);
    // Initialize the root session lifecycle listener. This single watch starts
    // the auth-state listener that clears/reloads user-scoped providers on
    // every auth transition (login, logout, user switch, session restoration).
    ref.watch(sessionLifecycleProvider);
    ref.watch(sessionBootstrapProvider);
    NotificationNavigationService.instance.setRouter(goRouter);
    NotificationService.instance.attachProviderContainer(
      ProviderScope.containerOf(context),
    );

    return MaterialApp.router(
      title: 'Kebda Zaman',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) {
        final location = goRouter.routerDelegate.currentConfiguration.uri.path;
        return KZResponsiveWrapper(
          location: location,
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: KZ.primary,
          primary: KZ.primary,
          secondary: KZ.secondary,
          tertiary: KZ.tertiary,
          surface: KZ.surface,
          error: KZ.error,
        ),
        scaffoldBackgroundColor: KZ.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: KZ.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: KZ.primary),
          titleTextStyle: KZ.headingStyle,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: KZ.surface,
          labelStyle: const TextStyle(fontSize: 13, color: KZ.onSurfaceVariant),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(KZ.radiusMd),
            borderSide: const BorderSide(color: KZ.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(KZ.radiusMd),
            borderSide: const BorderSide(color: KZ.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(KZ.radiusMd),
            borderSide: const BorderSide(color: KZ.primaryContainer, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(KZ.radiusMd),
            borderSide: const BorderSide(color: KZ.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(KZ.radiusMd),
            borderSide: const BorderSide(color: KZ.error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: KZ.outlineVariant,
          thickness: 1,
          space: 1,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? KZ.primaryContainer
                : KZ.secondary,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? KZ.primaryContainer.withOpacity(0.4)
                : KZ.surfaceContainerHigh,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(KZ.primary),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KZ.radiusFull),
              ),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(KZ.primary),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KZ.radiusFull),
              ),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            ),
            elevation: const WidgetStatePropertyAll(4),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const WidgetStatePropertyAll(KZ.primary),
            side: const WidgetStatePropertyAll(
              BorderSide(color: KZ.primary, width: 1.5),
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KZ.radiusFull),
              ),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: const WidgetStatePropertyAll(KZ.primary),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KZ.radiusFull),
              ),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          side: const BorderSide(color: KZ.outlineVariant),
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KZ.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: KZ.onSurface,
          contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KZ.radiusMd),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KZ.radiusLg),
            side: const BorderSide(color: KZ.outlineVariant, width: 0.5),
          ),
        ),
      ),
      routerConfig: goRouter,
    );
  }
}
