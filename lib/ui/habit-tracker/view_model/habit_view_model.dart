import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/domain/model/habit_model.dart';
import '../../../data/repository/habit_repository.dart';
import '../../../data/repository/daily_log_repository.dart';

enum HabitStatus { initial, loading, success, failure }

class HabitsState {
  final HabitStatus status;
  final String? errorMessage;
  final List<HabitModel> habits;

  HabitsState({
    this.status = HabitStatus.initial,
    this.errorMessage,
    this.habits = const [],
  });

  HabitsState copyWith({
    HabitStatus? status,
    String? errorMessage,
    List<HabitModel>? habits,
  }) {
    return HabitsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      habits: habits ?? this.habits,
    );
  }
}

class HabitsViewModel extends StateNotifier<HabitsState> {
  final HabitRepository _habitRepository;
  final DailyLogRepository _dailyLogRepository;
  final String _currentUserId;

  HabitsViewModel(
    this._habitRepository,
    this._dailyLogRepository,
    this._currentUserId,
  ) : super(HabitsState());

  Future<void> loadUserHabits() async {
    state = state.copyWith(status: HabitStatus.loading, errorMessage: null);

    try {
      final habits = await _habitRepository.fetchUserHabits(_currentUserId);
      state = state.copyWith(status: HabitStatus.success, habits: habits);
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to load habits.',
      );
    }
  }

  Future<void> toggleHabitCompletion(HabitModel habit) async {
    try {
      final today = DateTime.now();
      final existingLog = await _dailyLogRepository.getTodayLogForHabit(habit.id);
      
      if (existingLog != null) {
        // Toggle completion status
        await _dailyLogRepository.recordLog(
          habitId: habit.id,
          date: today,
          isCompleted: !existingLog.isCompleted,
          actualValue: habit.targetValue?.toDouble(),
          notes: existingLog.notes,
        );
      } else {
        // Create new log as completed
        await _dailyLogRepository.recordLog(
          habitId: habit.id,
          date: today,
          isCompleted: true,
          actualValue: habit.targetValue?.toDouble(),
          notes: 'Completed via app',
        );
      }

      // Update habit status in habits table
      final newStatus = existingLog?.isCompleted == true ? 'neutral' : 'completed';
      await _habitRepository.updateHabitStatus(
        habitId: habit.id,
        status: newStatus,
      );

      // Reload habits untuk update UI
      await loadUserHabits();
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to update habit status.',
      );
    }
  }

  Future<void> completeHabitWithValue({
    required int habitId,
    required double actualValue,
    String? notes,
  }) async {
    try {
      await _dailyLogRepository.recordLog(
        habitId: habitId,
        date: DateTime.now(),
        isCompleted: true,
        actualValue: actualValue,
        notes: notes,
      );

      await _habitRepository.updateHabitStatus(
        habitId: habitId,
        status: 'completed',
      );

      await loadUserHabits();
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to record habit completion.',
      );
    }
  }

  Future<Map<int, bool>> getTodayCompletionStatus() async {
    try {
      final todayLogs = await _dailyLogRepository.fetchLogsByDate(DateTime.now());
      final completionStatus = <int, bool>{};
      
      for (final log in todayLogs) {
        completionStatus[log.habitId] = log.isCompleted;
      }
      
      return completionStatus;
    } catch (e) {
      return {};
    }
  }

  Future<void> addHabit({
    required String name,
    required String frequency,
    required DateTime startDate,
    int? categoryId,
    String? notes,
    int? targetValue,
  }) async {
    try {
      final newHabit = HabitModel(
        id: 0,
        userId: _currentUserId,
        name: name,
        frequency: frequency,
        startDate: startDate,
        isActive: true,
        categoryId: categoryId,
        targetValue: targetValue,
        status: 'neutral',
      );

      await _habitRepository.createHabit(newHabit);
      await loadUserHabits();
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to add new habit.',
      );
      rethrow;
    }
  }
}