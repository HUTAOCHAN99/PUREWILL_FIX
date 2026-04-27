import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/services/habits/habit_api_service.dart';
import 'package:purewill/data/services/me/me_api_service.dart';
import 'package:purewill/domain/model/habit_log_model.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/profile_model.dart';
import 'package:purewill/ui/habit-tracker/view_model/habit_view_model.dart';

class HomeState {
  final HabitStatus status;
  final String? errorMessage;
  final List<HabitModel> todayHabits;
  final Map<int, LogStatus> todayCompletionStatus;
  final ProfileModel? currentUser;
  final String userRole;
  final bool isLoadingRole;

  LogStatus _mapTodayLogStatus(TodayLogStatus status) {
    switch (status) {
      case TodayLogStatus.success:
        return LogStatus.success;
      case TodayLogStatus.failed:
        return LogStatus.failed;
      case TodayLogStatus.netural:
        return LogStatus.neutral;
    }
  }

  LogStatus effectiveLogStatusForHabit(HabitModel habit) {
    final localStatus = todayCompletionStatus[habit.id];
    if (localStatus != null) {
      return localStatus;
    }
    return _mapTodayLogStatus(habit.todayLogStatus);
  }

  Map<int, LogStatus> get effectiveCompletionStatus {
    final result = <int, LogStatus>{};
    for (final habit in todayHabits) {
      result[habit.id] = effectiveLogStatusForHabit(habit);
    }
    return result;
  }

  int get totalHabits => todayHabits.length;

  int get completedToday {
    return todayHabits.where((habit) {
      return effectiveLogStatusForHabit(habit) == LogStatus.success;
    }).length;
  }

  double get progress {
    return totalHabits > 0 ? completedToday / totalHabits : 0.0;
  }

  HomeState({
    this.status = HabitStatus.initial,
    this.errorMessage,
    this.todayHabits = const [],
    this.todayCompletionStatus = const {},
    this.currentUser,
    this.userRole = 'user',
    this.isLoadingRole = false,
  });

  HomeState copyWith({
    HabitStatus? status,
    String? errorMessage,
    List<HabitModel>? todayHabits,
    Map<int, LogStatus>? todayCompletionStatus,
    ProfileModel? currentUser,
    String? userRole,
    bool? isLoadingRole,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      todayHabits: todayHabits ?? this.todayHabits,
      todayCompletionStatus:
          todayCompletionStatus ?? this.todayCompletionStatus,
      currentUser: currentUser ?? this.currentUser,
      userRole: userRole ?? this.userRole,
      isLoadingRole: isLoadingRole ?? this.isLoadingRole,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final HabitApiService _habitApiService;
  final MeApiService _meApiService;

  HomeViewModel(this._habitApiService, this._meApiService) : super(HomeState());

  Future<List<HabitModel>> _fetchUserHabits() async {
    final response = await _meApiService.getMeHabits();
    final data = response['data'] as List? ?? [];
    return data.map((json) => HabitModel.fromJson(json)).toList();
  }

  ProfileModel _mapMeResponseToProfile(Map<String, dynamic> data) {
    return ProfileModel(
      username: data['username']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      fullName: data['profile']["fullname"]?.toString() ?? '',
    );
  }

  Future<Map<int, LogStatus>> _getTodayCompletionStatus() async {
    return <int, LogStatus>{};
  }

  Future<String> _resolveUserRole() async {
    return 'user';
  }

  Future<void> initializeHome() async {
    state = state.copyWith(status: HabitStatus.loading, errorMessage: null);
    try {
      final allHabits = await _fetchUserHabits();
      final todayHabits = allHabits
          .where((habit) => habit.isActive == true)
          .toList();

      final meResponse = await _meApiService.getMe();
      final meData = meResponse['data'] as Map<String, dynamic>? ?? {};
      final user = _mapMeResponseToProfile(meData);

      final completionStatus = await _getTodayCompletionStatus();
      final role = await _resolveUserRole();

      state = state.copyWith(
        status: HabitStatus.success,
        todayHabits: todayHabits,
        todayCompletionStatus: completionStatus,
        currentUser: user,
        userRole: role,
        isLoadingRole: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to load home data.',
        isLoadingRole: false,
      );
    }
  }

  LogStatus getNextLogStatus(LogStatus currentStatus) {
    if (currentStatus == LogStatus.neutral) {
      return LogStatus.success;
    }
    if (currentStatus == LogStatus.success) {
      return LogStatus.failed;
    }
    return LogStatus.neutral;
  }

  Future<void> toggleHabitCompletion(HabitModel habit) async {
    final previousStatus = state.effectiveLogStatusForHabit(habit);
    final newStatus = getNextLogStatus(previousStatus);

    final optimisticMap = Map<int, LogStatus>.from(state.todayCompletionStatus);
    optimisticMap[habit.id] = newStatus;
    state = state.copyWith(todayCompletionStatus: optimisticMap);

    try {
      await _habitApiService.toggleHabitLog(habit.id);
    } catch (e) {
      final rollbackMap = Map<int, LogStatus>.from(state.todayCompletionStatus);
      rollbackMap[habit.id] = previousStatus;
      state = state.copyWith(todayCompletionStatus: rollbackMap);
      rethrow;
    }
  }
}
