// lib\ui\habit-tracker\utils\habit_icon_helper.dart
import 'package:flutter/material.dart';

class HabitIconHelper {
  static IconData getHabitIcon(String habitName) {
    final name = habitName.toLowerCase();
    
    if (name.contains('read') || name.contains('book')) {
      return Icons.menu_book;
    } else if (name.contains('meditation') || name.contains('yoga') || name.contains('mindfulness')) {
      return Icons.self_improvement;
    } else if (name.contains('water') || name.contains('drink') || name.contains('hydration')) {
      return Icons.local_drink;
    } else if (name.contains('exercise') || name.contains('workout') || name.contains('gym') || name.contains('fitness')) {
      return Icons.fitness_center;
    } else if (name.contains('study') || name.contains('learn') || name.contains('bus')) {
      return Icons.school;
    } else if (name.contains('morning') || name.contains('wake') || name.contains('worsnet')) {
      return Icons.wb_sunny;
    } else if (name.contains('gazebo') || name.contains('garden') || name.contains('plant')) {
      return Icons.nature;
    } else if (name.contains('crime') || name.contains('security') || name.contains('safety')) {
      return Icons.security;
    } else if (name.contains('money') || name.contains('finance') || name.contains('budget')) {
      return Icons.attach_money;
    } else if (name.contains('exhaust') || name.contains('energy') || name.contains('tired')) {
      return Icons.energy_savings_leaf;
    } else {
      return Icons.check_circle;
    }
  }

  static Color getHabitColor(String habitName) {
    final name = habitName.toLowerCase();
    
    if (name.contains('read') || name.contains('book')) {
      return const Color(0xFF2196F3); // Blue
    } else if (name.contains('meditation') || name.contains('yoga') || name.contains('mindfulness')) {
      return const Color(0xFF9C27B0); // Purple
    } else if (name.contains('water') || name.contains('drink') || name.contains('hydration')) {
      return const Color(0xFF00BCD4); // Cyan
    } else if (name.contains('exercise') || name.contains('workout') || name.contains('gym') || name.contains('fitness')) {
      return const Color(0xFFFF5722); // Deep Orange
    } else if (name.contains('study') || name.contains('learn') || name.contains('bus')) {
      return const Color(0xFF673AB7); // Deep Purple
    } else if (name.contains('morning') || name.contains('wake') || name.contains('worsnet')) {
      return const Color(0xFFFF9800); // Orange
    } else if (name.contains('gazebo') || name.contains('garden') || name.contains('plant')) {
      return const Color(0xFF4CAF50); // Green
    } else if (name.contains('crime') || name.contains('security') || name.contains('safety')) {
      return const Color(0xFFF44336); // Red
    } else if (name.contains('money') || name.contains('finance') || name.contains('budget')) {
      return const Color(0xFFFFC107); // Amber
    } else if (name.contains('exhaust') || name.contains('energy') || name.contains('tired')) {
      return const Color(0xFF795548); // Brown
    } else {
      return const Color(0xFF607D8B); // Blue Grey (default)
    }
  }

  static String getHabitCategory(String habitName) {
    final name = habitName.toLowerCase();
    
    if (name.contains('read') || name.contains('book') || name.contains('study') || name.contains('learn')) {
      return "Education";
    } else if (name.contains('meditation') || name.contains('yoga') || name.contains('mindfulness')) {
      return "Wellness";
    } else if (name.contains('water') || name.contains('drink') || name.contains('hydration')) {
      return "Health";
    } else if (name.contains('exercise') || name.contains('workout') || name.contains('gym') || name.contains('fitness')) {
      return "Fitness";
    } else if (name.contains('morning') || name.contains('wake') || name.contains('worsnet')) {
      return "Routine";
    } else if (name.contains('gazebo') || name.contains('garden') || name.contains('plant')) {
      return "Home";
    } else if (name.contains('crime') || name.contains('security') || name.contains('safety')) {
      return "Safety";
    } else if (name.contains('money') || name.contains('finance') || name.contains('budget')) {
      return "Finance";
    } else if (name.contains('exhaust') || name.contains('energy') || name.contains('tired')) {
      return "Energy";
    } else {
      return "General";
    }
  }
}