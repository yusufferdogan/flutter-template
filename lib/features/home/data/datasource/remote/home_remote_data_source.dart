import 'package:dartz/dartz.dart';
import 'package:filmku/models/response/genre_response.dart';
import 'package:filmku/models/response/movies_response.dart';
import 'package:filmku/shared/util/app_exception.dart';
import '../../models/style_dto.dart';
import '../../models/template_dto.dart';
import '../../models/community_image_dto.dart';

abstract class HomeRemoteDataSource {
  // Legacy FilmKu methods
  Future<Either<AppException, MoviesResponse>> getMovies(
      {required String endPoint, required int page});

  Future<Either<AppException, GenreResponse>> getGenre();

  // New AI Image Generator methods
  Future<List<StyleDto>> getTrendingStyles();

  Future<List<TemplateDto>> getTemplates({int limit = 10});

  Future<List<CommunityImageDto>> getCommunityImages({
    String? category,
    int page = 1,
    int limit = 20,
  });
}
