# Design Document - Image Generation Module

## Overview

The Image Generation module handles the complete flow of creating AI-generated images, from prompt configuration to result display. It manages credit validation, generation processing, and image sharing/downloading.

## Architecture

### Module Structure

```
lib/features/generation/
├── data/
│   ├── datasources/
│   │   ├── generation_remote_datasource.dart
│   │   └── generation_local_datasource.dart
│   ├── models/
│   │   ├── generated_image_dto.dart
│   │   └── generation_request_dto.dart
│   └── repositories/
│       └── generation_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── generated_image.dart
│   │   ├── shape.dart
│   │   └── style.dart
│   ├── repositories/
│   │   └── generation_repository.dart
│   └── usecases/
│       ├── generate_image_usecase.dart
│       ├── get_random_prompt_usecase.dart
│       ├── get_remaining_credits_usecase.dart
│       └── save_generated_image_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── prompt_bloc.dart
    │   ├── generation_bloc.dart
    │   └── states/events
    ├── screens/
    │   ├── prompt_screen.dart
    │   └── generation_result_screen.dart
    └── widgets/
        ├── prompt_input_field.dart
        ├── style_selector.dart
        ├── shape_selector.dart
        └── credit_indicator.dart
```

## Domain Entities

```dart
enum Shape { square, landscape, portrait, custom }

@freezed
class GeneratedImage with _$GeneratedImage {
  const factory GeneratedImage({
    required String id,
    required String imageUrl,
    required String prompt,
    required StyleType style,
    required Shape shape,
    required String userId,
    required DateTime createdAt,
  }) = _GeneratedImage;
}
```

## Repository Interface

```dart
abstract class GenerationRepository {
  Future<Either<Failure, GeneratedImage>> generateImage({
    required String prompt,
    required StyleType style,
    required Shape shape,
  });

  Future<Either<Failure, String>> getRandomPrompt();
  Future<Either<Failure, int>> getRemainingCredits();
  Future<Either<Failure, void>> saveGeneratedImage(GeneratedImage image);
}
```

## BLoC Architecture

### PromptBloc

- Manages prompt configuration state
- Handles style and shape selection
- Validates prompt before generation

### GenerationBloc

- Manages image generation process
- Tracks generation progress
- Handles credit deduction and refunds
- Manages generation results

## UI Components

### PromptInputField

- Multi-line text input (max 500 chars)
- Character counter
- Random prompt button
- Validation feedback

### StyleSelector

- Horizontal scrollable grid
- 8 style options with preview images
- Gradient border for selected style

### ShapeSelector

- Horizontal list of 4 shape options
- Icon representation for each shape
- Gradient border for selected shape

### CreditIndicator

- Displays "Use X of Y credits"
- Crown icon
- "Upgrade for more" link

## Testing Strategy

- Unit tests for use cases and BLoCs
- Widget tests for all components
- Integration tests for complete generation flow
