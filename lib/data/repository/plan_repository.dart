import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/plan_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepository();
});

class PlanRepository {
  final supabase = Supabase.instance.client;

  Future<List<PlanModel>> getPlans() async {
    try {
      final response = await supabase
          .from('plans')
          .select()
          .eq('is_active', true)
          .order('price', ascending: true);

      if (response == null) return [];

      return (response as List)
          .map((json) => PlanModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting plans: $e');
      return _getDefaultPlans();
    }
  }

  Future<PlanModel?> getPlanById(int planId) async {
    try {
      final response = await supabase
          .from('plans')
          .select()
          .eq('id', planId)
          .single();

      if (response == null) return null;
      return PlanModel.fromJson(response);
    } catch (e) {
      print('Error getting plan: $e');
      return null;
    }
  }

  Future<PlanModel?> getCurrentUserPlan() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final response = await supabase
          .from('user_subscriptions')
          .select('plan_id, plans(*)')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) return null;
      
      final planData = response['plans'];
      if (planData == null) return null;
      
      return PlanModel.fromJson(planData);
    } catch (e) {
      print('Error getting user plan: $e');
      return null;
    }
  }

  Future<void> subscribeToPlan(int planId) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Check if user already has active subscription
      final existingSub = await supabase
          .from('user_subscriptions')
          .select()
          .eq('user_id', user.id)
          .eq('status', 'active')
          .maybeSingle();

      if (existingSub != null) {
        // Update existing subscription
        await supabase
            .from('user_subscriptions')
            .update({
              'plan_id': planId,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existingSub['id']);
      } else {
        // Create new subscription
        await supabase.from('user_subscriptions').insert({
          'user_id': user.id,
          'plan_id': planId,
          'status': 'active',
          'start_date': DateTime.now().toIso8601String(),
          'end_date': null, // null untuk lifetime subscription
        });
      }

      // Update user profile
      await supabase
          .from('profiles')
          .update({
            'current_plan_id': planId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (e) {
      print('Error subscribing to plan: $e');
      rethrow;
    }
  }

  Future<void> cancelSubscription() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await supabase
          .from('user_subscriptions')
          .update({
            'status': 'cancelled',
            'end_date': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id)
          .eq('status', 'active');

      // Update user profile
      await supabase
          .from('profiles')
          .update({
            'current_plan_id': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (e) {
      print('Error cancelling subscription: $e');
      rethrow;
    }
  }

  List<PlanModel> _getDefaultPlans() {
    return [
      PlanModel(
        id: 1,
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
        isActive: true,
      ),
      PlanModel(
        id: 2,
        name: 'Sheet Monthly',
        type: 'monthly',
        price: 49000,
        originalPrice: 59000,
        currency: 'IDR',
        features: [
          'Fltur Habits Tracker Premium (graft, request)',
          'Konsultasi Psikologi (2 sesi) (older, chat)',
          'Riwayat & Catatan Konsultasi (save 30 hari)',
          'Smart reminder (otomatis sesuai pola kebiasaan)',
          'Komunitas Eksklusif & Forum Dukungan untuk Sharing lainnya',
        ],
        isPopular: true,
        isActive: true,
        badgeText: 'POPULAR',
        consultationSessions: 2,
        consultationHistoryDays: 30,
      ),
      PlanModel(
        id: 3,
        name: 'Sheet Yearly',
        type: 'yearly',
        price: 499000,
        originalPrice: 588000,
        currency: 'IDR',
        features: [
          'Fltur Habits Tracker Premium (graft, request)',
          'Konsultasi Psikologi (24 sesi) (older, chat)',
          'Riwayat & Catatan Konsultasi (save 365 hari)',
          'Smart reminder (otomatis sesuai pola kebiasaan)',
          'Komunitas Eksklusif & Forum Dukungan untuk Sharing lainnya',
          'Diskon 40% dari harga bulanan',
          'Prioritas dukungan customer',
        ],
        isBestValue: true,
        isActive: true,
        badgeText: 'BEST VALUE',
        consultationSessions: 24,
        consultationHistoryDays: 365,
      ),
    ];
  }
}