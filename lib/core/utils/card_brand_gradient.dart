import 'package:flutter/material.dart';

/// Brand-colored gradient for the "wallet card" treatment used anywhere a
/// saved card is displayed (checkout's saved-card picker, the Saved Cards
/// management screen) — purely cosmetic grouping by the brand string the
/// backend already returns, never used for any logic decision.
LinearGradient cardBrandGradient(String brand) {
  switch (brand.toLowerCase()) {
    case 'visa':
      return const LinearGradient(
        colors: [Color(0xFF1A1F71), Color(0xFF3B5AA6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'mastercard':
      return const LinearGradient(
        colors: [Color(0xFFEB4B31), Color(0xFFFF7A00)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'mada':
      return const LinearGradient(
        colors: [Color(0xFF0E5C36), Color(0xFF1B8A54)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    case 'amex':
    case 'american express':
      return const LinearGradient(
        colors: [Color(0xFF1F6FB2), Color(0xFF3A97D4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    default:
      return const LinearGradient(
        colors: [Color(0xFF3A3A3A), Color(0xFF5C5C5C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
  }
}
