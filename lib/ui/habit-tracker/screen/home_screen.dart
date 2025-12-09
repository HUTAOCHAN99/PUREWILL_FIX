import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/profile_model.dart';
import 'package:purewill/ui/auth/auth_provider.dart';
import 'package:purewill/ui/auth/screen/login_screen.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/ui/habit-tracker/screen/membership_screen.dart';
import 'package:purewill/ui/membership/plan_provider.dart';
import 'package:purewill/ui/habit-tracker/widget/clean_bottom_navigation_bar.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_cards_list.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_header.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_welcome_message.dart';
import 'package:purewill/ui/habit-tracker/widget/progress_card.dart';
import 'package:purewill/ui/habit-tracker/widget/premium_card_button.dart';
import 'package:purewill/ui/habit-tracker/screen/habit_detail_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/add_habit_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/habit_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:purewill/data/services/badge_service.dart';
import 'package:purewill/data/services/badge_notification_service.dart';

import 'package:purewill/domain/model/daily_log_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  Map<int, LogStatus> _todayCompletionStatus = {};

  final badgeNotificationService = BadgeNotificationService();
  late BadgeService badgeService;

  @override
  void initState() {
    super.initState();

    badgeService = BadgeService(
      Supabase.instance.client,
      badgeNotificationService,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏠 HomeScreen init: Loading data...');

      ref.read(habitNotifierProvider.notifier).loadTodayUserHabits();
      _loadTodayCompletionStatus();
      ref.read(habitNotifierProvider.notifier).getCurrentUser();

      Future.delayed(const Duration(milliseconds: 300), () {
        print('🔄 HomeScreen: Loading plan data...');
        ref.read(planProvider.notifier).loadPlans();
      });
    });
  }

  Future<void> _loadTodayCompletionStatus() async {
    try {
      final completionStatus = await ref
          .read(habitNotifierProvider.notifier)
          .getTodayCompletionStatus();
      if (mounted) {
        setState(() {
          _todayCompletionStatus = completionStatus;
        });
      }
    } catch (e) {
      print('Error loading completion status: $e');
    }
  }

  void _onNavBarTap(int index) {
    print('NavBar tapped: index $index');

    if (index == 1) {
      // Navigate to Habit Screen
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const HabitScreen()));
    } else if (index == 2) {
      // Navigate to Community (Komunitas)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AddHabitScreen(),
        ), // You can replace with community screen
      );
    } else if (index == 3) {
      // Navigate to Consultation (Konsultasi)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AddHabitScreen(),
        ), // You can replace with consultation screen
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _navigateToMembership() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MembershipScreen()));
  }

  // Debug method (opsional, bisa dihapus jika tidak digunakan)
  // void _debugCheckPremiumStatus() async {
  //   try {
  //     final user = Supabase.instance.client.auth.currentUser;
  //     if (user == null) {
  //       print('❌ No user logged in');
  //       return;
  //     }

  //     print('🔍 DEBUG: Checking premium status');
  //     print('User ID: ${user.id}');
  //     print('User Email: ${user.email}');

  //     // Check langsung dari database
  //     final profileResponse = await Supabase.instance.client
  //         .from('profiles')
  //         .select('is_premium_user, current_plan_id')
  //         .eq('user_id', user.id)
  //         .single();

  //     print('📊 Profile data: $profileResponse');

  //   } catch (e) {
  //     print('❌ Debug error: $e');
  //     _showSnackBar('Debug error: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final habitsState = ref.watch(habitNotifierProvider);
    final planState = ref.watch(planProvider);

    // print('🏠 HomeScreen build() called');
    // print('   PlanState:');
    // print('   - isLoading: ${planState.isLoading}');
    // print('   - isUserPremium: ${planState.isUserPremium}');
    // print('   - currentPlan: ${planState.currentPlan?.name}');
    // print('   - error: ${planState.error}');
    // print('   - plans count: ${planState.plans.length}');

    final List<HabitModel> userHabits = habitsState.habits;
    final ProfileModel? currentUser = habitsState.currentUser;
    final String userName = currentUser?.fullName ?? "User";
    final String userEmail = currentUser?.email ?? "email@example.com";

    final completedToday = userHabits.where((habit) {
      return _todayCompletionStatus[habit.id] == LogStatus.success;
    }).length;

    final totalHabits = userHabits.length;
    final progress = totalHabits > 0 ? completedToday / totalHabits : 0.0;

    // Use data from planState
    final bool isPremiumUser = planState.isUserPremium ?? false;
    final currentPlan = planState.currentPlan;

    // Show loading if plans are loading
    if (planState.isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/home/bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (planState.error != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/home/bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    planState.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.read(planProvider.notifier).loadPlans(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          print('🔄 Pull to refresh triggered');
          await ref.read(habitNotifierProvider.notifier).loadUserHabits();
          await ref.read(planProvider.notifier).refresh();
          await _loadTodayCompletionStatus();
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/home/bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                HabitHeader(
                  userEmail: userEmail,
                  userName: userName,
                  onLogout: _performLogout,
                  isPremiumUser: isPremiumUser,
                  currentPlan: currentPlan,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HabitWelcomeMessage(name: userName),
                        ProgressCard(
                          progress: progress,
                          completed: completedToday,
                          total: totalHabits,
                        ),

                        const SizedBox(height: 16),
                        PremiumCardButton(
                          isPremiumUser: isPremiumUser,
                          currentPlan: currentPlan,
                          onTap: _navigateToMembership,
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          "Your Habits",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        HabitCardsList(
                          habitsState: habitsState,
                          todayCompletionStatus: _todayCompletionStatus,
                          habits: userHabits,
                          onHabitTap: _handleHabitTap,
                          onCheckboxTap: _handleCheckboxTap,
                          isPremiumUser: isPremiumUser,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CleanBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        child: const Icon(Icons.add),
        heroTag: "add_habit_fab",
      ),
    );
  }

  void _addHabit() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddHabitScreen()));
  }

  void _handleHabitTap(HabitModel habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(
          habit: habit,
          completionStatus: _todayCompletionStatus,
        ),
      ),
    );
  }

  void _handleCheckboxTap(HabitModel habit) async {
    try {
      final currentStatus =
          _todayCompletionStatus[habit.id] == LogStatus.success;
      final newStatus = !currentStatus;

      setState(() {
        _todayCompletionStatus[habit.id] = newStatus
            ? LogStatus.success
            : LogStatus.neutral;
      });

      await ref
          .read(habitNotifierProvider.notifier)
          .toggleHabitCompletion(habit);
      if (newStatus) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          await Future.delayed(const Duration(milliseconds: 500));
          await badgeService.checkAllBadges(user.id);
          _showSnackBar('Habit completed!');
        }
      }
    } catch (e) {
      final previousStatus =
          _todayCompletionStatus[habit.id] == LogStatus.success;
      setState(() {
        _todayCompletionStatus[habit.id] = previousStatus
            ? LogStatus.neutral
            : LogStatus.success;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update habit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _performLogout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      ref.read(authNotifierProvider.notifier).logout();

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
