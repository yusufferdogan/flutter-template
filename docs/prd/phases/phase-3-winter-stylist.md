# Phase 3: Winter Stylist & Outfit Recommendations

**Phase Duration:** 6-8 weeks
**Priority:** P1 (Should Have)
**Dependencies:** Phase 1 (AR Makeup), Phase 2 (AI Analysis)
**Status:** Planning

---

## Executive Summary

Phase 3 expands the app beyond makeup to complete winter style coordination. The AI Winter Stylist analyzes user photos and makeup looks to recommend complementary outfits, accessories, and hair colors, creating cohesive seasonal aesthetics.

**Primary Goal**: Transform the app from a makeup tool into a complete winter style companion that helps users coordinate their entire look from head to toe.

**Success Criteria**:
- 40%+ of users engage with outfit recommendations
- 30%+ try hair color feature
- 20%+ session length increase
- 15%+ product click-through on outfit items
- 4.2+ satisfaction rating for style relevance

---

## Problem Statement

### User Pain Points

1. **Coordination Difficulty**: 67% of women struggle to match makeup with outfits (StyleCaster survey)
2. **Style Indecision**: Users want guidance on what looks good together
3. **Seasonal Styling**: Need winter-specific recommendations (cozy, layered looks)
4. **Hair Color Curiosity**: Want to try new hair colors safely before commitment
5. **Incomplete Solutions**: Existing apps do makeup OR fashion, not both

### Market Opportunity

- **Fashion AI Market**: Expected $4.4B by 2027 (15.4% CAGR - MarketsandMarkets)
- **Virtual Try-On Fashion**: 71% of shoppers want AR try-on for clothing (Snap survey)
- **Hair Color Apps**: Virtual hair color try-on increases salon bookings by 25% (ModiFace data)

---

## Feature Requirements

### 1. AI Outfit Recommendation Engine (P0)

**Description**: Analyze user's makeup look and suggest matching winter outfits.

**Recommendation Logic**:

**Input Parameters**:
- Current makeup look (colors, intensity, style)
- Skin tone and undertone
- User preferences (style: classic, edgy, minimal, glamorous)
- Occasion (casual, work, date, party)
- Season context (winter = focus on layering, warm tones, cozy fabrics)

**Style Aesthetic Categories**:
1. **Snow Muse**: Ethereal, all-white/cream, minimalist
2. **Cozy Cabin**: Warm knits, earth tones, rustic
3. **Winter Date**: Elegant, rich colors (burgundy, navy), sophisticated
4. **Nordic Minimalist**: Clean lines, neutral palette, Scandinavian
5. **Festive Glam**: Bold, metallic accents, party-ready

**Matching Algorithm**:
```
IF makeup = "Snow Muse" (light, ethereal)
  THEN outfit_palette = ["cream", "white", "soft_gray", "pale_blue"]
  THEN style_keywords = ["minimalist", "oversized_coat", "cashmere"]

IF makeup = "Winter Date" (bold, berry lips)
  THEN outfit_palette = ["burgundy", "deep_plum", "charcoal", "black"]
  THEN style_keywords = ["elegant", "structured", "velvet", "satin"]
```

**Output**:
- 5-10 outfit suggestions (each = top + bottom + outerwear + shoes)
- Each item shows: Image, brand, price, "Shop" link
- "Complete the Look" package (all items together)

**Acceptance Criteria**:
- [ ] Outfit recommendations visually match makeup color palette
- [ ] Style aesthetic is cohesive (no mixing minimalist with maximalist)
- [ ] At least 5 outfit combinations per user
- [ ] Each outfit includes 4+ items (top, bottom, outerwear, accessory)

---

### 2. Virtual Hair Color Try-On (P0)

**Description**: Allow users to preview different hair colors in real-time AR.

**Hair Colors** (Winter-Themed):
- **Warm**: Caramel blonde, Auburn, Copper red, Honey brown
- **Cool**: Ash blonde, Platinum, Black cherry, Charcoal brown
- **Bold**: Burgundy, Plum, Rose gold, Silver

**Technical Implementation**:
- Use ML Kit hair segmentation (or custom model)
- Apply color overlay to segmented hair region
- Support various hair textures and lengths
- Real-time rendering at 30 FPS

**UI Flow**:
1. Tap "Try Hair Colors" from style tab
2. Camera opens with face + hair detection
3. Scrollable hair color swatches at bottom
4. Tap swatch → hair color changes instantly
5. Intensity slider to adjust saturation
6. Capture button to save look

**Acceptance Criteria**:
- [ ] Hair segmentation works for various hairstyles (long, short, curly, straight)
- [ ] Color rendering looks natural (not flat/fake)
- [ ] Works with hats/accessories (only colors visible hair)
- [ ] 15+ hair color options available

---

### 3. Accessory Matching (P1)

**Description**: Suggest winter accessories (scarves, hats, gloves) that complete the look.

**Accessory Categories**:
- Scarves (knit, cashmere, patterned)
- Beanies & winter hats
- Gloves & mittens
- Statement jewelry (earrings, necklaces)
- Bags (crossbody, totes)

**Matching Rules**:
- Match accessory colors to makeup undertone
- Minimalist makeup → Simple accessories
- Bold makeup → Allow statement pieces (but not competing)
- Winter context → Prioritize warmth + texture (knits, fur, wool)

**Visual Presentation**:
- Grid layout of accessory options
- Filter by category
- Each shows: Image, name, price, "Add to Outfit"

**Acceptance Criteria**:
- [ ] 20+ accessories per category
- [ ] Recommendations align with outfit aesthetic
- [ ] "Add to Outfit" saves item to current look

---

### 4. Style Profiling & Preferences (P0)

**Description**: Learn user's style preferences to personalize recommendations.

**Profile Quiz** (Optional, post-first-use):
1. "Which aesthetic resonates with you?" (show 6 mood boards)
2. "Preferred style?" (Classic, Trendy, Edgy, Romantic, Minimal)
3. "Budget for clothing?" (Under $50, $50-150, $150+)
4. "Favorite brands?" (multi-select from 30 brands)

**Learning System**:
- Track which outfits user saves/clicks
- Track which hair colors user tries
- Adjust recommendations based on engagement patterns
- Collaborative filtering: "Users like you also liked..."

**Acceptance Criteria**:
- [ ] Profile quiz completion rate >60%
- [ ] Recommendations improve after 3+ interactions (measured by CTR)
- [ ] User can edit preferences anytime in settings

---

### 5. Occasion-Based Recommendations (P1)

**Description**: Filter outfits by occasion/event type.

**Occasion Types**:
- Everyday Casual
- Work/Office
- Date Night
- Holiday Party
- Outdoor (skiing, hiking)

**Implementation**:
- Dropdown filter on outfit recommendations screen
- Each occasion has style guidelines (e.g., Work = no sequins, conservative colors)
- Outfit database tagged with occasion suitability

**Acceptance Criteria**:
- [ ] All outfits tagged with ≥1 occasion
- [ ] Filter works instantly (<100ms)
- [ ] Occasion-specific styles make sense (e.g., party outfits are dressy)

---

### 6. "Shop the Look" Integration (P0)

**Description**: Bundle all items in a look for easy purchasing.

**Features**:
- "Shop Full Look" button shows all items (makeup + outfit + accessories)
- Estimated total price
- Individual item cards with "Shop Now" links
- Save entire look to wishlist
- Share look via social (preview image + product list)

**UI**:
- Modal overlay with scrollable item list
- Each item: Thumbnail, name, price, stock status, link
- Footer: Total price + "Checkout" (redirects to retailers)

**Acceptance Criteria**:
- [ ] "Shop the Look" displays all items correctly
- [ ] Price total calculates accurately
- [ ] Links direct to correct product pages
- [ ] Look can be saved and accessed later

---

## Technical Implementation

### Outfit Recommendation Backend

**API Endpoint**: `POST /api/v1/style/recommendations`

**Request**:
```json
{
  "makeup_look_id": "snow_muse",
  "skin_tone": {
    "fitzpatrick": 3,
    "undertone": "cool"
  },
  "preferences": {
    "style": ["minimalist", "elegant"],
    "budget": "mid_range",
    "occasion": "date_night"
  }
}
```

**Response**:
```json
{
  "outfits": [
    {
      "id": "outfit_001",
      "name": "Cozy Elegance",
      "aesthetic": "cozy_cabin",
      "total_price": 285.00,
      "items": [
        {
          "type": "top",
          "name": "Cashmere Turtleneck",
          "brand": "Everlane",
          "price": 120.00,
          "color": "camel",
          "image_url": "...",
          "buy_url": "..."
        },
        // more items...
      ]
    }
  ]
}
```

### Hair Segmentation Model

**Option 1**: Google ML Kit Selfie Segmentation
- Segments person from background
- Extract hair region via heuristic (top 20% of person mask)

**Option 2**: Custom Hair Parsing Model
- Train on FigaroDataset (hair parsing, 2000 images)
- Output: Binary mask of hair pixels
- TensorFlow Lite model <5MB

**Color Application**:
```dart
class HairColorRenderer {
  void applyColor(ui.Image hairMask, Color targetColor, double intensity) {
    // For each pixel in hairMask
    // If pixel is hair (mask = 1):
    //   newColor = blend(originalColor, targetColor, intensity)
    // Use HSV color space for natural blending
  }
}
```

### Outfit Database Schema

```sql
CREATE TABLE outfits (
    id VARCHAR PRIMARY KEY,
    name VARCHAR,
    aesthetic_category VARCHAR,
    occasion VARCHAR[],
    season VARCHAR,
    total_price DECIMAL
);

CREATE TABLE outfit_items (
    id VARCHAR PRIMARY KEY,
    outfit_id VARCHAR REFERENCES outfits(id),
    item_type VARCHAR,  -- top, bottom, outerwear, shoes, accessory
    brand VARCHAR,
    name VARCHAR,
    color VARCHAR,
    size_range VARCHAR,
    price DECIMAL,
    image_url VARCHAR,
    buy_url VARCHAR,
    in_stock BOOLEAN
);
```

**Data Population**:
- Scrape fashion e-commerce sites (Nordstrom, ASOS, H&M)
- Use fashion APIs (ShopStyle, RewardStyle)
- Manual curation: 50 curated outfits × 5 aesthetics = 250 looks

---

## User Flows

### Flow 1: Complete Winter Look

```
1. User opens app with "Snow Muse" makeup applied
2. Taps new "Style" tab at bottom
3. Style dashboard appears:
   - "Get Outfit Ideas"
   - "Try Hair Colors"
   - "Complete the Look"
4. User taps "Get Outfit Ideas"
5. Loading: "Finding outfits for your look..."
6. Outfit grid appears (6 outfits)
7. User taps first outfit card
8. Outfit detail view:
   - Large outfit image (model wearing look)
   - Items list (coat, sweater, jeans, boots)
   - Total price: $285
9. User taps "Try Hair Color"
10. Hair color selector appears over outfit
11. User selects "Auburn" hair
12. Hair color applies to user's photo
13. User satisfied: taps "Shop This Look"
14. All items display with buy links
15. User saves to wishlist for later
```

**Success Metrics**:
- 40%+ users complete this flow
- Average 3+ outfits viewed per session
- 25%+ try hair color feature

---

### Flow 2: Occasion-Based Styling

```
1. User has saved winter date makeup look
2. Taps Style tab
3. Selects "Occasion: Date Night"
4. System filters outfits for romantic/elegant options
5. 4 outfits shown (all appropriate for dates)
6. User explores outfit #2 ("Velvet Noir")
7. Loves the burgundy dress
8. Taps "Shop Now" on dress
9. Redirects to retailer site
10. Returns to app, saves outfit
```

**Success Metrics**:
- 30%+ use occasion filter
- 20%+ click through to product pages
- 15%+ save outfits

---

## Success Metrics & KPIs

### Engagement

| Metric | Target |
|--------|--------|
| Style Feature Usage | 40%+ of active users |
| Hair Color Try-On Rate | 30%+ |
| Outfit Recommendations Viewed | 3+ per session |
| Session Length Increase | +20% vs Phase 2 |

### Conversion

| Metric | Target |
|--------|--------|
| Outfit Product CTR | 15%+ |
| "Shop the Look" Usage | 25%+ of style users |
| Wishlist Additions (Outfit Items) | 20%+ |

### Satisfaction

| Metric | Target |
|--------|--------|
| Style Recommendations Relevance | 4.2+ / 5 |
| Hair Color Realism | 4.0+ / 5 |

---

## Risks & Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Hair segmentation inaccurate | Medium | Use robust ML Kit; test on diverse hairstyles |
| Outfit data sourcing challenges | High | Start with manual curation; partner with fashion APIs |
| Style recommendations feel generic | Medium | Personalization engine; A/B test aesthetics |
| Hair color looks fake | Medium | Advanced blending algorithms; user feedback iteration |

---

## Timeline & Budget

**Timeline**: 6-8 weeks
- Weeks 1-2: Outfit database & API setup
- Weeks 3-4: Hair segmentation & color rendering
- Weeks 5-6: UI development (outfit screens, hair try-on)
- Weeks 7-8: Testing, polish, launch

**Budget**: $60K-80K (2-3 engineers, 1 fashion curator)

---

## Dependencies

- Phase 1 & 2 complete
- Fashion product database (API or scraped data)
- Hair segmentation model (ML Kit or custom)

---

**Document Owner**: Product Management  
**Last Updated**: 2025-11-13  
**Version**: 1.0  
**Status**: Ready for Development
