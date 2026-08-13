import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/responsive/responsive_container.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_brand_logo.dart';

/// Cuts a shallow upward-bulging arc out of the top edge — the shape used
/// by [KZAuthHeroScaffold]'s white panel so the solid-color hero behind it
/// shows through as a "wave" rather than a straight or simply-rounded
/// edge. A single quadratic Bezier from `(0, waveDepth)` through
/// `(width/2, 0)` to `(width, waveDepth)` is enough for a smooth
/// symmetric hump — no need for a multi-segment path.
class _AuthWaveClipper extends CustomClipper<Path> {
  const _AuthWaveClipper();

  static const double waveDepth = 40;

  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, waveDepth)
      ..quadraticBezierTo(size.width / 2, 0, size.width, waveDepth)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// The Login/Signup page chrome: a solid-[KZ.primary] hero (brand mark +
/// app name + [heroSubtitle]) with a wave-topped white panel laid over its
/// lower portion, holding [child] (the actual form) directly — no card
/// heading, the form fields are the first thing in the panel. Both screens
/// share this exact shell — only their form content and copy differ — so a
/// redesign of the shell only ever needs to happen once.
///
/// The hero's tagline reuses each screen's own `auth.*_subtitle` copy
/// (already translated, screen-specific) rather than inventing a new
/// shared tagline string.
class KZAuthHeroScaffold extends StatelessWidget {
  final String heroSubtitle;
  final Widget child;
  final bool showBackButton;
  final VoidCallback? onBack;

  const KZAuthHeroScaffold({
    super.key,
    required this.heroSubtitle,
    required this.child,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The wave clipper only ever reveals this color behind its cut —
      // matches KZ.primary exactly so there's never a seam.
      backgroundColor: KZ.primary,
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: KZ.primary)),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: showBackButton
                      ? Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            tooltip: 'common.back'.tr(),
                            splashRadius: 22,
                            onPressed: onBack,
                          ),
                        )
                      : null,
                ),
                Padding(
                  // Bottom inset grows the hero itself (pushing the wave —
                  // and everything in the card below it — further down the
                  // screen) rather than adding empty padding inside the
                  // white card, which would just be dead space above the
                  // first field.
                  padding: const EdgeInsets.fromLTRB(
                    KZ.sp24,
                    KZ.sp4,
                    KZ.sp24,
                    KZ.sp48,
                  ),
                  child: Column(
                    children: [
                      // Full-color brand mark, no backing plate — directly
                      // on the solid-primary hero.
                      const KZBrandLogo(width: 96, height: 96),
                      const SizedBox(height: KZ.sp12),
                      Text(
                        'app_name'.tr(),
                        textAlign: TextAlign.center,
                        style: KZ.display.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: KZ.sp6),
                      Text(
                        heroSubtitle,
                        textAlign: TextAlign.center,
                        style: KZ.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ClipPath(
                    clipper: const _AuthWaveClipper(),
                    child: ColoredBox(
                      color: KZ.surface,
                      child: SafeArea(
                        top: false,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ResponsiveContainer(
                            maxWidth: 448,
                            padding: const EdgeInsets.symmetric(
                              horizontal: KZ.screenPadding,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                0,
                                KZ.sp48,
                                0,
                                KZ.sp20,
                              ),
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "or continue with" separator between email/password auth and social
/// auth. Shared so both screens present the same visual break.
class KZAuthDivider extends StatelessWidget {
  final String label;

  const KZAuthDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: KZ.outlineVariant, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KZ.sp16),
          child: Text(label, style: KZ.bodySmall),
        ),
        const Expanded(child: Divider(color: KZ.outlineVariant, thickness: 1)),
      ],
    );
  }
}

/// The bottom "Don't have an account? Sign up" / "Already have an account?
/// Log in" link. `Wrap` (not `Row`) so a longer translated string gracefully
/// wraps to a second line on narrow screens instead of overflowing.
class KZAuthFooterLink extends StatelessWidget {
  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;

  const KZAuthFooterLink({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: KZ.sp6,
      children: [
        Text(prompt, style: KZ.bodySmall),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Text(
            actionLabel,
            style: KZ.labelLarge.copyWith(color: KZ.primary),
          ),
        ),
      ],
    );
  }
}

/// Re-rounds every border state of a [KZ.inputDecoration] to a full pill
/// (matching [KZButton]'s default pill shape), without touching
/// [KZ.inputDecoration] itself — that token is shared by every form field
/// across the whole app, not just auth, so the pill treatment stays scoped
/// to [KZAuthTextField] rather than becoming a global redesign.
InputDecoration _pillBorders(InputDecoration base) {
  OutlineInputBorder pill(OutlineInputBorder b) =>
      b.copyWith(borderRadius: BorderRadius.circular(KZ.radiusFull));
  return base.copyWith(
    border: pill(base.border as OutlineInputBorder),
    enabledBorder: pill(base.enabledBorder as OutlineInputBorder),
    focusedBorder: pill(base.focusedBorder as OutlineInputBorder),
    disabledBorder: pill(base.disabledBorder as OutlineInputBorder),
    errorBorder: pill(base.errorBorder as OutlineInputBorder),
    focusedErrorBorder: pill(base.focusedErrorBorder as OutlineInputBorder),
  );
}

/// A Login/Signup form field, wrapping the shared [KZ.inputDecoration] token
/// (re-rounded to a pill via [_pillBorders], matching the primary button's
/// shape on these two screens) so both screens use one input language
/// (height, radius, focus state) instead of each hand-rolling its own
/// decoration.
class KZAuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  const KZAuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.hint,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: KZ.body.copyWith(fontSize: 15),
      validator: validator,
      decoration: _pillBorders(
        KZ.inputDecoration(
          label: label,
          hint: hint,
          prefixIcon: Icon(
            prefixIcon,
            color: KZ.onSurfaceVariant,
            size: KZ.iconControl,
          ),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
