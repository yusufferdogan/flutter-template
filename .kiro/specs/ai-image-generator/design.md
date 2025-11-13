# Design Document - AI Image Generator Mobile App

## Overview

This document outlines the technical design for the Artifex AI Image Generator mobile application. The app is built using Flutter for cross-platform development (iOS and Android), following a clean architecture pattern with BLoC state management. The design emphasizes a modern, gradient-rich UI with smooth animations and a focus on user experience.

## Architecture

### High-Level Architecture

The application follows a layered clean architecture pattern:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Screens, Widgets, BLoC/Cubit)        │
├─────────────────────────────────────────┤
│          Domain Layer                   │
│  (Use Cases, Entities, Repositories)    │
├─────────────────────────────────────────┤
│           Data Layer                    │
│  (Repository Impl, Data Sources, DTOs)  │
├─────────────────────────────────────────┤
│         External Services               │
│  (API, Local Storage, Auth Providers)   │
└─────────────────────────────────────────┘
```

### Technology Stack

- **Framework**: Flutter 3.x
- **State Management**: flutter_bloc
- **Dependency Injection**: get_it
- **Navigation**: go_router
- **Local Storage**: shared_preferences, hive
- **Network**: dio
- **Image Handling**: cached_network_image
- **Authentication**: firebase_auth (for OAuth)
- **Payments**: in_app_purchase
- **Code Generation**: freezed, json_serializable

## Components and Interfaces

### 1. Authentication Module

#### Components

**AuthenticationBloc**

- Manages authentication state across the app
- Handles login, signup, OAuth, and logout flows
- Persists authentication tokens

**AuthRepository**

```dart
abstract class AuthRepository {
  Future<Either<Failure, User>> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, User>> signInWithApple();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> resetPassword(String email);

  Stream<AuthState> get authStateChanges;
}
```

**Screens**

- `WelcomeScreen`: Initial landing page with hero image and CTA
- `WelcomeBottomSheet`: Modal bottom sheet with auth options
- `SignUpScreen`: Registration form with validation
- `SignInScreen`: Login form with forgot password link

#### UI Components

**GradientButton**

```dart
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  // Renders button with radial gradient background
  // Supports outlined variant with gradient border
}
```

**CustomTextField**

```dart
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final String? Function(String?)? validator;

  // Styled text field with dark background
  // Password toggle for secure fields
}
```

### 2. Home Module

#### Components

**HomeBloc**

- Manages home screen state
- Fetches trending styles and templates
- Handles navigation to generation flow

**HomeRepository**

```dart
abstract class HomeRepository {
  Future<Either<Failure, List<Style>>> getTrendingStyles();
  Future<Either<Failure, List<Template>>> getImageTemplates();
  Future<Either<Failure, List<CommunityImage>>> getCommunityImages({
    String? category,
  });
}
```

**Screens**

- `HomeScreen`: Main dashboard with navigation
- `HomePageView`: Scrollable content with sections

#### UI Components

**ImageGeneratorCard**

```dart
class ImageGeneratorCard extends StatelessWidget {
  final VoidCallback onGenerateTap;

  // Card with gradient background
  // Displays abstract illustration
  // "Generate" CTA button
}
```

**StyleCard**

```dart
class StyleCard extends StatelessWidget {
  final Style style;
  final VoidCallback onTap;

  // Displays style preview image
  // Style name label
  // Tap to select style
}
```

**BottomNavBar**

```dart
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  // Four tabs: Home, Explore, Notification, Profile
  // Active tab with gradient background
  // Smooth tab switching animation
}
```

### 3. Image Generation Module

#### Components

**PromptBloc**

- Manages prompt configuration state
- Handles style and shape selection
- Validates prompt before generation

**GenerationBloc**

- Manages image generation process
- Tracks generation progress
- Handles generation results

**GenerationRepository**

```dart
abstract class GenerationRepository {
  Future<Either<Failure, GeneratedImage>> generateImage({
    required String prompt,
    required Style style,
    required Shape shape,
  });

  Future<Either<Failure, String>> getRandomPrompt();

  Future<Either<Failure, int>> getRemainingCredits();
}
```

**Screens**

- `PromptScreen`: Prompt configuration interface
- `GenerationResultScreen`: Display generated image with actions

#### UI Components

**PromptInputField**

```dart
class PromptInputField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;

  // Multi-line text input
  // Character counter
  // Random prompt button
}
```

**StyleSelector**

```dart
class StyleSelector extends StatelessWidget {
  final List<Style> styles;
  final Style? selectedStyle;
  final Function(Style) onStyleSelected;

  // Horizontal scrollable grid
  // Style preview images
  // Gradient border for selected style
}
```

**ShapeSelector**

```dart
class ShapeSelector extends StatelessWidget {
  final List<Shape> shapes;
  final Shape? selectedShape;
  final Function(Shape) onShapeSelected;

  // Horizontal list of shape options
  // Icon representation of each shape
  // Gradient border for selected shape
}
```

**CreditIndicator**

```dart
class CreditIndicator extends StatelessWidget {
  final int usedCredits;
  final int totalCredits;
  final VoidCallback onUpgradeTap;

  // Displays credit usage
  // Crown icon for premium
  // "Upgrade for more" link
}
```

### 4. Explore Module

#### Components

**ExploreBloc**

- Manages explore screen state
- Handles category filtering
- Manages search functionality

**ExploreRepository**

```dart
abstract class ExploreRepository {
  Future<Either<Failure, List<Category>>> getCategories();

  Future<Either<Failure, List<ExploreImage>>> getCategoryImages(
    String categoryId,
  );

  Future<Either<Failure, List<ExploreImage>>> searchImages(
    String query,
  );
}
```

**Screens**

- `ExploreScreen`: Category list with search
- `ExploreDetailScreen`: Category image grid
- `ImageDetailScreen`: Full image view with details

#### UI Components

**CategoryCard**

```dart
class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  // Category name and arrow icon
  // Preview image grid (2x2)
  // Dark background card
}
```

**MasonryImageGrid**

```dart
class MasonryImageGrid extends StatelessWidget {
  final List<ExploreImage> images;
  final Function(ExploreImage) onImageTap;

  // Two-column masonry layout
  // Varying image heights
  // Smooth loading with shimmer
}
```

**SearchBar**

```dart
class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  // Search icon prefix
  // Dark background with border
  // Rounded corners (100px)
}
```

### 5. Notification Module

#### Components

**NotificationBloc**

- Manages notification list state
- Handles notification actions
- Marks notifications as read

**NotificationRepository**

```dart
abstract class NotificationRepository {
  Future<Either<Failure, List<Notification>>> getNotifications();

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, void>> clearAll();

  Stream<Notification> get notificationStream;
}
```

**Screens**

- `NotificationScreen`: List of notifications

#### UI Components

**NotificationCard**

```dart
class NotificationCard extends StatelessWidget {
  final Notification notification;
  final VoidCallback onTap;

  // Icon with colored background
  // Title and description
  // Timestamp with clock icon
  // Divider line
}
```

### 6. Profile Module

#### Components

**ProfileBloc**

- Manages profile state
- Handles profile updates
- Manages user settings

**ProfileRepository**

```dart
abstract class ProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile();

  Future<Either<Failure, void>> updateProfile({
    String? fullName,
    File? profileImage,
  });

  Future<Either<Failure, void>> updateSettings(Settings settings);
}
```

**Screens**

- `ProfileScreen`: User profile display

#### UI Components

**ProfileCard**

```dart
class ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEditTap;

  // Circular profile image (52px)
  // User name (bold)
  // Email address (gray)
  // Edit button (pencil icon)
}
```

### 7. Subscription Module

#### Components

**SubscriptionBloc**

- Manages subscription state
- Handles plan selection
- Processes payments

**SubscriptionRepository**

```dart
abstract class SubscriptionRepository {
  Future<Either<Failure, List<SubscriptionPlan>>> getPlans();

  Future<Either<Failure, void>> subscribe(SubscriptionPlan plan);

  Future<Either<Failure, void>> cancelSubscription();

  Future<Either<Failure, SubscriptionStatus>> getSubscriptionStatus();
}
```

**Screens**

- `PricingScreen`: Subscription plans and features

#### UI Components

**PlanCard**

```dart
class PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  // Plan name (MONTHLY/YEARLY)
  // Price with strikethrough for discount
  // Billing information
  // Checkmark for selected plan
  // Gradient border when selected
  // "50% SAVINGS" badge for yearly
}
```

**FeatureList**

```dart
class FeatureList extends StatelessWidget {
  final List<String> features;

  // Checkmark icon for each feature
  // Feature description text
  // Vertical list layout
}
```

## Data Models

### User

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String fullName,
    required String email,
    String? profileImageUrl,
    required bool isPremium,
    required int credits,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### GeneratedImage

```dart
@freezed
class GeneratedImage with _$GeneratedImage {
  const factory GeneratedImage({
    required String id,
    required String imageUrl,
    required String prompt,
    required Style style,
    required Shape shape,
    required String userId,
    required DateTime createdAt,
  }) = _GeneratedImage;

  factory GeneratedImage.fromJson(Map<String, dynamic> json)
    => _$GeneratedImageFromJson(json);
}
```

### Style

```dart
enum Style {
  none,
  photo,
  anime,
  illustration,
  popArt,
  abstract,
  fantasy,
  comic,
}
```

### Shape

```dart
enum Shape {
  square,
  landscape,
  portrait,
  custom,
}
```

### Notification

```dart
@freezed
class Notification with _$Notification {
  const factory Notification({
    required String id,
    required NotificationType type,
    required String title,
    required String description,
    required DateTime timestamp,
    required bool isRead,
    String? imageUrl,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json)
    => _$NotificationFromJson(json);
}

enum NotificationType {
  imageReady,
  likesReceived,
  systemUpdate,
}
```

### SubscriptionPlan

```dart
@freezed
class SubscriptionPlan with _$SubscriptionPlan {
  const factory SubscriptionPlan({
    required String id,
    required String name,
    required double price,
    required double originalPrice,
    required PlanDuration duration,
    required List<String> features,
    required int discountPercentage,
  }) = _SubscriptionPlan;

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json)
    => _$SubscriptionPlanFromJson(json);
}

enum PlanDuration {
  monthly,
  yearly,
}
```

## Error Handling

### Error Types

```dart
@freezed
class Failure with _$Failure {
  const factory Failure.network(String message) = NetworkFailure;
  const factory Failure.server(String message) = ServerFailure;
  const factory Failure.authentication(String message) = AuthenticationFailure;
  const factory Failure.validation(String message) = ValidationFailure;
  const factory Failure.insufficientCredits() = InsufficientCreditsFailure;
  const factory Failure.unknown(String message) = UnknownFailure;
}
```

### Error Handling Strategy

1. **Network Errors**: Display retry dialog with option to retry or cancel
2. **Authentication Errors**: Redirect to login screen with error message
3. **Validation Errors**: Show inline error messages on form fields
4. **Insufficient Credits**: Navigate to pricing screen with upgrade prompt
5. **Server Errors**: Display user-friendly error message with support contact

## Testing Strategy

### Unit Tests

- **BLoC Tests**: Test all state transitions and business logic
- **Repository Tests**: Mock data sources and test data transformations
- **Use Case Tests**: Test individual use cases with mocked repositories
- **Validator Tests**: Test all input validation logic

### Widget Tests

- **Screen Tests**: Test screen rendering and user interactions
- **Component Tests**: Test individual UI components
- **Navigation Tests**: Test navigation flows between screens

### Integration Tests

- **Authentication Flow**: Test complete signup/login flows
- **Generation Flow**: Test prompt to result generation
- **Subscription Flow**: Test plan selection and payment
- **Explore Flow**: Test category browsing and image viewing

### E2E Tests

- **Critical User Journeys**:
  - New user onboarding and first image generation
  - Existing user login and image generation
  - Premium subscription purchase
  - Image exploration and template usage

## Design System

### Colors

```dart
class AppColors {
  // Primary
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFFCC72F5), Color(0xFF7B2CFA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Background
  static const background = Color(0xFF121212);
  static const cardBackground = Color(0xFF1E1C28);
  static const inputBackground = Color(0xFF16151D);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF878294);
  static const textTertiary = Color(0xFF928AA6);

  // Borders
  static const borderPrimary = Color(0xFF382D4A);
  static const borderSecondary = Color(0xFF241D30);

  // Accent
  static const accentPurple = Color(0xFF946ABF);
  static const accentCyan = Color(0xFF00A8B4);
  static const accentOrange = Color(0xFFF7714D);
}
```

### Typography

```dart
class AppTextStyles {
  // Headings
  static const h1 = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const h2 = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.26,
  );

  // Body
  static const bodyLarge = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.48,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const bodySmall = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // Buttons
  static const button = TextStyle(
    fontFamily: 'Inter Display',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );
}
```

### Spacing

```dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}
```

### Border Radius

```dart
class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const pill = 100.0;
}
```

## Navigation Structure

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) {
        // Check auth state and redirect accordingly
      },
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/signin',
      builder: (context, state) => const SignInScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/explore',
          builder: (context, state) => const ExploreScreen(),
          routes: [
            GoRoute(
              path: ':categoryId',
              builder: (context, state) => ExploreDetailScreen(
                categoryId: state.pathParameters['categoryId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/prompt',
      builder: (context, state) => const PromptScreen(),
    ),
    GoRoute(
      path: '/generation-result',
      builder: (context, state) => GenerationResultScreen(
        image: state.extra as GeneratedImage,
      ),
    ),
    GoRoute(
      path: '/image-detail',
      builder: (context, state) => ImageDetailScreen(
        image: state.extra as ExploreImage,
      ),
    ),
    GoRoute(
      path: '/pricing',
      builder: (context, state) => const PricingScreen(),
    ),
  ],
);
```

## Performance Considerations

### Image Optimization

1. **Caching Strategy**:

   - Use `cached_network_image` for all remote images
   - Implement LRU cache with 100MB limit
   - Preload images for next screen during navigation

2. **Image Compression**:

   - Compress generated images before upload
   - Use WebP format for better compression
   - Implement progressive loading for large images

3. **Lazy Loading**:
   - Implement pagination for image lists
   - Load images on-demand as user scrolls
   - Use placeholder shimmer during loading

### State Management Optimization

1. **BLoC Optimization**:

   - Use `Equatable` for efficient state comparison
   - Implement `transformEvents` for debouncing
   - Use `distinct()` on streams to prevent unnecessary rebuilds

2. **Widget Optimization**:
   - Use `const` constructors wherever possible
   - Implement `RepaintBoundary` for complex widgets
   - Use `ListView.builder` for long lists

### Network Optimization

1. **Request Optimization**:

   - Implement request caching with dio_cache_interceptor
   - Use connection pooling for multiple requests
   - Implement retry logic with exponential backoff

2. **Payload Optimization**:
   - Use JSON compression for API responses
   - Implement pagination for list endpoints
   - Use GraphQL for flexible data fetching

## Security Considerations

### Authentication Security

1. **Token Management**:

   - Store tokens in secure storage (flutter_secure_storage)
   - Implement token refresh mechanism
   - Clear tokens on logout

2. **Password Security**:
   - Enforce minimum password requirements (8+ characters)
   - Hash passwords on client before transmission
   - Implement rate limiting for login attempts

### Data Security

1. **API Security**:

   - Use HTTPS for all API calls
   - Implement certificate pinning
   - Validate SSL certificates

2. **Local Storage Security**:
   - Encrypt sensitive data in local storage
   - Use secure storage for authentication tokens
   - Implement data expiration policies

### Privacy

1. **User Data**:

   - Implement GDPR-compliant data handling
   - Provide data export functionality
   - Allow account deletion with data removal

2. **Analytics**:
   - Anonymize user data in analytics
   - Provide opt-out for analytics tracking
   - Comply with privacy regulations

## Accessibility

### Screen Reader Support

1. **Semantic Labels**:

   - Add semantic labels to all interactive elements
   - Provide descriptive labels for images
   - Use proper heading hierarchy

2. **Navigation**:
   - Implement keyboard navigation support
   - Ensure logical tab order
   - Provide skip navigation links

### Visual Accessibility

1. **Color Contrast**:

   - Ensure WCAG AA compliance for text contrast
   - Provide high contrast mode option
   - Don't rely solely on color for information

2. **Text Scaling**:
   - Support dynamic text sizing
   - Test with large text sizes
   - Ensure layouts adapt to text scaling

### Interaction Accessibility

1. **Touch Targets**:

   - Minimum 44x44 points for touch targets
   - Adequate spacing between interactive elements
   - Provide visual feedback for interactions

2. **Gestures**:
   - Provide alternatives to complex gestures
   - Support standard platform gestures
   - Avoid gesture-only interactions

## Deployment Strategy

### Build Configuration

1. **Environment Configuration**:

   - Development: Debug mode, test API endpoints
   - Staging: Release mode, staging API endpoints
   - Production: Release mode, production API endpoints

2. **Build Variants**:
   - Free version: Limited features
   - Premium version: All features unlocked

### Release Process

1. **Pre-Release**:

   - Run all automated tests
   - Perform manual QA testing
   - Update version numbers and changelog

2. **Release**:

   - Build signed APK/IPA
   - Upload to Play Store/App Store
   - Submit for review

3. **Post-Release**:
   - Monitor crash reports
   - Track user feedback
   - Plan hotfixes if needed

### Monitoring

1. **Crash Reporting**:

   - Integrate Firebase Crashlytics
   - Monitor crash-free users percentage
   - Set up alerts for critical crashes

2. **Analytics**:

   - Track user engagement metrics
   - Monitor feature usage
   - Analyze user flows

3. **Performance Monitoring**:
   - Track app startup time
   - Monitor API response times
   - Track frame rendering performance
