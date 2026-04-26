// lib/data/repository/reminder_setting_repository.dart

import 'dart:developer';
import 'package:purewill/domain/model/reminder_setting_model.dart';

class ReminderSettingRepository {
  static final Map<int, ReminderSettingModel> _localSettings = {};
  static int _nextId = 1;

  ReminderSettingRepository();

  Future<ReminderSettingModel> createReminderSetting(ReminderSettingModel setting) async {
    log('🔧 DEBUG: createReminderSetting - habitId: ${setting.habitId}',
        name: 'REMINDER_DEBUG');

    final newSetting = ReminderSettingModel(
      id: _nextId.toString(),
      habitId: setting.habitId,
      isEnabled: setting.isEnabled,
      time: setting.time,
      snoozeDuration: setting.snoozeDuration,
      repeatDaily: setting.repeatDaily,
      isSoundEnabled: setting.isSoundEnabled,
      isVibrationEnabled: setting.isVibrationEnabled,
      createdAt: DateTime.now(),
    );

    _localSettings[setting.habitId] = newSetting;
    _nextId++;
    return newSetting;
  }

  Future<ReminderSettingModel> fetchReminderSettingsByHabit(int habitId) async {
    log('🔧 DEBUG: fetchReminderSettingsByHabit - habitId: $habitId',
        name: 'REMINDER_DEBUG');

    final existing = _localSettings[habitId];
    if (existing != null) return existing;

    return ReminderSettingModel(
      id: '',
      habitId: habitId,
      isEnabled: false,
      time: DateTime.now(),
      snoozeDuration: 5,
      repeatDaily: true,
      isSoundEnabled: true,
      isVibrationEnabled: true,
      createdAt: DateTime.now(),
    );
  }

  Future<void> updateReminderSetting({
    required String reminderSettingId,
    required Map<String, dynamic> updates,
  }) async {
    log('🔧 DEBUG: updateReminderSetting - id: $reminderSettingId',
        name: 'REMINDER_DEBUG');

    final entry = _localSettings.entries.firstWhere(
      (entry) => entry.value.id == reminderSettingId,
    );
    
    final current = entry.value;
    final updated = ReminderSettingModel(
      id: current.id,
      habitId: current.habitId,
      isEnabled: updates['is_enabled'] as bool? ?? current.isEnabled,
      time: updates['time'] as DateTime? ?? current.time,
      snoozeDuration: updates['snooze_duration'] as int? ?? current.snoozeDuration,
      repeatDaily: updates['repeat_daily'] as bool? ?? current.repeatDaily,
      isSoundEnabled: updates['is_sound_enabled'] as bool? ?? current.isSoundEnabled,
      isVibrationEnabled: updates['is_vibration_enabled'] as bool? ?? current.isVibrationEnabled,
      createdAt: current.createdAt,
    );
    
    _localSettings[updated.habitId] = updated;
  }

  Future<void> deleteReminderSetting(int habitId) async {
    log('🔧 DEBUG: deleteReminderSetting - habitId: $habitId',
        name: 'REMINDER_DEBUG');
    _localSettings.remove(habitId);
  }

  Future<void> deleteAllReminderSettingsForHabit(int habitId) async {
    log('🔧 DEBUG: deleteAllReminderSettingsForHabit - habitId: $habitId',
        name: 'REMINDER_DEBUG');
    _localSettings.remove(habitId);
  }
}