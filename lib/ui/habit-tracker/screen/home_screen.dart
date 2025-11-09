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
import 'package:purewill/ui/habit-tracker/widget/sped_dial.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final int _currentIndex = 0;
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

  @override
  Widget build(BuildContext context) {
    final habitsState = ref.watch(habitNotifierProvider);
    // final isLoading = habitsState.status == HabitStatus.loading;
    final List<HabitModel> userHabits = habitsState.habits;
    final ProfileModel? currentUser = habitsState.currentUser;
    final String userName = currentUser?.fullName ??"user not found";
    final String userEmail = currentUser?.email ??"email not found";    
    final completedToday = userHabits.where((habit) {
      return _todayCompletionStatus[habit.id] == true;
    }).length;

    final totalHabits = userHabits.length;
    print("taotal habits: $totalHabits");
    print("completed today: $completedToday");
    final progress = totalHabits > 0 ? completedToday / totalHabits : 0.0;

    print(progress);


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
      bottomNavigationBar: CleanBottomNavigationBar(currentIndex: _currentIndex, onTap: () => {}),
      floatingActionButton: SpeedDialButton(),
    );
  }


  void _handleHabitTap(HabitModel habit) {
    if (habit.isDefault) {
      print("habit is default, navigating to detail screen");
    } else {
      _toggleHabitCompletion(habit);
    }
  }


  Future<void> _toggleHabitCompletion(HabitModel habit) async {
    print(habit);
    try {
      final viewModel = ref.read(habitNotifierProvider.notifier);
      await viewModel.toggleHabitCompletion(habit);
      // await viewModel.loadUserHabits();
      await _loadTodayCompletionStatus();

      final isNowCompleted = _todayCompletionStatus[habit.id] ?? false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNowCompleted
                ? '${habit.name} completed! ✅'
                : '${habit.name} marked as not completed',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating habit: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
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