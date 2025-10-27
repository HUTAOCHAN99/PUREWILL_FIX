import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/ui/auth/auth_provider.dart' hide supabaseClientProvider;
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
    print(userHabits);
    final completedToday = _todayCompletionStatus.values
        .where((completed) => completed)
        .length;
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
              const HabitHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HabitWelcomeMessage(name: "adit"),
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
    } else {
      _toggleHabitCompletion(habit);
    }
  }


  Future<void> _toggleHabitCompletion(HabitModel habit) async {
    print(habit);
    try {
      final viewModel = ref.read(habitNotifierProvider.notifier);
      await viewModel.toggleHabitCompletion(habit);
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

  // User Profile Methods
  /*   void _showUserProfileMenu() {
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
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF7C3AED),
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                _getUserDisplayName(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _getUserEmail(),
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => Navigator.pop(context),
              ),
              _buildMenuButton(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => Navigator.pop(context),
              ),
              _buildMenuButton(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 10),
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showLogoutConfirmation();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Logout'),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  } */

  // Widget _buildMenuButton({
  //   required IconData icon,
  //   required String title,
  //   required VoidCallback onTap,
  // }) {
  //   return ListTile(
  //     leading: Icon(icon, color: Colors.grey.shade700),
  //     title: Text(title),
  //     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  //     contentPadding: EdgeInsets.zero,
  //     onTap: onTap,
  //   );
  // }

  String _getUserDisplayName() {
    final supabaseClient = ref.read(supabaseClientProvider);
    final currentUser = supabaseClient.auth.currentUser;
    final email = currentUser?.email ?? 'User';
    return email.split('@').first;
  }

  String _getUserEmail() {
    final supabaseClient = ref.read(supabaseClientProvider);
    final currentUser = supabaseClient.auth.currentUser;
    return currentUser?.email ?? 'user@example.com';
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performLogout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }


void _performLogout() async {
  try {
    // Tampilkan loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Gunakan AuthViewModel untuk logout
    final authViewModel = ref.read(authNotifierProvider.notifier);
    await authViewModel.logout();

    // Tutup dialog loading
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    // Navigate ke login screen dan clear semua stack
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
    // Tutup dialog loading jika ada error
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