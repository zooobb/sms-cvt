import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:uuid/uuid.dart';
import '../models/sms_message.dart';
import 'storage_service.dart';
import 'notification_service.dart';

class SmsService {
  static const MethodChannel _channel = MethodChannel(
    'com.smsfilter.sms_cvt/sms',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.smsfilter.sms_cvt/sms_events',
  );

  final SmsQuery _smsQuery = SmsQuery();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  StreamSubscription? _smsSubscription;
  bool _isListening = false;
  Function(SavedSmsMessage)? _onMessageSaved;

  bool get isListening => _isListening;

  Future<void> startListening({
    Function(SavedSmsMessage)? onMessageSaved,
  }) async {
    if (_isListening) return;

    _onMessageSaved = onMessageSaved;

    try {
      await _channel.invokeMethod('startListening');

      _smsSubscription = _eventChannel.receiveBroadcastStream().listen(
        (event) async {
          if (event is Map) {
            final sender = event['sender'] as String? ?? '';
            final body = event['body'] as String? ?? '';
            final timestamp =
                event['timestamp'] as int? ??
                DateTime.now().millisecondsSinceEpoch;

            print('Received SMS from: $sender, timestamp: $timestamp');
            print('SMS body: $body');

            await _handleIncomingSms(sender, body, timestamp);
          }
        },
        onError: (error) {
          print('Error in SMS stream: $error');
        },
        onDone: () {
          print('SMS stream done');
        },
      );

      _isListening = true;
      print('SMS listener started successfully');
    } catch (e) {
      print('Error starting SMS listener: $e');
    }
  }

  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _channel.invokeMethod('stopListening');
      await _smsSubscription?.cancel();
      _smsSubscription = null;
      _isListening = false;
      _onMessageSaved = null;
    } catch (e) {
      print('Error stopping SMS listener: $e');
    }
  }

  Future<void> _handleIncomingSms(
    String sender,
    String body,
    int timestamp,
  ) async {
    try {
      final config = await _storageService.loadConfig();

      print(
        'Current config: enabled=${config.isEnabled}, rules=${config.rules.length}',
      );

      if (!config.isEnabled) {
        print('SMS filtering is disabled, skipping message');
        return;
      }
      if (config.rules.isEmpty) {
        print('No rules configured, skipping message');
        return;
      }

      print('Checking if message should be saved: sender=$sender, body=$body');

      if (config.shouldSaveMessage(sender, body)) {
        final receivedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);

        // 先检查消息是否已存在，避免创建不必要的对象
        if (await _storageService.checkIfMessageExists(sender, receivedAt)) {
          print(
            'Message already exists, skipping: sender=$sender, timestamp=$timestamp',
          );
          return;
        }

        print('Message matches rules and is new, saving...');

        // 创建消息对象
        final savedMessage = SavedSmsMessage(
          id: _uuid.v4(),
          sender: sender,
          content: body,
          receivedAt: receivedAt,
          savedAt: DateTime.now(),
          type: '待分类',
          isManuallyClassified: false,
        );

        // 保存消息（addMessage 内部会再次检查，但这次应该不会重复）
        await _storageService.addMessage(savedMessage);

        // 发送通知
        await _notificationService.showSmsNotification(
          sender: sender,
          preview: body.length > 50 ? '${body.substring(0, 50)}...' : body,
          receivedAt: savedMessage.receivedAt,
        );

        _onMessageSaved?.call(savedMessage);
      } else {
        print('Message does not match rules, skipping');
      }
    } catch (e) {
      print('Error handling incoming SMS: $e');
    }
  }

  Future<List<SmsMessage>> getInboxMessages({int count = 100}) async {
    return await _smsQuery.querySms(kinds: [SmsQueryKind.inbox], count: count);
  }

  Future<int> scanAndSaveMessages() async {
    final config = await _storageService.loadConfig();
    if (!config.isEnabled) return 0;
    if (config.rules.isEmpty) return 0;

    final messages = await getInboxMessages(count: 500);
    print('Scanning ${messages.length} messages...');

    int savedCount = 0;
    int skippedCount = 0;

    for (final message in messages) {
      final sender = message.address ?? '';
      final body = message.body ?? '';
      final date = message.date ?? DateTime.now();

      // 先检查是否匹配过滤规则，避免不必要的检查
      if (!config.shouldSaveMessage(sender, body)) {
        continue;
      }

      // 使用专门的检查方法，避免创建临时对象
      if (await _storageService.checkIfMessageExists(sender, date)) {
        skippedCount++;
        continue;
      }

      // 创建并保存新消息
      final savedMessage = SavedSmsMessage(
        id: _uuid.v4(),
        sender: sender,
        content: body,
        receivedAt: date,
        savedAt: DateTime.now(),
        type: '待分类',
        isManuallyClassified: false,
      );

      await _storageService.addMessage(savedMessage);
      savedCount++;
      print('Saved new message: ${savedMessage.uniqueKey}');
    }

    print(
      'Scan completed: $savedCount new messages saved, $skippedCount duplicates skipped',
    );
    return savedCount;
  }

  Future<int> scanAllMessages() async {
    final config = await _storageService.loadConfig();
    if (config.rules.isEmpty) return 0;

    final messages = await getInboxMessages(count: 1000);
    print('Scanning all ${messages.length} messages...');

    int savedCount = 0;
    int skippedCount = 0;

    for (final message in messages) {
      final sender = message.address ?? '';
      final body = message.body ?? '';
      final date = message.date ?? DateTime.now();

      // 先检查是否匹配过滤规则，避免不必要的检查
      if (!config.shouldSaveMessage(sender, body)) {
        continue;
      }

      // 使用专门的检查方法，避免创建临时对象
      if (await _storageService.checkIfMessageExists(sender, date)) {
        skippedCount++;
        continue;
      }

      // 创建并保存新消息
      final savedMessage = SavedSmsMessage(
        id: _uuid.v4(),
        sender: sender,
        content: body,
        receivedAt: date,
        savedAt: DateTime.now(),
        type: '待分类',
        isManuallyClassified: false,
      );

      await _storageService.addMessage(savedMessage);
      savedCount++;
      print('Saved new message: ${savedMessage.uniqueKey}');
    }

    print(
      'Scan completed: $savedCount new messages saved, $skippedCount duplicates skipped',
    );
    return savedCount;
  }
}
