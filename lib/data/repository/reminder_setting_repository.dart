import 'dart:developer';
import 'package:flutter/material.dart';
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

      // Hapus id jika kosong (untuk create new)
      if (reminderSetting.id.isEmpty) {
        reminderSettingData.remove('id');
      }

      debugPrint('📦 CREATE REMINDER REQUEST DATA: $reminderSettingData');

      final response = await _supabaseClient
          .from(_reminderSettingTableName)
          .insert(reminderSettingData)
          .select()
          .single();

      // DEBUG: Print response untuk troubleshooting
      debugPrint('📦 CREATE REMINDER RESPONSE: $response');
      debugPrint('📦 Response type: ${response.runtimeType}');
      debugPrint('📦 Response keys: ${response.keys}');

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
      debugPrint('📦 FETCHING REMINDERS FOR HABIT: $habitId');

      final response = await _supabaseClient
          .from(_reminderSettingTableName)
          .select('*')
          .eq('habit_id', habitId)
          .order('time', ascending: true);

      // DEBUG: Print response untuk troubleshooting
      debugPrint('📦 FETCH REMINDERS RESPONSE: $response');
      debugPrint('📦 Number of reminders: ${response.length}');

      if (response.isNotEmpty) {
        for (var data in response) {
          debugPrint('📦 Reminder data: $data');
          debugPrint('📦 Reminder id type: ${data['id'].runtimeType}');
        }
      }

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
      debugPrint('📦 UPDATING REMINDER: $reminderSettingId');
      debugPrint('📦 UPDATE DATA: $updates');

      // Hapus field yang tidak perlu untuk update
      final cleanUpdates = Map<String, dynamic>.from(updates);

      // Jangan update id dan created_at
      cleanUpdates.remove('id');
      cleanUpdates.remove('created_at');

      // Pastikan habit_id tidak di-update (harus konsisten)
      if (cleanUpdates.containsKey('habit_id')) {
        debugPrint(
          '⚠️  Warning: habit_id should not be updated in reminder settings',
        );
        cleanUpdates.remove('habit_id');
      }

      // Konversi ID ke int untuk query Supabase
      final intId = int.tryParse(reminderSettingId);
      if (intId == null) {
        throw Exception('Invalid reminder setting ID: $reminderSettingId');
      }

      final response = await _supabaseClient
          .from(_reminderSettingTableName)
          .update(cleanUpdates)
          .eq('id', intId)
          .select(); // Tambahkan select untuk memastikan update berhasil

      debugPrint(
        '✅ UPDATE REMINDER SETTING SUCCESS: Reminder setting $reminderSettingId updated',
      );
      debugPrint('📦 Update response: $response');
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
      debugPrint('📦 DELETING REMINDER: $reminderSettingId');

      // Konversi ID ke int untuk query Supabase
      final intId = int.tryParse(reminderSettingId);
      if (intId == null) {
        throw Exception('Invalid reminder setting ID: $reminderSettingId');
      }

      await _supabaseClient
          .from(_reminderSettingTableName)
          .delete()
          .eq('id', intId);

      debugPrint(
        '✅ DELETE REMINDER SETTING SUCCESS: Reminder setting $reminderSettingId deleted.',
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
      debugPrint('📦 GETTING REMINDER BY ID: $reminderSettingId');

      // Konversi ID ke int untuk query Supabase
      final intId = int.tryParse(reminderSettingId);
      if (intId == null) {
        throw Exception('Invalid reminder setting ID: $reminderSettingId');
      }

      final response = await _supabaseClient
          .from(_reminderSettingTableName)
          .select('*')
          .eq('id', intId)
          .maybeSingle();

      if (response != null) {
        debugPrint('📦 FOUND REMINDER: $response');
        return ReminderSettingModel.fromJson(response);
      }

      debugPrint('📦 REMINDER NOT FOUND FOR ID: $reminderSettingId');
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

  // Method tambahan untuk mendapatkan semua reminder settings
  Future<List<ReminderSettingModel>> fetchAllReminderSettings() async {
    try {
      debugPrint('📦 FETCHING ALL REMINDER SETTINGS');

      final response = await _supabaseClient
          .from(_reminderSettingTableName)
          .select('*')
          .order('habit_id', ascending: true)
          .order('time', ascending: true);

      debugPrint('📦 ALL REMINDERS COUNT: ${response.length}');

      return response
          .map((data) => ReminderSettingModel.fromJson(data))
          .toList();
    } catch (e, stackTrace) {
      log(
        'FETCH ALL REMINDER SETTINGS FAILURE: Failed to fetch all reminder settings.',
        error: e,
        stackTrace: stackTrace,
        name: 'REMINDER_SETTING_REPO',
      );
      rethrow;
    }
  }

  // Method untuk menghapus semua reminder settings untuk habit tertentu
  Future<void> deleteAllReminderSettingsForHabit(int habitId) async {
    try {
      debugPrint('📦 DELETING ALL REMINDERS FOR HABIT: $habitId');

      await _supabaseClient
          .from(_reminderSettingTableName)
          .delete()
          .eq('habit_id', habitId);

      debugPrint(
        '✅ DELETE ALL REMINDERS SUCCESS: All reminders deleted for habit $habitId.',
      );
    } catch (e, stackTrace) {
      log(
        'DELETE ALL REMINDER SETTINGS FAILURE: Failed to delete all reminder settings for habit $habitId.',
        error: e,
        stackTrace: stackTrace,
        name: 'REMINDER_SETTING_REPO',
      );
      rethrow;
    }
  }

  // Method untuk check jika reminder setting sudah ada
  Future<bool> doesReminderSettingExist(int habitId, DateTime time) async {
    try {
      debugPrint(
        '📦 CHECKING IF REMINDER EXISTS FOR HABIT: $habitId AT TIME: $time',
      );

      final response = await _supabaseClient
          .from(_reminderSettingTableName)
          .select('id')
          .eq('habit_id', habitId)
          .eq('time', time.toIso8601String())
          .maybeSingle();

      final exists = response != null;
      debugPrint('📦 REMINDER EXISTS: $exists');

      return exists;
    } catch (e, stackTrace) {
      log(
        'CHECK REMINDER SETTING EXISTENCE FAILURE: Failed to check if reminder setting exists for habit $habitId.',
        error: e,
        stackTrace: stackTrace,
        name: 'REMINDER_SETTING_REPO',
      );
      return false;
    }
  }
}
