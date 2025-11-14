-- Storage Bucket Policies
-- This migration creates storage buckets and their access policies

-- Note: Storage buckets must be created manually in Supabase Dashboard or via CLI
-- This script only creates the policies

-- =============================================================================
-- STORAGE BUCKET: generated-images
-- Bucket Configuration:
--   - Name: generated-images
--   - Public: false
--   - File size limit: 10MB
--   - Allowed MIME types: image/jpeg, image/png, image/webp
-- =============================================================================

-- Policy: Users can upload their own images
-- Path structure: {user_id}/{timestamp}.{extension}
CREATE POLICY "Users can upload own images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'generated-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Policy: Users can read their own images
CREATE POLICY "Users can read own images"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'generated-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Policy: Users can update their own images
CREATE POLICY "Users can update own images"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'generated-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Policy: Users can delete their own images
CREATE POLICY "Users can delete own images"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'generated-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- =============================================================================
-- STORAGE BUCKET: profile-avatars
-- Bucket Configuration:
--   - Name: profile-avatars
--   - Public: true
--   - File size limit: 5MB
--   - Allowed MIME types: image/jpeg, image/png
-- =============================================================================

-- Policy: Users can upload their own avatar
-- Path structure: {user_id}/avatar.{extension}
CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'profile-avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Policy: Anyone can read avatars (public bucket)
CREATE POLICY "Anyone can read avatars"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profile-avatars');

-- Policy: Users can update their own avatar
CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'profile-avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Policy: Users can delete their own avatar
CREATE POLICY "Users can delete own avatar"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'profile-avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- =============================================================================
-- STORAGE BUCKET: templates
-- Bucket Configuration:
--   - Name: templates
--   - Public: true
--   - File size limit: 10MB
--   - Allowed MIME types: image/jpeg, image/png, image/webp
-- =============================================================================

-- Policy: Anyone can read template images
CREATE POLICY "Anyone can read template images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'templates');

-- Note: Only admins should be able to upload/update/delete templates
-- This should be done via Supabase Dashboard or service role key
