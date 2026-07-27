import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  RestaurantSettings _settings = const RestaurantSettings(
    name: 'Kebda Zaman',
    isOpen: true,
    deliveryFee: 20.0,
    loyaltyEgpStep: 10.0,
    loyaltyPointsPerStep: 1,
    loyaltyEarnRatePerCurrencyUnit: 0.1,
    loyaltyMinRedemptionPoints: 100,
    loyaltyMaxDiscountFromPoints: 50.0,
  );
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('restaurant_settings_state');
    if (data != null) {
      try {
        _settings = RestaurantSettings.fromJson(json.decode(data));
      } catch (_) {}
    }
    _initialized = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'restaurant_settings_state',
      json.encode(_settings.toJson()),
    );
  }

  @override
  Future<Result<RestaurantSettings>> getSettings() async {
    await _init();
    return Success(_settings);
  }

  @override
  Future<Result<RestaurantSettings>> getAdminSettings() async {
    await _init();
    return Success(_settings);
  }

  @override
  Future<Result<void>> updateSettings(RestaurantSettings settings) async {
    await _init();
    _settings = settings;
    await _save();
    return const Success(null);
  }
}
