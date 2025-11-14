class CommunityImage {
  final String id;
  final String imageUrl;
  final String prompt;
  final String artistName;
  final String artistAvatarUrl;
  final int likes;
  final String category;
  final DateTime createdAt;

  const CommunityImage({
    required this.id,
    required this.imageUrl,
    required this.prompt,
    required this.artistName,
    required this.artistAvatarUrl,
    required this.likes,
    required this.category,
    required this.createdAt,
  });

  CommunityImage copyWith({
    String? id,
    String? imageUrl,
    String? prompt,
    String? artistName,
    String? artistAvatarUrl,
    int? likes,
    String? category,
    DateTime? createdAt,
  }) {
    return CommunityImage(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      prompt: prompt ?? this.prompt,
      artistName: artistName ?? this.artistName,
      artistAvatarUrl: artistAvatarUrl ?? this.artistAvatarUrl,
      likes: likes ?? this.likes,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommunityImage &&
        other.id == id &&
        other.imageUrl == imageUrl &&
        other.prompt == prompt &&
        other.artistName == artistName &&
        other.artistAvatarUrl == artistAvatarUrl &&
        other.likes == likes &&
        other.category == category &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        imageUrl.hashCode ^
        prompt.hashCode ^
        artistName.hashCode ^
        artistAvatarUrl.hashCode ^
        likes.hashCode ^
        category.hashCode ^
        createdAt.hashCode;
  }
}
