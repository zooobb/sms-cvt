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
- Dart SDK: ^3.9.2, Flutter Material 3
- State management: Provider (ChangeNotifier pattern)

### Import Organization
```dart
// 1. Dart core → 2. Flutter SDK → 3. Third-party → 4. Project-relative
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sms_message.dart';
import 'storage_service.dart';
```

### Naming Conventions
- Classes: PascalCase (e.g., `SmsService`, `AppState`)
- Variables/Functions: camelCase (e.g., `loadConfig`)
- Private: underscore prefix (e.g., `_config`, `_isLoading`)
- Files: snake_case.dart (e.g., `sms_service.dart`)

### Types & Null Safety
```dart
class SavedSmsMessage {
  final String id;
  final String sender;
  SavedSmsMessage({required this.id, required this.sender});
}
```
Use `required` for non-nullable params, `late` for deferred init, null-aware operators `??`, `?.`, `??=`

### Const Constructors
```dart
const SizedBox(height: 16),
const Icon(Icons.add),
const Padding(padding: EdgeInsets.all(16)),
```
Use const for widgets, colors, padding, border radius

### Models
```dart
class FilterConfig {
  final List<String> senders;
  FilterConfig({required this.senders, this.isEnabled = false});
  FilterConfig copyWith({List<String>? senders, bool? isEnabled});
  Map<String, dynamic> toJson();
  factory FilterConfig.fromJson(Map<String, dynamic> json);
  factory FilterConfig.empty() => FilterConfig(senders: [], isEnabled: false);
}
```
Include `toJson()`, `fromJson`, `copyWith()`, computed getters, `toString()`

### State Management (Provider)
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
Private fields + public getters, `notifyListeners()` after changes, use `Consumer<T>` or `context.watch<T>`

### Async/Await
```dart
Future<void> _init() async {
  try {
    _config = await _storageService.loadConfig();
    _hasPermissions = await _permissionService.checkSmsPermissions();
  } catch (e) {
    print('Error initializing: $e');
  }
}
```
Always use async/await, try-catch for errors, init with `WidgetsFlutterBinding.ensureInitialized()`

### Widget Organization
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Consumer<AppState>(
      builder: (context, appState, child) => Column(
        children: [_buildStatusCard(context, appState), _buildActions(context)],
      ),
    ),
  );
}
```
Split into `_buildX` methods, use `Consumer<T>` for provider state, const child widgets

### Services
```dart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  Future<void> initialize() async { }
}
```
Singleton with factory for stateless, private static const for channel names

### Platform Channels
```dart
static const MethodChannel _channel = MethodChannel('com.smsfilter.sms_cvt/sms');
await _channel.invokeMethod('startListening');
```
Prefix with reverse domain, use MethodChannel for calls, EventChannel for streams

### Error Handling
```dart
Future<List<SavedSmsMessage>> loadMessages() async {
  try {
    final file = await _getMessagesFile();
    return jsonDecode(await file.readAsString()) as List<SavedSmsMessage>;
  } catch (e) {
    return [];
  }
}
```
Try-catch async ops, log with print() (avoid_print disabled), return defaults on error

### Comments
- Use Chinese for business logic (matching codebase)
- Brief and descriptive, no excessive doc comments
```dart
// 直接插入到正确的位置，避免重复排序
int insertIndex = 0;
```

### File Structure
```
lib/
├── main.dart                  # App entry, AppState
├── models/                    # Data models
│   ├── sms_message.dart
│   └── filter_config.dart
├── services/                  # Business logic
│   ├── sms_service.dart
│   ├── storage_service.dart
│   └── notification_service.dart
└── screens/                   # UI screens
    ├── home_screen.dart
    └── senders_screen.dart
```

### UI/Theme
```dart
final colorScheme = Theme.of(context).colorScheme;
colorScheme.primaryContainer,
```
Use `Theme.of(context).colorScheme`, Material 3 components (FilledButton, Card), consistent padding (16), borderRadius (12/16), AppBar centerTitle: true
