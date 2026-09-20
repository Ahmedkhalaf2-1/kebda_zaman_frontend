import 'package:shared_preferences/shared_preferences.dart';

/// Local-only "has the customer already dismissed the automatic post-delivery
/// review prompt for this order" flag — per-order, not per-user (an order id
/// is already globally unique, so no account-scoping is needed the way
/// [BiometricPreferenceStore] scopes by user id).
///
/// This is purely a "don't re-nag" signal for the *automatic* banner on the
/// order tracking screen. It never touches, and must never be confused with,
/// actual review completion — that is always determined fresh from the
/// backend's `GET /reviews/me/orders/:orderId` response, never inferred from
/// this store. Dismissing the prompt never hides the manual "Rate Order"
/// entry point in Orders history.
class ReviewPromptDismissalStore {
  static const String _dismissedOrderIdsKey =
      'kz_review_prompt_dismissed_order_ids';

  static Future<bool> isDismissed(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getStringList(_dismissedOrderIdsKey) ?? const [];
    return dismissed.contains(orderId);
  }

  static Future<void> dismiss(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getStringList(_dismissedOrderIdsKey) ?? const [];
    if (!dismissed.contains(orderId)) {
      await prefs.setStringList(_dismissedOrderIdsKey, [
        ...dismissed,
        orderId,
      ]);
    }
  }
}
