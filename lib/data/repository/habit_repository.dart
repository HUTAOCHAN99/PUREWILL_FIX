// lib/data/repository/habit_repository.dart

import 'dart:developer';
import 'package:purewill/data/services/habits/habit_api_service.dart';
import 'package:purewill/domain/model/habit_model.dart';

class HabitRepository {
  final HabitApiService _apiService;

  HabitRepository(this._apiService);

  Future<HabitModel> createHabit(HabitModel habit) async {
    try {
      final response = await _apiService.createHabit(habit);
      return HabitModel.fromJson(response['data']);
    } catch (e, stackTrace) {
      log('CREATE HABIT FAILURE: ${habit.name}', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<HabitModel>> fetchUserHabits(String userId) async {
    try {
      final response = await _apiService.getUserHabits(userId);
      final data = response['data'] as List? ?? [];
      return data.map((json) => HabitModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      log('FETCH HABITS FAILURE', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Future<HabitModel> initializeDefaultHabitsForUser(String userId) async {
    try {
      final defaultHabit = HabitModel(
        id: 0,
        userId: userId,
        frequency: 'DAILY',
        name: 'NoFap',
        notes: 'Track your NoFap journey',
        categoryId: 1,
        targetValue: 1,
        unit: 'day',
        startDate: DateTime.now(),
        endDate: null,
        isActive: false,
        isDefault: true,
      );
      return await createHabit(defaultHabit);
    } catch (e, stackTrace) {
      log('INITIALIZE DEFAULT HABITS FAILURE', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<HabitModel> activeNofapHabit(String userId, int habitId) async {
    try {
      final response = await _apiService.updateHabit(habitId, {'isActive': true});
      return HabitModel.fromJson(response['data']);
    } catch (e, stackTrace) {
      log('ACTIVATE NOFAP HABIT FAILURE', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<HabitModel> deactivateNofapHabit(String userId, int habitId) async {
    try {
      final response = await _apiService.updateHabit(habitId, {'isActive': false});
      return HabitModel.fromJson(response['data']);
    } catch (e, stackTrace) {
      log('DEACTIVATE NOFAP HABIT FAILURE', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<int> getNofapHabitId(String userId) async {
    try {
      final habits = await fetchUserHabits(userId);
      final nofapHabit = habits.firstWhere(
        (h) => h.name.toLowerCase() == 'nofap',
        orElse: () => throw Exception('NoFap habit not found'),
      );
      return nofapHabit.id;
    } catch (e, stackTrace) {
      log('GET NOFAP HABIT ID FAILURE', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<HabitModel>> fetchTodayUserHabits(String userId) async {
    try {
      final habits = await fetchUserHabits(userId);
      return habits.where((h) => h.isActive == true).toList();
    } catch (e, stackTrace) {
      log('FETCH TODAY HABITS FAILURE', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateHabitStatus({
    required int habitId,
    required String status,
  }) async {
    try {
      await _apiService.updateHabit(habitId, {'status': status});
    } catch (e, stackTrace) {
      log('UPDATE HABIT STATUS FAILURE', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateHabit({
    required int habitId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _apiService.updateHabit(habitId, updates);
    } catch (e, stackTrace) {
      log('UPDATE HABIT FAILURE', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteHabit(int habitId) async {
    try {
      await _apiService.deleteHabit(habitId);
    } catch (e, stackTrace) {
      log('DELETE HABIT FAILURE', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<HabitModel?> getHabitById(int habitId) async {
    try {
      final response = await _apiService.getHabitDetail(habitId);
      return HabitModel.fromJson(response['data']);
    } catch (e, stackTrace) {
      log('GET HABIT BY ID FAILURE', error: e, stackTrace: stackTrace);
      return null;
    }
  }
}