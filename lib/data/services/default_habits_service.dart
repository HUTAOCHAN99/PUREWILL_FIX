// lib/data/service/default_habits_service.dart
import 'package:flutter/material.dart';
import 'package:purewill/domain/model/habit_model.dart';

class DefaultHabitsService {
  static List<HabitModel> getDefaultHabits() {
    return [
      HabitModel(
        id: -1, // ID negatif untuk menandai default habit
        userId: 'default',
        name: 'Morning Workout',
        frequency: 'daily',
        startDate: DateTime.now(),
        targetValue: 30,
        isActive: true,
        status: 'neutral',
        isDefault: true,
      ),
      HabitModel(
        id: -2,
        userId: 'default',
        name: 'Read Books',
        frequency: 'daily',
        startDate: DateTime.now(),
        targetValue: 20,
        isActive: true,
        status: 'neutral',
        isDefault: true,
      ),
      HabitModel(
        id: -3,
        userId: 'default',
        name: 'Drink Water',
        frequency: 'daily',
        startDate: DateTime.now(),
        targetValue: 8,
        isActive: true,
        status: 'neutral',
        isDefault: true,
      ),
      HabitModel(
        id: -4,
        userId: 'default',
        name: 'Sleep Early',
        frequency: 'daily',
        startDate: DateTime.now(),
        targetValue: 1,
        isActive: true,
        status: 'neutral',
        isDefault: true,
      ),
    ];
  }

  static Map<String, IconData> getDefaultHabitIcons() {
    return {
      'Morning Workout': Icons.fitness_center,
      'Read Books': Icons.menu_book_rounded,
      'Drink Water': Icons.water_drop,
      'Sleep Early': Icons.nightlight_round,
    };
  }

  static Map<String, Color> getDefaultHabitColors() {
    return {
      'Morning Workout': Colors.green,
      'Read Books': Colors.green,
      'Drink Water': Colors.amber,
      'Sleep Early': Colors.blue,
    };
  }
}