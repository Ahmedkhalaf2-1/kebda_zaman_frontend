import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// Reusable Google sign-in button (logo only, no label) shared by Login and
/// Register — matches the existing social-button visual (56dp height, white
/// fill, outline border, 12dp radius) those screens already used for a
/// previously no-op Google button. Swaps its content for a spinner while
/// [isLoading], keeping the same footprint so nothing shifts, and disables
/// tapping while loading so a second tap can't start a second Google flow.
class KZGoogleSignInButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const KZGoogleSignInButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KZ.outlineVariant, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: KZ.primary,
                      ),
                    )
                  : const SizedBox(
                      width: 22,
                      height: 22,
                      child: CustomPaint(painter: KZGoogleLogoPainter()),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The official-style multi-color Google "G" mark, painted rather than
/// bundled as an asset — moved here (unchanged) from where Login/Register
/// each previously defined their own identical private copy.
class KZGoogleLogoPainter extends CustomPainter {
  const KZGoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Red arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -3.14159 * 0.8, 3.14159 * 0.6, false, paint);

    // Yellow arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 3.14159 * 0.7, 3.14159 * 0.5, false, paint);

    // Green arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 3.14159 * 0.1, 3.14159 * 0.6, false, paint);

    // Blue arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -3.14159 * 0.2, 3.14159 * 0.3, false, paint);

    // Blue horizontal bar
    paint.style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(
        size.width * 0.45,
        size.height * 0.42,
        size.width * 0.9,
        size.height * 0.58,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
