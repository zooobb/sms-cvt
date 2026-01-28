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
Order: Dart core → Flutter SDK → Third-party → Project-relative:
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sms_message.dart';
```

### Naming Conventions
Classes: PascalCase (`SmsService`, `SavedSmsMessage`), vars/fns: camelCase (`loadConfig`, `isEnabled`), private: `_config`, files: snake_case.dart

### Types & Null Safety
Use `required`, `late`, null-aware operators `??`, `?.`, `??=`, `final` for immutable fields. Avoid `dynamic` when possible.

### Const Constructors
Use const for widgets, colors, padding, border radius: `const SizedBox(height: 16)`, `const Color(0xFF6200EE)`

### Models
Include `toJson()`, `fromJson`, `copyWith()`, computed getters, `toString()`:
```dart
class FilterConfig {
  FilterConfig({required this.senders, this.isEnabled = false});
  FilterConfig copyWith({List<String>? senders, bool? isEnabled});
  factory FilterConfig.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
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
    try {
      _savedMessages = await _storageService.loadMessages();
      notifyListeners();
    } catch (e) {
      print('Error loading data: $e');
    }
  }
}
```
Use `Consumer<T>` or `context.watch<T>` in widgets.

### Async/Await
Always use async/await, try-catch for errors, init with `WidgetsFlutterBinding.ensureInitialized()`:
```dart
Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    _config = await _storageService.loadConfig();
  } catch (e) {
    print('Error initializing: $e');
  }
}
```

### Widget Organization
Split into `_buildX` methods, use `Consumer<T>` or `context.watch<T>` for provider state:
```dart
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('SMS Filter')),
    body: Consumer<AppState>(
      builder: (context, appState, child) => Column(
        children: [_buildStatusCard(context, appState)],
      ),
    ),
  );
}

Widget _buildStatusCard(BuildContext context, AppState appState) {
  return Card(
    child: ListTile(
      title: Text('Messages: ${appState.savedMessages.length}'),
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
static const EventChannel _eventChannel = EventChannel('com.smsfilter.sms_cvt/sms_events');
await _channel.invokeMethod('startListening');
```

### Error Handling
Try-catch async ops, log with print() (avoid_print disabled in analysis_options.yaml), return defaults on error:
```dart
Future<List<SavedSmsMessage>> loadMessages() async {
  try {
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => SavedSmsMessage.fromJson(e as Map<String, dynamic>)).toList();
  } catch (e) {
    print('Error loading messages: $e');
    return [];
  }
}
```

### Comments
- Use Chinese for business logic comments (matching codebase)
- Brief and descriptive, no excessive doc comments
- Add TODO comments for pending tasks: `// TODO(user): Add validation`

### File Structure
```
lib/
├── main.dart                  # App entry, AppState provider
├── models/                    # Data models (sms_message.dart, category_mapping.dart, filter_config.dart, sender_keyword_rule.dart)
├── services/                  # Business logic (sms_service.dart, storage_service.dart, notification_service.dart, permission_service.dart, category_service.dart, amount_extractor.dart)
└── screens/                   # UI screens (home_screen.dart, saved_messages_screen.dart, rules_screen.dart, category_manage_screen.dart)
```

### UI/Theme
Use `Theme.of(context).colorScheme`, Material 3 components (FilledButton, Card, ListTile), consistent padding (16), borderRadius (12/16), AppBar centerTitle: true. Avoid deprecated APIs.
