import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// Which semantic role a [KZButton] plays. Pick by meaning, not by how you
/// want it to look — the variant already encodes the correct visual
/// treatment (fill, outline, or text-only) for that meaning.
enum KZButtonVariant {
  /// The one primary action on a screen/section (e.g. "Add to cart",
  /// "Place order"). Filled, highest visual weight. Avoid more than one
  /// primary button visible at a time.
  primary,

  /// A supporting action alongside a primary one (e.g. "Edit" next to
  /// "Save"). Outlined, medium visual weight.
  secondary,

  /// A low-emphasis action (e.g. "Skip", "View all"). Text-only, no fill
  /// or border.
  tertiary,

  /// An irreversible or destructive action (e.g. "Remove item", "Delete
  /// account"). Filled in the error color — never use for merely negative
  /// but non-destructive actions like "Cancel".
  destructive,
}

/// The single shared button used across newly-adopted screens.
///
/// - Minimum 48dp height (`KZ.iconTapTargetMin`) for every variant, matching
///   the minimum mobile touch-target guideline.
/// - `loading: true` swaps the label for a fixed-size spinner without
///   changing the button's footprint (no layout shift).
/// - Disabled state is `onPressed == null` (standard Flutter convention) —
///   there is no separate `enabled` flag to keep out of sync.
/// - Defaults to a rounded-rectangle shape (`KZ.radiusMd`); set `pill: true`
///   only for the specific "primary fixed bottom bar" CTA treatment — pills
///   are a deliberate accent, not the default for every button.
class KZButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final KZButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final bool pill;
  final bool trailingIcon;

  const KZButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = KZButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.pill = true,
    this.trailingIcon = false,
  });

  bool get _disabled => onPressed == null || loading;

  ({Color background, Color foreground, Color? border}) get _palette {
    switch (variant) {
      case KZButtonVariant.primary:
        return (
          background: KZ.primary, // #8c2b00 (our signature rich terracotta!)
          foreground: Colors.white,
          border: null,
        );
      case KZButtonVariant.secondary:
        return (
          background: Colors.transparent,
          foreground: KZ.onSurface,
          border: KZ.outline,
        );
      case KZButtonVariant.tertiary:
        return (
          background: Colors.transparent,
          foreground: KZ.primary,
          border: null,
        );
      case KZButtonVariant.destructive:
        return (background: KZ.error, foreground: Colors.white, border: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(KZ.radiusFull), // 999px pill unified everywhere
      side: palette.border != null
          ? BorderSide(
              color: _disabled
                  ? palette.border!.withValues(alpha: 0.4)
                  : palette.border!,
              width: 1.5,
            )
          : BorderSide.none,
    );

    final Widget content = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: palette.foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null && !trailingIcon) ...[
                Icon(icon, size: KZ.iconControl, color: palette.foreground),
                const SizedBox(width: KZ.sp8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: KZ.buttonLabel.copyWith(color: palette.foreground),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null && trailingIcon) ...[
                const SizedBox(width: KZ.sp8),
                Icon(icon, size: KZ.iconControl, color: palette.foreground),
              ],
            ],
          );

    final button = ElevatedButton(
      onPressed: _disabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.background,
        disabledBackgroundColor:
            variant == KZButtonVariant.secondary ||
                variant == KZButtonVariant.tertiary
            ? Colors.transparent
            : palette.background.withValues(alpha: 0.4),
        foregroundColor: palette.foreground,
        disabledForegroundColor: palette.foreground.withValues(alpha: 0.4),
        elevation:
            variant == KZButtonVariant.primary ||
                variant == KZButtonVariant.destructive
            ? 2
            : 0,
        shadowColor: KZ.primary.withValues(alpha: 0.25),
        minimumSize: Size(fullWidth ? double.infinity : 0, KZ.iconTapTargetMin),
        padding: const EdgeInsets.symmetric(horizontal: KZ.sp20),
        shape: shape,
      ),
      child: content,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// A standalone icon-only action button. The glyph itself may be as small
/// as [KZ.iconControl], but the tappable container is always at least
/// [KZ.iconTapTargetMin] — never shrink the tap target to match the glyph.
class KZIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? background;
  final Color? foreground;
  final double size;

  const KZIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.background,
    this.foreground,
    this.size = KZ.iconTapTargetMin,
  });

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon, size: KZ.iconControl),
        style: IconButton.styleFrom(
          backgroundColor: background ?? KZ.surfaceContainerLow,
          foregroundColor: foreground ?? KZ.onSurface,
          shape: const CircleBorder(),
        ),
      ),
    );
    return tooltip == null ? button : Semantics(label: tooltip, child: button);
  }
}
