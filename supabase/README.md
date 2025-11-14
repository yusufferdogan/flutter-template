# Supabase Backend Setup Guide

This guide explains how to set up the Supabase backend for the Artifex AI Image Generator application.

## Prerequisites

- Supabase account (sign up at [supabase.com](https://supabase.com))
- Supabase CLI installed (optional, but recommended)
- Flutter SDK installed

## Step 1: Create Supabase Project

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Click "New Project"
3. Fill in project details:
   - **Name**: artifex-ai (or your preferred name)
   - **Database Password**: Choose a strong password
   - **Region**: Select closest to your target users
4. Click "Create new project"
5. Wait for project to initialize (~2 minutes)

## Step 2: Get Project Credentials

1. In your Supabase project dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL**: `https://your-project.supabase.co`
   - **Anon/Public Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
3. Keep these for the next step

## Step 3: Configure Environment Variables

1. Copy `.env.example` to `.env` in the project root:
   ```bash
   cp .env.example .env
   ```

2. Update `.env` with your Supabase credentials:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   ```

3. **Important**: Never commit `.env` to version control!

## Step 4: Run Database Migrations

### Option A: Using Supabase Dashboard (Recommended for beginners)

1. Go to **SQL Editor** in Supabase Dashboard
2. Run each migration file in order:
   - `migrations/001_initial_schema.sql`
   - `migrations/002_rls_policies.sql`
   - `migrations/003_functions_and_triggers.sql`
   - `migrations/004_storage_policies.sql`

3. Click "Run" for each file

### Option B: Using Supabase CLI

```bash
# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your-project-ref

# Run migrations
supabase db push
```

## Step 5: Create Storage Buckets

1. Go to **Storage** in Supabase Dashboard
2. Create three buckets with these configurations:

### Bucket: `generated-images`
- **Public**: No (private)
- **File size limit**: 10 MB
- **Allowed MIME types**: `image/jpeg, image/png, image/webp`

### Bucket: `profile-avatars`
- **Public**: Yes
- **File size limit**: 5 MB
- **Allowed MIME types**: `image/jpeg, image/png`

### Bucket: `templates`
- **Public**: Yes
- **File size limit**: 10 MB
- **Allowed MIME types**: `image/jpeg, image/png, image/webp`

3. After creating buckets, run `migrations/004_storage_policies.sql` in SQL Editor

## Step 6: Configure Authentication

1. Go to **Authentication** → **Settings** in Supabase Dashboard

### Email/Password Auth
- Already enabled by default
- Configure email templates if desired

### Google OAuth (Optional)
1. Go to **Authentication** → **Providers**
2. Enable Google provider
3. Add your Google OAuth credentials:
   - **Client ID**: From Google Cloud Console
   - **Client Secret**: From Google Cloud Console
4. Add redirect URL: `your-app-scheme://login-callback`

### Apple OAuth (Optional)
1. Go to **Authentication** → **Providers**
2. Enable Apple provider
3. Add your Apple OAuth credentials:
   - **Services ID**: From Apple Developer Portal
   - **Key ID**: From Apple Developer Portal
   - **Team ID**: Your Apple Team ID
4. Add redirect URL: `your-app-scheme://login-callback`

## Step 7: Deploy Edge Functions (Optional)

Edge functions are currently not implemented in this initial setup.
They will be added in future iterations for:
- AI image generation
- Subscription webhooks
- Notification delivery
- Image optimization

## Step 8: Seed Initial Data (Optional)

Create sample data for testing:

```sql
-- Insert sample styles
INSERT INTO public.styles (name, type, preview_image_url) VALUES
  ('Photorealistic', 'realistic', 'https://example.com/style1.jpg'),
  ('Anime', 'artistic', 'https://example.com/style2.jpg'),
  ('Oil Painting', 'artistic', 'https://example.com/style3.jpg'),
  ('Digital Art', 'digital', 'https://example.com/style4.jpg'),
  ('Watercolor', 'artistic', 'https://example.com/style5.jpg');

-- Insert sample categories
INSERT INTO public.categories (name, description, preview_image_urls) VALUES
  ('Nature', 'Beautiful natural landscapes', ARRAY['url1.jpg', 'url2.jpg']),
  ('Abstract', 'Abstract and surreal art', ARRAY['url3.jpg', 'url4.jpg']),
  ('Portrait', 'People and portraits', ARRAY['url5.jpg', 'url6.jpg']),
  ('Architecture', 'Buildings and structures', ARRAY['url7.jpg', 'url8.jpg']);
```

## Step 9: Test Connection

Run the Flutter app to test the Supabase connection:

```bash
flutter pub get
flutter run
```

The app should:
- Connect to Supabase successfully
- Allow user registration
- Allow user login
- Store and retrieve user data

## Troubleshooting

### Connection Failed
- Verify SUPABASE_URL and SUPABASE_ANON_KEY in `.env`
- Check that `.env` file is loaded in `main.dart`
- Ensure internet connection is working

### RLS Policy Errors
- Verify all RLS policies are enabled
- Check that user is authenticated before accessing data
- Test policies in Supabase Dashboard → SQL Editor

### Storage Upload Failed
- Verify storage buckets exist
- Check storage policies are applied
- Ensure file size is within limits
- Verify file MIME type is allowed

## Security Best Practices

1. **Never expose Service Role Key** in client code
2. **Always use RLS policies** for data access control
3. **Validate inputs** in edge functions and database functions
4. **Enable MFA** for Supabase admin accounts
5. **Rotate API keys** regularly
6. **Monitor** for suspicious activity in Supabase Dashboard

## Monitoring

Monitor your Supabase project:
1. Go to **Logs** in Supabase Dashboard
2. View database query logs
3. Check edge function logs
4. Monitor storage usage
5. Track authentication events

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Guide](https://supabase.com/docs/guides/storage)
- [Edge Functions](https://supabase.com/docs/guides/functions)

## Support

For issues or questions:
- Check Supabase documentation
- Visit [Supabase Discord](https://discord.supabase.com)
- Create an issue in this repository
