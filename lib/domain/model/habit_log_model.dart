enum LogStatus { neutral, success, failed }

class HabitLogModel {
  final int id;
  final int habitId;
  final LogStatus status;
  final DateTime logDate;
  final int? actualValue;
  final DateTime createdAt;

  HabitLogModel({
    required this.id,
    required this.habitId,
    required this.status,
    required this.logDate,
    this.actualValue,
    required this.createdAt,
  });

  static LogStatus parseLogStatus(String statusString) {
    switch (statusString.toLowerCase()) {
      case "success":
        return LogStatus.success;
      case "neutral":
        return LogStatus.neutral;
      case "failed":
        return LogStatus.failed;
      default:
        return LogStatus.neutral;
    }
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  factory HabitLogModel.fromJson(Map<String, dynamic> json) {
    return HabitLogModel(
      id: _parseInt(json['id']),
      habitId: _parseInt(json['habitId'] ?? json['habit_id']),
      status: parseLogStatus((json['status'] ?? 'neutral').toString()),
      logDate: _parseDate(json['logDate'] ?? json['log_date']),
      actualValue: _parseInt(json['actualValue'] ?? json['actual_value']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'status': status.name,
      'log_date': logDate.toIso8601String(),
      'actual_value': actualValue,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
