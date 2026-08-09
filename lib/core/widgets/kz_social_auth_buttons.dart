import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// Shared shell for a social-auth button (Google/Apple): fixed height,
/// outlined white surface, icon + label, disabled while [isLoading] swaps
/// the icon for a fixed-size spinner so the button never changes footprint.
/// Deliberately lower visual weight than [KZButton] primary (no fill, no
/// shadow) — social auth is a secondary path next to email/password.
class _SocialButtonShell extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _SocialButtonShell({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 52,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KZ.radiusMd),
            side: const BorderSide(color: KZ.outlineVariant, width: 1),
          ),
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(KZ.radiusMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: KZ.onSurfaceVariant,
                    ),
                  )
                else
                  icon,
                const SizedBox(width: KZ.sp8),
                Flexible(
                  child: Text(
                    label,
                    style: KZ.labelLarge,
                    overflow: TextOverflow.ellipsis,
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

/// Google sign-in button — logo painted rather than bundled as an asset.
/// Shared by Login and Signup so both present social auth identically.
class KZGoogleSignInButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final bool isLoading;

  const KZGoogleSignInButton({
    super.key,
    required this.onTap,
    required this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return _SocialButtonShell(
      icon: const SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(painter: KZGoogleLogoPainter()),
      ),
      label: label,
      onTap: onTap,
      isLoading: isLoading,
    );
  }
}

/// Apple sign-in button — matches [KZGoogleSignInButton]'s size, alignment,
/// and visual weight so the two providers read as one consistent row.
class KZAppleSignInButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final bool isLoading;

  const KZAppleSignInButton({
    super.key,
    required this.onTap,
    required this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return _SocialButtonShell(
      icon: const Icon(Icons.apple, size: 20, color: KZ.onSurface),
      label: label,
      onTap: onTap,
      isLoading: isLoading,
    );
  }
}

/// The official-style multi-color Google "G" mark, painted rather than
/// bundled as an asset.
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
