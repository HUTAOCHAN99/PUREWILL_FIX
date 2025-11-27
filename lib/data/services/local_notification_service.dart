import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  Function(String?)? _onNotificationTap;

  Future<void> initialize({Function(String?)? onNotificationTap}) async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    _onNotificationTap = onNotificationTap;
    
    // Initialize timezone
    tz.initializeTimeZones();

    // Android settings
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Linux settings
    const LinuxInitializationSettings linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    // Initialization settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
        _onNotificationTap?.call(response.payload);
      },
    );

    // Request permissions untuk iOS
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final iOSPlatform = _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iOSPlatform?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Schedule daily reminder dengan fallback untuk Android 14+
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required String habitId,
  }) async {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // Jika waktu sudah lewat hari ini, schedule untuk besok
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Android notification details
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'daily_habit_channel',
        'Daily Habit Reminders',
        channelDescription: 'Daily reminders for your habits',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
        badgeNumber: 1,
      );

      // Linux notification details
      const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        linux: linuxDetails,
      );

      // Coba schedule dengan exact alarm terlebih dahulu
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: habitId,
        );
        debugPrint('✅ Daily notification scheduled with exact alarm (ID: $id)');
      } catch (e) {
        // Fallback ke inexact alarm jika exact alarm tidak diizinkan
        debugPrint('⚠️ Exact alarm not permitted, falling back to inexact alarm: $e');
        
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: habitId,
        );
        debugPrint('✅ Daily notification scheduled with inexact alarm (ID: $id)');
      }

    } catch (e, stackTrace) {
      debugPrint('❌ Error scheduling daily notification: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Schedule one-time reminder dengan fallback
  Future<void> scheduleOneTimeReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String habitId,
  }) async {
    try {
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'one_time_habit_channel', 
        'One-time Habit Reminders',
        channelDescription: 'One-time reminders for your habits',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
      );

      const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        linux: linuxDetails,
      );

      // Coba schedule dengan exact alarm terlebih dahulu
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: habitId,
        );
        debugPrint('✅ One-time notification scheduled with exact alarm (ID: $id)');
      } catch (e) {
        // Fallback ke inexact alarm jika exact alarm tidak diizinkan
        debugPrint('⚠️ Exact alarm not permitted, falling back to inexact alarm: $e');
        
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: habitId,
        );
        debugPrint('✅ One-time notification scheduled with inexact alarm (ID: $id)');
      }

    } catch (e, stackTrace) {
      debugPrint('❌ Error scheduling one-time notification: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      debugPrint('✅ Notification $id cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling notification $id: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint('✅ All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Error cancelling all notifications: $e');
    }
  }

  // Test notification - untuk debugging
  Future<void> showTestNotification(String habitName) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel_id',
        'Test Notifications',
        channelDescription: 'Channel for test notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
      );

      const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails();

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        linux: linuxDetails,
      );

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _notificationsPlugin.show(
        notificationId,
        'Habit Reminder: $habitName',
        'Time to complete your habit!',
        notificationDetails,
        payload: 'test_$habitName',
      );

      debugPrint('✅ Test notification shown for $habitName (ID: $notificationId)');
    } catch (e, stackTrace) {
      debugPrint('❌ Error showing test notification: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // Check pending notifications (untuk debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pending = await _notificationsPlugin.pendingNotificationRequests();
      debugPrint('📋 Found ${pending.length} pending notifications');
      return pending;
    } catch (e) {
      debugPrint('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  // Method untuk handle notification tap
  void setOnNotificationTap(Function(String?) onTap) {
    _onNotificationTap = onTap;
  }

  // Method untuk check notification permissions
  Future<bool> checkPermissions() async {
    try {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final iOSPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      bool hasPermission = false;

      if (androidPlugin != null) {
        // Untuk Android, permissions biasanya sudah diberikan
        hasPermission = true;
      } else if (iOSPlugin != null) {
        final result = await iOSPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        hasPermission = result ?? false;
      }
      
      return hasPermission;
    } catch (e) {
      debugPrint('❌ Error checking permissions: $e');
      return false;
    }
  }

  // Check if exact alarms are permitted (Android 14+)
  Future<bool> canScheduleExactAlarms() async {
    try {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        // Coba schedule test notification dengan exact alarm
        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'test_exact_alarm_channel',
          'Test Exact Alarm',
          channelDescription: 'Channel for testing exact alarm permission',
          importance: Importance.high,
          priority: Priority.high,
        );

        const NotificationDetails notificationDetails = NotificationDetails(
          android: androidDetails,
        );

        final testTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
        
        try {
          await _notificationsPlugin.zonedSchedule(
            999999, // ID khusus untuk test
            'Test Exact Alarm',
            'Testing exact alarm permission',
            testTime,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
          
          // Cancel test notification
          await cancelNotification(999999);
          return true;
        } catch (e) {
          debugPrint('⚠️ Exact alarms not permitted: $e');
          return false;
        }
      }
      
      return true; // Untuk non-Android, assume permitted
    } catch (e) {
      debugPrint('❌ Error checking exact alarm permission: $e');
      return false;
    }
  }

  // Schedule dengan adaptive method berdasarkan permission
  Future<void> scheduleAdaptiveReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required String habitId,
    required bool repeatDaily,
  }) async {
    try {
      final canUseExactAlarm = await canScheduleExactAlarms();
      final androidScheduleMode = canUseExactAlarm 
          ? AndroidScheduleMode.exactAllowWhileIdle 
          : AndroidScheduleMode.inexactAllowWhileIdle;

      debugPrint('🎯 Using schedule mode: $androidScheduleMode');

      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // Jika waktu sudah lewat hari ini, schedule untuk besok
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'adaptive_habit_channel',
        'Habit Reminders',
        channelDescription: 'Adaptive reminders for your habits',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        sound: 'default',
        badgeNumber: 1,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      if (repeatDaily) {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: androidScheduleMode,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: habitId,
        );
        debugPrint('✅ Adaptive daily notification scheduled (Mode: $androidScheduleMode, ID: $id)');
      } else {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: androidScheduleMode,
          payload: habitId,
        );
        debugPrint('✅ Adaptive one-time notification scheduled (Mode: $androidScheduleMode, ID: $id)');
      }

    } catch (e, stackTrace) {
      debugPrint('❌ Error scheduling adaptive notification: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get notification channels (Android)
  Future<void> getNotificationChannels() async {
    try {
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final channels = await androidPlugin.getNotificationChannels();
        debugPrint('📱 Notification channels: ${channels?.length}');
        for (final channel in channels!) {
          debugPrint('   - ${channel.id}: ${channel.name}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error getting notification channels: $e');
    }
  }

  // Schedule multiple reminders for different times
  Future<void> scheduleMultipleReminders({
    required int baseId,
    required String title,
    required String body,
    required List<TimeOfDay> times,
    required String habitId,
  }) async {
    try {
      for (int i = 0; i < times.length; i++) {
        await scheduleAdaptiveReminder(
          id: baseId + i,
          title: title,
          body: body,
          time: times[i],
          habitId: habitId,
          repeatDaily: true,
        );
      }
      debugPrint('✅ ${times.length} adaptive reminders scheduled for habit $habitId');
    } catch (e, stackTrace) {
      debugPrint('❌ Error scheduling multiple reminders: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Cancel notifications for specific habit
  Future<void> cancelHabitNotifications(int habitId) async {
    try {
      final pending = await getPendingNotifications();
      int cancelledCount = 0;
      
      for (final notification in pending) {
        if (notification.payload == habitId.toString()) {
          await cancelNotification(notification.id);
          cancelledCount++;
        }
      }
      
      debugPrint('✅ Cancelled $cancelledCount notifications for habit $habitId');
    } catch (e) {
      debugPrint('❌ Error cancelling habit notifications: $e');
    }
  }
}