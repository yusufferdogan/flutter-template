import 'package:dartz/dartz.dart';
import '../entities/auth_failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithAppleUseCase {
  final AuthRepository repository;

  SignInWithAppleUseCase(this.repository);

  Future<Either<AuthFailure, User>> call() async {
    return await repository.signInWithApple();
  }
}
