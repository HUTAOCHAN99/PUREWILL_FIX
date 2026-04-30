import 'package:flutter/material.dart';
import 'package:purewill/domain/model/category_model.dart';
import 'package:purewill/utils/indonesia_timezone.dart';

enum TodayLogStatus { netural, success, failed }

TodayLogStatus _parseTodayLogStatus(dynamic value) {
  final raw = value?.toString().toLowerCase();
  switch (raw) {
    case 'success':
      return TodayLogStatus.success;
    case 'failed':
      return TodayLogStatus.failed;
    case 'neutral':
    case 'netural':
    default:
      return TodayLogStatus.netural;
  }
}

String _todayLogStatusToJson(TodayLogStatus status) {
  switch (status) {
    case TodayLogStatus.success:
      return 'success';
    case TodayLogStatus.failed:
      return 'failed';
    case TodayLogStatus.netural:
      return 'netural';
  }
}

class HabitModel {
  final int id;
  final String? userId;
  final String name;
  final String frequency;
  final DateTime startDate;
  final bool isActive;
  final CategoryModel? category;
  final String? notes;
  final DateTime? endDate;
  final int? targetValue;
  final String? unit;
  final int? unitId;
  final String status;
  final TodayLogStatus todayLogStatus;
  final bool reminderEnabled;
  final TimeOfDay? reminderTime;
  final bool isLocationLocked;
  final String? locationName;
  final double? targetLat;
  final double? targetLong;
  final int? radius;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  HabitModel({
    required this.id,
    this.userId,
    required this.name,
    required this.frequency,
    required this.startDate,
    this.isActive = true,
    this.category,
    this.notes,
    this.endDate,
    this.targetValue,
    this.unit,
    this.unitId,
    this.status = 'neutral',
    this.todayLogStatus = TodayLogStatus.netural,
    this.reminderEnabled = false,
    this.reminderTime,
    this.isLocationLocked = false,
    this.locationName,
    this.targetLat,
    this.targetLong,
    this.radius,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    int _parseInt(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    int? _parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    DateTime? _parseNullableDate(dynamic value) {
      return parseUtcToIndonesia(value, fallback: null);
    }

    CategoryModel? _parseCategory(
      dynamic categoryValue,
      dynamic categoryIdValue,
    ) {
      if (categoryValue is Map<String, dynamic>) {
        return CategoryModel.fromJson(categoryValue);
      }
      if (categoryValue is Map) {
        return CategoryModel.fromJson(Map<String, dynamic>.from(categoryValue));
      }

      final parsedId = _parseNullableInt(categoryIdValue);
      if (parsedId != null) {
        return CategoryModel(
          id: parsedId,
          name: 'Unknown',
          createdAt: nowInIndonesia(),
        );
      }
      return null;
    }

    TimeOfDay? parseReminderTime(dynamic time) {
      if (time is String) {
        final parts = time.split(':');
        if (parts.length == 2) {
          return TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
      return null;
    }

    TodayLogStatus _extractTodayLogStatus(Map<String, dynamic> source) {
      final now = nowInIndonesia();

      final habitLogsRaw = source['habitLogs'];
      if (habitLogsRaw is List && habitLogsRaw.isNotEmpty) {
        for (final entry in habitLogsRaw) {
          if (entry is Map) {
            final dateStr =
                entry['logDate'] ??
                entry['log_date'] ??
                entry['createdAt'] ??
                entry['created_at'];
            final parsed = parseUtcToIndonesia(dateStr, fallback: now);
            if (isSameIndonesiaDate(parsed, now)) {
              return _parseTodayLogStatus(entry['status']);
            }
          }
        }
        final first = habitLogsRaw.first;
        if (first is Map) {
          return _parseTodayLogStatus(first['status']);
        }
      }

      final logsRaw = source['logs'];
      if (logsRaw is List && logsRaw.isNotEmpty) {
        for (final entry in logsRaw) {
          if (entry is Map) {
            final dateStr =
                entry['logDate'] ??
                entry['log_date'] ??
                entry['createdAt'] ??
                entry['created_at'];
            final parsed = parseUtcToIndonesia(dateStr, fallback: now);
            if (isSameIndonesiaDate(parsed, now)) {
              return _parseTodayLogStatus(entry['status']);
            }
          }
        }
        final first = logsRaw.first;
        if (first is Map) {
          return _parseTodayLogStatus(first['status']);
        }
      }

      return _parseTodayLogStatus(source['status']);
    }

    String? _parseUnitName(dynamic unitValue) {
      if (unitValue is String) {
        return unitValue;
      }
      if (unitValue is Map) {
        return unitValue['name']?.toString();
      }
      return null;
    }

    int? _parseUnitId(dynamic unitIdValue, dynamic unitValue) {
      final fromUnitId = _parseNullableInt(unitIdValue);
      if (fromUnitId != null) {
        return fromUnitId;
      }
      if (unitValue is Map) {
        return _parseNullableInt(unitValue['id']);
      }
      return null;
    }

    return HabitModel(
      id: _parseInt(json['id']),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      frequency:
          (json['frequencyType'] ??
                  json['frecuency_type'] ??
                  json['frequency'] ??
                  'daily')
              .toString()
              .toLowerCase(),
      startDate:
          _parseNullableDate(json['startDate'] ?? json['start_date']) ??
          nowInIndonesia(),
      isActive: (json['isActive'] ?? json['is_active']) == true,
      category: _parseCategory(
        json['category'],
        json['categoryId'] ?? json['category_id'],
      ),
      notes: json['notes']?.toString(),
      endDate: _parseNullableDate(json['endDate'] ?? json['end_date']),
      targetValue: _parseNullableInt(
        json['targetValue'] ?? json['target_value'],
      ),
      unit: _parseUnitName(json['unit']),
      unitId: _parseUnitId(json['unitId'] ?? json['unit_id'], json['unit']),
      status: (json['status'] ?? 'neutral').toString().toLowerCase(),
      todayLogStatus: _extractTodayLogStatus(json),
      reminderEnabled:
          (json['reminderEnabled'] ?? json['reminder_enabled']) == true,
      reminderTime: parseReminderTime(
        json['reminderTime'] ?? json['reminder_time'],
      ),
      isLocationLocked:
          (json['isLocationLocked'] ?? json['is_location_locked']) == true,
      locationName:
          json['locationName']?.toString() ?? json['location_name']?.toString(),
      targetLat: json['targetLat'] is num
          ? (json['targetLat'] as num).toDouble()
          : (json['target_lat'] is num
                ? (json['target_lat'] as num).toDouble()
                : null),
      targetLong: json['targetLong'] is num
          ? (json['targetLong'] as num).toDouble()
          : (json['target_long'] is num
                ? (json['target_long'] as num).toDouble()
                : null),
      radius: _parseNullableInt(
        json['radius'] ?? json['radious'] ?? json['radius'],
      ),
      isDefault: (json['isDefault'] ?? json['is_default']) == true,
      createdAt: _parseNullableDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseNullableDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'userId': userId,
      'name': name,
      'frequencyType': frequency.toUpperCase(),
      'startDate': startDate.toIso8601String(),
      'isActive': isActive,
      'status': status,
      'todayLogStatus': _todayLogStatusToJson(todayLogStatus),
      'reminderEnabled': reminderEnabled,
      'isDefault': isDefault,
    };

    if (reminderTime != null) {
      json['reminderTime'] =
          '${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}';
    }

    if (category != null) {
      json['categoryId'] = category!.id;
    }
    if (notes != null) {
      json['notes'] = notes!;
    }
    if (endDate != null) {
      json['endDate'] = endDate!.toIso8601String();
    }
    if (targetValue != null) {
      json['targetValue'] = targetValue!;
    }
    if (unit != null) {
      json['unit'] = unit!;
    }
    if (unitId != null) {
      json['unitId'] = unitId!;
    }
    json['isLocationLocked'] = isLocationLocked;
    if (locationName != null) {
      json['locationName'] = locationName!;
    }
    if (targetLat != null) {
      json['targetLat'] = targetLat!;
    }
    if (targetLong != null) {
      json['targetLong'] = targetLong!;
    }
    if (radius != null) {
      json['radius'] = radius!;
    }
    if (createdAt != null) {
      json['createdAt'] = createdAt!.toIso8601String();
    }
    if (updatedAt != null) {
      json['updatedAt'] = updatedAt!.toIso8601String();
    }

    return json;
  }

  @override
  String toString() {
    return 'HabitModel{id: $id, name: $name, targetValue: $targetValue, unit: $unit, isDefault: $isDefault}';
  }
}
