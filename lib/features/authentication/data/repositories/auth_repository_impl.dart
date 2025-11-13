import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final firebase_auth.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<Either<AuthFailure, User>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // Validate password
      if (password.length < 8) {
        return const Left(AuthFailure.weakPassword());
      }

      final response = await remoteDataSource.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );

      await localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      await localDataSource.saveUser(response.user);

      return Right(response.user.toEntity());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<AuthFailure, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.signIn(
        email: email,
        password: password,
      );

      await localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      await localDataSource.saveUser(response.user);

      return Right(response.user.toEntity());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<AuthFailure, User>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return const Left(AuthFailure.oauthCancelled());
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);

      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        return const Left(AuthFailure.oauthFailed('Failed to get ID token'));
      }

      final response = await remoteDataSource.signInWithGoogle(idToken);

      await localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      await localDataSource.saveUser(response.user);

      return Right(response.user.toEntity());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<AuthFailure, User>> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential =
          firebase_auth.OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(oauthCredential);

      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        return const Left(AuthFailure.oauthFailed('Failed to get ID token'));
      }

      final response =
          await remoteDataSource.signInWithApple(credential.authorizationCode);

      await localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      await localDataSource.saveUser(response.user);

      return Right(response.user.toEntity());
    } catch (e) {
      if (e is SignInWithAppleAuthorizationException) {
        if (e.code == AuthorizationErrorCode.canceled) {
          return const Left(AuthFailure.oauthCancelled());
        }
        return Left(AuthFailure.oauthFailed(e.message));
      }
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    try {
      final token = await localDataSource.getAccessToken();

      if (token != null) {
        await remoteDataSource.signOut(token);
      }

      await localDataSource.clearTokens();
      await localDataSource.clearUser();
      await firebaseAuth.signOut();
      await googleSignIn.signOut();

      return const Right(null);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Stream<AuthState> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      return user != null ? AuthState.authenticated : AuthState.unauthenticated;
    });
  }

  @override
  Future<Either<AuthFailure, User?>> getCurrentUser() async {
    try {
      final userDto = await localDataSource.getUser();

      if (userDto == null) {
        return const Right(null);
      }

      return Right(userDto.toEntity());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  AuthFailure _handleException(Object e) {
    final errorMessage = e.toString();

    if (errorMessage.contains('Invalid credentials')) {
      return const AuthFailure.invalidCredentials();
    } else if (errorMessage.contains('Email already exists')) {
      return const AuthFailure.emailAlreadyExists();
    } else if (errorMessage.contains('Network error') ||
        errorMessage.contains('Connection timeout')) {
      return const AuthFailure.networkError();
    } else if (errorMessage.contains('Weak password')) {
      return const AuthFailure.weakPassword();
    } else if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          return const AuthFailure.invalidCredentials();
        case 'email-already-in-use':
          return const AuthFailure.emailAlreadyExists();
        case 'weak-password':
          return const AuthFailure.weakPassword();
        case 'network-request-failed':
          return const AuthFailure.networkError();
        default:
          return AuthFailure.serverError(e.message ?? 'Unknown error');
      }
    } else {
      return AuthFailure.unknown(errorMessage);
    }
  }
}
