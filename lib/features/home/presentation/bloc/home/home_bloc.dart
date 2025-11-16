import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/community_image.dart';
import '../../../domain/entities/style.dart';
import '../../../domain/entities/template.dart';
import '../../../domain/use_cases/get_community_images_usecase.dart';
import '../../../domain/use_cases/get_templates_usecase.dart';
import '../../../domain/use_cases/get_trending_styles_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetTrendingStylesUseCase getTrendingStylesUseCase;
  final GetTemplatesUseCase getTemplatesUseCase;
  final GetCommunityImagesUseCase getCommunityImagesUseCase;

  HomeBloc({
    required this.getTrendingStylesUseCase,
    required this.getTemplatesUseCase,
    required this.getCommunityImagesUseCase,
  }) : super(const HomeState()) {
    on<LoadTrendingStyles>(_onLoadTrendingStyles);
    on<LoadTemplates>(_onLoadTemplates);
    on<LoadCommunityImages>(_onLoadCommunityImages);
    on<FilterCommunityImages>(_onFilterCommunityImages);
    on<RefreshHome>(_onRefreshHome);
  }

  Future<void> _onLoadTrendingStyles(
    LoadTrendingStyles event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingStyles: true, error: null));

    final result = await getTrendingStylesUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingStyles: false,
        error: failure.toMessage(),
      )),
      (styles) => emit(state.copyWith(
        trendingStyles: styles,
        isLoadingStyles: false,
        error: null,
      )),
    );
  }

  Future<void> _onLoadTemplates(
    LoadTemplates event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoadingTemplates: true, error: null));

    final result = await getTemplatesUseCase();

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingTemplates: false,
        error: failure.toMessage(),
      )),
      (templates) => emit(state.copyWith(
        templates: templates,
        isLoadingTemplates: false,
        error: null,
      )),
    );
  }

  Future<void> _onLoadCommunityImages(
    LoadCommunityImages event,
    Emitter<HomeState> emit,
  ) async {
    if (event.loadMore) {
      if (!state.hasMoreCommunityImages || state.isLoadingMore) {
        return;
      }
      emit(state.copyWith(isLoadingMore: true));
    } else {
      emit(state.copyWith(
        isLoadingCommunity: true,
        error: null,
        currentPage: 1,
      ));
    }

    final page = event.loadMore ? state.currentPage + 1 : 1;
    final category = event.category ?? state.selectedCategory;

    final result = await getCommunityImagesUseCase(
      category: category == 'All' ? null : category,
      page: page,
      limit: 20,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingCommunity: false,
        isLoadingMore: false,
        error: failure.toMessage(),
      )),
      (images) {
        final hasMore = images.length >= 20;
        final updatedImages = event.loadMore
            ? [...state.communityImages, ...images]
            : images;

        emit(state.copyWith(
          communityImages: updatedImages,
          isLoadingCommunity: false,
          isLoadingMore: false,
          hasMoreCommunityImages: hasMore,
          currentPage: page,
          error: null,
        ));
      },
    );
  }

  Future<void> _onFilterCommunityImages(
    FilterCommunityImages event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      selectedCategory: event.category,
      communityImages: [],
      currentPage: 1,
      hasMoreCommunityImages: true,
    ));

    add(LoadCommunityImages(category: event.category));
  }

  Future<void> _onRefreshHome(
    RefreshHome event,
    Emitter<HomeState> emit,
  ) async {
    // Reset state
    emit(const HomeState());

    // Load all data
    add(const LoadTrendingStyles());
    add(const LoadTemplates());
    add(const LoadCommunityImages());
  }
}
