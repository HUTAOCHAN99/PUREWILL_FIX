import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/services/habits/habit_api_service.dart';
import 'package:purewill/data/services/me/me_api_service.dart';
import 'package:purewill/domain/model/category_model.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/target_unit_model.dart';

enum AddHabitStatus { initial, loading, success, failure, submitting }

class AddHabitState {
  final AddHabitStatus status;
  final String? errorMessage;
  final List<CategoryModel> categories;
  final List<TargetUnitModel> units;

  AddHabitState({
    this.status = AddHabitStatus.initial,
    this.errorMessage,
    this.categories = const [],
    this.units = const [],
  });

  AddHabitState copyWith({
    AddHabitStatus? status,
    String? errorMessage,
    List<CategoryModel>? categories,
    List<TargetUnitModel>? units,
  }) {
    return AddHabitState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      categories: categories ?? this.categories,
      units: units ?? this.units,
    );
  }
}

class AddHabitViewModel extends StateNotifier<AddHabitState> {
  final HabitApiService _habitApiService;
  final MeApiService _meApiService;

  AddHabitViewModel(this._habitApiService, this._meApiService)
    : super(AddHabitState());

  Future<void> loadCategories() async {
    state = state.copyWith(status: AddHabitStatus.loading, errorMessage: null);

    try {
      final response = await _meApiService.getMeCategories();
      final data = response['data'] as List? ?? [];

      final categories = data
          .whereType<Map>()
          .map(
            (json) => CategoryModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();

      state = state.copyWith(
        status: AddHabitStatus.success,
        categories: categories,
      );
    } catch (e) {
      state = state.copyWith(
        status: AddHabitStatus.failure,
        errorMessage: 'Failed to load categories.',
      );
    }
  }

  Future<void> loadUnits() async {
    try {
      final response = await _habitApiService.getUnits();
      final data = response['data'] as List? ?? [];

      final units = data
          .whereType<Map>()
          .map(
            (json) => TargetUnitModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();

      state = state.copyWith(units: units);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to load units.');
    }
  }

  Future<void> addHabit({
    required String name,
    required String frequency,
    required DateTime startDate,
    DateTime? endDate,
    int? categoryId,
    int? unitId,
    String? notes,
    int? targetValue,
    bool? reminderEnabled,
    TimeOfDay? reminderTime,
  }) async {
    final previousStatus = state.status;
    state = state.copyWith(
      status: AddHabitStatus.submitting,
      errorMessage: null,
    );

    try {
      final selectedCategory = categoryId != null
          ? state.categories
                .where((category) => category.id == categoryId)
                .cast<CategoryModel?>()
                .firstWhere((category) => category != null, orElse: () => null)
          : null;

      final newHabit = HabitModel(
        id: 0,
        name: name,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        isActive: true,
        category: selectedCategory,
        unitId: unitId,
        targetValue: targetValue,
        status: 'neutral',
        notes: notes,
        reminderEnabled: reminderEnabled ?? false,
        reminderTime: reminderTime,
      );

      await _habitApiService.createHabit(newHabit);

      state = state.copyWith(status: AddHabitStatus.success);
    } catch (e) {
      state = state.copyWith(
        status: AddHabitStatus.failure,
        errorMessage: 'Failed to add new habit.',
      );
      rethrow;
    } finally {
      if (state.status != AddHabitStatus.failure) {
        state = state.copyWith(status: previousStatus);
      }
    }
  }
}
