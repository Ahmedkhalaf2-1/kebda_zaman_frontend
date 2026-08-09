import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// Shared row skeleton for the People-management screens (Customers,
/// Staff/Cashiers) — both previously hand-rolled a near-identical card
/// (white surface, thin border, name + status badges row, muted subtitle,
/// trailing content). Extracted here once both diverged only in what
/// subtitle/trailing/badge content they supplied, not in the skeleton
/// itself — genuine shared structure, not abstraction for its own sake.
class AdminPersonCard extends StatelessWidget {
  final String name;
  final List<Widget> badges;
  final String? subtitle;
  final Widget? metaLine;
  final Widget trailing;
  final VoidCallback? onTap;

  const AdminPersonCard({
    super.key,
    required this.name,
    this.badges = const [],
    this.subtitle,
    this.metaLine,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: KZ.sp10),
      decoration: BoxDecoration(
        color: KZ.surface,
        borderRadius: BorderRadius.circular(KZ.radiusMd),
        border: Border.all(color: KZ.outlineVariant.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KZ.sp14,
            vertical: KZ.sp12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: KZ.itemTitle,
                          ),
                        ),
                        if (badges.isNotEmpty) ...[
                          const SizedBox(width: KZ.sp6),
                          Wrap(spacing: KZ.sp6, children: badges),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KZ.bodySmall,
                      ),
                    ],
                    if (metaLine != null) ...[
                      const SizedBox(height: KZ.sp4),
                      metaLine!,
                    ],
                  ],
                ),
              ),
              const SizedBox(width: KZ.sp8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// Small, low-fill status pill — icon + label at 12% background alpha, never
/// a large solid fill, so status stays legible without dominating the row.
class AdminStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const AdminStatusPill({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: KZ.sp8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KZ.radiusSm),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: KZ.statusLabel.copyWith(color: color),
      ),
    );
  }
}
