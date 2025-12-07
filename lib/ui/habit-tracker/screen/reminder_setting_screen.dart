import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/reminder_setting_model.dart';
import 'package:purewill/data/repository/reminder_setting_repository.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';

class ReminderSettingScreen extends ConsumerStatefulWidget {
  final HabitModel habit;
  final ReminderSettingModel? reminderSetting;
  const ReminderSettingScreen({super.key, required this.habit, this.reminderSetting});
  @override
  ConsumerState<ReminderSettingScreen> createState() => _ReminderSettingScreenState();
}

class _ReminderSettingScreenState extends ConsumerState<ReminderSettingScreen> {
  late final ReminderSettingRepository _repository;
  late final LocalNotificationService _notificationService;
  bool _isLoading = true;
  bool _hasChanges = false;

  final List<int> _snoozeOptions = [10, 30];
  int _selectedSnoozeIndex = 0;
  int _customSnoozeMinutes = 5;
  bool _useCustomSnooze = false;
  
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  bool _pushNotification = true;
  bool _emailNotification = false;
  
  bool _repeatDaily = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  @override
  void initState() {
    super.initState();
    
    _notificationService = LocalNotificationService();
    if (widget.reminderSetting != null) {
      _initializeFormFromModel(widget.reminderSetting!);
      _isLoading = false;
    } else {
      // If no existing setting, create a default one
      final reminderSetting = ReminderSettingModel(
        id: '',
        habitId: widget.habit.id,
        isEnabled: true,
        time: DateTime.now(),
        snoozeDuration: 10,
        repeatDaily: true,
        isSoundEnabled: true,
        isVibrationEnabled: false,
      );
      _initializeFormFromModel(reminderSetting);
      _isLoading = false;
    }
  }

  void _initializeFormFromModel(ReminderSettingModel model) {
    debugPrint('🎛️ === INITIALIZING FORM FROM MODEL ===');
    debugPrint('⏰ Model time: ${model.time}');
    debugPrint('🔔 Model snooze: ${model.snoozeDuration}');
    
    final snoozeIndex = _snoozeOptions.indexOf(model.snoozeDuration);
    if (snoozeIndex != -1) {
      _selectedSnoozeIndex = snoozeIndex;
      _useCustomSnooze = false;
      debugPrint('🔔 Using predefined snooze: ${_snoozeOptions[_selectedSnoozeIndex]}min');
    } else {
      _useCustomSnooze = true;
      _customSnoozeMinutes = model.snoozeDuration;
      debugPrint('🔔 Using custom snooze: ${_customSnoozeMinutes}min');
    }
    
    _selectedTime = TimeOfDay.fromDateTime(model.time);
    _repeatDaily = model.repeatDaily;
    _soundEnabled = model.isSoundEnabled;
    _vibrationEnabled = model.isVibrationEnabled;
    
    debugPrint('🎛️ === FORM INITIALIZATION COMPLETE ===');
  }

  Future<void> _saveSettings() async {
    debugPrint('💾 === SAVE SETTINGS START ===');
    debugPrint('🔍 Habit ID sebelum save: ${widget.habit.id}');
    debugPrint('🔍 ReminderSetting ID: ${widget.reminderSetting!.id}');
    
    // 🚨 VALIDASI KRITIS
    if (widget.habit.id <= 0) {
      debugPrint('❌ CRITICAL ERROR: Invalid habit ID: ${widget.habit.id}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ ERROR: Invalid habit data. Please save habit first.')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final snoozeDuration = _useCustomSnooze 
          ? _customSnoozeMinutes 
          : _snoozeOptions[_selectedSnoozeIndex];

      // Create DateTime with selected time
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final updatedSetting = ReminderSettingModel(
        id: widget.reminderSetting!.id,
        habitId: widget.habit.id,
        isEnabled: true,
        time: scheduledDateTime,
        snoozeDuration: snoozeDuration,
        repeatDaily: _repeatDaily,
        isSoundEnabled: _soundEnabled,
        isVibrationEnabled: _vibrationEnabled,
      );

      debugPrint('📦 ReminderSetting to save:');
      debugPrint('   - Habit ID: ${updatedSetting.habitId}');
      debugPrint('   - Time: ${updatedSetting.time}');
      debugPrint('   - Snooze: ${updatedSetting.snoozeDuration}min');
      debugPrint('   - Repeat Daily: ${updatedSetting.repeatDaily}');

  
      await ref.read(habitNotifierProvider.notifier).saveReminderSetting(habitId: updatedSetting.habitId, isEnabled: updatedSetting.isEnabled, time: updatedSetting.time, snoozeDuration: snoozeDuration, repeatDaily: updatedSetting.repeatDaily, isSoundEnabled: updatedSetting.isSoundEnabled, isVibrationEnabled: updatedSetting.isVibrationEnabled);

      // Schedule notification jika push notification diaktifkan
      if (_pushNotification) {
        debugPrint('🔔 Scheduling notification...');
        await _scheduleNotification();
      } else {
        // Cancel existing notifications jika push notification dimatikan
        debugPrint('🔕 Cancelling notifications...');
        await _notificationService.cancelNotification(widget.habit.id);
      }

      // Check pending notifications for debugging
      await _checkPendingNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Settings saved successfully!')),
        );
      }

      setState(() {
        _hasChanges = false;
      });
      
      debugPrint('💾 === SAVE SETTINGS SUCCESS ===');
    } catch (e, stackTrace) {
      debugPrint('❌ SAVE SETTINGS ERROR: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to save settings: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _scheduleNotification() async {
    try {
      debugPrint('⏰ === SCHEDULING NOTIFICATION ===');
      debugPrint('   - Habit: ${widget.habit.name}');
      debugPrint('   - Time: ${_selectedTime.format(context)}');
      debugPrint('   - Repeat: $_repeatDaily');
      
      if (_repeatDaily) {
        // Schedule daily repeating notification
        await _notificationService.scheduleDailyReminder(
          id: widget.habit.id,
          title: 'Habit Reminder: ${widget.habit.name}',
          body: 'Time to complete your habit: ${widget.habit.name}',
          time: _selectedTime,
          habitId: widget.habit.id.toString(),
        );
        debugPrint('🔁 Daily notification scheduled');
      } else {
        // Schedule one-time notification
        final now = DateTime.now();
        DateTime scheduledDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        // Jika waktu sudah lewat hari ini, jadwalkan untuk besok
        if (scheduledDateTime.isBefore(now)) {
          scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
          debugPrint('⏩ Time passed, scheduling for tomorrow');
        }

        await _notificationService.scheduleOneTimeReminder(
          id: widget.habit.id,
          title: 'Habit Reminder: ${widget.habit.name}',
          body: 'Time to complete your habit: ${widget.habit.name}',
          scheduledTime: scheduledDateTime,
          habitId: widget.habit.id.toString(),
        );
        debugPrint('⏰ One-time notification scheduled');
      }
      
      debugPrint('✅ Notification scheduled successfully for ${_selectedTime.format(context)}');
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR scheduling notification: $e');
      debugPrint('📋 StackTrace: $stackTrace');
    }
  }

  // Method untuk memilih waktu
  Future<void> _selectTime() async {
    debugPrint('🕒 Opening time picker...');
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (pickedTime != null && pickedTime != _selectedTime) {
      debugPrint('🕒 Time selected: ${pickedTime.format(context)}');
      setState(() {
        _selectedTime = pickedTime;
        _hasChanges = true;
      });
    } else {
      debugPrint('🕒 Time picker cancelled');
    }
  }

  // Test notification
  Future<void> _testNotification() async {
    debugPrint('🧪 Testing notification...');
    try {
      await _notificationService.showTestNotification(widget.habit.name);
      debugPrint('✅ Test notification sent');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Test notification sent!')),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Test notification failed: $e');
      debugPrint('📋 StackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to send test notification: $e')),
        );
      }
    }
  }

  // Check pending notifications for debugging
  Future<void> _checkPendingNotifications() async {
    try {
      debugPrint('📋 === CHECKING PENDING NOTIFICATIONS ===');
      final pending = await _notificationService.getPendingNotifications();
      debugPrint('   Total pending: ${pending.length}');
      for (var notif in pending) {
        debugPrint('   - ID: ${notif.id}, Title: ${notif.title}');
      }
      debugPrint('📋 === PENDING NOTIFICATIONS CHECK COMPLETE ===');
    } catch (e) {
      debugPrint('❌ Error checking pending notifications: $e');
    }
  }

  void _onSnoozeOptionChanged(int? index) {
    if (index == null) return;
    
    debugPrint('🔔 Snooze option changed to index: $index');
    setState(() {
      _selectedSnoozeIndex = index;
      _useCustomSnooze = false;
      _hasChanges = true;
    });
  }

  void _onCustomSnoozeChanged(String value) {
    final minutes = int.tryParse(value) ?? 5;
    debugPrint('🔔 Custom snooze changed to: $minutes minutes');
    setState(() {
      _customSnoozeMinutes = minutes.clamp(1, 60);
      _useCustomSnooze = true;
      _hasChanges = true;
    });
  }

  // 🎯 DEBUG METHOD: Print semua state
  void _debugCurrentState() {
    debugPrint('🎯 === CURRENT STATE DEBUG ===');
    debugPrint('   Habit ID: ${widget.habit.id}');
    debugPrint('   Selected Time: ${_selectedTime.format(context)}');
    debugPrint('   Push Notification: $_pushNotification');
    debugPrint('   Repeat Daily: $_repeatDaily');
    debugPrint('   Snooze: ${_useCustomSnooze ? _customSnoozeMinutes : _snoozeOptions[_selectedSnoozeIndex]}min');
    debugPrint('   Sound: $_soundEnabled, Vibration: $_vibrationEnabled');
    debugPrint('🎯 === STATE DEBUG COMPLETE ===');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Settings'),
        actions: [
          // 🎯 DEBUG BUTTON
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _debugCurrentState,
            tooltip: 'Debug State',
          ),
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveSettings,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎯 HABIT INFO DEBUG CARD (SIMPLE VERSION)
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🔍 Current Habit:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text('ID: ${widget.habit.id}'),
                          Text('Name: "${widget.habit.name}"'),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Reminders Section
                  _buildRemindersSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Notification Time Section
                  _buildNotificationTimeSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Notification Channel Section
                  _buildNotificationChannelSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Advanced Settings Section
                  _buildAdvancedSettingsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Test Button
                  _buildTestButton(),

                  // Debug Button
                  _buildDebugButton(),
                  
                  const SizedBox(height: 16),
                  
                  // Save Button
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildRemindersSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Get notified about important updates',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Time Picker
        ListTile(
          leading: const Icon(Icons.access_time),
          title: const Text('Reminder Time'),
          subtitle: Text(_selectedTime.format(context)),
          onTap: _selectTime,
          trailing: const Icon(Icons.arrow_drop_down),
        ),
        
        const SizedBox(height: 16),
        
        // Snooze Options
        const Text(
          'Snooze Options',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        
        Column(
          children: [
            for (int i = 0; i < _snoozeOptions.length; i++)
              _buildSnoozeOption(
                '${_snoozeOptions[i]} minutes',
                i,
              ),
            _buildCustomSnoozeOption(),
          ],
        ),
      ],
    );
  }

  Widget _buildSnoozeOption(String text, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: (_selectedSnoozeIndex == index && !_useCustomSnooze) 
                ? Colors.blue 
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: RadioListTile<int>(
          title: Text(text),
          value: index,
          groupValue: _useCustomSnooze ? null : _selectedSnoozeIndex,
          onChanged: (value) => _onSnoozeOptionChanged(value),
        ),
      ),
    );
  }

  Widget _buildCustomSnoozeOption() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _useCustomSnooze ? Colors.blue : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<int>(
        title: Row(
          children: [
            const Text('Custom'),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: TextField(
                controller: TextEditingController(
                  text: _customSnoozeMinutes.toString(),
                ),
                onChanged: _onCustomSnoozeChanged,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '5 min',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ],
        ),
        value: -1,
        groupValue: _useCustomSnooze ? -1 : null,
        onChanged: (value) {
          setState(() {
            _useCustomSnooze = true;
            _hasChanges = true;
          });
        },
      ),
    );
  }

  Widget _buildNotificationChannelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Channel',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Column(
          children: [
            CheckboxListTile(
              title: const Text('Push Notification'),
              value: _pushNotification,
              onChanged: (value) {
                setState(() {
                  _pushNotification = value ?? false;
                  _hasChanges = true;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Email'),
              value: _emailNotification,
              onChanged: (value) {
                setState(() {
                  _emailNotification = value ?? false;
                  _hasChanges = true;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Both'),
              value: _pushNotification && _emailNotification,
              onChanged: (value) {
                setState(() {
                  final newValue = value ?? false;
                  _pushNotification = newValue;
                  _emailNotification = newValue;
                  _hasChanges = true;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Advanced Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Column(
          children: [
            CheckboxListTile(
              title: const Text('Repeat Daily'),
              value: _repeatDaily,
              onChanged: (value) {
                setState(() {
                  _repeatDaily = value ?? true;
                  _hasChanges = true;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Sound'),
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value ?? true;
                  _hasChanges = true;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Vibration'),
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value ?? false;
                  _hasChanges = true;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _testNotification,
        icon: const Icon(Icons.notifications_active),
        label: const Text('Test Notification'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildDebugButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _checkPendingNotifications,
            icon: const Icon(Icons.bug_report),
            label: const Text('Check Pending Notifications'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _debugCurrentState,
            icon: const Icon(Icons.info),
            label: const Text('Debug Current State'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Save Settings',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }
}