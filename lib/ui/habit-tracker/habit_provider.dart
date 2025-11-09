import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/repository/category_repository.dart';
import 'package:purewill/data/repository/daily_log_repository.dart';
import 'package:purewill/data/repository/habit_repository.dart';
import 'package:purewill/data/repository/reminder_setting_repository.dart';
import 'package:purewill/data/repository/target_unit_repository.dart';
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

final targetUnitRepositoryProvider = Provider<TargetUnitRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TargetUnitRepository(client);
});

final dailyLogRepositoryProvider = Provider<DailyLogRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DailyLogRepository(client);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return UserRepository(client);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CategoryRepository(client);
});

final reminderSettingRepositoryProvider = Provider<ReminderSettingRepository>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  return ReminderSettingRepository(client);
});

final habitNotifierProvider =
    StateNotifierProvider<HabitsViewModel, HabitsState>((ref) {
      final habitRepository = ref.watch(habitRepositoryProvider);
      final dailyLogRepository = ref.watch(dailyLogRepositoryProvider);
      final reminderSettingRepository = ref.watch(
        reminderSettingRepositoryProvider,
      );
      final targetUnitRepository = ref.watch(targetUnitRepositoryProvider);
      final categoryRepository = ref.watch(categoryRepositoryProvider);
      final userRepository = ref.watch(userRepositoryProvider);
      final client = ref.read(supabaseClientProvider);
      final userId = client.auth.currentUser?.id;
      if (userId != null) {
        return HabitsViewModel(
          habitRepository,
          dailyLogRepository,
          reminderSettingRepository,
          targetUnitRepository,
          categoryRepository,
          userRepository,
          userId,
        );
      }
      return HabitsViewModel(
        habitRepository,
        dailyLogRepository,
        reminderSettingRepository,
        targetUnitRepository,
        categoryRepository,
        userRepository,
        "",
      );
    });

/* final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
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

final todayCompletionStatusProvider = FutureProvider<Map<int, bool>>((
  ref,
) async {
  try {
    final viewModel = ref.read(habitNotifierProvider.notifier);
    return await viewModel.getTodayCompletionStatus();
  } catch (e) {
    return {};
  }
});
 */
