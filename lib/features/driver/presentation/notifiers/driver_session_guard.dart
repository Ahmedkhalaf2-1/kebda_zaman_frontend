import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';

/// Every driver-facing repository call maps a 401 (ordinary expired token
/// that still failed after `AuthInterceptor`'s transparent refresh-and-retry,
/// or a deactivated account — see `AuthInterceptor`'s `DRIVER_DEACTIVATED`
/// handling, which deliberately skips the refresh attempt) to [AuthFailure].
/// Either way the local session is over: this ends it immediately via
/// [AuthNotifier.clearLocalSession] (local-only, no network call — mirrors
/// how [SessionBootstrapNotifier] already reacts to a definitive refresh
/// rejection) so the router's DRIVER redirect guard sends the app back to
/// `/login` and every driver/order provider gets cleared by
/// `sessionLifecycleProvider`.
///
/// Call this from a driver notifier's own `ref` right after any repository
/// call fails, before surfacing the failure to the UI.
Future<void> endDriverSessionIfAuthFailure(Ref ref, Failure failure) async {
  if (failure is AuthFailure) {
    await ref.read(authNotifierProvider.notifier).clearLocalSession();
  }
}
