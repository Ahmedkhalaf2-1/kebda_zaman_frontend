import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// A bordered card with a small caption title above its content — the
/// "labeled info block" pattern used repeatedly across non-admin detail
/// screens (driver order details' Customer/Address/Items/Payment blocks).
/// Extracted from what was a private, per-screen `_SectionCard` so every
/// screen using this pattern shares one padding/radius/title-style
/// definition instead of each hand-rolling its own copy.
class KZSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const KZSectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KZ.sp16),
      decoration: BoxDecoration(
        color: KZ.surface,
        borderRadius: BorderRadius.circular(KZ.radiusLg),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: KZ.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: KZ.secondary,
            ),
          ),
          const SizedBox(height: KZ.sp8),
          child,
        ],
      ),
    );
  }
}
