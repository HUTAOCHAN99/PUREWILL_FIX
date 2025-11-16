// lib\ui\habit-tracker\widget\habit_cards_list.dart
import 'package:flutter/material.dart';
import 'package:purewill/domain/model/daily_log_model.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/ui/habit-tracker/view_model/habit_view_model.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_card.dart';
import 'package:purewill/utils/habit_icon_helper.dart'; // ADD THIS IMPORT

class HabitCardsList extends StatelessWidget {
  final HabitsState habitsState;
  final Map<int, LogStatus> todayCompletionStatus;
  final List<HabitModel> habits;
  final void Function(HabitModel habit) onHabitTap;
  final Widget Function(String errorMessage)? buildErrorState;
  final Widget Function()? buildEmptyState;

  const HabitCardsList({
    super.key,
    required this.habitsState,
    required this.todayCompletionStatus,
    required this.habits,
    required this.onHabitTap,
    this.buildErrorState,
    this.buildEmptyState,
  });

  LogStatus parseLogStatus(String statusString) {
  // Gunakan .toLowerCase() agar aman dari "Completed" atau "completed"
  switch (statusString.toLowerCase()) {
    case "success":
      return LogStatus.success;
    case "neutral":
      return LogStatus.neutral;
    case "failed":
      return LogStatus.failed;
    default:
      return LogStatus.neutral; // Atau LogStatus.unknown jika Anda punya
  }
}

  @override
  Widget build(BuildContext context) {
    switch (habitsState.status) {
      case HabitStatus.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );

      case HabitStatus.failure:
        return buildErrorState?.call(
              habitsState.errorMessage ?? 'Unknown error',
            ) ??
            _defaultErrorState(habitsState.errorMessage ?? 'Unknown error');

      case HabitStatus.success:
        if (habitsState.habits.isEmpty) {
          return buildEmptyState?.call() ?? _defaultEmptyState();
        }

        final defaultHabits = habits.where((h) => h.isDefault).toList();
        final userHabits = habits.where((h)=> !h.isDefault).toList();
        final sortedHabits = [...defaultHabits, ...userHabits];

        return Column(
          children: sortedHabits.map((habit) {
            final isCompleted = todayCompletionStatus[habit.id] ?? false;
            
            // USE HABIT ICON HELPER INSTEAD OF DEFAULT HABITS SERVICE
            final iconData = HabitIconHelper.getHabitIcon(habit.name);
            final color = HabitIconHelper.getHabitColor(habit.name);

            return HabitCard(
              icon: iconData,
              title: habit.name,
              subtitle: _buildHabitSubtitle(habit),
              color: color,
              progress: isCompleted == LogStatus.success ? 1.0 : 0.0,
              status: parseLogStatus(habit.status),
              isDefault: habit.isDefault,
              onTap: () => onHabitTap(habit),
            );
          }).toList(),
        );
      case HabitStatus.initial:
        throw UnimplementedError();
    }
  }

  Widget _defaultErrorState(String message) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          const Text(
            'Failed to load habits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );

  Widget _defaultEmptyState() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, color: Colors.grey, size: 48),
          const SizedBox(height: 8),
          const Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first habit to get started!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );

  String _buildHabitSubtitle(HabitModel habit) {
    if (habit.targetValue != null && habit.unit != null) {
      return '${habit.targetValue} ${habit.unit}';
    }
    return 'Daily habit';
  }
}