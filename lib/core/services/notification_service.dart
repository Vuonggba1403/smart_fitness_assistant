import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // ✅ Khởi tạo timezone database
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        print('📱 Notification tapped: ${response.payload}');
      },
    );
  }

  Future<bool> requestPermissions() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final granted = await androidImplementation
        ?.requestNotificationsPermission();
    print('✅ Notification permission: $granted');
    return granted ?? false;
  }

  Future<void> scheduleWorkoutNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // ✅ Convert DateTime thành TZDateTime
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    print('📅 Scheduling notification:');
    print('   ID: $id');
    print('   Title: $title');
    print('   Body: $body');
    print('   Scheduled Time (Input): $scheduledTime');
    print('   Scheduled Time (TZ): $tzScheduledTime');
    print('   Current Time: $now');
    print(
      '   Time Difference: ${tzScheduledTime.difference(now).inMinutes} minutes',
    );

    if (tzScheduledTime.isBefore(now)) {
      print(
        '⚠️ WARNING: Scheduled time is in the past! Notification may not trigger.',
      );
    }

    const androidDetails = AndroidNotificationDetails(
      'workout_reminders',
      'Workout Reminders',
      channelDescription: 'Nhắc nhở tập luyện',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('✅ Notification scheduled successfully!');

      // Verify notification was scheduled
      final pending = await getPendingNotifications();
      final scheduled = pending.where((n) => n.id == id).toList();
      print(
        '✅ Verified: ${scheduled.length} pending notification(s) with ID $id',
      );
    } catch (e, stackTrace) {
      print('❌ Error scheduling notification: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    print('❌ Notification $id cancelled');
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    print('❌ All notifications cancelled');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
