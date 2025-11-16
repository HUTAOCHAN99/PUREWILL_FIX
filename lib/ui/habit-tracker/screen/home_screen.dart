// lib\ui\habit-tracker\screen\home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/profile_model.dart';
import 'package:purewill/ui/auth/auth_provider.dart';
import 'package:purewill/ui/auth/screen/login_screen.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/ui/habit-tracker/widget/clean_bottom_navigation_bar.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_cards_list.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_header.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_welcome_message.dart';
import 'package:purewill/ui/habit-tracker/widget/progress_card.dart';
import 'package:purewill/ui/habit-tracker/screen/habit_detail_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/add_habit_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  Map<int, bool> _todayCompletionStatus = {};

  @override
  void initState() {
    super.initState();
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
      setState(() {
        _todayCompletionStatus = completionStatus;
      });
    } catch (e) {
      print('Error loading completion status: $e');
    }
  }

  void _onNavBarTap(int index) {
    print('NavBar tapped: index $index'); // Debug print
    
    // PERBAIKAN: Cek berdasarkan urutan item di BottomNavigationBar
    if (index == 2) { // Index 2 seharusnya Add Habit
      print('Navigating to AddHabitScreen...');
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AddHabitScreen()),
      ).then((_) {
        print('Returned from AddHabitScreen');
        if (mounted) {
          setState(() {
            _currentIndex = 0; // Kembali ke Home setelah add habit
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

  @override
  Widget build(BuildContext context) {
    final habitsState = ref.watch(habitNotifierProvider);
    final List<HabitModel> userHabits = habitsState.habits;
    final ProfileModel? currentUser = habitsState.currentUser;
    final String userName = currentUser?.fullName ?? "user not found";
    final String userEmail = currentUser?.email ?? "email not found";    
    final completedToday = userHabits.where((habit) {
      return _todayCompletionStatus[habit.id] == true;
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
              HabitHeader(userEmail: userEmail, userName: userName, onLogout: _performLogout),
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