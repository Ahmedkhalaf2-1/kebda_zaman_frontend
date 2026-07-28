import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    String? phone,
    required String name,
    String? email,
    @Default([]) List<String> addressIds,
    @Default([]) List<String> favoriteItemIds,
    String? loyaltyAccountId,
    String? role,
    // Backend-authoritative guest flag — avoids the fragile name/email heuristic.
    @Default(false) bool isGuest,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// Prefer [User.isGuest] for all eligibility logic.
/// This extension is kept only for callers that still use it externally;
/// it now simply delegates to the backend field.
extension UserGuestExtension on User {
  bool get isGuestUser => isGuest;
}
