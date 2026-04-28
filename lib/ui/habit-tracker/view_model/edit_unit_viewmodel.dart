import 'package:flutter/material.dart';
import 'package:purewill/data/services/units/unit_api_service.dart';
import 'package:purewill/domain/model/target_unit_model.dart';

class EditUnitViewModel extends ChangeNotifier {
  final UnitApiService apiService;
  bool isLoading = false;
  String? error;
  TargetUnitModel? unit;
  String? successMessage;

  EditUnitViewModel(this.apiService);

  Future<void> loadDetail(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      unit = await apiService.getUnitDetail(id);
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> submitUpdate({
    required int id,
    required String name,
    String? abbreviation,
  }) async {
    isLoading = true;
    error = null;
    successMessage = null;
    notifyListeners();
    try {
      await apiService.updateUnit(
        id: id,
        name: name,
        abbreviation: abbreviation,
      );
      isLoading = false;
      successMessage = 'Unit updated successfully';
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
