import 'package:flutter/material.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/reminder_setting_model.dart';
import 'package:purewill/data/repository/reminder_setting_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReminderSettingScreen extends StatefulWidget {
  final HabitModel habit;

  const ReminderSettingScreen({super.key, required this.habit});

  @override
  State<ReminderSettingScreen> createState() => _ReminderSettingScreenState();
}

class _ReminderSettingScreenState extends State<ReminderSettingScreen> {
  late final ReminderSettingRepository _repository;
  late final LocalNotificationService _notificationService;
  late ReminderSettingModel _reminderSetting;
  bool _isLoading = true;
  bool _hasChanges = false;

  // Form state
  final List<int> _snoozeOptions = [10, 30];
  int _selectedSnoozeIndex = 0;
  int _customSnoozeMinutes = 5;
  bool _useCustomSnooze = false;
  
  // Time picker
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  // Notification channels
  bool _pushNotification = true;
  bool _emailNotification = false;
  
  // Advanced settings
  bool _repeatDaily = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  @override
  void initState() {
    super.initState();
    _repository = ReminderSettingRepository(Supabase.instance.client);
    _notificationService = LocalNotificationService();
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    try {
      final settings = await _repository.fetchReminderSettingsByHabit(widget.habit.id);
      
      if (settings.isNotEmpty) {
        _reminderSetting = settings.first;
        _initializeFormFromModel(_reminderSetting);
      } else {
        // Create default reminder setting
        _reminderSetting = ReminderSettingModel(
          id: '',
          habitId: widget.habit.id,
          isEnabled: true,
          time: DateTime.now(),
          snoozeDuration: 10,
          repeatDaily: true,
          isSoundEnabled: true,
          isVibrationEnabled: false,
        );
        _initializeFormFromModel(_reminderSetting);
      }
    } catch (e) {
      // If error, create default setting
      _reminderSetting = ReminderSettingModel(
        id: '',
        habitId: widget.habit.id,
        isEnabled: true,
        time: DateTime.now(),
        snoozeDuration: 10,
        repeatDaily: true,
        isSoundEnabled: true,
        isVibrationEnabled: false,
      );
      _initializeFormFromModel(_reminderSetting);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeFormFromModel(ReminderSettingModel model) {
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

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedSetting = ReminderSettingModel(
        id: _reminderSetting.id,
        habitId: widget.habit.id,
        isEnabled: true,
        time: DateTime.now(), // Waktu tidak terlalu penting untuk notification
        snoozeDuration: _useCustomSnooze 
            ? _customSnoozeMinutes 
            : _snoozeOptions[_selectedSnoozeIndex],
        repeatDaily: _repeatDaily,
        isSoundEnabled: _soundEnabled,
        isVibrationEnabled: _vibrationEnabled,
      );

      // Save to database
      if (_reminderSetting.id.isEmpty) {
        final created = await _repository.createReminderSetting(updatedSetting);
        _reminderSetting = created;
      } else {
        await _repository.updateReminderSetting(
          reminderSettingId: _reminderSetting.id,
          updates: updatedSetting.toJson(),
        );
        _reminderSetting = updatedSetting;
      }

      // Schedule notification jika push notification diaktifkan
      if (_pushNotification) {
        await _scheduleNotification();
      } else {
        // Cancel existing notifications jika push notification dimatikan
        await _notificationService.cancelNotification(widget.habit.id);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved successfully')),
      );

      setState(() {
        _hasChanges = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save settings: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scheduleNotification() async {
    try {
      if (_repeatDaily) {
        // Schedule daily repeating notification
        await _notificationService.scheduleDailyReminder(
          id: widget.habit.id,
          title: 'Habit Reminder: ${widget.habit.name}',
          body: 'Time to complete your habit: ${widget.habit.name}',
          time: _selectedTime,
          habitId: widget.habit.id.toString(),
        );
      } else {
        // Schedule one-time notification
        final now = DateTime.now();
        final scheduledDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );

        await _notificationService.scheduleOneTimeReminder(
          id: widget.habit.id,
          title: 'Habit Reminder: ${widget.habit.name}',
          body: 'Time to complete your habit: ${widget.habit.name}',
          scheduledTime: scheduledDateTime,
          habitId: widget.habit.id.toString(),
        );
      }
      
      debugPrint('Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      // Jangan throw error di sini, biarkan user tetap bisa save settings
    }
  }

  // Method untuk memilih waktu
  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
        _hasChanges = true;
      });
    }
  }

  // Test notification
  Future<void> _testNotification() async {
    try {
      await _notificationService.showTestNotification(widget.habit.name);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test notification sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send test notification: $e')),
      );
    }
  }

  void _onSnoozeOptionChanged(int? index) {
    if (index == null) return;
    
    setState(() {
      _selectedSnoozeIndex = index;
      _useCustomSnooze = false;
      _hasChanges = true;
    });
  }

  void _onCustomSnoozeChanged(String value) {
    final minutes = int.tryParse(value) ?? 5;
    setState(() {
      _customSnoozeMinutes = minutes.clamp(1, 60);
      _useCustomSnooze = true;
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Settings'),
        actions: [
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
          'Get unified about important updates',
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
            // Predefined options
            for (int i = 0; i < _snoozeOptions.length; i++)
              _buildSnoozeOption(
                '${_snoozeOptions[i]} minutes',
                i,
                _selectedSnoozeIndex == i && !_useCustomSnooze,
              ),
            
            // Custom option
            _buildCustomSnoozeOption(),
          ],
        ),
      ],
    );
  }

  Widget _buildSnoozeOption(String text, int index, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: RadioListTile<int>(
          title: Text(text),
          value: index,
          groupValue: _useCustomSnooze ? null : _selectedSnoozeIndex,
          onChanged: _onSnoozeOptionChanged,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
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