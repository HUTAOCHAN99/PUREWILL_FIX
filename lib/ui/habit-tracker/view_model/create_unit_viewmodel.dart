import 'package:flutter/material.dart';
import 'package:purewill/data/services/units/unit_api_service.dart';

class CreateUnitViewModel extends ChangeNotifier {
  final UnitApiService apiService;
  bool isLoading = false;
  String? error;
  String? successMessage;

  CreateUnitViewModel(this.apiService);

  Future<bool> submitCreate({
    required String name,
    String? abbreviation,
  }) async {
    isLoading = true;
    error = null;
    successMessage = null;
    notifyListeners();
    try {
      await apiService.createUnit(name: name, abbreviation: abbreviation);
      isLoading = false;
      successMessage = 'Unit created successfully';
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
