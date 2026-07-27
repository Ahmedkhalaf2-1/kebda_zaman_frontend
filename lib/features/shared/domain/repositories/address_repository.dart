import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/address.dart';

/// Repository interface for managing customer delivery addresses.
abstract class AddressRepository {
  /// Fetch all addresses for the authenticated user (oldest first).
  Future<Result<List<Address>>> getAddresses();

  /// Create a new address.
  /// Note: The first address created for a user is automatically forced to `isDefault: true` by the backend.
  Future<Result<Address>> createAddress(Address address);

  /// Full update of an existing address by [id].
  Future<Result<Address>> updateAddress(String id, Address address);

  /// Delete an address by [id].
  Future<Result<void>> deleteAddress(String id);

  /// Set an address as default by [id].
  Future<Result<Address>> setDefaultAddress(String id);
}
