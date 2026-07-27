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
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

extension UserGuestExtension on User {
  bool get isGuest =>
      email == null ||
      email!.isEmpty ||
      email!.toLowerCase().contains('guest') ||
      name.toLowerCase().contains('guest');
}
