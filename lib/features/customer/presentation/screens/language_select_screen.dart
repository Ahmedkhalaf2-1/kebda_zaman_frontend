import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';

class LanguageSelectScreen extends ConsumerStatefulWidget {
  const LanguageSelectScreen({super.key});

  @override
  ConsumerState<LanguageSelectScreen> createState() =>
      _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends ConsumerState<LanguageSelectScreen> {
  String _selectedLangCode = 'ar';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLangCode = context.locale.languageCode;
  }

  Future<void> _saveAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kz_lang_selected', true);

    if (mounted) {
      await context.setLocale(Locale(_selectedLangCode));
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KZ.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KZ.screenPadding,
            vertical: KZ.pageVerticalPadding,
          ),
          child: Column(
            children: [
              const SizedBox(height: KZ.sectionGap),

              // Header Emblem with Pulse Animation
              const _PulseEmblem(),

              const SizedBox(height: KZ.sectionGap),

              Text(
                'onboarding.select_language'.tr(),
                textAlign: TextAlign.center,
                style: KZ.pageTitle.copyWith(letterSpacing: -0.5),
              ),

              const SizedBox(height: KZ.sp8),

              Text(
                'onboarding.select_language_sub'.tr(),
                textAlign: TextAlign.center,
                style: KZ.bodySmall.copyWith(
                  color: KZ.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: KZ.sectionGap),

              // Arabic Option Card
              _buildLangCard(
                langCode: 'ar',
                title: 'العربية',
                subtitle: 'أصيل طعم الشارع المصري',
              ),

              const SizedBox(height: KZ.sp16),

              // English Option Card
              _buildLangCard(
                langCode: 'en',
                title: 'English',
                subtitle: 'Authentic Egyptian Street Food',
              ),

              const Spacer(),

              // Continue Button
              KZButton(
                label: 'onboarding.continue'.tr(),
                onPressed: _saveAndContinue,
                variant: KZButtonVariant.primary,
                fullWidth: true,
                pill: true,
              ),

              const SizedBox(height: KZ.sp16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangCard({
    required String langCode,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedLangCode == langCode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLangCode = langCode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(KZ.sp16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(KZ.radiusXl),
          border: Border.all(
            color: isSelected
                ? KZ.primary
                : KZ.outlineVariant.withValues(alpha: 0.35),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: KZ.sectionTitle.copyWith(
                      color: isSelected ? KZ.primary : KZ.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: KZ.bodySmall.copyWith(
                      color: KZ.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Custom Radio Circle (w-6 h-6 / 24x24)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? KZ.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? KZ.primary
                      : KZ.outline.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseEmblem extends StatefulWidget {
  const _PulseEmblem();

  @override
  State<_PulseEmblem> createState() => _PulseEmblemState();
}

class _PulseEmblemState extends State<_PulseEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 84 + (14 * _controller.value),
                height: 84 + (14 * _controller.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: KZ.primary.withValues(
                      alpha: 0.2 * (1 - _controller.value),
                    ),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: KZ.primary, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.language_rounded,
                    size: 34,
                    color: KZ.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
