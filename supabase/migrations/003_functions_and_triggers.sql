-- Database Functions and Triggers
-- This migration creates all necessary functions and triggers

-- =============================================================================
-- FUNCTION: handle_new_user
-- Purpose: Automatically create user profile when auth user is created
-- =============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, full_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    NEW.email
  );
  RETURN NEW;
EXCEPTION
  WHEN others THEN
    -- Log error but don't fail the auth insertion
    RAISE WARNING 'Failed to create user profile: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger: Create user profile on auth user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =============================================================================
-- FUNCTION: deduct_credits
-- Purpose: Deduct credits from user account with transaction safety
-- =============================================================================
CREATE OR REPLACE FUNCTION public.deduct_credits(
  p_user_id UUID,
  p_amount INTEGER,
  p_image_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_current_credits INTEGER;
BEGIN
  -- Get current credits with row lock to prevent race conditions
  SELECT credits INTO v_current_credits
  FROM public.users
  WHERE id = p_user_id
  FOR UPDATE;

  -- Check if user exists
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found: %', p_user_id;
  END IF;

  -- Check if user has enough credits
  IF v_current_credits < p_amount THEN
    RETURN FALSE;
  END IF;

  -- Deduct credits
  UPDATE public.users
  SET credits = credits - p_amount,
      updated_at = NOW()
  WHERE id = p_user_id;

  -- Record transaction
  INSERT INTO public.credit_transactions (user_id, amount, transaction_type, description, related_image_id)
  VALUES (p_user_id, -p_amount, 'generation', 'Image generation', p_image_id);

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: add_credits
-- Purpose: Add credits to user account
-- =============================================================================
CREATE OR REPLACE FUNCTION public.add_credits(
  p_user_id UUID,
  p_amount INTEGER,
  p_transaction_type TEXT,
  p_description TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
BEGIN
  -- Add credits
  UPDATE public.users
  SET credits = credits + p_amount,
      updated_at = NOW()
  WHERE id = p_user_id;

  -- Check if user exists
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User not found: %', p_user_id;
  END IF;

  -- Record transaction
  INSERT INTO public.credit_transactions (user_id, amount, transaction_type, description)
  VALUES (p_user_id, p_amount, p_transaction_type, p_description);

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: update_updated_at
-- Purpose: Automatically update updated_at timestamp
-- =============================================================================
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updating updated_at timestamps
DROP TRIGGER IF EXISTS update_users_updated_at ON public.users;
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

DROP TRIGGER IF EXISTS update_subscriptions_updated_at ON public.subscriptions;
CREATE TRIGGER update_subscriptions_updated_at
  BEFORE UPDATE ON public.subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- =============================================================================
-- FUNCTION: get_user_stats
-- Purpose: Calculate user statistics
-- =============================================================================
CREATE OR REPLACE FUNCTION public.get_user_stats(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  v_stats JSON;
BEGIN
  SELECT json_build_object(
    'total_images', COUNT(*),
    'public_images', COUNT(*) FILTER (WHERE is_public = TRUE),
    'total_likes', COALESCE(SUM(likes_count), 0),
    'latest_image_date', MAX(created_at)
  )
  INTO v_stats
  FROM public.generated_images
  WHERE user_id = p_user_id;

  RETURN v_stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: get_unread_notifications_count
-- Purpose: Get count of unread notifications for a user
-- =============================================================================
CREATE OR REPLACE FUNCTION public.get_unread_notifications_count(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM public.notifications
  WHERE user_id = p_user_id AND is_read = FALSE;

  RETURN COALESCE(v_count, 0);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: mark_all_notifications_read
-- Purpose: Mark all notifications as read for a user
-- =============================================================================
CREATE OR REPLACE FUNCTION public.mark_all_notifications_read(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE public.notifications
  SET is_read = TRUE
  WHERE user_id = p_user_id AND is_read = FALSE;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: increment_template_usage
-- Purpose: Increment usage count for a template
-- =============================================================================
CREATE OR REPLACE FUNCTION public.increment_template_usage(p_template_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE public.templates
  SET usage_count = usage_count + 1
  WHERE id = p_template_id;

  RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- FUNCTION: increment_style_usage
-- Purpose: Increment usage count for a style
-- =============================================================================
CREATE OR REPLACE FUNCTION public.increment_style_usage(p_style_name TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE public.styles
  SET usage_count = usage_count + 1
  WHERE name = p_style_name;

  RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
