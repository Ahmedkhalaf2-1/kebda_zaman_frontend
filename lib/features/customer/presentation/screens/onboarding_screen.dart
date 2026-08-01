import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';

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
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
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
    final List<Map<String, dynamic>> onboardingData = [
      {
        'title': 'onboarding.page1_title'.tr(),
        'sub': 'onboarding.page1_sub'.tr(),
        'imageUrl':
            'https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80',
        'badge': 'Kebda Zaman',
      },
      {
        'title': 'onboarding.page2_title'.tr(),
        'sub': 'onboarding.page2_sub'.tr(),
        'imageUrl':
            'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=80',
        'badge': 'Easy Ordering',
      },
      {
        'title': 'onboarding.page3_title'.tr(),
        'sub': 'onboarding.page3_sub'.tr(),
        'imageUrl':
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
        'badge': 'Hot & Fresh',
      },
    ];

    return Scaffold(
      backgroundColor: KZ.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Brand Title & Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KZ.screenPadding,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kebda Zaman',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: KZ.primary, // #8c2b00
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: KZ.secondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'onboarding.skip'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  final data = onboardingData[index];
                  return _buildPageSlide(
                    title: data['title'],
                    sub: data['sub'],
                    imageUrl: data['imageUrl'],
                    badge: data['badge'],
                  );
                },
              ),
            ),

            // Bottom Navigation & Indicators Section
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KZ.screenPadding,
                vertical: 20,
              ),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 32 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? KZ.primary
                              : KZ.outlineVariant.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Next / Get Started Button (Pill button with trailing arrow icon)
                  KZButton(
                    label: _currentPage == 2
                        ? 'onboarding.get_started'.tr()
                        : 'onboarding.next'.tr(),
                    icon: _currentPage == 2
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                    trailingIcon: true,
                    onPressed: _nextPage,
                    variant: KZButtonVariant.primary,
                    fullWidth: true,
                    pill: true,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageSlide({
    required String title,
    required String sub,
    required String imageUrl,
    required String badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Hero Section: Circular Photo Frame with Overlapping Badge at Bottom Center
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Circular Photo Frame (~280x280)
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: KZ.primaryFixed, // #ffdbcf (soft peach border)
                    width: 6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: KZ.primary.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: KZ.surfaceContainerLow,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: KZ.primary,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, err) => Container(
                    color: KZ.surfaceContainerLow,
                    child: const Center(
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        size: 64,
                        color: KZ.primary,
                      ),
                    ),
                  ),
                ),
              ),

              // Overlapping Badge at Bottom Center
              Positioned(
                bottom: -16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: KZ.primaryFixed, // #ffdbcf (peach pill background)
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(
                        0xFFFFB59C,
                      ).withValues(alpha: 0.6), // #ffb59c
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: KZ.primary.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: KZ.primary, // #8c2b00
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 44),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: KZ.onSurface,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 14),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              sub,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: KZ.onSurfaceVariant.withValues(alpha: 0.85),
                height: 1.5,
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
