import 'package:dartz/dartz.dart';
import '../entities/community_image.dart';
import '../failures/home_failure.dart';
import '../repositories/home_repository.dart';

class GetCommunityImagesUseCase {
  final HomeRepository repository;

  GetCommunityImagesUseCase(this.repository);

  Future<Either<HomeFailure, List<CommunityImage>>> call({
    String? category,
    int page = 1,
    int limit = 20,
  }) {
    return repository.getCommunityImages(
      category: category,
      page: page,
      limit: limit,
    );
  }
}
