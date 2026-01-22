# Agent Guidelines for sms_cvt

## Build, Lint, and Test Commands

### Setup & Build
```bash
flutter pub get && flutter clean
flutter run                        # Debug mode
flutter build apk                  # Android APK
flutter build ios                  # iOS app
```

### Analysis & Formatting
```bash
flutter analyze                    # Static analysis (flutter_lints)
dart fix --apply                   # Auto fixes
dart format .                      # Format all files
```

### Testing
```bash
flutter test                       # Run all tests
flutter test test/widget_test.dart # Run specific test file
flutter test --coverage            # With coverage
```

## Code Style Guidelines

### Tech Stack
- Dart SDK: ^3.9.2, Flutter Material 3, Provider (ChangeNotifier pattern)

### Import Organization
```dart
// Order: Dart core → Flutter SDK → Third-party → Project-relative
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sms_message.dart';
```

### Naming Conventions
- Classes: PascalCase (e.g., `SmsService`)
- Variables/Functions: camelCase (e.g., `loadConfig`)
- Private: underscore prefix (e.g., `_config`)
- Files: snake_case.dart

### Types & Null Safety
```dart
class SavedSmsMessage {
  final String id;
  SavedSmsMessage({required this.id});
}
```
Use `required`, `late`, null-aware operators `??`, `?.`, `??=`

### Const Constructors
Use const for widgets, colors, padding, border radius:
```dart
const SizedBox(height: 16),
const Icon(Icons.add),
```

### Models
Include `toJson()`, `fromJson`, `copyWith()`, computed getters, `toString()`:
```dart
class FilterConfig {
  FilterConfig({required this.senders, this.isEnabled = false});
  FilterConfig copyWith({List<String>? senders});
  factory FilterConfig.fromJson(Map<String, dynamic> json);
}
```

### State Management (Provider)
Private fields + public getters, `notifyListeners()` after changes:
```dart
class AppState extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<SavedSmsMessage> _savedMessages = [];
  List<SavedSmsMessage> get savedMessages => _savedMessages;

  Future<void> loadData() async {
    _savedMessages = await _storageService.loadMessages();
    notifyListeners();
  }
}
```
Use `Consumer<T>` or `context.watch<T>` in widgets.

### Async/Await
Always use async/await, try-catch for errors, init with `WidgetsFlutterBinding.ensureInitialized()`:
```dart
Future<void> _init() async {
  try {
    _config = await _storageService.loadConfig();
  } catch (e) {
    print('Error initializing: $e');
  }
}
```

### Widget Organization
Split into `_buildX` methods, use `Consumer<T>` for provider state:
```dart
Widget build(BuildContext context) {
  return Scaffold(
    body: Consumer<AppState>(
      builder: (context, appState, child) => Column(
        children: [_buildStatusCard(context, appState)],
      ),
    ),
  );
}
```

### Services
Singleton with factory for stateless, private static const for channel names:
```dart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
}
```

### Platform Channels
Prefix with reverse domain, use MethodChannel for calls, EventChannel for streams:
```dart
static const MethodChannel _channel = MethodChannel('com.smsfilter.sms_cvt/sms');
await _channel.invokeMethod('startListening');
```

### Error Handling
Try-catch async ops, log with print(), return defaults on error:
```dart
Future<List<SavedSmsMessage>> loadMessages() async {
  try {
    return jsonDecode(await file.readAsString()) as List<SavedSmsMessage>;
  } catch (e) {
    return [];
  }
}
```

### Comments
- Use Chinese for business logic (matching codebase)
- Brief and descriptive, no excessive doc comments

### File Structure
```
lib/
├── main.dart                  # App entry, AppState
├── models/                    # Data models
├── services/                  # Business logic
└── screens/                   # UI screens
```

### UI/Theme
Use `Theme.of(context).colorScheme`, Material 3 components (FilledButton, Card), consistent padding (16), borderRadius (12/16), AppBar centerTitle: true
