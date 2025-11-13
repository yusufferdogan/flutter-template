# Design Document - Profile Module

## Overview

Manages user profile display and editing.

## Architecture

```
lib/features/profile/
├── data/ (datasources, models, repositories)
├── domain/ (entities, repositories, usecases)
└── presentation/ (bloc, screens, widgets)
```

## Entities

```dart
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String fullName,
    required String email,
    String? profileImageUrl,
    required bool isPremium,
    required int credits,
  }) = _UserProfile;
}
```

## Key Components

- **ProfileBloc**: Manages profile state and updates
- **ProfileCard**: Displays user information
- **ProfileScreen**: Main profile view

_Requirements: 1_
