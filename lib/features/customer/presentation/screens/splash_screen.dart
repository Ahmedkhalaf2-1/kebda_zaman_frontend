import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_brand_logo.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/session_bootstrap_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _textSlideAnim;

  bool _minDurationElapsed = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _logoScaleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    );
    _textSlideAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _waitMinDuration();
  }

  Future<void> _waitMinDuration() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    _minDurationElapsed = true;
    _maybeNavigate();
  }

  /// Navigates only once both the minimum visual splash duration has
  /// elapsed AND session bootstrap has resolved to a concrete status — never
  /// while bootstrap is still loading, and never twice.
  void _maybeNavigate() {
    if (_hasNavigated || !_minDurationElapsed) return;

    final bootstrapAsync = ref.read(sessionBootstrapProvider);
    if (!bootstrapAsync.hasValue) return; // still loading

    final status = bootstrapAsync.value!;
    if (status == SessionBootstrapStatus.recoverableError) {
      // Stay on splash and let the retry affordance in build() handle it —
      // do not navigate, do not treat this as a permanent logout.
      return;
    }

    _hasNavigated = true;
    _navigateNext(status);
  }

  Future<void> _navigateNext(SessionBootstrapStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final hasSelectedLang = prefs.getBool('kz_lang_selected') ?? false;
    final hasCompletedOnboarding =
        prefs.getBool('kz_onboarding_completed') ?? false;

    if (!hasSelectedLang) {
      context.go('/language-select');
    } else if (!hasCompletedOnboarding) {
      context.go('/onboarding');
    } else if (status == SessionBootstrapStatus.biometricRequired) {
      // A restored session exists but is gated behind biometric login for
      // the cached user — the refresh token has NOT been used yet. Route to
      // Login, which auto-prompts biometrics once and falls back to the
      // normal form on cancel/failure.
      context.go('/login');
    } else {
      // Both authenticated and unauthenticated sessions land on the same
      // destination today — /home already supports guest browsing; this
      // matches the app's existing behavior, unchanged by this fix.
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fires _maybeNavigate() the moment bootstrap settles (success or
    // failure) rather than only when the min-duration timer fires — whichever
    // of the two finishes last is what actually triggers navigation.
    ref.listen<AsyncValue<SessionBootstrapStatus>>(sessionBootstrapProvider, (
      previous,
      next,
    ) {
      if (next.hasValue) _maybeNavigate();
    });

    final bootstrapAsync = ref.watch(sessionBootstrapProvider);
    final showRetry =
        bootstrapAsync.hasValue &&
        bootstrapAsync.value == SessionBootstrapStatus.recoverableError;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Colors.white)),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PulsingRingLogo(scaleAnim: _logoScaleAnim),
                    const SizedBox(height: KZ.sp24),
                    FadeTransition(
                      opacity: _textSlideAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.25),
                          end: Offset.zero,
                        ).animate(_textSlideAnim),
                        child: Text(
                          'home.tagline'.tr(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: KZ.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: KZ.sp32),
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: showRetry
                          ? Column(
                              children: [
                                const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 24,
                                  color: KZ.onSurfaceVariant,
                                ),
                                const SizedBox(height: KZ.sp12),
                                const Text(
                                  'Could not reach the server',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: KZ.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: KZ.sp12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: KZ.primary,
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                  ),
                                  onPressed: () => ref
                                      .read(sessionBootstrapProvider.notifier)
                                      .retry(),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                              ],
                            )
                          : const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: KZ.primary,
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The brand mark, plain — no ring, no backing plate, just a scale-in
/// entrance directly on the white splash background.
class _PulsingRingLogo extends StatelessWidget {
  final Animation<double> scaleAnim;

  const _PulsingRingLogo({required this.scaleAnim});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnim,
      child: const KZBrandLogo(width: 148, height: 148),
    );
  }
}
