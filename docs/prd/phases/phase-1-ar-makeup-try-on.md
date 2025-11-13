# Phase 1: Core AR Virtual Makeup Try-On (MVP)

**Phase Duration:** 10-12 weeks
**Priority:** P0 (Must Have)
**Dependencies:** None (Foundation phase)
**Status:** Planning

---

## Executive Summary

Phase 1 establishes the core foundation of the Winter-Glam app: real-time AR virtual makeup try-on. This MVP enables users to see themselves with winter-themed makeup looks applied in real-time through their device camera. Success in this phase is critical as it validates the core value proposition and technical feasibility of the entire product.

**Primary Goal**: Launch a functional, performant AR makeup application that allows users to try on virtual makeup with high accuracy and smooth real-time rendering.

**Success Criteria**:
- Achieve 30+ FPS AR rendering on target devices
- <100ms face detection latency
- 468-point facial landmark tracking accuracy
- 90%+ user satisfaction with AR realism in beta testing
- <2% crash rate in production

---

## Problem Statement

### User Pain Points

1. **Hygiene Concerns**: In-store makeup testers raise health concerns, especially post-pandemic
2. **Commitment Fear**: Users hesitate to purchase makeup without knowing how it looks on them
3. **Limited Selection**: Physical stores can only display limited SKUs for testing
4. **Time Constraints**: In-store shopping is time-consuming; users want quick exploration
5. **Return Costs**: Wrong color/shade purchases lead to returns and waste

### Market Validation

- **AR Try-On Adoption**: 34% of beauty shoppers used AR features in 2024 (Calibraint)
- **Conversion Impact**: AR try-on features increase online conversion by 35% (Sephora case study)
- **User Preference**: 71% of consumers would shop more frequently if AR try-on was available (Deloitte)
- **Engagement**: AR features increase session time by 2.7x on average (Perfect Corp)

---

## Target Users

### Primary Personas

**Persona 1: The Experimental Explorer**
- **Age**: 18-25
- **Behavior**: Active on Instagram/TikTok, follows beauty influencers
- **Needs**: Fun, shareable content; trend discovery; low-commitment experimentation
- **Pain Point**: Can't afford to buy many products to try different looks
- **Value**: Free virtual try-on lets her experiment endlessly

**Persona 2: The Busy Professional**
- **Age**: 26-35
- **Behavior**: Online shopper, values efficiency, reads reviews
- **Needs**: Confidence in purchases, time-saving tools, quality over quantity
- **Pain Point**: No time for in-store shopping, wants to avoid return hassles
- **Value**: Quick, accurate AR try-on from home

**Persona 3: The Beauty Enthusiast**
- **Age**: 22-40
- **Behavior**: Makeup hobbyist, watches tutorials, collects products
- **Needs**: Discovering new products, perfecting techniques, staying on-trend
- **Pain Point**: Hard to visualize tutorial looks on herself before buying products
- **Value**: AR preview of complex looks before committing to purchases

---

## Feature Requirements

### 1. Face Detection & Tracking (P0 - Must Have)

**Description**: Real-time detection of user's face with continuous tracking of facial landmarks.

**Technical Specifications**:
- Detect face in camera frame within <100ms
- Track 468-point 3D face mesh (eyes, nose, mouth, jawline, forehead)
- Update mesh at 30+ FPS
- Handle head rotation (±45° yaw, ±30° pitch, ±15° roll)
- Adapt to varying lighting conditions

**Implementation Options**:
1. **Google ML Kit Face Detection** (Recommended for MVP)
   - Pros: Free, on-device, good performance, well-documented
   - Cons: Fewer landmarks (contours only), less precise than MediaPipe
   - Integration: `google_mlkit_face_detection` Flutter package

2. **MediaPipe Face Mesh** (Alternative)
   - Pros: 468 landmarks, excellent accuracy, free
   - Cons: More complex integration, larger model size
   - Integration: Custom Flutter plugin or `flutter_mediapipe` (community)

3. **Banuba SDK** (Commercial Option)
   - Pros: Turnkey solution, optimized makeup filters included
   - Cons: Licensing costs ($$$), vendor lock-in
   - Integration: `banuba_sdk` Flutter plugin

**Acceptance Criteria**:
- [ ] Face detected in <100ms under good lighting
- [ ] Tracking maintains accuracy during speech and expressions
- [ ] Works on faces with glasses (not full occlusion)
- [ ] Gracefully handles multiple faces (focuses on largest/centered face)
- [ ] Performance: <10% CPU overhead on mid-range devices

**Edge Cases**:
- Side profile (>45° angle): Show hint to face camera
- Poor lighting: Prompt user to improve lighting
- No face detected: Show placeholder with instructions
- Face too close/far: Indicate optimal distance

---

### 2. Real-Time Makeup Overlay Rendering (P0 - Must Have)

**Description**: Apply virtual makeup textures aligned to detected facial features with natural blending.

**Makeup Categories** (MVP Scope):

1. **Foundation**
   - Coverage options: Light, Medium, Full
   - 5 shade ranges (very fair to deep)
   - Blend with natural skin tone using alpha blending
   - Cover: Full face, exclude eyes/lips

2. **Eyeshadow**
   - 3 winter-themed palettes:
     - Frosted Snow (silvers, whites, icy blues)
     - Warm Hearth (browns, golds, burgundy)
     - Northern Lights (purples, greens, aurora tones)
   - Apply to eyelid region (crease detection)
   - Support 2-3 color gradients per look

3. **Lipstick**
   - Finishes: Matte, Satin, Gloss
   - 8 winter shades (nudes, berries, deep reds, mauves)
   - Detect lip contours precisely
   - Simulate gloss shine with specular highlights

4. **Blush**
   - Placement: Cheek apples, draping, or natural
   - 5 shades (rosy pink, peach, berry, coral, bronze)
   - Soft gradient falloff for natural look

5. **Highlighter**
   - Placement: Cheekbones, brow bone, nose bridge, cupid's bow
   - Intensity: Subtle to intense
   - Winter glow effect (soft, not glittery)

**Rendering Pipeline**:

```
Camera Frame → Face Detection → Landmark Extraction →
Makeup Mask Generation → Texture Mapping → Alpha Blending →
Post-Processing (smoothing) → Display
```

**Technical Implementation**:
- Use Flutter's `CustomPaint` widget or native OpenGL/Metal rendering
- Apply makeup as textured meshes mapped to facial regions
- Use alpha blending for semi-transparent makeup (adjustable opacity)
- Implement color correction to match skin undertones
- Edge feathering for natural transitions

**Performance Targets**:
- Render full makeup look at 30 FPS minimum (60 FPS target)
- <16ms frame time on target devices
- Optimize with GPU shaders where possible

**Acceptance Criteria**:
- [ ] Makeup stays aligned during head movement
- [ ] Colors look natural under various lighting
- [ ] No visible seams or harsh edges
- [ ] Lipstick accurately follows lip movements
- [ ] Eyeshadow doesn't "float" when eyes blink
- [ ] Foundation blends seamlessly with skin tone

---

### 3. Live Camera Preview with AR (P0 - Must Have)

**Description**: Full-screen camera view with real-time AR makeup overlay and controls.

**UI Components**:

**Camera View** (Full screen background):
- Live camera feed with AR overlay
- Front-facing camera default (allow flip to rear for testing)
- Pinch to zoom (1x to 2.5x)
- Focus indicator on tap

**Bottom Control Bar**:
- **Makeup Categories** (horizontal scrollable tabs):
  - Face | Eyes | Lips | Cheeks | Highlight | [More]
  - Icons + labels, active state highlight
- **Look Presets** (quick access button):
  - "Snow Muse", "Cozy Cabin", "Winter Date", etc.
  - One-tap to apply full look

**Side Control Panel** (appears when category selected):
- **Product Selector**: Scrollable grid/list of options (colors, styles)
- **Intensity Slider**: 0-100% opacity/strength
- **Remove Button**: Clear current category
- **Info Button**: Show product details (if linked)

**Top Bar**:
- **Close/Back Button** (top-left)
- **Look Name** (center, if preset applied)
- **Capture Button** (top-right camera icon)
- **Settings Icon** (top-right, secondary)

**Capture Flow**:
1. User taps capture button
2. Freeze frame with brief flash animation
3. Auto-save to gallery (with permission)
4. Show preview modal with options:
   - Save to Device
   - Save to App Gallery
   - Share (later phase)
   - Edit Look
   - Discard

**Settings Menu**:
- Toggle: Face mesh debug view (developer mode)
- Lighting adjustment (brightness compensation)
- Camera resolution (auto, high, low)
- Performance mode (reduce quality on low-end devices)

**Acceptance Criteria**:
- [ ] <3 seconds to open camera and initialize AR
- [ ] UI remains responsive during rendering
- [ ] Captured photos save at high resolution (original frame quality)
- [ ] Controls are thumb-reachable on large phones
- [ ] No UI jank or lag during category switching

---

### 4. Curated Winter-Themed Makeup Looks (P0 - Must Have)

**Description**: Pre-designed makeup combinations that users can apply instantly.

**Look Definitions** (Minimum 5 for MVP):

1. **Snow Muse**
   - Foundation: Light, natural coverage
   - Eyes: Frosted silver/white shimmer on lid, soft gray crease
   - Lips: Nude pink, satin finish
   - Blush: Soft rose on apples
   - Highlight: Champagne glow on cheekbones
   - Vibe: Ethereal, icy, elegant

2. **Cozy Cabin**
   - Foundation: Medium, warm undertones
   - Eyes: Warm bronze lid, deep brown crease
   - Lips: Terracotta matte
   - Blush: Peach, natural placement
   - Highlight: Subtle gold
   - Vibe: Warm, approachable, autumn-meets-winter

3. **Winter Date Night**
   - Foundation: Medium, smooth coverage
   - Eyes: Burgundy smokey eye, dark brown outer corner
   - Lips: Deep berry, satin
   - Blush: Mauve, draping style
   - Highlight: Rose gold, intense
   - Vibe: Romantic, bold, sophisticated

4. **Nordic Minimalist**
   - Foundation: Light, dewy finish
   - Eyes: Soft taupe wash, no harsh lines
   - Lips: Barely-there nude
   - Blush: Natural flush, very soft
   - Highlight: Minimal, lit-from-within
   - Vibe: Clean, Scandinavian, effortless

5. **Festive Glam**
   - Foundation: Full coverage, flawless
   - Eyes: Metallic gold lid, dark olive/forest green crease
   - Lips: Classic red, matte
   - Blush: Terracotta, sculpted
   - Highlight: Intense gold
   - Vibe: Holiday party, bold, celebratory

**Data Structure** (JSON example):
```json
{
  "looks": [
    {
      "id": "snow_muse",
      "name": "Snow Muse",
      "description": "Ethereal winter glow",
      "thumbnail": "assets/looks/snow_muse.png",
      "categories": {
        "foundation": {
          "shade": "fair_neutral",
          "coverage": "light",
          "intensity": 0.7
        },
        "eyeshadow": {
          "palette": "frosted_snow",
          "colors": ["#E8F4F8", "#B8D4DB"],
          "intensity": 0.8
        },
        "lips": {
          "color": "#D4A5A5",
          "finish": "satin",
          "intensity": 0.6
        },
        "blush": {
          "color": "#F5C6C6",
          "placement": "apples",
          "intensity": 0.5
        },
        "highlight": {
          "color": "#F7E7CE",
          "areas": ["cheekbones", "nose_bridge"],
          "intensity": 0.7
        }
      },
      "tags": ["ethereal", "light", "elegant"]
    }
  ]
}
```

**Acceptance Criteria**:
- [ ] Each look applies all components simultaneously
- [ ] Looks load in <1 second
- [ ] Users can tweak individual elements after applying preset
- [ ] Look thumbnails accurately represent final result
- [ ] At least 3 looks tested with diverse skin tones for compatibility

---

### 5. Photo Capture & Gallery (P0 - Must Have)

**Description**: Save AR-enhanced photos and view them in an in-app gallery.

**Capture Functionality**:
- Capture current AR view at full camera resolution
- Include/exclude UI (toggle in settings)
- Auto-apply light touch-up (optional, default ON):
  - Skin smoothing (subtle)
  - Brightness adjustment (+5%)
  - Slight saturation boost for makeup

**Gallery Features**:
- Grid view of saved photos (3 columns)
- Sort by: Date (newest first), Look type, Favorites
- Long-press to multi-select
- Actions: Delete, Favorite, Export to device photos
- Empty state: Prompt to try first look

**Photo Metadata** (stored in app database):
- Timestamp
- Look ID and name (if from preset)
- Individual makeup settings (for "recreate" feature)
- Favorite flag (boolean)
- Local file path

**Storage**:
- Save to app's document directory (scoped storage)
- Optionally copy to device photo library (with permission)
- Max 100 photos in gallery (prompt to clean up if exceeded)

**Acceptance Criteria**:
- [ ] Photos saved at ≥1080p resolution
- [ ] Gallery loads instantly with thumbnail caching
- [ ] Photos retained after app restart
- [ ] Delete action includes confirmation dialog
- [ ] Export to device works on both iOS and Android

---

### 6. Makeup Intensity Controls (P0 - Must Have)

**Description**: Fine-tune the opacity/strength of each makeup element.

**Control Type**: Slider (0-100%)
- 0%: Completely transparent (removed)
- 50%: Natural, everyday look
- 100%: Full, bold application

**Behavior**:
- Slider appears when a makeup category is active
- Real-time preview as user drags slider
- Haptic feedback at 0%, 50%, 100% points (iOS/Android)
- Value persists for current session

**Visual Feedback**:
- Number indicator (e.g., "75%") next to slider
- "Before/After" toggle button to compare (hold to show original face)

**Acceptance Criteria**:
- [ ] Slider responds smoothly with no lag
- [ ] Intensity changes reflected immediately in AR view
- [ ] 0% fully removes makeup (not just faded)
- [ ] Settings saved when user switches categories

---

### 7. Basic Error Handling & User Guidance (P0 - Must Have)

**Description**: Provide helpful feedback when things go wrong or conditions aren't optimal.

**Error States**:

1. **Camera Permission Denied**
   - Message: "Camera access required. Please enable in Settings."
   - Action Button: "Open Settings" (deep link)
   - Allow: "Ask Again" (only on Android)

2. **Face Not Detected**
   - Overlay: Semi-transparent frame showing ideal face position
   - Message: "Position your face in the frame"
   - Tips: "Ensure good lighting • Face the camera directly"

3. **Poor Lighting Detected**
   - Icon: Light bulb with warning badge
   - Message: "Low light detected. For best results, move to brighter area."
   - Dismissible banner (user can proceed)

4. **Device Performance Issues**
   - Auto-detect low FPS (<20 FPS for 5 seconds)
   - Prompt: "Reduce quality for smoother experience?"
   - Options: "Optimize Now" | "Keep Current Quality"

5. **AR Not Supported** (old devices)
   - Message: "Your device doesn't meet requirements for AR features."
   - Fallback: Offer static photo upload + manual makeup (Phase 2 feature)

**Guidance Elements**:
- **First-Time User Tutorial** (swipeable cards):
  - Card 1: "Try On Makeup Instantly"
  - Card 2: "Adjust Intensity with Sliders"
  - Card 3: "Capture & Save Your Looks"
  - Card 4: "Tap to Begin!" (Skip button always visible)
- **Tooltips**: Contextual hints on first use of features (e.g., "Tap to select eyeshadow")
- **Empty States**: Friendly messages when gallery is empty

**Acceptance Criteria**:
- [ ] All error states tested and localized
- [ ] Camera permission handled gracefully
- [ ] Users can recover from errors without restarting app
- [ ] Tutorial skippable and never shown again (unless reset in settings)

---

## Non-Functional Requirements

### Performance

| Metric | Target | Minimum Acceptable |
|--------|--------|-------------------|
| AR Frame Rate | 60 FPS | 30 FPS |
| Face Detection Latency | 50ms | 100ms |
| App Cold Start Time | 2 seconds | 3 seconds |
| Makeup Category Switch | Instant (<100ms) | <300ms |
| Photo Capture Time | 1 second | 2 seconds |
| Memory Usage | <200 MB | <350 MB |
| Battery Drain | <10%/hour | <15%/hour |

### Compatibility

**iOS**:
- Minimum: iOS 13.0
- Recommended: iOS 15.0+
- Devices: iPhone 8 and newer (A11 chip+)
- Tested on: iPhone SE 2020, iPhone 12, iPhone 14 Pro

**Android**:
- Minimum: Android 8.0 (API 26)
- Recommended: Android 11+ (API 30+)
- Devices: ARCore compatible devices (most flagships 2018+)
- Tested on: Samsung Galaxy S20, Pixel 5, OnePlus 9

**Screen Sizes**:
- Primary: 5.0" to 6.7" phones (portrait orientation)
- Secondary: 7"+ tablets (basic support, not optimized)

### Accessibility

- **VoiceOver/TalkBack**: All buttons labeled, AR view described as "Camera preview with makeup overlay"
- **Dynamic Type**: Text scales with system font size (up to 2x)
- **Color Contrast**: All text meets WCAG 2.1 AA (4.5:1 for normal, 3:1 for large)
- **Haptic Feedback**: Confirmation vibrations for captures and slider endpoints
- **Alternative Text**: Images have alt descriptions

### Privacy & Security

- **Data Collection**: Only collect anonymous usage analytics (events, no PII)
- **Face Data**: Never stored or transmitted; processed locally in real-time
- **Photos**: Stored locally on device; user controls deletion
- **Permissions**: Request camera only when needed, with clear explanation
- **Third-Party**: No tracking SDKs (Facebook, etc.) in MVP

### Internationalization

- **Phase 1 Languages**: English (US) only
- **Future**: Design UI to support RTL languages (Arabic, Hebrew)
- **Number Formats**: Use system locale for any displayed numbers
- **Date/Time**: Use relative time ("Today", "Yesterday") in gallery

---

## User Flows

### Flow 1: First-Time User - Try First Look

```
1. User opens app for first time
   ↓
2. Onboarding tutorial (4 cards, swipeable)
   → Skip button available
   ↓
3. Camera permission request
   ↓ (if granted)
4. AR Camera view opens
   → Loading face detection (1-2 sec)
   ↓
5. Face detected, green outline appears briefly
   ↓
6. Tooltip: "Tap a look below to try it on!"
   ↓
7. User taps "Snow Muse" preset button
   ↓
8. Full makeup look applies instantly (< 1 sec)
   ↓
9. User sees themselves with makeup
   → Can adjust intensity, switch categories
   ↓
10. User taps camera button
   ↓
11. Capture animation, photo saved
   ↓
12. Preview modal appears
   → Options: Save to Gallery | Share | Edit Look | Discard
   ↓
13. User taps "Save to Gallery"
   ↓
14. Success toast: "Saved to My Looks!"
   → Auto-dismissed after 2 seconds
```

**Success Metrics**:
- >80% complete onboarding (don't skip)
- >90% grant camera permission
- >70% try at least one look in first session
- >50% capture a photo in first session

---

### Flow 2: Returning User - Custom Makeup

```
1. User opens app (camera view auto-opens)
   ↓
2. Face detection starts immediately
   ↓
3. Previous look loads (if exists)
   → or starts with blank face
   ↓
4. User taps "Eyes" category tab
   ↓
5. Side panel opens with eyeshadow options
   ↓
6. User selects "Frosted Snow" palette
   → Eyeshadow applies immediately
   ↓
7. User adjusts intensity slider to 75%
   ↓
8. User taps "Lips" tab
   ↓
9. User selects berry lipstick
   ↓
10. User satisfied with look
   → Taps capture button
   ↓
11. Photo saved to gallery
   ↓
12. User continues exploring or exits
```

**Success Metrics**:
- Average 3+ categories tried per session
- Average 5+ makeup products previewed
- 60%+ users adjust intensity sliders
- 40%+ users capture 2+ photos per session

---

### Flow 3: Error Recovery - No Face Detected

```
1. User opens app in dim lighting
   ↓
2. Camera opens, face detection runs
   ↓
3. No face detected for 3 seconds
   ↓
4. Overlay appears: "Position your face in the frame"
   → Semi-transparent face outline guide
   ↓
5. User adjusts position, still no face
   ↓
6. After 10 seconds, additional tip appears:
   "Try moving to a brighter area"
   ↓
7. User moves to better lighting
   ↓
8. Face detected, tip dismisses
   ↓
9. Normal flow continues
```

**Success Metrics**:
- <5% users abandon due to face detection issues
- Average recovery time: <15 seconds

---

## Technical Implementation Details

### Tech Stack

**Framework**:
- Flutter 3.16+ (stable channel)
- Dart 3.2+

**State Management**:
- Riverpod 2.4+ (recommended) or Bloc 8.1+
- Why: Clean architecture, testability, no boilerplate

**Camera & AR**:
- `camera` ^0.10.5 (Flutter official plugin)
- `google_mlkit_face_detection` ^0.9.0 (ML Kit)
- Alternative: `flutter_mediapipe` or Banuba SDK

**Image Processing**:
- `image` ^4.0.0 (Dart native)
- `flutter_image_compress` (optimize captures)

**Storage**:
- `sqflite` ^2.3.0 (local database for photo metadata)
- `path_provider` ^2.1.0 (app directory access)
- `shared_preferences` ^2.2.0 (settings)

**UI**:
- Material Design 3 components
- Custom painters for makeup overlays
- `flutter_svg` for icons

**Analytics** (basic):
- `firebase_analytics` ^10.7.0 (optional for MVP)

### Project Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart (MaterialApp config)
│   ├── router.dart (go_router setup)
│   └── theme.dart (winter-glam theme)
├── core/
│   ├── constants.dart
│   ├── utils/
│   │   ├── logger.dart
│   │   └── permissions.dart
│   └── errors/
│       └── exceptions.dart
├── features/
│   └── ar_makeup/
│       ├── data/
│       │   ├── models/
│       │   │   ├── makeup_look.dart
│       │   │   ├── makeup_product.dart
│       │   │   └── face_landmark.dart
│       │   ├── repositories/
│       │   │   └── makeup_repository_impl.dart
│       │   └── datasources/
│       │       ├── local_looks_datasource.dart
│       │       └── photo_storage_datasource.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── makeup_look.dart
│       │   │   └── saved_photo.dart
│       │   ├── repositories/
│       │   │   └── makeup_repository.dart
│       │   └── usecases/
│       │       ├── apply_makeup_look.dart
│       │       ├── detect_face.dart
│       │       ├── capture_photo.dart
│       │       └── load_looks.dart
│       └── presentation/
│           ├── providers/ (Riverpod)
│           │   ├── camera_provider.dart
│           │   ├── face_detection_provider.dart
│           │   └── makeup_state_provider.dart
│           ├── screens/
│           │   ├── ar_camera_screen.dart
│           │   └── gallery_screen.dart
│           └── widgets/
│               ├── camera_view.dart
│               ├── makeup_controls.dart
│               ├── look_selector.dart
│               └── intensity_slider.dart
└── assets/
    ├── looks/
    │   ├── looks.json
    │   └── thumbnails/
    ├── fonts/
    └── icons/
```

### Face Detection Implementation (ML Kit Example)

```dart
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart';

class FaceDetectionService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  Future<List<Face>> detectFaces(CameraImage image) async {
    final inputImage = _convertCameraImage(image);
    final faces = await _faceDetector.processImage(inputImage);
    return faces;
  }

  InputImage _convertCameraImage(CameraImage image) {
    // Convert CameraImage to InputImage format
    // Handle image rotation based on device orientation
    // ... implementation details
  }

  FaceLandmarks? extractLandmarks(Face face) {
    return FaceLandmarks(
      leftEye: face.landmarks[FaceLandmarkType.leftEye]?.position,
      rightEye: face.landmarks[FaceLandmarkType.rightEye]?.position,
      noseTip: face.landmarks[FaceLandmarkType.noseBase]?.position,
      mouthLeft: face.landmarks[FaceLandmarkType.leftMouth]?.position,
      mouthRight: face.landmarks[FaceLandmarkType.rightMouth]?.position,
      // ... more landmarks
    );
  }

  void dispose() {
    _faceDetector.close();
  }
}
```

### Makeup Rendering (Custom Painter Example)

```dart
class MakeupOverlayPainter extends CustomPainter {
  final FaceLandmarks landmarks;
  final MakeupLook currentLook;

  MakeupOverlayPainter({
    required this.landmarks,
    required this.currentLook,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw foundation
    if (currentLook.foundation != null) {
      _drawFoundation(canvas, size);
    }

    // Draw eyeshadow
    if (currentLook.eyeshadow != null) {
      _drawEyeshadow(canvas, size);
    }

    // Draw lipstick
    if (currentLook.lipstick != null) {
      _drawLipstick(canvas, size);
    }

    // ... other makeup layers
  }

  void _drawLipstick(Canvas canvas, Size size) {
    // Create lip shape path from landmarks
    final lipPath = Path();
    lipPath.moveTo(landmarks.mouthLeft!.dx, landmarks.mouthLeft!.dy);
    // ... add more points for accurate lip shape

    // Apply lipstick color with blending
    final paint = Paint()
      ..color = currentLook.lipstick!.color.withOpacity(
        currentLook.lipstick!.intensity,
      )
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.multiply; // For natural blending

    canvas.drawPath(lipPath, paint);
  }

  @override
  bool shouldRepaint(MakeupOverlayPainter oldDelegate) {
    return oldDelegate.landmarks != landmarks ||
           oldDelegate.currentLook != currentLook;
  }
}
```

---

## Testing Strategy

### Unit Tests (Target: 70% coverage)

**Test Suites**:
- Face detection service (mock camera images)
- Makeup look loading and parsing
- Photo save/load operations
- State management logic

**Example**:
```dart
test('MakeupLook parses from JSON correctly', () {
  final json = {'id': 'snow_muse', 'name': 'Snow Muse', ...};
  final look = MakeupLook.fromJson(json);
  expect(look.id, 'snow_muse');
  expect(look.name, 'Snow Muse');
});
```

### Integration Tests

**Scenarios**:
- Camera initialization → Face detection → Makeup overlay
- Apply preset look → Adjust intensity → Capture photo
- Gallery load → View photo → Delete photo

**Tools**: `integration_test` package, run on real devices

### Device Testing (Manual)

**Test Devices**:
- iOS: iPhone 8, iPhone 12, iPhone 14 Pro
- Android: Samsung Galaxy S20, Pixel 5, OnePlus 9

**Test Cases**:
- AR performance in varying lighting (bright, dim, mixed)
- Face tracking accuracy with different skin tones and features
- Makeup realism across diverse faces
- Battery and heat during extended use
- Camera orientation changes
- App backgrounding/foregrounding

### Beta Testing

**Closed Beta**: 50-100 users recruited from:
- Beauty enthusiast communities (Reddit, Discord)
- Instagram followers (if existing audience)
- Friends & family

**Feedback Collection**:
- In-app survey after first session (NPS question)
- Bug reporting button (integrated with crash reporting)
- Weekly feedback form via email

**Metrics to Track**:
- Session length (target: >4 minutes average)
- Feature usage (% using each makeup category)
- Crashes and errors
- Satisfaction scores

---

## Success Metrics & KPIs

### Technical Metrics

| Metric | Target | Tracking Method |
|--------|--------|-----------------|
| Crash-Free Rate | 99.5%+ | Firebase Crashlytics |
| AR Frame Rate | 30+ FPS | In-app performance monitor |
| Face Detection Success | 95%+ | Analytics event on detection |
| App Load Time | <3 seconds | Performance profiling |
| Photo Capture Success | 99%+ | Analytics + error logging |

### User Engagement Metrics

| Metric | Target | Tracking Method |
|--------|--------|-----------------|
| First Session Completion | 80%+ | Analytics funnel |
| Makeup Look Try-On Rate | 90%+ | Event: look_applied |
| Photo Capture Rate | 60%+ | Event: photo_captured |
| Return Rate (Day 1) | 40%+ | Cohort analysis |
| Session Length (Avg) | 4+ minutes | Session duration tracking |

### User Satisfaction

| Metric | Target | Tracking Method |
|--------|--------|-----------------|
| NPS Score | 50+ | In-app survey |
| App Store Rating | 4.2+ stars | App Store Connect / Play Console |
| AR Realism Satisfaction | 4+ / 5 | Post-session survey question |

---

## Risks & Mitigation

### High-Priority Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| **AR performance on low-end devices** | High | Medium | Implement adaptive quality settings; graceful degradation to photo mode |
| **Face detection fails for diverse faces** | High | Low | Extensive testing with diverse dataset; ML Kit generally robust |
| **Battery drain too high** | Medium | Medium | Optimize rendering; reduce FPS on low battery; background throttling |
| **Users find AR makeup unrealistic** | High | Medium | Iterate on blending algorithms; beta testing for feedback |
| **Camera permission denial** | Medium | Low | Clear permission explanation; fallback to photo upload |

### Medium-Priority Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| **Development timeline overrun** | Medium | Medium | Prioritize P0 features; cut P1 features if needed |
| **Third-party SDK issues (ML Kit)** | Medium | Low | Have backup plan (MediaPipe); avoid deep coupling |
| **iOS/Android platform differences** | Low | Medium | Platform-specific testing; conditional code where needed |

---

## Dependencies & Assumptions

### Dependencies

**Internal**:
- None (this is Phase 1, foundation)

**External**:
- Google ML Kit Face Detection API (free, stable)
- Flutter SDK updates (must stay on stable channel)
- App Store / Play Store approval (first-time app)

### Assumptions

1. **User Devices**: Assumes 80%+ of target users have devices capable of AR (iPhone 8+, Android 2018+)
2. **Lighting Conditions**: Assumes users will use app primarily in indoor/decent lighting (not pitch dark)
3. **Permission Grant**: Assumes 85%+ users will grant camera permission after explanation
4. **Design Assets**: Assumes makeup textures and look definitions will be created by design team concurrently
5. **Network**: No network required for Phase 1 (all on-device)

---

## Delivery & Acceptance

### Definition of Done

Phase 1 is considered complete when:

- [ ] All P0 features implemented and tested
- [ ] Unit test coverage ≥70%
- [ ] Integration tests pass on 5+ test devices
- [ ] Closed beta launched with 50+ users
- [ ] No P0 bugs remaining in backlog
- [ ] App Store and Play Store builds submitted
- [ ] Documentation complete (README, API docs)
- [ ] Handoff to Phase 2 team complete

### Acceptance Criteria (Stakeholder Sign-Off)

- [ ] **Product**: All features from requirements section functional
- [ ] **Engineering**: Code reviewed, no critical tech debt
- [ ] **Design**: UI matches Figma specs, winter theme consistent
- [ ] **QA**: All test plans executed, <5 open bugs (all P2/P3)
- [ ] **Beta Users**: NPS >50, no major usability complaints

---

## Timeline & Milestones

### Week-by-Week Plan

**Weeks 1-2: Setup & Architecture**
- Project setup (repo, CI/CD, team onboarding)
- Tech stack finalization
- Architecture design review
- Design handoff (Figma mockups, assets)
- Sprint planning

**Weeks 3-4: Core AR Infrastructure**
- Camera integration (Flutter camera plugin)
- Face detection implementation (ML Kit)
- Landmark extraction and mapping
- Basic AR overlay proof-of-concept
- **Milestone**: Face detected and tracked in real-time

**Weeks 5-6: Makeup Rendering**
- Implement makeup rendering pipeline
- Foundation and lipstick overlays (priority)
- Alpha blending and color correction
- Eyeshadow and blush overlays
- **Milestone**: All 5 makeup categories render

**Weeks 7-8: UI & Controls**
- AR camera screen layout
- Makeup category selector
- Intensity sliders
- Look presets implementation
- **Milestone**: Full UI functional end-to-end

**Weeks 9-10: Photo Capture & Gallery**
- Capture functionality
- Gallery screen
- Photo storage and metadata
- Export to device photos
- **Milestone**: Users can save and view photos

**Weeks 11-12: Polish & Testing**
- Error handling and user guidance
- Performance optimization
- Beta launch prep
- Bug fixing
- App store assets (screenshots, description)
- **Milestone**: Beta release to 50 users

### Key Milestones

| Milestone | Target Date | Deliverable |
|-----------|-------------|-------------|
| M1: Project Kickoff | Week 1 | Team onboarded, tasks assigned |
| M2: AR Prototype | Week 4 | Face tracking demo |
| M3: Makeup Rendering Complete | Week 6 | All makeup types visible |
| M4: Alpha Build | Week 8 | Internal testing build |
| M5: Feature Complete | Week 10 | All P0 features done |
| M6: Closed Beta Launch | Week 12 | 50+ beta users onboarded |
| M7: Public Launch | Week 14 | App stores live |

---

## Budget Estimate

### Development Costs

**Team** (10 weeks, post-setup):
- 2 Senior Flutter Developers: $12K/week x 10 = $120K
- 1 ML/Computer Vision Engineer: $14K/week x 8 = $112K
- 1 UI/UX Designer: $8K/week x 6 = $48K
- 1 QA Engineer: $6K/week x 6 = $36K

**Total Development**: ~$316K

### Tools & Services

- Firebase (free tier for MVP)
- App Store + Play Store fees: $124/year
- Design tools (Figma Pro): $45/month x 3 = $135
- Device testing (physical devices): $5K
- Beta testing platform (TestFlight + Play Console): Free

**Total Tools**: ~$5.3K

**Phase 1 Total Budget**: ~$321K

---

## Appendix

### Glossary

- **AR**: Augmented Reality
- **FPS**: Frames Per Second
- **ML**: Machine Learning
- **MVP**: Minimum Viable Product
- **NPS**: Net Promoter Score
- **P0/P1/P2**: Priority levels (0 = Must Have, 1 = Should Have, 2 = Nice to Have)
- **PRD**: Product Requirements Document
- **UI/UX**: User Interface / User Experience

### References

- [Google ML Kit Face Detection Docs](https://developers.google.com/ml-kit/vision/face-detection)
- [Flutter Camera Plugin](https://pub.dev/packages/camera)
- [MediaPipe Face Mesh](https://google.github.io/mediapipe/solutions/face_mesh.html)
- [Banuba SDK for Flutter](https://www.banuba.com/flutter-sdk)
- EM360Tech: Virtual Makeup Try-On Market Report (2024)
- Perfect Corp: YouCam AR Beauty Statistics (2024)

### Related Documents

- [Master PRD](../00-MASTER-PRD.md)
- [Phase 2 PRD - AI Shade Finder](./phase-2-ai-shade-finder.md)
- [Technical Architecture](../technical-architecture.md)
- [Design System](../design-system.md) *(To be added)*

---

**Document Owner**: Product Management
**Last Updated**: 2025-11-13
**Version**: 1.0
**Status**: Approved for Development

**Approved By**:
- [ ] Product Manager
- [ ] Engineering Lead
- [ ] Design Lead
- [ ] QA Lead

---

*This PRD is a living document and may be updated as requirements evolve during development. All major changes require stakeholder review and approval.*
