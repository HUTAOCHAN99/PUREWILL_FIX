// lib/data/repository/target_unit_repository.dart

import 'dart:developer';
import 'package:purewill/data/services/habits/habit_api_service.dart';
import 'package:purewill/domain/model/target_unit_model.dart';

class TargetUnitRepository {
  final HabitApiService _apiService;

  TargetUnitRepository(this._apiService);

  Future<List<TargetUnitModel>> fetchUserTargetUnits(String userId) async {
    try {
      log('📦 FETCH TARGET UNITS for user: $userId', name: 'TARGET_UNIT_REPO');
      
      final response = await _apiService.getUnits();
      final data = response['data'] as List? ?? [];
      
      log('✅ FETCH TARGET UNITS SUCCESS: ${data.length} units found', name: 'TARGET_UNIT_REPO');
      
      return data.map((json) => TargetUnitModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      log('❌ FETCH TARGET UNITS FAILURE', error: e, stackTrace: stackTrace, name: 'TARGET_UNIT_REPO');
      return [];
    }
  }

  Future<TargetUnitModel> createTargetUnit(String nameTargetUnit) async {
    try {
      log('🔧 DEBUG: createTargetUnit - name: $nameTargetUnit', name: 'TARGET_UNIT_REPO');
      
      // Note: Endpoint untuk create unit mungkin belum ada di backend
      // Ini adalah debug version yang simpan di local
      throw UnimplementedError('Create target unit endpoint not available in backend yet');
    } catch (e, stackTrace) {
      log('❌ CREATE TARGET UNIT FAILURE', error: e, stackTrace: stackTrace, name: 'TARGET_UNIT_REPO');
      rethrow;
    }
  }
}