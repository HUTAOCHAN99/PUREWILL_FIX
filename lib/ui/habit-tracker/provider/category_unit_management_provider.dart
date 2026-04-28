import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/ui/habit-tracker/view_model/category_list_viewmodel.dart';
import 'package:purewill/ui/habit-tracker/view_model/create_category_viewmodel.dart';
import 'package:purewill/ui/habit-tracker/view_model/edit_category_viewmodel.dart';
import 'package:purewill/ui/habit-tracker/view_model/unit_list_viewmodel.dart';
import 'package:purewill/ui/habit-tracker/view_model/create_unit_viewmodel.dart';
import 'package:purewill/ui/habit-tracker/view_model/edit_unit_viewmodel.dart';

final categoryListViewModelProvider = Provider<CategoryListViewModel>((ref) {
  final api = ref.watch(categoryApiServiceProvider);
  final vm = CategoryListViewModel(api);
  Future.microtask(vm.fetchCategories);
  return vm;
});

final createCategoryViewModelProvider = Provider<CreateCategoryViewModel>((
  ref,
) {
  final api = ref.watch(categoryApiServiceProvider);
  return CreateCategoryViewModel(api);
});

final editCategoryViewModelProvider = Provider<EditCategoryViewModel>((ref) {
  final api = ref.watch(categoryApiServiceProvider);
  return EditCategoryViewModel(api);
});

final unitListViewModelProvider = Provider<UnitListViewModel>((ref) {
  final api = ref.watch(unitApiServiceProvider);
  final vm = UnitListViewModel(api);
  Future.microtask(vm.fetchUnits);
  return vm;
});

final createUnitViewModelProvider = Provider<CreateUnitViewModel>((ref) {
  final api = ref.watch(unitApiServiceProvider);
  return CreateUnitViewModel(api);
});

final editUnitViewModelProvider = Provider<EditUnitViewModel>((ref) {
  final api = ref.watch(unitApiServiceProvider);
  return EditUnitViewModel(api);
});
