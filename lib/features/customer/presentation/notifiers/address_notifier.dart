import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/shared/domain/models/address.dart';

class AddressState {
  final List<Address> addresses;
  final bool isLoading;
  final String? errorMessage;

  const AddressState({
    this.addresses = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AddressState copyWith({
    List<Address>? addresses,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  Address? get defaultAddress {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => addresses.first,
    );
  }
}

class AddressNotifier extends StateNotifier<AddressState> {
  final Ref _ref;

  AddressNotifier(this._ref) : super(const AddressState(isLoading: true)) {
    loadAddresses();
  }

  Future<void> loadAddresses() async {
    final authState = _ref.read(authNotifierProvider);
    // Guest users & unauthenticated users must NOT access address endpoints
    if (!authState.isLoggedIn || (authState.user?.isGuest ?? false)) {
      state = const AddressState(addresses: [], isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    final repo = _ref.read(addressRepositoryProvider);
    final result = await repo.getAddresses();

    result.fold(
      (failure) {
        if (!mounted) return;
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (addresses) {
        if (!mounted) return;
        state = AddressState(addresses: addresses, isLoading: false);
      },
    );
  }

  Future<bool> createAddress(Address address) async {
    final repo = _ref.read(addressRepositoryProvider);
    final result = await repo.createAddress(address);
    if (result.isSuccess) {
      await loadAddresses();
      return true;
    } else {
      state = state.copyWith(errorMessage: result.failure.message);
      return false;
    }
  }

  Future<bool> updateAddress(String id, Address address) async {
    final repo = _ref.read(addressRepositoryProvider);
    final result = await repo.updateAddress(id, address);
    if (result.isSuccess) {
      await loadAddresses();
      return true;
    } else {
      state = state.copyWith(errorMessage: result.failure.message);
      return false;
    }
  }

  Future<bool> deleteAddress(String id) async {
    final repo = _ref.read(addressRepositoryProvider);
    final result = await repo.deleteAddress(id);
    if (result.isSuccess) {
      await loadAddresses();
      return true;
    } else {
      state = state.copyWith(errorMessage: result.failure.message);
      return false;
    }
  }

  Future<bool> setDefaultAddress(String id) async {
    final repo = _ref.read(addressRepositoryProvider);
    final result = await repo.setDefaultAddress(id);
    if (result.isSuccess) {
      await loadAddresses();
      return true;
    } else {
      state = state.copyWith(errorMessage: result.failure.message);
      return false;
    }
  }
}

final addressNotifierProvider =
    StateNotifierProvider<AddressNotifier, AddressState>((ref) {
      return AddressNotifier(ref);
    });
