import 'package:dartz/dartz.dart';
import '../entities/community_image.dart';
import '../entities/style.dart';
import '../entities/template.dart';
import '../failures/home_failure.dart';

abstract class HomeRepository {
  Future<Either<HomeFailure, List<Style>>> getTrendingStyles();

  Future<Either<HomeFailure, List<Template>>> getTemplates({
    int limit = 10,
  });

  Future<Either<HomeFailure, List<CommunityImage>>> getCommunityImages({
    String? category,
    int page = 1,
    int limit = 20,
  });
}
