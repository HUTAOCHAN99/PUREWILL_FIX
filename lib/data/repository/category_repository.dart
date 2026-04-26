// lib/data/repository/category_repository.dart

import 'dart:developer';
import 'package:purewill/data/services/habits/habit_api_service.dart';
import 'package:purewill/domain/model/category_model.dart';

class CategoryRepository {
  final HabitApiService _apiService;

  CategoryRepository(this._apiService);

  Future<List<CategoryModel>> fetchCategories(String userId) async {
    try {
      log('📦 FETCH CATEGORIES for user: $userId', name: 'CATEGORY_REPO');
      
      final response = await _apiService.getUserCategories(userId);
      final data = response['data'] as List? ?? [];
      
      log('✅ FETCH CATEGORIES SUCCESS: ${data.length} categories found', name: 'CATEGORY_REPO');
      
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      log('❌ FETCH CATEGORIES FAILURE', error: e, stackTrace: stackTrace, name: 'CATEGORY_REPO');
      return [];
    }
  }

  Future<CategoryModel> createCategory(String name, {String? description}) async {
    try {
      log('📦 CREATE CATEGORY: name=$name', name: 'CATEGORY_REPO');
      
      final response = await _apiService.createCategory(name, description: description);
      final category = CategoryModel.fromJson(response['data']);
      
      log('✅ CREATE CATEGORY SUCCESS: id=${category.id}', name: 'CATEGORY_REPO');
      return category;
    } catch (e, stackTrace) {
      log('❌ CREATE CATEGORY FAILURE', error: e, stackTrace: stackTrace, name: 'CATEGORY_REPO');
      rethrow;
    }
  }

  Future<CategoryModel> updateCategory(int id, {String? name, String? description}) async {
    try {
      log('📦 UPDATE CATEGORY: id=$id', name: 'CATEGORY_REPO');
      
      final response = await _apiService.updateCategory(id, name: name, description: description);
      final category = CategoryModel.fromJson(response['data']);
      
      log('✅ UPDATE CATEGORY SUCCESS: id=${category.id}', name: 'CATEGORY_REPO');
      return category;
    } catch (e, stackTrace) {
      log('❌ UPDATE CATEGORY FAILURE', error: e, stackTrace: stackTrace, name: 'CATEGORY_REPO');
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      log('📦 DELETE CATEGORY: id=$id', name: 'CATEGORY_REPO');
      
      await _apiService.deleteCategory(id);
      
      log('✅ DELETE CATEGORY SUCCESS: id=$id', name: 'CATEGORY_REPO');
    } catch (e, stackTrace) {
      log('❌ DELETE CATEGORY FAILURE', error: e, stackTrace: stackTrace, name: 'CATEGORY_REPO');
      rethrow;
    }
  }

  Future<CategoryModel?> getCategoryById(int id, String userId) async {
    try {
      final categories = await fetchCategories(userId);
      return categories.firstWhere(
        (category) => category.id == id,
        orElse: () => throw Exception('Category not found'),
      );
    } catch (e, stackTrace) {
      log('❌ GET CATEGORY BY ID FAILURE', error: e, stackTrace: stackTrace, name: 'CATEGORY_REPO');
      return null;
    }
  }
}