// lib/data/services/reminder_sync_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purewill/data/repository/auth_repository.dart';
import 'package:purewill/data/services/auth/auth_service.dart';
import 'package:purewill/data/services/habits/habit_api_service.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/data/services/reminder_api_service.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/reminder_setting_model.dart';

class ReminderSyncService {
  static final ReminderSyncService _instance = ReminderSyncService._internal();
  factory ReminderSyncService() => _instance;
  ReminderSyncService._internal();

  final LocalNotificationService _notificationService =
      LocalNotificationService();
  late final ReminderApiService _reminderApiService;
  late final HabitApiService _habitApiService;
  late final AuthRepository _authRepository;

  StreamSubscription? _reminderSubscription;

  Future<void> initialize() async {
    _reminderApiService = ReminderApiService();
    _habitApiService = HabitApiService();
    _authRepository = AuthRepository(AuthService());

    await _restoreAuthAndSyncTokens();
    await rescheduleAllReminders();
  }

  Future<void> _restoreAuthAndSyncTokens() async {
    try {
      await _authRepository.restoreSession();
      final token = _authRepository.accessToken;
      if (token == null || token.isEmpty) {
        debugPrint('ℹ️ Reminder sync skipped: no stored auth token');
        return;
      }

      _habitApiService.setAccessToken(token);
      _reminderApiService.setAccessToken(token);
      debugPrint('🔐 Reminder sync auth restored');
    } catch (e) {
      debugPrint('⚠️ Failed to restore auth for reminder sync: $e');
    }
  }

  // Reschedule all reminders from database
  Future<void> rescheduleAllReminders() async {
    try {
      debugPrint('🔄 Rescheduling all reminders...');

      // Cancel all existing notifications first
      await _notificationService.cancelAllNotifications();

      final token = _authRepository.accessToken;
      if (token == null || token.isEmpty) {
        debugPrint('ℹ️ No authenticated session; skipping reminder reschedule');
        return;
      }

      final habitsResponse = await _habitApiService.getUserHabits('me');
      final habitsData = habitsResponse['data'];
      final habits = <HabitModel>[];

      if (habitsData is List) {
        for (final item in habitsData) {
          if (item is Map) {
            habits.add(HabitModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      var scheduledCount = 0;
      for (final habit in habits) {
        try {
          final reminders = await _reminderApiService.getHabitReminderSettings(
            habit.id,
          );

          for (final reminderJson in reminders) {
            final reminder = ReminderSettingModel.fromJson(reminderJson);
            if (!reminder.isEnabled) continue;

            final notificationId = _buildNotificationId(
              habitId: habit.id,
              reminderId: reminder.id,
            );

            await _notificationService.scheduleHabitReminder(
              id: notificationId,
              title: 'Habit Reminder: ${habit.name}',
              body: 'Time to complete your habit: ${habit.name}',
              time: reminder.timeOfDay,
              habitId: habit.id.toString(),
              repeatDaily: reminder.repeatDaily,
            );
            scheduledCount++;
          }
        } catch (e) {
          debugPrint(
            '⚠️ Failed to reschedule reminders for habit ${habit.id}: $e',
          );
        }
      }

      debugPrint('✅ Rescheduled $scheduledCount reminder notification(s)');
    } catch (e) {
      debugPrint('❌ Error rescheduling reminders: $e');
    }
  }

  int _buildNotificationId({required int habitId, required String reminderId}) {
    final reminderSeed = reminderId.hashCode.abs() % 10000;
    return habitId * 10000 + reminderSeed;
  }

  // Cleanup
  Future<void> dispose() async {
    await _reminderSubscription?.cancel();
    debugPrint('🛑 Reminder sync service disposed');
  }
}
