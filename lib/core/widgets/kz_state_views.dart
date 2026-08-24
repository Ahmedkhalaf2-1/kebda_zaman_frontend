import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// A static placeholder block for skeleton loading layouts. Deliberately
/// has no shimmer/pulse animation — Sprint 2 excludes decorative motion by
/// design; a shimmer effect belongs to the later Motion System sprint and
/// can be layered on top of this same widget without changing call sites.
class KZSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;

  const KZSkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = const BorderRadius.all(Radius.circular(KZ.radiusSm)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: KZ.surfaceContainerLow,
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Shared empty-state layout: icon, title, optional supporting text, and at
/// most one action. No illustrations, no emojis — a single clean vector
/// icon only.
class KZEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? lottieAsset;

  const KZEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.lottieAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lottieAsset != null)
              SizedBox(
                width: 200,
                height: 200,
                child: ColoredBox(
                  color: Colors.white,
                  child: Lottie.asset(lottieAsset!, fit: BoxFit.contain),
                ),
              )
            else
              Icon(
                icon,
                size: 64,
                color: KZ.primary, // #8c2b00 (our signature terracotta primary!)
              ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: KZ.onSurface,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  message!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: KZ.onSurfaceVariant.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: KZ.primary, // #8c2b00
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: KZ.primary.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shared error-state layout. [message] must already be a human-readable,
/// user-facing sentence — never a raw exception, stack trace, or status
/// code. Callers are responsible for translating a caught error into
/// something like "We couldn't load this right now." before it reaches
/// this widget.
class KZErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const KZErrorState({
    super.key,
    required this.message,
    this.onRetry,
    required this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFEE2E2), // red-50 tint
                border: Border.all(
                  color: KZ.error.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: KZ.error,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: KZ.onSurface,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  retryLabel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KZ.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: KZ.primary.withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
