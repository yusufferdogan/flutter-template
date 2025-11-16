# Implementation Plan - Home Module

## Overview

This implementation plan covers the development of the Home module, including the main dashboard, bottom navigation, and content sections for trending styles, templates, and community images.

## Progress Summary

**Overall Progress: 2.5 / 23 tasks (10.9%)**

| Phase | Tasks | Status |
|-------|-------|--------|
| Domain Layer | 2 / 2 | ✅ Complete |
| Data Layer | 0.5 / 3 | 🚧 In Progress |
| Use Cases | 0 / 1 | ⏳ Pending |
| State Management | 0 / 1 | ⏳ Pending |
| UI Components | 0 / 8 | ⏳ Pending |
| Navigation | 0 / 1 | ⏳ Pending |
| Integration | 0 / 3 | ⏳ Pending |
| Testing | 0 / 3 | ⏳ Pending |

**Recently Completed:**
- ✅ Domain entities (Style, Template, CommunityImage, HomeFailure)
- ✅ HomeRepository interface with backward compatibility
- 🚧 HomeRepositoryImpl structure (stubs pending implementation)

**Next Steps:**
- [ ] Implement data layer DTOs (Task 3)
- [ ] Implement HomeRemoteDataSource with Supabase (Task 5)
- [ ] Implement HomeLocalDataSource with caching (Task 4)

---

## Tasks

- [x] 1. Create domain layer entities

  - ✅ Define StyleType enum
  - ✅ Create Style entity (manual implementation, not freezed)
  - ✅ Create Template entity (manual implementation, not freezed)
  - ✅ Create CommunityImage entity (manual implementation, not freezed)
  - ✅ Create HomeFailure sealed class for error handling
  - _Requirements: 1, 4, 5, 6_
  - _Completed: lib/features/home/domain/entities/_
  - _Note: Used manual implementation instead of freezed for consistency_

- [x] 2. Create HomeRepository interface

  - ✅ Define getTrendingStyles method
  - ✅ Define getTemplates method with pagination
  - ✅ Define getCommunityImages method with filtering and pagination
  - ✅ Maintain backward compatibility with legacy movie methods
  - _Requirements: 4, 5, 6_
  - _Completed: lib/features/home/domain/repositories/home_repository.dart_
  - _Note: Added both new AI methods and legacy FilmKu methods_

- [ ] 3. Implement data layer models

  - Create StyleDto with JSON serialization
  - Create TemplateDto with JSON serialization
  - Create CommunityImageDto with JSON serialization
  - Implement toEntity() methods for all DTOs
  - Generate code with build_runner
  - _Requirements: 4, 5, 6_

- [ ] 4. Implement HomeLocalDataSource

  - Create interface for local data source
  - Implement caching for trending styles (1 hour TTL)
  - Implement caching for templates (6 hours TTL)
  - Implement caching for community images (15 minutes TTL)
  - Add cache invalidation methods
  - _Requirements: 4, 5, 6_

- [ ] 5. Implement HomeRemoteDataSource

  - Create interface for remote data source
  - Implement getTrendingStyles API call
  - Implement getTemplates API call with limit parameter
  - Implement getCommunityImages API call with category, page, and limit parameters
  - Add error handling and response parsing
  - _Requirements: 4, 5, 6_

- [~] 6. Implement HomeRepository

  - ✅ Create HomeRepositoryImpl implementing HomeRepository interface
  - ✅ Inject remote and local data sources
  - ⏳ Implement getTrendingStyles with caching (stub with UnimplementedError)
  - ⏳ Implement getTemplates with caching (stub with UnimplementedError)
  - ⏳ Implement getCommunityImages with filtering and pagination (stub with UnimplementedError)
  - ⏳ Add cache-first strategy with fallback to network
  - ✅ Maintain legacy movie methods implementation
  - _Requirements: 4, 5, 6_
  - _Status: Partially completed - structure ready, implementation pending Phase 1_
  - _Completed: lib/features/home/data/repositories/home_repository_impl.dart_
  - _Note: Stub implementations added with UnimplementedError for new AI methods_

- [ ] 7. Implement use cases

  - Create GetTrendingStylesUseCase
  - Create GetTemplatesUseCase
  - Create GetCommunityImagesUseCase with filtering
  - _Requirements: 4, 5, 6_

- [ ] 8. Implement HomeBloc

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

- [ ] 9. Build ImageGeneratorCard component

  - Create card with gradient background (#312A41 to #1E1C2B)
  - Add abstract illustration image
  - Implement title text: "Image Generator"
  - Add subtitle text: "Turn your ideas into stunning images"
  - Add "Generate" button with gradient background
  - Set card dimensions: 343x137 with 12px border radius
  - Connect onTap to navigate to prompt screen
  - _Requirements: 2_

- [ ] 10. Build StyleCard component

  - Create card with dark background (#1E1C28)
  - Display style preview image (70x70)
  - Add style name label below image
  - Set border radius: 8px
  - Implement tap gesture
  - _Requirements: 4_

- [ ] 11. Build TemplateCard component

  - Display template preview image (118x151 or 117x151)
  - Set border radius: 10px
  - Implement tap gesture to navigate with template data
  - _Requirements: 5_

- [ ] 12. Build CategoryFilterChips component

  - Create horizontal scrollable chip list
  - Implement chips: All, Characters, Photography, Illustrations
  - Style selected chip with gradient background
  - Style unselected chips with border
  - Handle chip selection
  - _Requirements: 6_

- [ ] 13. Build CommunityImageGrid component

  - Implement two-column masonry layout using flutter_staggered_grid_view
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

- [ ] 16. Build HomeScreen

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

  - Handle navigation to prompt screen from ImageGeneratorCard
  - Handle navigation to prompt screen with selected style from StyleCard
  - Handle navigation to prompt screen with template from TemplateCard
  - Handle navigation to image detail from community image tap
  - Handle navigation to all styles screen from "See All"
  - Handle navigation to all templates screen from "See All"
  - _Requirements: 2, 4, 5, 6_

- [ ] 18. Implement caching and optimization

  - Configure cached_network_image for all images
  - Set up LRU cache with appropriate size limits
  - Implement progressive image loading
  - Preload images for next page in pagination
  - Add placeholder shimmer during loading
  - _Requirements: 4, 5, 6_

- [ ] 19. Add error handling and retry

  - Display error messages for network failures
  - Add retry button for failed requests
  - Handle empty states (no styles, templates, or community images)
  - Show appropriate messages for each error type
  - _Requirements: 1, 4, 5, 6_

- [ ] 20. Implement loading states

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

## Notes

- Complete tasks in order for proper dependency management
- Ensure all tests pass before integration
- Use cached_network_image for all remote images
- Implement proper error handling at each layer
- Follow masonry layout for community images grid
