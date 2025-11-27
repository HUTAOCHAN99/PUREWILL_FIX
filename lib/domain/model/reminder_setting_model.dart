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
  });

  factory ReminderSettingModel.fromJson(Map<String, dynamic> json) {
    debugPrint('🎯 REMINDER SETTING FROM JSON:');
    debugPrint('   - id: ${json['id']} (type: ${json['id']?.runtimeType})');
    debugPrint('   - habit_id: ${json['habit_id']} (type: ${json['habit_id']?.runtimeType})');
    debugPrint('   - is_enabled: ${json['is_enabled']} (type: ${json['is_enabled']?.runtimeType})');
    debugPrint('   - time: ${json['time']} (type: ${json['time']?.runtimeType})');
    debugPrint('   - snooze_duration: ${json['snooze_duration']} (type: ${json['snooze_duration']?.runtimeType})');
    debugPrint('   - repeat_daily: ${json['repeat_daily']} (type: ${json['repeat_daily']?.runtimeType})');
    debugPrint('   - is_sound_enabled: ${json['is_sound_enabled']} (type: ${json['is_sound_enabled']?.runtimeType})');
    debugPrint('   - is_vibration_enabled: ${json['is_vibration_enabled']} (type: ${json['is_vibration_enabled']?.runtimeType})');
    debugPrint('   - created_at: ${json['created_at']} (type: ${json['created_at']?.runtimeType})');

    // Parse time - handle both DateTime string and TimeOfDay format
    DateTime parsedTime;
    try {
      if (json['time'] is String) {
        parsedTime = DateTime.parse(json['time'] as String);
      } else {
        parsedTime = DateTime.now();
      }
    } catch (e) {
      debugPrint('❌ Error parsing time: $e, using current time');
      parsedTime = DateTime.now();
    }

    return ReminderSettingModel(
      id: json['id']?.toString() ?? '',
      habitId: json['habit_id'] as int? ?? 0,
      isEnabled: json['is_enabled'] as bool? ?? false, // Default false sesuai database
      time: parsedTime,
      snoozeDuration: json['snooze_duration'] as int? ?? 10,
      repeatDaily: json['repeat_daily'] as bool? ?? true, // Default true sesuai database
      isSoundEnabled: json['is_sound_enabled'] as bool? ?? true, // Default true sesuai database
      isVibrationEnabled: json['is_vibration_enabled'] as bool? ?? false, // Default false sesuai database
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'habit_id': habitId,
      'is_enabled': isEnabled,
      'time': time.toIso8601String(),
      'snooze_duration': snoozeDuration,
      'repeat_daily': repeatDaily,
      'is_sound_enabled': isSoundEnabled,
      'is_vibration_enabled': isVibrationEnabled,
    };

    // Hanya tambahkan id jika tidak kosong (untuk update)
    if (id.isNotEmpty) {
      json['id'] = int.tryParse(id) as Object;
    }

    // created_at biasanya dihandle oleh database
    debugPrint('🎯 REMINDER SETTING TO JSON: $json');
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
    );
  }

  @override
  String toString() {
    return 'ReminderSettingModel{id: $id, habitId: $habitId, isEnabled: $isEnabled, time: $time, snoozeDuration: $snoozeDuration, repeatDaily: $repeatDaily, isSoundEnabled: $isSoundEnabled, isVibrationEnabled: $isVibrationEnabled, createdAt: $createdAt}';
  }

  // Helper method untuk check jika ini instance kosong
  bool get isEmpty => id.isEmpty;
}