// lib/domain/model/target_unit_model.dart

class TargetUnitModel {
  final int id;
  final String name;
  final String? abbreviation;  // ✅ TAMBAHKAN
  final DateTime createdAt;
  final DateTime? updatedAt;    // ✅ TAMBAHKAN

  TargetUnitModel({
    required this.id,
    required this.name,
    this.abbreviation,
    required this.createdAt,
    this.updatedAt,
  });

  factory TargetUnitModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is String) {
        return DateTime.parse(date);
      }
      return DateTime.now();
    }

    return TargetUnitModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      abbreviation: json['abbreviation']?.toString(),
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: json['updated_at'] != null || json['updatedAt'] != null
          ? parseDate(json['updated_at'] ?? json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (abbreviation != null) 'abbreviation': abbreviation,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'TargetUnitModel{id: $id, name: $name, abbreviation: $abbreviation}';
  }
}