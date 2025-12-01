import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purewill/data/services/badge_service.dart';

class BadgeTriggerService {
  final SupabaseClient _supabase;
  final BadgeService _badgeService;

  BadgeTriggerService(this._supabase, this._badgeService);

  // Trigger badge check ketika habit selesai
  Future<void> onHabitCompleted(int habitId, BuildContext context) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      debugPrint('🏆 Habit $habitId completed, checking badges...');
      
      // Tunggu sebentar untuk memastikan data tersimpan
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Trigger badge check
      await _badgeService.checkAllBadges(user.id);
      
      // Tampilkan loading indicator
      _showBadgeCheckSnackbar(context);
      
    } catch (e, stack) {
      debugPrint('❌ Error triggering badge check: $e');
      debugPrint('Stack trace: $stack');
      
      _showErrorSnackbar(context, 'Failed to check badges');
    }
  }

  // Trigger badge check ketika habit baru dibuat
  Future<void> onHabitCreated(BuildContext context) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      debugPrint('🏆 New habit created, checking badges...');
      
      // Tunggu sebentar
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Trigger badge check untuk habit_count badges
      await _badgeService.checkAllBadges(user.id);
      
      _showBadgeCheckSnackbar(context);
      
    } catch (e, stack) {
      debugPrint('❌ Error triggering badge check: $e');
      debugPrint('Stack trace: $stack');
      _showErrorSnackbar(context, 'Failed to check badges');
    }
  }

  // Trigger badge check ketika streak berubah
  Future<void> onStreakChanged(BuildContext context) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      debugPrint('🔥 Streak changed, checking badges...');
      
      // Tunggu sebentar
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Trigger badge check untuk streak badges
      await _badgeService.checkAllBadges(user.id);
      
      _showBadgeCheckSnackbar(context);
      
    } catch (e, stack) {
      debugPrint('❌ Error triggering badge check: $e');
      debugPrint('Stack trace: $stack');
      _showErrorSnackbar(context, 'Failed to check badges');
    }
  }

  // Trigger badge check secara manual
  Future<void> manualTrigger(BuildContext context) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ No user logged in, cannot trigger badge check');
        _showErrorSnackbar(context, 'Please login first');
        return;
      }

      debugPrint('🔄 Manually triggering badge check...');
      
      // Tampilkan loading
      _showLoadingSnackbar(context, 'Checking badges...');
      
      // Jalankan badge check
      await _badgeService.checkAllBadges(user.id);
      
      // Tampilkan summary
      final badges = await _badgeService.getUserBadges(user.id);
      
      // Update snackbar dengan hasil
      _showSuccessSnackbar(context, 'Found ${badges.length} badges');
      
      debugPrint('📊 User has ${badges.length} total badges');
      
    } catch (e, stack) {
      debugPrint('❌ Error in manual trigger: $e');
      debugPrint('Stack trace: $stack');
      _showErrorSnackbar(context, 'Failed to check badges');
    }
  }

  // Test sederhana untuk verifikasi sistem bekerja
  Future<void> simpleTest(BuildContext context) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ Please login first to test badges');
        _showErrorSnackbar(context, 'Please login first');
        return;
      }

      debugPrint('🧪 Running simple badge system test...');
      
      // Tampilkan loading
      _showLoadingSnackbar(context, 'Testing badge system...');
      
      // 1. Show a test notification
      await _badgeService.testNotificationsOnly();
      
      await Future.delayed(const Duration(seconds: 2));
      
      // 2. Check current badges
      final badges = await _badgeService.getUserBadges(user.id);
      debugPrint('🏆 Current badges: ${badges.length}');
      
      // 3. Run a badge check
      await manualTrigger(context);
      
      debugPrint('✅ Simple test completed');
      
    } catch (e, stack) {
      debugPrint('❌ Simple test failed: $e');
      debugPrint('Stack trace: $stack');
      _showErrorSnackbar(context, 'Test failed');
    }
  }

  // Helper untuk menampilkan snackbar
  void _showBadgeCheckSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text('Checking for new badges...'),
          ],
        ),
        backgroundColor: Colors.purple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLoadingSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Check untuk milestone tertentu
  Future<void> checkForMilestones(BuildContext context) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      debugPrint('🎯 Checking for milestones...');
      
      // Get user data
      final profile = await _badgeService.getUserProfile(user.id);
      if (profile == null) return;

      final currentLevel = profile['level'] as int;
      final currentXP = profile['current_xp'] as int;
      final xpToNextLevel = profile['xp_to_next_level'] as int;

      // Check for level up
      if (currentXP >= xpToNextLevel) {
        _showLevelUpSnackbar(context, currentLevel + 1);
      }

      // Check for streak milestones
      final streak = await _calculateCurrentStreak(user.id);
      if (streak >= 3 && streak % 3 == 0) {
        _showStreakMilestoneSnackbar(context, streak);
      }

    } catch (e, stack) {
      debugPrint('❌ Error checking milestones: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  // Calculate current streak
  Future<int> _calculateCurrentStreak(String userId) async {
    try {
      // Get user's active habits
      final activeHabits = await _supabase
          .from('habits')
          .select('id')
          .eq('user_id', userId)
          .eq('is_active', true);

      if (activeHabits.isEmpty) return 0;

      int maxStreak = 0;
      
      // Calculate streak for each habit and take the maximum
      for (final habit in activeHabits) {
        final habitId = habit['id'] as int;
        
        // Get completed logs ordered by date descending
        final completedLogs = await _supabase
            .from('daily_logs')
            .select('log_date')
            .eq('habit_id', habitId)
            .eq('status', 'success')
            .order('log_date', ascending: false);

        if (completedLogs.isEmpty) continue;

        int streak = 0;
        DateTime currentDate = DateTime.now().toUtc();
        
        for (final log in completedLogs) {
          final logDate = DateTime.parse(log['log_date'] as String).toUtc();
          final difference = currentDate.difference(logDate).inDays;
          
          if (difference == streak) {
            streak++;
          } else {
            break;
          }
        }
        
        if (streak > maxStreak) {
          maxStreak = streak;
        }
      }
      
      return maxStreak;
    } catch (e) {
      debugPrint('❌ Error calculating current streak: $e');
      return 0;
    }
  }

  void _showLevelUpSnackbar(BuildContext context, int newLevel) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.yellow, size: 24),
            const SizedBox(width: 8),
            Text(
              '🎉 Level Up! You reached Level $newLevel',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showStreakMilestoneSnackbar(BuildContext context, int streak) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            Text(
              '🔥 $streak Day Streak! Keep going!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Cleanup resources jika diperlukan
  void dispose() {
    debugPrint('♻️ BadgeTriggerService disposed');
  }
}