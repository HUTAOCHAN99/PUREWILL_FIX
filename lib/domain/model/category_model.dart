class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final bool isDefault;
  final String? color;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? userId;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.isDefault = false,
    this.color,
    required this.createdAt,
    this.updatedAt,
    this.userId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic date) {
      if (date is String) {
        return DateTime.parse(date);
      }
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic date) {
      if (date is String) {
        return DateTime.tryParse(date);
      }
      return null;
    }

    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    final category = CategoryModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? 'Unknown',
      description: json['description']?.toString(),
      isDefault: (json['isDefault'] ?? json['is_default']) == true,
      color: json['color']?.toString(),
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: parseNullableDate(json['updatedAt'] ?? json['updated_at']),
      userId: parseNullableInt(json['userId'] ?? json['user_id']),
    );
    return category;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isDefault': isDefault,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userId': userId,
    };
  }

  @override
  String toString() {
    return 'CategoryModel{id: $id, name: $name}';
  }
}
