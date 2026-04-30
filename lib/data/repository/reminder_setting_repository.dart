import 'package:purewill/domain/model/reminder_setting_model.dart';
import 'package:purewill/data/services/reminder_api_service.dart';

class ReminderSettingRepository {
  final ReminderApiService _apiService;

  ReminderSettingRepository({required ReminderApiService apiService})
    : _apiService = apiService;

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
  }

  Future<ReminderSettingModel> fetchReminderSettingsByHabit(int habitId) async {
    final items = await fetchReminderSettingsListByHabit(habitId);
    if (items.isNotEmpty) {
      return items.first;
    }

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

  Future<List<ReminderSettingModel>> fetchReminderSettingsListByHabit(
    int habitId,
  ) async {
    final items = await _apiService.getHabitReminderSettings(habitId);
    return items.map(ReminderSettingModel.fromJson).toList();
  }

  Future<void> updateReminderSetting({
    required int reminderSettingId,
    required Map<String, dynamic> updates,
  }) async {
    await _apiService.updateReminderSetting(
      reminderSettingId,
      _normalizeUpdatePayload(updates),
    );
  }

  Future<void> deleteReminderSetting(int reminderSettingId) async {
    await _apiService.deleteReminderSetting(reminderSettingId);
  }

  Future<void> deleteAllReminderSettingsForHabit(int habitId) async {
    final items = await _apiService.getHabitReminderSettings(habitId);
    for (final item in items) {
      final id = item['id'];
      final parsedId = id is int ? id : int.tryParse(id?.toString() ?? '');
      if (parsedId != null) {
        await _apiService.deleteReminderSetting(parsedId);
      }
    }
  }
}
