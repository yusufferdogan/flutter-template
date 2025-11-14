import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/entities/auth_failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/supabase_auth_remote_datasource.dart';

/// Supabase implementation of authentication repository
class SupabaseAuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final SupabaseClient supabase;

  SupabaseAuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    SupabaseClient? supabase,
  }) : supabase = supabase ?? SupabaseConfig.client;

  @override
  Future<Either<AuthFailure, User>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );

      // Save tokens locally
      await localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // Save user data locally
      await localDataSource.saveUser(response.user);

      return Right(response.user.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
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

      // Save tokens locally
      await localDataSource.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // Save user data locally
      await localDataSource.saveUser(response.user);

      return Right(response.user.toEntity());
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<AuthFailure, User>> signInWithGoogle() async {
    try {
      // Use Supabase's native Google sign-in
      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'filmku://login-callback',
      );

      if (!response) {
        return const Left(OAuthCancelled());
      }

      // Wait for auth state change
      final session = supabase.auth.currentSession;
      if (session == null) {
        return const Left(OAuthFailed('Failed to get session'));
      }

      // Fetch user data
      final userData = await supabase
          .from('users')
          .select()
          .eq('id', session.user.id)
          .single();

      final user = User(
        id: userData['id'],
        fullName: userData['full_name'],
        email: userData['email'],
        profileImageUrl: userData['profile_image_url'],
        isPremium: userData['is_premium'] ?? false,
        credits: userData['credits'] ?? 10,
        createdAt: DateTime.parse(userData['created_at']),
      );

      // Save tokens and user data locally
      await localDataSource.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
      );

      return Right(user);
    } on AuthException catch (e) {
      return Left(OAuthFailed(e.message));
    } catch (e) {
      return Left(OAuthFailed(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, User>> signInWithApple() async {
    try {
      // Use Supabase's native Apple sign-in
      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'filmku://login-callback',
      );

      if (!response) {
        return const Left(OAuthCancelled());
      }

      // Wait for auth state change
      final session = supabase.auth.currentSession;
      if (session == null) {
        return const Left(OAuthFailed('Failed to get session'));
      }

      // Fetch user data
      final userData = await supabase
          .from('users')
          .select()
          .eq('id', session.user.id)
          .single();

      final user = User(
        id: userData['id'],
        fullName: userData['full_name'],
        email: userData['email'],
        profileImageUrl: userData['profile_image_url'],
        isPremium: userData['is_premium'] ?? false,
        credits: userData['credits'] ?? 10,
        createdAt: DateTime.parse(userData['created_at']),
      );

      // Save tokens and user data locally
      await localDataSource.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
      );

      return Right(user);
    } on AuthException catch (e) {
      return Left(OAuthFailed(e.message));
    } catch (e) {
      return Left(OAuthFailed(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    try {
      final token = await localDataSource.getAccessToken();
      await remoteDataSource.signOut(token ?? '');
      await localDataSource.clearTokens();
      await localDataSource.clearUser();
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<AuthFailure, void>> resetPassword(String email) async {
    try {
      await remoteDataSource.resetPassword(email);
      return const Right(null);
    } on Exception catch (e) {
      return Left(_mapExceptionToFailure(e));
    }
  }

  @override
  Stream<AuthState> get authStateChanges {
    return supabase.auth.onAuthStateChange.map((state) {
      if (state.session != null) {
        return AuthState.authenticated;
      } else {
        return AuthState.unauthenticated;
      }
    });
  }

  @override
  Future<Either<AuthFailure, User?>> getCurrentUser() async {
    try {
      // Check if user is authenticated
      final session = supabase.auth.currentSession;
      if (session == null) {
        return const Right(null);
      }

      // Try to get user from local storage first
      final localUser = await localDataSource.getUser();
      if (localUser != null) {
        return Right(localUser.toEntity());
      }

      // Fetch from Supabase
      final userData = await supabase
          .from('users')
          .select()
          .eq('id', session.user.id)
          .single();

      final user = User(
        id: userData['id'],
        fullName: userData['full_name'],
        email: userData['email'],
        profileImageUrl: userData['profile_image_url'],
        isPremium: userData['is_premium'] ?? false,
        credits: userData['credits'] ?? 10,
        createdAt: DateTime.parse(userData['created_at']),
      );

      return Right(user);
    } catch (e) {
      return Left(_mapExceptionToFailure(e as Exception));
    }
  }

  /// Map exceptions to auth failures
  AuthFailure _mapExceptionToFailure(Exception e) {
    final message = e.toString();

    if (message.contains('Invalid credentials') ||
        message.contains('Invalid email or password')) {
      return const InvalidCredentials();
    } else if (message.contains('Email already exists')) {
      return const EmailAlreadyExists();
    } else if (message.contains('Password is too weak')) {
      return const WeakPassword();
    } else if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout')) {
      return const NetworkError();
    } else if (message.contains('Server error')) {
      return ServerError(message);
    } else {
      return Unknown(message);
    }
  }
}
