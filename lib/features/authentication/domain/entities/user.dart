class User {
  final String id;
  final String fullName;
  final String email;
  final String? profileImageUrl;
  final bool isPremium;
  final int credits;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.profileImageUrl,
    required this.isPremium,
    required this.credits,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? fullName,
    String? email,
    String? profileImageUrl,
    bool? isPremium,
    int? credits,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isPremium: isPremium ?? this.isPremium,
      credits: credits ?? this.credits,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.fullName == fullName &&
        other.email == email &&
        other.profileImageUrl == profileImageUrl &&
        other.isPremium == isPremium &&
        other.credits == credits &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fullName.hashCode ^
        email.hashCode ^
        profileImageUrl.hashCode ^
        isPremium.hashCode ^
        credits.hashCode ^
        createdAt.hashCode;
  }
}
