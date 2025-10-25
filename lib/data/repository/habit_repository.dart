import 'dart:developer';
import 'package:purewill/data/services/default_habits_service.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HabitRepository {
  final SupabaseClient _supabaseClient;
  static const String _habitTableName = 'habits';

  HabitRepository(this._supabaseClient);

  Future<HabitModel> createHabit(HabitModel habit) async {
    try {
      final habitData = habit.toJson();

      print('=== HABIT DATA TO INSERT ===');
      print(habitData);
      print('===========================');

      final response = await _supabaseClient
          .from(_habitTableName)
          .insert(habitData)
          .select()
          .single();

      print('=== HABIT CREATED SUCCESS ===');
      print(response);
      print('===========================');

      return HabitModel.fromJson(response);
    } catch (e, stackTrace) {
      print('=== HABIT CREATION ERROR ===');
      print('Error: $e');
      print('Stack: $stackTrace');
      print('===========================');

      log(
        'CREATE HABIT FAILURE: Failed to create habit ${habit.name}.',
        error: e,
        stackTrace: stackTrace,
        name: 'HABIT_REPO',
      );
      rethrow;
    }
  }

  Future<List<HabitModel>> fetchUserHabits(String userId) async {
    try {
      // Ambil habits dari database
      final response = await _supabaseClient
          .from(_habitTableName)
          .select('*')
          .eq('user_id', userId)
          .order('start_date', ascending: true);

      final userHabits = response.map((data) => HabitModel.fromJson(data)).toList();

      // Gabungkan dengan default habits
      final defaultHabits = DefaultHabitsService.getDefaultHabits();
      
      // Filter default habits yang belum dibuat oleh user
      final userHabitNames = userHabits.map((h) => h.name).toSet();
      final availableDefaultHabits = defaultHabits
          .where((defaultHabit) => !userHabitNames.contains(defaultHabit.name))
          .toList();

      // Gabungkan user habits dengan available default habits
      final allHabits = [...userHabits, ...availableDefaultHabits];

      print('=== COMBINED HABITS ===');
      print('User habits: ${userHabits.length}');
      print('Available default habits: ${availableDefaultHabits.length}');
      print('Total habits: ${allHabits.length}');
      print('========================');

      return allHabits;
    } catch (e, stackTrace) {
      log(
        'FETCH HABITS FAILURE: Failed to fetch habits for user $userId.',
        error: e,
        stackTrace: stackTrace,
        name: 'HABIT_REPO',
      );
      
      // Fallback: return default habits jika error
      print('=== USING DEFAULT HABITS AS FALLBACK ===');
      return DefaultHabitsService.getDefaultHabits();
    }
  }

  // Hapus method updateHabitStatus atau perbaiki
  Future<void> updateHabitStatus({
    required int habitId,
    required bool isActive, // Ganti dengan isActive
  }) async {
    try {
      await _supabaseClient
          .from(_habitTableName)
          .update({'is_active': isActive})
          .eq('id', habitId);

      log(
        'UPDATE HABIT STATUS SUCCESS: Habit $habitId updated.',
        name: 'HABIT_REPO',
      );
    } catch (e, stackTrace) {
      log(
        'UPDATE HABIT FAILURE: Failed to update status for habit $habitId.',
        error: e,
        stackTrace: stackTrace,
        name: 'HABIT_REPO',
      );
      rethrow;
    }
  }

  Future<void> deleteHabit(int habitId) async {
    try {
      await _supabaseClient.from(_habitTableName).delete().eq('id', habitId);

      log('DELETE HABIT SUCCESS: Habit $habitId deleted.', name: 'HABIT_REPO');
    } catch (e, stackTrace) {
      log(
        'DELETE HABIT FAILURE: Failed to delete habit $habitId.',
        error: e,
        stackTrace: stackTrace,
        name: 'HABIT_REPO',
      );
      rethrow;
    }
  }
}
