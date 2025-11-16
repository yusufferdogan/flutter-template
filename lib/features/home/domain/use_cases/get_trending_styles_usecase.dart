import 'package:dartz/dartz.dart';
import '../entities/style.dart';
import '../failures/home_failure.dart';
import '../repositories/home_repository.dart';

class GetTrendingStylesUseCase {
  final HomeRepository repository;

  GetTrendingStylesUseCase(this.repository);

  Future<Either<HomeFailure, List<Style>>> call() {
    return repository.getTrendingStyles();
  }
}
