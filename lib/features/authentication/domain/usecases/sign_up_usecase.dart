import 'package:dartz/dartz.dart';
import '../entities/auth_failure.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<AuthFailure, User>> call({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // Validate full name
    if (fullName.trim().length < 2) {
      return const Left(
        AuthFailure.serverError('Full name must be at least 2 characters'),
      );
    }

    // Validate email format
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return const Left(
        AuthFailure.serverError('Invalid email format'),
      );
    }

    // Validate password
    if (password.length < 8) {
      return const Left(AuthFailure.weakPassword());
    }

    return await repository.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}
