import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/widgets/kz_brand_logo.dart';

/// The shared Login/Signup header: brand mark + title + subtitle. Kept
/// deliberately compact (64dp mark, tight spacing) so the form — the actual
/// purpose of the screen — starts well within the first viewport on short
/// phones instead of the logo pushing it below the fold.
class KZAuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const KZAuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(KZ.radiusXl),
            border: Border.all(color: KZ.outlineVariant, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(child: KZBrandLogo(width: 40, height: 40)),
        ),
        const SizedBox(height: KZ.sp16),
        Text(title, textAlign: TextAlign.center, style: KZ.pageTitle),
        const SizedBox(height: KZ.sp6),
        Text(subtitle, textAlign: TextAlign.center, style: KZ.bodySmall),
      ],
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

/// A Login/Signup form field, wrapping the shared [KZ.inputDecoration] token
/// so both screens use one input language (height, radius, focus state)
/// instead of each hand-rolling its own decoration.
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
      decoration: KZ.inputDecoration(
        label: label,
        hint: hint,
        prefixIcon: Icon(
          prefixIcon,
          color: KZ.onSurfaceVariant,
          size: KZ.iconControl,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
