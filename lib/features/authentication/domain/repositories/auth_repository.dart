import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../entities/auth_failure.dart';

enum AuthState { authenticated, unauthenticated }

abstract class AuthRepository {
  /// Sign up a new user with email and password
  Future<Either<AuthFailure, User>> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  /// Sign in an existing user with email and password
  Future<Either<AuthFailure, User>> signIn({
    required String email,
    required String password,
  });

  /// Sign in with Google OAuth
  Future<Either<AuthFailure, User>> signInWithGoogle();

  /// Sign in with Apple OAuth
  Future<Either<AuthFailure, User>> signInWithApple();

  /// Sign out the current user
  Future<Either<AuthFailure, void>> signOut();

  /// Reset password for the given email
  Future<Either<AuthFailure, void>> resetPassword(String email);

  /// Stream of authentication state changes
  Stream<AuthState> get authStateChanges;

  /// Get the current authenticated user
  Future<Either<AuthFailure, User?>> getCurrentUser();
}
