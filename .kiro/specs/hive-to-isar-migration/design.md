# Design Document

## Overview

This design document outlines the approach for migrating the Filmku application from Hive to Isar for authentication data storage. The migration will remove all Hive dependencies, create an Isar collection for user data, update the AuthLocalDataSource implementation, and ensure seamless data migration for existing users.

## Architecture

### Current State

- Hive is used exclusively for storing user authentication data (UserDto)
- FlutterSecureStorage is used for storing sensitive tokens (access_token, refresh_token)
- Isar is already initialized and used for other features (movies, genres, notifications)
- The LocalDb abstraction provides access to the Isar instance

### Target State

- Remove all Hive dependencies from the project
- Create an Isar collection for User data
- Update AuthLocalDataSource to use Isar instead of Hive Box
- Maintain FlutterSecureStorage for token management (no changes needed)
- Provide optional migration logic to transfer existing Hive data to Isar

## Components and Interfaces

### 1. User Isar Entity

Create a new Isar collection model for user data:

**File:** `lib/features/authentication/data/models/user_local_model.dart`

```dart
@collection
class UserLocalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId;

  late String fullName;
  late String email;
  String? profileImageUrl;
  late bool isPremium;
  late int credits;
  late String createdAt;
}
```

**Design Decisions:**

- Use `Isar.autoIncrement` for the primary key to let Isar manage IDs
- Add a unique index on `userId` to ensure only one user record exists
- Map all fields from UserDto to maintain data integrity
- Keep field names consistent with UserDto for easier mapping

### 2. Updated LocalDb Implementation

Update the Isar initialization to include the User schema:

**File:** `lib/shared/local/cache/local_db_impl.dart`

```dart
@override
Future<void> initDb() async {
  final dir = await getApplicationDocumentsDirectory();
  db = await Isar.open([
    MoviesSchema,
    GenresSchema,
    MovieDetailSchema,
    NotificationModelSchema,
    UserLocalModelSchema  // Add user schema
  ], directory: dir.path);
}
```

### 3. Updated AuthLocalDataSource

Refactor the implementation to use Isar instead of Hive:

**File:** `lib/features/authentication/data/datasources/auth_local_datasource.dart`

**Changes:**

- Remove `Box` dependency from constructor
- Add `LocalDb` dependency to access Isar instance
- Update `saveUser()` to write UserLocalModel to Isar
- Update `getUser()` to query UserLocalModel from Isar
- Update `clearUser()` to delete UserLocalModel from Isar
- Keep token methods unchanged (they use FlutterSecureStorage)

**Interface remains the same:**

```dart
abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String accessToken, required String refreshToken});
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<void> saveUser(UserDto user);
  Future<UserDto?> getUser();
  Future<void> clearUser();
}
```

### 4. Updated Dependency Injection

Update the Injector to remove Hive initialization:

**File:** `lib/di/Injector.dart`

**Changes:**

- Remove `import 'package:hive/hive.dart';`
- Remove Hive box initialization from `initSingletons()`
- Remove `Box` registration in GetIt
- Update `AuthLocalDataSource` factory to inject `LocalDb` instead of `Box`

### 5. Migration Strategy (Optional)

Since Hive is only used for a single user object, and the error indicates Hive isn't properly initialized, we can take a simpler approach:

**Option A: Clean Migration (Recommended)**

- Remove Hive completely
- Users will need to sign in again (acceptable for fixing a critical bug)
- Simpler implementation with no migration code

**Option B: Data Migration**

- Attempt to read from Hive if it exists
- Transfer data to Isar
- Clean up Hive data
- More complex but preserves user sessions

For this design, we'll implement **Option A** as it's cleaner and the authentication state loss is acceptable given the critical nature of the bug.

## Data Models

### UserLocalModel (Isar Collection)

```dart
@collection
class UserLocalModel {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String userId;
  String fullName;
  String email;
  String? profileImageUrl;
  bool isPremium;
  int credits;
  String createdAt;
}
```

### Mapping Functions

Helper methods to convert between UserDto and UserLocalModel:

```dart
// UserDto -> UserLocalModel
UserLocalModel toLocalModel(UserDto dto) {
  return UserLocalModel()
    ..userId = dto.id
    ..fullName = dto.fullName
    ..email = dto.email
    ..profileImageUrl = dto.profileImageUrl
    ..isPremium = dto.isPremium
    ..credits = dto.credits
    ..createdAt = dto.createdAt;
}

// UserLocalModel -> UserDto
UserDto fromLocalModel(UserLocalModel model) {
  return UserDto(
    id: model.userId,
    fullName: model.fullName,
    email: model.email,
    profileImageUrl: model.profileImageUrl,
    isPremium: model.isPremium,
    credits: model.credits,
    createdAt: model.createdAt,
  );
}
```

## Error Handling

### Isar Operations

- Wrap all Isar write operations in try-catch blocks
- Return null for read operations when data doesn't exist
- Log errors for debugging purposes

### Migration Scenarios

- If no user data exists (new install or after clean migration), return null from `getUser()`
- Handle cases where Isar is not initialized by throwing descriptive errors

## Testing Strategy

### Unit Tests

- Test UserLocalModel creation and field mapping
- Test AuthLocalDataSource CRUD operations with mocked LocalDb
- Test conversion between UserDto and UserLocalModel
- Test error handling for database operations

### Integration Tests

- Test full authentication flow with Isar storage
- Verify user data persists across app restarts
- Test token storage continues to work with FlutterSecureStorage

### Manual Testing

- Verify app starts without Hive initialization errors
- Test sign in and verify user data is saved to Isar
- Test sign out and verify user data is cleared from Isar
- Test app restart and verify user session persists

## Implementation Order

1. Create UserLocalModel Isar entity
2. Run build_runner to generate Isar schema
3. Update LocalDb to include UserLocalModelSchema
4. Update AuthLocalDataSource implementation
5. Update Injector dependency injection
6. Remove Hive dependencies from pubspec.yaml
7. Test the implementation
8. Clean up any remaining Hive imports or references

## Dependencies

### Existing (No Changes)

- `isar: ^3.1.0+1`
- `isar_flutter_libs: ^3.1.0+1`
- `path_provider: ^2.0.15`
- `flutter_secure_storage: ^9.0.0`

### To Remove

- `hive: ^2.2.3`
- `hive_flutter: ^1.1.0`
- `hive_generator: ^2.0.1` (from dev_dependencies)

### Build Tools (Existing)

- `isar_generator: ^3.1.0+1` (already in dev_dependencies)
- `build_runner: ^2.4.6` (already in dev_dependencies)
