import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/reminder_setting_model.dart';
import 'package:purewill/data/repository/reminder_setting_repository.dart';
import 'package:purewill/data/services/local_notification_service.dart';
import 'package:purewill/ui/habit-tracker/screen/reminder_setting_screen.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';

class ReminderListScreen extends ConsumerStatefulWidget {
  final HabitModel habit;
  const ReminderListScreen({super.key, required this.habit});

  @override
  ConsumerState<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends ConsumerState<ReminderListScreen> {
  late ReminderSettingRepository _repository;
  ReminderSettingModel? _setting;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final reminderApi = ref.read(reminderApiServiceProvider);
    _repository = ReminderSettingRepository(apiService: reminderApi);
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _repository.fetchReminderSettingsByHabit(
        widget.habit.id,
      );
      _setting = settings;
    } catch (e) {
      _setting = null;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    if (_setting == null || _setting!.id.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Hapus reminder'),
        content: const Text('Yakin ingin menghapus reminder ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final reminderId = int.tryParse(_setting!.id);
      if (reminderId == null) {
        throw Exception('Invalid reminder id');
      }

      await _repository.deleteReminderSetting(reminderId);
      await LocalNotificationService().cancelHabitNotifications(
        widget.habit.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reminder dihapus')));
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        backgroundColor: Colors.blue[50],
        foregroundColor: Colors.blue[800],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReminderSettingScreen(habit: widget.habit),
            ),
          );
          await _load();
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: _setting == null || _setting!.isEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Belum ada reminder untuk habit ini.'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReminderSettingScreen(habit: widget.habit),
                              ),
                            );
                            await _load();
                          },
                          child: const Text('Tambah Reminder'),
                        ),
                      ],
                    )
                  : _buildSettingCard(_setting!),
            ),
    );
  }

  Widget _buildSettingCard(ReminderSettingModel setting) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Waktu: ${setting.formattedTime}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: setting.isEnabled,
                  onChanged: (v) async {
                    // toggle enabled via update
                    final reminderId = int.tryParse(setting.id);
                    if (reminderId == null) return;
                    await _repository.updateReminderSetting(
                      reminderSettingId: reminderId,
                      updates: {'is_enabled': v},
                    );
                    await _load();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Berulang: ${setting.repeatDaily ? 'Harian' : 'Sekali'}'),
            const SizedBox(height: 8),
            Text('Next: ${setting.dynamicTimeDisplay}'),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReminderSettingScreen(
                          habit: widget.habit,
                          reminderSetting: setting,
                        ),
                      ),
                    );
                    await _load();
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Hapus'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
