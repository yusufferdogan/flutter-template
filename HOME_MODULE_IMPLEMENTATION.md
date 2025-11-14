# Home Module Implementation Plan

## Current Status

The home module foundation has been started with new domain entities for the AI Image Generator application. The existing FilmKu (movie app) home module needs to be transformed or replaced.

## What's Been Created

### ✅ Domain Layer - Entities
- `lib/features/home/domain/entities/style.dart` - Art style entity (Photo, Anime, Illustration, etc.)
- `lib/features/home/domain/entities/template.dart` - Image template entity
- `lib/features/home/domain/entities/community_image.dart` - Community shared image entity
- `lib/features/home/domain/failures/home_failure.dart` - Error handling for home module
- `lib/features/home/domain/repositories/home_repository.dart` - Repository interface (updated)

### 📋 Existing Files (From FilmKu Movie App)
The following files exist but are for the old movie application and need to be updated or replaced:
- Data sources (remote/local)
- Repository implementation
- Use cases (movie/genre related)
- BLoC (movie/genre blocs)
- UI screens and widgets (movie cards, shimmer effects)

## Implementation Tasks

### Phase 1: Data Layer (High Priority)

#### 1.1 Create DTOs
Create `/lib/features/home/data/models/`:
- `style_dto.dart` - Maps to `styles` table in Supabase
- `template_dto.dart` - Maps to `templates` table in Supabase
- `community_image_dto.dart` - Maps to `generated_images` table in Supabase

```dart
// Example: style_dto.dart
class StyleDto {
  final String id;
  final String name;
  final String type;
  final String previewImageUrl;
  final int usageCount;
  final bool isActive;

  // fromJson, toJson, toEntity methods
}
```

#### 1.2 Update HomeRemoteDataSource
File: `lib/features/home/data/datasource/remote/home_remote_datasource.dart`

Replace movie API calls with Supabase queries:
```dart
abstract class HomeRemoteDataSource {
  Future<List<StyleDto>> getTrendingStyles();
  Future<List<TemplateDto>> getTemplates({int limit = 10});
  Future<List<CommunityImageDto>> getCommunityImages({
    String? category,
    int page = 1,
    int limit = 20,
  });
}

class SupabaseHomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient supabase;

  @override
  Future<List<StyleDto>> getTrendingStyles() async {
    final response = await supabase
        .from('styles')
        .select()
        .eq('is_active', true)
        .order('usage_count', ascending: false)
        .limit(4);

    return (response as List)
        .map((json) => StyleDto.fromJson(json))
        .toList();
  }

  // Implement other methods...
}
```

#### 1.3 Update HomeLocalDataSource
File: `lib/features/home/data/datasource/local/home_local_datasource.dart`

Implement caching with Isar or Hive:
```dart
abstract class HomeLocalDataSource {
  Future<List<StyleDto>> getCachedStyles();
  Future<void> cacheStyles(List<StyleDto> styles);
  Future<List<TemplateDto>> getCachedTemplates();
  Future<void> cacheTemplates(List<TemplateDto> templates);
  Future<List<CommunityImageDto>> getCachedCommunityImages(String? category);
  Future<void> cacheCommunityImages(List<CommunityImageDto> images, String? category);
  Future<void> clearCache();
}
```

#### 1.4 Update HomeRepository
File: `lib/features/home/data/repositories/home_repository_impl.dart`

Implement cache-first strategy:
```dart
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;

  @override
  Future<Either<HomeFailure, List<Style>>> getTrendingStyles() async {
    try {
      // Try cache first
      final cachedStyles = await localDataSource.getCachedStyles();
      if (cachedStyles.isNotEmpty) {
        return Right(cachedStyles.map((dto) => dto.toEntity()).toList());
      }

      // Fetch from network
      final styles = await remoteDataSource.getTrendingStyles();
      await localDataSource.cacheStyles(styles);

      return Right(styles.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      return Left(HomeFailure.network());
    }
  }

  // Implement other methods...
}
```

### Phase 2: Domain Layer (High Priority)

#### 2.1 Create Use Cases
Create `/lib/features/home/domain/usecases/`:
- `get_trending_styles_usecase.dart`
- `get_templates_usecase.dart`
- `get_community_images_usecase.dart`

```dart
// Example: get_trending_styles_usecase.dart
class GetTrendingStylesUseCase {
  final HomeRepository repository;

  GetTrendingStylesUseCase(this.repository);

  Future<Either<HomeFailure, List<Style>>> call() {
    return repository.getTrendingStyles();
  }
}
```

### Phase 3: Presentation Layer - State Management

#### 3.1 Create HomeBloc
File: `lib/features/home/presentation/bloc/home/home_bloc.dart`

```dart
// Events
sealed class HomeEvent {
  const HomeEvent();
}

class LoadTrendingStyles extends HomeEvent {}
class LoadTemplates extends HomeEvent {}
class LoadCommunityImages extends HomeEvent {
  final String? category;
  final bool loadMore;

  const LoadCommunityImages({this.category, this.loadMore = false});
}
class FilterCommunityImages extends HomeEvent {
  final String category;
  const FilterCommunityImages(this.category);
}
class RefreshHome extends HomeEvent {}

// State
class HomeState {
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

  // Constructor, copyWith, etc.
}
```

### Phase 4: Presentation Layer - UI Components

#### 4.1 Core Widgets
Create `/lib/features/home/presentation/widgets/`:

**image_generator_card.dart**
- Gradient background card
- Title: "Image Generator"
- Subtitle: "Turn your ideas into stunning images"
- Generate button
- Navigate to prompt screen on tap

**style_card.dart**
- Dark background (#1E1C28)
- 70x70 preview image
- Style name label
- 8px border radius

**template_card.dart**
- 118x151 preview image
- 10px border radius
- Navigate with template data on tap

**community_image_grid.dart**
- Two-column masonry layout
- Lazy loading with pagination
- Pull-to-refresh
- Shimmer loading

**category_filter_chips.dart**
- Chips: All, Characters, Photography, Illustrations
- Gradient background for selected
- Border for unselected

**bottom_nav_bar.dart**
- 4 tabs: Home, Explore, Notification, Profile
- Gradient background for active tab
- Notification badge support
- 100px border radius

#### 4.2 Main Screens

**home_screen.dart**
- Scrollable page with gradient background
- Image Generator Card (top)
- "Try Trend Styles" section with 4 style cards
- "Image Template" section with horizontal scroll
- "Get Inspired from Community" with filter chips and grid
- Pull-to-refresh
- Loading/error states

**main_shell.dart**
- Bottom navigation wrapper
- IndexedStack to preserve tab state
- Tab switching logic

### Phase 5: Integration & Navigation

#### 5.1 Update Dependency Injection
File: `lib/di/Injector.dart`

```dart
void provideDataSources() {
  // Home
  injector.registerFactory<HomeLocalDataSource>(
      () => HomeLocalDataSourceImpl(localDb: injector.get<LocalDb>()));
  injector.registerFactory<HomeRemoteDataSource>(
      () => SupabaseHomeRemoteDataSourceImpl(
          supabase: SupabaseConfig.client));
}

void provideRepositories() {
  injector.registerFactory<HomeRepository>(() => HomeRepositoryImpl(
      homeRemoteDataSource: injector.get<HomeRemoteDataSource>(),
      homeLocalDataSource: injector.get<HomeLocalDataSource>()));
}

void provideUseCases() {
  injector.registerFactory<GetTrendingStylesUseCase>(
      () => GetTrendingStylesUseCase(injector.get<HomeRepository>()));
  injector.registerFactory<GetTemplatesUseCase>(
      () => GetTemplatesUseCase(injector.get<HomeRepository>()));
  injector.registerFactory<GetCommunityImagesUseCase>(
      () => GetCommunityImagesUseCase(injector.get<HomeRepository>()));
}

void provideBlocs() {
  injector.registerFactory<HomeBloc>(() => HomeBloc(
      getTrendingStylesUseCase: injector.get<GetTrendingStylesUseCase>(),
      getTemplatesUseCase: injector.get<GetTemplatesUseCase>(),
      getCommunityImagesUseCase: injector.get<GetCommunityImagesUseCase>()));
}
```

#### 5.2 Update Routing
Configure GoRouter with MainShell and bottom navigation.

### Phase 6: Supabase Integration

#### 6.1 Query Examples

**Get Trending Styles:**
```dart
final styles = await supabase
    .from('styles')
    .select()
    .eq('is_active', true)
    .order('usage_count', ascending: false)
    .limit(4);
```

**Get Templates:**
```dart
final templates = await supabase
    .from('templates')
    .select()
    .eq('is_active', true)
    .limit(limit);
```

**Get Community Images:**
```dart
var query = supabase
    .from('generated_images')
    .select('*, users!inner(full_name, profile_image_url)')
    .eq('is_public', true)
    .order('created_at', ascending: false);

if (category != null && category != 'All') {
  query = query.eq('category', category);
}

final images = await query
    .range((page - 1) * limit, page * limit - 1);
```

### Phase 7: Testing

#### 7.1 Unit Tests
- Test domain entities
- Test use cases with mocked repositories
- Test BLoC state transitions
- Test DTO to Entity conversions

#### 7.2 Widget Tests
- Test each UI component
- Test navigation handlers
- Test loading/error states

#### 7.3 Integration Tests
- Test complete home screen flow
- Test filter and pagination
- Test tab navigation

## Migration Strategy

### Option A: Replace Existing Module
1. Backup old home module files
2. Delete old movie-related code
3. Implement new AI image generator home module

### Option B: Coexist Temporarily
1. Keep old movie home in different namespace
2. Implement new home module
3. Switch routing to new module
4. Delete old module when stable

**Recommended: Option A** - Clean slate for new app identity

## Progress Tracking

### ✅ Completed
- Domain entities (Style, Template, CommunityImage)
- HomeFailure error handling
- HomeRepository interface

### 🚧 In Progress
- Data layer DTOs
- Data sources implementation

### ⏳ Pending
- Repository implementation
- Use cases
- BLoC implementation
- UI components
- Navigation setup
- Testing

## Quick Start Guide

To continue implementation:

1. **Create DTOs** (Priority 1)
   ```bash
   # Create models directory
   mkdir -p lib/features/home/data/models
   # Implement StyleDto, TemplateDto, CommunityImageDto
   ```

2. **Update Data Sources** (Priority 2)
   - Replace movie API calls with Supabase queries
   - Implement caching strategy

3. **Create Use Cases** (Priority 3)
   - Simple wrapper classes around repository methods

4. **Implement BLoC** (Priority 4)
   - Define events and states
   - Implement event handlers

5. **Build UI** (Priority 5)
   - Start with ImageGeneratorCard
   - Build other widgets incrementally
   - Assemble HomeScreen

6. **Test & Integrate** (Priority 6)
   - Unit tests
   - Widget tests
   - Update routing

## Architecture Diagram

```
┌─────────────────────────────────────────────┐
│         Presentation Layer                  │
│  ┌────────────┐  ┌─────────────────────┐   │
│  │  HomeBloc  │  │   UI Components     │   │
│  └────────────┘  │ - HomeScreen        │   │
│         │        │ - Widgets           │   │
│         │        │ - BottomNavBar      │   │
│         ▼        └─────────────────────┘   │
│  ┌────────────┐                            │
│  │ Use Cases  │                            │
│  └────────────┘                            │
└─────────────┬───────────────────────────────┘
              │
┌─────────────▼───────────────────────────────┐
│         Domain Layer                        │
│  ┌────────────────────────────────────┐    │
│  │  HomeRepository (interface)        │    │
│  └────────────────────────────────────┘    │
│  ┌────────────────────────────────────┐    │
│  │  Entities: Style, Template, etc.  │    │
│  └────────────────────────────────────┘    │
└─────────────┬───────────────────────────────┘
              │
┌─────────────▼───────────────────────────────┐
│         Data Layer                          │
│  ┌────────────────────────────────────┐    │
│  │  HomeRepositoryImpl                │    │
│  └────────────────────────────────────┘    │
│         │                    │              │
│         ▼                    ▼              │
│  ┌─────────────┐      ┌──────────────┐    │
│  │   Remote    │      │    Local     │    │
│  │ DataSource  │      │  DataSource  │    │
│  │ (Supabase)  │      │   (Cache)    │    │
│  └─────────────┘      └──────────────┘    │
└─────────────────────────────────────────────┘
```

## Resources

- [Home Module Requirements](/.kiro/specs/home-module/requirements.md)
- [Home Module Design](/.kiro/specs/home-module/design.md)
- [Home Module Tasks](/.kiro/specs/home-module/tasks.md)
- [Supabase Integration Guide](/SUPABASE_INTEGRATION.md)
- [Supabase Setup Guide](/supabase/README.md)

## Notes

- Use `cached_network_image` for all images
- Implement proper error handling at each layer
- Follow the existing clean architecture pattern
- Maintain backward compatibility during migration
- Test thoroughly before removing old code
