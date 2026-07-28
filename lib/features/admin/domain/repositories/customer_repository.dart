import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/customer_summary.dart';

/// ADMIN-only customer management
/// (PHASE_6_CUSTOMER_MANAGEMENT_API_CONTRACT.md).
abstract class CustomerRepository {
  Future<Result<List<CustomerSummary>>> getCustomers({
    String? query,
    bool? isActive,
    int page,
    int limit,
  });

  Future<Result<CustomerDetail>> getCustomerDetail(String id);

  Future<Result<CustomerDetail>> updateCustomerStatus(
    String id, {
    required bool isActive,
  });
}
