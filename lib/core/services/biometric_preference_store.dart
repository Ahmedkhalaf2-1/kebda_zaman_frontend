import 'package:shared_preferences/shared_preferences.dart';

/// Local-only "is biometric login turned on, and for which user" flag.
///
/// Deliberately SharedPreferences, not secure storage — this stores no
/// secret, just a boolean + the user id it applies to. The actual session
/// material (refresh token) it gates access to already lives in secure
/// storage via the existing auth architecture; this store never touches it.
///
/// Bound to a specific user id so that logging in as a different user (or
/// after logout, where [AuthNotifier.userKey] is cleared) can never let a
/// stale preference apply to the wrong account — see call sites in
/// [AuthNotifier] and [SessionBootstrapNotifier].
class BiometricPreferenceStore {
  static const String _enabledKey = 'kz_biometric_enabled';
  static const String _userIdKey = 'kz_biometric_user_id';

  /// User ids who have already been shown the post-login/signup biometric
  /// onboarding prompt (Enabled, declined, or failed — any outcome counts as
  /// "seen"), so it is offered at most once per account on this device. Not
  /// scoped to the currently active user and deliberately survives logout —
  /// its only purpose is "don't nag this account again", which should still
  /// hold if they log back in later.
  static const String _onboardingSeenKey = 'kz_biometric_onboarding_seen';

  /// Whether biometric login is enabled AND tied to [userId] specifically.
  static Future<bool> isEnabledFor(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_enabledKey) ?? false;
    final storedUserId = prefs.getString(_userIdKey);
    return enabled && storedUserId != null && storedUserId == userId;
  }

  /// Only ever call this immediately after a successful biometric
  /// verification — never as a bare preference write.
  static Future<void> enableFor(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, true);
    await prefs.setString(_userIdKey, userId);
  }

  /// Disables future biometric prompts/actions. Never touches the session
  /// itself — this only turns off the local gate/shortcut.
  static Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_enabledKey);
    await prefs.remove(_userIdKey);
  }

  /// Whether the one-time post-login/signup onboarding prompt has already
  /// been shown (and resolved, one way or another) for [userId].
  static Future<bool> hasSeenOnboardingFor(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getStringList(_onboardingSeenKey) ?? const [];
    return seen.contains(userId);
  }

  /// Marks the onboarding prompt as shown for [userId] so it is never
  /// offered again on this device, regardless of whether the user enabled,
  /// declined, or the biometric check itself failed/cancelled.
  static Future<void> markOnboardingSeenFor(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getStringList(_onboardingSeenKey) ?? const [];
    if (!seen.contains(userId)) {
      await prefs.setStringList(_onboardingSeenKey, [...seen, userId]);
    }
  }

  /// Called only from account deletion — removes [userId]'s onboarding
  /// history along with every other biometric artifact tied to that account.
  static Future<void> clearOnboardingSeenFor(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getStringList(_onboardingSeenKey) ?? const [];
    if (seen.contains(userId)) {
      await prefs.setStringList(
        _onboardingSeenKey,
        seen.where((id) => id != userId).toList(),
      );
    }
  }
}
