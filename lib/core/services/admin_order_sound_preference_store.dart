import 'package:shared_preferences/shared_preferences.dart';

/// Local-only device preference for the admin new-order alert bell —
/// deliberately device-scoped (like [BiometricPreferenceStore]), not tied to
/// a specific admin account: a cashier terminal is a shared physical device,
/// so "how loud is the order bell" is a property of that device/register,
/// not of whoever happens to be logged in on it.
///
/// Absent any saved preference, sound defaults to enabled at full app
/// volume (1.0) — an explicit save always wins over that default afterwards.
class AdminOrderSoundPreferenceStore {
  static const String _enabledKey = 'kz_admin_order_sound_enabled';
  static const String _volumeKey = 'kz_admin_order_sound_volume';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  /// 0.0-1.0, applied as the `audioplayers` player volume (an
  /// application-level gain on the decoded asset) — never an attempt to
  /// change the device/OS output volume.
  static Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getDouble(_volumeKey);
    if (stored == null) return 1.0;
    return stored.clamp(0.0, 1.0);
  }

  static Future<void> setVolume(double volume) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume.clamp(0.0, 1.0));
  }
}
