import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/style.dart';

part 'style_dto.freezed.dart';
part 'style_dto.g.dart';

@freezed
class StyleDto with _$StyleDto {
  const StyleDto._();

  const factory StyleDto({
    required String id,
    required String name,
    required String type,
    @JsonKey(name: 'preview_image_url') required String previewImageUrl,
    @JsonKey(name: 'usage_count') required int usageCount,
  }) = _StyleDto;

  factory StyleDto.fromJson(Map<String, dynamic> json) =>
      _$StyleDtoFromJson(json);

  Style toEntity() {
    return Style(
      id: id,
      name: name,
      type: _parseStyleType(type),
      previewImageUrl: previewImageUrl,
      usageCount: usageCount,
    );
  }

  StyleType _parseStyleType(String typeString) {
    try {
      return StyleType.values.firstWhere(
        (e) => e.name.toLowerCase() == typeString.toLowerCase(),
        orElse: () => StyleType.none,
      );
    } catch (e) {
      return StyleType.none;
    }
  }
}
