# Design Document - Supabase Backend Integration

## Overview

This document details the technical design for integrating Supabase as the backend infrastructure, including database schema, authentication, storage, edge functions, and security policies.

## Architecture

### System Architecture

```
┌─────────────────────────────────────────────┐
│         Flutter Mobile App                  │
│         (supabase_flutter SDK)              │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│         Supabase Platform                   │
├─────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐        │
│  │   Auth       │  │   Database   │        │
│  │  (GoTrue)    │  │ (PostgreSQL) │        │
│  └──────────────┘  └──────────────┘        │
│  ┌──────────────┐  ┌──────────────┐        │
│  │   Storage    │  │    Edge      │        │
│  │              │  │  Functions   │        │
│  └──────────────┘  └──────────────┘        │
│  ┌──────────────┐  ┌──────────────┐        │
│  │   Realtime   │  │   Webhooks   │        │
│  └──────────────┘  └──────────────┘        │
└─────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│         External Services                   │
│  - AI Image Generation API                  │
│  - Payment Processors                       │
│  - Email Service                            │
└─────────────────────────────────────────────┘
```

## Database Schema

### Tables

#### users

```sql
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  profile_image_url TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  credits INTEGER DEFAULT 10,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_is_premium ON public.users(is_premium);
```

#### generated_images

```sql
CREATE TABLE public.generated_images (
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

-- Indexes
CREATE INDEX idx_generated_images_user_id ON public.generated_images(user_id);
CREATE INDEX idx_generated_images_created_at ON public.generated_images(created_at DESC);
CREATE INDEX idx_generated_images_is_public ON public.generated_images(is_public) WHERE is_public = TRUE;
CREATE INDEX idx_generated_images_style ON public.generated_images(style);
```

#### templates

```sql
CREATE TABLE public.templates (
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

-- Indexes
CREATE INDEX idx_templates_category ON public.templates(category);
CREATE INDEX idx_templates_style ON public.templates(style);
CREATE INDEX idx_templates_usage_count ON public.templates(usage_count DESC);
```

#### styles

```sql
CREATE TABLE public.styles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  type TEXT NOT NULL,
  preview_image_url TEXT NOT NULL,
  usage_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_styles_type ON public.styles(type);
CREATE INDEX idx_styles_usage_count ON public.styles(usage_count DESC);
```

#### categories

```sql
CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  preview_image_urls TEXT[] NOT NULL,
  image_count INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_categories_name ON public.categories(name);
```

#### notifications

```sql
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX idx_notifications_is_read ON public.notifications(user_id, is_read);
```

#### subscriptions

```sql
CREATE TABLE public.subscriptions (
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

-- Indexes
CREATE INDEX idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON public.subscriptions(status);
CREATE UNIQUE INDEX idx_subscriptions_user_active ON public.subscriptions(user_id)
  WHERE status = 'active';
```

#### credit_transactions

```sql
CREATE TABLE public.credit_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  amount INTEGER NOT NULL, -- positive for credit, negative for debit
  transaction_type TEXT NOT NULL, -- purchase, generation, refund, bonus
  description TEXT,
  related_image_id UUID REFERENCES public.generated_images(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_credit_transactions_user_id ON public.credit_transactions(user_id);
CREATE INDEX idx_credit_transactions_created_at ON public.credit_transactions(created_at DESC);
```

## Row Level Security Policies

### users table

```sql
-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
CREATE POLICY "Users can read own data"
  ON public.users FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own data"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);
```

### generated_images table

```sql
-- Enable RLS
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
```

### templates table

```sql
-- Enable RLS
ALTER TABLE public.templates ENABLE ROW LEVEL SECURITY;

-- Anyone can read active templates
CREATE POLICY "Anyone can read active templates"
  ON public.templates FOR SELECT
  USING (is_active = TRUE);
```

### styles table

```sql
-- Enable RLS
ALTER TABLE public.styles ENABLE ROW LEVEL SECURITY;

-- Anyone can read active styles
CREATE POLICY "Anyone can read active styles"
  ON public.styles FOR SELECT
  USING (is_active = TRUE);
```

### notifications table

```sql
-- Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users can read their own notifications
CREATE POLICY "Users can read own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

-- Users can update their own notifications
CREATE POLICY "Users can update own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id);
```

### subscriptions table

```sql
-- Enable RLS
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can read their own subscriptions
CREATE POLICY "Users can read own subscriptions"
  ON public.subscriptions FOR SELECT
  USING (auth.uid() = user_id);
```

### credit_transactions table

```sql
-- Enable RLS
ALTER TABLE public.credit_transactions ENABLE ROW LEVEL SECURITY;

-- Users can read their own transactions
CREATE POLICY "Users can read own transactions"
  ON public.credit_transactions FOR SELECT
  USING (auth.uid() = user_id);
```

## Database Functions

### Create user profile on signup

```sql
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
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### Deduct credits

```sql
CREATE OR REPLACE FUNCTION public.deduct_credits(
  p_user_id UUID,
  p_amount INTEGER,
  p_image_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_current_credits INTEGER;
BEGIN
  -- Get current credits with row lock
  SELECT credits INTO v_current_credits
  FROM public.users
  WHERE id = p_user_id
  FOR UPDATE;

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
  INSERT INTO public.credit_transactions (user_id, amount, transaction_type, related_image_id)
  VALUES (p_user_id, -p_amount, 'generation', p_image_id);

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Update timestamp trigger

```sql
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_subscriptions_updated_at
  BEFORE UPDATE ON public.subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
```

## Storage Buckets

### Configuration

```typescript
// generated-images bucket
{
  name: 'generated-images',
  public: false,
  fileSizeLimit: 10485760, // 10MB
  allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp']
}

// profile-avatars bucket
{
  name: 'profile-avatars',
  public: true,
  fileSizeLimit: 5242880, // 5MB
  allowedMimeTypes: ['image/jpeg', 'image/png']
}

// templates bucket
{
  name: 'templates',
  public: true,
  fileSizeLimit: 10485760, // 10MB
  allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp']
}
```

### Storage Policies

```sql
-- generated-images: Users can upload their own images
CREATE POLICY "Users can upload own images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'generated-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- generated-images: Users can read their own images
CREATE POLICY "Users can read own images"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'generated-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- profile-avatars: Users can upload their own avatar
CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'profile-avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- profile-avatars: Anyone can read avatars (public bucket)
CREATE POLICY "Anyone can read avatars"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profile-avatars');
```

## Edge Functions

### 1. generate-image

```typescript
// supabase/functions/generate-image/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  try {
    const { prompt, style, shape, userId } = await req.json();

    // Create Supabase client
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Check and deduct credits
    const { data: creditCheck } = await supabase.rpc("deduct_credits", {
      p_user_id: userId,
      p_amount: 1,
    });

    if (!creditCheck) {
      return new Response(JSON.stringify({ error: "Insufficient credits" }), {
        status: 402,
      });
    }

    // Call AI API (e.g., Stability AI, DALL-E, etc.)
    const aiResponse = await fetch(Deno.env.get("AI_API_URL")!, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${Deno.env.get("AI_API_KEY")}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ prompt, style, shape }),
    });

    const imageData = await aiResponse.arrayBuffer();

    // Upload to storage
    const fileName = `${userId}/${Date.now()}.png`;
    const { data: uploadData, error: uploadError } = await supabase.storage
      .from("generated-images")
      .upload(fileName, imageData, {
        contentType: "image/png",
      });

    if (uploadError) throw uploadError;

    // Get public URL
    const {
      data: { publicUrl },
    } = supabase.storage.from("generated-images").getPublicUrl(fileName);

    // Save to database
    const { data: imageRecord } = await supabase
      .from("generated_images")
      .insert({
        user_id: userId,
        image_url: publicUrl,
        storage_path: fileName,
        prompt,
        style,
        shape,
      })
      .select()
      .single();

    // Create notification
    await supabase.from("notifications").insert({
      user_id: userId,
      type: "imageReady",
      title: "Your AI image is ready!",
      description:
        "Your masterpiece has been generated—tap to view and download.",
      image_url: publicUrl,
    });

    return new Response(JSON.stringify({ success: true, image: imageRecord }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    });
  }
});
```

### 2. handle-subscription-webhook

```typescript
// supabase/functions/handle-subscription-webhook/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  try {
    const payload = await req.json();

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Handle different webhook events
    switch (payload.type) {
      case "subscription.created":
      case "subscription.updated":
        await supabase.from("subscriptions").upsert({
          user_id: payload.user_id,
          plan_id: payload.plan_id,
          plan_name: payload.plan_name,
          status: payload.status,
          current_period_start: payload.current_period_start,
          current_period_end: payload.current_period_end,
        });

        // Update user premium status
        await supabase
          .from("users")
          .update({
            is_premium: payload.status === "active",
          })
          .eq("id", payload.user_id);
        break;

      case "subscription.deleted":
        await supabase
          .from("users")
          .update({
            is_premium: false,
          })
          .eq("id", payload.user_id);
        break;
    }

    return new Response(JSON.stringify({ success: true }));
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    });
  }
});
```

## Flutter Integration

### Supabase Client Setup

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
    realtimeClientOptions: const RealtimeClientOptions(
      logLevel: RealtimeLogLevel.info,
    ),
  );
}

final supabase = Supabase.instance.client;
```

### Example Usage

```dart
// Authentication
final response = await supabase.auth.signUp(
  email: email,
  password: password,
  data: {'full_name': fullName},
);

// Database query
final images = await supabase
  .from('generated_images')
  .select()
  .eq('user_id', userId)
  .order('created_at', ascending: false);

// Storage upload
final file = File(imagePath);
await supabase.storage
  .from('generated-images')
  .upload('$userId/${DateTime.now().millisecondsSinceEpoch}.png', file);

// Realtime subscription
final subscription = supabase
  .from('notifications')
  .stream(primaryKey: ['id'])
  .eq('user_id', userId)
  .listen((data) {
    // Handle new notifications
  });

// Edge function call
final response = await supabase.functions.invoke(
  'generate-image',
  body: {
    'prompt': prompt,
    'style': style,
    'shape': shape,
    'userId': userId,
  },
);
```

## Security Best Practices

1. **Never expose service role key in client**
2. **Use RLS policies for all tables**
3. **Validate all inputs in edge functions**
4. **Use prepared statements to prevent SQL injection**
5. **Implement rate limiting on edge functions**
6. **Store sensitive data in Supabase secrets**
7. **Enable MFA for admin accounts**
8. **Regularly rotate API keys**
9. **Monitor for suspicious activity**
10. **Keep Supabase client SDK updated**

## Performance Optimization

1. **Create appropriate indexes on frequently queried columns**
2. **Use connection pooling**
3. **Implement caching for static data (styles, templates)**
4. **Use CDN for storage bucket assets**
5. **Optimize image sizes before upload**
6. **Use pagination for large result sets**
7. **Implement database query optimization**
8. **Monitor slow queries and optimize**

## Monitoring and Logging

1. **Enable Supabase logging**
2. **Set up alerts for errors**
3. **Monitor database performance**
4. **Track edge function execution times**
5. **Monitor storage usage**
6. **Track API quota consumption**
7. **Implement custom logging for critical operations**
