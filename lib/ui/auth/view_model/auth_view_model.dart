import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/repository/auth_repository.dart';
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

  AuthViewModel(this._repository) : super(AuthState());

  Future<void> login(String email, String password) async {
    try {
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
    } catch (e) {
      state = state.copyWith(status: AuthStatus.failure, errorMessage: "error");
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
    } catch (e) {
      state = state.copyWith(status: AuthStatus.failure, errorMessage: "error");
    }
  }

  Future<void> logout() async {
  try {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    await _repository.logout();
    
    // Clear user data setelah logout success
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
      errorMessage: "Logout failed"
    );
  }
}

  Future<void> verifySignupOtp(String email, String otp) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      final user = await _repository.verifySignupOTP(email: email, otp: otp);
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
    } catch (e) {
      state = state.copyWith(status: AuthStatus.failure, errorMessage: "error");
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
