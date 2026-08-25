import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_brand_logo.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';

class AuthChoiceScreen extends ConsumerWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: KZ.surface, // #fcf9f5 (heritage cream)
      body: Stack(
        children: [
          // Decorative top accent strip (from HTML: bg-heritage-terracotta opacity-20)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              color: KZ.primary.withValues(alpha: 0.22),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Brand Logo Section — the shared full-color mark, no plate/shadow behind it.
                      const KZBrandLogo(width: 128, height: 128),

                      const SizedBox(height: 56),

                      // Title
                      Text(
                        'onboarding.welcome_title'.tr(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'onboarding.welcome_sub'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: KZ.secondary.withValues(alpha: 0.9),
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Primary CTA: Log In Button
                      KZButton(
                        label: 'auth.login_btn'.tr(),
                        onPressed: () => context.push('/login'),
                        variant: KZButtonVariant.primary,
                        fullWidth: true,
                        pill: true,
                      ),

                      const SizedBox(height: 16),

                      // Secondary CTA: Create My Account Button
                      KZButton(
                        label: 'auth.signup_btn'.tr(),
                        onPressed: () => context.push('/signup'),
                        variant: KZButtonVariant.secondary,
                        fullWidth: true,
                        pill: true,
                      ),

                      const SizedBox(height: 16),

                      // Text Link: Continue as Guest (with arrow after text)
                      Consumer(
                        builder: (context, ref, child) {
                          final isLoading = ref
                              .watch(authNotifierProvider)
                              .isLoading;
                          return KZButton(
                            label: 'onboarding.continue_guest'.tr(),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final success = await ref
                                        .read(authNotifierProvider.notifier)
                                        .continueAsGuest();
                                    if (success && context.mounted) {
                                      context.go('/home');
                                    }
                                  },
                            variant: KZButtonVariant.tertiary,
                            icon: Icons.arrow_forward_rounded,
                            trailingIcon: true,
                            loading: isLoading,
                            pill: true,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
