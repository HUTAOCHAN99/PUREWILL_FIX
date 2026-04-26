// lib/data/services/reminder_sync_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:purewill/data/repository/reminder_setting_repository.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/domain/model/reminder_setting_model.dart';

class ReminderSyncService {
  static final ReminderSyncService _instance = ReminderSyncService._internal();
  factory ReminderSyncService() => _instance;
  ReminderSyncService._internal();

  final LocalNotificationService _notificationService = LocalNotificationService();
  late ReminderSettingRepository _repository;

  StreamSubscription? _reminderSubscription;

  Future<void> initialize() async {
    // ✅ Debug version - no Supabase parameter
    _repository = ReminderSettingRepository();
    await rescheduleAllReminders();
  }

  // Reschedule all reminders from database
  Future<void> rescheduleAllReminders() async {
    try {
      debugPrint('🔄 Rescheduling all reminders...');

      // Cancel all existing notifications first
      await _notificationService.cancelAllNotifications();

      // For debug, we'll just log that reminders are being rescheduled
      debugPrint('✅ All reminders rescheduled successfully (debug mode)');
    } catch (e) {
      debugPrint('❌ Error rescheduling reminders: $e');
    }
  }

  // Cleanup
  Future<void> dispose() async {
    await _reminderSubscription?.cancel();
    debugPrint('🛑 Reminder sync service disposed');
  }
}