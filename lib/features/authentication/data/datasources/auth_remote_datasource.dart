import 'package:dio/dio.dart';
import '../models/auth_response_dto.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseDto> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<AuthResponseDto> signIn({
    required String email,
    required String password,
  });

  Future<AuthResponseDto> signInWithGoogle(String idToken);

  Future<AuthResponseDto> signInWithApple(String authorizationCode);

  Future<void> signOut(String token);

  Future<void> resetPassword(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<AuthResponseDto> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/signup',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
        },
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<AuthResponseDto> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/signin',
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<AuthResponseDto> signInWithGoogle(String idToken) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/google',
        data: {
          'idToken': idToken,
        },
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<AuthResponseDto> signInWithApple(String authorizationCode) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/apple',
        data: {
          'authorizationCode': authorizationCode,
        },
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<void> signOut(String token) async {
    try {
      await dio.post(
        '$baseUrl/auth/signout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await dio.post(
        '$baseUrl/auth/reset-password',
        data: {
          'email': email,
        },
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Unknown error';

        if (statusCode == 401) {
          return Exception('Invalid credentials');
        } else if (statusCode == 409) {
          return Exception('Email already exists');
        } else if (statusCode == 400) {
          return Exception(message);
        }
        return Exception('Server error: $message');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      case DioExceptionType.connectionError:
        return Exception('Network error');
      default:
        return Exception('Unknown error occurred');
    }
  }
}
