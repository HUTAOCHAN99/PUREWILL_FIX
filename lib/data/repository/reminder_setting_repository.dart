import 'dart:developer';
import 'package:purewill/domain/model/reminder_setting_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReminderSettingRepository {
  final SupabaseClient _supabaseClient;
  static const String _reminderSettingTableName = 'reminder_settings';

  ReminderSettingRepository(this._supabaseClient);

  Future<ReminderSettingModel> createReminderSetting(
    ReminderSettingModel reminderSetting,
  ) async {
    try {
      final reminderSettingData = reminderSetting.toJson();

      final response = await _supabaseClient
          .from(_reminderSettingTableName)
          .insert(reminderSettingData)
          .select()
          .single();

      return ReminderSettingModel.fromJson(response);
    } catch (e, stackTrace) {
      log(
        'CREATE REMINDER SETTING FAILURE: Failed to create reminder setting for habit ${reminderSetting.habitId}.',
        error: e,
        stackTrace: stackTrace,
        name: 'REMINDER_SETTING_REPO',
      );
      rethrow;
    }
  }

  Future<List<ReminderSettingModel>> fetchReminderSettingsByHabit(
    int habitId,
  ) async {
    try {
      final response = await _supabaseClient
          .from(_reminderSettingTableName)
          .select('*')
          .eq('habit_id', habitId)
          .order('time', ascending: true);

      return response
          .map((data) => ReminderSettingModel.fromJson(data))
          .toList();
    } catch (e, stackTrace) {
      log(
        'FETCH REMINDER SETTINGS FAILURE: Failed to fetch reminder settings for habit $habitId.',
        error: e,
        stackTrace: stackTrace,
        name: 'REMINDER_SETTING_REPO',
      );
      rethrow;
    }
  }

  Future<void> updateReminderSetting({
    required String reminderSettingId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _supabaseClient
          .from(_reminderSettingTableName)
          .update(updates)
          .eq('id', reminderSettingId);

      log(
        'UPDATE REMINDER SETTING SUCCESS: Reminder setting $reminderSettingId updated with $updates.',
        name: 'REMINDER_SETTING_REPO',
      );
    } catch (e, stackTrace) {
      log(
        'UPDATE REMINDER SETTING FAILURE: Failed to update reminder setting $reminderSettingId.',
        error: e,
        stackTrace: stackTrace,
        name: 'REMINDER_SETTING_REPO',
      );
      rethrow;
    }
  }

  Future<void> deleteReminderSetting(String reminderSettingId) async {
    try {
      await _supabaseClient
          .from(_reminderSettingTableName)
          .delete()
          .eq('id', reminderSettingId);

      log(
        'DELETE REMINDER SETTING SUCCESS: Reminder setting $reminderSettingId deleted.',
        name: 'REMINDER_SETTING_REPO',
      );
    } catch (e, stackTrace) {
      log(
        'DELETE REMINDER SETTING FAILURE: Failed to delete reminder setting $reminderSettingId.',
        error: e,
        stackTrace: stackTrace,
        name: 'REMINDER_SETTING_REPO',
      );
      rethrow;
    }
  }

  Future<ReminderSettingModel?> getReminderSettingById(
    String reminderSettingId,
  ) async {
    try {
      final response = await _supabaseClient
          .from(_reminderSettingTableName)
          .select('*')
          .eq('id', reminderSettingId)
          .maybeSingle();

      if (response != null) {
        return ReminderSettingModel.fromJson(response);
      }
      return null;
    } catch (e, stackTrace) {
      log(
        'GET REMINDER SETTING BY ID FAILURE: Failed to fetch reminder setting $reminderSettingId.',
        error: e,
        stackTrace: stackTrace,
        name: 'REMINDER_SETTING_REPO',
      );
      return null;
    }
  }
}
