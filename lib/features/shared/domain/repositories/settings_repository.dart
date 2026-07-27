import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/restaurant_settings.dart';

abstract class SettingsRepository {
  Future<Result<RestaurantSettings>> getSettings();

  /// Admin-only: hits `/admin/settings`, includes fields not present on the
  /// public shape (phone, taxRatePercent, currency, workingHours) so a
  /// subsequent [updateSettings] full-replace call doesn't clobber them.
  Future<Result<RestaurantSettings>> getAdminSettings();

  Future<Result<void>> updateSettings(RestaurantSettings settings);
}
