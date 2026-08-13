import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:lottie/lottie.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/theme/kz_motion.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_brand_logo.dart';
import 'package:kebda_zaman/core/widgets/kz_chip.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';

/// A single onboarding page's content. [chips] are small, non-interactive
/// decorative labels (never fake controls) — empty for the brand/identity
/// page, which stays deliberately minimal.
class _OnboardingPageData {
  final String titleKey;
  final String subKey;
  final String? imageAsset;
  final String? lottieAsset;
  final List<({IconData? icon, String labelKey})> chips;

  const _OnboardingPageData({
    required this.titleKey,
    required this.subKey,
    this.imageAsset,
    this.lottieAsset,
    this.chips = const [],
  });
}

const List<_OnboardingPageData> _kOnboardingPages = [
  _OnboardingPageData(
    titleKey: 'onboarding.page1_title',
    subKey: 'onboarding.page1_sub',
    imageAsset: 'assets/images/onboarding_page1.jpg',
  ),
  _OnboardingPageData(
    titleKey: 'onboarding.page2_title',
    subKey: 'onboarding.page2_sub',
    imageAsset: 'assets/images/onboarding_page2.jpg',
    chips: [
      (
        icon: Icons.local_fire_department_rounded,
        labelKey: 'onboarding.page2_chip_spicy',
      ),
      (
        icon: Icons.add_circle_outline_rounded,
        labelKey: 'onboarding.page2_chip_extras',
      ),
      (icon: Icons.block_rounded, labelKey: 'onboarding.page2_chip_no_onion'),
    ],
  ),
  _OnboardingPageData(
    titleKey: 'onboarding.page3_title',
    subKey: 'onboarding.page3_sub',
    lottieAsset: 'assets/lottie/delivery_guy.json',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kz_onboarding_completed', true);

    if (mounted) {
      context.go('/auth-choice');
    }
  }

  void _nextPage() {
    if (_currentPage < _kOnboardingPages.length - 1) {
      _pageController.nextPage(
        duration: KZMotion.emphasized,
        curve: KZMotion.enterExit,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _kOnboardingPages.length - 1;

    return Scaffold(
      backgroundColor: KZ.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: compact brand mark + Skip action.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KZ.screenPadding,
                vertical: KZ.sp12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const KZBrandLogo(height: 26),
                  TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: KZ.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: KZ.sp12,
                        vertical: KZ.sp8,
                      ),
                    ),
                    child: Text(
                      'onboarding.skip'.tr(),
                      style: KZ.labelLarge.copyWith(color: KZ.secondary),
                    ),
                  ),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _kOnboardingPages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPageView(
                    key: ValueKey('onboarding_page_$index'),
                    pageIndex: index,
                    data: _kOnboardingPages[index],
                  );
                },
              ),
            ),

            // Bottom Navigation & Indicators Section
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KZ.screenPadding,
                KZ.sp8,
                KZ.screenPadding,
                KZ.sp20,
              ),
              child: ResponsiveContainer(
                maxWidth: 480,
                child: Column(
                  children: [
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _kOnboardingPages.length,
                        (index) => AnimatedContainer(
                          key: ValueKey('onboarding_indicator_$index'),
                          duration: KZMotion.durationFor(
                            context,
                            KZMotion.standard,
                          ),
                          curve: KZMotion.stateChange,
                          margin: const EdgeInsets.symmetric(
                            horizontal: KZ.sp4,
                          ),
                          height: 8,
                          width: _currentPage == index ? 32 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? KZ.primary
                                : KZ.outlineVariant.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(KZ.radiusFull),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: KZ.sp24),

                    // Next / Start Ordering (pill button, directional icon).
                    KZButton(
                      label: isLastPage
                          ? 'onboarding.start_ordering'.tr()
                          : 'onboarding.next'.tr(),
                      icon: isLastPage
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      trailingIcon: true,
                      onPressed: _nextPage,
                      variant: KZButtonVariant.primary,
                      fullWidth: true,
                      pill: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single onboarding slide: hero image card + optional decorative chips +
/// title/subtitle. Wrapped in a scroll view constrained to the viewport
/// height so short content stays vertically centered while tall content
/// (large text scale, small phones) scrolls instead of overflowing.
class _OnboardingPageView extends StatefulWidget {
  final int pageIndex;
  final _OnboardingPageData data;

  const _OnboardingPageView({
    super.key,
    required this.pageIndex,
    required this.data,
  });

  @override
  State<_OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<_OnboardingPageView> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    // Self-driving entrance fade/slide — animates from 0 to 1 the moment
    // this widget is first built, with no manual setState/frame-callback
    // scheduling involved (TweenAnimationBuilder owns its own
    // AnimationController internally and disposes it automatically with
    // the widget). Reduced-motion still gets a real (zero-duration) tween,
    // so it settles at the end value immediately rather than skipping the
    // builder.
    final duration = KZMotion.durationFor(context, KZMotion.emphasized);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: KZ.screenPadding,
            vertical: KZ.sp16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - KZ.sp16 * 2, // matches padding
            ),
            child: Center(
              child: ResponsiveContainer(
                maxWidth: 480,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: duration,
                  curve: KZMotion.enterExit,
                  builder: (context, t, child) {
                    return Opacity(
                      opacity: t,
                      child: Transform.translate(
                        offset: Offset(0, (1 - t) * 12),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _HeroImageCard(
                        pageIndex: widget.pageIndex,
                        imageAsset: data.imageAsset,
                        lottieAsset: data.lottieAsset,
                      ),
                      if (data.chips.isNotEmpty) ...[
                        const SizedBox(height: KZ.sp20),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: KZ.sp8,
                          runSpacing: KZ.sp8,
                          children: [
                            for (final chip in data.chips)
                              KZChip(
                                label: chip.labelKey.tr(),
                                icon: chip.icon,
                                selected: false,
                                onTap: null,
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: KZ.sp32),
                      Text(
                        data.titleKey.tr(),
                        textAlign: TextAlign.center,
                        style: KZ.display.copyWith(fontSize: 27),
                      ),
                      const SizedBox(height: KZ.sp12),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KZ.sp12,
                        ),
                        child: Text(
                          data.subKey.tr(),
                          textAlign: TextAlign.center,
                          style: KZ.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Layered hero visual: a rotated accent shape behind a rounded image card.
/// Replaces the old fixed 280x280 circular frame — sizes itself to the
/// available width (capped) and keeps a fixed aspect ratio so it never
/// stretches or crops awkwardly. Purely decorative — excluded from the
/// semantics tree; the page's title/subtitle already carry the meaning.
class _HeroImageCard extends StatelessWidget {
  final int pageIndex;
  final String? imageAsset;
  final String? lottieAsset;

  const _HeroImageCard({
    required this.pageIndex,
    this.imageAsset,
    this.lottieAsset,
  });

  // Page-to-page variation so the three pages feel connected but not
  // visually identical, using only existing KZ palette colors.
  Color get _accentColor =>
      pageIndex == 1 ? KZ.surfaceContainerHigh : KZ.primaryFixed;
  double get _accentRotation => switch (pageIndex) {
    0 => -0.05,
    1 => 0.045,
    _ => -0.035,
  };
  AlignmentDirectional get _accentAlignment => switch (pageIndex) {
    0 => AlignmentDirectional.topStart,
    1 => AlignmentDirectional.bottomEnd,
    _ => AlignmentDirectional.bottomStart,
  };

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth.clamp(200.0, 320.0);
          if (lottieAsset != null) {
            // No card, shadow, or accent shape — just the animation on the
            // plain page background.
            return SizedBox(
              width: cardWidth,
              child: AspectRatio(
                aspectRatio: 1,
                child: Lottie.asset(lottieAsset!, fit: BoxFit.contain),
              ),
            );
          }
          return SizedBox(
            width: cardWidth,
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Rotated accent shape behind the card — subtle depth,
                  // no gradients, KZ palette only.
                  Align(
                    alignment: _accentAlignment,
                    child: Transform.rotate(
                      angle: _accentRotation,
                      child: Container(
                        width: cardWidth * 0.72,
                        height: cardWidth * 0.72,
                        decoration: BoxDecoration(
                          color: _accentColor,
                          borderRadius: BorderRadius.circular(KZ.radiusXl),
                        ),
                      ),
                    ),
                  ),

                  // Small solid accent dot — red/black, brand-page only.
                  if (pageIndex == 0)
                    PositionedDirectional(
                      top: -10,
                      end: 6,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: KZ.onSurface,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                  // Main image card.
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(KZ.radiusXl),
                      boxShadow: [
                        BoxShadow(
                          color: KZ.primary.withValues(alpha: 0.16),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(KZ.radiusXl),
                      child: Image.asset(
                        imageAsset!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: KZ.surfaceContainerLow,
                          child: const Center(
                            child: Icon(
                              Icons.restaurant_menu_rounded,
                              size: 56,
                              color: KZ.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
