// lib\ui\habit-tracker\screen\home_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/daily_log_model.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/plan_model.dart';
import 'package:purewill/domain/model/profile_model.dart';
import 'package:purewill/ui/auth/auth_provider.dart';
import 'package:purewill/ui/auth/screen/login_screen.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/ui/habit-tracker/screen/membership_screen.dart';
import 'package:purewill/ui/membership/plan_provider.dart'; // IMPORT PLAN PROVIDER
import 'package:purewill/ui/habit-tracker/widget/clean_bottom_navigation_bar.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_cards_list.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_header.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_welcome_message.dart';
import 'package:purewill/ui/habit-tracker/widget/progress_card.dart';
import 'package:purewill/ui/habit-tracker/screen/habit_detail_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/add_habit_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import untuk badge service
import 'package:purewill/data/services/badge_service.dart';
import 'package:purewill/data/services/badge_notification_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  Map<int, LogStatus> _todayCompletionStatus = {};
  
  // Global instances (sesuai dengan main.dart)
  final badgeNotificationService = BadgeNotificationService();
  late BadgeService badgeService;

  @override
  void initState() {
    super.initState();
    
    // Initialize badge service
    badgeService = BadgeService(
      Supabase.instance.client,
      badgeNotificationService,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏠 HomeScreen init: Loading data...');
      
      // Load habits data
      ref.read(habitNotifierProvider.notifier).loadUserHabits();
      _loadTodayCompletionStatus();
      ref.read(habitNotifierProvider.notifier).getCurrentUser();
      
      // LOAD PLAN DATA - dengan delay untuk memastikan auth selesai
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

    if (index == 2) {
      print('Navigating to AddHabitScreen...');
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const AddHabitScreen()))
          .then((_) {
            print('Returned from AddHabitScreen');
            if (mounted) {
              setState(() {
                _currentIndex = 0;
              });
            }
          });
    } else {
      print('Switching to tab: $index');
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToMembership() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MembershipScreen()),
    );
  }

  // Helper method untuk format tanggal
  String _formatEndDate(String planType) {
    if (planType == 'free') return 'Selamanya';
    if (planType == 'monthly') return '30 hari';
    if (planType == 'yearly') return '365 hari';
    return 'Aktif';
  }

  // Debug method
  void _debugCheckPremiumStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      print('🔍 DEBUG: Checking premium status');
      print('User ID: ${user.id}');
      print('User Email: ${user.email}');
      
      // Check langsung dari database
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('is_premium_user, current_plan_id')
          .eq('user_id', user.id)
          .single();
      
      print('📊 Profile data: $profileResponse');
      
    } catch (e) {
      print('❌ Debug error: $e');
      _showSnackBar('Debug error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsState = ref.watch(habitNotifierProvider);
    final planState = ref.watch(planProvider);
    
    // DEBUG LOGS
    print('🏠 HomeScreen build() called');
    print('   PlanState:');
    print('   - isLoading: ${planState.isLoading}');
    print('   - isUserPremium: ${planState.isUserPremium}');
    print('   - currentPlan: ${planState.currentPlan?.name}');
    print('   - error: ${planState.error}');
    print('   - plans count: ${planState.plans.length}');

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
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Show error if there's an error
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
                // UPDATE: Pass premium status ke HabitHeader
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
                        
                        // Tombol Membership - UPDATE dengan status premium
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _navigateToMembership,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isPremiumUser 
                                  ? Colors.green
                                  : Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              shadowColor: isPremiumUser 
                                  ? Colors.green.withAlpha(77)
                                  : Colors.deepPurple.withAlpha(77),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: isPremiumUser ? Colors.yellow : Colors.yellow[300],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isPremiumUser 
                                      ? 'Premium Member' 
                                      : 'Upgrade to Premium',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ],
                            ),
                          ),
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );
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
      final currentStatus = _todayCompletionStatus[habit.id] == LogStatus.success;
      final newStatus = !currentStatus;

      setState(() {
        _todayCompletionStatus[habit.id] = newStatus
            ? LogStatus.success
            : LogStatus.neutral;
      });

      // Update ke backend
      await ref
          .read(habitNotifierProvider.notifier)
          .toggleHabitCompletion(habit);

      // TRIGGER BADGE CHECK ketika habit completed
      if (newStatus) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          // Tunggu sebentar lalu check badges
          await Future.delayed(const Duration(milliseconds: 500));
          await badgeService.checkAllBadges(user.id);
          
          // Tampilkan konfirmasi
          _showSnackBar('Habit completed!');
        }
      }

    } catch (e) {
      // Jika error, kembalikan status sebelumnya
      final previousStatus = _todayCompletionStatus[habit.id] == LogStatus.success;
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

  // Method untuk menampilkan detail plan
  void _showPlanDetails(BuildContext context, PlanModel currentPlan) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    'CURRENT PLAN',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  currentPlan.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  currentPlan.formattedPrice,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Features:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...currentPlan.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _navigateToMembership();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Manage Subscription',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}