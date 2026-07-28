import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Centralized motion tokens for Kebda Zaman (Phase 9). Every interaction
/// animation in the app should reuse a duration/curve from here rather than
/// hand-picking arbitrary numbers per screen — keeps the whole app feeling
/// like one consistent system instead of a collection of one-off tweaks.
class KZMotion {
  KZMotion._();

  // ─── Durations ──────────────────────────────────────────
  /// Press/tap feedback — must feel immediate, never delay the tap itself.
  static const Duration instant = Duration(milliseconds: 100);

  /// Small state flips: icon swaps, quantity digit changes, chip selection.
  static const Duration fast = Duration(milliseconds: 160);

  /// Default for most enter/exit and content-swap transitions.
  static const Duration standard = Duration(milliseconds: 220);

  /// Reserved for the rare "this matters" moment — success confirmation,
  /// a hero entrance. Never used for routine state changes.
  static const Duration emphasized = Duration(milliseconds: 320);

  // ─── Curves ─────────────────────────────────────────────
  /// Press-down/press-up feedback on buttons, cards, chips.
  static const Curve press = Curves.easeOut;

  /// Content entering or leaving the screen (fades, small slides).
  static const Curve enterExit = Curves.easeOutCubic;

  /// Ordinary state changes (loading → content, toggles, badges).
  static const Curve stateChange = Curves.easeInOut;

  /// One-time success/confirmation emphasis — deliberately not bouncy
  /// (`easeOutBack` etc. are avoided — no exaggerated bounce per spec).
  static const Curve successEmphasis = Curves.easeOutCubic;

  // ─── Press-feedback scale ───────────────────────────────
  /// How far a pressable shrinks on press — subtle by design. Anything
  /// larger reads as a bounce, not feedback.
  static const double pressScale = 0.97;

  /// True when the platform/user has requested reduced motion
  /// (`Settings > Accessibility > Reduce Motion` on iOS/macOS,
  /// `Remove animations` on Android, `prefers-reduced-motion` on web).
  /// Flutter surfaces this as [MediaQueryData.disableAnimations].
  static bool reduceMotion(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ??
        SchedulerBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .disableAnimations;
  }

  /// Returns [instant] duration (effectively skipping the animation) when
  /// reduced motion is requested, otherwise [duration]. Use for
  /// nonessential scale/slide flourishes — never for a loading/progress
  /// indicator, which must keep running regardless.
  static Duration durationFor(BuildContext context, Duration duration) {
    return reduceMotion(context) ? Duration.zero : duration;
  }
}

/// Shared press-feedback wrapper: a subtle scale-down while pressed, using
/// [KZMotion] tokens. Wrap any tappable surface (button, card, chip, list
/// row) in this instead of hand-rolling a `GestureDetector` + `AnimatedScale`
/// pair per screen. Purely a feedback layer — it does not change the
/// child's layout, size, or hit-test behavior, and it still lets the child
/// handle its own tap/hover/focus (this widget only reads down/up/cancel to
/// drive the scale).
class KZPressableScale extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const KZPressableScale({super.key, required this.child, this.enabled = true});

  @override
  State<KZPressableScale> createState() => _KZPressableScaleState();
}

class _KZPressableScaleState extends State<KZPressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled) return;
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? KZMotion.pressScale : 1.0;
    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: scale,
        duration: KZMotion.durationFor(context, KZMotion.instant),
        curve: KZMotion.press,
        child: widget.child,
      ),
    );
  }
}
