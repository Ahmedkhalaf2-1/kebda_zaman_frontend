import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/session_bootstrap_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  bool _minDurationElapsed = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
    _waitMinDuration();
  }

  Future<void> _waitMinDuration() async {
    await Future.delayed(const Duration(milliseconds: 2400));
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
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final hasSelectedLang = prefs.getBool('kz_lang_selected') ?? false;
    final hasCompletedOnboarding =
        prefs.getBool('kz_onboarding_completed') ?? false;

    if (!hasSelectedLang) {
      context.go('/language-select');
    } else if (!hasCompletedOnboarding) {
      context.go('/onboarding');
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
      backgroundColor: KZ.surface,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [KZ.surface, KZ.primaryFixed],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Restaurant Emblem
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: KZ.primaryContainer,
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: KZ.primary.withOpacity(0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant_rounded,
                            size: 58,
                            color: KZ.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: KZ.sp24),

                      const Text(
                        'كبدة زمان',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: KZ.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: KZ.sp6),

                      Text(
                        'home.tagline'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: KZ.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: KZ.sp32),

                      if (showRetry) ...[
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
                      ] else
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: KZ.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
