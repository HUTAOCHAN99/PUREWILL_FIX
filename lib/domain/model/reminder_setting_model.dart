class ReminderSettingModel {
  final String id;
  final int habitId;
  final bool isEnabled;
  final DateTime time;
  final int snoozeDuration;
  final bool repeatDaily;
  final bool isSoundEnabled;
  final bool isVibrationEnabled;

  ReminderSettingModel({
    required this.id,
    required this.habitId,
    required this.isEnabled,
    required this.time,
    required this.snoozeDuration,
    required this.repeatDaily,
    required this.isSoundEnabled,
    required this.isVibrationEnabled,
  });

  factory ReminderSettingModel.fromJson(Map<String, dynamic> json) {
    return ReminderSettingModel(
      id: json['id'],
      habitId: json['habit_id'],
      isEnabled: json['is_enabled'],
      time: DateTime.parse(json['time']),
      snoozeDuration: json['snooze_duration'],
      repeatDaily: json['repeat_daily'],
      isSoundEnabled: json['is_sound_enabled'],
      isVibrationEnabled: json['is_vibration_enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'is_enabled': isEnabled,
      'time': time.toIso8601String(),
      'snooze_duration': snoozeDuration,
      'repeat_daily': repeatDaily,
      'is_sound_enabled': isSoundEnabled,
      'is_vibration_enabled': isVibrationEnabled,
    };
  }
}
