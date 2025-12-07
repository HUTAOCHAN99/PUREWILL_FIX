import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/daily_log_model.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/reminder_setting_model.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/ui/habit-tracker/screen/edit_habit_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/reminder_setting_screen.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/calendar_tracker_widget.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/habit_actions_dropdown.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/motivational_quote_widget.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/performance_chart_widget.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/progress_widget.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/weekly_streak_widget.dart';
import 'package:purewill/utils/habit_icon_helper.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final HabitModel habit;
  final Map<int, LogStatus> completionStatus;
  const HabitDetailScreen({
    super.key,
    required this.habit,
    required this.completionStatus,
  });

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  late bool _isCompleted;
  int _completedDays = 0;

  List<bool>? _weeklyStreak;
  List<double>? _weeklyPerformance;
  List<DateTime>? _completionDates;
  bool _isLoading = true;
  ReminderSettingModel? _reminderSetting;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int habitId = widget.habit.id;
      _isCompleted =
          widget.completionStatus[widget.habit.id] == LogStatus.success;
      _loadHabitLogForThisMonth(habitId);
      _loadReminderSetting(habitId);
    });
  }

  Future<void> _loadReminderSetting(int habitId) async {
    try {
      final reminderSetting = await ref
          .read(habitNotifierProvider.notifier)
          .loadCurrentReminderSetting(habitId);
      if (mounted) {
        setState(() {
          _reminderSetting = reminderSetting;
        });
      }
    } catch (e) {
      print('Error loading reminder setting: $e');
      if (mounted) {
        setState(() {
          _reminderSetting = null;
        });
      }
    }
  }

  Future<void> _loadHabitLogForThisMonth(int habitId) async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate = DateTime(now.year, now.month, 1);
      DateTime endDate = DateTime(now.year, now.month + 1, 0);

      final habitLogForThisMonth = await ref
          .read(habitNotifierProvider.notifier)
          .fetchLogsForCalendar(
            startDate: startDate,
            endDate: endDate,
            habitId: habitId,
          );

      DateTime today = DateUtils.dateOnly(now);
      int currentWeekday = today.weekday;
      DateTime startDateWeek = today.subtract(
        Duration(days: currentWeekday - 1),
      );
      DateTime endDateWeek = startDateWeek.add(const Duration(days: 6));

      final List<DailyLogModel> logsForThisWeek = habitLogForThisMonth.where((
        dailyLog,
      ) {
        DateTime logDateOnly = DateUtils.dateOnly(dailyLog.logDate);
        return !logDateOnly.isBefore(startDateWeek) &&
            !logDateOnly.isAfter(endDateWeek);
      }).toList();

      final completedDays = logsForThisWeek
          .where((log) => log.status == LogStatus.success)
          .length;

      List<bool> localWeeklyStreak = List.generate(7, (_) => false);
      List<double> localWeeklyPerformance = List.generate(7, (_) => 0.0);

      for (var log in logsForThisWeek) {
        DateTime logDateOnly = DateUtils.dateOnly(log.logDate);
        int dayIndex = logDateOnly.difference(startDateWeek).inDays;

        if (dayIndex >= 0 && dayIndex < 7) {
          localWeeklyStreak[dayIndex] = log.status == LogStatus.success;
          localWeeklyPerformance[dayIndex] = log.status == LogStatus.success
              ? 100.0
              : 0.0;
        }
      }

      final List<DateTime> localCompletionDates = habitLogForThisMonth.map((
        dailyLog,
      ) {
        return dailyLog.logDate;
      }).toList();

      if (mounted) {
        setState(() {
          _weeklyStreak = localWeeklyStreak;
          _weeklyPerformance = localWeeklyPerformance;
          _completionDates = localCompletionDates;
          _completedDays = completedDays;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading completion status: $e');
      if (mounted) {
        setState(() {
          _weeklyStreak = List.generate(7, (_) => false);
          _weeklyPerformance = List.generate(7, (_) => 0.0);
          _completionDates = [];
          _completedDays = 0;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconData = HabitIconHelper.getHabitIcon(widget.habit.name);
    final iconColor = HabitIconHelper.getHabitColor(widget.habit.name);
    final category = HabitIconHelper.getHabitCategory(widget.habit.name);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color.fromRGBO(184, 230, 230, 1),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderBackground(iconData, iconColor, category),
              titlePadding: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
              collapseMode: CollapseMode.pin,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Habit detail",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              HabitActionsDropdown(
                onActionSelected: _handleMenuAction,
                habitName: widget.habit.name,
                habit: widget.habit,
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProgressWidget(
                    isCompleted: _isCompleted,
                    habitColor: iconColor,
                    habitName: "fd",
                    completedDays: _completedDays,
                    totalDays: 7,
                  ),
                  const SizedBox(height: 24),

                  WeeklyStreakWidget(
                    weeklyStreak:
                        _weeklyStreak != null && _weeklyStreak!.length == 7
                        ? _weeklyStreak!
                        : List.generate(7, (_) => false),
                  ),
                  const SizedBox(height: 24),

                  PerformanceChartWidget(
                    weeklyPerformance:
                        _weeklyPerformance != null &&
                            _weeklyPerformance!.length == 7
                        ? _weeklyPerformance!
                        : List.generate(7, (_) => 0.0),
                  ),
                  const SizedBox(height: 24),

                  CalendarTrackerWidget(
                    completionDates: _completionDates ?? [],
                  ),
                  const SizedBox(height: 16),

                  MotivationalQuotesWidget(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String value) {
    HabitActionsDropdown.handleMenuAction(
      value: value,
      context: context,
      habitName: widget.habit.name,
      habit: widget.habit,
      onEdit: _editHabit,
      onReminder: _setReminder,
      onDelete: _deleteHabit,
    );
  }

  void _editHabit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditHabitScreen(habit: widget.habit),
      ),
    );
  }

  void _setReminder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReminderSettingScreen(habit: widget.habit, reminderSetting: _reminderSetting),
      ),
    );
  }

  void _deleteHabit() {
    HabitActionsDropdown.showDeleteConfirmationDialog(
      context: context,
      habitName: widget.habit.name,
      onConfirm: () {
        _performDeleteHabit();
      },
    );
  }

  Future<void> _performDeleteHabit() async {
    try {
      final viewModel = ref.read(habitNotifierProvider.notifier);

      if (widget.habit.isDefault) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${widget.habit.name}" adalah habit default dan tidak dapat dihapus',
            ),
          ),
        );
        return;
      }

      await viewModel.deleteHabit(habitId: widget.habit.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${widget.habit.name}" berhasil dihapus')),
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus habit: $e')));
    }
  }

  Widget _buildHeaderBackground(
    IconData iconData,
    Color iconColor,
    String category,
  ) {
    return Container(
      color: const Color.fromRGBO(184, 230, 230, 1),
      padding: const EdgeInsets.only(
        top: kToolbarHeight + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(iconData, size: 25, color: iconColor),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    widget.habit.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
