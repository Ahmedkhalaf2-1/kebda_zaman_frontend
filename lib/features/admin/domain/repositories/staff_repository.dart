import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/staff_account.dart';

/// ADMIN-only cashier/staff account management (PHASE_5_CASHIER_API_CONTRACT.md).
abstract class StaffRepository {
  Future<Result<List<StaffAccount>>> getStaff();

  Future<Result<StaffAccount>> createStaff({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  Future<Result<StaffAccount>> updateStaff(
    String id, {
    String? name,
    String? email,
    String? phone,
    bool? isActive,
    String? password,
  });
}
