import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/ui/habit-tracker/view_model/habit_detail_view_model.dart';

final habitDetailProvider =
    StateNotifierProvider<HabitDetailViewModel, HabitDetailState>((ref) {
      final habitApiService = ref.watch(habitApiServiceProvider);
      return HabitDetailViewModel(habitApiService);
    });
