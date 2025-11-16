import 'package:dartz/dartz.dart';
import 'package:filmku/features/home/data/datasource/remote/home_remote_data_source.dart';
import 'package:filmku/models/response/genre_response.dart';
import 'package:filmku/models/response/movies_response.dart';
import 'package:filmku/shared/network/network_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:filmku/shared/network/network_values.dart';
import 'package:filmku/shared/util/app_exception.dart';
import '../../models/style_dto.dart';
import '../../models/template_dto.dart';
import '../../models/community_image_dto.dart';

class HomeRemoteDataSourceImpl extends HomeRemoteDataSource {
  final NetworkService networkService;
  final SupabaseClient supabaseClient;

  HomeRemoteDataSourceImpl({
    required this.networkService,
    required this.supabaseClient,
  });

  @override
  Future<Either<AppException, MoviesResponse>> getMovies(
      {required String endPoint, required int page}) async {
    final response = await networkService.get(endPoint, queryParams: {
      Params.page: page,
    });

    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null) {
        return Left(
          AppException(
              identifier: endPoint,
              statusCode: 0,
              message: 'The data is not in the valid format',
              which: 'http'),
        );
      }
      final moviesResponse =
          MoviesResponse.fromJson(jsonData, jsonData['results'] ?? []);
      return Right(moviesResponse);
    });
  }

  @override
  Future<Either<AppException, GenreResponse>> getGenre() async {
    final response = await networkService.get(EndPoints.genre);
    return response.fold((l) => Left(l), (r) {
      final jsonData = r.data;
      if (jsonData == null) {
        return Left(AppException(
            identifier: EndPoints.genre,
            statusCode: 0,
            message: 'The data is not in the valid format',
            which: 'http'));
      }
      final genresResponse = GenreResponse(jsonData['genres'] ?? []);
      return Right(genresResponse);
    });
  }

  // New AI Image Generator methods

  @override
  Future<List<StyleDto>> getTrendingStyles() async {
    try {
      final response = await supabaseClient
          .from('trending_styles')
          .select()
          .order('usage_count', ascending: false)
          .limit(4);

      return (response as List)
          .map((json) => StyleDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch trending styles: $e');
    }
  }

  @override
  Future<List<TemplateDto>> getTemplates({int limit = 10}) async {
    try {
      final response = await supabaseClient
          .from('templates')
          .select()
          .limit(limit);

      return (response as List)
          .map((json) => TemplateDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch templates: $e');
    }
  }

  @override
  Future<List<CommunityImageDto>> getCommunityImages({
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final offset = (page - 1) * limit;

      var query = supabaseClient
          .from('community_images')
          .select();

      // Apply filter before ordering
      if (category != null && category.toLowerCase() != 'all') {
        query = query.eq('category', category);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) =>
              CommunityImageDto.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch community images: $e');
    }
  }
}
