import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  Future<void> showSmsNotification({
    required String sender,
    required String preview,
    DateTime? receivedAt,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final when = receivedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch;

    final androidDetails = AndroidNotificationDetails(
      'sms_filter_channel',
      '短信过滤通知',
      channelDescription: '当短信被过滤保存时显示通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      // 增强通知显示效果
      showWhen: true,
      when: when,
      styleInformation: BigTextStyleInformation(preview),
    );

    final details = NotificationDetails(android: androidDetails);

    final timeString = receivedAt != null 
        ? ' ${receivedAt.hour.toString().padLeft(2, '0')}:${receivedAt.minute.toString().padLeft(2, '0')}' 
        : '';

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      '已保存短信 - $sender$timeString',
      preview,
      details,
    );
  }
}
