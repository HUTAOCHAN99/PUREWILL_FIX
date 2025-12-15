import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/repository/auth_repository.dart';
import 'package:purewill/data/repository/habit_repository.dart';
import 'package:purewill/data/repository/habit_session_repository.dart';
import 'package:purewill/data/repository/user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { initial, success, loading, failure }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final User? user;

  AuthState({this.status = AuthStatus.initial, this.errorMessage, this.user});

  AuthState copyWith({AuthStatus? status, String? errorMessage, User? user}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: user,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final UserRepository _userRepository;
  final HabitRepository _habitRepository;
  final HabitSessionRepository _habitSessionRepository;

  AuthViewModel(
    this._repository,
    this._userRepository,
    this._habitRepository,
    this._habitSessionRepository,
  ) : super(AuthState());

  Future<void> login(String email, String password) async {
    try {
      print("email: $email, password: $password");
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      final user = await _repository.login(email: email, password: password);
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.success,
          errorMessage: null,
          user: user,
        );
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.failure, errorMessage: "error");
      rethrow;
    }
  }

  Future<void> signup(String fullname, String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      final user = await _repository.signup(
        fullname: fullname,
        email: email,
        password: password,
      );

      final habit = await _habitRepository.initializeDefaultHabitsForUser(user!.id);

     

      state = state.copyWith(
        status: AuthStatus.success,
        errorMessage: null,
        user: user,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.failure, errorMessage: "error");
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      await _repository.logout();
      state = state.copyWith(
        status: AuthStatus.success,
        user: null,
        errorMessage: null,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: "Logout failed",
      );
    }
  }

  Future<void> verifySignupOtp(String email, String otp) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      final user = await _repository.verifySignupOTP(email: email, otp: otp);

      await _userRepository.createUserProfile(
        userId: user!.id,
        fullName: user.userMetadata!["full_name"],
      );

      state = state.copyWith(
        status: AuthStatus.success,
        errorMessage: null,
        user: user,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.failure, errorMessage: "error");
      print(e.toString());
    }
  }

  Future<void> resendSignupOTP(String email) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      await _repository.resendSignupOTP(email: email);
      state = state.copyWith(status: AuthStatus.success, errorMessage: null);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.failure, errorMessage: "error");
    }
  }

  Future<void> sendPasswordResetOTP(String email) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      await _repository.sendPasswordResetOTP(email: email);
      state = state.copyWith(status: AuthStatus.success, errorMessage: null);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.failure, errorMessage: "error");
    }
  }

  Future<void> verifyPasswordResetOtp(String email, String otp) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      final user = await _repository.verifyPasswordResetOtp(
        email: email,
        otp: otp,
      );
      state = state.copyWith(
        status: AuthStatus.success,
        errorMessage: null,
        user: user,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.failure, errorMessage: "error");
    }
  }

  Future<void> resendPasswordResetOtp(String email) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      await _repository.resendPasswordResetOtp(email: email);
      state = state.copyWith(status: AuthStatus.success, errorMessage: null);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.failure, errorMessage: "error");
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      final user = await _repository.updatePassword(newPassword: newPassword);
      state = state.copyWith(
        status: AuthStatus.success,
        errorMessage: null,
        user: user,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.failure,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.failure, errorMessage: "error");
    }
  }
}
