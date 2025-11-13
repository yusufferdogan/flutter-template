import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String fullName,
    required String email,
    String? profileImageUrl,
    required bool isPremium,
    required int credits,
    required DateTime createdAt,
  }) = _User;
}
