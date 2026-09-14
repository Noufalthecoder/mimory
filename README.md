# MIMORY ♡

## Your people. Your moments. Your world.

A living memory experience that turns meaningful moments shared with the people who matter into little worlds you can revisit, explore, and grow.

```
Flutter  •  Dart  •  RevenueCat  •  Local-First  •  iOS & Android
```

[Repository](https://github.com/Noufalthecoder/mimory) • [Documentation](#architecture) • [Getting Started](#getting-started) • [MIMORY+ Monetization](#mimory)

---

## A memory shouldn't disappear into a camera roll.

People accumulate meaningful moments with partners, close friends, and family—trips taken, quiet evenings, inside jokes, and milestones. Today, these moments usually end up trapped in chronological camera rolls or social feeds designed for public consumption rather than personal intimacy.

**MIMORY gives those moments a place to live.**

Instead of scrolling through a flat grid of timestamps, MIMORY lets you build dedicated, storybook-style worlds for each relationship. Moments become physical landmarks along scenic walking paths, weather changes with the seasons and time of day, and the world itself visibly expands as your shared story deepens.

---

## From a moment to a little world.

```
Moment  ──→  Memory  ──→  Living World  ──→  Explore  ──→  Remember  ──→  Grow
```

- **Moment**: Something meaningful happens between you and someone you care about.
- **Memory**: You capture it as a photo or story with a date, title, and heartfelt note.
- **Living World**: The memory is placed as an interactive landmark inside your dedicated world.
- **Explore**: Walk through the environment together using intuitive joystick controls.
- **Remember**: Approach any landmark to open and relive that exact memory.
- **Grow**: As you record more memories, the environment blooms, expands, and deepens.

---

## The experience

### 1. Create a World
Create a personalized space for each meaningful relationship (Partner, Best Friend, Family). Choose custom chibi storybook avatars with individualized hairstyles, hair colors, skin tones, and outfits, set across distinct themes like *Cozy Town*, *Starlit Forest*, *Blooming Meadow*, and *Sunlit Valley*.

### 2. Keep a Memory
Capture milestones as photo keepsakes or written story vignettes. Every memory is preserved with high-resolution image persistence in local sandbox storage.

### 3. Walk Through It (Memory Walk)
Step into a third-person, 2.5D perspective walking world. Navigate paths with a responsive virtual joystick, approach signposts pointing toward past memories, and tap to hold hands with your companion character as you explore together.

### 4. Remember When?
Landmarks react dynamically as you approach. Tapping any landmark smoothly opens the keepsake detail sheet, presenting the full story, date, and original photo.

### 5. Living Conditions
Worlds reflect natural atmospheric cycles in real-time or through custom moods:
- **Time of Day**: Crisp morning light, warm daylight, golden sunset skies, and lantern-lit indigo nights.
- **Dynamic Weather**: Clear sunshine, gentle rain (where characters share an umbrella), and peaceful snowfall (with cozy winter accessories).
- **Ambient Life**: Floating butterflies, glowing fireflies at night, passing clouds, and curious garden rabbits that react to the weather.

### 6. Watch It Grow
The physical boundaries, nature density, and ambient richness of each world scale dynamically with the number of memories you create together.

---

## Memory Walk Architecture

Memory Walk is one of MIMORY’s signature features. It transforms abstract dates into an explorable spatial journey.

```
┌─────────────────────────────────────────────────────────────┐
│                    Stable Memory Walk World                 │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐   │
│   │   Living World Layers                               │   │
│   │   [ Sky & Sun/Moon | Mountains | Meadows | Trees ]   │   │
│   └─────────────────────────────────────────────────────┘   │
│                             │                               │
│   ┌─────────────────────────▼───────────────────────────┐   │
│   │   Perspective Camera & Spatial Math                 │   │
│   │   • Camera3D depth projection & scaling             │   │
│   │   • Soft dead-zone anchor & smooth lag damping      │   │
│   └─────────────────────────┬───────────────────────────┘   │
│                             │                               │
│   ┌─────────────────────────▼───────────────────────────┐   │
│   │   Interactive Entities                              │   │
│   │   • Paired Character Controller (Hand Holding)      │   │
│   │   • Directional Signposts                           │   │
│   │   • Reactive Memory Landmarks                       │   │
│   │   • Environmental Animals (Garden Rabbit)           │   │
│   └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

- **Perspective Projection**: Mathematical 3D-to-2D depth projection (`Camera3D`) scales objects, landmarks, and characters smoothly based on distance from the lens while maintaining painter's algorithm depth sorting.
- **Camera Anchor & Dead-Zone**: A soft dead-zone prevents camera jitter during subtle joystick micro-movements, creating a cinematic, grounded walking feel.
- **Character Animation Pairing**: Characters feature custom Canvas-drawn animations that synchronize walking cycles, direction facing, umbrella holding during rain, and hand holding.

---

## MIMORY+

MIMORY integrates RevenueCat (`purchases_flutter`) for seamless, cross-platform subscription and lifetime purchase management.

### Monetization Flow

```
   Monthly Package ───┐
    Yearly Package ───┼──→ RevenueCat Offering ('default')
  Lifetime Package ───┘                │
                                       ▼
                            Purchases SDK Transaction
                                       │
                                       ▼
                           'mimory_plus' Entitlement
                                       │
                                       ▼
                       Reactive Premium State Broadcast
                                       │
                                       ▼
                        MIMORY+ Unlocked Capabilities
                     • Unlimited Memory Worlds
                     • Dynamic Weather & Atmosphere
                     • Living Storybook Companions
```

### Engineering Principles for Monetization

1. **Entitlement-Driven Architecture**: Premium access is strictly determined by RevenueCat's verified `CustomerInfo.entitlements['mimory_plus'].isActive` state. The application contains zero bypass flags or fake local unlock mechanisms.
2. **Truthful Capability Model (`MimoryPlusCapability`)**: The paywall and post-purchase celebration screens dynamically render only verified, currently implemented capabilities (`implemented == true`), ensuring complete product truthfulness.
3. **Reactive UI State**: `RevenueCatService` extends `ChangeNotifier`, instantly propagating purchase and restore events across active screens without requiring app restarts.
4. **Graceful Degradation**: If network access is lost or API keys are unconfigured, the app falls back safely to the core free tier without crashing.

---

## Architecture

MIMORY is engineered as a local-first, modular Flutter application built around clear domain boundaries and clean service contracts.

```
                           ┌─────────────────────────┐
                           │       MimoryApp         │
                           │   (AppTheme / Router)   │
                           └────────────┬────────────┘
                                        │
           ┌────────────────────────────┼────────────────────────────┐
           ▼                            ▼                            ▼
  ┌──────────────────┐        ┌──────────────────┐        ┌──────────────────┐
  │  features/auth   │        │  features/world  │        │ features/memory  │
  │  • WelcomeScreen │        │  • WorldScreen   │        │ • FirstMemory    │
  │  • LoginScreen   │        │  • YourWorlds    │        │ • MemoryDetail   │
  └──────────────────┘        │  • CreateWorld   │        └──────────────────┘
                              └────────┬─────────┘
                                       │
                                       ▼
                         ┌───────────────────────────┐
                         │   features/monetization   │
                         │   • MimoryPlusPaywall     │
                         │   • MimoryCelebration     │
                         │   • CapabilityCards       │
                         └─────────────┬─────────────┘
                                       │
 ┌─────────────────────────────────────┴─────────────────────────────────────┐
 │                             Domain & Services                             │
 │                                                                           │
 │   ┌──────────────────────┐  ┌──────────────────────┐  ┌────────────────┐  │
 │   │     WorldService     │  │    StorageService    │  │ RevenueCatServ │  │
 │   │  (State & Lifecycle) │  │  (Local Persistence) │  │ (Monetization) │  │
 │   └──────────────────────┘  └──────────────────────┘  └────────────────┘  │
 └─────────────────────────────────────┬─────────────────────────────────────┘
                                       │
                                       ▼
                   ┌───────────────────────────────────────┐
                   │             Data Models               │
                   │  • World           • Memory           │
                   │  • Character       • Environment      │
                   │  • UserSession     • Capabilities     │
                   └───────────────────────────────────────┘
```

### Architectural Responsibilities

- **Presentation Layer (`lib/features/`)**: Self-contained feature modules managing screen lifecycles, user inputs, and navigation.
- **Core Design System (`lib/core/`)**: Reusable UI components (`TactilePillButton`, `MimoryTextField`, `StorybookCard`) and design tokens (`AppTheme`).
- **Domain Services (`lib/services/`)**: Isolated singletons managing state orchestration (`WorldService`), persistent disk I/O (`StorageService`), and monetization (`RevenueCatService`).
- **Data Models (`lib/models/`)**: Immutable data definitions with strict JSON serialization/deserialization and zero UI dependencies.

---

## Project Structure

```
lib/
├── core/
│   ├── theme/               # Colors, typography (Playfair / Plus Jakarta), shadows
│   └── widgets/             # Tactile buttons, text fields, cards, branding icons
├── features/
│   ├── auth/                # Welcome screen, mock Google/Email authentication
│   ├── memory/              # First memory creation, keepsake detail sheet
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

| Layer | Technology | Architectural Rationale |
|---|---|---|
| **Framework** | Flutter 3.x / Dart | Single cross-platform codebase delivering native 60fps canvas rendering on iOS and Android. |
| **Monetization** | RevenueCat SDK (`purchases_flutter: ^10.12.0`) | Server-side verified receipt validation, cross-platform offerings, and entitlement state management. |
| **Local Persistence** | `shared_preferences: ^2.5.5` | Fast, lightweight local key-value persistence for structured JSON worlds, memories, and sessions. |
| **Document Storage** | `path_provider: ^2.1.6` | App-controlled sandboxed document storage for local image and photo preservation across app restarts. |
| **Typography** | `google_fonts: ^6.2.1` | Tailored storybook typography pairing Playfair Display headings with Plus Jakarta Sans body copy. |
| **Media Capture** | `image_picker: ^1.0.7` | Native gallery image selection with safe sandbox persistence. |
| **Identity** | `uuid: ^4.3.3` | Cryptographically secure UUIDv4 generation for deterministic entity relationships. |

---

## Engineering Highlights

- **Local-First Reliability**: All user data, worlds, memories, and photos persist locally on device. No mandatory cloud accounts or external dependencies are required to experience the full app.
- **Continuous Session Persistence**: User identity and session state persist across app termination while keeping user content safely isolated.
- **Custom Canvas Rendering**: Characters, weather layers, and perspective terrain are rendered programmatically via Flutter's `CustomPainter` API, avoiding heavy 3D asset bundles while ensuring high-frame-rate mobile performance.
- **Isolated Service Contracts**: Services expose clean async interfaces (`createWorld`, `purchasePackage`, `persistPhoto`) and emit reactive notifications via `ChangeNotifier`.

---

## Verification & Testing

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

## Demo

A complete walkthrough video of the MIMORY onboarding, world creation, living atmospheric walk, and MIMORY+ purchase experience:

> 🎬 *Demo video coming soon for Shipaton submission.*

---

## Privacy & Data Handling

MIMORY respects personal intimacy:
- **Local-First**: All world details, memory photos, notes, and avatars remain stored locally on your device.
- **Zero Third-Party Data Sharing**: Photos are never uploaded to third-party ad networks or unverified servers.
- **Secure Purchases**: All subscription transactions are handled securely through RevenueCat and platform payment systems.

---

## License

This project is created for evaluation and personal memory keeping. All rights reserved.
