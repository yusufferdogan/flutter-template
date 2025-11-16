# Implementation Plan

- [-] 1. Create UserLocalModel Isar entity and generate schema

  - Create `lib/features/authentication/data/models/user_local_model.dart` with Isar collection annotations
  - Define all fields from UserDto (userId, fullName, email, profileImageUrl, isPremium, credits, createdAt)
  - Add unique index on userId field
  - Create mapping functions to convert between UserDto and UserLocalModel
  - Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate Isar schema
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 2. Update LocalDb to include User schema

  - Modify `lib/shared/local/cache/local_db_impl.dart` to import UserLocalModelSchema
  - Add UserLocalModelSchema to the Isar.open schemas list in initDb()
  - _Requirements: 3.1, 3.2, 3.3_

- [x] 3. Refactor AuthLocalDataSource to use Isar

  - [x] 3.1 Update AuthLocalDataSourceImpl constructor

    - Remove Box dependency from constructor parameters
    - Add LocalDb dependency to access Isar instance
    - _Requirements: 2.4, 3.2_

  - [ ] 3.2 Implement saveUser() with Isar

    - Convert UserDto to UserLocalModel using mapping function
    - Write UserLocalModel to Isar collection using writeTxn
    - Handle existing user by querying with unique userId and updating
    - _Requirements: 2.1_

  - [-] 3.3 Implement getUser() with Isar

    - Query UserLocalModel from Isar collection
    - Convert UserLocalModel to UserDto using mapping function
    - Return null if no user exists
    - _Requirements: 2.2_

  - [ ] 3.4 Implement clearUser() with Isar
    - Delete UserLocalModel from Isar collection using writeTxn
    - Query by userId and delete the record
    - _Requirements: 2.3_

- [x] 4. Update dependency injection in Injector

  - Remove all Hive imports from `lib/di/Injector.dart`
  - Remove Hive box initialization code from initSingletons()
  - Remove Box registration from GetIt container
  - Update AuthLocalDataSource factory to inject LocalDb instead of Box
  - Ensure Isar initialization happens before AuthLocalDataSource registration
  - _Requirements: 1.1, 3.1, 3.2, 3.3_

- [x] 5. Remove Hive dependencies from project

  - Remove `hive`, `hive_flutter` from dependencies in pubspec.yaml
  - Remove `hive_generator` from dev_dependencies in pubspec.yaml
  - Run `flutter pub get` to update dependencies
  - _Requirements: 1.2, 1.4_

- [x] 6. Clean up remaining Hive references

  - Search codebase for any remaining Hive imports and remove them
  - Verify no Hive-related code remains in the project
  - _Requirements: 1.1, 1.4_

- [ ]\* 7. Verify implementation
  - Run the application and verify it starts without Hive initialization errors
  - Test sign in flow and verify user data is saved to Isar
  - Test app restart and verify user session persists
  - Test sign out and verify user data is cleared
  - _Requirements: 1.4, 2.1, 2.2, 2.3, 3.4_
