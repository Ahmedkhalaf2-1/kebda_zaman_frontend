import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/session_bootstrap_notifier.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import 'package:kebda_zaman/core/widgets/kz_social_auth_buttons.dart';
import 'package:kebda_zaman/core/widgets/kz_auth_layout.dart';
import 'package:kebda_zaman/core/services/biometric_service.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/customer/presentation/widgets/biometric_onboarding_dialog.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isAdminLogin = false;
  bool _obscurePassword = true;

  bool _biometricBusy = false;
  bool _biometricAutoPromptDone = false;
  KZBiometricKind _biometricKind = KZBiometricKind.none;

  @override
  void initState() {
    super.initState();
    ref.read(biometricServiceProvider).availableKind().then((kind) {
      if (mounted) setState(() => _biometricKind = kind);
    });
    // Fires at most once per screen visit, and only for the specific
    // bootstrap outcome that requires it — never on a plain rebuild, and
    // never again after the user cancels/fails (no prompt loop).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeAutoPromptBiometric();
    });
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _navigateForUser(User? user, {bool forceAdmin = false}) {
    if (forceAdmin || user?.role == 'ADMIN') {
      context.go('/admin/dashboard');
    } else if (user?.role == 'CASHIER') {
      // Cashiers never see customer navigation — they land directly on
      // Orders Management, the only admin section they're allowed into.
      context.go('/admin/orders');
    } else {
      context.go('/home');
    }
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final identifier = _identifierCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    bool success = false;
    if (_isAdminLogin) {
      success = await ref
          .read(authNotifierProvider.notifier)
          .adminLogin(identifier: identifier, password: password);
    } else {
      success = await ref
          .read(authNotifierProvider.notifier)
          .login(identifier: identifier, password: password);
    }

    if (success && mounted) {
      final user = ref.read(authNotifierProvider).user;
      // "Normal Login" only — the admin-login toggle above is a distinct
      // path for staff, not the customer onboarding this dialog is for.
      if (!_isAdminLogin) {
        await maybeShowBiometricOnboardingDialog(context, ref);
        if (!mounted) return;
      }
      _navigateForUser(user, forceAdmin: _isAdminLogin);
    }
  }

  Future<void> _maybeAutoPromptBiometric() async {
    if (!mounted || _biometricAutoPromptDone) return;
    final status = ref.read(sessionBootstrapProvider).value;
    if (status != SessionBootstrapStatus.biometricRequired) return;
    _biometricAutoPromptDone = true;
    await _unlockWithBiometrics(auto: true);
  }

  Future<void> _unlockWithBiometrics({required bool auto}) async {
    if (_biometricBusy) return;
    setState(() => _biometricBusy = true);

    final result = await ref
        .read(biometricServiceProvider)
        .authenticate(reasonKey: 'biometric.prompt_reason'.tr());

    if (!mounted) return;
    setState(() => _biometricBusy = false);

    switch (result) {
      case BiometricAuthSuccess():
        await ref.read(sessionBootstrapProvider.notifier).confirmAfterBiometric();
        if (!mounted) return;
        final newStatus = ref.read(sessionBootstrapProvider).value;
        if (newStatus == SessionBootstrapStatus.authenticated) {
          _navigateForUser(ref.read(authNotifierProvider).user);
        } else {
          // Backend rejected the refresh token (expired/revoked) — biometric
          // success never overrides that. Local session is already cleared
          // by confirmAfterBiometric's underlying refresh path; fall back to
          // the normal form already on screen.
          _showBiometricMessage('biometric.session_expired'.tr());
        }
      case BiometricAuthCancelled():
        // No message, no retry loop — the normal form is already visible.
        break;
      case BiometricAuthNotEnrolled():
      case BiometricAuthUnavailable():
        if (!auto) _showBiometricMessage('biometric.unavailable'.tr());
      case BiometricAuthLockedOut():
        _showBiometricMessage('biometric.locked_out'.tr());
      case BiometricAuthPermanentlyLockedOut():
        _showBiometricMessage('biometric.locked_out_permanent'.tr());
      case BiometricAuthError():
        if (!auto) _showBiometricMessage('biometric.generic_error'.tr());
    }
  }

  void _showBiometricMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  IconData get _biometricIcon => switch (_biometricKind) {
    KZBiometricKind.face => Icons.face_retouching_natural_rounded,
    KZBiometricKind.fingerprint => Icons.fingerprint_rounded,
    KZBiometricKind.generic => Icons.fingerprint_rounded,
    KZBiometricKind.none => Icons.fingerprint_rounded,
  };

  String get _biometricLabel => switch (_biometricKind) {
    KZBiometricKind.face => 'biometric.unlock_face'.tr(),
    KZBiometricKind.fingerprint => 'biometric.unlock_fingerprint'.tr(),
    _ => 'biometric.unlock_generic'.tr(),
  };

  // Secondary to the main Login CTA (KZButton's own `secondary` variant is
  // an outline, lower visual weight than the filled primary button above
  // it) — this is a fallback/retry action, not an alternative front door.
  Widget _buildBiometricUnlockButton() {
    return KZButton(
      label: _biometricLabel,
      icon: _biometricIcon,
      variant: KZButtonVariant.secondary,
      fullWidth: true,
      loading: _biometricBusy,
      onPressed: () => _unlockWithBiometrics(auto: false),
    );
  }

  void _handleGoogleSignIn() async {
    final success = await ref
        .read(authNotifierProvider.notifier)
        .googleSignIn();

    // A `false` result covers both cancellation and failure — either way
    // the error banner (if any) is already reflected in authState, and we
    // must not navigate. Same role-based routing as email/password login,
    // though Google accounts are always CUSTOMER on the backend today.
    if (success && mounted) {
      final user = ref.read(authNotifierProvider).user;
      if (user?.role == 'ADMIN') {
        context.go('/admin/dashboard');
      } else if (user?.role == 'CASHIER') {
        context.go('/admin/orders');
      } else {
        context.go('/home');
      }
    }
  }

  void _handleAppleSignIn() async {
    final success = await ref.read(authNotifierProvider.notifier).appleSignIn();

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: KZ.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar for back navigation, only when pushed from elsewhere.
            if (Navigator.canPop(context))
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: KZ.sp12,
                  vertical: KZ.sp8,
                ),
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: KZ.primary,
                    size: KZ.iconAction,
                  ),
                  tooltip: 'common.back'.tr(),
                  splashRadius: 22,
                  onPressed: () => context.pop(),
                ),
              )
            else
              const SizedBox(height: KZ.sp16),

            Expanded(
              child: ResponsiveContainer(
                maxWidth: 448,
                // Fixed horizontal padding regardless of breakpoint —
                // ResponsiveContainer's own responsive padding would
                // otherwise stack with this screen's padding, making the
                // form narrower on tablet/desktop than on mobile.
                padding: const EdgeInsets.symmetric(
                  horizontal: KZ.screenPadding,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: KZ.sp8),
                  child: Column(
                    children: [
                      KZAuthHeader(
                        title: 'auth.login_title'.tr(),
                        subtitle: 'auth.login_subtitle'.tr(),
                      ),

                      const SizedBox(height: KZ.sp24),

                      if (authState.errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(KZ.sp14),
                          decoration: BoxDecoration(
                            color: KZ.errorContainer,
                            borderRadius: BorderRadius.circular(KZ.radiusMd),
                            border: Border.all(
                              color: KZ.error.withValues(alpha: 0.3),
                            ),
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
                                  authState.errorMessage!,
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

                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            KZAuthTextField(
                              controller: _identifierCtrl,
                              label: 'auth.email_or_username'.tr(),
                              hint: 'auth.email_or_username_hint'.tr(),
                              prefixIcon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'auth.fill_all_fields'.tr();
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: KZ.sp16),

                            KZAuthTextField(
                              controller: _passwordCtrl,
                              label: 'auth.password'.tr(),
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
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'auth.fill_all_fields'.tr();
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: KZ.sp12),

                            // Admin login toggle — secondary, quieter than
                            // the form fields above. Forgot Password was
                            // removed from here: no real reset-password flow
                            // exists anywhere in the app, so a clickable
                            // no-op wasn't worth keeping.
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isAdminLogin = !_isAdminLogin;
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: KZ.sp4,
                                ),
                                child: Text(
                                  _isAdminLogin
                                      ? 'auth.switch_to_customer_login'.tr()
                                      : 'auth.switch_to_admin_login'.tr(),
                                  style: KZ.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),

                            const SizedBox(height: KZ.sp24),

                            KZButton(
                              label: 'auth.login_btn'.tr(),
                              fullWidth: true,
                              loading: authState.isLoading,
                              onPressed: _handleLogin,
                            ),

                            if (ref.watch(sessionBootstrapProvider).value ==
                                SessionBootstrapStatus
                                    .biometricRequired) ...[
                              const SizedBox(height: KZ.sp12),
                              _buildBiometricUnlockButton(),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: KZ.sp28),

                      KZAuthDivider(label: 'auth.or_continue'.tr()),

                      const SizedBox(height: KZ.sp20),

                      Row(
                        children: [
                          KZGoogleSignInButton(
                            label: 'auth.google'.tr(),
                            isLoading: authState.isLoading,
                            onTap: _handleGoogleSignIn,
                          ),
                          const SizedBox(width: KZ.sp12),
                          KZAppleSignInButton(
                            label: 'auth.apple'.tr(),
                            isLoading: authState.isLoading,
                            onTap: _handleAppleSignIn,
                          ),
                        ],
                      ),

                      const SizedBox(height: KZ.sp32),

                      KZAuthFooterLink(
                        prompt: 'auth.no_account'.tr(),
                        actionLabel: 'auth.signup_link'.tr(),
                        onTap: () => context.push('/signup'),
                      ),

                      const SizedBox(height: KZ.sp20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
