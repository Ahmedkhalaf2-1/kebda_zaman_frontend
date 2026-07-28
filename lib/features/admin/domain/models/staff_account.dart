import 'package:freezed_annotation/freezed_annotation.dart';

part 'staff_account.freezed.dart';
part 'staff_account.g.dart';

@freezed
class StaffAccount with _$StaffAccount {
  const factory StaffAccount({
    required String id,
    required String name,
    String? email,
    String? phone,
    required bool isActive,
    required DateTime createdAt,
  }) = _StaffAccount;

  factory StaffAccount.fromJson(Map<String, dynamic> json) =>
      _$StaffAccountFromJson(json);
}
