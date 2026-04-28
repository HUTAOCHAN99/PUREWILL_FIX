import 'package:flutter/material.dart';
import 'package:purewill/data/services/units/unit_api_service.dart';
import 'package:purewill/domain/model/target_unit_model.dart';

class UnitListViewModel extends ChangeNotifier {
  final UnitApiService apiService;
  List<TargetUnitModel> units = [];
  List<TargetUnitModel> filtered = [];
  bool isLoading = false;
  String? error;

  UnitListViewModel(this.apiService);

  Future<void> fetchUnits() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await apiService.getAllUnits();
      units = result;
      filtered = result;
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  void searchUnit(String query) {
    if (query.isEmpty) {
      filtered = units;
    } else {
      filtered = units
          .where((u) => u.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> deleteUnit(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await apiService.deleteUnit(id);
      await fetchUnits();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }
}
