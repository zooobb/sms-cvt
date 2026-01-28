import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/sms_service.dart';
import 'services/permission_service.dart';
import 'services/notification_service.dart';
import 'models/filter_config.dart';
import 'models/sender_keyword_rule.dart';
import 'models/sms_message.dart';
import 'models/category_mapping.dart';
import 'services/category_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const SmsFilterApp());
}

class SmsFilterApp extends StatelessWidget {
  const SmsFilterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppState())],
      child: MaterialApp(
        title: 'SMS Filter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.light,
            // 优化色彩搭配
            primary: const Color(0xFF6750A4),
            primaryContainer: const Color(0xFFEADDFF),
            secondary: const Color(0xFF625B71),
            secondaryContainer: const Color(0xFFE8DEF8),
            error: const Color(0xFFB3261E),
            errorContainer: const Color(0xFFF9DEDC),
            surface: const Color(0xFFFEF7FF),
            surfaceContainerHighest: const Color(0xFFE7E0EC),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onError: Colors.white,
            onSurface: const Color(0xFF1C1B1F),
            onSurfaceVariant: const Color(0x4F46464F),
          ),
          useMaterial3: true,
          // 优化卡片主题
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
          ),
          // 优化应用栏主题
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 4,
            shadowColor: Colors.black12,
          ),
          // 优化文本主题
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 16, height: 1.5),
            bodyMedium: TextStyle(fontSize: 14, height: 1.4),
            bodySmall: TextStyle(fontSize: 12, height: 1.3),
            titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          // 优化按钮主题
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          // 优化输入框主题
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final SmsService _smsService = SmsService();
  final PermissionService _permissionService = PermissionService();
  final CategoryService _categoryService = CategoryService();

  FilterConfig _config = FilterConfig.empty();
  List<SavedSmsMessage> _savedMessages = [];
  List<CategoryMapping> _categoryMappings = [];
  bool _isLoading = true;
  bool _hasPermissions = false;

  FilterConfig get config => _config;
  List<SavedSmsMessage> get savedMessages => _savedMessages;
  List<CategoryMapping> get categoryMappings => _categoryMappings;
  bool get isLoading => _isLoading;
  bool get hasPermissions => _hasPermissions;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    await loadData();
    await loadCategoryMappings();
    await checkPermissions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadData() async {
    _config = await _storageService.loadConfig();
    _savedMessages = await _storageService.loadMessages();
    // 按接收时间倒序排列
    _savedMessages.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    notifyListeners();
  }

  Future<void> loadCategoryMappings() async {
    _categoryMappings = await _categoryService.getMappings();
    notifyListeners();
  }

  Future<void> checkPermissions() async {
    _hasPermissions = await _permissionService.checkSmsPermissions();
    notifyListeners();
  }

  Future<bool> requestPermissions() async {
    _hasPermissions = await _permissionService.requestSmsPermissions();
    notifyListeners();
    return _hasPermissions;
  }

  Future<void> updateConfig(FilterConfig newConfig) async {
    _config = newConfig;
    await _storageService.saveConfig(newConfig);
    notifyListeners();
  }

  Future<void> addRule(String sender, [List<String>? keywords]) async {
    if (sender.isEmpty) return;
    if (_config.rules.any((r) => r.sender == sender)) return;

    final newRule = SenderKeywordRule(sender: sender, keywords: keywords ?? []);

    final newRules = [..._config.rules, newRule];
    await updateConfig(_config.copyWith(rules: newRules));
  }

  Future<void> removeRule(String sender) async {
    final newRules = _config.rules.where((r) => r.sender != sender).toList();
    await updateConfig(_config.copyWith(rules: newRules));
  }

  Future<void> addKeywordForSender(String sender, String keyword) async {
    final ruleIndex = _config.rules.indexWhere((r) => r.sender == sender);
    if (ruleIndex == -1) return;

    final rule = _config.rules[ruleIndex];
    if (rule.keywords.contains(keyword)) return;

    final newKeywords = [...rule.keywords, keyword];
    final newRule = rule.copyWith(keywords: newKeywords);

    final newRules = [..._config.rules];
    newRules[ruleIndex] = newRule;

    await updateConfig(_config.copyWith(rules: newRules));
  }

  Future<void> removeKeywordForSender(String sender, String keyword) async {
    final ruleIndex = _config.rules.indexWhere((r) => r.sender == sender);
    if (ruleIndex == -1) return;

    final rule = _config.rules[ruleIndex];
    final newKeywords = rule.keywords.where((k) => k != keyword).toList();
    final newRule = rule.copyWith(keywords: newKeywords);

    final newRules = [..._config.rules];
    newRules[ruleIndex] = newRule;

    await updateConfig(_config.copyWith(rules: newRules));
  }

  List<String> getSenders() {
    return _config.rules.map((r) => r.sender).toList();
  }

  List<String> getKeywordsForSender(String sender) {
    final rule = _config.rules.firstWhere(
      (r) => r.sender == sender,
      orElse: () => SenderKeywordRule(sender: sender, keywords: []),
    );
    return rule.keywords;
  }

  Future<void> deleteMessage(String id) async {
    await _storageService.deleteMessage(id);
    _savedMessages.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  Future<void> clearAllMessages() async {
    await _storageService.clearAllMessages();
    _savedMessages.clear();
    notifyListeners();
  }

  Future<void> updateMessage(SavedSmsMessage message) async {
    await _storageService.updateMessage(message);
    final index = _savedMessages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      _savedMessages[index] = message;
      notifyListeners();
    }
  }

  Future<void> addCategoryMapping(CategoryMapping mapping) async {
    await _categoryService.addMapping(mapping);
    await loadCategoryMappings(); // 重新从 service 加载
  }

  Future<void> removeCategoryMapping(String keyword) async {
    await _categoryService.removeMapping(keyword);
    await loadCategoryMappings(); // 重新从 service 加载
  }

  Future<String> exportMessages({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _storageService.exportToJson(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<File?> exportDataToFile({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _storageService.exportToFile(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<int> scanExistingMessages() async {
    final count = await _smsService.scanAllMessages();
    await loadData();
    return count;
  }

  Future<void> reclassifyMessages() async {
    await _storageService.reclassifyMessages();
    await loadData();
  }
}
