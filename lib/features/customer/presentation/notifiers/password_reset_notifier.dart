import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';

/// Standalone controller for the public forgot/reset-password flow.
///
/// Deliberately NOT a [StateNotifier]/folded into `AuthNotifier`: both
/// [ForgotPasswordScreen]/[ResetPasswordScreen] already track their own
/// local "submitting" flag (checked synchronously before any async gap,
/// same pattern as every other auth screen's duplicate-submission guard),
/// and nothing ever watches this controller's own state — under
/// `Provider.autoDispose`, that means it can be disposed while a call is
/// still in flight. A plain mutable field on a plain object tolerates
/// that fine; a `StateNotifier` does not (mutating `state` after dispose
/// throws in debug mode). [_inFlight] here is just a defense-in-depth
/// backstop, not the primary guard.
class PasswordResetController {
  PasswordResetController(this._ref);

  final Ref _ref;
  bool _inFlight = false;

  Future<Result<void>> forgotPassword(String email) async {
    if (_inFlight) {
      return const Err(UnknownFailure('A request is already in progress.'));
    }
    _inFlight = true;
    try {
      return await _ref.read(authRepositoryProvider).forgotPassword(email);
    } finally {
      _inFlight = false;
    }
  }

  Future<Result<void>> resetPassword({
    required String token,
    required String password,
  }) async {
    if (_inFlight) {
      return const Err(UnknownFailure('A request is already in progress.'));
    }
    _inFlight = true;
    try {
      return await _ref
          .read(authRepositoryProvider)
          .resetPassword(token: token, password: password);
    } finally {
      _inFlight = false;
    }
  }
}

final passwordResetControllerProvider = Provider.autoDispose<PasswordResetController>(
  (ref) => PasswordResetController(ref),
);
