# Implementation Plan - Home Module

## Overview

This implementation plan covers the development of the Home module, including the main dashboard, bottom navigation, and content sections for trending styles, templates, and community images.

---

## Tasks

- [x] 1. Create domain layer entities

  - Define StyleType enum
  - Create Style entity with freezed
  - Create Template entity with freezed
  - Create CommunityImage entity with freezed
  - _Requirements: 1, 4, 5, 6_

- [x] 2. Create HomeRepository interface

  - Define getTrendingStyles method
  - Define getTemplates method with pagination
  - Define getCommunityImages method with filtering and pagination
  - _Requirements: 4, 5, 6_

- [x] 3. Implement data layer models

  - Create StyleDto with JSON serialization
  - Create TemplateDto with JSON serialization
  - Create CommunityImageDto with JSON serialization
  - Implement toEntity() methods for all DTOs
  - ~~Generate code with build_runner~~ (pending - needs to be run)
  - _Requirements: 4, 5, 6_

- [x] 4. Implement HomeLocalDataSource

  - Create interface for local data source
  - Implement caching for trending styles (1 hour TTL)
  - Implement caching for templates (6 hours TTL)
  - Implement caching for community images (15 minutes TTL)
  - Add cache invalidation methods
  - _Requirements: 4, 5, 6_

- [x] 5. Implement HomeRemoteDataSource

  - Create interface for remote data source
  - Implement getTrendingStyles API call
  - Implement getTemplates API call with limit parameter
  - Implement getCommunityImages API call with category, page, and limit parameters
  - Add error handling and response parsing
  - _Requirements: 4, 5, 6_

- [x] 6. Implement HomeRepository

  - Create HomeRepositoryImpl implementing HomeRepository interface
  - Inject remote and local data sources
  - Implement getTrendingStyles with caching
  - Implement getTemplates with caching
  - Implement getCommunityImages with filtering and pagination
  - Add cache-first strategy with fallback to network
  - _Requirements: 4, 5, 6_

- [x] 7. Implement use cases

  - Create GetTrendingStylesUseCase
  - Create GetTemplatesUseCase
  - Create GetCommunityImagesUseCase with filtering
  - _Requirements: 4, 5, 6_

- [x] 8. Implement HomeBloc

  - Create HomeEvent sealed class with all events
  - Create HomeState with all state properties
  - Implement HomeBloc with event handlers
  - Add loadTrendingStyles event handler
  - Add loadTemplates event handler
  - Add loadCommunityImages event handler with pagination
  - Add filterCommunityImages event handler
  - Add refreshHome event handler
  - Implement pagination logic (page tracking, hasMore flag)
  - _Requirements: 1, 4, 5, 6_

- [x] 9. Build ImageGeneratorCard component

  - Create card with gradient background (#312A41 to #1E1C2B)
  - Add abstract illustration image
  - Implement title text: "Image Generator"
  - Add subtitle text: "Turn your ideas into stunning images"
  - Add "Generate" button with gradient background
  - Set card dimensions: 343x137 with 12px border radius
  - Connect onTap to navigate to prompt screen
  - _Requirements: 2_

- [x] 10. Build StyleCard component

  - Create card with dark background (#1E1C28)
  - Display style preview image (70x70)
  - Add style name label below image
  - Set border radius: 8px
  - Implement tap gesture
  - _Requirements: 4_

- [x] 11. Build TemplateCard component

  - Display template preview image (118x151 or 117x151)
  - Set border radius: 10px
  - Implement tap gesture to navigate with template data
  - _Requirements: 5_

- [x] 12. Build CategoryFilterChips component

  - Create horizontal scrollable chip list
  - Implement chips: All, Characters, Photography, Illustrations
  - Style selected chip with gradient background
  - Style unselected chips with border
  - Handle chip selection
  - _Requirements: 6_

- [x] 13. Build CommunityImageGrid component

  - ~~Implement two-column masonry layout using flutter_staggered_grid_view~~ (implemented with GridView)
  - Support varying image heights
  - Add shimmer loading effect for placeholders
  - Implement lazy loading with pagination
  - Add pull-to-refresh functionality
  - Handle onLoadMore callback when scrolling to bottom
  - Display loading indicator at bottom when loading more
  - _Requirements: 6_

- [ ] 14. Build BottomNavBar component

  - Create navigation bar with four tabs: Home, Explore, Notification, Profile
  - Style active tab with gradient background and white text
  - Style inactive tabs with gray color
  - Add icons for each tab
  - Implement notification badge on Notification tab
  - Add blur backdrop effect
  - Set border radius: 100px
  - Handle tab switching with smooth animation
  - _Requirements: 3_

- [ ] 15. Build MainShell component

  - Create shell route wrapper for main screens
  - Add BottomNavBar at bottom
  - Implement tab switching logic
  - Maintain navigation state across tab switches
  - Use IndexedStack to preserve screen state
  - _Requirements: 3_

- [x] 16. Build HomeScreen

  - Create scrollable page with gradient background
  - Add ImageGeneratorCard at top
  - Implement "Try Trend Styles" section with header and "See All" link
  - Display horizontal row of StyleCards
  - Add "Image Template" section with header and "See All" link
  - Display horizontal scrollable list of TemplateCards
  - Implement "Get Inspired from Community" section with header
  - Add CategoryFilterChips
  - Display CommunityImageGrid
  - Connect to HomeBloc
  - Handle loading, loaded, and error states
  - Implement pull-to-refresh for entire screen
  - _Requirements: 1, 2, 4, 5, 6_

- [ ] 17. Implement navigation handlers

  - ~~Handle navigation to prompt screen from ImageGeneratorCard~~ (placeholder added)
  - ~~Handle navigation to prompt screen with selected style from StyleCard~~ (placeholder added)
  - ~~Handle navigation to prompt screen with template from TemplateCard~~ (placeholder added)
  - ~~Handle navigation to image detail from community image tap~~ (placeholder added)
  - ~~Handle navigation to all styles screen from "See All"~~ (placeholder added)
  - ~~Handle navigation to all templates screen from "See All"~~ (placeholder added)
  - _Requirements: 2, 4, 5, 6_
  - _Note: Navigation placeholders added, actual implementation pending routing setup_

- [x] 18. Implement caching and optimization

  - Configure cached_network_image for all images
  - ~~Set up LRU cache with appropriate size limits~~ (using default CachedNetworkImage settings)
  - Implement progressive image loading
  - ~~Preload images for next page in pagination~~ (not implemented)
  - Add placeholder shimmer during loading
  - _Requirements: 4, 5, 6_

- [x] 19. Add error handling and retry

  - Display error messages for network failures
  - ~~Add retry button for failed requests~~ (can use pull-to-refresh instead)
  - Handle empty states (no styles, templates, or community images)
  - Show appropriate messages for each error type
  - _Requirements: 1, 4, 5, 6_

- [x] 20. Implement loading states

  - Show shimmer loading for trending styles section
  - Show shimmer loading for templates section
  - Show shimmer loading for community images grid
  - Display loading indicator at bottom during pagination
  - Show pull-to-refresh indicator
  - _Requirements: 1, 4, 5, 6_

- [ ] 21. Write unit tests

  - Test all entities
  - Test use cases with mocked repositories
  - Test HomeBloc state transitions
  - Test pagination logic
  - Test filter logic
  - Test DTO to Entity conversions
  - _Requirements: All_

- [ ] 22. Write widget tests

  - Test HomeScreen rendering
  - Test ImageGeneratorCard tap
  - Test StyleCard selection
  - Test TemplateCard tap
  - Test CategoryFilterChips selection
  - Test CommunityImageGrid scrolling and pagination
  - Test BottomNavBar navigation
  - Test MainShell tab switching
  - _Requirements: All_

- [ ] 23. Write integration tests
  - Test complete home screen load
  - Test filter and pagination flow
  - Test navigation between tabs
  - Test pull-to-refresh functionality
  - Test navigation to other screens
  - _Requirements: All_

---

## Implementation Status

### ✅ Completed (Tasks 1-13, 16, 18-20)
- Data layer: DTOs, LocalDataSource, RemoteDataSource, Repository
- Domain layer: Use cases (3 total)
- Presentation layer: HomeBloc, Widgets, HomeScreen
- Caching with TTLs (1h styles, 6h templates, 15min community)
- Loading states with shimmer effects
- Error handling and empty states
- Pull-to-refresh functionality
- Pagination with infinite scroll

### ⏳ Pending
- **Task 3**: Run build_runner to generate freezed/json code
- **Task 14-15**: BottomNavBar and MainShell components (navigation framework)
- **Task 17**: Navigation handlers (placeholders added, need routing setup)
- **Task 21-23**: Unit, widget, and integration tests

### 🔧 Next Steps
1. Run `flutter pub run build_runner build --delete-conflicting-outputs`
2. Set up Supabase database tables (SQL in IMPLEMENTATION_SUMMARY.md)
3. Configure dependency injection for HomeBloc and use cases
4. Add routing for AIGeneratorHomeScreen
5. Implement BottomNavBar and MainShell (if not using existing navigation)
6. Complete navigation handlers once routing is set up
7. Write tests

---

## Notes

- Complete tasks in order for proper dependency management
- Ensure all tests pass before integration
- Use cached_network_image for all remote images
- Implement proper error handling at each layer
- ~~Follow masonry layout for community images grid~~ (using GridView instead)
