import 'package:flutter/material.dart';

class ReminderSettingModel {
  final String id;
  final int habitId;
  final bool isEnabled;
  final DateTime time;
  final int snoozeDuration;
  final bool repeatDaily;
  final bool isSoundEnabled;
  final bool isVibrationEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ReminderSettingModel({
    required this.id,
    required this.habitId,
    required this.isEnabled,
    required this.time,
    required this.snoozeDuration,
    required this.repeatDaily,
    required this.isSoundEnabled,
    required this.isVibrationEnabled,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReminderSettingModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    bool parseBool(dynamic value, {bool fallback = false}) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      final raw = value?.toString().toLowerCase();
      if (raw == 'true' || raw == '1') return true;
      if (raw == 'false' || raw == '0') return false;
      return fallback;
    }

    // Parse the timestamp as-is
    DateTime parsedTime;
    try {
      if (json['time'] is String) {
        parsedTime = DateTime.parse(json['time'] as String);
      } else {
        parsedTime = DateTime.now();
      }
    } catch (e) {
      parsedTime = DateTime.now();
    }

    DateTime? parsedCreatedAt;
    try {
      final createdAtValue = json['createdAt'] ?? json['created_at'];
      if (createdAtValue is String) {
        parsedCreatedAt = DateTime.parse(createdAtValue);
      }
    } catch (_) {
      parsedCreatedAt = null;
    }

    DateTime? parsedUpdatedAt;
    try {
      final updatedAtValue = json['updatedAt'] ?? json['updated_at'];
      if (updatedAtValue is String) {
        parsedUpdatedAt = DateTime.parse(updatedAtValue);
      }
    } catch (_) {
      parsedUpdatedAt = null;
    }

    final habitId = json['habitId'] ?? json['habit_id'];
    final isEnabled = json['isEnabled'] ?? json['is_enabled'];
    final snoozeDuration = json['snoozeDuration'] ?? json['snooze_duration'];
    final repeatDaily = json['repeatDaily'] ?? json['repeat_daily'];
    final isSoundEnabled = json['isSoundEnabled'] ?? json['is_sound_enabled'];
    final isVibrationEnabled =
        json['isVibrationEnabled'] ?? json['is_vibration_enabled'];

    return ReminderSettingModel(
      id: json['id']?.toString() ?? '',
      habitId: parseInt(habitId),
      isEnabled: parseBool(isEnabled),
      time: parsedTime,
      snoozeDuration: parseInt(snoozeDuration, fallback: 10),
      repeatDaily: parseBool(repeatDaily, fallback: true),
      isSoundEnabled: parseBool(isSoundEnabled, fallback: true),
      isVibrationEnabled: parseBool(isVibrationEnabled, fallback: false),
      createdAt: parsedCreatedAt ?? DateTime.now(),
      updatedAt: parsedUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'habitId': habitId,
      'isEnabled': isEnabled,
      'time': time.toIso8601String(),
      'snoozeDuration': snoozeDuration,
      'repeatDaily': repeatDaily,
      'isSoundEnabled': isSoundEnabled,
      'isVibrationEnabled': isVibrationEnabled,
    };

    // Only add id if not empty (for update)
    if (id.isNotEmpty) {
      final parsedId = int.tryParse(id);
      if (parsedId != null) {
        json['id'] = parsedId;
      }
    }

    // debugPrint('🎯 REMINDER SETTING TO JSON:');
    // debugPrint('   - Exact time to store: ${time.toIso8601String()}');
    // debugPrint('   - Hour: ${time.hour}, Minute: ${time.minute}');

    return json;
  }

  // Create empty/default instance
  factory ReminderSettingModel.empty({required int habitId}) {
    final now = DateTime.now();
    return ReminderSettingModel(
      id: '',
      habitId: habitId,
      isEnabled: false,
      time: now,
      snoozeDuration: 10,
      repeatDaily: true,
      isSoundEnabled: true,
      isVibrationEnabled: false,
      createdAt: now,
    );
  }

  ReminderSettingModel copyWith({
    String? id,
    int? habitId,
    bool? isEnabled,
    DateTime? time,
    int? snoozeDuration,
    bool? repeatDaily,
    bool? isSoundEnabled,
    bool? isVibrationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderSettingModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      isEnabled: isEnabled ?? this.isEnabled,
      time: time ?? this.time,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      repeatDaily: repeatDaily ?? this.repeatDaily,
      isSoundEnabled: isSoundEnabled ?? this.isSoundEnabled,
      isVibrationEnabled: isVibrationEnabled ?? this.isVibrationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ReminderSettingModel{id: $id, habitId: $habitId, isEnabled: $isEnabled, time: $time, snoozeDuration: $snoozeDuration, repeatDaily: $repeatDaily, isSoundEnabled: $isSoundEnabled, isVibrationEnabled: $isVibrationEnabled, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  // Helper methods
  bool get isEmpty => id.isEmpty;
  TimeOfDay get timeOfDay => TimeOfDay.fromDateTime(time);

  String get formattedTime {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  bool get isPastForToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderToday = DateTime(
      today.year,
      today.month,
      today.day,
      time.hour,
      time.minute,
    );
    return reminderToday.isBefore(now);
  }

  DateTime get nextScheduledTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var scheduled = DateTime(
      today.year,
      today.month,
      today.day,
      time.hour,
      time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  String get dynamicTimeDisplay {
    final nextTime = nextScheduledTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (nextTime.year == today.year &&
        nextTime.month == today.month &&
        nextTime.day == today.day) {
      return 'Today at $formattedTime';
    } else if (nextTime.year == tomorrow.year &&
        nextTime.month == tomorrow.month &&
        nextTime.day == tomorrow.day) {
      return 'Tomorrow at $formattedTime';
    } else {
      return '${nextTime.day}/${nextTime.month} at $formattedTime';
    }
  }
}
