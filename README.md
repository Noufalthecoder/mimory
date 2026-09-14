<div align="center">

<img src="assets/docs/hero_banner.svg" alt="MIMORY — Your people. Your moments. Your world." width="100%"/>

<br/>

<a href="https://github.com/Noufalthecoder/mimory"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter"/></a>
<a href="https://github.com/Noufalthecoder/mimory"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart"/></a>
<a href="https://github.com/Noufalthecoder/mimory"><img src="https://img.shields.io/badge/RevenueCat-purchases__flutter-E56A38?style=flat-square" alt="RevenueCat"/></a>
<a href="https://github.com/Noufalthecoder/mimory"><img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-5856D6?style=flat-square" alt="Platform"/></a>
<a href="https://github.com/Noufalthecoder/mimory"><img src="https://img.shields.io/badge/Architecture-Local--First-5F9E52?style=flat-square" alt="Local-First"/></a>
<a href="https://github.com/Noufalthecoder/mimory"><img src="https://img.shields.io/badge/Tests-36%20Passed-4CAF50?style=flat-square" alt="Tests"/></a>

<br/><br/>

[**The Human Problem**](#sometimes-one-moment-makes-us-forget-all-the-others) • [**The Living World Idea**](#what-if-your-memories-had-a-place-to-live) • [**The Emotional Loop**](#the-emotional-loop) • [**Memory Walk**](#signature-experience-memory-walk) • [**System Architecture**](#system-architecture) • [**RevenueCat Monetization**](#revenuecat--mimory-monetization) • [**Verification**](#verification--test-suite) • [**Quickstart**](#getting-started)

</div>

---

## Sometimes one moment makes us forget all the others.

People regularly capture meaningful moments with the people they care about: photos, messages, trips, inside jokes, and quiet everyday memories.

Yet those moments usually disappear into chronological camera rolls, endless message threads, and forgotten cloud storage.

More importantly, relationships naturally go through quiet periods:
- Life becomes busy.
- Someone moves away.
- Communication slows down.
- A small misunderstanding happens.

In those moments, it is easy to become focused on the latest quietness or conflict, temporarily forgetting the much larger, warmer story already built together.

> ### *MIMORY doesn't judge your relationships. MIMORY remembers them with you.*

MIMORY preserves meaningful memories inside dedicated, living worlds. When a world has been quiet for a while, MIMORY can gently surface an older moment worth remembering—not as a guilt-driven relationship analysis, but as a gentle reminder of the foundation that already exists.

<br/>

<div align="center">
  <img src="assets/docs/emotional_loop.svg" alt="The Emotional Loop of MIMORY" width="100%"/>
</div>

<br/>

---

## What if your memories had a place to live?

MIMORY gives memories a spatial, emotional presence instead of leaving them as a flat chronological list:

```
  Camera Roll  ──→  Living Storybook World
        Photo  ──→  Interactive Keepsake
       Memory  ──→  Physical Landmark
 Relationship  ──→  Dedicated World (Partner, Best Friend, Family)
     Timeline  ──→  Story You Can Walk Through
```

When you create a world for someone important, you choose customizable chibi avatars and select a storybook aesthetic (*Cozy Town*, *Starlit Forest*, *Blooming Meadow*, or *Sunlit Valley*). As you add memories, they take root as interactive physical landmarks along scenic walking paths.

<br/>

<div align="center">
  <img src="assets/docs/product_flow.svg" alt="From a Moment to a Living World — 6 Product Stages" width="100%"/>
</div>

<br/>

---

## The Core Product Experience

<table>
  <tr>
    <td width="50%" valign="top">
      <h3>🏡 1. Dedicated Relationship Worlds</h3>
      <p>Create separate, personal worlds for each relationship (Partner, Best Friend, Family). Customize chibi avatars with individualized hairstyles, hair colors, skin tones, and outfits.</p>
    </td>
    <td width="50%" valign="top">
      <h3>📸 2. Keepsake Photo &amp; Story Preservation</h3>
      <p>Preserve milestones as photo keepsakes or written story vignettes. Photos are persisted in app-controlled local sandbox storage, surviving device restarts and OS updates.</p>
    </td>
  </tr>
  <tr>
    <td width="50%" valign="top">
      <h3>🚶‍♀️ 3. 2.5D Interactive Memory Walk</h3>
      <p>Explore your world using a responsive 360° virtual joystick. Stroll along cobblestone paths, follow directional signposts pointing to past memories, and hold hands with your companion character.</p>
    </td>
    <td width="50%" valign="top">
      <h3>📍 4. Proximity Landmark Reliving</h3>
      <p>As you approach memory landmarks in the world, they illuminate with subtle proximity glows. Tapping a landmark smoothly presents the keepsake sheet with its story, date, and original photo.</p>
    </td>
  </tr>
  <tr>
    <td width="50%" valign="top">
      <h3>🌤️ 5. Real-Time Atmospheric Conditions</h3>
      <p>Worlds reflect natural time cycles (Morning, Day, Sunset, Night) and seasonal weather (Rain with shared umbrellas, Winter snowfall with cozy accessories, and evening fireflies).</p>
    </td>
    <td width="50%" valign="top">
      <h3>✨ 6. Organic World Expansion</h3>
      <p>As you add memories, the world dynamically scales its terrain boundaries, environmental flora density, and companion animal behaviors.</p>
    </td>
  </tr>
</table>

---

## Signature Experience: Memory Walk

Instead of scrolling through your memories, **Memory Walk** lets you walk through them together.

Memories become physical landmarks along winding paths. Direction signposts point the way toward milestones, and both characters explore in real time, sharing an umbrella when it rains or holding hands along the journey.

<br/>

<div align="center">
  <img src="assets/docs/memory_walk_diagram.svg" alt="Memory Walk Spatial Engine" width="100%"/>
</div>

<br/>

### Spatial Math Highlights

1. **3D Perspective Camera (`Camera3D`)**: Mathematically projects 3D world coordinates `(x, y, z)` into screen space `(dx, dy)` using focal length (`500.0`) and pitch angles (`0.35 rad`), applying painter's algorithm depth sorting and distance scaling (`scale = focal / depth`).
2. **Smooth Follow with Soft Dead-Zone**: A cinematic camera dead-zone (`dx: 20`, `dy: 25`) absorbs small joystick micro-movements, preventing camera jitter while smoothly following players via damped lag interpolation (`lagT = 0.15`).
3. **Synchronized Paired Controller**: Custom `CustomPainter` character models synchronize leg swing cycles, direction facing, shared umbrella holding during rain, and hand-holding positions.

---

## System Architecture

MIMORY is engineered as a local-first, modular Flutter application with strict domain separation, reactive service orchestration, and verified entitlement monetization.

<br/>

<div align="center">
  <img src="assets/docs/system_architecture.svg" alt="MIMORY System Architecture" width="100%"/>
</div>

<br/>

### Architectural Principles

- **Presentation Layer (`lib/features/`)**: Self-contained feature modules managing screen lifecycles, user inputs, and navigation without coupling to data storage mechanisms.
- **Core Design Tokens (`lib/core/`)**: Unified storybook design system with tactile pill buttons, custom text fields, and soft elevation tokens in `AppTheme`.
- **Domain State Singletons (`lib/services/`)**: `WorldService` orchestrates user session, world management, and 1:N memory relations. `RevenueCatService` evaluates verified entitlement streams.
- **Local-First Reliability**: `StorageService` serializes data to `SharedPreferences` while `path_provider` sandboxes high-resolution photos in `/mimory_photos/`, eliminating mandatory cloud dependencies.

---

## RevenueCat & MIMORY+ Monetization

MIMORY integrates the official RevenueCat Flutter SDK (`purchases_flutter: ^10.12.0`) to power the **MIMORY+** premium experience for the RevenueCat Shipaton.

<br/>

<div align="center">
  <img src="assets/docs/revenuecat_architecture.svg" alt="RevenueCat Monetization Architecture" width="100%"/>
</div>

<br/>

### Monetization Engineering

- **Entitlement-Driven Access**: Premium state is strictly evaluated via RevenueCat's verified `CustomerInfo.entitlements['mimory_plus'].isActive`. There are zero local bypass flags or unverified states.
- **Truthful Capability Model (`MimoryPlusCapability`)**: Paywalls and unlock celebration screens dynamically query `MimoryPlusCapability.unlockedForPlus`, presenting only genuinely implemented capabilities (`implemented == true`).
- **Reactive State Propagation**: `RevenueCatService` extends `ChangeNotifier`, broadcasting instant entitlement updates across the UI upon purchase or restore.
- **Test Store / Sandbox Ready**: Pre-configured with a public Test Store key (`test_aToLAmiQXjnnqPxxxISoWwxRVAK`) for immediate sandbox evaluation without requiring live App Store / Google Play merchant credentials.

---

## Engineering Decisions

- **Local-First Reliability**: Memories are personal and sacred. All worlds, memories, and photos persist locally on device with zero cloud synchronization requirements for the core product experience.
- **Strict 1:N World-Memory Isolation**: Each memory is bound to a persistent `worldId` via deterministic UUIDv4 identifiers, guaranteeing that memories never leak between separate relationships.
- **Custom Canvas Rendering**: Programmatic Flutter `CustomPainter` rendering delivers native 60fps mobile canvas performance on iOS and Android without heavy 3D asset bundles.
- **Clean Service Boundaries**: Services expose clean async contracts (`createWorld`, `purchasePackage`, `persistPhoto`) and emit reactive notifications via `ChangeNotifier`.

---

## Data Model

```
 ┌───────────────────────────────────┐
 │               World               │
 ├───────────────────────────────────┤
 │ id: String (UUID)                 │
 │ name: String                      │
 │ relationshipType: String          │
 │ personName: String                │
 │ nickname: String?                 │
 │ userAvatarId: String              │
 │ companionAvatarId: String         │
 │ worldStyle: String                │
 │ createdAt: DateTime               │
 └─────────────────┬─────────────────┘
                   │
                   │ 1 : N (via worldId)
                   ▼
 ┌───────────────────────────────────┐       ┌───────────────────────────────────┐
 │              Memory               │       │             Character             │
 ├───────────────────────────────────┤       ├───────────────────────────────────┤
 │ id: String (UUID)                 │       │ id: String                        │
 │ worldId: String                   │◄──────┤ worldId: String                   │
 │ type: MemoryType (photo | story)  │       │ personName: String                │
 │ title: String                     │       │ hairStyle: String                 │
 │ description: String               │       │ hairColor: Color                  │
 │ imagePath: String?                │       │ skinTone: Color                   │
 │ memoryDate: DateTime              │       │ outfitColor: Color                │
 │ createdAt: DateTime               │       │ isCurrentUser: bool               │
 └───────────────────────────────────┘       └───────────────────────────────────┘
```

---

## Technology

<br/>

<div align="center">
  <img src="assets/docs/tech_stack.svg" alt="Technology Stack" width="100%"/>
</div>

<br/>

| Layer | Technology | Architectural Rationale |
|---|---|---|
| **Framework** | Flutter 3.x / Dart | Single cross-platform codebase delivering native 60fps canvas rendering on iOS and Android. |
| **Monetization** | RevenueCat SDK (`purchases_flutter: ^10.12.0`) | Server-side receipt validation, offerings delivery, and cross-platform entitlement management. |
| **Local Persistence** | `shared_preferences: ^2.5.5` | Fast, lightweight local key-value persistence for structured JSON worlds, memories, and sessions. |
| **Document Storage** | `path_provider: ^2.1.6` | App-controlled sandboxed document storage for local image and photo preservation across app restarts. |
| **Typography** | `google_fonts: ^6.2.1` | Curated storybook typography pairing Playfair Display headings with Plus Jakarta Sans body copy. |
| **Media Capture** | `image_picker: ^1.0.7` | Native gallery image selection with safe sandbox persistence. |
| **Identity** | `uuid: ^4.3.3` | Cryptographically secure UUIDv4 generation for deterministic entity relationships. |

---

## Project Structure

```
lib/
├── core/
│   ├── theme/               # Storybook typography, color palettes, shadows
│   └── widgets/             # Tactile buttons, text fields, cards, branding icons
├── features/
│   ├── auth/                # Welcome screen, mock Google & Email session persistence
│   ├── memory/              # Keepsake creation wizard, photo picker, detail sheet
│   ├── monetization/        # MIMORY+ paywall, celebration screen, capability cards
│   └── world/               # World creation wizard, avatar selector, world overview
├── models/
│   ├── avatar_definition.dart     # Preset chibi avatar profiles and palettes
│   ├── character.dart             # Living character state (hair, skin, outfit)
│   ├── memory.dart                # Photo and story keepsake data models
│   ├── mimory_plus_capability.dart# Truthful monetization capability catalog
│   ├── user_session.dart          # Local session and authentication identity
│   ├── world.dart                 # World metadata, style, and companion bindings
│   ├── world_environment_config.dart # Atmospheric lighting, time, season tokens
│   └── world_point.dart           # 3D spatial vector and distance math
├── services/
│   ├── revenue_cat_config.dart    # Public SDK keys and entitlement definitions
│   ├── revenue_cat_service.dart   # Purchases SDK singleton & entitlement stream
│   ├── storage_service.dart       # SharedPreferences and document directory storage
│   └── world_service.dart         # Core application state manager
├── widgets/
│   ├── anime_character_widget.dart# CustomPainter storybook character renderer
│   ├── couple_character_pair_widget.dart # Paired couple walking & hand holding
│   └── memory_walk/               # 3D perspective terrain, camera, landmarks, animals
└── main.dart                # Application bootstrap & service initialization
```

---

## Verification & Test Suite

MIMORY includes comprehensive automated test suites covering data persistence, memory boundary isolation, 3D camera projection, weather algorithms, and RevenueCat integration.

```
test/
├── product_functionality_test.dart   # World/memory persistence, session isolation, routing
├── living_world_test.dart            # Time-of-day/season algorithms, ambient weather layers
├── stable_memory_walk_test.dart      # Memory Walk joystick, hand holding, signboard constraints
├── third_person_world_test.dart      # Camera3D perspective math, deadzone follow, depth sorting
└── revenue_cat_service_test.dart     # Entitlement matching, singleton consistency, capability truthfulness
```

### Verified Test Results

```
$ flutter analyze
✓ No issues found! (0 warnings, 0 errors)

$ flutter test
✓ test/product_functionality_test.dart: All 8 tests passed
✓ test/living_world_test.dart: All 11 tests passed
✓ test/stable_memory_walk_test.dart: All 3 tests passed
✓ test/third_person_world_test.dart: All 8 tests passed
✓ test/revenue_cat_service_test.dart: All 5 tests passed
✓ test/widget_test.dart: Passed
────────────────────────────────────────────
✓ 36 / 36 tests passed
```

---

## Current Status

To ensure complete transparency and trustworthiness, here is the verified status of each component in the repository:

| Capability / Component | Implementation Status | Notes |
|---|---|---|
| **Flutter Mobile App** | ✅ Implemented | Tested on Android & iOS |
| **World Creation & Avatars** | ✅ Implemented | 4 world styles, customizable avatar pairs |
| **Keepsake Memory Storage** | ✅ Implemented | Photos & written stories with persistent local storage |
| **Interactive Memory Walk** | ✅ Implemented | 3D perspective terrain, joystick, paired couple walk |
| **Living Atmosphere** | ✅ Implemented | Real-time time of day, rain, snow, fireflies, rabbits |
| **RevenueCat MIMORY+ Flow** | ✅ Implemented | Monthly, Yearly, Lifetime packages & entitlement checks |
| **RevenueCat Test Store** | ✅ Configured | Ready for testing without requiring live merchant setup |
| **Cloud Synchronization** | ⏳ Planned | Current architecture is local-first |
| **Audio Memory Echoes** | ⏳ Planned | Roadmap feature explicitly tagged in capability model |

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.13.3 or higher)
- Android Studio / Xcode (for device deployment or simulators)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/Noufalthecoder/mimory.git
cd mimory

# 2. Install dependencies
flutter pub get

# 3. Run automated tests to verify your environment
flutter test

# 4. Launch the application
flutter run
```

---

## RevenueCat Setup & Testing

MIMORY comes pre-configured with a RevenueCat Test Store public SDK key (`test_aToLAmiQXjnnqPxxxISoWwxRVAK`) for development and evaluation.

### Testing Purchases in Sandbox / Test Store:
1. Launch MIMORY on a physical device or emulator.
2. Tap the **MIMORY+** button in the header or world screen.
3. Select any offering (**Monthly**, **Yearly**, or **Lifetime**).
4. Complete the transaction using RevenueCat's sandbox/test sheet.
5. The application will immediately verify the `mimory_plus` entitlement and transition into the **"Your little world just grew. ♡"** celebration screen.

### Configuring Your Own RevenueCat Project:
1. Create a project at [app.revenuecat.com](https://app.revenuecat.com).
2. Create an Entitlement with identifier `mimory_plus`.
3. Set up your products and attach them to a default offering.
4. Replace the public SDK keys in `lib/services/revenue_cat_config.dart`.

---

## Privacy & Data Handling

- **Local-First Storage**: All world details, memory photos, notes, and avatars remain stored locally on your device.
- **Zero Third-Party Data Tracking**: Photos and personal stories are never shared with advertising networks or third-party servers.
- **Secure Purchases**: Subscription receipts and customer info are validated securely through RevenueCat and platform payment channels.

---

## License

This project is created for evaluation and personal memory keeping. All rights reserved.
