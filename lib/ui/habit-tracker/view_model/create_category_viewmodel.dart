import 'package:flutter/material.dart';
import 'package:purewill/data/services/categories/category_api_service.dart';

class CreateCategoryViewModel extends ChangeNotifier {
  final CategoryApiService apiService;
  bool isLoading = false;
  String? error;
  String? successMessage;

  CreateCategoryViewModel(this.apiService);

  Future<bool> submitCreate({required String name, String? description}) async {
    isLoading = true;
    error = null;
    successMessage = null;
    notifyListeners();
    try {
      await apiService.createCategory(name: name, description: description);
      isLoading = false;
      successMessage = 'Category created successfully';
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
