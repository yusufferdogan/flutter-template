enum StyleType {
  none,
  photo,
  anime,
  illustration,
  popArt,
  abstract,
  fantasy,
  comic,
}

class Style {
  final String id;
  final String name;
  final StyleType type;
  final String previewImageUrl;
  final int usageCount;

  const Style({
    required this.id,
    required this.name,
    required this.type,
    required this.previewImageUrl,
    required this.usageCount,
  });

  Style copyWith({
    String? id,
    String? name,
    StyleType? type,
    String? previewImageUrl,
    int? usageCount,
  }) {
    return Style(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Style &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.previewImageUrl == previewImageUrl &&
        other.usageCount == usageCount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        type.hashCode ^
        previewImageUrl.hashCode ^
        usageCount.hashCode;
  }
}
