# AVC Flutter Mobile Application

## Overview

This is the Flutter mobile application for the AVC (Artificial Vocal Cord) system. The app provides comprehensive device management, real-time health monitoring, AI-assisted controls, and offline support for AVC devices.

## Features

- **User Authentication**: Secure login with session management
- **Device Discovery**: WiFi-based device discovery and pairing
- **Health Monitoring**: Real-time metrics (signal, battery, latency, accuracy)
- **Device Configuration**: AI model selection, sensor calibration, firmware updates
- **AI Assistant**: Intelligent device management recommendations
- **Alerts & Notifications**: Push notifications and in-app alerts
- **Offline Support**: Full functionality without network connectivity
- **Data Sync**: Automatic synchronization when online

## Architecture

The app follows Clean Architecture with Riverpod for state management:

```
lib/
├── main.dart                          # App entry point
├── config/                            # App configuration
├── presentation/                      # UI layer (screens, widgets, navigation)
├── domain/                            # Business logic (entities, repositories, usecases)
├── data/                              # Data layer (datasources, models, repositories)
├── services/                          # Business services
├── providers/                         # Riverpod providers
└── utils/                             # Utilities and helpers
```

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Android Studio / Xcode (for platform-specific builds)
- Firebase account (for push notifications and analytics)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Generate code:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Platform Setup

#### iOS
- Minimum deployment target: iOS 14.0
- Configure Xcode project with proper signing certificates
- Add required permissions in Info.plist

#### Android
- Minimum SDK: API 26 (Android 8.0)
- Target SDK: API 34 (Android 14)
- Configure signing keys in `android/app/build.gradle`

## Development

### Code Generation

The project uses several code generation tools:

- **Drift**: Database code generation
- **Freezed**: Immutable data classes
- **Riverpod Generator**: Provider code generation

Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

For watch mode:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Testing

Run tests:
```bash
# Unit tests
flutter test

# Widget tests
flutter test --platform chrome

# Integration tests
flutter test integration_test/
```

### Linting

The project uses `flutter_lints` for code analysis:
```bash
flutter analyze
```

## Dependencies

### Core Dependencies
- **flutter_riverpod**: State management
- **go_router**: Navigation
- **dio**: HTTP client
- **drift**: SQLite database
- **firebase_messaging**: Push notifications

### Development Dependencies
- **build_runner**: Code generation
- **flutter_lints**: Code analysis
- **mockito**: Testing

## Project Structure

### Key Directories

- `lib/presentation/screens/`: All app screens
- `lib/presentation/widgets/`: Reusable UI components
- `lib/domain/entities/`: Business entities
- `lib/domain/repositories/`: Repository interfaces
- `lib/data/datasources/`: Data sources (local, remote, device)
- `lib/data/repositories/`: Repository implementations
- `lib/services/`: Business logic services
- `lib/providers/`: Riverpod providers

### Configuration Files

- `pubspec.yaml`: Dependencies and project metadata
- `analysis_options.yaml`: Linting and analysis rules
- `ios/`: iOS-specific configuration
- `android/`: Android-specific configuration

## Building for Release

### iOS
```bash
flutter build ios --release
```

### Android
```bash
flutter build apk --release
# or for App Bundle
flutter build appbundle --release
```

## Contributing

1. Follow the existing code style and architecture
2. Write tests for new features
3. Update documentation as needed
4. Run `flutter analyze` before committing

## License

[Add license information here]