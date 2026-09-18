import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/customer_summary.dart';
import 'package:kebda_zaman/features/admin/domain/models/customers_reset_summary.dart';

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

  /// ADMIN-only: `GET /admin/customers/reset-preview` — a dry-run count of
  /// what [resetCustomers] would clear, with no side effects.
  Future<Result<CustomersResetSummary>> previewResetCustomers();

  /// ADMIN-only, destructive: `DELETE /admin/customers/reset` — for every
  /// CUSTOMER account, zeroes loyalty points and deletes loyalty
  /// transactions/reviews/feedback. Never deletes the User row itself, or
  /// their addresses/cart/tokens. Disabled server-side outside
  /// non-production environments (`403 RESET_DISABLED_IN_PRODUCTION`).
  /// Irreversible.
  Future<Result<CustomersResetSummary>> resetCustomers();
}
