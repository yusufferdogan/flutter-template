import 'style.dart';

class Template {
  final String id;
  final String name;
  final String prompt;
  final String previewImageUrl;
  final StyleType style;
  final String category;

  const Template({
    required this.id,
    required this.name,
    required this.prompt,
    required this.previewImageUrl,
    required this.style,
    required this.category,
  });

  Template copyWith({
    String? id,
    String? name,
    String? prompt,
    String? previewImageUrl,
    StyleType? style,
    String? category,
  }) {
    return Template(
      id: id ?? this.id,
      name: name ?? this.name,
      prompt: prompt ?? this.prompt,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      style: style ?? this.style,
      category: category ?? this.category,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Template &&
        other.id == id &&
        other.name == name &&
        other.prompt == prompt &&
        other.previewImageUrl == previewImageUrl &&
        other.style == style &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        prompt.hashCode ^
        previewImageUrl.hashCode ^
        style.hashCode ^
        category.hashCode;
  }
}
