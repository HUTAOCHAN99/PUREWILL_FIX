import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:purewill/data/repository/plan_repository.dart';
import 'package:purewill/domain/model/plan_model.dart';

final planProvider = StateNotifierProvider<PlanNotifier, PlanState>((ref) {
  return PlanNotifier(ref.read(planRepositoryProvider));
});

class PlanState {
  final List<PlanModel> plans;
  final bool isLoading;
  final String? error;
  final PlanModel? currentPlan; // paket yang sedang dipilih user

  PlanState({
    this.plans = const [],
    this.isLoading = false,
    this.error,
    this.currentPlan,
  });

  PlanState copyWith({
    List<PlanModel>? plans,
    bool? isLoading,
    String? error,
    PlanModel? currentPlan,
  }) {
    return PlanState(
      plans: plans ?? this.plans,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPlan: currentPlan ?? this.currentPlan,
    );
  }

  // Helper getters
  PlanModel? get freePlan => plans.firstWhere(
        (plan) => plan.type == 'free',
        orElse: () => _defaultFreePlan(),
      );

  List<PlanModel> get premiumPlans => plans
      .where((plan) => plan.type == 'monthly' || plan.type == 'yearly')
      .toList();

  List<PlanModel> get activePlans => plans.where((plan) => plan.isActive).toList();

  PlanModel _defaultFreePlan() {
    return PlanModel(
      id: 0,
      name: 'Free',
      type: 'free',
      price: 0,
      currency: 'IDR',
      features: [
        'Akses Fltur Habits Tracker',
        'Akses Fltur Komunitas',
        'Akses Fltur Artikel Gratis',
        'Reminder & Notifikasi (Basic reminder)',
      ],
    );
  }
}

class PlanNotifier extends StateNotifier<PlanState> {
  final PlanRepository _planRepository;

  PlanNotifier(this._planRepository) : super(PlanState()) {
    loadPlans();
  }

  Future<void> loadPlans() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final plans = await _planRepository.getPlans();
      
      // Juga load current user plan jika ada
      final userPlan = await _planRepository.getCurrentUserPlan();
      
      state = state.copyWith(
        plans: plans,
        isLoading: false,
        currentPlan: userPlan,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load plans: $e',
      );
    }
  }

  Future<void> subscribeToPlan(int planId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _planRepository.subscribeToPlan(planId);
      final updatedPlan = await _planRepository.getCurrentUserPlan();
      
      state = state.copyWith(
        isLoading: false,
        currentPlan: updatedPlan,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to subscribe: $e',
      );
      rethrow;
    }
  }

  Future<void> cancelSubscription() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _planRepository.cancelSubscription();
      
      state = state.copyWith(
        isLoading: false,
        currentPlan: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to cancel subscription: $e',
      );
      rethrow;
    }
  }
}