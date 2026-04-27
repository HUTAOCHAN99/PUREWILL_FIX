import 'package:flutter/material.dart';
import 'package:purewill/domain/model/habit_log_model.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/ui/habit-tracker/view_model/habit_view_model.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_card.dart';
import 'package:purewill/utils/habit_icon_helper.dart';

class HabitCardsList extends StatelessWidget {
  final HabitStatus status;
  final String? errorMessage;
  final Map<int, LogStatus> todayCompletionStatus;
  final List<HabitModel> habits;
  final void Function(HabitModel habit) onHabitTap;
  final void Function(HabitModel habit) onCheckboxTap;
  final Widget Function(String errorMessage)? buildErrorState;
  final Widget Function()? buildEmptyState;
  final bool isPremiumUser;

  const HabitCardsList({
    super.key,
    required this.status,
    this.errorMessage,
    required this.todayCompletionStatus,
    required this.habits,
    required this.onHabitTap,
    required this.onCheckboxTap,
    this.buildErrorState,
    this.buildEmptyState,
    required this.isPremiumUser,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case HabitStatus.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );

      case HabitStatus.failure:
        return buildErrorState?.call(errorMessage ?? 'Unknown error') ??
            _defaultErrorState(errorMessage ?? 'Unknown error');

      case HabitStatus.success:
        if (habits.isEmpty) {
          return buildEmptyState?.call() ?? _defaultEmptyState();
        }

        final defaultHabits = habits.where((h) => h.isDefault).toList();
        final userHabits = habits.where((h) => !h.isDefault).toList();
        final sortedHabits = [...defaultHabits, ...userHabits];

        return Column(
          children: sortedHabits.map((habit) {
            final todayLogStatus = _resolveTodayLogStatus(habit);
            final categoryName = _determineCategory(habit);
            final iconData = HabitIconHelper.getHabitIcon(categoryName);
            final color = HabitIconHelper.getHabitColor(categoryName);

            return HabitCard(
              icon: iconData,
              title: habit.name,
              subtitle: _buildHabitSubtitle(habit),
              color: color,
              progress: todayLogStatus == TodayLogStatus.success ? 1.0 : 0.0,
              status: todayLogStatus,
              category: categoryName,
              isDefault: habit.isDefault,
              onTap: () => onHabitTap(habit),
              onCheckboxTap: () => onCheckboxTap(habit),
            );
          }).toList(),
        );
      case HabitStatus.initial:
        throw UnimplementedError();
    }
  }

  TodayLogStatus _resolveTodayLogStatus(HabitModel habit) {
    final localStatus = todayCompletionStatus[habit.id];
    if (localStatus == null) {
      return habit.todayLogStatus;
    }

    switch (localStatus) {
      case LogStatus.success:
        return TodayLogStatus.success;
      case LogStatus.failed:
        return TodayLogStatus.failed;
      case LogStatus.neutral:
        return TodayLogStatus.netural;
    }
  }

  String _determineCategory(HabitModel habit) {
    final categoryId = habit.category?.id;
    if (categoryId != null) {
      final categoryName = _mapCategoryIdToName(categoryId);
      // print(
      //   'Habit ${habit.name}: categoryId ${habit.category?.id} -> $categoryName',
      // );
      return categoryName;
    }

    final categoryFromName = HabitIconHelper.getHabitCategory(habit.name);
    // print(
    //   'Habit ${habit.name}: no categoryId, using name -> $categoryFromName',
    // );
    return categoryFromName;
  }

  String _mapCategoryIdToName(int categoryId) {
    switch (categoryId) {
      case 1:
        return "Health & Fitness";
      case 2:
        return "Learning & Education";
      case 3:
        return "Productivity";
      case 4:
        return "Mindfulness & Mental Health";
      case 5:
        return "Personal Care";
      case 6:
        return "Social & Relationships";
      case 7:
        return "Finance";
      case 8:
        return "Hobbies & Creativity";
      case 9:
        return "Work & Career";
      case 10:
        return "Other";
      default:
        return "Other";
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
    if (habit.targetValue != null) {
      if (habit.unit != null && habit.unit!.isNotEmpty) {
        return '${habit.targetValue} ${habit.unit}';
      }
      return '${habit.targetValue}';
    }
    return 'Daily habit';
  }
}
