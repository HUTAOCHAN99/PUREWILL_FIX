// // lib/data/repository/daily_log_repository.dart

// import 'dart:developer';
// import 'package:purewill/domain/model/habit_log_model.dart';
// import 'package:purewill/domain/model/habit_model.dart';

// class DailyLogRepository {
//   // Local storage untuk debug
//   static final Map<int, List<HabitLogModel>> _localLogs = {};
//   static int _nextId = 1;

//   DailyLogRepository();

//   void _logNotImplemented(String mechanism) {
//     log(
//       '$mechanism: belum di impelemtnasikan di habit service',
//       name: 'HABIT_SERVICE_MIGRATION',
//     );
//   }

//   Future<void> addLogsForNewHabit(HabitModel habit) async {
//     _logNotImplemented('daily log addLogsForNewHabit');
//     return Future.value();
//   }

//   // ✅ PERBAIKI: actualValue dari double? menjadi int?
//   Future<HabitLogModel> recordLog({
//     required int habitId,
//     required DateTime date,
//     required LogStatus status,
//     int? actualValue, // ✅ UBAH dari double? ke int?
//   }) async {
//     _logNotImplemented('daily log recordLog');

//     final logs = _localLogs[habitId] ?? [];
//     final existingIndex = logs.indexWhere(
//       (log) =>
//           log.logDate.year == date.year &&
//           log.logDate.month == date.month &&
//           log.logDate.day == date.day,
//     );

//     if (existingIndex != -1) {
//       final updated = logs[existingIndex].copyWith(
//         status: status,
//         actualValue: actualValue,
//       );
//       logs[existingIndex] = updated;
//       return updated;
//     }

//     final newLog = HabitLogModel(
//       id: _nextId++,
//       habitId: habitId,
//       logDate: date,
//       status: status,
//       actualValue: actualValue,
//       createdAt: DateTime.now(),
//     );

//     _localLogs[habitId] = [...logs, newLog];
//     return newLog;
//   }

//   Future<List<HabitLogModel>> fetchLogsByHabit(int habitId) async {
//     _logNotImplemented('daily log fetchLogsByHabit');
//     return _localLogs[habitId] ?? [];
//   }

//   Future<int> fetchHabitLogStreak(int habitId) async {
//     _logNotImplemented('daily log fetchHabitLogStreak');
//     final logs = _localLogs[habitId] ?? [];
//     if (logs.isEmpty) return 0;

//     final sortedLogs = List<HabitLogModel>.from(logs)
//       ..sort((a, b) => b.logDate.compareTo(a.logDate));

//     int streak = 0;
//     final now = DateTime.now();
//     DateTime currentDate = DateTime(now.year, now.month, now.day);

//     for (var log in sortedLogs) {
//       final logDate = DateTime(
//         log.logDate.year,
//         log.logDate.month,
//         log.logDate.day,
//       );
//       if (logDate == currentDate && log.status == LogStatus.success) {
//         streak++;
//         currentDate = currentDate.subtract(const Duration(days: 1));
//       } else if (logDate == currentDate && log.status != LogStatus.success) {
//         break;
//       } else if (logDate != currentDate) {
//         break;
//       }
//     }

//     return streak;
//   }

//   Future<List<HabitLogModel>> fetchLogsByDateRange({
//     required int habitId,
//     required DateTime startDate,
//     required DateTime endDate,
//   }) async {
//     _logNotImplemented('daily log fetchLogsByDateRange');
//     final logs = _localLogs[habitId] ?? [];
//     return logs.where((log) {
//       return log.logDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
//           log.logDate.isBefore(endDate.add(const Duration(days: 1)));
//     }).toList();
//   }

//   Future<List<HabitLogModel>> fetchLogsByDate(DateTime date) async {
//     _logNotImplemented('daily log fetchLogsByDate');
//     final allLogs = _localLogs.values.expand((logs) => logs).toList();
//     return allLogs.where((log) {
//       return log.logDate.year == date.year &&
//           log.logDate.month == date.month &&
//           log.logDate.day == date.day;
//     }).toList();
//   }

//   Future<HabitLogModel?> getTodayLogForHabit(int habitId) async {
//     _logNotImplemented('daily log getTodayLogForHabit');
//     final today = DateTime.now();
//     final logs = _localLogs[habitId] ?? [];
//     try {
//       return logs.firstWhere(
//         (log) =>
//             log.logDate.year == today.year &&
//             log.logDate.month == today.month &&
//             log.logDate.day == today.day,
//       );
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<void> deleteLogsByHabit(int habitId) async {
//     _logNotImplemented('daily log deleteLogsByHabit');
//     _localLogs.remove(habitId);
//   }

//   Future<void> deleteLogsBeforeDate({
//     required int habitId,
//     required DateTime date,
//   }) async {
//     _logNotImplemented('daily log deleteLogsBeforeDate');
//     final logs = _localLogs[habitId] ?? [];
//     _localLogs[habitId] = logs
//         .where((log) => log.logDate.isAfter(date))
//         .toList();
//   }

//   Future<void> deleteLogsAfterDate({
//     required int habitId,
//     required DateTime date,
//   }) async {
//     _logNotImplemented('daily log deleteLogsAfterDate');
//     final logs = _localLogs[habitId] ?? [];
//     _localLogs[habitId] = logs
//         .where((log) => log.logDate.isBefore(date))
//         .toList();
//   }
// }

// // ✅ PERBAIKI: Extension helper - actualValue dari double? menjadi int?
// extension HabitLogModelCopyWith on HabitLogModel {
//   HabitLogModel copyWith({
//     int? id,
//     int? habitId,
//     DateTime? logDate,
//     LogStatus? status,
//     int? actualValue, // ✅ UBAH dari double? ke int?
//     DateTime? createdAt,
//   }) {
//     return HabitLogModel(
//       id: id ?? this.id,
//       habitId: habitId ?? this.habitId,
//       logDate: logDate ?? this.logDate,
//       status: status ?? this.status,
//       actualValue: actualValue ?? this.actualValue,
//       createdAt: createdAt ?? this.createdAt,
//     );
//   }
// }
