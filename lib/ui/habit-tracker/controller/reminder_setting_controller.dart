import 'package:flutter/material.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/data/services/reminder_sync_service.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/reminder_setting_model.dart';
import 'package:purewill/data/repository/reminder_setting_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReminderSettingController with ChangeNotifier {
  final HabitModel habit;
  final ReminderSettingRepository _repository;
  final LocalNotificationService _notificationService;
  final ReminderSyncService _reminderSyncService;

  ReminderSettingModel? _reminderSetting;
  bool _isLoading = true;
  bool _hasChanges = false;

  // Form state
  final List<int> _snoozeOptions = [5, 10, 15, 30, 60];
  int _selectedSnoozeIndex = 1;
  int _customSnoozeMinutes = 5;
  bool _useCustomSnooze = false;
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _pushNotification = true;
  bool _repeatDaily = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  ReminderSettingController({
    required this.habit,
    required ReminderSettingRepository repository,
    required LocalNotificationService notificationService,
    required ReminderSyncService reminderSyncService,
  })  : _repository = repository,
        _notificationService = notificationService,
        _reminderSyncService = reminderSyncService {
    _initialize();
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get hasChanges => _hasChanges;
  List<int> get snoozeOptions => _snoozeOptions;
  int get selectedSnoozeIndex => _selectedSnoozeIndex;
  int get customSnoozeMinutes => _customSnoozeMinutes;
  bool get useCustomSnooze => _useCustomSnooze;
  TimeOfDay get selectedTime => _selectedTime;
  bool get pushNotification => _pushNotification;
  bool get repeatDaily => _repeatDaily;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  ReminderSettingModel? get reminderSetting => _reminderSetting;

  Future<void> _initialize() async {
    await _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    try {
      final settings = await _repository.fetchReminderSettingsByHabit(habit.id);

      if (settings.isNotEmpty) {
        _reminderSetting = settings.first;
        _initializeFormFromModel(_reminderSetting!);
      } else {
        _reminderSetting = ReminderSettingModel(
          id: '',
          habitId: habit.id,
          isEnabled: true,
          time: DateTime.now(),
          snoozeDuration: 10,
          repeatDaily: true,
          isSoundEnabled: true,
          isVibrationEnabled: true,
          createdAt: DateTime.now(),
        );
        _initializeFormFromModel(_reminderSetting!);
      }
    } catch (e) {
      _reminderSetting = ReminderSettingModel(
        id: '',
        habitId: habit.id,
        isEnabled: true,
        time: DateTime.now(),
        snoozeDuration: 10,
        repeatDaily: true,
        isSoundEnabled: true,
        isVibrationEnabled: true,
        createdAt: DateTime.now(),
      );
      _initializeFormFromModel(_reminderSetting!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _initializeFormFromModel(ReminderSettingModel model) {
    _pushNotification = model.isEnabled;

    final snoozeIndex = _snoozeOptions.indexOf(model.snoozeDuration);
    if (snoozeIndex != -1) {
      _selectedSnoozeIndex = snoozeIndex;
      _useCustomSnooze = false;
    } else {
      _useCustomSnooze = true;
      _customSnoozeMinutes = model.snoozeDuration;
    }

    _selectedTime = TimeOfDay.fromDateTime(model.time);
    _repeatDaily = model.repeatDaily;
    _soundEnabled = model.isSoundEnabled;
    _vibrationEnabled = model.isVibrationEnabled;
  }

  // Setters dengan notifyListeners
  void setSelectedTime(TimeOfDay time) {
    _selectedTime = time;
    _hasChanges = true;
    notifyListeners();
  }

  void setPushNotification(bool value) {
    _pushNotification = value;
    _hasChanges = true;
    notifyListeners();
  }

  void setRepeatDaily(bool value) {
    _repeatDaily = value;
    _hasChanges = true;
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    _hasChanges = true;
    notifyListeners();
  }

  void setVibrationEnabled(bool value) {
    _vibrationEnabled = value;
    _hasChanges = true;
    notifyListeners();
  }

  void setSnoozeOption(int index) {
    _selectedSnoozeIndex = index;
    _useCustomSnooze = false;
    _hasChanges = true;
    notifyListeners();
  }

  void setCustomSnooze(int minutes) {
    _customSnoozeMinutes = minutes.clamp(1, 120);
    _useCustomSnooze = true;
    _hasChanges = true;
    notifyListeners();
  }

  void setUseCustomSnooze(bool value) {
    _useCustomSnooze = value;
    _hasChanges = true;
    notifyListeners();
  }

  // Business logic methods
  Future<void> saveSettings() async {
    if (habit.id <= 0) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snoozeDuration = _useCustomSnooze
          ? _customSnoozeMinutes
          : _snoozeOptions[_selectedSnoozeIndex];

      final now = DateTime.now().toUtc();
      final scheduledDateTime = DateTime.utc(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await _updateHabitReminderSettings(_pushNotification);

      final updateData = <String, dynamic>{
        'is_enabled': _pushNotification,
        'time': scheduledDateTime.toIso8601String(),
        'snooze_duration': snoozeDuration,
        'repeat_daily': _repeatDaily,
        'is_sound_enabled': _soundEnabled,
        'is_vibration_enabled': _vibrationEnabled,
      };

      if (_reminderSetting!.id.isEmpty) {
        final newReminder = ReminderSettingModel(
          id: '',
          habitId: habit.id,
          isEnabled: _pushNotification,
          time: scheduledDateTime,
          snoozeDuration: snoozeDuration,
          repeatDaily: _repeatDaily,
          isSoundEnabled: _soundEnabled,
          isVibrationEnabled: _vibrationEnabled,
          createdAt: DateTime.now().toUtc(),
        );

        _reminderSetting = await _repository.createReminderSetting(newReminder);
      } else {
        await _repository.updateReminderSetting(
          reminderSettingId: _reminderSetting!.id,
          updates: updateData,
        );
      }

      if (_pushNotification) {
        await _scheduleNotification();
      } else {
        await _notificationService.cancelHabitNotifications(habit.id);
      }

      await _reminderSyncService.rescheduleAllReminders();
      await checkPendingNotifications(); // Fixed: changed from _checkPendingNotifications

      _hasChanges = false;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateHabitReminderSettings(bool reminderEnabled) async {
    final timeString =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';

    await Supabase.instance.client
        .from('habits')
        .update({
          'reminder_enabled': reminderEnabled,
          'reminder_time': timeString,
        })
        .eq('id', habit.id);
  }

  Future<void> _scheduleNotification() async {
    await _notificationService.cancelHabitNotifications(habit.id);

    await _notificationService.scheduleAdaptiveReminder(
      id: habit.id,
      title: 'Habit Reminder: ${habit.name}',
      body: 'Time to complete your habit: ${habit.name}',
      time: _selectedTime,
      habitId: habit.id.toString(),
      repeatDaily: _repeatDaily,
    );
  }

  Future<void> testNotification() async {
    await _notificationService.showTestNotification(habit.name);
  }

  Future<void> checkPendingNotifications() async {
    await _notificationService.getPendingNotifications();
  }

  Future<void> checkPermissions() async {
    await _notificationService.checkPermissions();
  }

  String getTimeString(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void debugCurrentState() {
    // Tetap menggunakan debugPrint untuk debugging
    debugPrint('🎯 === CURRENT STATE DEBUG ===');
    debugPrint('   Habit ID: ${habit.id}');
    debugPrint('   Habit Name: ${habit.name}');
    debugPrint('   Selected Time: ${getTimeString(_selectedTime)}');
    debugPrint('   Push Notification: $_pushNotification');
    debugPrint('   Repeat Daily: $_repeatDaily');
    debugPrint(
      '   Snooze: ${_useCustomSnooze ? _customSnoozeMinutes : _snoozeOptions[_selectedSnoozeIndex]}min',
    );
    debugPrint('   Sound: $_soundEnabled, Vibration: $_vibrationEnabled');
    debugPrint('   ReminderSetting ID: ${_reminderSetting?.id}');
    debugPrint('   Has Changes: $_hasChanges');
    debugPrint('🎯 === STATE DEBUG COMPLETE ===');
  }
}