import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
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
                      // Brand Logo Section (w-32 h-32 / 128x128 white box with subtle peach border and shadow)
                      Container(
                        width: 128,
                        height: 128,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFFEF2E0),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: KZ.primary.withValues(alpha: 0.12),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: KZ.primary.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomPaint(
                            size: const Size(64, 64),
                            painter: _KebdaLogoPainter(),
                          ),
                        ),
                      ),

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

/// Renders the exact SVG heritage food / cloche house icon from the HTML design.
class _KebdaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = KZ
          .primary // #8c2b00
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = KZ.primary
      ..style = PaintingStyle.fill;

    // The original SVG viewBox is 0 0 24 24.
    // We scale it to fit the container size (e.g., 64x64).
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final path = Path()
      ..moveTo(17, 2)
      ..lineTo(10, 9)
      ..moveTo(17, 2)
      ..cubicTo(18.6569, 2, 20, 3.34315, 20, 5)
      ..cubicTo(20, 6.65685, 18.6569, 8, 17, 8)
      ..lineTo(10, 9)
      ..moveTo(17, 2)
      ..lineTo(17, 5)
      ..moveTo(10, 9)
      ..lineTo(4, 15)
      ..lineTo(4, 21)
      ..lineTo(7, 21)
      ..lineTo(10, 18)
      ..lineTo(13, 21)
      ..lineTo(16, 21)
      ..lineTo(16, 15)
      ..lineTo(10, 9);

    canvas.drawPath(path, paint);
    canvas.drawCircle(const Offset(7, 11), 2.0, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
