# GPS Tracker

A cross-platform Flutter application for recording GPS tracking sessions with real-time battery monitoring, background location capture, route visualization, and full session history management.

---

## Description

GPS Tracker allows users to start and stop location tracking sessions that continue recording in the background — even when the app is minimized, the screen is locked, or (on Android) the app is removed from recent apps. Each session captures GPS coordinates every 60 seconds and stores them locally. Users can review past sessions, view captured coordinates on an interactive map, and delete sessions they no longer need.

Battery information is read directly from native platform APIs (Android `BatteryManager`, iOS `UIDevice`) via Flutter platform channels — no third-party battery packages are used.

### Key Features

- **Live battery monitoring** — reads and streams battery percentage from native code via `MethodChannel` and `EventChannel`
- **Background GPS tracking** — continues recording when minimized, screen locked, or removed from recents (Android foreground service with `START_STICKY`; iOS background location updates)
- **60-second location capture** — latitude, longitude, accuracy, and timestamp saved per point
- **Session history** — browse all past sessions with start time, end time, duration, and point count
- **Session detail** — full list of captured coordinates with timestamps and accuracy values
- **Interactive map** — route rendered as a polyline on OpenStreetMap tiles with start/end markers
- **Session deletion** — permanently remove a session and all its location data
- **Environment configuration** — dev / staging / prod `.env` files control intervals, logging, and map tile URL

---

## Technology Stack

### Flutter / Dart

| Technology | Purpose |
|---|---|
| **Flutter 3.x** | Cross-platform UI framework |
| **Dart 3.x** | Application language |
| **flutter_bloc 8** | BLoC state management pattern |
| **equatable** | Value equality for BLoC states and events |
| **get_it** | Service locator / dependency injection container |
| **injectable** | Code-generation annotations for get_it |
| **hive + hive_flutter** | Lightweight NoSQL local database (no SQLite) |
| **geolocator** | GPS coordinate access and streaming |
| **permission_handler** | Runtime permission requests (location, notifications) |
| **flutter_map** | Map rendering — OpenStreetMap tiles, no Google Maps |
| **latlong2** | LatLng coordinate model for flutter_map |
| **flutter_dotenv** | Environment variable loading from `.env` files |
| **uuid** | RFC 4122 UUID generation for session and point IDs |
| **intl** | Date and time formatting |
| **path_provider** | Platform-specific file system paths |
| **build_runner** | Code generation runner |
| **hive_generator** | Generates Hive type adapters from annotations |

### Android (Kotlin)

| Technology | Purpose |
|---|---|
| **Kotlin 2.2.20** | Native Android code |
| **Android Gradle Plugin 8.11.1** | Android build tooling |
| **Gradle 8.14** | Build system |
| **FusedLocationProviderClient** | High-accuracy GPS via Google Play Services |
| **Foreground Service (START_STICKY)** | Background location capture, survives recents swipe |
| **BatteryManager** | Native battery level reads |
| **BroadcastReceiver (ACTION_BATTERY_CHANGED)** | Streaming battery level changes |
| **MethodChannel / EventChannel** | Flutter ↔ native communication |
| **compileSdk / targetSdk 36** | Latest Android SDK |
| **minSdk 29** | Android 10+ (required for `ACCESS_BACKGROUND_LOCATION`) |

### iOS (Swift)

| Technology | Purpose |
|---|---|
| **Swift** | Native iOS code |
| **CLLocationManager** | GPS location access |
| **Background Location Updates** | Continues tracking when app is backgrounded |
| **Significant Location Changes** | Fallback for low-power background tracking |
| **UIDevice.batteryLevel** | Native battery level reads |
| **batteryLevelDidChangeNotification** | Streaming battery level changes |
| **MethodChannel / EventChannel** | Flutter ↔ native communication |

---

## Architecture

The project follows **Clean Architecture** with a **Feature-First** folder structure and strict layer separation.

```
lib/
├── config/                         # App-wide configuration
│   ├── constants/
│   │   ├── app_constants.dart      # Channel names, notification IDs, intervals
│   │   ├── hive_constants.dart     # Hive box names and adapter type IDs
│   │   ├── permission_constants.dart
│   │   ├── route_constants.dart    # Named route strings
│   │   └── storage_constants.dart
│   ├── env/
│   │   └── app_env.dart            # Loads and exposes .env values
│   ├── routes/
│   │   └── app_router.dart         # Centralized named route generator
│   └── themes/
│       ├── app_colors.dart         # Full color palette (no fluorescent colors)
│       ├── app_radius.dart         # Border radius scale
│       ├── app_spacing.dart        # 8-point spacing grid
│       ├── app_text_styles.dart    # All text styles
│       └── app_theme.dart          # MaterialApp ThemeData assembly
│
├── core/                           # Shared infrastructure
│   ├── error/
│   │   ├── exceptions.dart         # AppException subclasses
│   │   └── failures.dart           # Failure subclasses (domain layer)
│   └── utils/
│       ├── date_utils.dart         # DateTime / Duration formatters
│       └── logger.dart             # Structured logger (respects ENABLE_LOGGING)
│
├── features/                       # One folder per product feature
│   │
│   ├── battery/                    # Native battery monitoring
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── battery_data_source.dart    # MethodChannel + EventChannel
│   │   │   └── repositories/
│   │   │       └── battery_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── battery_repository.dart     # Abstract contract
│   │   │   └── usecases/
│   │   │       ├── get_battery_level_use_case.dart
│   │   │       └── watch_battery_use_case.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── battery_bloc.dart
│   │       │   ├── battery_event.dart           # LoadBattery, BatteryChanged
│   │       │   └── battery_state.dart           # Initial, Loading, Loaded, Error
│   │       └── widgets/
│   │           └── battery_widget.dart          # Battery card with icon + percentage
│   │
│   ├── tracking/                   # GPS session lifecycle
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── location_service.dart        # Geolocator wrapper + 60s timer
│   │   │   │   └── tracking_local_data_source.dart  # Hive reads/writes
│   │   │   └── repositories/
│   │   │       └── tracking_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── tracking_repository.dart
│   │   │   └── usecases/
│   │   │       ├── start_tracking_use_case.dart
│   │   │       ├── stop_tracking_use_case.dart
│   │   │       └── get_active_session_use_case.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── tracking_bloc.dart
│   │       │   ├── tracking_event.dart          # InitTracking, StartTracking, StopTracking, TrackingUpdated
│   │       │   └── tracking_state.dart          # Initial, Loading, Running, Stopped, Error
│   │       ├── screens/
│   │       │   └── home_screen.dart             # Main screen
│   │       └── widgets/
│   │           └── tracking_control_widget.dart # Start/Stop buttons + live session card
│   │
│   ├── session/                    # Session history and detail
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── session_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── repositories/
│   │   │   │   └── session_repository.dart
│   │   │   └── usecases/
│   │   │       └── session_use_cases.dart       # GetAll, GetPoints, Delete
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── session_bloc.dart            # LoadSessions, DeleteSession, OpenSession
│   │       ├── screens/
│   │       │   ├── session_list_screen.dart
│   │       │   └── session_detail_screen.dart
│   │       └── widgets/
│   │           └── session_tile.dart            # Session card with delete confirmation
│   │
│   ├── permissions/                # Location permission flow
│   │   ├── domain/
│   │   │   └── repositories/
│   │   │       └── permission_repository.dart   # Interface + impl + use cases
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── permission_bloc.dart         # CheckPermissions, RequestPermissions
│   │       └── screens/
│   │           └── permission_denied_screen.dart
│   │
│   └── map/                        # Route visualization
│       └── presentation/
│           └── screens/
│               └── map_screen.dart              # flutter_map + OSM + polyline + markers
│
├── shared/                         # Cross-feature models and types
│   ├── enums/
│   │   └── tracking_status.dart
│   └── models/
│       ├── tracking_session.dart   # Hive model — session metadata
│       ├── tracking_session.g.dart # Generated Hive adapter
│       ├── location_point.dart     # Hive model — single GPS coordinate
│       └── location_point.g.dart  # Generated Hive adapter
│
├── injection/
│   └── injection.dart              # get_it registrations (data sources → repos → use cases → blocs)
│
└── main.dart                       # Hive init, DI setup, MultiBlocProvider, MaterialApp
```

### Android Native

```
android/
├── app/
│   └── src/main/
│       ├── kotlin/com/gps/tracker/
│       │   ├── MainActivity.kt                  # Registers channel handlers
│       │   ├── BatteryChannelHandler.kt         # MethodChannel — one-shot battery read
│       │   ├── BatteryEventHandler.kt           # EventChannel — streaming battery changes
│       │   ├── TrackingForegroundService.kt     # START_STICKY foreground service + FusedLocation
│       │   └── LocationReceiver.kt              # BroadcastReceiver for location events
│       ├── res/
│       │   ├── mipmap-mdpi/        ic_launcher.png (48×48)
│       │   ├── mipmap-hdpi/        ic_launcher.png (72×72)
│       │   ├── mipmap-xhdpi/       ic_launcher.png (96×96)
│       │   ├── mipmap-xxhdpi/      ic_launcher.png (144×144)
│       │   ├── mipmap-xxxhdpi/     ic_launcher.png (192×192)
│       │   ├── mipmap-anydpi-v26/  ic_launcher.xml (adaptive icon)
│       │   └── values/             styles.xml, colors.xml
│       └── AndroidManifest.xml
├── build.gradle                    # AGP 8.11.1, Kotlin 2.2.20
├── settings.gradle                 # Plugin versions
├── gradle.properties               # AndroidX, JVM args
└── gradle/wrapper/
    └── gradle-wrapper.properties   # Gradle 8.14
```

### iOS Native

```
ios/Runner/
├── AppDelegate.swift               # Registers channel handlers + location manager
├── BatteryChannelHandler.swift     # MethodChannel — UIDevice.batteryLevel
├── BatteryEventHandler.swift       # EventChannel — batteryLevelDidChangeNotification
├── LocationTrackingManager.swift   # CLLocationManager — background location updates
└── Info.plist                      # Location usage descriptions + background modes
```

---

## State Management — BLoC

| BLoC | Events | States |
|---|---|---|
| `BatteryBloc` | `LoadBattery`, `BatteryChanged` | `BatteryInitial`, `BatteryLoading`, `BatteryLoaded`, `BatteryError` |
| `TrackingBloc` | `InitTracking`, `StartTracking`, `StopTracking`, `TrackingUpdated` | `TrackingInitial`, `TrackingLoading`, `TrackingRunning`, `TrackingStopped`, `TrackingError` |
| `SessionBloc` | `LoadSessions`, `DeleteSession`, `OpenSession` | `SessionLoading`, `SessionLoaded`, `SessionDetailLoaded`, `SessionError` |
| `PermissionBloc` | `CheckPermissions`, `RequestPermissions` | `PermissionUnknown`, `PermissionGranted`, `PermissionDenied` |

---

## Database — Hive

| Box | Model | Key Fields |
|---|---|---|
| `tracking_sessions` | `TrackingSession` | `id`, `startTime`, `endTime`, `isActive`, `totalLocations` |
| `location_points` | `LocationPoint` | `id`, `sessionId`, `latitude`, `longitude`, `accuracy`, `timestamp` |

---

## Environment Configuration

Three `.env` files are bundled as Flutter assets:

| File | Usage |
|---|---|
| `.env.dev` | Local development — logging enabled |
| `.env.staging` | Staging builds |
| `.env.prod` | Production — logging disabled |

Switch environments in `main.dart`:

```dart
await AppEnv.load(env: 'dev'); // 'dev' | 'staging' | 'prod'
```

Available keys:

```
APP_NAME=GPS Tracker
LOCATION_INTERVAL=60          # Seconds between GPS captures
ENABLE_LOGGING=true
MAP_TILE_URL=https://tile.openstreetmap.org/{z}/{x}/{y}.png
```

---

## Color Palette

| Token | Hex | Usage |
|---|---|---|
| `primary` | `#7D9D9C` | Buttons, icons, accents |
| `secondary` | `#A6C1B9` | Supporting UI elements |
| `background` | `#F4F6F8` | App scaffold background |
| `surface` | `#FFFFFF` | Cards and sheets |
| `accent` | `#D8C3A5` | Warm highlights |
| `error` | `#D88C8C` | Errors, delete actions |
| `trackingActive` | `#5C9E8A` | Live session indicators |

---

## Required Permissions

### Android (`AndroidManifest.xml`)

| Permission | Reason |
|---|---|
| `ACCESS_FINE_LOCATION` | Precise GPS coordinates |
| `ACCESS_BACKGROUND_LOCATION` | Continue tracking when app is not in foreground |
| `FOREGROUND_SERVICE` | Run the tracking foreground service |
| `FOREGROUND_SERVICE_LOCATION` | Foreground service type declaration (API 29+) |
| `POST_NOTIFICATIONS` | Show the persistent tracking notification (API 33+) |
| `INTERNET` | Fetch OpenStreetMap tiles |

### iOS (`Info.plist`)

| Key | Reason |
|---|---|
| `NSLocationWhenInUseUsageDescription` | Foreground location |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | Background location |
| `UIBackgroundModes → location` | Enables background location updates |

---

## Getting Started

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Android Studio / Xcode
- A physical device (GPS and battery APIs do not work reliably on emulators)

### Setup

```bash
# 1. Install Flutter dependencies
flutter pub get

# 2. The Hive .g.dart adapter files are pre-generated.
#    If you modify TrackingSession or LocationPoint, regenerate with:
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run on a connected device
flutter run
```

### iOS — Additional Step

Open `ios/Runner.xcworkspace` in Xcode, go to **Target → Signing & Capabilities**, add **Background Modes**, and tick **Location updates**.

---

## Build Versions

| Tool | Version |
|---|---|
| Flutter | ≥ 3.0.0 |
| Dart | ≥ 3.0.0 |
| Android Gradle Plugin | 8.11.1 |
| Gradle | 8.14 |
| Kotlin | 2.2.20 |
| compileSdk / targetSdk | 36 |
| minSdk | 29 (Android 10+) |
