import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../models/user_dto.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> clearTokens();

  Future<void> saveUser(UserDto user);

  Future<UserDto?> getUser();

  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final Box box;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user';

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.box,
  });

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      secureStorage.write(key: _accessTokenKey, value: accessToken),
      secureStorage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      secureStorage.delete(key: _accessTokenKey),
      secureStorage.delete(key: _refreshTokenKey),
    ]);
  }

  @override
  Future<void> saveUser(UserDto user) async {
    final userJson = json.encode(user.toJson());
    await box.put(_userKey, userJson);
  }

  @override
  Future<UserDto?> getUser() async {
    final userJson = box.get(_userKey);
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> userMap = json.decode(userJson);
      return UserDto.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await box.delete(_userKey);
  }
}
