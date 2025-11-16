part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadTrendingStyles extends HomeEvent {
  const LoadTrendingStyles();
}

class LoadTemplates extends HomeEvent {
  const LoadTemplates();
}

class LoadCommunityImages extends HomeEvent {
  final String? category;
  final bool loadMore;

  const LoadCommunityImages({
    this.category,
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [category, loadMore];
}

class FilterCommunityImages extends HomeEvent {
  final String category;

  const FilterCommunityImages(this.category);

  @override
  List<Object?> get props => [category];
}

class RefreshHome extends HomeEvent {
  const RefreshHome();
}
