import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/services/habits/habit_api_service.dart';
import 'package:purewill/data/services/me/me_api_service.dart';
import 'package:purewill/domain/model/category_model.dart';
import 'package:purewill/domain/model/habit_log_model.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/profile_model.dart';
import 'package:purewill/domain/model/reminder_setting_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:purewill/domain/model/target_unit_model.dart';

enum HabitStatus { initial, loading, success, failure }

class HabitsState {
  final HabitStatus status;
  final String? errorMessage;
  final List<HabitModel> habits;
  final List<HabitModel> todayHabit;
  final List<HabitLogModel> habitLogs;
  final List<TargetUnitModel> targetUnits;
  final List<CategoryModel> categories;
  final List<HabitLogModel> habitLogForThisMonth;
  final HabitModel? currentHabitDetail;

  final ReminderSettingModel? currentReminderSetting;
  ProfileModel? currentUser;

  HabitsState({
    this.status = HabitStatus.initial,
    this.errorMessage,
    this.habits = const [],
    this.todayHabit = const [],
    this.habitLogs = const [],
    this.targetUnits = const [],
    this.categories = const [],
    this.habitLogForThisMonth = const [],
    this.currentUser,
    this.currentHabitDetail,
    this.currentReminderSetting,
  });

  HabitsState copyWith({
    HabitStatus? status,
    String? errorMessage,
    List<HabitModel>? habits,
    List<HabitModel>? todayHabit,
    List<HabitLogModel>? habitLogs,
    List<HabitLogModel>? habitLogForThisMonth,
    List<TargetUnitModel>? targetUnits,
    List<CategoryModel>? categories,
    List<ReminderSettingModel>? reminderSettings,
    ProfileModel? currentUser,
    HabitModel? currentHabitDetail,
  }) {
    return HabitsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      habits: habits ?? this.habits,
      todayHabit: todayHabit ?? this.todayHabit,
      habitLogs: habitLogs ?? this.habitLogs,
      habitLogForThisMonth: habitLogForThisMonth ?? this.habitLogForThisMonth,
      targetUnits: targetUnits ?? this.targetUnits,
      categories: categories ?? this.categories,
      currentUser: currentUser ?? this.currentUser,
      currentHabitDetail: currentHabitDetail ?? this.currentHabitDetail,
    );
  }
}

class HabitsViewModel extends StateNotifier<HabitsState> {
  final HabitApiService _habitApiService;
  final MeApiService _meApiService;
  // geolocation
  // imported lazily where needed

  HabitsViewModel(this._habitApiService, this._meApiService)
    : super(HabitsState());

  void clearState() {
    state = HabitsState(
      status: HabitStatus.initial,
      errorMessage: null,
      habits: const [],
      todayHabit: const [],
      habitLogs: const [],
      targetUnits: const [],
      categories: const [],
      currentUser: null,
      currentHabitDetail: null,
      currentReminderSetting: null,
    );
  }

  Future<List<HabitModel>> _fetchUserHabits() async {
    final response = await _meApiService.getMeHabits();
    final data = response['data'] as List? ?? [];

    print("response get user habits");
    print(response);
    return data.map((json) => HabitModel.fromJson(json)).toList();
  }

  Future<int> _getNofapHabitId() async {
    final habits = await _fetchUserHabits();
    final nofapHabit = habits.firstWhere(
      (habit) => habit.name.toLowerCase() == 'nofap',
      orElse: () => throw Exception('NoFap habit not found'),
    );
    return nofapHabit.id;
  }

  Future<HabitModel?> _getHabitById(int habitId) async {
    try {
      final response = await _habitApiService.getHabitDetail(habitId);
      return HabitModel.fromJson(response['data']);
    } catch (_) {
      return null;
    }
  }

  Future<HabitModel> _createHabit(HabitModel habit) async {
    final response = await _habitApiService.createHabit(habit);
    return HabitModel.fromJson(response['data']);
  }

  Future<void> _updateHabit(int habitId, Map<String, dynamic> updates) async {
    await _habitApiService.updateHabit(habitId, updates);
  }

  Future<void> updateHabitFields({
    required int habitId,
    required Map<String, dynamic> updates,
  }) async {
    if (updates.isEmpty) {
      return;
    }

    try {
      await _updateHabit(habitId, updates);
      await loadUserHabits();
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to edit habit.',
      );
      rethrow;
    }
  }

  Future<void> _deleteHabit(int habitId) async {
    await _habitApiService.deleteHabit(habitId);
  }

  ProfileModel _mapMeResponseToProfile(Map<String, dynamic> data) {
    return ProfileModel(
      username: data['username']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      fullName: data['profile']["fullname"]?.toString() ?? '',
    );
  }

  Future<void> getCurrentUser() async {
    state = state.copyWith(status: HabitStatus.loading, errorMessage: null);
    try {
      final response = await _meApiService.getMe();
      final data = response['data'] as Map<String, dynamic>? ?? {};
      final currentUser = _mapMeResponseToProfile(data);
      // print(currentUser);
      state = state.copyWith(
        status: HabitStatus.success,
        currentUser: currentUser,
      );
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to load user profile.',
      );
    }
  }

  // Future<bool> isHabitStarted({required int habitId}) async {
  //   try {
  //     final habit = await _habitSessionRepository.getActiveHabitSession(
  //       habitId: habitId,
  //       userId: _currentUserId,
  //     );
  //     if (habit == null) {
  //       return false;
  //     }
  //     return true;
  //   } catch (e) {
  //     log(
  //       'IS HABIT STARTED FAILURE: Failed to check if habit $habitId has started.',
  //       error: e,
  //       name: 'HABIT_VIEW_MODEL',
  //     );
  //     rethrow;
  //   }
  // }

  Future<int> getNofapHabitId() async {
    try {
      final habitId = await _getNofapHabitId();
      return habitId;
    } catch (e) {
      rethrow;
    }
  }

  // Future<List<HabitLogModel>> getLogNofapHabit() async {
  //   try {
  //     final habitId = await _getNofapHabitId();
  //     final log = await _dailyLogRepository.fetchLogsByHabit(habitId);
  //     return log;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<void> startNofapHabit() async {
  //   try {
  //     final habitId = await _getNofapHabitId();
  //     await _activateNofapHabit(habitId);
  //     await _habitSessionRepository.addHabitSession(
  //       habitId: habitId,
  //       userId: _currentUserId,
  //       startDate: DateTime.now(),
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<void> stopNofapHabit() async {
  //   try {
  //     final habitId = await _getNofapHabitId();
  //     final activeSession = await _habitSessionRepository.getActiveHabitSession(
  //       habitId: habitId,
  //       userId: _currentUserId,
  //     );
  //     await _habitSessionRepository.updateHabitSession(
  //       sessionId: activeSession!.id,
  //       endDate: DateTime.now(),
  //       isActive: false,
  //     );
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<int> getNofapHabitStreak() async {
  //   try {
  //     final habitId = await _getNofapHabitId();
  //     final streak = await _habitSessionRepository.fetchNofapHabitLongestStreak(
  //       habitId: habitId,
  //       userId: _currentUserId,
  //     );
  //     return streak;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<int> getNofapHabitCurrentStreak() async {
  //   try {
  //     final habitId = await _getNofapHabitId();
  //     final streak = await _habitSessionRepository.fetchNofapHabitCurrentStreak(
  //       habitId: habitId,
  //       userId: _currentUserId,
  //     );
  //     return streak;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<int> getRelapseCountNofapHabit() async {
  //   try {
  //     final habitId = await _getNofapHabitId();
  //     final relapseCount = await _habitSessionRepository.getRelapseCount(
  //       habitId: habitId,
  //       userId: _currentUserId,
  //     );
  //     return relapseCount;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Future<List<DateTime>> getSuccessDaysNofapHabit() async {
  //   try {
  //     final habitId = await _getNofapHabitId();
  //     final successDays = await _habitSessionRepository.getSuccessDays(
  //       habitId: habitId,
  //       userId: _currentUserId,
  //     );
  //     return successDays;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<void> loadUserHabits() async {
    state = state.copyWith(status: HabitStatus.loading, errorMessage: null);

    try {
      final allHabits = await _fetchUserHabits();
      state = state.copyWith(status: HabitStatus.success, habits: allHabits);
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to load habits.',
      );
    }
  }

  Future<void> loadTodayUserHabits() async {
    print("load today habit user");
    state = state.copyWith(status: HabitStatus.loading, errorMessage: null);
    try {
      final allHabits = await _fetchUserHabits();
      final now = DateTime.now();
      final todayOnly = DateTime(now.year, now.month, now.day);

      final habits = allHabits.where((habit) {
        // Only include explicitly active habits
        if (habit.isActive != true) return false;

        // Normalize start date to date-only for comparison
        final s = habit.startDate;
        final startOnly = DateTime(s.year, s.month, s.day);

        // Include habit when startDate is today or before
        return startOnly.compareTo(todayOnly) <= 0;
      }).toList();

      print(habits);

      state = state.copyWith(status: HabitStatus.success, todayHabit: habits);
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to load today habits.',
      );
    }
  }

  Future<void> loadHabitDetail({required int habitId}) async {
    state = state.copyWith(status: HabitStatus.loading, errorMessage: null);

    try {
      final habitDetail = await _getHabitById(habitId);
      state = state.copyWith(
        status: HabitStatus.success,
        currentHabitDetail: habitDetail,
      );
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to load habit detail.',
      );
    }
  }

  Future<void> loadCategories() async {
    state = state.copyWith(status: HabitStatus.loading, errorMessage: null);

    try {
      final response = await _meApiService.getMeCategories();
      final data = response['data'] as List? ?? [];

      final categories = data
          .whereType<Map>()
          .map(
            (json) => CategoryModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();

      state = state.copyWith(
        status: HabitStatus.success,
        categories: categories,
      );
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to load categories.',
      );
    }
  }

  Future<void> toggleHabitCompletion(HabitModel habit) async {
    try {
      state = state.copyWith(status: HabitStatus.loading);

      double? lat;
      double? long;

      if (habit.isLocationLocked) {
        final permission = await Permission.location.request();
        if (!permission.isGranted) {
          throw Exception('Location permission denied');
        }

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );
        lat = position.latitude;
        long = position.longitude;
      }

      await _habitApiService.toggleHabitLog(
        habit.id,
        currentLat: lat,
        currentLong: long,
      );

      state = state.copyWith(status: HabitStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to update habit status. $e',
      );
      rethrow;
    }
  }

  Future<void> completeHabitWithValue({
    required int habitId,
    required double actualValue,
    String? notes,
  }) async {
    // try {
    //   await _dailyLogRepository.recordLog(
    //     habitId: habitId,
    //     date: DateTime.now(),
    //     status: LogStatus.success,
    //     actualValue: actualValue.toInt(), // ✅ Ubah: tambah .toInt()
    //   );

    //   await _updateHabitStatus(habitId: habitId, status: 'completed');

    //   await loadUserHabits();
    // } catch (e) {
    //   state = state.copyWith(
    //     status: HabitStatus.failure,
    //     errorMessage: 'Failed to record habit completion.',
    //   );
    // }
  }

  Future<Map<int, LogStatus>> getTodayCompletionStatus() async {
    try {
      final completionStatus = <int, LogStatus>{};
      return completionStatus;
    } catch (e) {
      return {};
    }
  }

  Future<void> addHabit({
    required String name,
    required String frequency,
    required DateTime startDate,
    DateTime? endDate,
    int? categoryId,
    String? notes,
    int? targetValue,
    bool? reminderEnabled,
    TimeOfDay? reminderTime,
  }) async {
    try {
      final selectedCategory = categoryId != null
          ? state.categories
                .where((category) => category.id == categoryId)
                .cast<CategoryModel?>()
                .firstWhere((category) => category != null, orElse: () => null)
          : null;

      final newHabit = HabitModel(
        id: 0,
        // userId: _currentUserId,
        name: name,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        isActive: true,
        category: selectedCategory,
        targetValue: targetValue,
        status: 'neutral',
        notes: notes,
      );

      await _createHabit(newHabit);
      // await _dailyLogRepository.addLogsForNewHabit(habit);
      // await _reminderSettingRepository.createReminderSetting(
      //   ReminderSettingModel(
      //     id: '',
      //     habitId: habit.id,
      //     isEnabled: reminderEnabled ?? false,
      //     time: reminderTime != null
      //         ? DateTime(
      //             startDate.year,
      //             startDate.month,
      //             startDate.day,
      //             reminderTime.hour,
      //             reminderTime.minute,
      //           )
      //         : DateTime.now(),
      //     snoozeDuration: 5,
      //     repeatDaily: true,
      //     isSoundEnabled: true,
      //     isVibrationEnabled: true,
      //     createdAt: DateTime.now(),
      //   ),
      // );
      await loadTodayUserHabits();
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
      // await _targetUnitRepository.createTargetUnit(nameTargetUnit);
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to create target unit.',
      );
      rethrow;
    }
  }

  Future<void> deleteHabit({required int habitId}) async {
    try {
      // await _reminderSettingRepository.deleteAllReminderSettingsForHabit(
      // habitId,
      // );
      // await _dailyLogRepository.deleteLogsByHabit(habitId);
      await _deleteHabit(habitId);
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to delete habit.',
      );
      rethrow;
    }
  }

  Future<void> updateHabits({
    required int habitId,
    String? newName,
    String? newFrequency,
    DateTime? newStartDate,
    DateTime? newEndDate,
    int? newCategoryId,
    String? newNotes,
    int? newTargetValue,
  }) async {
    try {
      final oldHabit = await _getHabitById(habitId);
      if (oldHabit == null) {
        throw Exception('Habit not found');
      }

      final updateData = <String, dynamic>{};
      if (newName != null && newName != oldHabit.name) {
        updateData['name'] = newName;
      }

      if (newFrequency != null && newFrequency != oldHabit.frequency) {
        updateData['frequencyType'] = newFrequency.toUpperCase();
      }

      if (newStartDate != null && newStartDate != oldHabit.startDate) {
        updateData['startDate'] = newStartDate.toIso8601String();
      }

      if (newEndDate != oldHabit.endDate) {
        if (newEndDate != null) {
          updateData['endDate'] = newEndDate.toIso8601String();
        } else {
          updateData['endDate'] = null;
        }
      }

      if (newCategoryId != oldHabit.category?.id) {
        updateData['categoryId'] = newCategoryId;
      }

      if (newNotes != oldHabit.notes) {
        updateData['notes'] = newNotes;
      }

      if (newTargetValue != oldHabit.targetValue) {
        updateData['targetValue'] = newTargetValue;
      }

      if (updateData.isEmpty) {
        return;
      }

      await _updateHabit(habitId, updateData);

      if (newStartDate != null && newStartDate != oldHabit.startDate) {
        // await _dailyLogRepository.deleteLogsBeforeDate(
        //   habitId: habitId,
        //   date: newStartDate,
        // );
      }

      if (newEndDate != oldHabit.endDate) {
        if (newEndDate != null) {
          // await _dailyLogRepository.deleteLogsAfterDate(
          // habitId: habitId,
          // date: newEndDate,
          // );
        }
      }

      await loadUserHabits();
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to edit habit.',
      );
      rethrow;
    }
  }

  Future<void> saveReminderSetting({
    required int habitId,
    required bool isEnabled,
    required DateTime time,
    required int snoozeDuration,
    required bool repeatDaily,
    required bool isSoundEnabled,
    required bool isVibrationEnabled,
  }) async {
    try {
      // final reminderSettingBefore = await _reminderSettingRepository
      //     .fetchReminderSettingsByHabit(habitId);

      // if (reminderSettingBefore.id.isNotEmpty) {
      // await _reminderSettingRepository.updateReminderSetting(
      //   reminderSettingId: reminderSettingBefore.id,
      //   updates: {
      //     'is_enabled': isEnabled,
      //     'time': time.toIso8601String(),
      //     'snooze_duration': snoozeDuration,
      //     'repeat_daily': repeatDaily,
      //     'is_sound_enabled': isSoundEnabled,
      //     'is_vibration_enabled': isVibrationEnabled,
      //   },
      // );
      // await loadCurrentReminderSetting(habitId);
      log(
        'UPDATE REMINDER SETTING SUCCESS: Reminder setting created for habit $habitId.',
        name: 'HABIT_VIEW_MODEL',
      );
      // return;
      // }

      // await _reminderSettingRepository.createReminderSetting(reminderSetting);

      log(
        'CREATE REMINDER SETTING SUCCESS: Reminder setting created for habit $habitId.',
        name: 'HABIT_VIEW_MODEL',
      );
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to create reminder setting.',
      );
      rethrow;
    }
  }

  Future<void> deleteReminderSetting(int habitId) async {
    try {
      // await _reminderSettingRepository.deleteReminderSetting(habitId);
      // await loadCurrentReminderSetting(habitId);
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to delete reminder setting.',
      );
      rethrow;
    }
  }
}
