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
    final authService = AuthService();
    _authRepository = AuthRepository(authService);
    _reminderApiService = ReminderApiService(authRepository: _authRepository);
    _habitApiService = HabitApiService(authRepository: _authRepository);

    await _restoreAuthAndSyncTokens();
    // Schedule reschedule as backup (non-blocking) after delay
    // This ensures all dependencies are ready and UI scheduling takes priority
    Future.delayed(const Duration(milliseconds: 500), () {
      rescheduleAllReminders();
    }).ignore();
  }

  Future<void> _restoreAuthAndSyncTokens() async {
    try {
      // Require biometric verification on cold startup before using
      // the refresh endpoint so the app doesn't refresh automatically
      // when reopened while locked.
      await _authRepository.restoreSession(requireBiometric: true);
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

  // Reschedule all reminders from database (backup mechanism only)
  Future<void> rescheduleAllReminders() async {
    try {
      debugPrint('🔄 [BACKUP] Rescheduling all reminders from database...');

      // Cancel all existing notifications first
      await _notificationService.cancelAllNotifications();

      final token = _authRepository.accessToken;
      if (token == null || token.isEmpty) {
        debugPrint('ℹ️ [BACKUP] No auth token; skipping reschedule');
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

      int scheduledCount = 0;
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
            '⚠️ [BACKUP] Failed to reschedule reminders for habit ${habit.id}: $e',
          );
        }
      }

      debugPrint(
        '✅ [BACKUP] Backup rescheduled $scheduledCount notification(s)',
      );
    } catch (e) {
      debugPrint('❌ [BACKUP] Error during backup reschedule: $e');
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
