import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import 'package:kebda_zaman/core/widgets/kz_social_auth_buttons.dart';
import 'package:kebda_zaman/core/widgets/kz_auth_layout.dart';
import 'package:kebda_zaman/features/customer/presentation/widgets/biometric_onboarding_dialog.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeTerms = true;

  // Recognizers for the tappable "Terms of Service" / "Privacy Policy"
  // spans inside the agreement RichText below. Created once per widget
  // lifetime (not per build) and explicitly disposed — a TapGestureRecognizer
  // left undisposed leaks, and recreating one on every build would drop
  // in-flight gesture state.
  late final TapGestureRecognizer _termsRecognizer = TapGestureRecognizer()
    ..onTap = () => context.push('/legal/terms');
  late final TapGestureRecognizer _privacyRecognizer = TapGestureRecognizer()
    ..onTap = () => context.push('/legal/privacy');

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${'auth.terms_agree'.tr()}${'auth.terms_service'.tr()}',
          ),
          backgroundColor: KZ.error,
        ),
      );
      return;
    }

    final success = await ref
        .read(authNotifierProvider.notifier)
        .signUp(
          name: _nameCtrl.text,
          email: _emailCtrl.text,
          phone: _phoneCtrl.text,
          password: _passwordCtrl.text,
        );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('auth.signup_success'.tr()),
          backgroundColor: KZ.tertiary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      await maybeShowBiometricOnboardingDialog(context, ref);
      if (!mounted) return;
      context.go('/profile');
    }
  }

  void _handleGoogleSignIn() async {
    final success = await ref
        .read(authNotifierProvider.notifier)
        .googleSignIn();

    // `false` covers both cancellation and failure — the error banner (if
    // any) is already reflected in authState, and either way we must not
    // navigate. The backend may resolve an existing account rather than
    // create one, so this intentionally skips the "signup success" copy
    // and just enters the app like Login's Google button does.
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
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    context.pop();
                  } else {
                    context.go('/login');
                  }
                },
              ),
            ),

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
                        title: 'auth.signup_title'.tr(),
                        subtitle: 'auth.signup_subtitle'.tr(),
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
                              controller: _nameCtrl,
                              label: 'auth.full_name'.tr(),
                              hint: 'auth.full_name_hint'.tr(),
                              prefixIcon: Icons.person_outline_rounded,
                              textCapitalization: TextCapitalization.words,
                              validator: (v) {
                                if (v == null || v.trim().length < 2) {
                                  return 'auth.fill_all_fields'.tr();
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: KZ.sp16),

                            KZAuthTextField(
                              controller: _emailCtrl,
                              label: 'auth.email'.tr(),
                              hint: 'auth.email_hint'.tr(),
                              prefixIcon: Icons.mail_outline_rounded,
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
                              controller: _phoneCtrl,
                              label: 'auth.phone'.tr(),
                              hint: 'auth.phone_hint'.tr(),
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
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
                                if (v == null || v.trim().length < 8) {
                                  return 'auth.password_hint'.tr();
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: KZ.sp16),

                            // Terms checkbox
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: KZ.sp4,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: Checkbox(
                                      value: _agreeTerms,
                                      activeColor: KZ.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      side: const BorderSide(
                                        color: KZ.outline,
                                        width: 1.5,
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _agreeTerms = val ?? true;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: KZ.sp12),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: KZ.bodySmall.copyWith(
                                          height: 1.4,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: 'auth.terms_agree'.tr(),
                                          ),
                                          TextSpan(
                                            text: 'auth.terms_service'.tr(),
                                            style: const TextStyle(
                                              color: KZ.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            recognizer: _termsRecognizer,
                                          ),
                                          TextSpan(text: 'auth.and'.tr()),
                                          TextSpan(
                                            text: 'auth.privacy_policy'.tr(),
                                            style: const TextStyle(
                                              color: KZ.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            recognizer: _privacyRecognizer,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: KZ.sp24),

                            KZButton(
                              label: 'auth.signup_btn'.tr(),
                              fullWidth: true,
                              loading: authState.isLoading,
                              onPressed: _handleSignUp,
                            ),
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
                        prompt: 'auth.already_account'.tr(),
                        actionLabel: 'auth.login_link'.tr(),
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            context.pop();
                          } else {
                            context.push('/login');
                          }
                        },
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
