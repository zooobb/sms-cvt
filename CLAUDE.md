# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SMS Filter app - A Flutter application for filtering SMS messages based on sender/keyword rules, auto-categorizing transactions, and exporting data. Targets Android and iOS.

## Build Commands

```bash
# Setup & Build
flutter pub get && flutter clean
flutter run                        # Debug mode
flutter build apk                  # Android APK
flutter build ios                  # iOS app

# Analysis & Formatting
flutter analyze                    # Static analysis
dart fix --apply                   # Auto fixes
dart format .                      # Format all files

# Testing
flutter test                       # Run all tests
flutter test test/widget_test.dart # Run specific test file
```

## Architecture

**State Management**: Provider (ChangeNotifier pattern) - `AppState` in `main.dart` manages all app state.

**Directory Structure**:
```
lib/
├── main.dart              # App entry + AppState (ChangeNotifier)
├── models/                # Data models with JSON serialization
├── services/              # Business logic and platform interactions
└── screens/               # UI screens
```

**Data Flow**: `SmsService` listens for SMS via `EventChannel` → `FilterConfig.shouldSaveMessage()` matches rules → `StorageService` persists to JSON → `CategoryService` auto-categorizes.

**Platform Channels**:
- `MethodChannel`: `com.smsfilter.sms_cvt/sms`
- `EventChannel`: `com.smsfilter.sms_cvt/sms_events`

## Key Conventions

- **Imports**: Dart core → Flutter SDK → Third-party → Project-relative
- **Classes**: `PascalCase`, files: `snake_case.dart`, private members: `_prefix`
- **Models**: Include `toJson()`, `fromJson()`, `copyWith()`
- **Services**: Singleton pattern with factory constructor
- **UI**: Material 3 components, consistent padding (16px), borderRadius (12/16px)
- **Comments**: Use Chinese for business logic (matches existing codebase)
