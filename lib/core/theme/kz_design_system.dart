import 'package:flutter/material.dart';

/// Unified design system for Kebda Zaman Admin & Customer UI.
/// All screens must use these tokens for consistent spacing, colors, and styles.
class KZ {
  KZ._();

  // ─── Colors ───────────────────────────────────────────
  static const Color primary = Color(0xFFAB3500);
  static const Color primaryContainer = Color(0xFFFF6B35);
  static const Color primaryFixed = Color(0xFFFFDBD0);
  static const Color onPrimary = Colors.white;

  static const Color surface = Color(0xFFFCF9F5);
  static const Color surfaceContainer = Color(0xFFEFEEEA);
  static const Color surfaceContainerLow = Color(0xFFF4F4F0);
  static const Color surfaceContainerHigh = Color(0xFFE9E8E4);
  static const Color onSurface = Color(0xFF1B1C1A);
  static const Color onSurfaceVariant = Color(0xFF594139);

  static const Color secondary = Color(0xFF5F5E5F);
  static const Color outlineVariant = Color(0xFFE1BFB5);
  static const Color outline = Color(0xFF8D7168);

  static const Color tertiary = Color(0xFF006E1C);
  static const Color tertiaryContainer = Color(0xFF4AAD4E);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static const Color success = Color(0xFF006E1C);
  static const Color successContainer = Color(0xFFB3F0B2);

  // ─── Spacing ──────────────────────────────────────────
  static const double sp4 = 4;
  static const double sp6 = 6;
  static const double sp8 = 8;
  static const double sp10 = 10;
  static const double sp12 = 12;
  static const double sp14 = 14;
  static const double sp16 = 16;
  static const double sp20 = 20;
  static const double sp24 = 24;
  static const double sp28 = 28;
  static const double sp32 = 32;
  static const double sp48 = 48;

  /// Horizontal padding for all screens
  static const double screenPadding = 20;

  // ─── Border Radius ─────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // ─── Icon Sizes ─────────────────────────────────────────
  // Icon language: Material Symbols "Rounded" variants exclusively (e.g.
  // Icons.favorite_rounded, not Icons.favorite or Icons.favorite_outlined) —
  // never mix filled/outlined/rounded for the same concept. Cupertino icons
  // only where a specific platform convention genuinely requires them.
  //
  // The glyph size below is what's *visible*; the tappable container around
  // an icon-only control must still be >= iconTapTargetMin regardless of
  // how small the glyph inside it is.
  static const double iconInline = 16; // inline within text/labels
  static const double iconControl =
      20; // default control icon (buttons, list rows)
  static const double iconAction = 24; // prominent standalone action icon
  static const double iconNavigation = 24; // bottom nav / tab bar icons
  static const double iconTapTargetMin =
      48; // minimum interactive container size

  // ─── Elevation Shadows ─────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primary.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get bottomBarShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.07),
      blurRadius: 16,
      offset: const Offset(0, -4),
    ),
  ];

  // ─── Input Decoration ─────────────────────────────────
  /// Covers the default / focused / error / disabled / read-only / password
  /// text-field states — Flutter's `TextField` already drives which border
  /// shows based on its own `enabled`/focus/validation state, so a single
  /// decoration definition here is enough for all of them. `readOnly`
  /// fields should still pass `enabled: false` visually if they should read
  /// as non-interactive (Flutter's `readOnly` alone keeps the enabled look).
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    String? errorText,
    bool enabled = true,
    Widget? suffix,
    Widget? prefix,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      enabled: enabled,
      suffix: suffix,
      prefix: prefix,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      suffixText: suffixText,
      filled: true,
      fillColor: enabled ? surface : surfaceContainerLow,
      labelStyle: const TextStyle(fontSize: 13, color: onSurfaceVariant),
      errorStyle: const TextStyle(fontSize: 12, color: error),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primaryContainer, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: outlineVariant.withOpacity(0.5)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: sp16,
        vertical: sp14,
      ),
    );
  }

  /// A search field's decoration: pill-shaped, filled, leading search icon,
  /// no floating label (search fields are identified by placement/icon, not
  /// a label) — visually distinct from a form field by design, not an
  /// oversight.
  static InputDecoration searchInputDecoration({
    required String hint,
    Widget? trailing,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: secondary),
      prefixIcon: const Icon(
        Icons.search_rounded,
        color: secondary,
        size: iconControl,
      ),
      suffixIcon: trailing,
      filled: true,
      fillColor: surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusFull),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusFull),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusFull),
        borderSide: const BorderSide(color: primaryContainer, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: sp16,
        vertical: sp12,
      ),
    );
  }

  // ─── Card Decoration ──────────────────────────────────
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
    color: color ?? Colors.white,
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: outlineVariant.withOpacity(0.35)),
    boxShadow: cardShadow,
  );

  static BoxDecoration sectionDecoration({Color? color}) => BoxDecoration(
    color: color ?? surfaceContainer,
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: outlineVariant.withOpacity(0.25)),
  );

  // ─── Text Styles (legacy — still used by screens outside the Sprint 2
  // first-batch migration; kept unchanged for those call sites) ──────────
  static const TextStyle headingStyle = TextStyle(
    // Was 'Montserrat', which was never bundled as an asset and silently
    // fell back to each platform's system font — fixed to the app's real
    // typeface. Size/weight/color intentionally left untouched.
    fontFamily: 'Readex Pro',
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: primary,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: onSurface,
  );

  // ─── Semantic Type Scale (Sprint 2) ────────────────────────────────────
  // The one-and-only type scale for newly-adopted screens/components. Every
  // role is named for what it *means*, never for its numeric size, so a
  // future scale adjustment never requires renaming call sites. All roles
  // use the Readex Pro family (the app's single bilingual Arabic/Latin
  // typeface — see Sprint 2 report) at weight >= 400: never light/thin.
  //
  // "Max usage" below is a guideline for reviewers, not an enforced limit.

  /// Hero-scale emphasis. Max usage: at most one per screen — a single
  /// standout number or headline (e.g. a splash/onboarding statement).
  /// Never for ordinary page titles.
  static const TextStyle display = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: onSurface,
  );

  /// The screen's own title (AppBar title / top-of-screen heading). Max
  /// usage: exactly one per screen.
  static const TextStyle pageTitle = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 22,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: onSurface,
  );

  /// Header introducing a group of content within a screen (e.g. "Popular
  /// Now", "Your Cart"). Max usage: once per section.
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: onSurface,
  );

  /// A menu item / product name in a list, grid, or card. Intended for 1-2
  /// lines; truncate beyond that rather than growing the row.
  static const TextStyle itemTitle = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 15,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );

  /// Title inside a compact card surface (order card header, address card
  /// name). Slightly smaller/quieter than [itemTitle] since it usually sits
  /// alongside metadata (status, date) rather than a hero food image.
  static const TextStyle cardTitle = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: onSurface,
  );

  /// Prominent supporting paragraph — item descriptions, promo detail text.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w500,
    color: onSurfaceVariant,
  );

  /// Default paragraph/body text for ordinary UI copy.
  static const TextStyle body = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: onSurface,
  );

  /// Secondary/supporting inline text — quieter than [body], still legible
  /// at normal reading distance. Not for anything load-bearing.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: onSurfaceVariant,
  );

  /// Prominent field/form label or a selected tab label.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: onSurface,
  );

  /// Standard label — chip text, filter text, compact control labels.
  static const TextStyle label = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: onSurfaceVariant,
  );

  /// Least prominent helper/meta text — timestamps, fine print, disclaimers.
  static const TextStyle caption = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: secondary,
  );

  /// A prominent, standalone price — item details price, cart grand total.
  /// Max usage: one per screen/card; use [price] for anything else.
  static const TextStyle priceLarge = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: primary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// A standard, inline price — menu list price, order line price.
  static const TextStyle price = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: onSurface,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Button label text. Color intentionally omitted — each button variant
  /// supplies its own foreground color.
  static const TextStyle buttonLabel = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  /// Bottom navigation / tab bar item label.
  static const TextStyle navigationLabel = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: onSurfaceVariant,
  );

  /// Status badge/chip text (order status, availability). Always pair with
  /// a non-color signal (icon or explicit word) — never rely on color alone
  /// to communicate status.
  static const TextStyle statusLabel = TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
  );

  // ─── Common Widgets ───────────────────────────────────

  /// Divider used between list items
  static Widget get divider => const Divider(height: 1, color: outlineVariant);

  /// Toggle row (label + Switch) — used in forms
  static Widget toggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: sp16),
      decoration: BoxDecoration(
        color: surfaceContainer,
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bodyStyle),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              activeColor: primaryContainer,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  /// Standard AppBar for sub-pages (form screens)
  static AppBar formAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
  }) {
    return AppBar(
      backgroundColor: surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded, color: primary, size: 26),
      ),
      title: Text(title, style: headingStyle),
      actions: actions,
    );
  }
}
