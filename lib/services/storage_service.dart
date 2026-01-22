import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sms_message.dart';
import '../models/filter_config.dart';
import 'category_service.dart';

class StorageService {
  static const String _configKey = 'filter_config';
  static const String _messagesFileName = 'saved_messages.json';
  final CategoryService _categoryService = CategoryService();

  // ========== 配置存储 ==========

  Future<void> saveConfig(FilterConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_configKey, jsonEncode(config.toJson()));
  }

  Future<FilterConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_configKey);
    if (jsonStr == null) {
      return FilterConfig.empty();
    }
    return FilterConfig.fromJson(jsonDecode(jsonStr));
  }

  // ========== 短信存储 ==========

  Future<File> _getMessagesFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_messagesFileName');
  }

  Future<List<SavedSmsMessage>> loadMessages() async {
    try {
      final file = await _getMessagesFile();
      if (!await file.exists()) {
        return [];
      }
      final content = await file.readAsString();
      final jsonData = jsonDecode(content) as Map<String, dynamic>;
      final messages = (jsonData['messages'] as List)
          .map((e) => SavedSmsMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      return messages;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveMessages(List<SavedSmsMessage> messages) async {
    final file = await _getMessagesFile();
    final jsonData = {
      'messages': messages.map((m) => m.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
    await file.writeAsString(jsonEncode(jsonData));
  }

  Future<bool> checkIfMessageExists(String sender, DateTime receivedAt) async {
    final messages = await loadMessages();
    final uniqueKey = '${sender}_${receivedAt.millisecondsSinceEpoch}';
    return messages.any((m) => m.uniqueKey == uniqueKey);
  }

  Future<void> addMessage(SavedSmsMessage message) async {
    final messages = await loadMessages();

    final isDuplicate = messages.any((m) => m.uniqueKey == message.uniqueKey);
    if (isDuplicate) {
      print('Duplicate message detected: ${message.uniqueKey}, skipping save');
      return;
    }

    SavedSmsMessage messageWithCategory;

    if (message.isManuallyClassified) {
      messageWithCategory = message;
    } else {
      final categoryMapping = await _categoryService.matchCategory(
        message.content,
      );
      final type = categoryMapping?.type ?? '支出';
      final category = categoryMapping?.category ?? '待分类';
      final secondaryCategory = categoryMapping?.secondaryCategory;

      messageWithCategory = SavedSmsMessage(
        id: message.id,
        sender: message.sender,
        content: message.content,
        receivedAt: message.receivedAt,
        savedAt: message.savedAt,
        type: type,
        category: category,
        secondaryCategory: secondaryCategory,
        isManuallyClassified: false,
      );
    }

    messages.insert(0, messageWithCategory);
    await saveMessages(messages);
  }

  Future<void> deleteMessage(String id) async {
    final messages = await loadMessages();
    messages.removeWhere((m) => m.id == id);
    await saveMessages(messages);
  }

  Future<void> updateMessage(SavedSmsMessage updatedMessage) async {
    final messages = await loadMessages();
    final index = messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      messages[index] = updatedMessage;
      await saveMessages(messages);
    }
  }

  Future<void> clearAllMessages() async {
    final file = await _getMessagesFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> reclassifyMessages() async {
    final messages = await loadMessages();
    bool hasChanges = false;

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];

      if (message.isManuallyClassified) {
        continue;
      }

      final categoryMapping = await _categoryService.matchCategory(
        message.content,
      );
      final newType = categoryMapping?.type ?? '支出';
      final newCategory = categoryMapping?.category ?? '待分类';
      final newSecondaryCategory = categoryMapping?.secondaryCategory;

      if (message.type != newType ||
          message.category != newCategory ||
          message.secondaryCategory != newSecondaryCategory) {
        messages[i] = SavedSmsMessage(
          id: message.id,
          sender: message.sender,
          content: message.content,
          receivedAt: message.receivedAt,
          savedAt: message.savedAt,
          type: newType,
          category: newCategory,
          secondaryCategory: newSecondaryCategory,
          isManuallyClassified: false,
        );
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await saveMessages(messages);
    }
  }

  // ========== 导出功能 ==========

  Future<String> exportToJson({DateTime? startDate, DateTime? endDate}) async {
    final messages = await loadMessages();
    var filteredMessages = messages;

    if (startDate != null || endDate != null) {
      filteredMessages = messages.where((m) {
        if (startDate != null && m.receivedAt.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && m.receivedAt.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();
    }

    final sortedMessages = List<SavedSmsMessage>.from(filteredMessages)
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

    final jsonData = {
      'messages': sortedMessages
          .map((m) => _formatMessageForExport(m))
          .toList(),
      'exportedAt': _formatDateTime(DateTime.now()),
      'totalCount': sortedMessages.length,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };
    return const JsonEncoder.withIndent('  ').convert(jsonData);
  }

  Map<String, dynamic> _formatMessageForExport(SavedSmsMessage message) {
    final result = <String, dynamic>{
      'id': message.id,
      'sender': message.sender,
      'content': message.content,
      'receivedAt': _formatDateTime(message.receivedAt),
      'savedAt': _formatDateTime(message.savedAt),
      'uniqueKey': message.uniqueKey,
      'type': message.type,
      'isManuallyClassified': message.isManuallyClassified,
    };

    if (message.category != null) {
      result['category'] = message.category!;
    }

    return result;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  Future<File?> exportToFile({DateTime? startDate, DateTime? endDate}) async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportFile = File('${directory.path}/sms_export_$timestamp.json');
      final jsonContent = await exportToJson(
        startDate: startDate,
        endDate: endDate,
      );
      await exportFile.writeAsString(jsonContent);
      return exportFile;
    } catch (e) {
      return null;
    }
  }
}
