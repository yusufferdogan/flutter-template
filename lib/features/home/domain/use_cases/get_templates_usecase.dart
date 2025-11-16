import 'package:dartz/dartz.dart';
import '../entities/template.dart';
import '../failures/home_failure.dart';
import '../repositories/home_repository.dart';

class GetTemplatesUseCase {
  final HomeRepository repository;

  GetTemplatesUseCase(this.repository);

  Future<Either<HomeFailure, List<Template>>> call({int limit = 10}) {
    return repository.getTemplates(limit: limit);
  }
}
