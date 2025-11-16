import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/style.dart';
import '../../domain/entities/template.dart';

part 'template_dto.freezed.dart';
part 'template_dto.g.dart';

@freezed
class TemplateDto with _$TemplateDto {
  const TemplateDto._();

  const factory TemplateDto({
    required String id,
    required String name,
    required String prompt,
    @JsonKey(name: 'preview_image_url') required String previewImageUrl,
    required String style,
    required String category,
  }) = _TemplateDto;

  factory TemplateDto.fromJson(Map<String, dynamic> json) =>
      _$TemplateDtoFromJson(json);

  Template toEntity() {
    return Template(
      id: id,
      name: name,
      prompt: prompt,
      previewImageUrl: previewImageUrl,
      style: _parseStyleType(style),
      category: category,
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
