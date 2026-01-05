import 'package:flutter/material.dart';
import 'package:smart_fitness_assistant/core/services/notification_service.dart';
import 'package:smart_fitness_assistant/core/services/water_tracker_service.dart';
import 'package:smart_fitness_assistant/core/models/water_intake.dart';

/// Debug screen để test notifications
class DebugNotificationsScreen extends StatefulWidget {
  const DebugNotificationsScreen({super.key});

  @override
  State<DebugNotificationsScreen> createState() =>
      _DebugNotificationsScreenState();
}

class _DebugNotificationsScreenState extends State<DebugNotificationsScreen> {
  final _notificationService = NotificationService();
  final _waterService = WaterTrackerService();
  List<String> _logs = [];

  void _addLog(String log) {
    setState(() {
      _logs.add('[${DateTime.now().toString().substring(11, 19)}] $log');
    });
    print(log);
  }

  Future<void> _checkPendingNotifications() async {
    _addLog('🔍 Checking pending notifications...');
    final pending = await _notificationService.getPendingNotifications();
    _addLog('📊 Found ${pending.length} pending notifications');

    for (var notif in pending) {
      _addLog('  - ID: ${notif.id}, Title: ${notif.title}');
    }
  }

  Future<void> _testImmediateNotification() async {
    _addLog('🧪 Testing immediate notification...');
    final now = DateTime.now().add(const Duration(seconds: 5));

    await _notificationService.scheduleWorkoutNotification(
      id: 99999,
      title: '🧪 Test Notification',
      body: 'This is a test notification in 5 seconds',
      scheduledTime: now,
    );

    _addLog('✅ Scheduled test notification for ${now.toString()}');
  }

  Future<void> _testWaterReminders() async {
    _addLog('💧 Testing water reminders...');
    final userId = _waterService.currentUserId;

    if (userId == null) {
      _addLog('❌ User not logged in');
      return;
    }

    _addLog('👤 User ID: $userId');

    final settings = await _waterService.loadSettings(userId);
    _addLog('⚙️ Settings loaded:');
    _addLog('  - Enabled: ${settings.reminderEnabled}');
    _addLog('  - Interval: ${settings.reminderIntervalMinutes} min');
    _addLog(
      '  - Start: ${settings.reminderStartTime?.hour}:${settings.reminderStartTime?.minute}',
    );
    _addLog(
      '  - End: ${settings.reminderEndTime?.hour}:${settings.reminderEndTime?.minute}',
    );

    if (settings.reminderEnabled) {
      await _waterService.scheduleReminders(userId, settings);
      _addLog('✅ Reminders scheduled');
    } else {
      _addLog('⚠️ Reminders are disabled');
    }

    await _checkPendingNotifications();
  }

  Future<void> _cancelAllNotifications() async {
    _addLog('🗑️ Cancelling all notifications...');
    await _notificationService.cancelAllNotifications();
    _addLog('✅ All notifications cancelled');
    await _checkPendingNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Notifications')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _checkPendingNotifications,
                  icon: const Icon(Icons.list),
                  label: const Text('Check Pending Notifications'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _testImmediateNotification,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Test Notification (5s)'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _testWaterReminders,
                  icon: const Icon(Icons.water_drop),
                  label: const Text('Test Water Reminders'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _cancelAllNotifications,
                  icon: const Icon(Icons.delete),
                  label: const Text('Cancel All'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Text(
                    _logs[index],
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
