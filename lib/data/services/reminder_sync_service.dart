import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purewill/data/repository/reminder_setting_repository.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/domain/model/reminder_setting_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReminderSyncService {
  static final ReminderSyncService _instance = ReminderSyncService._internal();
  factory ReminderSyncService() => _instance;
  ReminderSyncService._internal();

  final LocalNotificationService _notificationService =
      LocalNotificationService();
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  late ReminderSettingRepository _repository;

  StreamSubscription? _reminderSubscription;
  Timer? _syncTimer;

  Future<void> initialize() async {
    _repository = ReminderSettingRepository(_supabaseClient);
    await _setupRealtimeSubscription();
    await _startPeriodicSync();
    await rescheduleAllReminders(); // Changed from _rescheduleAllReminders to public
  }

  // Setup realtime subscription untuk perubahan reminder
  Future<void> _setupRealtimeSubscription() async {
    try {
      _reminderSubscription = _supabaseClient
          .from('reminder_settings')
          .stream(primaryKey: ['id'])
          .listen((event) {
            debugPrint('🔄 Realtime update received for reminders');
            _handleReminderUpdates(event);
          });

      debugPrint('✅ Realtime subscription for reminders started');
    } catch (e) {
      debugPrint('❌ Failed to setup realtime subscription: $e');
    }
  }

  void _handleReminderUpdates(List<Map<String, dynamic>> updates) {
    for (final update in updates) {
      final eventType = update['type'] ?? 'UPDATE';
      final record = update['new'] ?? update['old'];

      if (record != null) {
        final reminder = ReminderSettingModel.fromJson(record);

        switch (eventType) {
          case 'INSERT':
            _scheduleReminderNotification(reminder);
            break;
          case 'UPDATE':
            _updateScheduledReminder(reminder);
            break;
          case 'DELETE':
            _cancelReminderNotification(reminder);
            break;
        }
      }
    }
  }

  // Sinkronisasi periodik setiap 30 menit
  Future<void> _startPeriodicSync() async {
    _syncTimer = Timer.periodic(const Duration(minutes: 30), (timer) async {
      await rescheduleAllReminders();
    });
  }

  // Reschedule semua reminder dari database (PUBLIC METHOD)
  Future<void> rescheduleAllReminders() async {
    try {
      debugPrint('🔄 Rescheduling all reminders from database...');

      // Cancel semua notifikasi yang ada
      await _notificationService.cancelAllNotifications();

      // Ambil semua habit yang aktif dengan reminder enabled
      final habitsResponse = await _supabaseClient
          .from('habits')
          .select('id, name, reminder_enabled, reminder_time')
          .eq('is_active', true)
          .eq('reminder_enabled', true);

      for (final habit in habitsResponse) {
        final habitId = habit['id'] as int;
        final habitName = habit['name'] as String;

        // Ambil reminder settings untuk habit ini
        final reminders = await _repository.fetchReminderSettingsByHabit(
          habitId,
        );

        for (final reminder in reminders) {
          if (reminder.isEnabled) {
            await _scheduleReminderNotification(reminder, habitName: habitName);
          }
        }
      }

      debugPrint('✅ All reminders rescheduled successfully');
    } catch (e) {
      debugPrint('❌ Error rescheduling reminders: $e');
    }
  }

  // Schedule notifikasi untuk reminder
  // Di method _scheduleReminderNotification, ganti dengan:
  Future<void> _scheduleReminderNotification(
    ReminderSettingModel reminder, {
    String? habitName,
  }) async {
    try {
      if (!reminder.isEnabled) return;

      // Jika habitName tidak provided, fetch dari database
      String finalHabitName = habitName ?? '';
      if (finalHabitName.isEmpty) {
        final habitResponse = await _supabaseClient
            .from('habits')
            .select('name')
            .eq('id', reminder.habitId)
            .single();
        finalHabitName = habitResponse['name'] as String;
      }

      final time = TimeOfDay.fromDateTime(reminder.time);
      final notificationId = _generateNotificationId(reminder);

      // Gunakan adaptive scheduling
      await _notificationService.scheduleAdaptiveReminder(
        id: notificationId,
        title: 'Habit Reminder: $finalHabitName',
        body: 'Time to complete your habit!',
        time: time,
        habitId: reminder.habitId.toString(),
        repeatDaily: reminder.repeatDaily,
      );

      debugPrint(
        '✅ Adaptive reminder scheduled: $finalHabitName at ${_formatTime(time)}',
      );
    } catch (e) {
      debugPrint('❌ Error scheduling reminder: $e');
    }
  }

  // Helper method untuk mendapatkan context
  String _formatTime(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12
        ? hour - 12
        : hour == 0
        ? 12
        : hour;
    return '$displayHour:$minute $period';
  }

  // Update scheduled reminder
  Future<void> _updateScheduledReminder(ReminderSettingModel reminder) async {
    try {
      // Cancel existing notification
      await _cancelReminderNotification(reminder);

      // Schedule new notification jika enabled
      if (reminder.isEnabled) {
        await _scheduleReminderNotification(reminder);
      }

      debugPrint('✅ Reminder updated for habit ${reminder.habitId}');
    } catch (e) {
      debugPrint('❌ Error updating reminder: $e');
    }
  }

  // Cancel reminder notification
  Future<void> _cancelReminderNotification(
    ReminderSettingModel reminder,
  ) async {
    try {
      final notificationId = _generateNotificationId(reminder);
      await _notificationService.cancelNotification(notificationId);
      debugPrint('✅ Reminder cancelled: $notificationId');
    } catch (e) {
      debugPrint('❌ Error cancelling reminder: $e');
    }
  }

  // Generate unique notification ID dari reminder
  int _generateNotificationId(ReminderSettingModel reminder) {
    return reminder.id.hashCode & 0x7FFFFFFF; // Positive integer
  }

  // Cleanup resources
  Future<void> dispose() async {
    await _reminderSubscription?.cancel();
    _syncTimer?.cancel();
    debugPrint('🛑 Reminder sync service disposed');
  }
}
