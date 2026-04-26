// lib/data/repository/habit_session_repository.dart

import 'dart:developer';

class HabitSessionModel {
  final int id;
  final int habitId;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final int? finalStreakLength;
  final String? relapseNotes;
  final bool isActive;

  HabitSessionModel({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.finalStreakLength,
    this.relapseNotes,
    required this.isActive,
  });

  factory HabitSessionModel.fromJson(Map<String, dynamic> json) {
    return HabitSessionModel(
      id: json['id'] as int,
      habitId: json['habitId'] as int? ?? json['habit_id'] as int? ?? 0,
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      finalStreakLength: json['finalStreakLength'] as int?,
      relapseNotes: json['relapseNotes'] as String?,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? false,
    );
  }
}

class HabitSessionRepository {
  static HabitSessionModel? _activeSession;
  static final List<HabitSessionModel> _sessionHistory = [];
  static int _nextId = 1;

  HabitSessionRepository();

  Future<HabitSessionModel> addHabitSession({
    required int habitId,
    required String userId,
    required DateTime startDate,
  }) async {
    log('🔧 DEBUG: addHabitSession - habitId: $habitId, userId: $userId',
        name: 'HABIT_SESSION_DEBUG');

    if (_activeSession != null) {
      _activeSession = _activeSession!.copyWith(
        endDate: startDate,
        isActive: false,
      );
      _sessionHistory.add(_activeSession!);
    }

    _activeSession = HabitSessionModel(
      id: _nextId++,
      habitId: habitId,
      userId: userId,
      startDate: startDate,
      isActive: true,
    );

    return _activeSession!;
  }

  Future<HabitSessionModel> updateHabitSession({
    required int sessionId,
    DateTime? endDate,
    int? finalStreakLength,
    String? relapseNotes,
    bool? isActive,
  }) async {
    log('🔧 DEBUG: updateHabitSession - sessionId: $sessionId',
        name: 'HABIT_SESSION_DEBUG');

    if (_activeSession?.id == sessionId) {
      _activeSession = _activeSession!.copyWith(
        endDate: endDate,
        finalStreakLength: finalStreakLength,
        relapseNotes: relapseNotes,
        isActive: isActive ?? false,
      );
      if (isActive == false && _activeSession != null) {
        _sessionHistory.add(_activeSession!);
        final completed = _activeSession;
        _activeSession = null;
        return completed!;
      }
      return _activeSession!;
    }

    final index = _sessionHistory.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      final old = _sessionHistory[index];
      final updated = old.copyWith(
        endDate: endDate,
        finalStreakLength: finalStreakLength,
        relapseNotes: relapseNotes,
        isActive: isActive ?? old.isActive,
      );
      _sessionHistory[index] = updated;
      return updated;
    }

    throw Exception('Session not found');
  }

  Future<int> fetchNofapHabitLongestStreak({
    required int habitId,
    required String userId,
  }) async {
    int longest = 0;
    for (var session in _sessionHistory) {
      if (session.finalStreakLength != null && session.finalStreakLength! > longest) {
        longest = session.finalStreakLength!;
      }
    }
    if (_activeSession != null && _activeSession!.isActive) {
      final current = DateTime.now().difference(_activeSession!.startDate).inDays;
      if (current > longest) longest = current;
    }
    return longest;
  }

  Future<int> fetchNofapHabitCurrentStreak({
    required int habitId,
    required String userId,
  }) async {
    if (_activeSession != null && _activeSession!.isActive) {
      return DateTime.now().difference(_activeSession!.startDate).inDays;
    }
    return 0;
  }

  Future<int> getRelapseCount({
    required int habitId,
    required String userId,
  }) async {
    return _sessionHistory.length;
  }

  Future<List<DateTime>> getSuccessDays({
    required int habitId,
    required String userId,
  }) async {
    final successDays = <DateTime>[];
    for (var session in _sessionHistory) {
      if (session.finalStreakLength != null && session.finalStreakLength! > 0) {
        for (int i = 0; i < session.finalStreakLength!; i++) {
          successDays.add(session.startDate.add(Duration(days: i)));
        }
      }
    }
    return successDays;
  }

  Future<void> deleteHabitSession({required int sessionId}) async {
    if (_activeSession?.id == sessionId) {
      _activeSession = null;
    } else {
      _sessionHistory.removeWhere((s) => s.id == sessionId);
    }
  }

  Future<HabitSessionModel?> getActiveHabitSession({
    required int habitId,
    required String userId,
  }) async {
    if (_activeSession != null && _activeSession!.isActive) {
      return _activeSession;
    }
    return null;
  }

  Future<List<HabitSessionModel>> getHabitSessionHistory({
    required int habitId,
    required String userId,
  }) async {
    return _sessionHistory;
  }
}

// Extension helper
extension HabitSessionModelCopyWith on HabitSessionModel {
  HabitSessionModel copyWith({
    int? id,
    int? habitId,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? finalStreakLength,
    String? relapseNotes,
    bool? isActive,
  }) {
    return HabitSessionModel(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      finalStreakLength: finalStreakLength ?? this.finalStreakLength,
      relapseNotes: relapseNotes ?? this.relapseNotes,
      isActive: isActive ?? this.isActive,
    );
  }
}