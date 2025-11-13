# Implementation Plan - Supabase Backend Integration

## Overview

This implementation plan covers setting up Supabase as the backend infrastructure, including database schema, authentication, storage, edge functions, and security policies.

---

## Tasks

- [ ] 1. Supabase Project Setup

  - Create new Supabase project
  - Configure project settings and region
  - Set up custom domain (optional)
  - Configure CORS settings for mobile app
  - _Requirements: All_

- [ ] 2. Database Schema Creation

  - Create `users` table with indexes
  - Create `generated_images` table with indexes
  - Create `templates` table with indexes
  - Create `styles` table with indexes
  - Create `categories` table with indexes
  - Create `notifications` table with indexes
  - Create `subscriptions` table with indexes
  - Create `credit_transactions` table with indexes
  - Establish foreign key relationships
  - _Requirements: 1_

- [ ] 3. Row Level Security Setup

  - Enable RLS on all tables
  - Create RLS policy for users table (read/update own data)
  - Create RLS policies for generated_images table (CRUD own images, read public)
  - Create RLS policy for templates table (read active templates)
  - Create RLS policy for styles table (read active styles)
  - Create RLS policy for notifications table (read/update own notifications)
  - Create RLS policy for subscriptions table (read own subscriptions)
  - Create RLS policy for credit_transactions table (read own transactions)
  - Test all RLS policies
  - _Requirements: 5_

- [ ] 4. Database Functions and Triggers

  - Create `handle_new_user()` function and trigger for auto profile creation
  - Create `deduct_credits()` function with transaction support
  - Create `update_updated_at()` function and triggers
  - Create function to calculate user statistics
  - Create function to clean up expired sessions
  - Create function to aggregate notification counts
  - Test all functions and triggers
  - _Requirements: 7_

- [ ] 5. Authentication Configuration

  - Configure email/password authentication
  - Set up email templates (verification, password reset)
  - Enable Google OAuth provider
  - Configure Google OAuth credentials
  - Enable Apple OAuth provider
  - Configure Apple OAuth credentials
  - Set JWT expiration and refresh policies
  - Configure redirect URLs for mobile app
  - Test authentication flows
  - _Requirements: 2_

- [ ] 6. Storage Bucket Setup

  - Create `generated-images` bucket with 10MB limit
  - Create `profile-avatars` bucket with 5MB limit
  - Create `templates` bucket with 10MB limit
  - Configure allowed MIME types for each bucket
  - Set up storage policies for generated-images bucket
  - Set up storage policies for profile-avatars bucket
  - Set up storage policies for templates bucket
  - Enable image transformation
  - Test file upload and access
  - _Requirements: 3_

- [ ] 7. Edge Function: generate-image

  - Create edge function project structure
  - Implement credit validation logic
  - Integrate with AI image generation API
  - Implement image upload to storage
  - Save image metadata to database
  - Create notification on completion
  - Add error handling and logging
  - Implement retry logic for API failures
  - Deploy and test edge function
  - _Requirements: 4, 8_

- [ ] 8. Edge Function: handle-subscription-webhook

  - Create webhook handler function
  - Implement subscription.created event handler
  - Implement subscription.updated event handler
  - Implement subscription.deleted event handler
  - Update user premium status
  - Add webhook signature verification
  - Add error handling and logging
  - Deploy and test webhook handler
  - _Requirements: 4_

- [ ] 9. Edge Function: process-notification

  - Create notification delivery function
  - Implement push notification integration
  - Add notification batching logic
  - Implement notification preferences
  - Add error handling and logging
  - Deploy and test function
  - _Requirements: 4_

- [ ] 10. Edge Function: optimize-image

  - Create image processing function
  - Implement image resizing
  - Implement image compression
  - Implement format conversion (WebP)
  - Add watermark for free users (optional)
  - Add error handling and logging
  - Deploy and test function
  - _Requirements: 4_

- [ ] 11. Realtime Configuration

  - Enable realtime for notifications table
  - Enable realtime for generated_images table
  - Configure realtime authorization
  - Set up realtime channels
  - Test realtime subscriptions
  - _Requirements: 6_

- [ ] 12. Flutter SDK Integration

  - Add supabase_flutter dependency
  - Initialize Supabase client in main.dart
  - Configure auth flow type (PKCE)
  - Set up deep linking for OAuth
  - Create Supabase service wrapper
  - Implement error handling for Supabase calls
  - _Requirements: All_

- [ ] 13. Implement Data Sources with Supabase

  - Update AuthRemoteDataSource to use Supabase Auth
  - Update HomeRemoteDataSource to use Supabase database
  - Update GenerationRemoteDataSource to use Supabase functions
  - Update ExploreRemoteDataSource to use Supabase database
  - Update NotificationRemoteDataSource to use Supabase realtime
  - Update ProfileRemoteDataSource to use Supabase database
  - Update SubscriptionRemoteDataSource to use Supabase database
  - _Requirements: All_

- [ ] 14. Implement Storage Integration

  - Create storage service for image uploads
  - Implement image upload with progress tracking
  - Implement image download
  - Implement image deletion
  - Add image caching strategy
  - Handle storage errors
  - _Requirements: 3_

- [ ] 15. Seed Initial Data

  - Create SQL script to seed styles table
  - Create SQL script to seed templates table
  - Create SQL script to seed categories table
  - Upload template preview images to storage
  - Upload style preview images to storage
  - Run seed scripts on Supabase
  - _Requirements: 1_

- [ ] 16. Environment Configuration

  - Set up environment variables for Supabase URL and keys
  - Configure different environments (dev, staging, prod)
  - Store AI API keys in Supabase secrets
  - Store OAuth credentials in Supabase secrets
  - Document environment setup
  - _Requirements: 8_

- [ ] 17. Backup and Recovery Setup

  - Enable automatic daily backups
  - Configure point-in-time recovery
  - Enable storage bucket versioning
  - Set backup retention policy (30 days)
  - Document recovery procedures
  - Test backup restoration
  - _Requirements: 9_

- [ ] 18. Monitoring and Logging Setup

  - Enable Supabase logging for database queries
  - Enable logging for edge function executions
  - Set up alerts for error rates
  - Set up alerts for performance issues
  - Configure custom logging for critical operations
  - Set up dashboard for monitoring
  - _Requirements: 10_

- [ ] 19. Security Hardening

  - Review and test all RLS policies
  - Implement rate limiting on edge functions
  - Enable MFA for admin accounts
  - Rotate API keys
  - Review storage bucket permissions
  - Implement input validation in edge functions
  - Conduct security audit
  - _Requirements: 5_

- [ ] 20. Performance Optimization

  - Analyze slow queries and add indexes
  - Implement connection pooling
  - Set up CDN for storage assets
  - Optimize edge function cold starts
  - Implement caching for static data
  - Test and optimize database queries
  - _Requirements: All_

- [ ] 21. Documentation

  - Document database schema
  - Document API endpoints (edge functions)
  - Document RLS policies
  - Document storage bucket structure
  - Create developer setup guide
  - Create deployment guide
  - _Requirements: All_

- [ ] 22. Testing

  - Write integration tests for database operations
  - Write tests for edge functions
  - Test authentication flows
  - Test storage operations
  - Test realtime subscriptions
  - Test RLS policies
  - Perform load testing
  - _Requirements: All_

- [ ] 23. Migration Scripts

  - Create migration script for schema changes
  - Create rollback scripts
  - Test migrations on staging
  - Document migration procedures
  - _Requirements: 1_

- [ ] 24. Production Deployment
  - Review all configurations
  - Run final tests on staging
  - Deploy to production
  - Verify all services are running
  - Monitor for issues
  - _Requirements: All_

---

## Notes

- Complete tasks in order for proper dependency management
- Test each component thoroughly before moving to next
- Keep Supabase documentation handy for reference
- Use Supabase CLI for local development and testing
- Implement proper error handling at each layer
- Monitor costs and optimize resource usage
- Follow Supabase best practices for security and performance
