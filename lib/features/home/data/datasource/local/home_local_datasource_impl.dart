import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:filmku/models/domain/movies.dart';
import 'package:filmku/models/genres.dart';
import 'package:filmku/shared/util/app_exception.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:filmku/shared/local/cache/local_db.dart';
import '../../models/style_dto.dart';
import '../../models/template_dto.dart';
import '../../models/community_image_dto.dart';
import 'home_local_datasource.dart';

class HomeLocalDataSourceImpl extends HomeLocalDataSource {
  LocalDb localDb;
  final SharedPreferences sharedPreferences;

  // Cache keys
  static const String _trendingStylesKey = 'trending_styles';
  static const String _trendingStylesTimestampKey = 'trending_styles_timestamp';
  static const String _templatesKey = 'templates';
  static const String _templatesTimestampKey = 'templates_timestamp';
  static const String _communityImagesKeyPrefix = 'community_images';

  // Cache durations
  static const Duration _stylesCacheDuration = Duration(hours: 1);
  static const Duration _templatesCacheDuration = Duration(hours: 6);
  static const Duration _communityImagesCacheDuration = Duration(minutes: 15);

  HomeLocalDataSourceImpl({
    required this.localDb,
    required this.sharedPreferences,
  });

  @override
  Future<void> cacheMovies({required Movies movies}) async {
    await localDb.getDb().writeTxn(() async {
      final cached = await localDb
          .getDb()
          .movies
          .filter()
          .typeEqualTo(movies.type)
          .pageEqualTo(movies.page)
          .findFirst();
      if (cached == null) {
        await localDb.getDb().movies.put(movies);
      } else {
        await localDb.getDb().movies.put(movies.copyWith(id: cached.id));
      }
    });
  }

  @override
  Future<void> cacheGenres({required Genres genres}) async {
    await localDb.getDb().writeTxn(() async {
      await localDb.getDb().genres.put(genres);
    });
  }

  @override
  Future<Either<AppException, Genres>> getGenreCache() async {
    final cachedGenres = await localDb.getDb().genres.where().findFirst();
    if (cachedGenres == null) {
      return Left(AppException(
          message: 'Genre not cached',
          statusCode: 0,
          identifier: 'genres',
          which: 'cache'));
    } else {
      return Right(cachedGenres);
    }
  }

  @override
  Future<Either<AppException, Movies>> getCacheMovies(
      {required String type}) async {
    final movies = await localDb
        .getDb()
        .movies
        .filter()
        .typeEqualTo(type)
        .pageEqualTo(0) // Cache on 0 page
        .findFirst();
    if (movies == null) {
      return Left(AppException(
          message: 'Cache not Found',
          statusCode: 0,
          identifier: type,
          which: 'cache'));
    } else {
      return Right(movies);
    }
  }

  // New AI Image Generator methods

  @override
  Future<void> cacheTrendingStyles({required List<StyleDto> styles}) async {
    final jsonList = styles.map((style) => style.toJson()).toList();
    await sharedPreferences.setString(_trendingStylesKey, json.encode(jsonList));
    await sharedPreferences.setInt(
      _trendingStylesTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<StyleDto>?> getCachedTrendingStyles() async {
    final timestamp = sharedPreferences.getInt(_trendingStylesTimestampKey);
    if (timestamp == null) return null;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    if (now.difference(cachedTime) > _stylesCacheDuration) {
      // Cache expired
      return null;
    }

    final jsonString = sharedPreferences.getString(_trendingStylesKey);
    if (jsonString == null) return null;

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => StyleDto.fromJson(json)).toList();
  }

  @override
  Future<void> cacheTemplates({required List<TemplateDto> templates}) async {
    final jsonList = templates.map((template) => template.toJson()).toList();
    await sharedPreferences.setString(_templatesKey, json.encode(jsonList));
    await sharedPreferences.setInt(
      _templatesTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<TemplateDto>?> getCachedTemplates() async {
    final timestamp = sharedPreferences.getInt(_templatesTimestampKey);
    if (timestamp == null) return null;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    if (now.difference(cachedTime) > _templatesCacheDuration) {
      // Cache expired
      return null;
    }

    final jsonString = sharedPreferences.getString(_templatesKey);
    if (jsonString == null) return null;

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => TemplateDto.fromJson(json)).toList();
  }

  @override
  Future<void> cacheCommunityImages({
    required List<CommunityImageDto> images,
    required String category,
    required int page,
  }) async {
    final key = _getCommunityImagesKey(category, page);
    final timestampKey = '${key}_timestamp';

    final jsonList = images.map((image) => image.toJson()).toList();
    await sharedPreferences.setString(key, json.encode(jsonList));
    await sharedPreferences.setInt(
      timestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<List<CommunityImageDto>?> getCachedCommunityImages({
    required String category,
    required int page,
  }) async {
    final key = _getCommunityImagesKey(category, page);
    final timestampKey = '${key}_timestamp';

    final timestamp = sharedPreferences.getInt(timestampKey);
    if (timestamp == null) return null;

    final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    if (now.difference(cachedTime) > _communityImagesCacheDuration) {
      // Cache expired
      return null;
    }

    final jsonString = sharedPreferences.getString(key);
    if (jsonString == null) return null;

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => CommunityImageDto.fromJson(json)).toList();
  }

  @override
  Future<void> clearCommunityImagesCache() async {
    final keys = sharedPreferences.getKeys();
    for (final key in keys) {
      if (key.startsWith(_communityImagesKeyPrefix)) {
        await sharedPreferences.remove(key);
      }
    }
  }

  String _getCommunityImagesKey(String category, int page) {
    return '${_communityImagesKeyPrefix}_${category}_$page';
  }
}
