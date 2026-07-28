import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/theme/kz_motion.dart';

/// The one shared surface for every card-like container — product/food
/// cards, order cards, summary/info cards, admin metric cards. Wraps
/// `KZ.cardDecoration()` so radius, border, and shadow can never drift
/// between screens again; screens only ever compose their own content
/// inside it.
///
/// Pass `onTap` to get a correctly-clipped ripple that respects the card's
/// rounded corners — the whole card becomes the tap target, with no extra
/// decoration needed to signal that it's tappable.
class KZCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  const KZCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(KZ.sp16),
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      clipBehavior: onTap != null ? Clip.antiAlias : Clip.none,
      decoration: KZ.cardDecoration(color: color),
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(padding: padding, child: child),
              ),
            ),
    );
    return onTap == null ? card : KZPressableScale(child: card);
  }
}

/// A food/product photo at a fixed, correct aspect ratio inside a card —
/// never stretched, never distorted, always `BoxFit.cover` so the image
/// fills its frame the way a menu photo should. Use this instead of a raw
/// `Image`/`CachedNetworkImage` any time a food photo sits inside a card, so
/// every product image across the app crops consistently.
class KZFoodImage extends StatelessWidget {
  final String imageUrl;
  final double aspectRatio;
  final BorderRadius? borderRadius;

  const KZFoodImage({
    super.key,
    required this.imageUrl,
    this.aspectRatio = 4 / 3,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final image = AspectRatio(
      aspectRatio: aspectRatio,
      child: imageUrl.isEmpty
          ? Container(
              color: KZ.surfaceContainerLow,
              child: const Icon(Icons.restaurant_rounded, color: KZ.outline),
            )
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              // Stable-size placeholder (this `AspectRatio` box) avoids any
              // layout shift while loading; the fade-in itself just makes
              // the swap from placeholder to photo feel intentional rather
              // than a flicker.
              fadeInDuration: KZMotion.standard,
              fadeInCurve: KZMotion.enterExit,
              placeholder: (context, url) =>
                  Container(color: KZ.surfaceContainerLow),
              errorWidget: (context, url, error) => Container(
                color: KZ.surfaceContainerLow,
                child: const Icon(Icons.restaurant_rounded, color: KZ.outline),
              ),
            ),
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
