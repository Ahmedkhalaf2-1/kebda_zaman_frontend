import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/theme/kz_motion.dart';

/// A togglable pill — used for filters, category selection, and any other
/// "pick one/some of these" control. One widget covers all three, since
/// they share the same stable semantic (selectable, pill-shaped, label +
/// optional icon) and only differ in what list of options a screen puts
/// next to each other.
class KZChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  const KZChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : KZ.onSurfaceVariant;
    return KZPressableScale(
      enabled: onTap != null,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(KZ.radiusFull),
        child: InkWell(
          borderRadius: BorderRadius.circular(KZ.radiusFull),
          onTap: onTap,
          child: AnimatedContainer(
            duration: KZMotion.durationFor(context, KZMotion.fast),
            curve: KZMotion.stateChange,
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(
              horizontal: KZ.sp16,
              vertical: KZ.sp8,
            ),
            decoration: BoxDecoration(
              color: selected ? KZ.primary : KZ.surfaceContainerLow,
              borderRadius: BorderRadius.circular(KZ.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: KZ.iconInline, color: foreground),
                  const SizedBox(width: KZ.sp6),
                ],
                Text(
                  label,
                  style: KZ.label.copyWith(color: foreground, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A non-interactive status indicator (order status, availability, ...).
/// The icon is required and always shown alongside color, so status is
/// never communicated by color alone — a colorblind user, or anyone who
/// can't perceive the color difference, still gets the icon + word.
class KZStatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const KZStatusBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KZ.sp10,
        vertical: KZ.sp4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KZ.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: KZ.iconInline, color: color),
          const SizedBox(width: KZ.sp4),
          Text(label, style: KZ.statusLabel.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// A small numeric badge overlaid on an icon (e.g. unread notification
/// count on a bell). Caps the displayed count at 99+ rather than growing
/// unbounded.
class KZNotificationBadge extends StatelessWidget {
  final int count;

  const KZNotificationBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: KZ.error,
        borderRadius: BorderRadius.circular(KZ.radiusFull),
        border: Border.all(color: KZ.surface, width: 1.5),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
