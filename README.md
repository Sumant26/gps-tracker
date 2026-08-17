# 📍 GPS Tracker

A cross-platform Flutter application for recording GPS tracking sessions with real-time battery monitoring, background location capture, route visualization, and full session history management.

---

## ✨ Features

- 🔋 **Live battery monitoring** — reads and streams battery percentage from native code via `MethodChannel` and `EventChannel`
- 📡 **Background GPS tracking** — continues recording when minimized, screen locked, or removed from recents (Android foreground service with `START_STICKY`; iOS background location updates)
- ⏱️ **60-second location capture** — latitude, longitude, accuracy, and timestamp saved per point
- 📋 **Session history** — browse all past sessions with start time, end time, duration, and point count
- 🗺️ **Interactive map** — route rendered as a polyline on OpenStreetMap tiles with start/end markers
- 🗑️ **Session deletion** — permanently remove a session and all its location data
- ⚙️ **Environment configuration** — dev / staging / prod `.env` files control intervals, logging, and map tile URL

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| State Management | flutter_bloc 8 |
| Dependency Injection | get_it + injectable |
| Local Storage | Hive + hive_flutter |
| Location | geolocator + permission_handler |
| Map | flutter_map (OpenStreetMap) |
| Environment | flutter_dotenv |
| Android Native | Kotlin — Foreground Service, FusedLocationProvider, BatteryManager |
| iOS Native | Swift — CLLocationManager, UIDevice, Background Location Updates |

---

## 📁 Project Structure

```
lib/
├── config/                         # App-wide configuration
│   ├── constants/                  # Channel names, routes, Hive box names
│   ├── env/                        # .env loader (AppEnv)
│   ├── routes/                     # Named route generator
│   └── themes/                     # Colors, spacing, text styles, ThemeData
│
├── core/                           # Shared infrastructure
│   ├── error/                      # Exceptions and Failures
│   └── utils/                      # Date formatters, structured logger
│
├── features/                       # One folder per product feature
│   ├── battery/                    # Native battery monitoring (BLoC + MethodChannel/EventChannel)
│   ├── tracking/                   # GPS session lifecycle (BLoC + Foreground Service)
│   ├── session/                    # Session history and detail (BLoC + Hive)
│   ├── permissions/                # Location permission flow (BLoC)
│   └── map/                        # Route visualization (flutter_map + OSM)
│
├── shared/                         # Cross-feature models
│   └── models/                     # TrackingSession, LocationPoint (Hive models)
│
├── injection/
│   └── injection.dart              # get_it DI registrations
│
└── main.dart                       # Hive init, DI setup, MultiBlocProvider, MaterialApp
```

---

## 🏗️ Architecture

The project follows **Clean Architecture** with a **Feature-First** folder structure and strict layer separation:

- **Data layer** — data sources, repositories implementations
- **Domain layer** — abstract repository contracts, use cases
- **Presentation layer** — BLoC (events, states), screens, widgets

### State Management — BLoC

| BLoC | Events | States |
|---|---|---|
| `BatteryBloc` | `LoadBattery`, `BatteryChanged` | `BatteryInitial`, `BatteryLoading`, `BatteryLoaded`, `BatteryError` |
| `TrackingBloc` | `InitTracking`, `StartTracking`, `StopTracking`, `TrackingUpdated` | `TrackingInitial`, `TrackingLoading`, `TrackingRunning`, `TrackingStopped`, `TrackingError` |
| `SessionBloc` | `LoadSessions`, `DeleteSession`, `OpenSession` | `SessionLoading`, `SessionLoaded`, `SessionDetailLoaded`, `SessionError` |
| `PermissionBloc` | `CheckPermissions`, `RequestPermissions` | `PermissionUnknown`, `PermissionGranted`, `PermissionDenied` |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK ≥ 3.0.0](https://docs.flutter.dev/get-started/install)
- Android Studio / Xcode
- A physical device (GPS and battery APIs do not work reliably on emulators)

### Run Locally

```bash
# Clone the repository
git clone https://github.com/Sumant26/gps-tracker.git
cd gps-tracker

# Install Flutter dependencies
flutter pub get

# Run on a connected device
flutter run
```

> **Note:** The Hive `.g.dart` adapter files are pre-generated. If you modify `TrackingSession` or `LocationPoint`, regenerate with:
> ```bash
> flutter pub run build_runner build --delete-conflicting-outputs
> ```

### iOS — Additional Step

Open `ios/Runner.xcworkspace` in Xcode, go to **Target → Signing & Capabilities**, add **Background Modes**, and tick **Location updates**.

---

## ⚙️ Environment Configuration

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

## 🔐 Required Permissions

### Android

| Permission | Reason |
|---|---|
| `ACCESS_FINE_LOCATION` | Precise GPS coordinates |
| `ACCESS_BACKGROUND_LOCATION` | Continue tracking when app is not in foreground |
| `FOREGROUND_SERVICE` | Run the tracking foreground service |
| `POST_NOTIFICATIONS` | Show the persistent tracking notification (API 33+) |
| `INTERNET` | Fetch OpenStreetMap tiles |

### iOS

| Key | Reason |
|---|---|
| `NSLocationWhenInUseUsageDescription` | Foreground location |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | Background location |
| `UIBackgroundModes → location` | Enables background location updates |

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
