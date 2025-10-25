import 'dart:developer';
import 'package:purewill/domain/model/category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryRepository {
  final SupabaseClient _supabaseClient;
  static const String _categoryTableName = 'categories';

  CategoryRepository(this._supabaseClient);

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      print('=== FETCHING CATEGORIES FROM SUPABASE ===');
      print('Table: $_categoryTableName');
      print('Supabase Client: ${_supabaseClient != null}');
      
      final response = await _supabaseClient
          .from(_categoryTableName)
          .select('*')
          .order('name', ascending: true);

      print('=== CATEGORIES RAW RESPONSE ===');
      print('Type: ${response.runtimeType}');
      print('Length: ${response.length}');
      print('Data: $response');
      print('========================');

      if (response.isEmpty) {
        print('=== NO CATEGORIES FOUND IN RESPONSE ===');
        return [];
      }

      // Debug each item before parsing
      print('=== PARSING EACH CATEGORY ===');
      final categories = <CategoryModel>[];
      for (var i = 0; i < response.length; i++) {
        try {
          print('Item $i: ${response[i]}');
          final category = CategoryModel.fromJson(response[i]);
          categories.add(category);
        } catch (e) {
          print('Error parsing category $i: $e');
          print('Problematic data: ${response[i]}');
        }
      }

      print('=== FINAL CATEGORIES LIST ===');
      print('Total parsed: ${categories.length}');
      for (var category in categories) {
        print(' - ${category.id}: ${category.name}');
      }
      print('========================');

      return categories;
    } catch (e, stackTrace) {
      print('=== CATEGORIES FETCH ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      print('========================');
      
      log(
        'FETCH CATEGORIES FAILURE: Failed to fetch categories.',
        error: e,
        stackTrace: stackTrace,
        name: 'CATEGORY_REPO',
      );
      rethrow;
    }
  }
}