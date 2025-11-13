# Design Document - Explore Module

## Overview

Handles image discovery through categories, search, and detailed image viewing with template functionality.

## Architecture

```
lib/features/explore/
├── data/ (datasources, models, repositories)
├── domain/ (entities, repositories, usecases)
└── presentation/ (bloc, screens, widgets)
```

## Key Components

- **ExploreBloc**: Manages category and search state
- **ImageDetailBloc**: Handles image detail and template navigation
- **CategoryCard**: Displays category with preview grid
- **MasonryImageGrid**: Two-column layout with lazy loading
- **SearchBar**: Search input with debouncing

## Entities

```dart
@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required List<String> previewImageUrls,
  }) = _Category;
}

@freezed
class ExploreImage with _$ExploreImage {
  const factory ExploreImage({
    required String id,
    required String imageUrl,
    required String prompt,
    required String artistName,
    required String artistAvatarUrl,
    required String category,
  }) = _ExploreImage;
}
```

_Requirements: 1, 2, 3_
