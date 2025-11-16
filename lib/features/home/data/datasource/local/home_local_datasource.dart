import 'package:dartz/dartz.dart';
import 'package:filmku/models/domain/movies.dart';
import 'package:filmku/models/genres.dart';
import 'package:filmku/shared/util/app_exception.dart';
import '../../models/style_dto.dart';
import '../../models/template_dto.dart';
import '../../models/community_image_dto.dart';

abstract class HomeLocalDataSource {
  // Legacy FilmKu methods
  Future<void> cacheMovies({required Movies movies});

  Future<void> cacheGenres({required Genres genres});

  Future<Either<AppException, Movies>> getCacheMovies({required String type});

  Future<Either<AppException, Genres>> getGenreCache();

  // New AI Image Generator methods
  Future<void> cacheTrendingStyles({required List<StyleDto> styles});

  Future<List<StyleDto>?> getCachedTrendingStyles();

  Future<void> cacheTemplates({required List<TemplateDto> templates});

  Future<List<TemplateDto>?> getCachedTemplates();

  Future<void> cacheCommunityImages({
    required List<CommunityImageDto> images,
    required String category,
    required int page,
  });

  Future<List<CommunityImageDto>?> getCachedCommunityImages({
    required String category,
    required int page,
  });

  Future<void> clearCommunityImagesCache();
}
