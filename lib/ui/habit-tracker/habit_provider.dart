// lib/ui/habit-tracker/habit_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/repository/habit_repository.dart';
import 'package:purewill/data/repository/habit_session_repository.dart';
import 'package:purewill/data/repository/daily_log_repository.dart';
import 'package:purewill/data/repository/reminder_setting_repository.dart';
import 'package:purewill/data/repository/target_unit_repository.dart';
import 'package:purewill/data/repository/category_repository.dart';
import 'package:purewill/data/services/habits/habit_api_service.dart';
import 'package:purewill/ui/habit-tracker/view_model/habit_view_model.dart';
import 'package:purewill/ui/auth/auth_provider.dart';

// ==================== API SERVICE ====================
final habitApiServiceProvider = Provider<HabitApiService>((ref) {
  return HabitApiService();
});

// ==================== REAL API REPOSITORIES (LENGKAP) ====================
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final apiService = ref.watch(habitApiServiceProvider);
  return HabitRepository(apiService);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final apiService = ref.watch(habitApiServiceProvider);
  return CategoryRepository(apiService);
});

// ==================== DEBUG REPOSITORIES (BELUM ADA DI BACKEND) ====================
final dailyLogRepositoryProvider = Provider<DailyLogRepository>((ref) {
  return DailyLogRepository(); // Debug version - local memory
});

final reminderSettingRepositoryProvider = Provider<ReminderSettingRepository>((ref) {
  return ReminderSettingRepository(); // Debug version - local memory
});

final habitSessionRepositoryProvider = Provider<HabitSessionRepository>((ref) {
  return HabitSessionRepository(); // Debug version - local memory
});

final targetUnitRepositoryProvider = Provider<TargetUnitRepository>((ref) {
  final apiService = ref.watch(habitApiServiceProvider);
  return TargetUnitRepository(apiService);  // ✅ Tambahkan apiService
});

// ==================== TOKEN SYNC ====================
final habitTokenSyncProvider = Provider<void>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final habitService = ref.watch(habitApiServiceProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  
  if (authState.user != null && authRepo.accessToken != null) {
    habitService.setAccessToken(authRepo.accessToken!);
  }
  return null;
});

// ==================== HABIT NOTIFIER ====================
final habitNotifierProvider = StateNotifierProvider<HabitsViewModel, HabitsState>((ref) {
  // Watch token sync
  ref.watch(habitTokenSyncProvider);
  
  // Real API repositories
  final habitRepository = ref.watch(habitRepositoryProvider);
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  
  // Debug repositories
  final dailyLogRepository = ref.watch(dailyLogRepositoryProvider);
  final reminderSettingRepository = ref.watch(reminderSettingRepositoryProvider);
  final habitSessionRepository = ref.watch(habitSessionRepositoryProvider);
  final targetUnitRepository = ref.watch(targetUnitRepositoryProvider);

  final authState = ref.watch(authNotifierProvider);
  final userId = authState.user?.id ?? "";

  // Listen to auth changes
  ref.listen(authNotifierProvider, (previous, next) {
    if (previous?.user?.id != next.user?.id) {
      ref.invalidateSelf();
      final authRepo = ref.read(authRepositoryProvider);
      final habitService = ref.read(habitApiServiceProvider);
      if (authRepo.accessToken != null) {
        habitService.setAccessToken(authRepo.accessToken!);
      }
    }
  });

  return HabitsViewModel(
    habitRepository,
    dailyLogRepository,
    reminderSettingRepository,
    habitSessionRepository,
    targetUnitRepository,
    categoryRepository,
    userRepository,
    userId,
  );
});