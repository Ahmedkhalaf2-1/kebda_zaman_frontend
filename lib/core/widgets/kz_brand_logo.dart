import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// The one shared Kebda Zaman brand mark (`assets/photos/logo.png`) — every
/// screen that needs the real logo (splash, auth headers, admin shell)
/// renders it through this widget instead of duplicating `Image.asset`
/// calls, so sizing/fit/semantics stay consistent everywhere it appears.
///
/// Always `BoxFit.contain` — the source PNG is never stretched or cropped.
/// The container (background/circular/rounded) is opt-in and only applied
/// when a screen actually needs one; by default this renders just the
/// image, safe to drop into any light or dark surface since the asset's
/// own transparent padding is left untouched rather than edited or cropped.
class KZBrandLogo extends StatelessWidget {
  static const String assetPath = 'assets/photos/logo.png';

  final double? width;
  final double? height;
  final String? semanticLabel;

  /// Optional background behind the logo — only set this when the screen
  /// specifically needs a solid/circular plate under the mark (e.g. to
  /// guarantee contrast on a colored background). Leave `null` to render
  /// just the image.
  final Color? backgroundColor;

  /// Renders the optional background as a circle instead of a rounded
  /// rectangle. Ignored when [backgroundColor] is `null`.
  final bool circular;

  /// Corner radius for the optional background when [circular] is `false`.
  /// Ignored when [backgroundColor] is `null`.
  final BorderRadius? borderRadius;

  /// Padding between the optional background edge and the image.
  final EdgeInsetsGeometry padding;

  /// Optional flat tint for the mark itself (e.g. `Colors.white` on a solid
  /// hero background) — recolors every opaque pixel to this color via
  /// [BlendMode.srcIn], collapsing the source PNG's own colors. Leave
  /// `null` (the default, used everywhere except the auth hero) to render
  /// the logo in its normal full color.
  final Color? color;

  const KZBrandLogo({
    super.key,
    this.width,
    this.height,
    this.semanticLabel,
    this.backgroundColor,
    this.circular = false,
    this.borderRadius,
    this.padding = EdgeInsets.zero,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: color == null ? null : BlendMode.srcIn,
      semanticLabel: semanticLabel ?? 'app_name'.tr(),
    );

    if (backgroundColor == null) return image;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : borderRadius,
      ),
      child: image,
    );
  }
}
