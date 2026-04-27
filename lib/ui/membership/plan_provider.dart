import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/domain/model/plan_model.dart';
import 'package:purewill/domain/model/profile_model.dart';
import 'package:purewill/data/repository/plan_repository.dart';

// State
class PlanState {
  final List<PlanModel> plans;
  final PlanModel? currentPlan;
  final bool isLoading;
  final String? error;
  final bool? isUserPremium;
  final ProfileModel? userProfile;

  PlanState({
    required this.plans,
    this.currentPlan,
    this.isLoading = false,
    this.error,
    this.isUserPremium,
    this.userProfile,
  });

  PlanState copyWith({
    List<PlanModel>? plans,
    PlanModel? currentPlan,
    bool? isLoading,
    String? error,
    bool? isUserPremium,
    ProfileModel? userProfile,
  }) {
    return PlanState(
      plans: plans ?? this.plans,
      currentPlan: currentPlan ?? this.currentPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isUserPremium: isUserPremium ?? this.isUserPremium,
      userProfile: userProfile ?? this.userProfile,
    );
  }

  // Helper getters
  PlanModel? get freePlan => plans.firstWhere(
    (plan) => plan.type == 'free',
    orElse: () => plans.firstWhere((plan) => plan.id == 1),
  );

  List<PlanModel> get premiumPlans =>
      plans.where((plan) => plan.type != 'free' && plan.isActive).toList();
}

// Provider
final planProvider = StateNotifierProvider<PlanNotifier, PlanState>((ref) {
  return PlanNotifier(ref.read(planRepositoryProvider));
});

class PlanNotifier extends StateNotifier<PlanState> {
  final PlanRepository _planRepository;

  PlanNotifier(this._planRepository) : super(PlanState(plans: [])) {
    // Auto-load ketika provider dibuat
    _autoLoad();
  }

  // Auto load ketika user sudah login
  void _autoLoad() async {
    await loadPlans();
  }

  // Load plans dan status user
  Future<void> loadPlans() async {
    try {
      // print('🔄 PlanNotifier.loadPlans() called');
      state = state.copyWith(isLoading: true, error: null);

      final userId = _planRepository.getCurrentUserId();

      if (userId == null) {
        // print('⚠️ No user logged in, loading public plans only');
        final plans = await _planRepository.getPlans();
        state = state.copyWith(
          plans: plans,
          isLoading: false,
          isUserPremium: false,
          currentPlan: null,
        );
        return;
      }

      // Load semua data
      // print('📥 Loading plans data...');
      final plans = await _planRepository.getPlans();
      // print('✅ Loaded ${plans.length} plans');

      // print('📥 Loading current plan...');
      final currentPlan = await _planRepository.getCurrentUserPlan();
      // print('✅ Current plan: ${currentPlan?.name ?? "None"}');

      // print('📥 Checking premium status...');
      final isPremium = await _planRepository.isUserPremium(userId);
      // print('✅ Is premium: $isPremium');

      // Get user profile
      ProfileModel? userProfile;
      try {
        userProfile = await _planRepository.getUserProfileWithPremiumStatus();
        // print('✅ User profile loaded');
      } catch (e) {
        // print('⚠️ Failed to load user profile: $e');
      }

      state = state.copyWith(
        plans: plans,
        currentPlan: currentPlan,
        isLoading: false,
        isUserPremium: isPremium,
        userProfile: userProfile,
        error: null,
      );

      // print('🎯 PlanState updated:');
      // print('   - Plans: ${state.plans.length}');
      // print('   - Current plan: ${state.currentPlan?.name}');
      // print('   - Is premium: ${state.isUserPremium}');
      // print('   - Has error: ${state.error != null}');
    } catch (e) {
      print('❌ Error in PlanNotifier.loadPlans(): $e');
      // print('Stack trace: $stackTrace');

      // HAPUS FALLBACK KE DEFAULT PLANS
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load plans. Please check your internet connection.',
      );
    }
  }

  // Subscribe to plan
  Future<void> subscribeToPlan(int planId) async {
    try {
      // print('🔄 Subscribing to plan $planId');
      state = state.copyWith(isLoading: true, error: null);

      await _planRepository.subscribeToPlan(planId);

      // Reload data setelah subscribe
      // print('✅ Subscription successful, reloading data...');
      await loadPlans();
    } catch (e) {
      // print('❌ Error subscribing to plan: $e');
      // print('Stack trace: $stackTrace');
      state = state.copyWith(
        error: 'Failed to subscribe: $e',
        isLoading: false,
      );
      rethrow;
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription() async {
    try {
      // print('🔄 Cancelling subscription');
      state = state.copyWith(isLoading: true, error: null);

      await _planRepository.cancelSubscription();

      // Reload data setelah cancel
      // print('✅ Cancellation successful, reloading data...');
      await loadPlans();
    } catch (e) {
      // print('❌ Error cancelling subscription: $e');
      // print('Stack trace: $stackTrace');
      state = state.copyWith(
        error: 'Failed to cancel subscription: $e',
        isLoading: false,
      );
      rethrow;
    }
  }

  // Check if user is premium
  Future<bool> checkPremiumStatus() async {
    try {
      final userId = _planRepository.getCurrentUserId();
      if (userId == null) return false;

      return await _planRepository.isUserPremium(userId);
    } catch (e) {
      // print('❌ Error checking premium status: $e');
      return false;
    }
  }

  // Get user profile
  Future<ProfileModel?> getUserProfile() async {
    try {
      return await _planRepository.getUserProfileWithPremiumStatus();
    } catch (e) {
      // print('❌ Error getting user profile: $e');
      return null;
    }
  }

  // Sync premium status
  Future<void> syncPremiumStatus() async {
    try {
      // print('🔄 Syncing premium status');
      await _planRepository.syncPremiumStatus();
      await loadPlans();
    } catch (e) {
      // print('❌ Error syncing premium status: $e');
    }
  }

  // Force refresh
  Future<void> refresh() async {
    // print('🔄 Force refreshing plan data');
    await loadPlans();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
