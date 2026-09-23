import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/forgot_password_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Widget coverage for the "Forgot password?" entry screen: success shows
/// only the generic, no-enumeration copy; validation/cooldown/rate-limit/
/// network failures each show the right message; a submission in flight
/// can't be duplicated.
class _ScriptableAuthRepository implements AuthRepository {
  Future<Result<void>> Function(String email)? onForgotPassword;
  int forgotPasswordCallCount = 0;

  @override
  Future<Result<void>> forgotPassword(String email) async {
    forgotPasswordCallCount++;
    return onForgotPassword!(email);
  }

  @override
  Future<Result<void>> resetPassword({
    required String token,
    required String password,
  }) async => throw UnimplementedError();

  @override
  Future<Result<User?>> getCurrentUser() async => const Success(null);
  @override
  Future<Result<void>> logout() async => const Success(null);
  @override
  Future<Result<void>> deleteAccount() async => throw UnimplementedError();
  @override
  Future<Result<User>> login(String email, String password) async =>
      throw UnimplementedError();
  @override
  Future<Result<User>> adminLogin(String email, String password) async =>
      throw UnimplementedError();
  @override
  Future<Result<User>> googleLogin(String firebaseIdToken) async =>
      throw UnimplementedError();
  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async => throw UnimplementedError();
  @override
  Future<Result<User>> guestLogin() async => throw UnimplementedError();
  @override
  Future<Result<User>> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? locale,
  }) async => throw UnimplementedError();
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: '/forgot-password',
    routes: [
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Text('LOGIN')),
      ),
    ],
  );
}

Future<_ScriptableAuthRepository> _pump(WidgetTester tester) async {
  final repo = _ScriptableAuthRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repo)],
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        startLocale: const Locale('en'),
        fallbackLocale: const Locale('en'),
        useOnlyLangCode: true,
        saveLocale: false,
        assetLoader: const CodegenLoader(),
        child: Builder(
          builder: (context) => MaterialApp.router(
            routerConfig: _buildRouter(),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

Future<void> _enterEmailAndSubmit(WidgetTester tester, String email) async {
  await tester.enterText(find.byType(TextFormField), email);
  await tester.tap(find.text('Send Reset Link'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'success shows only the generic no-enumeration message, never "no account found"',
    (tester) async {
      final repo = await _pump(tester);
      repo.onForgotPassword = (_) async => const Success(null);

      await _enterEmailAndSubmit(tester, 'customer@example.com');

      expect(
        find.text(
          "If this email is eligible, you'll receive a password reset link shortly.",
        ),
        findsOneWidget,
      );
      expect(find.textContaining('no account'), findsNothing);
      expect(find.textContaining('not found'), findsNothing);
    },
  );

  testWidgets('a resend countdown appears after success', (tester) async {
    final repo = await _pump(tester);
    repo.onForgotPassword = (_) async => const Success(null);

    await _enterEmailAndSubmit(tester, 'customer@example.com');

    expect(find.text('Resend available in 60s'), findsOneWidget);
  });

  testWidgets('an invalid email shows a client-side validation error, no network call', (
    tester,
  ) async {
    final repo = await _pump(tester);
    repo.onForgotPassword = (_) async => const Success(null);

    await _enterEmailAndSubmit(tester, 'not-an-email');

    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(repo.forgotPasswordCallCount, 0);
  });

  testWidgets('a 429 PASSWORD_RESET_COOLDOWN shows the cooldown message', (
    tester,
  ) async {
    final repo = await _pump(tester);
    repo.onForgotPassword = (_) async => Err(
      PasswordResetRateLimitedFailure(
        'Please wait before requesting another link.',
        ApiException(
          statusCode: 429,
          error: 'Too Many Requests',
          message: 'Please wait before requesting another link.',
          code: 'PASSWORD_RESET_COOLDOWN',
        ),
        null,
      ),
    );

    await _enterEmailAndSubmit(tester, 'customer@example.com');

    expect(
      find.text(
        'You already requested a link recently. Please wait a moment before trying again.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a network failure shows the generic network-error message', (
    tester,
  ) async {
    final repo = await _pump(tester);
    repo.onForgotPassword = (_) async =>
        const Err(NetworkFailure('You appear to be offline.'));

    await _enterEmailAndSubmit(tester, 'customer@example.com');

    expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
  });

  testWidgets('a submission in flight cannot be duplicated', (tester) async {
    final repo = await _pump(tester);
    repo.onForgotPassword = (_) async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return const Success(null);
    };

    await tester.enterText(find.byType(TextFormField), 'customer@example.com');
    // Two rapid taps before the first request resolves. The second tap's
    // target may already be mid-transition to the loading spinner
    // (AnimatedSwitcher), so warnIfMissed is disabled for it — the
    // assertion that matters is the call count below, not the tap itself
    // landing pixel-perfect.
    await tester.tap(find.text('Send Reset Link'));
    await tester.pump(const Duration(milliseconds: 20));
    await tester.tap(find.text('Send Reset Link'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(repo.forgotPasswordCallCount, 1);
  });
}
