import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/services/categories/category_api_service.dart';
import 'package:purewill/data/services/habits/habit_api_service.dart';
import 'package:purewill/data/services/reminder_api_service.dart';
import 'package:purewill/data/services/me/me_api_service.dart';
import 'package:purewill/data/services/motivation_service.dart';
import 'package:purewill/data/services/nofap/nofap_session_api_service.dart';
import 'package:purewill/data/services/units/unit_api_service.dart';
import 'package:purewill/ui/habit-tracker/view_model/add_habit_view_model.dart';
import 'package:purewill/ui/habit-tracker/view_model/habit_view_model.dart';
import 'package:purewill/ui/habit-tracker/view_model/home_view_model.dart';
import 'package:purewill/ui/habit-tracker/view_model/nofap_view_model.dart';
import 'package:purewill/ui/auth/auth_provider.dart';

final habitApiServiceProvider = Provider<HabitApiService>((ref) {
  return HabitApiService();
});

final categoryApiServiceProvider = Provider<CategoryApiService>((ref) {
  return CategoryApiService();
});

final unitApiServiceProvider = Provider<UnitApiService>((ref) {
  return UnitApiService();
});

final meApiServiceProvider = Provider<MeApiService>((ref) {
  return MeApiService();
});

final nofapSessionApiServiceProvider = Provider<NofapSessionApiService>((ref) {
  return NofapSessionApiService();
});

final reminderApiServiceProvider = Provider<ReminderApiService>((ref) {
  return ReminderApiService();
});

final motivationServiceProvider = Provider<MotivationService>((ref) {
  return MotivationService();
});

// ==================== DEBUG REPOSITORIES (BELUM ADA DI BACKEND) ====================
// final dailyLogRepositoryProvider = Provider<DailyLogRepository>((ref) {
//   return DailyLogRepository(); // Debug version - local memory
// });

// final reminderSettingRepositoryProvider = Provider<ReminderSettingRepository>((
//   ref,
// ) {
//   return ReminderSettingRepository(); // Debug version - local memory
// });

// final habitSessionRepositoryProvider = Provider<HabitSessionRepository>((ref) {
//   return HabitSessionRepository(); // Debug version - local memory
// });

// final targetUnitRepositoryProvider = Provider<TargetUnitRepository>((ref) {
//   final apiService = ref.watch(habitApiServiceProvider);
//   return TargetUnitRepository(apiService); // ✅ Tambahkan apiService
// });

// ==================== TOKEN SYNC ====================
final habitTokenSyncProvider = Provider<void>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final habitService = ref.watch(habitApiServiceProvider);
  final categoryService = ref.watch(categoryApiServiceProvider);
  final unitService = ref.watch(unitApiServiceProvider);
  final meService = ref.watch(meApiServiceProvider);
  final reminderService = ref.watch(reminderApiServiceProvider);
  final nofapService = ref.watch(nofapSessionApiServiceProvider);
  final authRepo = ref.watch(authRepositoryProvider);

  if (authState.user != null && authRepo.accessToken != null) {
    habitService.setAccessToken(authRepo.accessToken!);
    categoryService.setAccessToken(authRepo.accessToken!);
    unitService.setAccessToken(authRepo.accessToken!);
    meService.setAccessToken(authRepo.accessToken!);
    reminderService.setAccessToken(authRepo.accessToken!);
    nofapService.setAccessToken(authRepo.accessToken!);
  }
});

// ==================== HABIT NOTIFIER ====================
final habitNotifierProvider = StateNotifierProvider<HabitsViewModel, HabitsState>(
  (ref) {
    // Watch token sync
    ref.watch(habitTokenSyncProvider);

    // Real API service/repositories
    final habitApiService = ref.watch(habitApiServiceProvider);
    final meApiService = ref.watch(meApiServiceProvider);
    // final userRepository = ref.watch(userRepositoryProvider);

    // Debug repositories
    // final dailyLogRepository = ref.watch(dailyLogRepositoryProvider);
    // final reminderSettingRepository = ref.watch(
    //   reminderSettingRepositoryProvider,
    // );
    // final habitSessionRepository = ref.watch(habitSessionRepositoryProvider);
    // final targetUnitRepository = ref.watch(targetUnitRepositoryProvider);

    // Listen to auth changes
    ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.user?.id != next.user?.id) {
        ref.invalidateSelf();
        final authRepo = ref.read(authRepositoryProvider);
        final habitService = ref.read(habitApiServiceProvider);
        final meService = ref.read(meApiServiceProvider);
        final categoryService = ref.read(categoryApiServiceProvider);
        final unitService = ref.read(unitApiServiceProvider);
        if (authRepo.accessToken != null) {
          habitService.setAccessToken(authRepo.accessToken!);
          categoryService.setAccessToken(authRepo.accessToken!);
          unitService.setAccessToken(authRepo.accessToken!);
          meService.setAccessToken(authRepo.accessToken!);
        }
      }
    });

    return HabitsViewModel(
      habitApiService,
      meApiService,
      // userId,
    );
  },
);

final homeNotifierProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  ref.watch(habitTokenSyncProvider);

  final habitApiService = ref.watch(habitApiServiceProvider);
  final meApiService = ref.watch(meApiServiceProvider);

  ref.listen(authNotifierProvider, (previous, next) {
    if (previous?.user?.id != next.user?.id) {
      ref.invalidateSelf();
      final authRepo = ref.read(authRepositoryProvider);
      final habitService = ref.read(habitApiServiceProvider);
      final meService = ref.read(meApiServiceProvider);
      if (authRepo.accessToken != null) {
        habitService.setAccessToken(authRepo.accessToken!);
        meService.setAccessToken(authRepo.accessToken!);
      }
    }
  });

  return HomeViewModel(habitApiService, meApiService);
});

final addHabitNotifierProvider =
    StateNotifierProvider<AddHabitViewModel, AddHabitState>((ref) {
      ref.watch(habitTokenSyncProvider);

      final habitApiService = ref.watch(habitApiServiceProvider);
      final meApiService = ref.watch(meApiServiceProvider);

      ref.listen(authNotifierProvider, (previous, next) {
        if (previous?.user?.id != next.user?.id) {
          ref.invalidateSelf();
          final authRepo = ref.read(authRepositoryProvider);
          final habitService = ref.read(habitApiServiceProvider);
          final meService = ref.read(meApiServiceProvider);
          if (authRepo.accessToken != null) {
            habitService.setAccessToken(authRepo.accessToken!);
            meService.setAccessToken(authRepo.accessToken!);
          }
        }
      });

      return AddHabitViewModel(habitApiService, meApiService);
    });

final nofapNotifierProvider = StateNotifierProvider<NofapViewModel, NofapState>(
  (ref) {
    ref.watch(habitTokenSyncProvider);

    final nofapService = ref.watch(nofapSessionApiServiceProvider);
    final meService = ref.watch(meApiServiceProvider);
    final motivationService = ref.watch(motivationServiceProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.user?.id != next.user?.id) {
        ref.invalidateSelf();
        final authRepo = ref.read(authRepositoryProvider);
        final service = ref.read(nofapSessionApiServiceProvider);
        final meService = ref.read(meApiServiceProvider);
        if (authRepo.accessToken != null) {
          service.setAccessToken(authRepo.accessToken!);
          meService.setAccessToken(authRepo.accessToken!);
        }
      }
    });

    return NofapViewModel(nofapService, meService, motivationService);
  },
);
