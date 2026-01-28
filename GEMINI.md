# GEMINI.md

## Project Overview

This is a Flutter project for an SMS filtering and forwarding application named "sms_cvt". The application allows users to define rules to filter incoming SMS messages based on the sender and keywords. Matching messages are saved within the app, categorized, and can be exported.

The app uses the following key technologies:

*   **Flutter:** For the cross-platform (iOS and Android) UI.
*   **Provider:** For state management.
*   **flutter_sms_inbox:** To read SMS messages from the device's inbox.
*   **shared_preferences:** For persisting filter configurations.
*   **flutter_local_notifications:** To notify the user when a message is filtered.
*   **Platform Channels:** To listen for incoming SMS messages in real-time.

The core functionality is centered around the `AppState` class, which manages the application's state, including filter rules, saved messages, and permissions. The `SmsService` handles the logic for listening to, filtering, and saving SMS messages, while the `StorageService` manages the persistence of data.

## Building and Running

To build and run this project, you will need to have the Flutter SDK installed.

1.  **Get dependencies:**
    ```bash
    flutter pub get
    ```

2.  **Run the app:**
    ```bash
    flutter run
    ```

## Development Conventions

*   **State Management:** The project uses the `provider` package for state management. The main application state is managed in the `AppState` class in `lib/main.dart`.
*   **Services:** Business logic is separated into service classes, such as `SmsService`, `StorageService`, `PermissionService`, and `NotificationService`. These services are located in the `lib/services/` directory.
*   **UI:** The UI is built with Material Design components and is organized into screens in the `lib/screens/` directory.
*   **Models:** Data models are defined in the `lib/models/` directory.
*   **Permissions:** The app uses the `permission_handler` package to request SMS permissions at runtime.
*   **Background Execution:** The app uses platform channels to listen for SMS messages in the background. The native code for this is likely located in the `android/` and `ios/` directories.
