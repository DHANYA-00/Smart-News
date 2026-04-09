import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInitialize = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: darwinInitialize,
      macOS: darwinInitialize,
    );

    await _flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await init();
    
    // For Android 13+ it will show a prompt. 
    // For iOS, it shows the native permission alert.
    final androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    final iosImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> scheduleDailyReminder() async {
    await requestPermissions();

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_news_reminder_channel',
      'Daily News Reminder',
      channelDescription: 'Reminds you to check out the latest news.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Cancel old notifications first
    await cancelDailyReminder();

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      id: 0,
      title: 'SmartNews',
      body: 'Time to catch up on the latest news! 📰',
      repeatInterval: RepeatInterval.daily,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelDailyReminder() async {
    await init();
    await _flutterLocalNotificationsPlugin.cancel(id: 0);
  }
}
