import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/address.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/address_repository.dart';

class FakeAddressRepository implements AddressRepository {
  final List<Address> _addresses = [
    const Address(
      id: 'addr-1',
      userId: 'user-1',
      label: 'Home',
      street: '123 El-Tahrir St.',
      building: 'Building 5',
      floor: '3',
      apartment: '12',
      city: 'Cairo',
      area: 'Dokki',
      isDefault: true,
    ),
    const Address(
      id: 'addr-2',
      userId: 'user-1',
      label: 'Work',
      street: '45 Smart Village',
      building: 'Building B3',
      floor: '1',
      apartment: '101',
      city: 'Giza',
      area: '6th of October',
      isDefault: false,
    ),
  ];

  @override
  Future<Result<List<Address>>> getAddresses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Success(List.unmodifiable(_addresses));
  }

  @override
  Future<Result<Address>> createAddress(Address address) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final isFirst = _addresses.isEmpty;
    final newAddress = address.copyWith(
      id: 'addr-${DateTime.now().millisecondsSinceEpoch}',
      isDefault: isFirst || address.isDefault,
    );
    if (newAddress.isDefault) {
      _clearDefaults();
    }
    _addresses.add(newAddress);
    return Success(newAddress);
  }

  @override
  Future<Result<Address>> updateAddress(String id, Address address) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _addresses.indexWhere((a) => a.id == id);
    if (index == -1) {
      return const Err(NotFoundFailure('ADDRESS_NOT_FOUND'));
    }
    if (address.isDefault) {
      _clearDefaults();
    }
    final updated = address.copyWith(id: id);
    _addresses[index] = updated;
    return Success(updated);
  }

  @override
  Future<Result<void>> deleteAddress(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _addresses.indexWhere((a) => a.id == id);
    if (index == -1) {
      return const Err(NotFoundFailure('ADDRESS_NOT_FOUND'));
    }
    _addresses.removeAt(index);
    return const Success(null);
  }

  @override
  Future<Result<Address>> setDefaultAddress(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _addresses.indexWhere((a) => a.id == id);
    if (index == -1) {
      return const Err(NotFoundFailure('ADDRESS_NOT_FOUND'));
    }
    _clearDefaults();
    final updated = _addresses[index].copyWith(isDefault: true);
    _addresses[index] = updated;
    return Success(updated);
  }

  void _clearDefaults() {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: false);
    }
  }
}
