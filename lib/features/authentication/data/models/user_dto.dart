import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDto with _$UserDto {
  const UserDto._();

  const factory UserDto({
    required String id,
    required String fullName,
    required String email,
    String? profileImageUrl,
    required bool isPremium,
    required int credits,
    required String createdAt,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  User toEntity() => User(
        id: id,
        fullName: fullName,
        email: email,
        profileImageUrl: profileImageUrl,
        isPremium: isPremium,
        credits: credits,
        createdAt: DateTime.parse(createdAt),
      );

  factory UserDto.fromEntity(User user) => UserDto(
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        profileImageUrl: user.profileImageUrl,
        isPremium: user.isPremium,
        credits: user.credits,
        createdAt: user.createdAt.toIso8601String(),
      );
}
