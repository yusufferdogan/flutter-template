# Supabase Integration Guide

This document explains the Supabase backend integration for the Artifex AI Image Generator application.

## Overview

The application now supports Supabase as the primary backend infrastructure, providing:

- **Authentication**: Email/password, Google OAuth, Apple OAuth
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Storage**: Cloud storage for images and avatars
- **Realtime**: WebSocket-based real-time data sync
- **Edge Functions**: Serverless functions for backend logic (coming soon)

## Architecture

The Supabase integration follows a clean architecture pattern:

```
lib/
├── core/
│   └── supabase/
│       └── supabase_config.dart          # Supabase client configuration
├── features/
│   └── authentication/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── supabase_auth_remote_datasource.dart  # Supabase auth datasource
│       │   │   └── auth_remote_datasource.dart           # Original Dio datasource
│       │   └── repositories/
│       │       ├── supabase_auth_repository_impl.dart    # Supabase repository
│       │       └── auth_repository_impl.dart             # Original repository
│       └── domain/
│           └── repositories/
│               └── auth_repository.dart                   # Interface
supabase/
├── migrations/
│   ├── 001_initial_schema.sql              # Database tables
│   ├── 002_rls_policies.sql                # Row Level Security
│   ├── 003_functions_and_triggers.sql      # Database functions
│   └── 004_storage_policies.sql            # Storage access policies
└── README.md                                # Setup guide
```

## Quick Start

### 1. Install Dependencies

The Supabase Flutter SDK has been added to `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

Run:
```bash
flutter pub get
```

### 2. Set Up Supabase Project

Follow the detailed guide in [`supabase/README.md`](supabase/README.md) to:

1. Create a Supabase project
2. Run database migrations
3. Create storage buckets
4. Configure authentication providers

### 3. Configure Environment Variables

Copy `.env.example` to `.env` and add your Supabase credentials:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

### 4. Switch to Supabase Implementation

Update the dependency injection in `lib/di/Injector.dart`:

**Option A: Use Supabase for Authentication**

```dart
import 'package:filmku/features/authentication/data/datasources/supabase_auth_remote_datasource.dart';
import 'package:filmku/features/authentication/data/repositories/supabase_auth_repository_impl.dart';

void provideDataSources() {
  // ... other datasources

  //Authentication - Using Supabase
  injector.registerFactory<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(
      secureStorage: injector.get<FlutterSecureStorage>(),
      box: injector.get<Box>()));
  injector.registerFactory<AuthRemoteDataSource>(
      () => SupabaseAuthRemoteDataSource());
}

void provideRepositories() {
  // ... other repositories

  //Authentication - Using Supabase
  injector.registerFactory<AuthRepository>(() => SupabaseAuthRepositoryImpl(
      remoteDataSource: injector.get<AuthRemoteDataSource>() as SupabaseAuthRemoteDataSource,
      localDataSource: injector.get<AuthLocalDataSource>()));
}
```

**Option B: Keep Original Dio Implementation**

If you want to keep the existing Dio-based implementation, you don't need to change anything. The Supabase implementation coexists with the original.

## Features Implemented

### ✅ Completed

1. **Database Schema**
   - Users table with credits tracking
   - Generated images table with metadata
   - Templates and styles tables
   - Categories table
   - Notifications table
   - Subscriptions table
   - Credit transactions table

2. **Row Level Security (RLS)**
   - User data protection
   - Image ownership policies
   - Public template access
   - Notification privacy

3. **Database Functions**
   - Auto-create user profile on signup
   - Credit deduction with transaction safety
   - User statistics calculation
   - Notification management
   - Usage tracking for templates and styles

4. **Authentication**
   - Email/password authentication
   - Google OAuth integration
   - Apple OAuth integration
   - Session management
   - Token refresh

5. **Flutter Integration**
   - Supabase client configuration
   - Auth remote datasource
   - Auth repository implementation
   - Automatic initialization

### 🚧 Pending

1. **Storage Implementation**
   - Image upload service
   - Profile avatar management
   - Template storage

2. **Edge Functions**
   - AI image generation
   - Subscription webhooks
   - Notification delivery
   - Image optimization

3. **Realtime Features**
   - Real-time notifications
   - Image generation status updates

4. **Additional Features**
   - Image exploration feed
   - User profiles
   - Subscription management
   - Credit purchases

## Database Schema

### Key Tables

#### users
- User account information
- Premium status and credits
- Profile image URL

#### generated_images
- AI-generated image metadata
- User ownership
- Public/private visibility
- Likes count

#### notifications
- User notifications
- Read/unread status
- Related image references

#### credit_transactions
- Credit purchase/usage history
- Transaction types: purchase, generation, refund, bonus

For complete schema details, see `supabase/migrations/001_initial_schema.sql`.

## Security

### Row Level Security (RLS)

All tables have RLS enabled with policies ensuring:

- Users can only read/update their own data
- Public templates and styles are readable by all
- Images respect public/private visibility
- Notifications are private to each user

### Best Practices

1. **Never expose Service Role Key** in client code
2. **Always use RLS policies** for data access control
3. **Validate all inputs** on the server side
4. **Use secure storage** for sensitive tokens
5. **Enable MFA** for Supabase admin accounts

## API Usage

### Authentication

```dart
// Sign up
final result = await authRepository.signUp(
  fullName: 'John Doe',
  email: 'john@example.com',
  password: 'securePassword123',
);

// Sign in
final result = await authRepository.signIn(
  email: 'john@example.com',
  password: 'securePassword123',
);

// Sign in with Google
final result = await authRepository.signInWithGoogle();

// Sign out
await authRepository.signOut();
```

### Database Queries

```dart
// Get user images
final images = await supabase
  .from('generated_images')
  .select()
  .eq('user_id', userId)
  .order('created_at', ascending: false);

// Get public images (explore feed)
final publicImages = await supabase
  .from('generated_images')
  .select()
  .eq('is_public', true)
  .order('created_at', ascending: false)
  .limit(20);

// Get user stats
final stats = await supabase.rpc('get_user_stats', params: {
  'p_user_id': userId,
});
```

### Database Functions

```dart
// Deduct credits
final success = await supabase.rpc('deduct_credits', params: {
  'p_user_id': userId,
  'p_amount': 1,
  'p_image_id': imageId,
});

// Mark all notifications as read
await supabase.rpc('mark_all_notifications_read', params: {
  'p_user_id': userId,
});
```

## Testing

### Test Supabase Connection

```dart
// In your test or debug code
final response = await SupabaseConfig.client.from('users').select().limit(1);
print('Supabase connected: $response');
```

### Test Authentication

```dart
// Test sign up
final result = await authRepository.signUp(
  fullName: 'Test User',
  email: 'test@example.com',
  password: 'password123',
);

result.fold(
  (failure) => print('Sign up failed: $failure'),
  (user) => print('Sign up successful: ${user.email}'),
);
```

## Troubleshooting

### Common Issues

1. **"SUPABASE_URL not found in .env file"**
   - Ensure `.env` file exists in project root
   - Verify it contains `SUPABASE_URL` and `SUPABASE_ANON_KEY`
   - Make sure `await dotenv.load()` runs before Supabase initialization

2. **"Row Level Security policy violation"**
   - Check that RLS policies are properly set up
   - Verify user is authenticated before accessing data
   - Review policy SQL in `supabase/migrations/002_rls_policies.sql`

3. **"Failed to create user profile"**
   - Ensure the `handle_new_user` trigger is created
   - Check Supabase logs for errors
   - Verify `users` table exists

4. **OAuth not working**
   - Configure OAuth providers in Supabase Dashboard
   - Set up correct redirect URLs
   - Verify OAuth credentials are valid

## Migration from Dio to Supabase

If you're migrating from the original Dio implementation:

1. **Data Migration**: Export existing user data and import to Supabase
2. **Update Injector**: Switch datasources and repositories
3. **Test Authentication**: Verify all auth flows work
4. **Update API Calls**: Replace Dio calls with Supabase queries
5. **Remove Old Code**: Clean up unused Dio implementations (optional)

## Next Steps

1. **Implement Storage Features**
   - Create storage service for image uploads
   - Add profile avatar management

2. **Add Edge Functions**
   - Deploy AI image generation function
   - Set up webhook handlers

3. **Implement Realtime**
   - Add notification subscriptions
   - Real-time image generation status

4. **Complete Features**
   - Explore feed
   - User profiles
   - Subscription management

## Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Setup Guide](supabase/README.md)
- [Database Schema](supabase/migrations/)

## Support

For issues or questions:
- Check the [troubleshooting section](#troubleshooting)
- Review Supabase documentation
- Visit [Supabase Discord](https://discord.supabase.com)
- Create an issue in this repository
