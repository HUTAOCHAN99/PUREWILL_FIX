import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/repository/auth_repository.dart';
import 'package:purewill/data/repository/user_repository.dart';
import 'package:purewill/ui/auth/view_model/auth_view_model.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return UserRepository(client);
});

final authNotifierProvider = StateNotifierProvider<AuthViewModel, AuthState>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final habitRepository = ref.watch(habitRepositoryProvider);
  return AuthViewModel(repository, userRepository, habitRepository);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return supabaseClient.auth.onAuthStateChange.map(
    (event) => event.session?.user,
  );
});