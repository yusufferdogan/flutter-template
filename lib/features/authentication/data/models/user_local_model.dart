import 'package:isar/isar.dart';
import 'user_dto.dart';

part 'user_local_model.g.dart';

@collection
class UserLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId;

  late String fullName;
  late String email;
  String? profileImageUrl;
  late bool isPremium;
  late int credits;
  late String createdAt;

  // Mapping function: UserDto -> UserLocalModel
  static UserLocalModel fromDto(UserDto dto) {
    return UserLocalModel()
      ..userId = dto.id
      ..fullName = dto.fullName
      ..email = dto.email
      ..profileImageUrl = dto.profileImageUrl
      ..isPremium = dto.isPremium
      ..credits = dto.credits
      ..createdAt = dto.createdAt;
  }

  // Mapping function: UserLocalModel -> UserDto
  UserDto toDto() {
    return UserDto(
      id: userId,
      fullName: fullName,
      email: email,
      profileImageUrl: profileImageUrl,
      isPremium: isPremium,
      credits: credits,
      createdAt: createdAt,
    );
  }
}
