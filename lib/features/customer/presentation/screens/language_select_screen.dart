import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Header Emblem with Pulse Animation
              const _PulseEmblem(),

              const SizedBox(height: 28),

              Text(
                'onboarding.select_language'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: KZ.onSurface,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'onboarding.select_language_sub'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: KZ.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(height: 36),

              // Arabic Option Card (KSA Flag 🇸🇦)
              _buildLangCard(
                langCode: 'ar',
                flag: '🇸🇦',
                imageUrl: 'https://flagcdn.com/w320/sa.png',
                title: 'العربية',
                subtitle: 'أصيل طعم الشارع المصري',
              ),

              const SizedBox(height: 16),

              // English Option Card (USA Flag 🇺🇸)
              _buildLangCard(
                langCode: 'en',
                flag: '🇺🇸',
                imageUrl: 'https://flagcdn.com/w320/us.png',
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

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangCard({
    required String langCode,
    required String flag,
    required String imageUrl,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? KZ.primaryContainer.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? KZ.primary
                : KZ.outlineVariant.withValues(alpha: 0.35),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? KZ.primary.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Flag Image Box (w-14 h-10 / 56x40)
            Container(
              width: 56,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: KZ.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: Text(flag, style: const TextStyle(fontSize: 24)),
                ),
                errorWidget: (context, url, err) => Center(
                  child: Text(flag, style: const TextStyle(fontSize: 24)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? KZ.primary : KZ.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
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
          width: 116,
          height: 116,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 96 + (16 * _controller.value),
                height: 96 + (16 * _controller.value),
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
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: KZ.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: KZ.primary.withValues(
                        alpha: 0.1 + (0.12 * _controller.value),
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.language_rounded,
                    size: 40,
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
