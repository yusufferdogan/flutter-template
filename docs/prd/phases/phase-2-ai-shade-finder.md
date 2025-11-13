# Phase 2: AI Shade Finder & Product Recommendations

**Phase Duration:** 6-8 weeks
**Priority:** P0 (Must Have)
**Dependencies:** Phase 1 (AR Virtual Makeup Try-On)
**Status:** Planning

---

## Executive Summary

Phase 2 transforms the app from a fun AR toy into a practical shopping tool by adding intelligent skin tone analysis and personalized product recommendations. Users can discover their perfect foundation and lipstick shades through AI-powered analysis, then receive curated product suggestions from real cosmetics brands.

**Primary Goal**: Enable users to confidently select makeup products that match their unique skin tone and undertone, reducing purchase uncertainty and returns.

**Success Criteria**:
- 85%+ accuracy in skin tone classification (validated against dermatologist ratings)
- 25%+ of users engage with shade finder feature
- 20%+ click-through rate on product recommendations
- 4.5+ rating for shade accuracy from user surveys
- Integration with 20+ cosmetics brands in product database

---

## Problem Statement

### User Pain Points

1. **Shade Matching Difficulty**: 62% of women struggle to find the right foundation shade (Perfect Corp survey)
2. **Online Shopping Uncertainty**: Can't test products online, leading to incorrect purchases and returns
3. **Undertone Confusion**: Many users don't know if they're cool, warm, or neutral toned
4. **Overwhelm from Options**: Hundreds of shades across brands make selection paralyzing
5. **Lack of Personalization**: Generic recommendations don't account for individual features

### Market Validation

- **AI Beauty Tech**: The AI in beauty market expected to reach $9.36B by 2030 (MarketsandMarkets)
- **Skin Tone Tech Adoption**: 45% of beauty shoppers want AI shade-matching tools (McKinsey)
- **Conversion Impact**: Personalized recommendations increase conversion by 20-40% (Salesforce)
- **Reference**: Perfect Corp's AI Skin Advisor has analyzed 50M+ faces globally

---

## Target Users

Extends Phase 1 personas with specific needs:

**Primary Persona: The Shade-Seeker (Sarah, 28)**
- **Challenge**: Tried 8 foundations, none matched perfectly
- **Behavior**: Reads reviews obsessively, watches YouTube shade comparisons
- **Need**: Quick, accurate shade recommendation she can trust
- **Value**: AI analysis saves hours of research and costly mistakes

**Secondary Persona: The Beginner (Emma, 22)**
- **Challenge**: New to makeup, doesn't know her skin type or undertone
- **Behavior**: Asks friends for advice, easily influenced by trends
- **Need**: Educational guidance on what works for her features
- **Value**: Hand-holding through product selection process

---

## Feature Requirements

### 1. AI Skin Tone Analysis (P0 - Must Have)

**Description**: Analyze user's face photo to classify skin tone on Fitzpatrick scale and detect undertone.

**Classification System**:

**Fitzpatrick Scale** (6 types):
- Type I: Very Fair (pale white, burns easily)
- Type II: Fair (white, burns easily)
- Type III: Fair to Medium (beige, tans gradually)
- Type IV: Medium (light brown, tans easily)
- Type V: Medium to Dark (brown)
- Type VI: Dark (dark brown to black)

**Undertone Classification** (3 types):
- Cool: Pink, red, or bluish undertones
- Warm: Golden, yellow, or peachy undertones
- Neutral: Mix of cool and warm

**Technical Approach**:

**Option 1: TensorFlow Lite Model** (Recommended)
- Train custom CNN on diverse skin tone dataset
- Input: Face image (cropped to face region, standardized lighting)
- Output: Fitzpatrick type (1-6) + undertone (cool/warm/neutral) + confidence scores
- Model size: <10MB for on-device inference

**Dataset Requirements**:
- 10K+ labeled face images across all Fitzpatrick types
- Balanced representation of skin tones, ages, genders
- Captured under various lighting conditions
- Sources: Public datasets (FairFace, UTKFace) + licensed data

**Training Process**:
1. Data augmentation (brightness, contrast, rotation)
2. Transfer learning from pre-trained ResNet50 or MobileNetV3
3. Fine-tune on skin tone classification task
4. Validate on held-out test set (85%+ accuracy target)
5. Convert to TensorFlow Lite (.tflite file)

**Option 2: Cloud API** (Fallback)
- Use Perfect Corp API or ModiFace API
- Pros: High accuracy, no model training
- Cons: Costs ($$$), network dependency, slower

**Implementation**:
```dart
class SkinToneAnalyzer {
  final Interpreter _interpreter;

  Future<SkinToneResult> analyzeFace(Uint8List imageBytes) async {
    // Preprocess image
    final inputTensor = _preprocessImage(imageBytes);

    // Run inference
    final output = List.filled(9, 0.0); // 6 Fitz + 3 undertone
    _interpreter.run(inputTensor, output);

    // Parse results
    return SkinToneResult(
      fitzpatrickType: _argMax(output.sublist(0, 6)) + 1,
      undertone: _classifyUndertone(output.sublist(6, 9)),
      confidence: _maxConfidence(output),
    );
  }
}
```

**Accuracy Validation**:
- Benchmark against professional makeup artist ratings
- Test with diverse users in beta (include underrepresented skin tones)
- Continuously improve model with feedback loop

**Acceptance Criteria**:
- [ ] Fitzpatrick classification accuracy ≥85% on test set
- [ ] Undertone classification accuracy ≥80%
- [ ] Inference time <1 second on device
- [ ] Works in various lighting (daylight, indoor, ring light)
- [ ] Graceful handling of edge cases (e.g., fake tan, uneven skin)

---

### 2. Foundation Shade Matching (P0 - Must Have)

**Description**: Recommend specific foundation products and shades that match user's analyzed skin tone.

**Matching Algorithm**:

1. **User Analysis Input**:
   - Fitzpatrick type
   - Undertone
   - Optional: Preferences (coverage, finish, skin type)

2. **Product Database Query**:
   - Filter by Fitzpatrick range compatibility
   - Match undertone (e.g., warm undertone → warm-toned foundations)
   - Rank by popularity, rating, and brand tier

3. **Shade Mapping**:
   - Use standardized shade codes (e.g., L'Oréal "W3" = Fair Warm 3)
   - Map Fitzpatrick + undertone to brand-specific shade names
   - Example: Type III + Warm → Fenty 240, Maybelline 120 Warm, MAC NC30

4. **Output**:
   - Top 5-10 product recommendations
   - Each with: Brand, product name, shade name, price, rating, thumbnail
   - "Match confidence" badge (90%, 85%, etc.)

**Product Database Schema**:
```json
{
  "products": [
    {
      "id": "fenty_pro_filtr_240",
      "brand": "Fenty Beauty",
      "name": "Pro Filt'r Soft Matte Foundation",
      "shade": "240",
      "shade_description": "Light to medium with neutral undertones",
      "fitzpatrick_range": [3, 4],
      "undertone": "neutral",
      "coverage": "medium_to_full",
      "finish": "matte",
      "price_usd": 39.00,
      "rating": 4.5,
      "reviews_count": 12500,
      "image_url": "https://cdn.../fenty-240.jpg",
      "buy_url": "https://fentybeauty.com/..."
    }
  ]
}
```

**Database Population**:
- Scrape/partner with brand sites for product info
- Use Sephora/Ulta APIs if available
- Manual curation for top 20 brands initially
- Expand to 50+ brands over 6 months

**UI Flow**:
1. User taps "Find My Shade" button
2. Prompt: "Take a selfie in good lighting"
3. Camera opens (reuse Phase 1 camera)
4. User captures photo
5. Loading: "Analyzing your skin tone..." (1-2 sec)
6. Results screen:
   - **Your Skin Tone**: "Fair with Cool Undertones (Type II)"
   - **Perfect Matches** section
   - Cards for each foundation (image, brand, shade, price)
   - "Try On" button to apply in AR
   - "View Details" to see full product page

**Acceptance Criteria**:
- [ ] Shade recommendations align with user's Fitzpatrick + undertone
- [ ] At least 5 products recommended for any skin tone
- [ ] "Try On" applies foundation in AR preview
- [ ] Product details include price, rating, and buy link

---

### 3. Lipstick Color Recommendations (P0 - Must Have)

**Description**: Suggest lip colors that complement user's skin tone and undertone.

**Recommendation Logic**:

**Color Theory Basics**:
- Cool undertones → Favor blue-based reds, pink, mauve, berry
- Warm undertones → Favor orange-based reds, coral, peach, nude
- Neutral undertones → Can wear any, emphasize versatile shades

**Personalized Algorithm**:
1. Start with user's undertone
2. Consider Fitzpatrick type (lighter skin → softer shades, deeper skin → bolder shades possible)
3. Seasonal context (winter theme → berry, burgundy, plum, classic red)
4. Output: 10-15 lipstick recommendations grouped by color family

**UI Presentation**:
- **"Colors for You"** section
- Swipeable carousel of lip swatches
- Tap swatch to apply in AR instantly
- Info card: Brand, shade name, finish (matte/satin/gloss), price
- "Add to Wishlist" heart icon

**Example Recommendations**:
- Fair + Cool → MAC "Ruby Woo" (blue-red), NARS "Dolce Vita" (dusty rose)
- Medium + Warm → Fenty "Ma'Damn" (brownish-nude), MAC "Chili" (warm terracotta)
- Deep + Neutral → Pat McGrath "Elson" (deep berry), Fenty "Icon" (true red)

**Acceptance Criteria**:
- [ ] At least 10 lip colors recommended per user
- [ ] Recommendations make sense (match undertone rules)
- [ ] Swatches accurately represent actual product colors
- [ ] AR try-on works for each recommended lipstick

---

### 4. Blush & Highlighter Matching (P1 - Should Have)

**Description**: Extend shade matching to blush and highlighter products.

**Blush Logic**:
- Fair skin → Soft pink, peach, light coral
- Medium skin → Mauve, terracotta, berry
- Deep skin → Plum, deep berry, bronze
- Cool undertone → Pink, rosy shades
- Warm undertone → Peach, coral, bronze

**Highlighter Logic**:
- Fair skin → Champagne, pearl, light gold
- Medium skin → Rose gold, gold, bronze
- Deep skin → Bronze, copper, gold
- Cool undertone → Silver, icy champagne
- Warm undertone → Gold, bronze

**UI**: Similar to lipstick carousel, separate section for each

**Acceptance Criteria**:
- [ ] 5+ blush recommendations per user
- [ ] 5+ highlighter recommendations
- [ ] AR try-on functional for recommended products

---

### 5. Product Information Cards (P0 - Must Have)

**Description**: Detailed product views with all relevant info for purchase decision.

**Card Components**:

**Header**:
- Product image (high-res)
- Brand logo
- Favorite icon (heart)

**Body**:
- Product name
- Shade name and description
- Price (with currency)
- Star rating (e.g., 4.5 ★★★★☆)
- Review count
- **Match badge**: "95% Match for Your Skin"

**Details Section** (expandable):
- Description (from brand)
- Key features (e.g., "Long-wear", "Hydrating", "SPF 15")
- Ingredients (first 10 listed)
- Skin type suitability

**Actions**:
- **Try On Button**: Apply in AR camera
- **Shop Now Button**: Open affiliate link (Phase 5)
- **Add to Wishlist**: Save for later
- **Share Button**: Share product via social

**Acceptance Criteria**:
- [ ] All product data displays correctly
- [ ] Images load quickly (cached)
- [ ] "Try On" transitions to AR view seamlessly
- [ ] Wishlist persists across sessions

---

### 6. Shade Comparison Tool (P1 - Should Have)

**Description**: Let users compare 2-3 foundation shades side-by-side in AR.

**Use Case**: User narrows down to 2 shades but can't decide.

**UI**:
- "Compare" button on product cards
- Select up to 3 products
- Split-screen AR view (or toggle between shades rapidly)
- Side-by-side product info below

**Acceptance Criteria**:
- [ ] Compare mode supports 2-3 products
- [ ] AR rendering switches smoothly
- [ ] Clear labels indicate which shade is active

---

### 7. User Skin Profile & Preferences (P0 - Must Have)

**Description**: Store user's skin analysis results and preferences for future personalization.

**Profile Data**:
- Fitzpatrick type
- Undertone
- Skin type (oily, dry, combination, normal)
- Concerns (acne-prone, sensitive, mature, etc.)
- Favorite brands
- Preferred finish (matte, dewy, natural)
- Budget range (drugstore, mid-range, luxury)

**Profile Creation Flow**:
1. After first shade finder analysis, prompt: "Save your skin profile?"
2. Show analysis results
3. Ask 3-5 quick questions:
   - "What's your skin type?" (dropdown)
   - "Any skin concerns?" (multi-select)
   - "Preferred makeup finish?" (matte / dewy / natural)
4. Optional: Email signup for personalized tips
5. Save profile to local storage + cloud (if logged in)

**Benefits**:
- Skip re-analysis on subsequent uses
- Refine recommendations over time
- Enable cross-device sync (if user has account)

**Acceptance Criteria**:
- [ ] Profile saved after first analysis
- [ ] User can edit profile in settings
- [ ] Recommendations improve with profile data
- [ ] Profile syncs to cloud (if logged in)

---

### 8. Educational Content (P2 - Nice to Have)

**Description**: Teach users about skin tones, undertones, and shade selection.

**Content Types**:

1. **"Know Your Undertone" Quiz**:
   - 3-4 questions (e.g., "Jewelry: gold or silver looks better?")
   - Result: Your undertone is Warm/Cool/Neutral + explanation

2. **Shade Finder Tips**:
   - "Take photo in natural daylight"
   - "Remove makeup for best results"
   - "Hold phone at eye level"

3. **Glossary**:
   - Terms like "Fitzpatrick scale", "undertone", "oxidation"
   - Short definitions + examples

**Delivery**:
- Info icons (ⓘ) throughout UI that open tooltips
- "Learn More" link on results screen
- Optional: Dedicated "Beauty 101" section in app

**Acceptance Criteria**:
- [ ] Quiz functional with accurate undertone result
- [ ] Tips displayed before shade finder photo capture
- [ ] Glossary accessible from menu

---

## Non-Functional Requirements

### Performance

| Metric | Target | Minimum Acceptable |
|--------|--------|-------------------|
| Skin Tone Inference | <1 second | <2 seconds |
| Product Query Response | <300ms | <500ms |
| Database Size (local cache) | <20 MB | <50 MB |
| Image Loading (product photos) | <1 second | <2 seconds |

### Accuracy

| Metric | Target |
|--------|--------|
| Fitzpatrick Classification | 85%+ |
| Undertone Classification | 80%+ |
| Shade Match Satisfaction | 4.5+ / 5 (user rating) |

### Data Quality

- Product database updated monthly
- Price accuracy: 95%+
- Product availability: Remove discontinued products within 30 days

---

## Technical Implementation

### AI Model Training (Custom TFLite)

**Dataset Sources**:
- FairFace dataset (Harvard, 100K images)
- UTKFace dataset (age, gender, race)
- Proprietary: Commission diverse photoshoots (500-1K images)
- Augmentation: 5x expansion via rotation, lighting, contrast adjustments

**Training Pipeline**:
```python
# Pseudocode for training
import tensorflow as tf
from tensorflow import keras

# Load data
train_data, val_data = load_datasets()

# Base model (transfer learning)
base_model = keras.applications.MobileNetV3Large(
    include_top=False,
    weights='imagenet',
    input_shape=(224, 224, 3)
)
base_model.trainable = False  # Freeze initially

# Custom head
model = keras.Sequential([
    base_model,
    keras.layers.GlobalAveragePooling2D(),
    keras.layers.Dense(128, activation='relu'),
    keras.layers.Dropout(0.3),
    keras.layers.Dense(9, activation='softmax')  # 6 Fitz + 3 undertone
])

# Compile
model.compile(
    optimizer='adam',
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

# Train
model.fit(train_data, validation_data=val_data, epochs=20)

# Fine-tune (unfreeze base model)
base_model.trainable = True
model.compile(optimizer=keras.optimizers.Adam(1e-5), ...)
model.fit(train_data, epochs=10)

# Convert to TFLite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()
with open('skin_tone_model.tflite', 'wb') as f:
    f.write(tflite_model)
```

**Validation**:
- Test on 20% held-out dataset
- Manual review: Dermatologist labels 500 samples
- A/B test: Compare recommendations with human makeup artist

### Product Database (Firebase / PostgreSQL)

**Schema**:
```sql
CREATE TABLE products (
    id VARCHAR PRIMARY KEY,
    category VARCHAR,  -- foundation, lipstick, blush, etc.
    brand VARCHAR,
    name VARCHAR,
    shade_name VARCHAR,
    fitzpatrick_min INT,  -- 1-6
    fitzpatrick_max INT,
    undertone VARCHAR,  -- cool, warm, neutral, any
    coverage VARCHAR,
    finish VARCHAR,
    price_usd DECIMAL,
    currency VARCHAR,
    rating DECIMAL,
    reviews_count INT,
    image_url VARCHAR,
    buy_url VARCHAR,
    affiliate_link VARCHAR,
    in_stock BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE INDEX idx_category_fitz ON products(category, fitzpatrick_min, fitzpatrick_max);
CREATE INDEX idx_undertone ON products(undertone);
```

**API Endpoints**:
- `GET /products/recommendations?fitzpatrick=3&undertone=warm&category=foundation`
- `GET /products/:id`
- `POST /products/search` (with filters)

**Caching Strategy**:
- Cache top 100 products locally (SQLite)
- Refresh cache every 7 days
- Lazy load images (progressive JPEGs)

### Flutter Integration

**New Screens**:
1. **Shade Finder Screen** (capture photo, analyze)
2. **Skin Profile Screen** (show results, edit profile)
3. **Product Recommendations Screen** (list with filters)
4. **Product Detail Screen** (full info card)

**State Management** (Riverpod):
```dart
final skinToneProvider = FutureProvider.autoDispose<SkinToneResult>((ref) async {
  final imageBytes = ref.watch(capturedImageProvider);
  final analyzer = ref.watch(skinToneAnalyzerProvider);
  return await analyzer.analyzeFace(imageBytes);
});

final productRecommendationsProvider = FutureProvider.family<List<Product>, SkinToneResult>(
  (ref, skinTone) async {
    final repo = ref.watch(productRepositoryProvider);
    return await repo.getRecommendations(
      fitzpatrick: skinTone.fitzpatrickType,
      undertone: skinTone.undertone,
      category: 'foundation',
    );
  },
);
```

---

## User Flows

### Flow 1: First-Time Shade Finder

```
1. User taps "Find My Shade" on home screen
   ↓
2. Education screen: "How it works" (3 tips)
   → Button: "Let's Go!"
   ↓
3. Camera screen opens
   → Overlay: Face alignment guide
   → Tip: "Remove makeup for best results"
   ↓
4. User captures selfie
   ↓
5. Processing screen (animated)
   → "Analyzing skin tone..."
   ↓ (1-2 seconds)
6. Results screen:
   → **Your Skin Tone**: "Fair with Cool Undertones (Type II)"
   → Visual: Illustrated skin tone swatch
   → Button: "Find Matching Products"
   ↓
7. User taps button
   ↓
8. Product recommendations screen
   → Foundation section (5 products)
   → Lipstick section (10 products)
   → Blush section (5 products)
   ↓
9. User taps foundation card
   ↓
10. Product detail modal opens
   → All info displayed
   → "Try On" button prominent
   ↓
11. User taps "Try On"
   ↓
12. AR camera opens with foundation applied
   → Can adjust intensity
   → Can capture photo
```

**Success Metrics**:
- 80%+ complete shade finder flow
- 70%+ view recommendations
- 40%+ try on at least 1 recommended product

---

### Flow 2: Returning User - Check Lipstick

```
1. User opens app (AR camera default view)
   ↓
2. User taps profile icon (top-right)
   ↓
3. Profile screen shows saved skin tone
   → Button: "Explore Products for My Tone"
   ↓
4. User taps button
   ↓
5. Recommendations screen opens
   → Tabs: Foundation | Lipstick | Blush | Highlighter
   → Lipstick tab active
   ↓
6. User scrolls through lipstick swatches
   → Taps a berry shade
   ↓
7. Lipstick applies in AR preview (picture-in-picture)
   → User sees herself with lipstick
   → Swipe to try next shade
   ↓
8. User finds favorite
   → Taps "Add to Wishlist"
   ↓
9. Confirmation: "Added to Wishlist!"
```

**Success Metrics**:
- 60%+ returning users access recommendations directly
- Average 3+ products tried per session
- 30%+ add to wishlist

---

## Testing Strategy

### Model Accuracy Testing

**Fitzpatrick Classification**:
- Test set: 2,000 diverse images (333 per type)
- Benchmark: Dermatologist ground truth labels
- Metrics: Accuracy, precision, recall, F1-score per class
- Target: 85%+ overall accuracy, no class <80%

**Undertone Classification**:
- Subset: 1,500 images with undertone labels
- Validation: Professional makeup artist review
- Target: 80%+ accuracy

**Fairness Evaluation**:
- Measure accuracy across demographics (age, gender, ethnicity)
- Ensure no group has <75% accuracy (avoid bias)

### Product Recommendation Testing

**Matching Logic**:
- Unit tests: Given skin tone X → verify correct products returned
- Edge cases: Rare skin tones, missing data

**Database Quality**:
- Manual QA: Review 100 random products for accuracy
- Price checks: Automated web scraping to verify prices monthly

### User Acceptance Testing

**Beta Group**: 200 users
- 50 per Fitzpatrick type (I-II, III-IV, V-VI)
- Survey questions:
  - "How accurate was your skin tone analysis?" (1-5)
  - "Did the recommended foundations match your shade?" (Yes/No)
  - "Would you purchase a recommended product?" (Yes/No)

**Success Threshold**: 80%+ answer "Yes" or rate 4+

---

## Success Metrics & KPIs

### Engagement

| Metric | Target | Tracking |
|--------|--------|----------|
| Shade Finder Usage Rate | 25%+ of users | Event: shade_finder_started |
| Recommendation Views | 80%+ of shade finder users | Funnel: shade_finder → recommendations |
| Product Try-On from Recs | 50%+ | Event: product_tried_from_recs |
| Wishlist Additions | 20%+ of users | Event: product_added_to_wishlist |

### Satisfaction

| Metric | Target |
|--------|--------|
| Shade Match Satisfaction | 4.5+ / 5 |
| Recommendation Relevance | 4.3+ / 5 |
| NPS (Phase 2) | 60+ |

### Technical

| Metric | Target |
|--------|--------|
| Model Accuracy | 85%+ (Fitzpatrick), 80%+ (undertone) |
| API Response Time | <300ms (p95) |
| Error Rate | <1% (inference failures) |

---

## Risks & Mitigation

### High-Priority Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| Model bias (inaccurate for certain skin tones) | High | Medium | Diverse training data; bias audits; continuous improvement |
| Product data quality issues | Medium | High | Manual curation; automated validation scripts; partner with brands |
| User distrust of AI recommendations | Medium | Low | Transparency (show confidence scores); education; compare with pro reviews |
| Insufficient product inventory | High | Medium | Start with top 20 brands; expand gradually; partnerships |

---

## Dependencies

**Internal**:
- Phase 1 complete (AR camera, photo capture)
- Design assets (skin tone illustrations, UI for product cards)

**External**:
- Product data from brands or Sephora/Ulta APIs
- ML training compute (Google Colab Pro or cloud GPUs)
- TensorFlow Lite Flutter plugin

---

## Timeline & Milestones

**Weeks 1-2: Setup & Data Collection**
- Gather training datasets
- Setup ML training environment
- API and database design

**Weeks 3-4: Model Training**
- Train skin tone classifier
- Validate accuracy
- Convert to TFLite

**Weeks 5-6: Product Database**
- Populate database (500+ products)
- Build recommendation algorithm
- Test matching logic

**Weeks 7-8: Flutter Integration**
- Shade finder UI
- Product recommendations UI
- AR try-on for recommended products

**Weeks 9-10: Testing & Launch**
- Beta testing (200 users)
- Bug fixes
- Launch to production

**Milestone**: Phase 2 complete when 25%+ users use shade finder and satisfaction >4.5/5

---

## Budget Estimate

**Development**: $50K-70K (6-8 weeks, 2-3 engineers)
**ML Training**: $5K (compute + data licensing)
**Product Data**: $10K (manual curation, APIs)
**Total**: $65K-85K

---

## Appendix

### References

- Perfect Corp: AI Skin Analysis Technology
- Fitzpatrick Skin Type Scale (dermatology standard)
- FairFace Dataset (Harvard)
- TensorFlow Lite Documentation

### Related Documents

- [Phase 1 PRD](./phase-1-ar-makeup-try-on.md)
- [Phase 3 PRD](./phase-3-winter-stylist.md)
- [Master PRD](../00-MASTER-PRD.md)

---

**Document Owner**: Product Management
**Last Updated**: 2025-11-13
**Version**: 1.0
**Status**: Ready for Development

