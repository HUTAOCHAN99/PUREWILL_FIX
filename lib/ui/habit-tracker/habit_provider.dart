import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/repository/category_repository.dart';
import 'package:purewill/data/repository/daily_log_repository.dart';
import 'package:purewill/data/repository/habit_repository.dart';
import 'package:purewill/data/repository/user_repository.dart';
import 'package:purewill/domain/model/category_model.dart';
import 'package:purewill/domain/model/daily_log_model.dart';
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

final habitNotifierProvider = StateNotifierProvider<HabitsViewModel, HabitsState>((ref) {
  final _habitRepository = ref.watch(habitRepositoryProvider);
  final _dailyLogRepository = ref.watch(dailyLogRepositoryProvider);
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId != null) {
    return HabitsViewModel(_habitRepository, _dailyLogRepository, userId);
  }
  return HabitsViewModel(_habitRepository, _dailyLogRepository, "");
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CategoryRepository(client);
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  try {
    print('=== CATEGORIES PROVIDER INITIATED ===');
    
    final repository = ref.watch(categoryRepositoryProvider);
    print('Repository: ${repository.hashCode}');
    
    final categories = await repository.fetchCategories();
    
    print('=== CATEGORIES PROVIDER COMPLETED ===');
    print('Retrieved ${categories.length} categories');
    print('Categories: $categories');
    
    return categories;
  } catch (e, stackTrace) {
    print('=== CATEGORIES PROVIDER ERROR ===');
    print('Error: $e');
    print('Stack: $stackTrace');
    print('Returning empty list as fallback');
    
    return [];
  }
});

final todayLogsProvider = FutureProvider<Map<int, DailyLogModel>>((ref) async {
  try {
    final dailyLogRepo = ref.watch(dailyLogRepositoryProvider);
    final todayLogs = await dailyLogRepo.fetchLogsByDate(DateTime.now());
    
    final logsMap = <int, DailyLogModel>{};
    for (final log in todayLogs) {
      logsMap[log.habitId] = log;
    }
    
    return logsMap;
  } catch (e) {
    return {};
  }
});

final todayCompletionStatusProvider = FutureProvider<Map<int, bool>>((ref) async {
  try {
    final viewModel = ref.read(habitNotifierProvider.notifier);
    return await viewModel.getTodayCompletionStatus();
  } catch (e) {
    return {};
  }
});