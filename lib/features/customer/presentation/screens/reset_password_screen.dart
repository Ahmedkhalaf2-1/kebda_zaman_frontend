import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/kz_web_referrer_guard.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_auth_layout.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/password_reset_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';

enum _ResetPhase { form, invalidLink, success }

/// The public reset-password landing page — the page an emailed reset link
/// (`{PASSWORD_RESET_URL}?token={raw_token}`) actually opens in a browser.
/// Reachable while logged out, and left reachable even if the device
/// happens to already have a session (router.dart never redirects this
/// path away) — opening the link never disturbs an unrelated session by
/// itself; only a *successful* reset clears the local session here, since
/// the backend has by then revoked every refresh-token session for this
/// account anyway (PASSWORD_RESET_API_CONTRACT.md §Session invalidation).
///
/// Never auto-submits on open: the token is only ever sent once the user
/// actually presses the submit button with a chosen password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  /// Raw value of the `token` query parameter, or `null`/empty if the link
  /// was missing, malformed, or opened without one at all — all three are
  /// handled identically (an immediate "link invalid" state, no network
  /// call ever attempted).
  final String? token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _errorMessage;

  late _ResetPhase _phase;
  String? _invalidLinkMessage;

  @override
  void initState() {
    super.initState();
    applyStrictNoReferrer();
    // Token length policy per PASSWORD_RESET_API_CONTRACT.md (1-512 chars)
    // — a value outside that range can never succeed server-side, so this
    // skips a pointless network round trip. Anything else (including a
    // "well-formed-looking" token) is left entirely to the actual
    // reset-password call: this screen has no way to know a token is
    // genuinely valid without asking the backend.
    final token = widget.token;
    if (token == null || token.isEmpty || token.length > 512) {
      _phase = _ResetPhase.invalidLink;
      _invalidLinkMessage = 'password_reset.missing_token_message'.tr();
    } else {
      _phase = _ResetPhase.form;
    }
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    restoreDefaultReferrerPolicy();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return; // Duplicate-submission guard.
    if (!_formKey.currentState!.validate()) return;
    final token = widget.token;
    if (token == null) return; // Unreachable — form phase implies a token.

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(passwordResetControllerProvider)
        .resetPassword(token: token, password: _passwordCtrl.text);

    if (!mounted) return;

    await result.fold(
      (failure) async {
        final cause = failure.cause;
        final code = cause is ApiException ? cause.code : null;
        if (code == 'INVALID_RESET_TOKEN' ||
            code == 'RESET_TOKEN_ALREADY_USED' ||
            code == 'RESET_TOKEN_EXPIRED') {
          setState(() {
            _submitting = false;
            _phase = _ResetPhase.invalidLink;
            _invalidLinkMessage = switch (code) {
              'RESET_TOKEN_EXPIRED' => 'password_reset.expired_link_message'.tr(),
              'RESET_TOKEN_ALREADY_USED' =>
                'password_reset.used_link_message'.tr(),
              _ => 'password_reset.invalid_link_message'.tr(),
            };
          });
          return;
        }
        setState(() {
          _submitting = false;
          _errorMessage = _messageFor(failure, code);
        });
      },
      (_) async {
        // The backend has just revoked every refresh-token session for this
        // account. If this device happens to be signed into that same
        // account right now, its local session is dead server-side too —
        // clear it locally so the UI doesn't keep claiming to be logged in
        // with credentials that no longer work. This never touches any
        // *other* account's session, and never runs on an invalid-token
        // failure above (an unrelated session must never be punished for a
        // bad/expired link).
        if (mounted && ref.read(authNotifierProvider).isLoggedIn) {
          await ref.read(authNotifierProvider.notifier).clearLocalSession();
        }
        if (!mounted) return;
        setState(() {
          _submitting = false;
          _phase = _ResetPhase.success;
        });
      },
    );
  }

  String _messageFor(Failure failure, String? code) {
    if (failure is PasswordResetRateLimitedFailure) {
      return 'password_reset.rate_limited_generic'.tr();
    }
    if (code == 'VALIDATION_ERROR') {
      return 'password_reset.password_length_error'.tr();
    }
    if (failure is NetworkFailure) {
      return 'common.something_wrong'.tr();
    }
    return failure.message;
  }

  @override
  Widget build(BuildContext context) {
    return KZAuthHeroScaffold(
      heroSubtitle: 'password_reset.reset_subtitle'.tr(),
      showBackButton: false,
      child: switch (_phase) {
        _ResetPhase.form => _buildForm(),
        _ResetPhase.invalidLink => _buildInvalidLink(),
        _ResetPhase.success => _buildSuccess(),
      },
    );
  }

  Widget _buildForm() {
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
        Text('password_reset.reset_title'.tr(), style: KZ.sectionTitle),
        const SizedBox(height: KZ.sp20),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KZAuthTextField(
                controller: _passwordCtrl,
                label: 'password_reset.new_password_label'.tr(),
                hint: 'auth.password_hint'.tr(),
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: KZ.onSurfaceVariant,
                    size: KZ.iconControl,
                  ),
                  splashRadius: 20,
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) {
                  final value = v ?? '';
                  if (value.length < 8 || value.length > 72) {
                    return 'password_reset.password_length_error'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: KZ.sp16),
              KZAuthTextField(
                controller: _confirmCtrl,
                label: 'password_reset.confirm_password_label'.tr(),
                hint: 'auth.password_hint'.tr(),
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: KZ.onSurfaceVariant,
                    size: KZ.iconControl,
                  ),
                  splashRadius: 20,
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (v) {
                  if (v != _passwordCtrl.text) {
                    return 'password_reset.password_mismatch'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: KZ.sp24),
              KZButton(
                label: 'password_reset.reset_btn'.tr(),
                fullWidth: true,
                loading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvalidLink() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(KZ.sp16),
          decoration: BoxDecoration(
            color: KZ.errorContainer,
            borderRadius: BorderRadius.circular(KZ.radiusMd),
            border: Border.all(color: KZ.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.link_off_rounded, color: KZ.error, size: 26),
              const SizedBox(width: KZ.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'password_reset.invalid_link_title'.tr(),
                      style: KZ.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: KZ.error,
                      ),
                    ),
                    const SizedBox(height: KZ.sp6),
                    Text(
                      _invalidLinkMessage ??
                          'password_reset.invalid_link_message'.tr(),
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
          label: 'password_reset.request_new_link_btn'.tr(),
          fullWidth: true,
          onPressed: () => context.go('/forgot-password'),
        ),
        const SizedBox(height: KZ.sp16),
        Center(
          child: TextButton(
            onPressed: () => context.go('/login'),
            child: Text('password_reset.back_to_login'.tr()),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
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
                Icons.check_circle_outline_rounded,
                color: KZ.tertiary,
                size: 26,
              ),
              const SizedBox(width: KZ.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'password_reset.success_title'.tr(),
                      style: KZ.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: KZ.sp6),
                    Text(
                      'password_reset.success_message'.tr(),
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
          label: 'password_reset.go_to_login_btn'.tr(),
          fullWidth: true,
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}
