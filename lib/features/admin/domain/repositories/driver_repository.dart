import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/driver_account.dart';

/// ADMIN-only driver account management (DRIVER_DELIVERY_API_CONTRACT.md).
abstract class DriverRepository {
  /// `GET /admin/drivers?q=&isActive=&page=&limit=` — returns a plain array
  /// (no `total` envelope, same convention as `/admin/customers`), so
  /// pagination is inferred by callers from whether a full page came back.
  Future<Result<List<DriverAccount>>> getDrivers({
    String? query,
    bool? isActive,
    int page = 1,
    int limit = 20,
  });

  Future<Result<DriverAccount>> getDriverById(String id);

  Future<Result<DriverAccount>> createDriver({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  Future<Result<DriverAccount>> updateDriver(
    String id, {
    String? name,
    String? email,
    String? phone,
    String? password,
    bool? isActive,
  });
}
