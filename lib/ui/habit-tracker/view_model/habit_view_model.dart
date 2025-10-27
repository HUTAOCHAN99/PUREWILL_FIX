import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/repository/category_repository.dart';
import 'package:purewill/data/repository/target_unit_repository.dart';
import 'package:purewill/data/repository/user_repository.dart';
import 'package:purewill/domain/model/category_model.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/profile_model.dart';
import 'package:purewill/domain/model/target_unit_model.dart';
import '../../../data/repository/habit_repository.dart';
import '../../../data/repository/daily_log_repository.dart';

enum HabitStatus { initial, loading, success, failure }

class HabitsState {
  final HabitStatus status;
  final String? errorMessage;
  final List<HabitModel> habits;
  final List<TargetUnitModel> targetUnits;
  final List<CategoryModel> categories;
  ProfileModel? currentUser;

  HabitsState({
    this.status = HabitStatus.initial,
    this.errorMessage,
    this.habits = const [],
    this.targetUnits = const [],
    this.categories = const [],
    this.currentUser
  });

  HabitsState copyWith({
    HabitStatus? status,
    String? errorMessage,
    List<HabitModel>? habits,
    List<TargetUnitModel>? targetUnits,
    List<CategoryModel>? caregories,
    ProfileModel? currentUser
  }) {
    return HabitsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      habits: habits ?? this.habits,
      targetUnits: targetUnits ?? this.targetUnits,
      categories: caregories ?? categories,
      currentUser: currentUser ?? this.currentUser
    );
  }
}

class HabitsViewModel extends StateNotifier<HabitsState> {
  final HabitRepository _habitRepository;
  final DailyLogRepository _dailyLogRepository;
  final TargetUnitRepository _targetUnitRepository;
  final CategoryRepository _categoryRepository;
  final UserRepository _userRepository;
  final String _currentUserId;

  HabitsViewModel(
    this._habitRepository,
    this._dailyLogRepository,
    this._targetUnitRepository,
    this._categoryRepository,
    this._userRepository,
    this._currentUserId,
  ) : super(HabitsState());


  Future<void> getCurrentUser() async {
      state = state.copyWith(status: HabitStatus.loading, errorMessage: null);
      try {
        final currentUser = await _userRepository.fetchUserProfile(_currentUserId);
        state = state.copyWith(status: HabitStatus.success, currentUser: currentUser);
      } catch (e) {
        state = state.copyWith(
          status: HabitStatus.failure,
          errorMessage: 'Failed to load user profile.',
        );
      }
  }
  

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

  Future<void> loadUserTargetUnits() async {
    state = state.copyWith(status: HabitStatus.loading, errorMessage: null);

    try {
      final targetUnits = await _targetUnitRepository.fetchUserTargetUnits(
        _currentUserId,
      );

      state = state.copyWith(
        status: HabitStatus.success,
        targetUnits: targetUnits,
      );
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to load target units.',
      );
    }
  }

  Future<void> loadCategories() async {
    state = state.copyWith(status: HabitStatus.loading, errorMessage: null);

    try {
      final categories = await _categoryRepository.fetchCategories();
       print("data categories");
      print(categories);

      state = state.copyWith(
        status: HabitStatus.success,
        caregories: categories,
      );
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to load categorise.',
      );
    }
  }

  Future<void> toggleHabitCompletion(HabitModel habit) async {
    try {
      final today = DateTime.now();
      final existingLog = await _dailyLogRepository.getTodayLogForHabit(
        habit.id,
      );

      if (existingLog != null) {
        await _dailyLogRepository.recordLog(
          habitId: habit.id,
          date: today,
          isCompleted: !existingLog.isCompleted,
          actualValue: habit.targetValue?.toDouble(),
        );
      } else {
        await _dailyLogRepository.recordLog(
          habitId: habit.id,
          date: today,
          isCompleted: true,
          actualValue: habit.targetValue?.toDouble(),
        );
      }

      // final newStatus = existingLog?.isCompleted == true
      //     ? 'neutral'
      //     : 'completed';

      /*       await _habitRepository.updateHabitStatus(
        habitId: habit.id,
        status: newStatus,
      ); */

      await loadUserHabits();
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to update habit status.' + e.toString(),
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
      final todayLogs = await _dailyLogRepository.fetchLogsByDate(
        DateTime.now(),
      );
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

  Future<void> createTargetUnit({required String nameTargetUnit}) async {
    try {
      await _targetUnitRepository.createTargetUnit(nameTargetUnit);
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to create target unit.',
      );
      rethrow;
    }
  }
}
