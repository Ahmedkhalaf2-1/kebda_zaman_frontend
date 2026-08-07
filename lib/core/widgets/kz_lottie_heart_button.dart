import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// Favorite toggle button, same frosted circular backdrop used across
/// menu/item cards. Resting state is always a plain, crisply-sized heart
/// icon — filled red when [isFavorite], white outline otherwise — exactly
/// like the old Icon-based toggle, so it's never harder to see and always
/// ends up red once marked as a favorite. The Lottie only plays as a bigger
/// burst effect over the top for the brief moment a favorite is *added*;
/// once it finishes it steps aside and the static red icon takes over.
/// Un-favoriting has no animation, same as the old instant toggle.
class KZLottieHeartButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final String semanticsLabel;
  final double size;
  final double iconSize;
  final double shadowOpacity;

  const KZLottieHeartButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    required this.semanticsLabel,
    this.size = 48,
    this.iconSize = 20,
    this.shadowOpacity = 0.1,
  });

  @override
  State<KZLottieHeartButton> createState() => _KZLottieHeartButtonState();
}

class _KZLottieHeartButtonState extends State<KZLottieHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isBursting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void didUpdateWidget(KZLottieHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isFavorite && widget.isFavorite) {
      setState(() => _isBursting = true);
      _controller.forward(from: 0).whenComplete(() {
        if (mounted) setState(() => _isBursting = false);
      });
    } else if (oldWidget.isFavorite && !widget.isFavorite) {
      _controller.value = 0;
      if (_isBursting) setState(() => _isBursting = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final burstSize = widget.iconSize * 2.4;
    return Semantics(
      button: true,
      label: widget.semanticsLabel,
      child: InkWell(
        onTap: widget.onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.92),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: widget.shadowOpacity),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Lottie stays mounted from the first build (just hidden)
                // so its onLoaded fires — and the controller gets its real
                // duration — well before forward() is ever triggered by a
                // tap. Setting the duration mid-flight (i.e. only mounting
                // this while bursting) caused a visible speed jump partway
                // through on whichever instance loaded the asset first.
                Opacity(
                  opacity: _isBursting ? 1 : 0,
                  child: SizedBox(
                    width: burstSize,
                    height: burstSize,
                    child: Lottie.asset(
                      'assets/lottie/heart.json',
                      controller: _controller,
                      onLoaded: (composition) {
                        _controller.duration = composition.duration;
                      },
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Opacity(
                  opacity: _isBursting ? 0 : 1,
                  child: Icon(
                    widget.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: KZ.primary,
                    size: widget.iconSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
