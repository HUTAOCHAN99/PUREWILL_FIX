class NofapSessionModel {
  final int id;
  final DateTime startDate;
  final DateTime? endDate;
  final String? relapseNotes;
  final int userId;

  const NofapSessionModel({
    required this.id,
    required this.startDate,
    this.endDate,
    this.relapseNotes,
    required this.userId,
  });

  bool get isActive => endDate == null;

  factory NofapSessionModel.fromJson(Map<String, dynamic> json) {
    return NofapSessionModel(
      id: _parseInt(json['id']),
      startDate: DateTime.parse(json['startDate'].toString()),
      endDate: json['endDate'] == null
          ? null
          : DateTime.tryParse(json['endDate'].toString()),
      relapseNotes: json['relapseNotes']?.toString(),
      userId: _parseInt(json['userId']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
