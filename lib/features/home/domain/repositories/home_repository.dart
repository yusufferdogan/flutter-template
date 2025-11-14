import 'package:dartz/dartz.dart';
import 'package:filmku/models/domain/movies.dart';
import 'package:filmku/models/genres.dart';
import 'package:filmku/shared/util/app_exception.dart';
import '../entities/community_image.dart';
import '../entities/style.dart';
import '../entities/template.dart';
import '../failures/home_failure.dart';

abstract class HomeRepository {
  // New AI Image Generator methods
  Future<Either<HomeFailure, List<Style>>> getTrendingStyles();

  Future<Either<HomeFailure, List<Template>>> getTemplates({
    int limit = 10,
  });

  Future<Either<HomeFailure, List<CommunityImage>>> getCommunityImages({
    String? category,
    int page = 1,
    int limit = 20,
  });

  // Legacy FilmKu movie methods (for backward compatibility)
  Future<Either<AppException, Movies>> fetchAndCacheMovies({
    required int page,
    required String type,
  });

  Future<Either<AppException, Movies>> fetchCachedMovies({
    required String type,
  });

  Future<Either<AppException, Genres>> fetchAndCacheGenres();

  Future<Either<AppException, Genres>> fetchCachedGenres();
}
