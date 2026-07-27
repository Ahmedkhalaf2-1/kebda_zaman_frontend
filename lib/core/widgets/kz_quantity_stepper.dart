import 'package:flutter/material.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// The one shared quantity control for cart lines and item customization.
///
/// - Each minus/plus tap target is a full `KZ.iconTapTargetMin` (48dp) even
///   though the glyph inside is smaller — never shrink the tappable area to
///   match the icon.
/// - Decrementing below [minQuantity] is disabled (greyed out, no handler)
///   rather than allowed to go to zero/negative or removing the row itself
///   — screens that want "decrementing at 1 removes the item" should pass
///   `minQuantity: 0` and treat a resulting 0 as a removal upstream.
/// - Uses `Row`, which Flutter mirrors automatically under RTL — no manual
///   left/right positioning, so this is RTL-correct by construction.
/// - The quantity label swaps via a brief built-in `AnimatedSwitcher` fade —
///   this is the "minimal built-in state transition" allowance for Sprint 2,
///   not the premium motion the next sprint will add on top of this widget.
class KZQuantityStepper extends StatelessWidget {
  final int quantity;
  final int minQuantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  const KZQuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.minQuantity = 1,
    this.maxQuantity = 99,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrement = quantity > minQuantity;
    final canIncrement = quantity < maxQuantity;

    return Container(
      decoration: BoxDecoration(
        color: KZ.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KZ.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            semanticLabel: 'Decrease quantity',
            onTap: canDecrement ? () => onChanged(quantity - 1) : null,
          ),
          SizedBox(
            width: 32,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                '$quantity',
                key: ValueKey<int>(quantity),
                textAlign: TextAlign.center,
                style: KZ.labelLarge,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            semanticLabel: 'Increase quantity',
            onTap: canIncrement ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;

  const _StepButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: KZ.iconTapTargetMin,
            height: KZ.iconTapTargetMin,
            child: Icon(
              icon,
              size: KZ.iconControl,
              color: enabled ? KZ.onSurface : KZ.outline,
            ),
          ),
        ),
      ),
    );
  }
}
