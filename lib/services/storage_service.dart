import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sms_message.dart';
import '../models/filter_config.dart';

class StorageService {
  static const String _configKey = 'filter_config';
  static const String _messagesFileName = 'saved_messages.json';

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
    // 先检查是否已存在，避免不必要的对象创建和文件读取
    if (await checkIfMessageExists(message.sender, message.receivedAt)) {
      print('Duplicate message detected: ${message.uniqueKey}, skipping save');
      return;
    }

    final messages = await loadMessages();
    messages.insert(0, message);
    await saveMessages(messages);
  }

  Future<void> deleteMessage(String id) async {
    final messages = await loadMessages();
    messages.removeWhere((m) => m.id == id);
    await saveMessages(messages);
  }

  Future<void> clearAllMessages() async {
    final file = await _getMessagesFile();
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ========== 导出功能 ==========

  Future<String> exportToJson() async {
    final messages = await loadMessages();
    final jsonData = {
      'messages': messages.map((m) => m.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'totalCount': messages.length,
    };
    return const JsonEncoder.withIndent('  ').convert(jsonData);
  }

  Future<File?> exportToFile() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) return null;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportFile = File('${directory.path}/sms_export_$timestamp.json');
      final jsonContent = await exportToJson();
      await exportFile.writeAsString(jsonContent);
      return exportFile;
    } catch (e) {
      return null;
    }
  }
}
