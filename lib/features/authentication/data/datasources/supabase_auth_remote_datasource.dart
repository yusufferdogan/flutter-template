import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../models/auth_response_dto.dart';
import '../models/user_dto.dart';
import 'auth_remote_datasource.dart';

/// Supabase implementation of authentication remote data source
class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final SupabaseClient _supabase;

  SupabaseAuthRemoteDataSource({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseConfig.client;

  @override
  Future<AuthResponseDto> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      if (response.user == null) {
        throw Exception('Sign up failed: No user returned');
      }

      // Fetch user data from public.users table
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      final userDto = UserDto(
        id: userData['id'],
        fullName: userData['full_name'],
        email: userData['email'],
        profileImageUrl: userData['profile_image_url'],
        isPremium: userData['is_premium'] ?? false,
        credits: userData['credits'] ?? 10,
        createdAt: userData['created_at'],
      );

      return AuthResponseDto(
        user: userDto,
        accessToken: response.session?.accessToken ?? '',
        refreshToken: response.session?.refreshToken ?? '',
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponseDto> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed: No user returned');
      }

      // Fetch user data from public.users table
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      final userDto = UserDto(
        id: userData['id'],
        fullName: userData['full_name'],
        email: userData['email'],
        profileImageUrl: userData['profile_image_url'],
        isPremium: userData['is_premium'] ?? false,
        credits: userData['credits'] ?? 10,
        createdAt: userData['created_at'],
      );

      return AuthResponseDto(
        user: userDto,
        accessToken: response.session?.accessToken ?? '',
        refreshToken: response.session?.refreshToken ?? '',
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponseDto> signInWithGoogle(String idToken) async {
    try {
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (response.user == null) {
        throw Exception('Google sign in failed: No user returned');
      }

      // Fetch user data from public.users table
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      final userDto = UserDto(
        id: userData['id'],
        fullName: userData['full_name'],
        email: userData['email'],
        profileImageUrl: userData['profile_image_url'],
        isPremium: userData['is_premium'] ?? false,
        credits: userData['credits'] ?? 10,
        createdAt: userData['created_at'],
      );

      return AuthResponseDto(
        user: userDto,
        accessToken: response.session?.accessToken ?? '',
        refreshToken: response.session?.refreshToken ?? '',
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthResponseDto> signInWithApple(String authorizationCode) async {
    try {
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: authorizationCode,
      );

      if (response.user == null) {
        throw Exception('Apple sign in failed: No user returned');
      }

      // Fetch user data from public.users table
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      final userDto = UserDto(
        id: userData['id'],
        fullName: userData['full_name'],
        email: userData['email'],
        profileImageUrl: userData['profile_image_url'],
        isPremium: userData['is_premium'] ?? false,
        credits: userData['credits'] ?? 10,
        createdAt: userData['created_at'],
      );

      return AuthResponseDto(
        user: userDto,
        accessToken: response.session?.accessToken ?? '',
        refreshToken: response.session?.refreshToken ?? '',
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Apple sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut(String token) async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  /// Handle Supabase Auth exceptions
  Exception _handleAuthException(AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.toLowerCase().contains('email')) {
          return Exception('Email already exists');
        } else if (e.message.toLowerCase().contains('password')) {
          return Exception('Password is too weak');
        }
        return Exception(e.message);
      case '401':
      case '422':
        return Exception('Invalid credentials');
      case '429':
        return Exception('Too many requests. Please try again later');
      case '500':
        return Exception('Server error. Please try again later');
      default:
        return Exception(e.message);
    }
  }
}
