import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_auth_layout.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/password_reset_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';

/// A simple, deliberately unstrict email-shape check — just enough to catch
/// an obviously malformed address before spending a network round trip.
/// The backend's `@IsEmail` remains the actual source of truth; this only
/// improves the error message for the common "forgot the @" typo case.
final RegExp _kSimpleEmailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// The "Forgot password?" entry-point screen — public, reachable while
/// logged out (and left reachable even if a session happens to exist; see
/// router.dart). Always shows the same generic success copy regardless of
/// whether the submitted email matches an account, per
/// PASSWORD_RESET_API_CONTRACT.md's no-enumeration guarantee — this screen
/// must never be extended to say "no account found" for any response.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _submitting = false;
  bool _sent = false;
  String? _errorMessage;

  Timer? _countdownTimer;
  int _resendSecondsLeft = 0;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Starts (or restarts) the resend countdown. [seconds] is either this
  /// screen's own 60s post-success UX policy, or a real server-supplied
  /// `Retry-After` value on a cooldown/rate-limit error — never a guessed
  /// number standing in for one the server didn't send.
  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    setState(() => _resendSecondsLeft = seconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendSecondsLeft -= 1;
        if (_resendSecondsLeft <= 0) {
          _resendSecondsLeft = 0;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _submit() async {
    if (_submitting) return; // Duplicate-submission guard.
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final email = _emailCtrl.text.trim();
    final result = await ref
        .read(passwordResetControllerProvider)
        .forgotPassword(email);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _submitting = false;
          _errorMessage = _messageFor(failure);
        });
        if (failure is PasswordResetRateLimitedFailure &&
            failure.retryAfterSeconds != null) {
          _startCountdown(failure.retryAfterSeconds!);
        }
      },
      (_) {
        setState(() {
          _submitting = false;
          _sent = true;
        });
        // Our own UX policy (not a claim about the server's actual
        // per-email cooldown window) — see class doc on [_startCountdown].
        _startCountdown(60);
      },
    );
  }

  String _messageFor(Failure failure) {
    final cause = failure.cause;
    final code = cause is ApiException ? cause.code : null;
    if (failure is PasswordResetRateLimitedFailure) {
      if (code == 'PASSWORD_RESET_COOLDOWN') {
        return 'password_reset.cooldown_message'.tr();
      }
      if (code == 'PASSWORD_RESET_RATE_LIMITED') {
        return 'password_reset.rate_limited_message'.tr();
      }
      // Generic per-IP ThrottlerException — no distinguishing code.
      return 'password_reset.rate_limited_generic'.tr();
    }
    if (code == 'VALIDATION_ERROR') {
      return 'password_reset.invalid_email'.tr();
    }
    if (failure is NetworkFailure) {
      return 'common.something_wrong'.tr();
    }
    return failure.message;
  }

  @override
  Widget build(BuildContext context) {
    return KZAuthHeroScaffold(
      heroSubtitle: 'password_reset.forgot_subtitle'.tr(),
      showBackButton: true,
      onBack: () =>
          Navigator.canPop(context) ? context.pop() : context.go('/login'),
      child: _sent ? _buildSentState() : _buildFormState(),
    );
  }

  Widget _buildFormState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_errorMessage != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KZ.sp14),
            decoration: BoxDecoration(
              color: KZ.errorContainer,
              borderRadius: BorderRadius.circular(KZ.radiusMd),
              border: Border.all(color: KZ.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: KZ.error,
                  size: 22,
                ),
                const SizedBox(width: KZ.sp10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: KZ.bodySmall.copyWith(
                      color: KZ.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KZ.sp20),
        ],
        Text(
          'password_reset.forgot_title'.tr(),
          style: KZ.sectionTitle,
        ),
        const SizedBox(height: KZ.sp8),
        Text(
          'password_reset.forgot_body'.tr(),
          style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
        ),
        const SizedBox(height: KZ.sp24),
        Form(
          key: _formKey,
          child: KZAuthTextField(
            controller: _emailCtrl,
            label: 'auth.email'.tr(),
            hint: 'auth.email_hint'.tr(),
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              final value = v?.trim() ?? '';
              if (value.isEmpty) {
                return 'auth.fill_all_fields'.tr();
              }
              if (value.length > 255 || !_kSimpleEmailPattern.hasMatch(value)) {
                return 'password_reset.invalid_email'.tr();
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: KZ.sp24),
        KZButton(
          label: 'password_reset.send_link_btn'.tr(),
          fullWidth: true,
          loading: _submitting,
          onPressed:
              (_submitting || _resendSecondsLeft > 0) ? null : _submit,
        ),
        if (_resendSecondsLeft > 0) ...[
          const SizedBox(height: KZ.sp10),
          Text(
            'password_reset.resend_countdown'.tr(
              namedArgs: {'seconds': '$_resendSecondsLeft'},
            ),
            style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
          ),
        ],
        const SizedBox(height: KZ.sp20),
        Center(
          child: TextButton(
            onPressed: () =>
                Navigator.canPop(context) ? context.pop() : context.go('/login'),
            child: Text('password_reset.back_to_login'.tr()),
          ),
        ),
      ],
    );
  }

  Widget _buildSentState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(KZ.sp16),
          decoration: BoxDecoration(
            color: KZ.tertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(KZ.radiusMd),
            border: Border.all(color: KZ.tertiary.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                color: KZ.tertiary,
                size: 26,
              ),
              const SizedBox(width: KZ.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'password_reset.check_inbox_title'.tr(),
                      style: KZ.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: KZ.sp6),
                    Text(
                      'password_reset.generic_sent_message'.tr(),
                      style: KZ.bodySmall.copyWith(color: KZ.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KZ.sp28),
        KZButton(
          label: _resendSecondsLeft > 0
              ? 'password_reset.resend_countdown'.tr(
                  namedArgs: {'seconds': '$_resendSecondsLeft'},
                )
              : 'password_reset.resend_btn'.tr(),
          variant: KZButtonVariant.secondary,
          fullWidth: true,
          loading: _submitting,
          onPressed: (_resendSecondsLeft > 0 || _submitting) ? null : _submit,
        ),
        const SizedBox(height: KZ.sp20),
        Center(
          child: TextButton(
            onPressed: () => context.go('/login'),
            child: Text('password_reset.back_to_login'.tr()),
          ),
        ),
      ],
    );
  }
}
