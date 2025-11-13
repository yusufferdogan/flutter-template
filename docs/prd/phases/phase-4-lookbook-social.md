# Phase 4: Lookbook Creator & Social Features

**Phase Duration:** 8-10 weeks
**Priority:** P1 (Should Have)
**Dependencies:** Phase 1-3 complete
**Status:** Planning

---

## Executive Summary

Phase 4 transforms the app into a social platform where users create, curate, and share their winter beauty and style collections. The Lookbook Creator automates content creation, while social features enable community discovery and viral growth.

**Primary Goal**: Drive organic user acquisition through social sharing and create a sticky content creation/consumption loop.

**Success Criteria**:
- 40%+ users create ≥1 lookbook
- 25%+ share on social media
- 3x increase in organic user acquisition
- 5+ looks saved per active user
- 60%+ week-1 retention (up from 40% baseline)

---

## Problem Statement

### User Needs

1. **Content Creation Desire**: 68% of beauty enthusiasts want to create/share looks (Tribe Dynamics)
2. **Social Proof**: Users trust peer recommendations over brand ads (92% - Nielsen)
3. **Discovery**: Need inspiration from real people with similar features
4. **Organization**: Want to save and organize favorite looks
5. **Virality**: Brands see 4x ROI from user-generated content (Stackla)

### Market Opportunity

- **Beauty UGC**: Engagement rate 6.9x higher than brand content (Tribe Dynamics)
- **Social Commerce**: 54% of social media users research products on platforms (GlobalWebIndex)
- **TikTok Beauty**: #BeautyTok has 300B+ views; virtual try-on content dominates

---

## Feature Requirements

### 1. Auto-Generated Lookbooks (P0)

**Description**: Automatically create shareable lookbooks from user's saved looks.

**Lookbook Types**:

**1. Collage Lookbook** (Grid Layout):
- 2x2 or 3x3 grid of saved look photos
- Each photo shows user with different makeup/outfit
- Title overlay: User's name + "Winter Looks 2025"
- Subtle snow/winter graphic elements
- App branding (small logo in corner)

**2. Carousel Lookbook** (Swipeable):
- 5-10 slides, one look per slide
- Each slide: Photo + look name + product list
- Transition animations (fade, slide)
- Last slide: Call-to-action ("Download the app!")

**3. Video Reel** (15-30 seconds):
- Slideshow of looks with smooth transitions
- Background music (licensed or user-selected)
- Text overlays with look names
- Hashtags at end (#WinterGlam #VirtualMakeup)

**Auto-Generation Flow**:
1. User has 3+ saved looks
2. App prompts: "Create your winter lookbook?"
3. User taps "Yes"
4. Template selector appears (3 layouts)
5. User selects "Collage"
6. Customization screen:
   - Title text (editable)
   - Background pattern (5 options)
   - Color scheme (auto-matches looks)
7. Preview generated in <3 seconds
8. User can regenerate or customize further
9. Finalize → Save to device + in-app gallery

**Technical Implementation**:
```dart
class LookbookGenerator {
  Future<ui.Image> generateCollage(List<Look> looks, LookbookTemplate template) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Draw background
    _drawBackground(canvas, template.backgroundPattern);
    
    // Layout photos in grid
    for (var i = 0; i < looks.length; i++) {
      final photo = await _loadImage(looks[i].photoPath);
      final position = template.grid.getPosition(i);
      canvas.drawImageRect(photo, position, Paint());
    }
    
    // Add overlays (title, graphics)
    _drawOverlays(canvas, template);
    
    final picture = recorder.endRecording();
    return await picture.toImage(1080, 1350);  // Instagram dimensions
  }
}
```

**Acceptance Criteria**:
- [ ] Lookbook generation completes in <5 seconds
- [ ] Output image is high-res (1080×1350 minimum)
- [ ] All templates look polished (no pixelation, alignment issues)
- [ ] User can edit text and colors before finalizing

---

### 2. Social Media Sharing (P0)

**Description**: One-tap sharing to Instagram, TikTok, Pinterest, Snapchat.

**Sharing Options**:

**Instagram**:
- **Feed Post**: Export lookbook image, open Instagram with pre-filled caption
- **Stories**: Export with optimized dimensions (1080×1920), include stickers
- **Reels**: Export video lookbook (15-30s)

**TikTok**:
- Export video reel with trending audio suggestion
- Pre-filled hashtags: #VirtualMakeup #WinterBeauty #ARfilter

**Pinterest**:
- Export as Pin (vertical image, rich description)
- Auto-tagged with relevant categories (Beauty, Fashion, Winter Style)

**Snapchat**:
- Export as Snap with AR lens label
- Option to save to Memories

**Technical Implementation**:
- Use native share sheets (`share_plus` Flutter plugin)
- Deep linking where possible (Instagram Stories API)
- Fallback: Save to device photos + prompt manual share

**Caption Templates**:
```
"Trying out winter glam looks with [App Name]! ❄️✨ Which is your fave? 1, 2, or 3? #WinterMakeup #VirtualTryOn #BeautyTech"
```

**Tracking**:
- Count shares via analytics events
- Track installs from shared content (UTM parameters in bio links)
- Measure virality coefficient (K-factor)

**Acceptance Criteria**:
- [ ] Share buttons work for all platforms
- [ ] Captions pre-populated with hashtags
- [ ] Shared content includes app branding (logo watermark)
- [ ] >25% of users share ≥1 lookbook

---

### 3. In-App Look Discovery Feed (P1)

**Description**: Browse community-created looks for inspiration.

**Feed Features**:

**Content Sources**:
- User-generated looks (public profile users)
- Featured/curated looks (team-selected)
- Trending looks (most tried/saved this week)

**Feed UI**:
- Infinite scroll (Pinterest-style masonry grid)
- Each card: Photo thumbnail, creator name, look name, # of tries
- Tap to view detail:
  - Full photo
  - Makeup products used
  - Outfit items (if applicable)
  - "Try This Look" button
  - Save/Like buttons

**Personalization**:
- Recommend looks based on user's skin tone
- Surface looks from similar style preferences
- Show looks from followed creators (if social features enabled)

**Content Moderation**:
- User-reported content review
- Auto-filter inappropriate images (ML-based)
- Community guidelines enforcement

**Acceptance Criteria**:
- [ ] Feed loads instantly (skeleton screens)
- [ ] "Try This Look" applies look to user's AR view
- [ ] Users can save looks to their collection
- [ ] Moderation queue reviewed within 24 hours

---

### 4. User Profiles & Collections (P0)

**Description**: Personal profile pages with saved looks, wishlist, and followers.

**Profile Components**:

**Header**:
- Profile photo (optional, avatar default)
- Username
- Bio (100 characters)
- Stats: # Looks Created | # Followers | # Following

**Tabs**:
1. **My Looks**: Grid of user's created looks (photos)
2. **Saved**: Looks saved from discovery feed
3. **Wishlist**: Products marked for purchase

**Privacy Settings**:
- Public profile (default) vs Private
- Control who can see looks (Everyone, Followers, Only Me)

**Profile Creation Flow**:
- Optional during onboarding (skip allowed)
- Required for sharing to discovery feed
- Username uniqueness check
- Profile photo upload or choose avatar

**Acceptance Criteria**:
- [ ] Profile creation <2 minutes
- [ ] Username availability checked in real-time
- [ ] Privacy settings honored (private profiles not in feed)
- [ ] Profile editable anytime from settings

---

### 5. Fantasy Portrait Effects "Snow Queen Mode" (P1)

**Description**: Transform selfies into cinematic winter-themed art.

**Effects**:

**1. Frozen Queen**:
- Icy blue overlay with frost particles
- Snowflake crown illustration
- Glowing eyes effect
- Soft-focus background blur

**2. Winter Forest Muse**:
- Evergreen trees in background (composited)
- Falling snow animation
- Warm golden glow (magic hour lighting)

**3. Fireplace Glow**:
- Warm orange/amber lighting from side
- Bokeh light particles
- Cozy, intimate vibe

**Implementation**:
- Apply as post-process filter (after AR makeup)
- Use blend modes and particle systems
- Render at 1080p minimum

**UI Flow**:
1. User captures photo with makeup look
2. In edit screen, tap "Fantasy Effects" tab
3. Preview each effect with thumbnail
4. Tap to apply, intensity slider appears
5. Save enhanced photo

**Acceptance Criteria**:
- [ ] 5 fantasy effects available
- [ ] Effects render in <2 seconds
- [ ] Output looks professional (no artifacts)
- [ ] 20%+ users try fantasy effects

---

### 6. Look Tagging & Search (P1)

**Description**: Tag looks with keywords and search community looks.

**Tagging**:
- Auto-tags: Makeup look name, season (winter), aesthetic
- User tags: Add custom tags (e.g., "date night", "glam", "natural")
- Product tags: Link to specific products used

**Search**:
- Search bar on discovery feed
- Filters: Skin tone, aesthetic, occasion, products
- Autocomplete suggestions

**Implementation**:
- Elasticsearch or Algolia for fast search
- Index: Look name, tags, creator name, products

**Acceptance Criteria**:
- [ ] Search returns results in <500ms
- [ ] At least 10 auto-tags per look
- [ ] Users can add 5+ custom tags

---

### 7. Challenges & Campaigns (P2)

**Description**: Branded hashtag challenges to drive engagement.

**Examples**:
- **#WinterGlamChallenge**: Create 3 winter looks, share with hashtag
- **#SnowQueenContest**: Best fantasy portrait wins prize
- **Brand Partnerships**: e.g., "Try Fenty Winter Edit Challenge"

**Mechanics**:
- In-app banner promotes challenge
- Participation: Create look, tag with hashtag, share
- Leaderboard: Most liked looks
- Prizes: Gift cards, featured placement, product bundles

**Acceptance Criteria**:
- [ ] Challenge landing page with details
- [ ] Submissions tracked via hashtag
- [ ] Leaderboard updates daily
- [ ] 10%+ user participation rate

---

## Technical Implementation

### Lookbook Generation (Image Processing)

**Libraries**:
- `image` package for canvas manipulation
- `flutter_native_image` for compression
- `video_player` & `ffmpeg` for video reels

**Performance**:
- Background thread for generation (avoid UI jank)
- Caching: Save generated lookbooks to avoid re-rendering

### Social Sharing

**Plugins**:
- `share_plus`: Cross-platform sharing
- `uni_links`: Deep linking from social media
- `flutter_native_splash`: Branded splash for new users from social

**Attribution**:
- Branch.io or Firebase Dynamic Links
- Track install source (Instagram, TikTok, etc.)
- Reward referrers (future: referral program)

### Discovery Feed Backend

**API Endpoints**:
- `GET /api/v1/feed` (paginated, personalized)
- `GET /api/v1/looks/:id` (look details)
- `POST /api/v1/looks` (upload new look)
- `POST /api/v1/looks/:id/like`
- `POST /api/v1/looks/:id/report`

**Database Schema**:
```sql
CREATE TABLE looks (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    title VARCHAR,
    description TEXT,
    image_url VARCHAR,
    makeup_look_id VARCHAR,
    products JSONB,  -- Array of product IDs
    tags VARCHAR[],
    is_public BOOLEAN DEFAULT true,
    likes_count INT DEFAULT 0,
    saves_count INT DEFAULT 0,
    tries_count INT DEFAULT 0,
    created_at TIMESTAMP
);

CREATE TABLE user_profiles (
    user_id UUID PRIMARY KEY,
    username VARCHAR UNIQUE,
    display_name VARCHAR,
    bio TEXT,
    profile_photo_url VARCHAR,
    is_private BOOLEAN DEFAULT false,
    followers_count INT DEFAULT 0,
    following_count INT DEFAULT 0
);

CREATE TABLE follows (
    follower_id UUID REFERENCES users(id),
    following_id UUID REFERENCES users(id),
    created_at TIMESTAMP,
    PRIMARY KEY (follower_id, following_id)
);
```

**Content Delivery**:
- CDN for images (CloudFlare, CloudFront)
- Image optimization: WebP format, progressive loading
- Lazy loading in feed (load 20 items, fetch more on scroll)

---

## User Flows

### Flow 1: Create & Share First Lookbook

```
1. User has 4 saved looks
2. App shows notification: "Ready to create your lookbook?"
3. User taps notification
4. Lookbook creator screen opens
5. User selects "Collage" template
6. Preview shows 4 photos in grid
7. User edits title: "My Winter Vibes ❄️"
8. User taps "Generate"
9. Processing (2 seconds)
10. Final lookbook displays
11. User taps "Share to Instagram"
12. Instagram opens with lookbook + caption
13. User posts to feed
14. Returns to app, sees "Lookbook shared!" confirmation
```

**Success Metrics**:
- 40%+ users create lookbook after 3+ saves
- 60%+ of lookbook creators share externally

---

### Flow 2: Discover & Try Community Look

```
1. User taps "Discover" tab
2. Feed of community looks loads
3. User scrolls, sees look titled "Burgundy Elegance"
4. Taps to view detail
5. See: Photo, makeup products, 1.2K tries
6. Taps "Try This Look"
7. AR camera opens with look applied
8. User loves it, captures photo
9. Taps heart icon to save
10. Look added to "Saved" collection
```

**Success Metrics**:
- 50%+ users browse discovery feed
- 30%+ try a look from feed
- Average 3+ looks saved from discovery

---

## Success Metrics & KPIs

### Creation & Sharing

| Metric | Target |
|--------|--------|
| Lookbook Creation Rate | 40%+ (users with 3+ looks) |
| Social Share Rate | 25%+ |
| Shared Content Engagement | 5%+ like/comment rate (external) |
| Viral Coefficient | 1.5+ (each user brings 1.5 new users) |

### Community Engagement

| Metric | Target |
|--------|--------|
| Discovery Feed Usage | 50%+ of users |
| Looks Tried from Feed | 30%+ |
| Profile Creation Rate | 60%+ |
| Follower Growth | 10+ avg followers per active creator |

### Retention

| Metric | Target |
|--------|--------|
| Week-1 Retention | 60%+ (up from 40%) |
| DAU/MAU | 45%+ (up from 30%) |
| Session Frequency | 4+ per week |

---

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Low-quality UGC | Medium | Curated feed; moderation; featured content |
| Privacy concerns (sharing faces) | High | Clear privacy settings; anonymous option; consent flows |
| Copyright issues (music, graphics) | Medium | Licensed content only; user disclaimers |
| Spam/abuse in community | Medium | Report system; AI moderation; human review |

---

## Timeline & Budget

**Timeline**: 8-10 weeks
- Weeks 1-2: Lookbook generator + templates
- Weeks 3-4: Social sharing integration
- Weeks 5-6: Discovery feed & profiles
- Weeks 7-8: Fantasy effects & search
- Weeks 9-10: Testing, moderation tools, launch

**Budget**: $70K-90K (3 engineers, 1 community manager)

---

## Dependencies

- Phase 1-3 complete
- Content moderation tools/service (e.g., Sightengine)
- Social media API access (Instagram, TikTok)
- CDN for user-generated content

---

**Document Owner**: Product Management  
**Last Updated**: 2025-11-13  
**Version**: 1.0  
**Status**: Ready for Development
