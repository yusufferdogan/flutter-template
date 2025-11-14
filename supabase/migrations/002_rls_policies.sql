-- Row Level Security (RLS) Policies
-- This migration enables RLS and creates policies for all tables

-- =============================================================================
-- USERS TABLE RLS POLICIES
-- =============================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
CREATE POLICY "Users can read own data"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own data"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);

-- =============================================================================
-- GENERATED_IMAGES TABLE RLS POLICIES
-- =============================================================================
ALTER TABLE public.generated_images ENABLE ROW LEVEL SECURITY;

-- Users can read their own images
CREATE POLICY "Users can read own images"
  ON public.generated_images FOR SELECT
  USING (auth.uid() = user_id);

-- Users can read public images
CREATE POLICY "Anyone can read public images"
  ON public.generated_images FOR SELECT
  USING (is_public = TRUE);

-- Users can insert their own images
CREATE POLICY "Users can insert own images"
  ON public.generated_images FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own images
CREATE POLICY "Users can update own images"
  ON public.generated_images FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can delete their own images
CREATE POLICY "Users can delete own images"
  ON public.generated_images FOR DELETE
  USING (auth.uid() = user_id);

-- =============================================================================
-- TEMPLATES TABLE RLS POLICIES
-- =============================================================================
ALTER TABLE public.templates ENABLE ROW LEVEL SECURITY;

-- Anyone can read active templates
CREATE POLICY "Anyone can read active templates"
  ON public.templates FOR SELECT
  USING (is_active = TRUE);

-- =============================================================================
-- STYLES TABLE RLS POLICIES
-- =============================================================================
ALTER TABLE public.styles ENABLE ROW LEVEL SECURITY;

-- Anyone can read active styles
CREATE POLICY "Anyone can read active styles"
  ON public.styles FOR SELECT
  USING (is_active = TRUE);

-- =============================================================================
-- CATEGORIES TABLE RLS POLICIES
-- =============================================================================
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- Anyone can read active categories
CREATE POLICY "Anyone can read active categories"
  ON public.categories FOR SELECT
  USING (is_active = TRUE);

-- =============================================================================
-- NOTIFICATIONS TABLE RLS POLICIES
-- =============================================================================
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users can read their own notifications
CREATE POLICY "Users can read own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

-- Users can update their own notifications
CREATE POLICY "Users can update own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- =============================================================================
-- SUBSCRIPTIONS TABLE RLS POLICIES
-- =============================================================================
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can read their own subscriptions
CREATE POLICY "Users can read own subscriptions"
  ON public.subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- =============================================================================
-- CREDIT_TRANSACTIONS TABLE RLS POLICIES
-- =============================================================================
ALTER TABLE public.credit_transactions ENABLE ROW LEVEL SECURITY;

-- Users can read their own transactions
CREATE POLICY "Users can read own transactions"
  ON public.credit_transactions FOR SELECT
  USING (auth.uid() = user_id);
