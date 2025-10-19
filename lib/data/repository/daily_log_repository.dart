import 'dart:developer';
import 'package:purewill/domain/model/daily_log_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DailyLogRepository {
  final SupabaseClient _supabaseClient;
  static const String _logTableName = 'daily_logs';

  DailyLogRepository(this._supabaseClient);

  Future<DailyLogModel> recordLog({
    required int habitId,
    required DateTime date,
    required bool isCompleted,
    double? actualValue,
    String? notes,
  }) async {
    try {
      final logData = {
        'habit_id': habitId,
        'log_date': date.toIso8601String().substring(0, 10),
        'is_completed': isCompleted,
        'actual_value': actualValue,
        'notes': notes,
      };

      final response = await _supabaseClient
          .from(_logTableName)
          .upsert(logData, onConflict: 'habit_id, log_date')
          .select()
          .single();

        return DailyLogModel.fromJson(response);
    } catch (e, stackTrace) {
      log(
        'RECORD LOG FAILURE: Failed to record log for habit $habitId on ${date.toIso8601String().substring(0, 10)}.',
        error: e,
        stackTrace: stackTrace,
        name: 'DAILY_LOG_REPO',
      );
      rethrow;
    }
  }

  Future<List<DailyLogModel>> fetchLogsByHabit(int habitId) async {
    try {
      final response = await _supabaseClient
          .from(_logTableName)
          .select('*')
          .eq('habit_id', habitId)
          .order('log_date', ascending: false);

        return response.map((data) => DailyLogModel.fromJson(data)).toList();
    } catch (e, stackTrace) {
      log(
        'FETCH LOGS FAILURE: Failed to fetch logs for habit $habitId.',
        error: e,
        stackTrace: stackTrace,
        name: 'DAILY_LOG_REPO',
      );
      rethrow;
    }
  }

  Future<List<DailyLogModel>> fetchLogsByDateRange({
    required int habitId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabaseClient
          .from(_logTableName)
          .select('*')
          .eq('habit_id', habitId)
          .gte(
            'log_date',
            startDate.toIso8601String().substring(0, 10),
          ) // Greater Than or Equal
          .lte(
            'log_date',
            endDate.toIso8601String().substring(0, 10),
          ) // Less Than or Equal
          .order('log_date', ascending: true);

        return response.map((data) => DailyLogModel.fromJson(data)).toList();
    } catch (e, stackTrace) {
      log(
        'FETCH LOGS RANGE FAILURE: Failed to fetch logs for habit $habitId in range.',
        error: e,
        stackTrace: stackTrace,
        name: 'DAILY_LOG_REPO',
      );
      rethrow;
    }
  }

  Future<void> deleteLog({required int habitId, required DateTime date}) async {
    try {
      await _supabaseClient
          .from(_logTableName)
          .delete()
          .eq('habit_id', habitId)
          .eq('log_date', date.toIso8601String().substring(0, 10));

      log(
        'DELETE LOG SUCCESS: Log deleted for habit $habitId on ${date.toIso8601String().substring(0, 10)}.',
        name: 'DAILY_LOG_REPO',
      );
    } catch (e, stackTrace) {
      log(
        'DELETE LOG FAILURE: Failed to delete log for habit $habitId.',
        error: e,
        stackTrace: stackTrace,
        name: 'DAILY_LOG_REPO',
      );
      rethrow;
    }
  }
}
