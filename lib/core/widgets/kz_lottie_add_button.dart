import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// "Add to cart" circular button. Resting state is a plain "+" icon on the
/// given [backgroundColor] — no shadow. On tap, fires [onTap] immediately
/// and briefly plays the "added" Lottie burst over the icon, then reverts
/// back to the plain "+" so the button stays repeatable for further adds.
class KZLottieAddButton extends StatefulWidget {
  final VoidCallback onTap;
  final String semanticsLabel;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final double iconSize;

  const KZLottieAddButton({
    super.key,
    required this.onTap,
    required this.semanticsLabel,
    required this.backgroundColor,
    required this.iconColor,
    this.size = 48,
    this.iconSize = 24,
  });

  @override
  State<KZLottieAddButton> createState() => _KZLottieAddButtonState();
}

class _KZLottieAddButtonState extends State<KZLottieAddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    setState(() => _isPlaying = true);
    _controller.forward(from: 0).whenComplete(() {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final burstSize = widget.iconSize * 1.4;
    return Semantics(
      button: true,
      label: widget.semanticsLabel,
      child: InkWell(
        onTap: _handleTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Lottie stays mounted from the first build (just hidden)
                // so its onLoaded fires — and the controller gets its real
                // duration — well before forward() is ever triggered by a
                // tap. Setting the duration mid-flight (i.e. only mounting
                // this on tap) caused a visible speed jump partway through.
                Opacity(
                  opacity: _isPlaying ? 1 : 0,
                  child: SizedBox(
                    width: burstSize,
                    height: burstSize,
                    child: Lottie.asset(
                      'assets/lottie/added.json',
                      controller: _controller,
                      onLoaded: (composition) {
                        _controller.duration = composition.duration;
                      },
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Opacity(
                  opacity: _isPlaying ? 0 : 1,
                  child: Icon(
                    Icons.add_rounded,
                    color: widget.iconColor,
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
