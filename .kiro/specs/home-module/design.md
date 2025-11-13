# Design Document - Home Module

## Overview

The Home module serves as the main dashboard of the application, providing quick access to image generation, trending styles, templates, and community content. It includes the bottom navigation system that connects all major features.

## Architecture

### Module Structure

```
lib/
├── features/
│   └── home/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── home_remote_datasource.dart
│       │   │   └── home_local_datasource.dart
│       │   ├── models/
│       │   │   ├── style_dto.dart
│       │   │   ├── template_dto.dart
│       │   │   └── community_image_dto.dart
│       │   └── repositories/
│       │       └── home_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── style.dart
│       │   │   ├── template.dart
│       │   │   └── community_image.dart
│       │   ├── repositories/
│       │   │   └── home_repository.dart
│       │   └── usecases/
│       │       ├── get_trending_styles_usecase.dart
│       │       ├── get_templates_usecase.dart
│       │       └── get_community_images_usecase.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── home_bloc.dart
│           │   ├── home_event.dart
│           │   └── home_state.dart
│           ├── screens/
│           │   ├── home_screen.dart
│           │   └── main_shell.dart
│           └── widgets/
│               ├── image_generator_card.dart
│               ├── style_card.dart
│               ├── template_card.dart
│               ├── community_image_grid.dart
│               ├── category_filter_chips.dart
│               └── bottom_nav_bar.dart
```

## Components and Interfaces

### Domain Layer

#### Entities

```dart
enum StyleType {
  none,
  photo,
  anime,
  illustration,
  popArt,
  abstract,
  fantasy,
  comic,
}

@freezed
class Style with _$Style {
  const factory Style({
    required String id,
    required String name,
    required StyleType type,
    required String previewImageUrl,
    required int usageCount,
  }) = _Style;
}

@freezed
class Template with _$Template {
  const factory Template({
    required String id,
    required String name,
    required String prompt,
    required String previewImageUrl,
    required StyleType style,
    required String category,
  }) = _Template;
}

@freezed
class CommunityImage with _$CommunityImage {
  const factory CommunityImage({
    required String id,
    required String imageUrl,
    required String prompt,
    required String artistName,
    required String artistAvatarUrl,
    required int likes,
    required String category,
    required DateTime createdAt,
  }) = _CommunityImage;
}
```

#### Repository Interface

```dart
abstract class HomeRepository {
  Future<Either<Failure, List<Style>>> getTrendingStyles();

  Future<Either<Failure, List<Template>>> getTemplates({
    int limit = 10,
  });

  Future<Either<Failure, List<CommunityImage>>> getCommunityImages({
    String? category,
    int page = 1,
    int limit = 20,
  });
}
```

### Data Layer

#### DTOs

```dart
@freezed
class StyleDto with _$StyleDto {
  const factory StyleDto({
    required String id,
    required String name,
    required String type,
    required String previewImageUrl,
    required int usageCount,
  }) = _StyleDto;

  factory StyleDto.fromJson(Map<String, dynamic> json)
    => _$StyleDtoFromJson(json);

  Style toEntity() => Style(
    id: id,
    name: name,
    type: StyleType.values.firstWhere((e) => e.name == type),
    previewImageUrl: previewImageUrl,
    usageCount: usageCount,
  );
}

@freezed
class TemplateDto with _$TemplateDto {
  const factory TemplateDto({
    required String id,
    required String name,
    required String prompt,
    required String previewImageUrl,
    required String style,
    required String category,
  }) = _TemplateDto;

  factory TemplateDto.fromJson(Map<String, dynamic> json)
    => _$TemplateDtoFromJson(json);

  Template toEntity() => Template(
    id: id,
    name: name,
    prompt: prompt,
    previewImageUrl: previewImageUrl,
    style: StyleType.values.firstWhere((e) => e.name == style),
    category: category,
  );
}

@freezed
class CommunityImageDto with _$CommunityImageDto {
  const factory CommunityImageDto({
    required String id,
    required String imageUrl,
    required String prompt,
    required String artistName,
    required String artistAvatarUrl,
    required int likes,
    required String category,
    required String createdAt,
  }) = _CommunityImageDto;

  factory CommunityImageDto.fromJson(Map<String, dynamic> json)
    => _$CommunityImageDtoFromJson(json);

  CommunityImage toEntity() => CommunityImage(
    id: id,
    imageUrl: imageUrl,
    prompt: prompt,
    artistName: artistName,
    artistAvatarUrl: artistAvatarUrl,
    likes: likes,
    category: category,
    createdAt: DateTime.parse(createdAt),
  );
}
```

### Presentation Layer

#### HomeBloc

**Events**

```dart
@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.loadTrendingStyles() = LoadTrendingStyles;
  const factory HomeEvent.loadTemplates() = LoadTemplates;
  const factory HomeEvent.loadCommunityImages({
    String? category,
    @Default(false) bool loadMore,
  }) = LoadCommunityImages;
  const factory HomeEvent.filterCommunityImages(String category)
    = FilterCommunityImages;
  const factory HomeEvent.refreshHome() = RefreshHome;
}
```

**States**

```dart
@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default([]) List<Style> trendingStyles,
    @Default([]) List<Template> templates,
    @Default([]) List<CommunityImage> communityImages,
    @Default('All') String selectedCategory,
    @Default(false) bool isLoadingStyles,
    @Default(false) bool isLoadingTemplates,
    @Default(false) bool isLoadingCommunity,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasMoreCommunityImages,
    @Default(1) int currentPage,
    String? error,
  }) = _HomeState;
}
```

### UI Components

#### ImageGeneratorCard

```dart
class ImageGeneratorCard extends StatelessWidget {
  final VoidCallback onGenerateTap;

  // Features:
  // - Gradient background (linear from #312A41 to #1E1C2B)
  // - Abstract illustration image
  // - Title: "Image Generator"
  // - Subtitle: "Turn your ideas into stunning images"
  // - "Generate" button with gradient background
  // - Card dimensions: 343x137
  // - Border radius: 12px
}
```

#### StyleCard

```dart
class StyleCard extends StatelessWidget {
  final Style style;
  final VoidCallback onTap;

  // Features:
  // - Dark background (#1E1C28)
  // - Style preview image (70x70)
  // - Style name label below image
  // - Border radius: 8px
  // - Tap gesture to select style
}
```

#### TemplateCard

```dart
class TemplateCard extends StatelessWidget {
  final Template template;
  final VoidCallback onTap;

  // Features:
  // - Template preview image (118x151 or 117x151)
  // - Border radius: 10px
  // - Tap gesture to use template
}
```

#### CommunityImageGrid

```dart
class CommunityImageGrid extends StatelessWidget {
  final List<CommunityImage> images;
  final Function(CommunityImage) onImageTap;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;

  // Features:
  // - Two-column masonry layout
  // - Varying image heights
  // - Lazy loading with pagination
  // - Shimmer loading effect
  // - Pull-to-refresh support
}
```

#### CategoryFilterChips

```dart
class CategoryFilterChips extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  // Features:
  // - Horizontal scrollable chip list
  // - Categories: All, Characters, Photography, Illustrations
  // - Selected chip with gradient background
  // - Unselected chips with border
}
```

#### BottomNavBar

```dart
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int notificationCount;

  // Features:
  // - Four tabs: Home, Explore, Notification, Profile
  // - Active tab with gradient background
  // - Inactive tabs with gray color
  // - Notification badge on Notification tab
  // - Smooth tab switching animation
  // - Blur backdrop effect
  // - Border radius: 100px
}
```

#### MainShell

```dart
class MainShell extends StatelessWidget {
  final Widget child;

  // Features:
  // - Wraps all main screens
  // - Displays BottomNavBar
  // - Maintains navigation state
  // - Handles tab switching
}
```

## Data Flow

### Initial Load Flow

```
App Launch → LoadTrendingStyles Event → GetTrendingStylesUseCase
→ HomeRepository → API Call → StyleDto List → Style List → State Update

LoadTemplates Event → GetTemplatesUseCase → HomeRepository
→ API Call → TemplateDto List → Template List → State Update

LoadCommunityImages Event → GetCommunityImagesUseCase
→ HomeRepository → API Call → CommunityImageDto List
→ CommunityImage List → State Update
```

### Filter Community Images Flow

```
User Tap Filter → FilterCommunityImages Event → Update Selected Category
→ LoadCommunityImages Event with Category → API Call with Filter
→ Filtered Images → State Update
```

### Pagination Flow

```
User Scrolls to Bottom → LoadCommunityImages Event (loadMore: true)
→ Increment Page → API Call with Page Number → Append Images
→ State Update
```

## Caching Strategy

### Trending Styles

- Cache duration: 1 hour
- Cache key: `trending_styles`
- Refresh on pull-to-refresh

### Templates

- Cache duration: 6 hours
- Cache key: `templates`
- Refresh on pull-to-refresh

### Community Images

- Cache duration: 15 minutes
- Cache key: `community_images_{category}_{page}`
- Clear cache on filter change

## Performance Optimization

### Image Loading

- Use `cached_network_image` for all images
- Implement progressive loading
- Preload images for next page
- Use placeholder shimmer during loading

### List Performance

- Use `ListView.builder` for scrollable lists
- Implement pagination (20 items per page)
- Use `AutomaticKeepAliveClientMixin` for tab persistence
- Debounce scroll events for load more

### State Management

- Use `Equatable` for efficient state comparison
- Implement `distinct()` on streams
- Avoid unnecessary rebuilds with `const` constructors

## Error Handling

### Error Types

```dart
@freezed
class HomeFailure with _$HomeFailure {
  const factory HomeFailure.network() = NetworkFailure;
  const factory HomeFailure.server(String message) = ServerFailure;
  const factory HomeFailure.cache() = CacheFailure;
}
```

### Error Messages

- Network error: "Please check your internet connection"
- Server error: "Unable to load content. Please try again"
- Cache error: "Failed to load cached data"

## Testing Strategy

### Unit Tests

- Test HomeBloc state transitions
- Test use cases with mocked repositories
- Test DTO to Entity conversions
- Test pagination logic

### Widget Tests

- Test HomeScreen rendering
- Test ImageGeneratorCard tap
- Test StyleCard selection
- Test TemplateCard tap
- Test CategoryFilterChips selection
- Test BottomNavBar navigation

### Integration Tests

- Test complete home screen load
- Test filter and pagination
- Test navigation between tabs
- Test pull-to-refresh
