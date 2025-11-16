import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/community_image.dart';

part 'community_image_dto.freezed.dart';
part 'community_image_dto.g.dart';

@freezed
class CommunityImageDto with _$CommunityImageDto {
  const CommunityImageDto._();

  const factory CommunityImageDto({
    required String id,
    @JsonKey(name: 'image_url') required String imageUrl,
    required String prompt,
    @JsonKey(name: 'artist_name') required String artistName,
    @JsonKey(name: 'artist_avatar_url') required String artistAvatarUrl,
    required int likes,
    required String category,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _CommunityImageDto;

  factory CommunityImageDto.fromJson(Map<String, dynamic> json) =>
      _$CommunityImageDtoFromJson(json);

  CommunityImage toEntity() {
    return CommunityImage(
      id: id,
      imageUrl: imageUrl,
      prompt: prompt,
      artistName: artistName,
      artistAvatarUrl: artistAvatarUrl,
      likes: likes,
      category: category,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
