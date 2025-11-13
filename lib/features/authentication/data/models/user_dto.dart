import '../../domain/entities/user.dart';

class UserDto {
  final String id;
  final String fullName;
  final String email;
  final String? profileImageUrl;
  final bool isPremium;
  final int credits;
  final String createdAt;

  const UserDto({
    required this.id,
    required this.fullName,
    required this.email,
    this.profileImageUrl,
    required this.isPremium,
    required this.credits,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      isPremium: json['isPremium'] as bool,
      credits: json['credits'] as int,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'isPremium': isPremium,
      'credits': credits,
      'createdAt': createdAt,
    };
  }

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
