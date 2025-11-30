// lib\data\services\performance_service.dart
import 'package:flutter/foundation.dart';
import 'package:purewill/data/repository/habit_repository.dart';

class PerformanceService {
  final HabitRepository _habitRepository;

  PerformanceService(this._habitRepository);

  Future<List<double>> getWeeklyPerformance(int habitId) async {
    try {
      // Untuk sementara, return data dummy
      // Nanti bisa diganti dengan implementasi sebenarnya
      debugPrint('Getting weekly performance for habit: $habitId');
      
      // Return data dummy (7 hari dengan nilai random)
      return List.generate(7, (index) => 0.0);
      
    } catch (e) {
      debugPrint('Error in PerformanceService: $e');
      return List.filled(7, 0.0);
    }
  }
}