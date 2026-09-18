import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_account.freezed.dart';
part 'driver_account.g.dart';

/// Admin-managed DRIVER account (DRIVER_DELIVERY_API_CONTRACT.md,
/// `DriverResponseDto`). Mirrors [StaffAccount]'s shape but kept as its own
/// type since a driver carries no `role` discriminant (a driver is always
/// DRIVER) and is managed through its own `/admin/drivers` endpoints, not
/// `/admin/staff`.
@freezed
abstract class DriverAccount with _$DriverAccount {
  const factory DriverAccount({
    required String id,
    required String name,
    String? email,
    String? phone,
    required bool isActive,
    required DateTime createdAt,
  }) = _DriverAccount;

  factory DriverAccount.fromJson(Map<String, dynamic> json) =>
      _$DriverAccountFromJson(json);
}
