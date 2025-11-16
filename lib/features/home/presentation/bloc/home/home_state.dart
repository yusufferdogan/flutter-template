part of 'home_bloc.dart';

class HomeState extends Equatable {
  final List<Style> trendingStyles;
  final List<Template> templates;
  final List<CommunityImage> communityImages;
  final String selectedCategory;
  final bool isLoadingStyles;
  final bool isLoadingTemplates;
  final bool isLoadingCommunity;
  final bool isLoadingMore;
  final bool hasMoreCommunityImages;
  final int currentPage;
  final String? error;

  const HomeState({
    this.trendingStyles = const [],
    this.templates = const [],
    this.communityImages = const [],
    this.selectedCategory = 'All',
    this.isLoadingStyles = false,
    this.isLoadingTemplates = false,
    this.isLoadingCommunity = false,
    this.isLoadingMore = false,
    this.hasMoreCommunityImages = true,
    this.currentPage = 1,
    this.error,
  });

  HomeState copyWith({
    List<Style>? trendingStyles,
    List<Template>? templates,
    List<CommunityImage>? communityImages,
    String? selectedCategory,
    bool? isLoadingStyles,
    bool? isLoadingTemplates,
    bool? isLoadingCommunity,
    bool? isLoadingMore,
    bool? hasMoreCommunityImages,
    int? currentPage,
    String? error,
  }) {
    return HomeState(
      trendingStyles: trendingStyles ?? this.trendingStyles,
      templates: templates ?? this.templates,
      communityImages: communityImages ?? this.communityImages,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoadingStyles: isLoadingStyles ?? this.isLoadingStyles,
      isLoadingTemplates: isLoadingTemplates ?? this.isLoadingTemplates,
      isLoadingCommunity: isLoadingCommunity ?? this.isLoadingCommunity,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreCommunityImages:
          hasMoreCommunityImages ?? this.hasMoreCommunityImages,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        trendingStyles,
        templates,
        communityImages,
        selectedCategory,
        isLoadingStyles,
        isLoadingTemplates,
        isLoadingCommunity,
        isLoadingMore,
        hasMoreCommunityImages,
        currentPage,
        error,
      ];
}
