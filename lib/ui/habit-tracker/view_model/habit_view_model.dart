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
      errorMessage: errorMessage,
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
        errorMessage: 'Gagal memuat kebiasaan.',
      );
    }
  }

  Future<void> recordHabitCompletion({
    required int habitId,
    required double value,
    String? notes,
  }) async {
    final now = DateTime.now();

    try {
      await _dailyLogRepository.recordLog(
        habitId: habitId,
        date: now,
        isCompleted: true,
        actualValue: value,
        notes: notes,
      );

      await loadUserHabits();
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Gagal mencatat penyelesaian kebiasaan.',
      );
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
        isActive: true, // Default true
        categoryId: categoryId,
        targetValue: targetValue,
        status: 'neutral', // Default status
      );

      await _habitRepository.createHabit(newHabit);
      await loadUserHabits();
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Gagal menambahkan kebiasaan baru.',
      );
      rethrow;
    }
  }
}
