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
      startDate: _parseRequiredDateTime(
        json['startDate'],
        fallback: DateTime.now(),
      ),
      endDate: _parseOptionalDateTime(json['endDate']),
      relapseNotes: json['relapseNotes']?.toString(),
      userId: _parseInt(json['userId']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseRequiredDateTime(
    dynamic value, {
    required DateTime fallback,
  }) {
    final parsed = _parseOptionalDateTime(value);
    return parsed ?? fallback;
  }

  static DateTime? _parseOptionalDateTime(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;

    return DateTime.tryParse(text);
  }
}
