class DailyLogModel {
  final int id;
  final int habitId;
  final DateTime logDate;
  final bool isCompleted;
  final double? actualValue;
  final String? notes;

  DailyLogModel({
    required this.id,
    required this.habitId,
    required this.logDate,
    required this.isCompleted,
    this.actualValue,
    this.notes,
  });

  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      id: json['id'],
      habitId: json['habit_id'],
      logDate: DateTime.parse(json['log_date']),
      isCompleted: json['is_completed'],
      actualValue: json['actual_value']?.toDouble(), 
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'log_date': logDate.toIso8601String().substring(
        0,
        10,
      ), // Hanya tanggal (YYYY-MM-DD)
      'is_completed': isCompleted,
      'actual_value': actualValue,
      'notes': notes,
    };
  }
}