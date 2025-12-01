import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/daily_log_model.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/profile_model.dart';
import 'package:purewill/ui/auth/auth_provider.dart';
import 'package:purewill/ui/auth/screen/login_screen.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/ui/habit-tracker/screen/membership_screen.dart';
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
      ref.read(habitNotifierProvider.notifier).loadUserHabits();
      _loadTodayCompletionStatus();
      ref.read(habitNotifierProvider.notifier).getCurrentUser();
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
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToMembership() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const MembershipScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitsState = ref.watch(habitNotifierProvider);
    final List<HabitModel> userHabits = habitsState.habits;
    final ProfileModel? currentUser = habitsState.currentUser;
    final String userName = currentUser?.fullName ?? "user not found";
    final String userEmail = currentUser?.email ?? "email not found";

    final completedToday = userHabits.where((habit) {
      return _todayCompletionStatus[habit.id] == LogStatus.success;
    }).length;

    final totalHabits = userHabits.length;
    final progress = totalHabits > 0 ? completedToday / totalHabits : 0.0;

    return Scaffold(
      body: Container(
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
                      
                      // Tombol Membership
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _navigateToMembership,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: Colors.deepPurple.withOpacity(0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow[300],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Premium Membership',
                                style: TextStyle(
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
          await Future.delayed(Duration(milliseconds: 500));
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
}