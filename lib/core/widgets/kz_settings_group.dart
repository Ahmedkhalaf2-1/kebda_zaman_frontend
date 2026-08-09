import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// Shared building blocks for a grouped settings list — used by both
/// Profile (its own compact "Account/Settings" entry point) and the real
/// Settings screen, so the two share one visual language for group
/// headers/cards/rows instead of each screen inventing its own.

/// A quiet, compact label above a settings group.
class KZSettingsGroupHeader extends StatelessWidget {
  final String text;
  const KZSettingsGroupHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: KZ.label.copyWith(letterSpacing: 0.6),
      ),
    );
  }
}

/// Card surface for one settings group — same radius/border/shadow
/// language everywhere a group of settings rows appears.
class KZSettingsGroup extends StatelessWidget {
  final List<Widget> rows;
  const KZSettingsGroup({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KZ.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: KZ.primary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }
}

/// Hairline separator between rows inside the same [KZSettingsGroup].
class KZSettingsDivider extends StatelessWidget {
  const KZSettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: KZ.outlineVariant.withValues(alpha: 0.25),
    );
  }
}

/// One navigable/tappable settings row: icon-in-circle, title, chevron.
class KZSettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? iconBackground;
  final Color? titleColor;
  // Terminal actions (logout, delete account) aren't a drill-down to
  // another screen, so they don't get the chevron that implies one.
  final bool showChevron;

  const KZSettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.iconBackground,
    this.titleColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            iconBackground ??
                            KZ.primaryFixed.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: iconColor ?? KZ.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KZ.labelLarge.copyWith(
                          fontSize: 15,
                          color: titleColor ?? KZ.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showChevron) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: KZ.outline.withValues(alpha: 0.7),
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
