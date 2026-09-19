import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_account.freezed.dart';
part 'driver_account.g.dart';

/// `GET /admin/drivers`' server-calculated availability — the source of
/// truth for whether a driver can be assigned right now. Never computed
/// client-side from cached order lists, since that can trivially go stale
/// the moment another admin assigns/reassigns/delivers an order.
enum DriverAvailability {
  available,
  busy,

  /// A future value this build doesn't recognize yet, or a driver whose
  /// account has no availability info (older backend versions) — treated as
  /// "unknown, not confirmed available", never as [available].
  unknown,
}

DriverAvailability _availabilityFromWire(String? value) {
  switch (value) {
    case 'AVAILABLE':
      return DriverAvailability.available;
    case 'BUSY':
      return DriverAvailability.busy;
    default:
      return DriverAvailability.unknown;
  }
}

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
    @JsonKey(
      name: 'availability',
      fromJson: _availabilityFromWire,
      includeToJson: false,
    )
    @Default(DriverAvailability.unknown)
    DriverAvailability availability,
    String? activeOrderId,
  }) = _DriverAccount;

  factory DriverAccount.fromJson(Map<String, dynamic> json) =>
      _$DriverAccountFromJson(json);
}
