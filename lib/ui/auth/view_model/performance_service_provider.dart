// lib\providers\performance_service_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/data/repository/habit_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purewill/data/services/performance_service.dart';

// Provider untuk Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider untuk HabitRepository
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final supabaseClient = ref.read(supabaseClientProvider);
  return HabitRepository(supabaseClient); // Sesuaikan dengan constructor HabitRepository Anda
});

// Provider untuk PerformanceService
final performanceServiceProvider = Provider<PerformanceService>((ref) {
  final habitRepository = ref.read(habitRepositoryProvider);
  return PerformanceService(habitRepository);
});