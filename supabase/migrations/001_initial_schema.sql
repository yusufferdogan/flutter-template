-- Initial Database Schema for Artifex AI Image Generator
-- This migration creates all necessary tables for the application

-- =============================================================================
-- TABLE: users
-- Purpose: Store user account information
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  profile_image_url TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  credits INTEGER DEFAULT 10,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for users table
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_users_is_premium ON public.users(is_premium);

-- =============================================================================
-- TABLE: generated_images
-- Purpose: Store AI-generated image metadata
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.generated_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  storage_path TEXT NOT NULL,
  prompt TEXT NOT NULL,
  style TEXT NOT NULL,
  shape TEXT NOT NULL,
  is_public BOOLEAN DEFAULT FALSE,
  likes_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for generated_images table
CREATE INDEX IF NOT EXISTS idx_generated_images_user_id ON public.generated_images(user_id);
CREATE INDEX IF NOT EXISTS idx_generated_images_created_at ON public.generated_images(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_generated_images_is_public ON public.generated_images(is_public) WHERE is_public = TRUE;
CREATE INDEX IF NOT EXISTS idx_generated_images_style ON public.generated_images(style);

-- =============================================================================
-- TABLE: templates
-- Purpose: Store pre-made image templates
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  prompt TEXT NOT NULL,
  preview_image_url TEXT NOT NULL,
  style TEXT NOT NULL,
  category TEXT NOT NULL,
  usage_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for templates table
CREATE INDEX IF NOT EXISTS idx_templates_category ON public.templates(category);
CREATE INDEX IF NOT EXISTS idx_templates_style ON public.templates(style);
CREATE INDEX IF NOT EXISTS idx_templates_usage_count ON public.templates(usage_count DESC);

-- =============================================================================
-- TABLE: styles
-- Purpose: Store available art styles
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.styles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  type TEXT NOT NULL,
  preview_image_url TEXT NOT NULL,
  usage_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for styles table
CREATE INDEX IF NOT EXISTS idx_styles_type ON public.styles(type);
CREATE INDEX IF NOT EXISTS idx_styles_usage_count ON public.styles(usage_count DESC);

-- =============================================================================
-- TABLE: categories
-- Purpose: Store image categories
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  preview_image_urls TEXT[] NOT NULL,
  image_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for categories table
CREATE INDEX IF NOT EXISTS idx_categories_name ON public.categories(name);

-- =============================================================================
-- TABLE: notifications
-- Purpose: Store user notifications
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for notifications table
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(user_id, is_read);

-- =============================================================================
-- TABLE: subscriptions
-- Purpose: Store user subscription information
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  plan_id TEXT NOT NULL,
  plan_name TEXT NOT NULL,
  status TEXT NOT NULL, -- active, cancelled, expired
  current_period_start TIMESTAMPTZ NOT NULL,
  current_period_end TIMESTAMPTZ NOT NULL,
  cancel_at_period_end BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for subscriptions table
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON public.subscriptions(status);
CREATE UNIQUE INDEX IF NOT EXISTS idx_subscriptions_user_active ON public.subscriptions(user_id)
  WHERE status = 'active';

-- =============================================================================
-- TABLE: credit_transactions
-- Purpose: Track user credit transactions
-- =============================================================================
CREATE TABLE IF NOT EXISTS public.credit_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  amount INTEGER NOT NULL, -- positive for credit, negative for debit
  transaction_type TEXT NOT NULL, -- purchase, generation, refund, bonus
  description TEXT,
  related_image_id UUID REFERENCES public.generated_images(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for credit_transactions table
CREATE INDEX IF NOT EXISTS idx_credit_transactions_user_id ON public.credit_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_credit_transactions_created_at ON public.credit_transactions(created_at DESC);
