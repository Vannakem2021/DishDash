# DishDash Tech Context

## Core Technologies

1. **Flutter (SDK: ^3.7.2)**

   - Cross-platform UI framework for building native applications
   - Widget-based architecture for UI components
   - Hot-reload for rapid development

2. **Dart (Programming Language)**

   - Strongly-typed language optimized for UI
   - Supports asynchronous programming
   - JIT/AOT compilation for development and production

3. **SQLite (sqflite: ^2.3.0)**
   - Local relational database
   - ACID compliant
   - Efficient data storage and retrieval
   - Used for offline data persistence

## Frontend

1. **UI Components**

   - Material Design implementation
   - Custom theme using `AppTheme` for consistent styling
   - Responsive layouts for different screen sizes

2. **Asset Management**

   - Local images in `assets/images/`
   - Custom fonts: 'IBMPlexSans' and 'SyneMono'
   - SVG support using `flutter_svg` (^2.0.10+1)

3. **Image Handling**
   - `cached_network_image` (^3.3.1) for efficient image loading
   - Fallback images for loading/error states
   - Optimized image caching

## State Management

1. **Provider (^6.1.2)**
   - InheritedWidget-based state management
   - Used for app-wide state (e.g., cart management)
   - Enables efficient UI updates

## Data Management

1. **Local Storage**

   - SQLite for structured data storage
   - `DatabaseHelper` for database operations
   - Repository pattern for data access

2. **File System**

   - `path` (^1.8.3) for file path management
   - `path_provider` (^2.1.1) for platform-specific directories

3. **Session Management**
   - `shared_preferences` (^2.2.2) for key-value storage
   - Used for authentication state and user settings

## Utilities

1. **Date & Time Formatting**

   - `intl` (^0.19.0) for localization and formatting
   - Used for currency and date formatting

2. **Font Handling**
   - `google_fonts` (^6.1.0) for additional font options
   - Custom font families defined in `pubspec.yaml`

## Development Setup

1. **Environment Requirements**

   - Flutter SDK ^3.7.2
   - Android Studio or Visual Studio Code
   - Android SDK for Android development
   - Xcode for iOS development

2. **Build Configuration**

   - Android: minSdkVersion 21, targetSdkVersion 34
   - iOS: iOS 12.0 minimum
   - NDK version configuration for Android build

3. **Dependencies Management**
   - Managed through `pubspec.yaml`
   - Package versioning for stability

## Technical Constraints

1. **Mobile Only**

   - Focused on mobile platforms (Android/iOS)
   - Not optimized for web or desktop

2. **Local Database Limitations**

   - Data stored only on device
   - No cloud synchronization
   - Limited storage based on device capacity

3. **Performance Considerations**
   - Image caching necessary for smooth scrolling
   - Database queries optimized for speed
   - Asset size management for app bundle size control
