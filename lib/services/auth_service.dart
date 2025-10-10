import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Login dengan email dan password
  Future<AuthResponse?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return response;
    } on AuthException catch (e) {
      rethrow;
    } catch (e) {
      throw Exception('An error occurred during login');
    }
  }

  // Register user baru - Supabase otomatis kirim email verification
  // auth_service.dart - PERBAIKI method registerWithEmail
  Future<AuthResponse?> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      print('🔄 Starting registration for: $email');

      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {'full_name': fullName.trim()},
      );

      if (response.user != null) {
        print('✅ Auth success, creating profile...');

        // HAPUS email dari profiles - gunakan user_id dan full_name saja
        await _supabase.from('profiles').insert({
          'user_id': response.user!.id,
          'full_name': fullName.trim(),
          'is_premium_user': false,
          'created_at': DateTime.now().toIso8601String(),
        });

        print('✅ Profile created successfully (without email duplication)');
        print('✅ OTP email sent automatically via "Confirm signup" template');
      }

      return response;
    } on AuthException catch (e) {
      print('❌ Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw Exception('An error occurred during registration');
    }
  }

  Future<AuthResponse> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    try {
      print('🔄 Verifying signup OTP for: $email');

      final response = await _supabase.auth.verifyOTP(
        email: email.trim(),
        token: otp.trim(),
        type: OtpType.signup, // PASTIKAN pakai signup type
      );

      print('✅ OTP verification successful');
      return response;
    } on AuthException catch (e) {
      print('❌ OTP Verification Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected OTP Verification Error: $e');
      throw Exception('Failed to verify OTP');
    }
  }

  // Resend OTP untuk signup
  Future<void> resendSignupOtp(String email) async {
    try {
      await _supabase.auth.resend(type: OtpType.signup, email: email.trim());
      print('✅ OTP resent for signup: $email');
    } on AuthException catch (e) {
      print('❌ OTP Resend Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected OTP Resend Error: $e');
      throw Exception('Failed to resend OTP');
    }
  }

  // Resend OTP untuk verifikasi email
  Future<void> resendEmailVerificationOtp(String email) async {
    try {
      await _supabase.auth.resend(type: OtpType.signup, email: email.trim());
      print('✅ OTP resent for email verification: $email');
    } on AuthException catch (e) {
      print('❌ OTP Resend Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected OTP Resend Error: $e');
      throw Exception('Failed to resend verification OTP');
    }
  }

  // Kirim OTP untuk reset password
  Future<void> sendPasswordResetOtp(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim(),
        // Opsional: Tambahkan redirectTo jika perlu, tapi kita pakai OTP
      );
      print('✅ Password reset OTP sent to: $email');
    } on AuthException catch (e) {
      print('❌ Password Reset OTP Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected Password Reset OTP Error: $e');
      throw Exception('Failed to send password reset OTP');
    }
  }

  Future<AuthResponse> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      print('🔄 Verifying password reset OTP for: $email');

      final response = await _supabase.auth.verifyOTP(
        email: email.trim(),
        token: otp.trim(),
        type: OtpType
            .recovery, // PASTIKAN pakai recovery type untuk reset password
      );

      print('✅ Password reset OTP verification successful');
      return response;
    } on AuthException catch (e) {
      print('❌ Password Reset OTP Verification Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected Password Reset OTP Verification Error: $e');
      throw Exception('Failed to verify password reset OTP');
    }
  }

  Future<void> resendPasswordResetOtp(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.recovery, // PASTIKAN pakai recovery type
        email: email.trim(),
      );
      print('✅ OTP resent for password reset: $email');
    } on AuthException catch (e) {
      print('❌ Password Reset OTP Resend Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected Password Reset OTP Resend Error: $e');
      throw Exception('Failed to resend password reset OTP');
    }
  }

  // Verifikasi OTP
  Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
    required String type,
  }) async {
    try {
      print('🔄 Verifying OTP for: $email, type: $type');

      final response = await _supabase.auth.verifyOTP(
        email: email.trim(),
        token: otp.trim(),
        type: type == 'signup' ? OtpType.signup : OtpType.recovery,
      );

      print('✅ OTP verification successful');
      return response;
    } on AuthException catch (e) {
      print('❌ OTP Verification Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected OTP Verification Error: $e');
      throw Exception('Failed to verify OTP');
    }
  }

  // Update password setelah reset
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword.trim()),
      );
      print('✅ Password updated successfully');
      return response;
    } on AuthException catch (e) {
      print('❌ Update Password Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Unexpected Update Password Error: $e');
      throw Exception('An error occurred while resetting password');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout Error: $e');
      throw Exception('An error occurred during logout');
    }
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Check jika user sudah login
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  // Validasi email
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  // Validasi password (minimal 6 karakter)
  bool isValidPassword(String password) {
    return password.trim().length >= 6;
  }

  // Validasi full name (tidak kosong)
  bool isValidFullName(String fullName) {
    return fullName.trim().isNotEmpty;
  }

  // Stream untuk mendengarkan perubahan state auth
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Method untuk mendapatkan user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;

    try {
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', currentUser!.id)
          .single();

      return profile;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }
}

// Extension untuk memudahkan validasi form
extension AuthValidators on AuthService {
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (!isValidPassword(value)) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    return null;
  }

  String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
}
