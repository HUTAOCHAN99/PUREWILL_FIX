import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/habit_log_model.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/ui/habit-tracker/provider/habit_detail_provider.dart';
import 'package:purewill/ui/habit-tracker/screen/edit_habit_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/reminder_list_screen.dart';
import 'package:purewill/ui/habit-tracker/view_model/habit_detail_view_model.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/calendar_tracker_widget.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/habit_actions_dropdown.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/habit_detail_explanation_widget.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(habitDetailProvider.notifier)
          .loadHabitDetailData(habitId: widget.habit.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitDetailState = ref.watch(habitDetailProvider);
    final habit = habitDetailState.currentHabitDetail ?? widget.habit;

    final iconData = HabitIconHelper.getHabitIcon(habit.name);
    final iconColor = HabitIconHelper.getHabitColor(habit.name);
    final category =
        habit.category?.name ?? HabitIconHelper.getHabitCategory(habit.name);

    if (habitDetailState.status == HabitStatus.loading) {
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
              background: _buildHeaderBackground(
                habit.name,
                iconData,
                iconColor,
                category,
              ),
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
                habitName: habit.name,
                habit: habit,
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HabitDetailExplanationWidget(
                    habit: habit,
                    habitColor: iconColor,
                  ),
                  const SizedBox(height: 24),

                  ProgressWidget(
                    // isCompleted: _isCompleted,
                    isCompleted: _isTodayCompleted(habitDetailState.habitLogs),
                    habitColor: iconColor,
                    habitName: habit.name,
                    completedDays: habitDetailState.completedDays,
                    totalDays: habitDetailState.possibleDays,
                  ),
                  const SizedBox(height: 24),

                  WeeklyStreakWidget(streak: habitDetailState.habitLogStreak),
                  const SizedBox(height: 24),
                  CalendarTrackerWidget(
                    habitLogForThisMonth: habitDetailState.habitLogForThisMonth,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String value) {
    final habit =
        ref.read(habitDetailProvider).currentHabitDetail ?? widget.habit;

    HabitActionsDropdown.handleMenuAction(
      value: value,
      context: context,
      habitName: habit.name,
      habit: habit,
      onEdit: _editHabit,
      onReminder: _setReminder,
      onDelete: _deleteHabit,
    );
  }

  Future<void> _editHabit() async {
    final edited = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditHabitScreen(
          habit:
              ref.read(habitDetailProvider).currentHabitDetail ?? widget.habit,
        ),
      ),
    );

    if (!mounted || edited != true) {
      return;
    }

    await ref
        .read(habitDetailProvider.notifier)
        .loadHabitDetailData(habitId: widget.habit.id);
  }

  void _setReminder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReminderListScreen(
          habit:
              ref.read(habitDetailProvider).currentHabitDetail ?? widget.habit,
        ),
      ),
    );
  }

  void _deleteHabit() {
    HabitActionsDropdown.showDeleteConfirmationDialog(
      context: context,
      habitName:
          (ref.read(habitDetailProvider).currentHabitDetail ?? widget.habit)
              .name,
      onConfirm: () {
        _performDeleteHabit();
      },
    );
  }

  Future<void> _performDeleteHabit() async {
    try {
      final viewModel = ref.read(habitNotifierProvider.notifier);
      final habit =
          ref.read(habitDetailProvider).currentHabitDetail ?? widget.habit;

      if (habit.isDefault) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${habit.name}" adalah habit default dan tidak dapat dihapus',
            ),
          ),
        );
        return;
      }
      await viewModel.deleteHabit(habitId: habit.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${habit.name}" berhasil dihapus')),
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
    String habitName,
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
                    habitName,
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

  bool _isTodayCompleted(List<HabitLogModel> logs) {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    final todayLogs = logs.where((log) {
      final date = DateTime(
        log.logDate.year,
        log.logDate.month,
        log.logDate.day,
      );
      return date == normalizedToday;
    });

    return todayLogs.any((log) => log.status == LogStatus.success);
  }
}
