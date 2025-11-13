import 'package:dartz/dartz.dart';
import '../entities/auth_failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<AuthFailure, User>> call({
    required String email,
    required String password,
  }) async {
    // Validate email format
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return const Left(
        AuthFailure.serverError('Invalid email format'),
      );
    }

    // Validate password is not empty
    if (password.isEmpty) {
      return const Left(
        AuthFailure.serverError('Password cannot be empty'),
      );
    }

    return await repository.signIn(
      email: email,
      password: password,
    );
  }
}
