# Easacc Task - Flutter Application

A modern Flutter application built with Clean Architecture principles, featuring authentication, device discovery, and web view capabilities. The app follows SOLID principles and implements a scalable, maintainable codebase structure.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Key Implementations](#key-implementations)
- [Setup Instructions](#setup-instructions)
- [Configuration](#configuration)
- [Platform Support](#platform-support)

## 🎯 Overview

Easacc Task is a Flutter application designed with Clean Architecture principles, providing:

- **Multi-provider Authentication**: Email/Password, Google Sign-In, and Facebook Login
- **Network Device Discovery**: WiFi and Bluetooth device scanning and connection
- **Web View Integration**: In-app web browsing with custom navigation
- **Modern UI/UX**: Smooth animations, iOS-style transitions, and responsive design
- **Cross-platform Support**: Android and iOS with platform-specific configurations

## 🏗️ Architecture

The application follows **Clean Architecture** principles, dividing the codebase into three main layers:

### Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                  Presentation Layer                      │
│  (UI, BLoC, Widgets, Pages, State Management)            │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│                    Domain Layer                          │
│  (Entities, Use Cases, Repository Interfaces)          │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│                     Data Layer                           │
│  (Models, Data Sources, Repository Implementations)     │
└─────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### 1. **Presentation Layer** (`lib/features/*/presentation/`)
- **BLoC Pattern**: State management using `flutter_bloc`
- **Pages**: Screen-level widgets
- **Widgets**: Reusable UI components
- **Events & States**: BLoC event/state definitions

#### 2. **Domain Layer** (`lib/features/*/domain/`)
- **Entities**: Business logic objects (pure Dart classes)
- **Use Cases**: Single-responsibility business logic operations
- **Repository Interfaces**: Abstract contracts for data operations

#### 3. **Data Layer** (`lib/features/*/data/`)
- **Models**: Data transfer objects with JSON serialization
- **Data Sources**: 
  - **Remote**: API calls, Firebase, external services
  - **Local**: SharedPreferences, local storage
- **Repository Implementations**: Concrete implementations of domain interfaces

### Core Principles Applied

- ✅ **Single Responsibility**: Each class/widget has one purpose
- ✅ **Dependency Inversion**: Depend on abstractions (interfaces), not concretions
- ✅ **Separation of Concerns**: Clear boundaries between layers
- ✅ **Testability**: Easy to mock and test each layer independently

## ✨ Features

### 1. Authentication System

#### Email/Password Authentication
- Sign up with email and password
- Sign in with existing credentials
- Form validation and error handling
- Firebase Authentication integration

#### Social Authentication
- **Google Sign-In**: OAuth 2.0 flow with Firebase
- **Facebook Login**: Facebook SDK integration with profile data fetching
- Automatic profile picture and email retrieval
- Cross-platform deep linking support

**Implementation Highlights:**
- Fetches user data (email, name, profile picture) from social providers
- Updates Firebase user profile with social data
- Handles empty emails for social logins (optional validation)
- Deep link configuration for Android and iOS

### 2. Network Device Discovery

#### WiFi Device Scanning
- Scans local network for devices with open ports
- Detects network printers (ports 9100, 515, 631)
- Finds web servers and IoT devices (ports 80, 443, 8080)
- Shows current WiFi network information

#### Bluetooth Device Scanning
- Scans for Bluetooth Low Energy (BLE) devices
- Discovers fitness trackers, smart watches, printers
- Device sorting by signal strength (RSSI)
- 15-second scan duration with real-time updates

**Implementation Details:**
- Uses `network_info_plus` for WiFi scanning
- Uses `flutter_blue_plus` for Bluetooth scanning
- Socket-based port scanning for WiFi devices
- Stream-based Bluetooth device discovery
- Device deduplication and signal strength sorting

### 3. Web View Integration

- In-app web browsing with custom navigation
- Bottom sheet presentation style
- Loading states and error handling
- Refresh and navigation controls

### 4. Settings Management

- Web URL configuration and persistence
- Device type selection (WiFi/Bluetooth)
- Device connection/disconnection
- Local storage using SharedPreferences

### 5. UI/UX Enhancements

#### Animations
- **flutter_animate**: Smooth page transitions and widget animations
- Login page: Fade and slide animations for form switching
- Settings page: Staggered animations for sections
- iOS-style navigation transitions

#### Custom Route Transitions
- **SlideFromRightRoute**: iOS-style push animation (settings page)
- **SlideToRightRoute**: Reverse slide animation (logout)
- **BottomSheetRoute**: Slide from bottom (web view)

#### Responsive Design
- **flutter_screenutil**: Screen size adaptation
- Design size: 375x812 (iPhone X)
- Responsive text and spacing
- RTL support ready (Arabic language)

## 🛠️ Tech Stack

### Core Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^8.1.6 | State management |
| `get_it` | ^7.7.0 | Dependency injection |
| `dartz` | ^0.10.1 | Functional programming (Either, Option) |
| `equatable` | ^2.0.5 | Value equality for states/events |

### Firebase & Authentication

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^4.2.1 | Firebase initialization |
| `firebase_auth` | ^6.1.2 | Authentication |
| `google_sign_in` | ^6.2.1 | Google Sign-In |
| `flutter_facebook_auth` | ^7.1.2 | Facebook Login |

### UI & Design

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_screenutil` | ^5.9.0 | Responsive design |
| `google_fonts` | ^6.2.1 | Custom typography |
| `flutter_animate` | ^4.5.0 | Animations |

### Network & Device Discovery

| Package | Version | Purpose |
|---------|---------|---------|
| `network_info_plus` | ^5.0.2 | WiFi network information |
| `flutter_blue_plus` | ^1.30.7 | Bluetooth Low Energy |
| `webview_flutter` | ^4.9.0 | In-app web browsing |

### Storage

| Package | Version | Purpose |
|---------|---------|---------|
| `shared_preferences` | ^2.2.3 | Local key-value storage |

## 📁 Project Structure

```
lib/
├── core/                          # Core functionality shared across features
│   ├── constants/                 # App constants and strings
│   │   ├── app_constants.dart
│   │   └── app_strings.dart
│   ├── di/                        # Dependency injection
│   │   └── injection_container.dart
│   ├── errors/                    # Error handling
│   │   └── failures.dart
│   ├── routes/                    # Navigation and routing
│   │   ├── app_routes.dart
│   │   └── route_transitions.dart
│   ├── services/                 # Core services
│   │   └── storage_service.dart
│   ├── theme/                     # App theming
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── utils/                     # Utility functions
│   │   ├── pretty_logger.dart
│   │   └── validators.dart
│   └── widgets/                   # Shared widgets
│       └── app_scaffold.dart
│
├── features/                      # Feature modules (Clean Architecture)
│   ├── authentication/            # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/       # Remote & local data sources
│   │   │   ├── models/            # Data models
│   │   │   └── repositories/     # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/          # Business entities
│   │   │   ├── repositories/      # Repository interfaces
│   │   │   └── usecases/         # Business logic use cases
│   │   └── presentation/
│   │       ├── bloc/              # BLoC state management
│   │       ├── pages/             # Screen widgets
│   │       └── widgets/          # Feature-specific widgets
│   │
│   ├── settings/                  # Settings feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   │
│   └── webview/                   # Web view feature
│       └── presentation/
│           ├── bloc/
│           └── pages/
│
├── firebase_options.dart          # Firebase configuration
└── main.dart                      # App entry point
```

## 🔑 Key Implementations

### 1. Dependency Injection Setup

**Location**: `lib/core/di/injection_container.dart`

Uses `get_it` for service locator pattern:

```dart
// Register services as singletons or factories
getIt.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(
    remoteDataSource: getIt(),
    localDataSource: getIt(),
  ),
);

// BLoCs are registered as factories (new instance each time)
getIt.registerFactory<AuthBloc>(() => AuthBloc());
```

**Benefits:**
- Loose coupling between components
- Easy testing with mock dependencies
- Centralized dependency management

### 2. Authentication Flow

#### Email/Password Flow
1. User enters email/password
2. `SignInWithEmailUseCase` validates input
3. `AuthRemoteDataSource` calls Firebase Auth
4. `AuthRepository` caches user data locally
5. `AuthBloc` emits authenticated state
6. UI navigates to profile page

#### Social Login Flow (Facebook Example)
1. User taps "Continue with Facebook"
2. `SignInWithFacebookUseCase` triggers
3. `AuthRemoteDataSource`:
   - Calls `FacebookAuth.instance.login()`
   - Gets access token
   - Creates Firebase credential
   - Signs in to Firebase
   - Fetches user data from Facebook Graph API
   - Updates Firebase user profile
4. User data cached locally
5. BLoC emits authenticated state

**Key Implementation**: `lib/features/authentication/data/datasources/auth_remote_datasource.dart`

```dart
// Fetches email, name, and profile picture from Facebook
final userData = await _facebookAuth.getUserData();

// Updates Firebase profile with Facebook data
await firebaseUser.updateProfile(
  displayName: name,
  photoURL: photoUrl,
);
```

### 3. Device Discovery Implementation

#### WiFi Scanning
**Location**: `lib/features/settings/data/datasources/settings_remote_datasource.dart`

```dart
// Get network info
final wifiIP = await _networkInfo.getWifiIP();

// Extract network base (e.g., 192.168.1.x)
final baseIP = '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}';

// Scan common ports on network devices
for (int i = 1; i <= 20; i++) {
  final testIP = '$baseIP.$i';
  // Try connecting to printer ports (9100, 515, 631)
  // Try connecting to device ports (80, 443, 8080)
}
```

#### Bluetooth Scanning
```dart
// Start BLE scan
await FlutterBluePlus.startScan(timeout: Duration(seconds: 15));

// Listen to scan results stream
final subscription = FlutterBluePlus.scanResults.listen((results) {
  for (final result in results) {
    // Extract device info
    // Deduplicate and sort by RSSI
  }
});
```

**Features:**
- Real-time device discovery via streams
- Device deduplication
- Signal strength sorting (RSSI)
- 15-second scan duration
- Platform-specific permissions handling

### 4. BLoC State Management

**Example**: `lib/features/authentication/presentation/bloc/auth_bloc.dart`

```dart
// Event
class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
}

// State
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserEntity user;
}

// BLoC Handler
Stream<AuthState> _mapSignInWithEmailToState(
  SignInWithEmailEvent event,
) async* {
  yield AuthLoading();
  final result = await _signInWithEmailUseCase(
    SignInWithEmailParams(
      email: event.email,
      password: event.password,
    ),
  );
  
  yield* result.fold(
    (failure) async* {
      yield AuthError(failure.message);
    },
    (user) async* {
      yield AuthAuthenticated(user);
    },
  );
}
```

**Benefits:**
- Predictable state management
- Easy to test
- Clear separation of business logic and UI

### 5. Custom Route Transitions

**Location**: `lib/core/routes/route_transitions.dart`

Implements iOS-style animations:

- **SlideFromRightRoute**: Settings page entry
- **SlideToRightRoute**: Logout animation
- **BottomSheetRoute**: Web view presentation

```dart
class SlideFromRightRoute extends PageRouteBuilder {
  // Custom transition with easeOutCubic curve
  // 300ms duration for smooth iOS-like feel
}
```

### 6. Error Handling

**Location**: `lib/core/errors/failures.dart`

Uses `dartz` package for functional error handling:

```dart
// Use Cases return Either<Failure, Success>
Future<Either<Failure, UserEntity>> call(SignInParams params) async {
  try {
    final user = await repository.signIn(...);
    return Right(user);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
```

### 7. Local Storage

**Location**: `lib/core/services/storage_service.dart`

Wraps `SharedPreferences` with type-safe methods:

```dart
class StorageService {
  Future<void> saveString(String key, String value);
  Future<String?> getString(String key);
  Future<void> remove(String key);
}
```

Used for:
- Caching user credentials
- Storing settings (web URL, selected device)
- Offline data persistence

## 🚀 Setup Instructions

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.10.0 or higher)
- Android Studio / Xcode (for platform-specific setup)
- Firebase project configured
- Facebook Developer account (for Facebook login)
- Google Cloud Console project (for Google Sign-In)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd easacc_task
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Configure Firebase in `lib/firebase_options.dart`

4. **Android Configuration**
   - Update `android/app/src/main/AndroidManifest.xml`:
     - Facebook App ID and Client Token
     - Deep link schemes
     - Permissions (Bluetooth, Location, Internet)
   - Update `android/app/build.gradle`:
     - Min SDK version: 21
     - Target SDK version: 34

5. **iOS Configuration**
   - Update `ios/Runner/Info.plist`:
     - Facebook App ID and Client Token
     - URL Schemes
     - Privacy descriptions (Bluetooth, Location, Local Network)
   - Update `ios/Runner/AppDelegate.swift`:
     - Facebook SDK initialization
     - Google Sign-In configuration
     - URL callback handling

6. **Run the app**
   ```bash
   flutter run
   ```

## ⚙️ Configuration

### Facebook Login Setup

1. **Facebook Developer Console**
   - Create app and get App ID and Client Token
   - Add Android package name and iOS Bundle ID
   - Configure OAuth redirect URIs:
     - `fb{APP_ID}://authorize`
     - `https://{FIREBASE_PROJECT}.firebaseapp.com/__/auth/handler`

2. **Android Configuration**
   ```xml
   <!-- strings.xml -->
   <string name="fb_login_protocol_scheme">fb{APP_ID}</string>
   
   <!-- AndroidManifest.xml -->
   <meta-data android:name="com.facebook.sdk.ApplicationId" 
              android:value="@string/fb_app_id"/>
   ```

3. **iOS Configuration**
   ```xml
   <!-- Info.plist -->
   <key>FacebookAppID</key>
   <string>{APP_ID}</string>
   <key>CFBundleURLSchemes</key>
   <array>
     <string>fb{APP_ID}</string>
   </array>
   ```

### Google Sign-In Setup

1. **Google Cloud Console**
   - Create OAuth 2.0 credentials
   - Add Android package name and SHA-1 fingerprint
   - Add iOS Bundle ID

2. **Android Configuration**
   - Add `google-services.json` to `android/app/`
   - SHA-1 fingerprint in Firebase Console

3. **iOS Configuration**
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Add REVERSED_CLIENT_ID to URL Schemes in Info.plist

## 📱 Platform Support

### Android
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Permissions**:
  - Internet
  - Bluetooth
  - Location (for Bluetooth scanning)
  - AD_ID (optional, can be removed)

### iOS
- **Min iOS**: 12.0
- **Target iOS**: 17.0+
- **Permissions**:
  - NSBluetoothAlwaysUsageDescription
  - NSLocationWhenInUseUsageDescription
  - NSLocalNetworkUsageDescription

## 📝 Code Quality

### Linting
- Uses `flutter_lints` package
- Follows Flutter style guide
- Custom analysis options in `analysis_options.yaml`

### Logging
- Custom `PrettyLogger` utility
- Structured logging with tags and data
- Debug, Info, Warning, Error, Success levels

### Validation
- Email validation using regex
- Password strength validation
- URL validation for web view

## 🔒 Security Considerations

1. **API Keys**: Never commit sensitive keys to version control
2. **Firebase Rules**: Configure proper security rules
3. **Deep Links**: Validate deep link URLs
4. **Permissions**: Request only necessary permissions
5. **Data Encryption**: Consider encrypting sensitive local data

## 🧪 Testing

### Unit Tests
- Test use cases with mock repositories
- Test BLoC state transitions
- Test utility functions

### Integration Tests
- Test authentication flows
- Test device discovery
- Test navigation flows

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)

## 👥 Contributing

This project follows Clean Architecture principles. When adding new features:

1. Create feature folder with domain/data/presentation layers
2. Define entities in domain layer
3. Create use cases for business logic
4. Implement repositories in data layer
5. Add BLoC for state management
6. Create UI widgets in presentation layer
7. Register dependencies in `injection_container.dart`

## 📄 License

[Your License Here]

---

**Built with ❤️ using Flutter and Clean Architecture**

