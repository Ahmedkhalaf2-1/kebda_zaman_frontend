import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/reset_password_screen.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:kebda_zaman/generated/codegen_loader.g.dart';

/// Widget coverage for the public reset-password landing page: missing/
/// malformed tokens never reach the network, password-confirmation
/// validation, a successful reset's "go to login" state, and each of the
/// three distinct token-rejection codes producing the correct
/// invalid-link message (never a generic one that hides which case it is).
class _ScriptableAuthRepository implements AuthRepository {
  Future<Result<void>> Function({required String token, required String password})?
  onResetPassword;
  int resetPasswordCallCount = 0;

  @override
  Future<Result<void>> resetPassword({
    required String token,
    required String password,
  }) async {
    resetPasswordCallCount++;
    return onResetPassword!(token: token, password: password);
  }

  @override
  Future<Result<void>> forgotPassword(String email) async =>
      throw UnimplementedError();

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

/// Mirrors router.dart's own `/reset-password` `pageBuilder` token
/// extraction exactly (defensive try/catch around
/// `state.uri.queryParameters['token']`) so this test exercises the same
/// parsing behavior the real router uses, without needing to instantiate
/// the app's entire route tree.
GoRouter _buildRouter(String initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          String? token;
          try {
            token = state.uri.queryParameters['token'];
          } catch (_) {
            token = null;
          }
          return ResetPasswordScreen(token: token);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const Scaffold(body: Text('FORGOT')),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Text('LOGIN')),
      ),
    ],
  );
}

Future<_ScriptableAuthRepository> _pump(
  WidgetTester tester,
  String initialLocation,
) async {
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
            routerConfig: _buildRouter(initialLocation),
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

Future<void> _fillPasswords(
  WidgetTester tester, {
  required String password,
  required String confirm,
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), password);
  await tester.enterText(fields.at(1), confirm);
  await tester.tap(find.text('Reset Password'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('missing/malformed token — never auto-submits, never calls the network', () {
    testWidgets('no token query param at all', (tester) async {
      final repo = await _pump(tester, '/reset-password');

      expect(
        find.text('This reset link is missing or malformed. Please request a new one.'),
        findsOneWidget,
      );
      expect(repo.resetPasswordCallCount, 0);
      // Never a bare form on an unusable link.
      expect(find.text('Reset Password'), findsNothing);
    });

    testWidgets('an empty token value', (tester) async {
      final repo = await _pump(tester, '/reset-password?token=');

      expect(
        find.text('This reset link is missing or malformed. Please request a new one.'),
        findsOneWidget,
      );
      expect(repo.resetPasswordCallCount, 0);
    });

    testWidgets('a token far past the 512-char contract limit', (tester) async {
      final repo = await _pump(
        tester,
        '/reset-password?token=${'a' * 600}',
      );

      expect(
        find.text('This reset link is missing or malformed. Please request a new one.'),
        findsOneWidget,
      );
      expect(repo.resetPasswordCallCount, 0);
    });

    testWidgets('"Request a new link" goes to /forgot-password', (tester) async {
      await _pump(tester, '/reset-password');

      await tester.tap(find.text('Request a New Link'));
      await tester.pumpAndSettle();

      expect(find.text('FORGOT'), findsOneWidget);
    });
  });

  testWidgets('opening a well-formed link never auto-submits', (tester) async {
    final repo = await _pump(tester, '/reset-password?token=valid-raw-token');

    // The form is shown, but nothing was sent until the user acts.
    expect(find.text('Reset Password'), findsOneWidget);
    expect(repo.resetPasswordCallCount, 0);
  });

  testWidgets('mismatched passwords show a validation error, no network call', (
    tester,
  ) async {
    final repo = await _pump(tester, '/reset-password?token=valid-raw-token');

    await _fillPasswords(tester, password: 'longEnough1', confirm: 'different1');

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(repo.resetPasswordCallCount, 0);
  });

  testWidgets('a too-short password shows the length validation error', (
    tester,
  ) async {
    final repo = await _pump(tester, '/reset-password?token=valid-raw-token');

    await _fillPasswords(tester, password: 'short1', confirm: 'short1');

    expect(
      find.text('Password must be between 8 and 72 characters.'),
      findsOneWidget,
    );
    expect(repo.resetPasswordCallCount, 0);
  });

  testWidgets('a successful reset shows the success state and a way back to login', (
    tester,
  ) async {
    final repo = await _pump(tester, '/reset-password?token=valid-raw-token');
    repo.onResetPassword = ({required token, required password}) async =>
        const Success(null);

    await _fillPasswords(tester, password: 'newPassword123', confirm: 'newPassword123');

    expect(find.text('Password updated'), findsOneWidget);
    expect(find.text('Go to Log In'), findsOneWidget);

    await tester.tap(find.text('Go to Log In'));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);
  });

  for (final entry in {
    'INVALID_RESET_TOKEN': 'This password reset link is invalid. Please request a new one.',
    'RESET_TOKEN_EXPIRED':
        'This password reset link has expired. Please request a new one.',
    'RESET_TOKEN_ALREADY_USED':
        'This password reset link has already been used. Please request a new one.',
  }.entries) {
    testWidgets('${entry.key} switches to the correct invalid-link message', (
      tester,
    ) async {
      final repo = await _pump(tester, '/reset-password?token=valid-raw-token');
      repo.onResetPassword = ({required token, required password}) async => Err(
        AuthFailure(
          'nope',
          ApiException(
            statusCode: 401,
            error: 'Unauthorized',
            message: 'nope',
            code: entry.key,
          ),
        ),
      );

      await _fillPasswords(
        tester,
        password: 'newPassword123',
        confirm: 'newPassword123',
      );

      expect(find.text('This link is no longer valid'), findsOneWidget);
      expect(find.text(entry.value), findsOneWidget);
      // The dead-end form is gone — the only way forward is a new link.
      expect(find.text('Reset Password'), findsNothing);
    });
  }

  testWidgets('a generic 429 keeps the form (the token itself is still valid)', (
    tester,
  ) async {
    final repo = await _pump(tester, '/reset-password?token=valid-raw-token');
    repo.onResetPassword = ({required token, required password}) async =>
        const Err(
          PasswordResetRateLimitedFailure('Too many requests', null, null),
        );

    await _fillPasswords(
      tester,
      password: 'newPassword123',
      confirm: 'newPassword123',
    );

    expect(find.text('Too many attempts. Please try again later.'), findsOneWidget);
    // Still on the form — a rate limit doesn't invalidate the token.
    expect(find.text('Reset Password'), findsOneWidget);
  });
}
