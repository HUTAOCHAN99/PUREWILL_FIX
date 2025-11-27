import 'package:flutter/material.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/data/services/reminder_sync_service.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/data/repository/reminder_setting_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import components dan controller
import '../controller/reminder_setting_controller.dart';
import '../components/reminder_setting_components.dart' as components;

class ReminderSettingScreen extends StatefulWidget {
  final HabitModel habit;

  const ReminderSettingScreen({super.key, required this.habit});

  @override
  State<ReminderSettingScreen> createState() => _ReminderSettingScreenState();
}

class _ReminderSettingScreenState extends State<ReminderSettingScreen> {
  late ReminderSettingController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = ReminderSettingController(
      habit: widget.habit,
      repository: ReminderSettingRepository(Supabase.instance.client),
      notificationService: LocalNotificationService(),
      reminderSyncService: ReminderSyncService(),
    )..addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _controller.debugCurrentState,
            tooltip: 'Debug State',
          ),
          if (_controller.hasChanges)
            TextButton(
              onPressed: _controller.isLoading ? null : _controller.saveSettings,
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Habit Info Card
                  components.ReminderSettingComponents.buildHabitInfoCard(widget.habit),
                  
                  const SizedBox(height: 16),
                  
                  // Reminders Section
                  components.ReminderSettingComponents.buildRemindersSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Notification Time Section
                  components.ReminderSettingComponents.buildNotificationTimeSection(_controller, context),
                  
                  const SizedBox(height: 24),
                  
                  // Notification Channel Section
                  components.ReminderSettingComponents.buildNotificationChannelSection(_controller),
                  
                  const SizedBox(height: 24),
                  
                  // Advanced Settings Section
                  components.ReminderSettingComponents.buildAdvancedSettingsSection(_controller),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons Section
                  components.ReminderSettingComponents.buildActionButtonsSection(_controller),
                  
                  const SizedBox(height: 16),
                  
                  // Save Button
                  components.ReminderSettingComponents.buildSaveButton(_controller),
                ],
              ),
            ),
    );
  }
}