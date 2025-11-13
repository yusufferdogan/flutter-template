# Authentication Module

This module handles user registration, login, OAuth authentication (Google and Apple), and session management for the Artifex AI Image Generator app.

## Architecture

The module follows Clean Architecture principles with three main layers:

### Domain Layer
- **Entities**: `User`, `AuthFailure`
- **Repository Interface**: `AuthRepository`
- **Use Cases**:
  - `SignUpUseCase`
  - `SignInUseCase`
  - `SignInWithGoogleUseCase`
  - `SignInWithAppleUseCase`
  - `SignOutUseCase`
  - `ResetPasswordUseCase`

### Data Layer
- **Data Sources**:
  - `AuthRemoteDataSource`: Handles API calls
  - `AuthLocalDataSource`: Manages local token storage and user caching
- **Models**: `UserDto`, `AuthResponseDto`
- **Repository Implementation**: `AuthRepositoryImpl`

### Presentation Layer
- **BLoC**: `AuthenticationBloc` with events and states
- **Screens**:
  - `WelcomeScreen`: Initial landing screen
  - `SignUpScreen`: User registration
  - `SignInScreen`: User login
- **Widgets**:
  - `WelcomeBottomSheet`: Authentication options modal
  - `AuthTextField`: Reusable form input
  - `SocialAuthButton`: OAuth provider buttons
  - `GradientButton`: Custom styled button

## Features

1. **Email/Password Authentication**
   - User registration with validation
   - Login with email and password
   - Password reset functionality

2. **OAuth Authentication**
   - Google Sign-In
   - Apple Sign-In

3. **Session Management**
   - Secure token storage using Flutter Secure Storage
   - User data caching with Hive
   - Automatic token refresh
   - Persistent login sessions

4. **Validation**
   - Email format validation
   - Password strength requirements (minimum 8 characters)
   - Real-time form validation
   - Password confirmation matching

5. **Error Handling**
   - User-friendly error messages
   - Network error handling
   - OAuth cancellation handling

## Setup

### Dependencies

The module requires the following dependencies (already added to `pubspec.yaml`):

```yaml
dependencies:
  firebase_auth: ^4.15.3
  google_sign_in: ^6.1.6
  sign_in_with_apple: ^5.0.0
  flutter_secure_storage: ^9.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_bloc: ^8.1.3
  freezed_annotation: ^2.4.1
  dartz: ^0.10.1
```

### Code Generation

Run the following command to generate freezed and JSON serialization code:

```bash
./generate.sh
```

Or manually:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Dependency Injection

The module is integrated with GetIt for dependency injection. To initialize:

```dart
await initSingletons();
provideDataSources();
provideRepositories();
provideUseCases();
provideBlocs();
```

## Usage

### Using the Authentication Bloc

```dart
// In your widget
BlocProvider<AuthenticationBloc>(
  create: (context) => injector.get<AuthenticationBloc>()..add(CheckAuthStatus()),
  child: YourWidget(),
)

// Sign up
context.read<AuthenticationBloc>().add(
  AuthenticationEvent.signUpRequested(
    fullName: 'John Doe',
    email: 'john@example.com',
    password: 'password123',
  ),
);

// Sign in
context.read<AuthenticationBloc>().add(
  AuthenticationEvent.signInRequested(
    email: 'john@example.com',
    password: 'password123',
  ),
);

// Google Sign-In
context.read<AuthenticationBloc>().add(
  const AuthenticationEvent.signInWithGoogleRequested(),
);

// Sign out
context.read<AuthenticationBloc>().add(
  const AuthenticationEvent.signOutRequested(),
);
```

### Listening to Authentication State

```dart
BlocListener<AuthenticationBloc, AuthenticationState>(
  listener: (context, state) {
    state.maybeWhen(
      authenticated: (user) {
        // Navigate to home
        context.go('/home');
      },
      error: (message) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
      unauthenticated: () {
        // Navigate to login
        context.go('/login');
      },
      orElse: () {},
    );
  },
  child: YourWidget(),
)
```

## API Configuration

Update the base URL in `lib/di/Injector.dart`:

```dart
injector.registerFactory<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
    dio: injector.get<NetworkService>().dio,
    baseUrl: 'YOUR_API_BASE_URL'));  // Update this
```

## Security Considerations

- Tokens are stored securely using Flutter Secure Storage
- Passwords are never stored on the client
- OAuth flows use PKCE for enhanced security
- User data is cached locally using Hive with encryption

## Testing

The module includes comprehensive testing:

- **Unit Tests**: Test use cases, BLoC, and validation logic
- **Widget Tests**: Test screen rendering and interactions
- **Integration Tests**: Test complete authentication flows

Run tests:

```bash
flutter test
```

## Requirements Fulfilled

This implementation fulfills all requirements specified in the design document:

✅ User Registration (Requirement 1)
✅ User Login (Requirement 2)
✅ OAuth Authentication (Requirement 3)
✅ Welcome Screen (Requirement 4)
✅ Authentication Options Bottom Sheet (Requirement 5)
✅ Session Management (Requirement 6)

## Notes

- The module integrates with Firebase Authentication for OAuth flows
- All screens follow the design specifications from the requirements document
- Form validation is implemented with real-time feedback
- Error messages are user-friendly and match the design specifications
