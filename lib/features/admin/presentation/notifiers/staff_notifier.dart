import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/admin/domain/models/staff_account.dart';

class StaffNotifier extends AutoDisposeAsyncNotifier<List<StaffAccount>> {
  @override
  Future<List<StaffAccount>> build() async {
    final repo = ref.read(staffRepositoryProvider);
    final result = await repo.getStaff();
    return result.fold((f) => throw f, (data) => data);
  }

  Future<Failure?> createStaff({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    final repo = ref.read(staffRepositoryProvider);
    final result = await repo.createStaff(
      name: name,
      email: email,
      password: password,
      role: role,
      phone: phone,
    );
    return result.fold((f) => f, (staff) {
      ref.invalidateSelf();
      return null;
    });
  }

  Future<Failure?> updateStaff(
    String id, {
    String? name,
    String? email,
    String? phone,
    bool? isActive,
    String? password,
  }) async {
    final repo = ref.read(staffRepositoryProvider);
    final result = await repo.updateStaff(
      id,
      name: name,
      email: email,
      phone: phone,
      isActive: isActive,
      password: password,
    );
    return result.fold((f) => f, (staff) {
      ref.invalidateSelf();
      return null;
    });
  }
}

final staffProvider =
    AutoDisposeAsyncNotifierProvider<StaffNotifier, List<StaffAccount>>(
      () => StaffNotifier(),
    );
