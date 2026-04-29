import 'dart:developer';
import 'package:purewill/domain/model/reminder_setting_model.dart';
import 'package:purewill/data/services/reminder_api_service.dart';

class ReminderSettingRepository {
  static final Map<int, ReminderSettingModel> _localSettings = {};
  static int _nextId = 1;

  final ReminderApiService? _apiService;

  ReminderSettingRepository({ReminderApiService? apiService})
    : _apiService = apiService;

  void _logNotImplemented(String mechanism) {
    log(
      '$mechanism: belum di impelemtnasikan di habit service',
      name: 'HABIT_SERVICE_MIGRATION',
    );
  }

  Map<String, dynamic> _normalizeUpdatePayload(Map<String, dynamic> updates) {
    return {
      if (updates.containsKey('time')) 'time': updates['time'],
      if (updates.containsKey('isEnabled')) 'isEnabled': updates['isEnabled'],
      if (updates.containsKey('is_enabled')) 'isEnabled': updates['is_enabled'],
      if (updates.containsKey('snoozeDuration'))
        'snoozeDuration': updates['snoozeDuration'],
      if (updates.containsKey('snooze_duration'))
        'snoozeDuration': updates['snooze_duration'],
      if (updates.containsKey('repeatDaily'))
        'repeatDaily': updates['repeatDaily'],
      if (updates.containsKey('repeat_daily'))
        'repeatDaily': updates['repeat_daily'],
      if (updates.containsKey('isSoundEnabled'))
        'isSoundEnabled': updates['isSoundEnabled'],
      if (updates.containsKey('is_sound_enabled'))
        'isSoundEnabled': updates['is_sound_enabled'],
      if (updates.containsKey('isVibrationEnabled'))
        'isVibrationEnabled': updates['isVibrationEnabled'],
      if (updates.containsKey('is_vibration_enabled'))
        'isVibrationEnabled': updates['is_vibration_enabled'],
    };
  }

  Map<String, dynamic> _extractDataMap(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return response;
  }

  Future<ReminderSettingModel> createReminderSetting(
    ReminderSettingModel setting,
  ) async {
    _logNotImplemented('reminder createReminderSetting');

    // Attempt remote creation if api service available
    if (_apiService != null) {
      try {
        final body = {
          'habitId': setting.habitId,
          'time': setting.time.toIso8601String(),
          'isEnabled': setting.isEnabled,
          'snoozeDuration': setting.snoozeDuration,
          'repeatDaily': setting.repeatDaily,
          'isSoundEnabled': setting.isSoundEnabled,
          'isVibrationEnabled': setting.isVibrationEnabled,
        };
        final resp = await _apiService.createReminderSetting(body);
        return ReminderSettingModel.fromJson(_extractDataMap(resp));
      } catch (e) {
        // fallback to local
      }
    }

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
    _logNotImplemented('reminder fetchReminderSettingsByHabit');

    // Try remote fetch first
    if (_apiService != null) {
      try {
        final items = await _apiService.getHabitReminderSettings(habitId);
        if (items.isNotEmpty) {
          return ReminderSettingModel.fromJson(items.first);
        }
      } catch (e) {
        // ignore and fallback to local
      }
    }

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
    required int reminderSettingId,
    required Map<String, dynamic> updates,
  }) async {
    _logNotImplemented('reminder updateReminderSetting');

    if (_apiService != null) {
      try {
        await _apiService.updateReminderSetting(
          reminderSettingId,
          _normalizeUpdatePayload(updates),
        );
        return;
      } catch (e) {
        // fallback to local
      }
    }

    final entry = _localSettings.entries.firstWhere(
      (entry) => entry.value.id == reminderSettingId.toString(),
    );

    final current = entry.value;
    DateTime? parsedTime;
    final timeValue = updates['time'];
    if (timeValue is DateTime) {
      parsedTime = timeValue;
    } else if (timeValue is String) {
      parsedTime = DateTime.tryParse(timeValue);
    }

    final updated = ReminderSettingModel(
      id: current.id,
      habitId: current.habitId,
      isEnabled:
          (updates['isEnabled'] as bool?) ??
          (updates['is_enabled'] as bool?) ??
          current.isEnabled,
      time: parsedTime ?? current.time,
      snoozeDuration:
          (updates['snoozeDuration'] as int?) ??
          (updates['snooze_duration'] as int?) ??
          current.snoozeDuration,
      repeatDaily:
          (updates['repeatDaily'] as bool?) ??
          (updates['repeat_daily'] as bool?) ??
          current.repeatDaily,
      isSoundEnabled:
          (updates['isSoundEnabled'] as bool?) ??
          (updates['is_sound_enabled'] as bool?) ??
          current.isSoundEnabled,
      isVibrationEnabled:
          (updates['isVibrationEnabled'] as bool?) ??
          (updates['is_vibration_enabled'] as bool?) ??
          current.isVibrationEnabled,
      createdAt: current.createdAt,
    );

    _localSettings[updated.habitId] = updated;
  }

  Future<void> deleteReminderSetting(int reminderSettingId) async {
    _logNotImplemented('reminder deleteReminderSetting');
    if (_apiService != null) {
      try {
        await _apiService.deleteReminderSetting(reminderSettingId);
        _localSettings.removeWhere(
          (key, value) => value.id == reminderSettingId.toString(),
        );
        return;
      } catch (e) {
        // fallback
      }
    }

    _localSettings.removeWhere(
      (key, value) => value.id == reminderSettingId.toString(),
    );
  }

  Future<void> deleteAllReminderSettingsForHabit(int habitId) async {
    _logNotImplemented('reminder deleteAllReminderSettingsForHabit');
    if (_apiService != null) {
      try {
        final items = await _apiService.getHabitReminderSettings(habitId);
        for (final item in items) {
          final id = item['id'];
          final parsedId = id is int ? id : int.tryParse(id?.toString() ?? '');
          if (parsedId != null) {
            await _apiService.deleteReminderSetting(parsedId);
          }
        }
      } catch (e) {
        // ignore
      }
    }
    _localSettings.remove(habitId);
  }
}
