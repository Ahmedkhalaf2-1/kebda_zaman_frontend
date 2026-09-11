import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// Shared amber star accent — kept local to this file since no other KZ
/// component needs a "rating" color yet.
const Color _kStarColor = Color(0xFFF6A609);

/// A 1-5 star selector/display. Read-only when [onChanged] is null (menu
/// item rating display); interactive otherwise (review submission forms).
class KZStarRating extends StatelessWidget {
  final int rating;
  final ValueChanged<int>? onChanged;
  final double size;

  const KZStarRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final interactive = onChanged != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final starValue = i + 1;
        final filled = starValue <= rating;
        final icon = Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: filled ? _kStarColor : KZ.outline,
        );
        if (!interactive) return icon;
        return InkWell(
          customBorder: const CircleBorder(),
          onTap: () => onChanged!(starValue),
          child: Padding(padding: const EdgeInsets.all(2), child: icon),
        );
      }),
    );
  }
}

/// Compact read-only "★ 4.8 (327)" display for menu items. Renders a
/// neutral "no ratings yet" label instead of a fake/zero star row when
/// [reviewCount] is 0 — never displays a rating nobody has actually given.
class KZMenuItemRatingBadge extends StatelessWidget {
  final double averageRating;
  final int reviewCount;
  final String noRatingsLabel;
  final String Function(double rating, int count) ratedLabelBuilder;

  const KZMenuItemRatingBadge({
    super.key,
    required this.averageRating,
    required this.reviewCount,
    required this.noRatingsLabel,
    required this.ratedLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (reviewCount <= 0) {
      return Text(
        noRatingsLabel,
        style: KZ.caption.copyWith(color: KZ.onSurfaceVariant),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: _kStarColor),
        const SizedBox(width: 2),
        Text(
          ratedLabelBuilder(averageRating, reviewCount),
          style: KZ.caption.copyWith(
            color: KZ.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
