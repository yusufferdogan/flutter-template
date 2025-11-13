# Design Document - Authentication Module

## Overview

The Authentication module handles user registration, login, OAuth authentication (Google and Apple), and session management. It follows clean architecture principles with BLoC state management and secure token storage.

## Architecture

### Module Structure

```
lib/
├── features/
│   └── authentication/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── auth_remote_datasource.dart
│       │   │   └── auth_local_datasource.dart
│       │   ├── models/
│       │   │   ├── user_dto.dart
│       │   │   └── auth_response_dto.dart
│       │   └── repositories/
│       │       └── auth_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── user.dart
│       │   ├── repositories/
│       │   │   └── auth_repository.dart
│       │   └── usecases/
│       │       ├── sign_up_usecase.dart
│       │       ├── sign_in_usecase.dart
│       │       ├── sign_in_with_google_usecase.dart
│       │       ├── sign_in_with_apple_usecase.dart
│       │       ├── sign_out_usecase.dart
│       │       └── reset_password_usecase.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── authentication_bloc.dart
│           │   ├── authentication_event.dart
│           │   └── authentication_state.dart
│           ├── screens/
│           │   ├── welcome_screen.dart
│           │   ├── sign_up_screen.dart
│           │   └── sign_in_screen.dart
│           └── widgets/
│               ├── welcome_bottom_sheet.dart
│               ├── auth_text_field.dart
│               └── social_auth_button.dart
```

## Components and Interfaces

### Domain Layer

#### User Entity

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
}
```

#### AuthRepository Interface

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

  Future<Either<Failure, User?>> getCurrentUser();
}
```

### Data Layer

#### DTOs

```dart
@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String fullName,
    required String email,
    String? profileImageUrl,
    required bool isPremium,
    required int credits,
    required String createdAt,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

  User toEntity() => User(
    id: id,
    fullName: fullName,
    email: email,
    profileImageUrl: profileImageUrl,
    isPremium: isPremium,
    credits: credits,
    createdAt: DateTime.parse(createdAt),
  );
}

@freezed
class AuthResponseDto with _$AuthResponseDto {
  const factory AuthResponseDto({
    required UserDto user,
    required String accessToken,
    required String refreshToken,
  }) = _AuthResponseDto;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json)
    => _$AuthResponseDtoFromJson(json);
}
```

#### Data Sources

```dart
abstract class AuthRemoteDataSource {
  Future<AuthResponseDto> signUp({
    required String fullName,
    required String email,
    required String password,
  });

  Future<AuthResponseDto> signIn({
    required String email,
    required String password,
  });

  Future<AuthResponseDto> signInWithGoogle(String idToken);

  Future<AuthResponseDto> signInWithApple(String authorizationCode);

  Future<void> signOut(String token);

  Future<void> resetPassword(String email);
}

abstract class AuthLocalDataSource {
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> clearTokens();

  Future<void> saveUser(UserDto user);

  Future<UserDto?> getUser();
}
```

### Presentation Layer

#### AuthenticationBloc

**Events**

```dart
@freezed
class AuthenticationEvent with _$AuthenticationEvent {
  const factory AuthenticationEvent.signUpRequested({
    required String fullName,
    required String email,
    required String password,
  }) = SignUpRequested;

  const factory AuthenticationEvent.signInRequested({
    required String email,
    required String password,
  }) = SignInRequested;

  const factory AuthenticationEvent.signInWithGoogleRequested()
    = SignInWithGoogleRequested;

  const factory AuthenticationEvent.signInWithAppleRequested()
    = SignInWithAppleRequested;

  const factory AuthenticationEvent.signOutRequested() = SignOutRequested;

  const factory AuthenticationEvent.resetPasswordRequested(String email)
    = ResetPasswordRequested;

  const factory AuthenticationEvent.authStateChanged(User? user)
    = AuthStateChanged;
}
```

**States**

```dart
@freezed
class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState.initial() = Initial;
  const factory AuthenticationState.loading() = Loading;
  const factory AuthenticationState.authenticated(User user) = Authenticated;
  const factory AuthenticationState.unauthenticated() = Unauthenticated;
  const factory AuthenticationState.error(String message) = Error;
}
```

### UI Components

#### WelcomeScreen

- Full-screen gradient background
- Hero image with AI-generated artwork
- Title: "Experience the Future of AI-Powered Imagery"
- Subtitle describing app capabilities
- Primary CTA: "Try it out" button with gradient
- Secondary link: "Already have an account? Sign In"

#### WelcomeBottomSheet

- Modal bottom sheet with blur backdrop
- Drag handle for dismissal
- "Sign Up" button (gradient background)
- "Login" button (gradient border)
- Divider with "or" text
- "Continue with Apple" button
- "Continue with Google" button

#### SignUpScreen

- Header with back button and title
- Form fields:
  - Fullname (text input)
  - Email (email input with validation)
  - Password (secure input with toggle)
  - Confirm Password (secure input with toggle)
- Terms and privacy policy text
- "Create Account" button (disabled until valid)
- Real-time validation feedback

#### SignInScreen

- Header with back button and title
- Form fields:
  - Email (email input)
  - Password (secure input with toggle)
- "Forgot Password?" link
- "Login" button (disabled until valid)
- Error message display

## Data Flow

### Sign Up Flow

```
User Input → SignUpRequested Event → SignUpUseCase → AuthRepository
→ AuthRemoteDataSource → API Call → AuthResponseDto → User Entity
→ Save Tokens (Local) → Authenticated State → Navigate to Home
```

### Sign In Flow

```
User Input → SignInRequested Event → SignInUseCase → AuthRepository
→ AuthRemoteDataSource → API Call → AuthResponseDto → User Entity
→ Save Tokens (Local) → Authenticated State → Navigate to Home
```

### OAuth Flow

```
User Tap → OAuth Provider → Authorization → ID Token/Auth Code
→ SignInWithGoogle/AppleUseCase → AuthRepository → API Call
→ AuthResponseDto → User Entity → Save Tokens → Authenticated State
```

## Security Considerations

### Token Storage

- Use `flutter_secure_storage` for storing tokens
- Encrypt tokens at rest
- Clear tokens on logout
- Implement token refresh mechanism

### Password Security

- Minimum 8 characters
- Client-side validation
- Server-side hashing (bcrypt/argon2)
- No password storage on client

### OAuth Security

- Use PKCE for OAuth flows
- Validate state parameter
- Verify ID token signature
- Use secure redirect URIs

## Error Handling

### Error Types

```dart
@freezed
class AuthFailure with _$AuthFailure {
  const factory AuthFailure.invalidCredentials() = InvalidCredentials;
  const factory AuthFailure.emailAlreadyExists() = EmailAlreadyExists;
  const factory AuthFailure.weakPassword() = WeakPassword;
  const factory AuthFailure.networkError() = NetworkError;
  const factory AuthFailure.serverError(String message) = ServerError;
  const factory AuthFailure.oauthCancelled() = OAuthCancelled;
  const factory AuthFailure.oauthFailed(String message) = OAuthFailed;
}
```

### Error Messages

- Invalid credentials: "Invalid email or password"
- Email exists: "An account with this email already exists"
- Weak password: "Password must be at least 8 characters"
- Network error: "Please check your internet connection"
- Server error: "Something went wrong. Please try again"
- OAuth cancelled: "Sign in was cancelled"

## Validation Rules

### Email Validation

- Must contain @ symbol
- Must have valid domain
- Regex: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`

### Password Validation

- Minimum 8 characters
- At least one uppercase letter (optional)
- At least one number (optional)
- At least one special character (optional)

### Name Validation

- Minimum 2 characters
- Maximum 50 characters
- Letters, spaces, and hyphens only

## Testing Strategy

### Unit Tests

- Test all use cases with mocked repositories
- Test BLoC state transitions
- Test validation logic
- Test DTO to Entity conversions

### Widget Tests

- Test screen rendering
- Test form validation
- Test button states
- Test error display

### Integration Tests

- Test complete sign up flow
- Test complete sign in flow
- Test OAuth flows
- Test session persistence
