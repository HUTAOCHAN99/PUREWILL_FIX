import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/services/habits/habit_api_service.dart';
import 'package:purewill/domain/model/habit_log_model.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/utils/indonesia_timezone.dart';

enum HabitStatus { initial, loading, success, failure }

class HabitDetailState {
  final HabitStatus status;
  final String? errorMessage;
  final List<HabitLogModel> habitLogs;
  final List<HabitLogModel> habitLogForThisMonth;
  final List<HabitLogModel> habitLogForThisWeek;
  final int completedDays;
  final int habitLogStreak;
  final int possibleDays;
  final HabitModel? currentHabitDetail;

  HabitDetailState({
    this.status = HabitStatus.initial,
    this.errorMessage,
    this.habitLogs = const [],
    this.habitLogForThisMonth = const [],
    this.habitLogForThisWeek = const [],
    this.completedDays = 0,
    this.habitLogStreak = 0,
    this.possibleDays = 0,
    this.currentHabitDetail,
  });

  HabitDetailState copyWith({
    HabitStatus? status,
    String? errorMessage,
    List<HabitLogModel>? habitLogs,
    List<HabitLogModel>? habitLogForThisMonth,
    List<HabitLogModel>? habitLogForThisWeek,
    int? completedDays,
    int? habitLogStreak,
    int? possibleDays,
    HabitModel? currentHabitDetail,
  }) {
    return HabitDetailState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      habitLogs: habitLogs ?? this.habitLogs,
      habitLogForThisMonth: habitLogForThisMonth ?? this.habitLogForThisMonth,
      habitLogForThisWeek: habitLogForThisWeek ?? this.habitLogForThisWeek,
      completedDays: completedDays ?? this.completedDays,
      habitLogStreak: habitLogStreak ?? this.habitLogStreak,
      possibleDays: possibleDays ?? this.possibleDays,
      currentHabitDetail: currentHabitDetail ?? this.currentHabitDetail,
    );
  }
}

class HabitDetailViewModel extends StateNotifier<HabitDetailState> {
  final HabitApiService _habitApiService;

  HabitDetailViewModel(this._habitApiService) : super(HabitDetailState());

  void clearState() {
    state = HabitDetailState();
  }

  Future<HabitModel?> _getHabitById(int habitId) async {
    try {
      final response = await _habitApiService.getHabitDetail(habitId);
      return HabitModel.fromJson(response['data']);
    } catch (_) {
      return null;
    }
  }

  Future<List<HabitLogModel>> _getHabitLogs(int habitId) async {
    final response = await _habitApiService.getHabitLogs(habitId: habitId);
    final data = response['data'] as List? ?? [];
    return data
        .whereType<Map>()
        .map((json) => HabitLogModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> deleteHabit({required int habitId}) async {
    try {
      await _habitApiService.deleteHabit(habitId);
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to delete habit.',
      );
      rethrow;
    }
  }

  Future<void> loadHabitDetailData({required int habitId}) async {
    state = state.copyWith(status: HabitStatus.loading, errorMessage: null);

    try {
      final habitDetail = await _getHabitById(habitId);
      if (habitDetail == null) {
        throw Exception('Habit not found');
      }

      final logs = await _getHabitLogs(habitId);

      final monthLogs = _getLogsForCurrentMonth(logs);
      final weekLogs = _getLogsForCurrentWeek(logs);

      final completedDays = _countWeeklyCompletedDays(weekLogs);
      final possibleDays = _countWeeklyPossibleDays(
        habitDetail.startDate,
        habitDetail.endDate,
      );
      final streak = _calculateCurrentStreak(logs, habitDetail.startDate);

      state = state.copyWith(
        status: HabitStatus.success,
        currentHabitDetail: habitDetail,
        habitLogs: logs,
        habitLogForThisMonth: monthLogs,
        habitLogForThisWeek: weekLogs,
        completedDays: completedDays,
        possibleDays: possibleDays,
        habitLogStreak: streak,
      );
    } catch (e) {
      state = state.copyWith(
        status: HabitStatus.failure,
        errorMessage: 'Failed to load habit detail data.',
      );
    }
  }

  DateTime _dateOnly(DateTime date) {
    final local = dateOnlyInIndonesia(date);
    return DateTime(local.year, local.month, local.day);
  }

  List<HabitLogModel> _getLogsForCurrentMonth(List<HabitLogModel> logs) {
    final now = _dateOnly(nowInIndonesia());
    return logs.where((log) {
      final d = _dateOnly(log.logDate);
      return d.year == now.year && d.month == now.month;
    }).toList();
  }

  List<HabitLogModel> _getLogsForCurrentWeek(List<HabitLogModel> logs) {
    final now = _dateOnly(nowInIndonesia());
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return logs.where((log) {
      final date = _dateOnly(log.logDate);
      return !date.isBefore(startOfWeek) && !date.isAfter(endOfWeek);
    }).toList();
  }

  int _countWeeklyCompletedDays(List<HabitLogModel> weeklyLogs) {
    final successDates = weeklyLogs
        .where((log) => log.status == LogStatus.success)
        .map((log) => _dateOnly(log.logDate))
        .map((date) => date.toIso8601String())
        .toSet();

    return successDates.length;
  }

  int _countWeeklyPossibleDays(
    DateTime habitStartDate,
    DateTime? habitEndDate,
  ) {
    final today = _dateOnly(nowInIndonesia());
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    final normalizedStart = _dateOnly(habitStartDate);
    final normalizedEnd = habitEndDate != null ? _dateOnly(habitEndDate) : null;

    final effectiveStart = normalizedStart.isAfter(startOfWeek)
        ? normalizedStart
        : startOfWeek;

    final effectiveEndBase =
        normalizedEnd != null && normalizedEnd.isBefore(today)
        ? normalizedEnd
        : today;

    if (effectiveEndBase.isBefore(effectiveStart)) {
      return 0;
    }

    return effectiveEndBase.difference(effectiveStart).inDays + 1;
  }

  int _calculateCurrentStreak(
    List<HabitLogModel> logs,
    DateTime habitStartDate,
  ) {
    if (logs.isEmpty) return 0;

    final sorted = List<HabitLogModel>.from(logs)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final statusByDate = <String, LogStatus>{};
    for (final log in sorted) {
      final key = _dateOnly(log.logDate).toIso8601String();
      statusByDate[key] ??= log.status;
    }

    final today = _dateOnly(nowInIndonesia());
    final minDate = _dateOnly(habitStartDate);

    var streak = 0;
    var cursor = today;

    while (!cursor.isBefore(minDate)) {
      final key = cursor.toIso8601String();
      final status = statusByDate[key];

      if (status == LogStatus.success) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }

      break;
    }

    return streak;
  }

  // NOTE:
  // Untuk efisiensi data jangka panjang, idealnya backend menyediakan endpoint
  // query range (contoh: /habits/:id/logs?startDate=...&endDate=...) agar client
  // tidak perlu selalu mengambil seluruh log lalu memfilter di frontend.
}
