import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/services/me/me_api_service.dart';
import 'package:purewill/domain/model/auth_model.dart';
import 'package:purewill/domain/model/user_model.dart';
import 'package:purewill/ui/auth/auth_provider.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';

class ProfileState {
  final bool isLoading;
  final bool isLogoutLoading;
  final String? errorMessage;
  final UserModel? user;

  const ProfileState({
    this.isLoading = false,
    this.isLogoutLoading = false,
    this.errorMessage,
    this.user,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isLogoutLoading,
    String? errorMessage,
    UserModel? user,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isLogoutLoading: isLogoutLoading ?? this.isLogoutLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

class ProfileViewModel extends StateNotifier<ProfileState> {
  final Ref ref;
  final MeApiService _meApiService;

  ProfileViewModel(this.ref, this._meApiService) : super(const ProfileState());

  String? _pickText(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  UserModel _mapProfileResponse(Map<String, dynamic> data) {
    final authUser = ref.read(authNotifierProvider).user;
    final profile = data['profile'];
    final profileMap = profile is Map<String, dynamic>
        ? profile
        : profile is Map
        ? Map<String, dynamic>.from(profile)
        : const <String, dynamic>{};

    final username = _pickText(data['username']) ?? '';
    final email = _pickText(data['email']) ?? authUser?.email ?? '';
    final fullName =
        _pickText(profileMap['fullname']) ??
        _pickText(authUser?.fullName) ??
        username;
    final phoneNumber =
        _pickText(data['phoneNumber']) ??
        _pickText(profileMap['phoneNumber']) ??
        _pickText(profileMap['phone_number']);

    return UserModel(
      id: data['id']?.toString() ?? authUser?.id ?? '',
      email: email,
      fullName: fullName.isNotEmpty ? fullName : username,
      avatarUrl: authUser?.avatarUrl,
      username: username.isNotEmpty ? username : null,
      phoneNumber: phoneNumber,
    );
  }

  Future<void> loadProfile({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final response = await _meApiService.getMe();
      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw AuthException('Invalid profile data');
      }
      final user = _mapProfileResponse(data);
      state = state.copyWith(isLoading: false, errorMessage: null, user: user);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile: $e',
      );
    }
  }

  Future<bool> updateProfile({
    required String email,
    required String username,
    required String fullName,
    String? password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updates = <String, dynamic>{
        'email': email,
        'username': username,
        'fullname': fullName,
        if (password != null && password.trim().isNotEmpty)
          'password': password,
      };

      final response = await _meApiService.updateMe(updates);
      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw AuthException('Invalid profile update response');
      }

      final user = _mapProfileResponse(data);
      state = state.copyWith(isLoading: false, errorMessage: null, user: user);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update profile: $e',
      );
      return false;
    }
  }

  Future<bool> logout() async {
    state = state.copyWith(isLogoutLoading: true, errorMessage: null);
    try {
      await ref.read(authNotifierProvider.notifier).logout();
      state = const ProfileState();
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLogoutLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLogoutLoading: false,
        errorMessage: 'Logout failed: $e',
      );
      return false;
    }
  }
}

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
      ref.watch(habitTokenSyncProvider);
      final meService = ref.watch(meApiServiceProvider);
      final vm = ProfileViewModel(ref, meService);
      Future.microtask(vm.loadProfile);
      return vm;
    });
