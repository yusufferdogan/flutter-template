import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar/isar.dart';
import '../../../../shared/local/cache/local_db.dart';
import '../models/user_dto.dart';
import '../models/user_local_model.dart';

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
  final LocalDb localDb;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.localDb,
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
    try {
      final isar = localDb.getDb();
      final userLocalModel = UserLocalModel.fromDto(user);

      await isar.writeTxn(() async {
        // Save the user data (will replace existing user with same userId due to unique index)
        await isar.userLocalModels.put(userLocalModel);
      });
    } catch (e) {
      // Log error for debugging
      throw Exception('Failed to save user: $e');
    }
  }

  @override
  Future<UserDto?> getUser() async {
    try {
      final isar = localDb.getDb();
      final userLocalModel = await isar.userLocalModels.where().findFirst();

      if (userLocalModel == null) return null;

      return userLocalModel.toDto();
    } catch (e) {
      // Log error for debugging
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      final isar = localDb.getDb();

      await isar.writeTxn(() async {
        await isar.userLocalModels.clear();
      });
    } catch (e) {
      // Log error for debugging
      throw Exception('Failed to clear user: $e');
    }
  }
}
