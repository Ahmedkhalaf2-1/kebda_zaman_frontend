import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kebda_zaman/core/theme/kz_motion.dart';

/// One consistent transition language for GoRouter routes (Phase 9) —
/// replaces each platform's inconsistent default push transition with a
/// restrained fade + small slide for regular screens, or a plain fade for
/// admin section switches. Route paths, redirects, and guards are
/// untouched; this only changes how the page visually enters/exits.
///
/// Reduced-motion is honored inside `transitionsBuilder` itself (it has a
/// `context`), not by branching before the page is built.
Page<T> kzFadeSlidePage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: KZMotion.standard,
    reverseTransitionDuration: KZMotion.standard,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (KZMotion.reduceMotion(context)) {
        return FadeTransition(opacity: animation, child: child);
      }
      final fade = CurvedAnimation(
        parent: animation,
        curve: KZMotion.enterExit,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.03),
        end: Offset.zero,
      ).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

/// Restrained transition for admin section switches — fade only, no slide,
/// so moving between sidebar/drawer destinations feels calm rather than
/// like a stack of pushed screens.
Page<T> kzAdminPage<T>({required GoRouterState state, required Widget child}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: KZMotion.standard,
    reverseTransitionDuration: KZMotion.standard,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: KZMotion.stateChange,
        ),
        child: child,
      );
    },
  );
}
