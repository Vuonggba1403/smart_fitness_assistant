import 'package:flutter/material.dart';

class WaterIntake {
  final String? id;
  final String forUser;
  final int amountMl;
  final DateTime createdAt;

  WaterIntake({
    this.id,
    required this.forUser,
    required this.amountMl,
    required this.createdAt,
  });

  factory WaterIntake.fromJson(Map<String, dynamic> json) {
    return WaterIntake(
      id: json['id'],
      forUser: json['for_user'],
      amountMl: json['amount_ml'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'for_user': forUser,
      'amount_ml': amountMl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

// ✅ THÊM: Model cho water goal settings
class WaterGoalSettings {
  final String? id;
  final String forUser;
  final int dailyGoalMl;
  final bool reminderEnabled;
  final int reminderIntervalMinutes; // Nhắc mỗi X phút
  final TimeOfDay? reminderStartTime; // Bắt đầu nhắc từ
  final TimeOfDay? reminderEndTime; // Nhắc đến

  WaterGoalSettings({
    this.id,
    required this.forUser,
    this.dailyGoalMl = 2000,
    this.reminderEnabled = false,
    this.reminderIntervalMinutes = 60,
    this.reminderStartTime,
    this.reminderEndTime,
  });

  factory WaterGoalSettings.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return WaterGoalSettings(
      id: json['id'],
      forUser: json['for_user'],
      dailyGoalMl: json['daily_goal_ml'] ?? 2000,
      reminderEnabled: json['reminder_enabled'] ?? false,
      reminderIntervalMinutes: json['reminder_interval_minutes'] ?? 60,
      reminderStartTime: parseTime(json['reminder_start_time']),
      reminderEndTime: parseTime(json['reminder_end_time']),
    );
  }

  Map<String, dynamic> toJson() {
    String? formatTime(TimeOfDay? time) {
      if (time == null) return null;
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }

    return {
      'for_user': forUser,
      'daily_goal_ml': dailyGoalMl,
      'reminder_enabled': reminderEnabled,
      'reminder_interval_minutes': reminderIntervalMinutes,
      'reminder_start_time': formatTime(reminderStartTime),
      'reminder_end_time': formatTime(reminderEndTime),
    };
  }

  WaterGoalSettings copyWith({
    String? id,
    String? forUser,
    int? dailyGoalMl,
    bool? reminderEnabled,
    int? reminderIntervalMinutes,
    TimeOfDay? reminderStartTime,
    TimeOfDay? reminderEndTime,
  }) {
    return WaterGoalSettings(
      id: id ?? this.id,
      forUser: forUser ?? this.forUser,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderIntervalMinutes:
          reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      reminderStartTime: reminderStartTime ?? this.reminderStartTime,
      reminderEndTime: reminderEndTime ?? this.reminderEndTime,
    );
  }
}
