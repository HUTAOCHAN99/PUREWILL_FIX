import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/data/repository/reminder_setting_repository.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/reminder_setting_model.dart';
import 'package:purewill/ui/auth/auth_provider.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';

class AddReminderScreen extends ConsumerStatefulWidget {
  final HabitModel habit;

  const AddReminderScreen({super.key, required this.habit});

  @override
  ConsumerState<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends ConsumerState<AddReminderScreen> {
  static const List<int> _snoozeOptions = [5, 10, 15, 30, 60];

  late final ReminderSettingRepository _repository;
  late final LocalNotificationService _notificationService;

  bool _isSaving = false;
  bool _isEnabled = true;
  bool _repeatDaily = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  int _snoozeDuration = 10;
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    final reminderApi = ref.read(reminderApiServiceProvider);
    final token = ref.read(authRepositoryProvider).accessToken;
    if (token != null && token.isNotEmpty) {
      reminderApi.setAccessToken(token);
    }

    _repository = ReminderSettingRepository(apiService: reminderApi);
    _notificationService = LocalNotificationService();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final newReminder = ReminderSettingModel(
        id: '',
        habitId: widget.habit.id,
        isEnabled: _isEnabled,
        time: scheduledDateTime,
        snoozeDuration: _snoozeDuration,
        repeatDaily: _repeatDaily,
        isSoundEnabled: _soundEnabled,
        isVibrationEnabled: _vibrationEnabled,
        createdAt: now,
      );

      await _repository.createReminderSetting(newReminder);

      if (_isEnabled) {
        await _notificationService.cancelHabitNotifications(widget.habit.id);
        await _notificationService.scheduleHabitReminder(
          id: widget.habit.id * 10000 +
              (_selectedTime.hour * 100 + _selectedTime.minute),
          title: 'Habit Reminder: ${widget.habit.name}',
          body: 'Time to complete your habit: ${widget.habit.name}',
          time: _selectedTime,
          habitId: widget.habit.id.toString(),
          repeatDaily: _repeatDaily,
        );
      } else {
        await _notificationService.cancelHabitNotifications(widget.habit.id);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder berhasil ditambahkan')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambah reminder: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Reminder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.habit.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Reminder'),
              value: _isEnabled,
              onChanged: (value) => setState(() => _isEnabled = value),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reminder Time'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _snoozeDuration,
              items: _snoozeOptions
                  .map(
                    (value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value menit'),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _snoozeDuration = value);
              },
              decoration: const InputDecoration(labelText: 'Snooze Duration'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Repeat Daily'),
              value: _repeatDaily,
              onChanged: (value) => setState(() => _repeatDaily = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Sound'),
              value: _soundEnabled,
              onChanged: (value) => setState(() => _soundEnabled = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Vibration'),
              value: _vibrationEnabled,
              onChanged: (value) => setState(() => _vibrationEnabled = value),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
