import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/widgets/biometric_onboarding_dialog.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';

/// Staff roles never see customer surfaces (biometric onboarding, customer
/// navigation) — each lands directly on its own section.
bool isStaffRole(User? user) =>
    user?.role == 'ADMIN' ||
    user?.role == 'CASHIER' ||
    user?.role == 'KITCHEN' ||
    user?.role == 'DRIVER';

/// The landing route for [user]'s role after a successful sign-in.
String homeRouteForUser(User? user) => switch (user?.role) {
  'ADMIN' => '/admin/dashboard',
  // Cashiers never see customer navigation — they land directly on
  // Orders Management, the only admin section they're allowed into.
  'CASHIER' => '/admin/orders',
  // Kitchen staff land directly on their ticket queue — same
  // confined-to-one-section pattern as cashiers above.
  'KITCHEN' => '/admin/kitchen',
  // Drivers land directly on their own app — never customer navigation.
  'DRIVER' => '/driver/orders',
  _ => '/home',
};

/// Shared tail of every interactive sign-in (email, Google, Apple): offers
/// the one-time biometric onboarding to customers, then routes by role.
Future<void> completeSignIn(BuildContext context, WidgetRef ref) async {
  final user = ref.read(authNotifierProvider).user;
  if (!isStaffRole(user)) {
    await maybeShowBiometricOnboardingDialog(context, ref);
    if (!context.mounted) return;
  }
  context.go(homeRouteForUser(user));
}
