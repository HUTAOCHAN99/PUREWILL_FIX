import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/repository/daily_log_repository.dart';
import 'package:purewill/data/repository/habit_repository.dart';
import 'package:purewill/data/repository/user_repository.dart';
import 'package:purewill/ui/habit-tracker/view_model/habit_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return HabitRepository(client);
});

final dailyLogRepositoryProvider = Provider<DailyLogRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DailyLogRepository(client);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return UserRepository(client);
});

final habitNotifierProvider =
    StateNotifierProvider<HabitsViewModel, HabitsState>((ref) {
      final _habitRepository = ref.watch(habitRepositoryProvider);
      final _dailyLogRepository = ref.watch(dailyLogRepositoryProvider);
      final client = ref.watch(supabaseClientProvider);
      final userId = client.auth.currentUser?.id;
      if (userId != null) {
        return HabitsViewModel(_habitRepository, _dailyLogRepository, userId);
      }
      return HabitsViewModel(_habitRepository, _dailyLogRepository, "");
    });
