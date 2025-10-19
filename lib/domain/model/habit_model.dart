class HabitModel {
  final int id;
  final String userId;
  final String name;
  final String frequency;
  final DateTime startDate;
  final bool isCompleted;

  HabitModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.frequency,
    required this.startDate,
    required this.isCompleted,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      frequency: json['frequency'],
      // Supabase mengembalikan format String, perlu di-parse
      startDate: DateTime.parse(json['start_date']),
      isCompleted: json['is_completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'frequency': frequency,
      // Format tanggal ke String ISO 8601
      'start_date': startDate.toIso8601String(),
      'is_completed': isCompleted,
    };
  }
}