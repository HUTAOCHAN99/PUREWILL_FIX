import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/profile_model.dart';
import 'package:purewill/ui/auth/auth_provider.dart';
import 'package:purewill/ui/auth/screen/login_screen.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/ui/habit-tracker/screen/community_selection_screen.dart';
// import 'package:purewill/ui/habit-tracker/screen/membership_screen.dart';
import 'package:purewill/ui/habit-tracker/view_model/habit_view_model.dart';
// import 'package:purewill/ui/membership/plan_provider.dart';
import 'package:purewill/ui/habit-tracker/widget/clean_bottom_navigation_bar.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_cards_list.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_header.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_welcome_message.dart';
import 'package:purewill/ui/habit-tracker/widget/progress_card.dart';
// import 'package:purewill/
import 'package:purewill/ui/habit-tracker/screen/habit_detail_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/add_habit_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/habit_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/consultation_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/nofap_screen.dart';
import 'package:purewill/domain/model/habit_log_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeNotifierProvider.notifier).initializeHome();

      // Schedule reminders setelah login
      // _scheduleReminders();
    });
  }

  // Future<void> _scheduleReminders() async {
  //   try {
  //     // debugPrint('🔄 Scheduling reminders for current user...');
  //     final reminderService = ReminderSyncService();
  //     await reminderService.rescheduleAllReminders();
  //     // debugPrint('✅ Reminders scheduled successfully');
  //   } catch (e) {
  //     // debugPrint('❌ Error scheduling reminders: $e');
  //   }
  // }

  void _onNavBarTap(int index) {
    if (index == 1) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HabitScreen()),
      );
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NoFapScreen()),
      );
    } else if (index == 3) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const CommunitySelectionScreen(),
        ),
      );
    } else if (index == 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ConsultationScreen()),
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

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);

    if (homeState.isLoadingRole || homeState.status == HabitStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<HabitModel> userHabits = homeState.todayHabits;
    final effectiveCompletionStatus = homeState.effectiveCompletionStatus;
    final ProfileModel? currentUser = homeState.currentUser;
    print(currentUser);
    final String userName = currentUser?.fullName ?? "User";
    final String userEmail = currentUser?.email ?? "email@example.com";

    final completedToday = homeState.completedToday;
    final totalHabits = homeState.totalHabits;
    final progress = homeState.progress;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(homeNotifierProvider.notifier).initializeHome();
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
                  userRole: homeState.userRole,
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

                        if (homeState.userRole == 'doctor' ||
                            homeState.userRole == 'admin')
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: homeState.userRole == 'doctor'
                                  ? const Color(0xFF10B981).withOpacity(0.1)
                                  : const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: homeState.userRole == 'doctor'
                                    ? const Color(0xFF10B981).withOpacity(0.3)
                                    : const Color(0xFFEF4444).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  homeState.userRole == 'doctor'
                                      ? Icons.medical_services
                                      : Icons.admin_panel_settings,
                                  color: homeState.userRole == 'doctor'
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    homeState.userRole == 'doctor'
                                        ? 'Akun dokter Anda sudah aktif'
                                        : 'Anda memiliki akses admin',
                                    style: TextStyle(
                                      color: homeState.userRole == 'doctor'
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        ProgressCard(
                          progress: progress,
                          completed: completedToday,
                          total: totalHabits,
                        ),

                        const SizedBox(height: 16),

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
                          status: homeState.status,
                          errorMessage: homeState.errorMessage,
                          todayCompletionStatus: effectiveCompletionStatus,
                          habits: userHabits,
                          onHabitTap: _handleHabitTap,
                          onCheckboxTap: _handleCheckboxTap,
                          isPremiumUser: true,
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
          completionStatus: ref
              .read(homeNotifierProvider)
              .effectiveCompletionStatus,
        ),
      ),
    );
  }

  void _handleCheckboxTap(HabitModel habit) async {
    final previousStatus =
        ref.read(homeNotifierProvider).effectiveCompletionStatus[habit.id] ??
        LogStatus.neutral;

    try {
      await ref
          .read(homeNotifierProvider.notifier)
          .toggleHabitCompletion(habit);

      final newStatus =
          ref.read(homeNotifierProvider).effectiveCompletionStatus[habit.id] ??
          previousStatus;

      if (newStatus == LogStatus.success) {
        _showSnackBar('Habit completed successfully!');
      } else if (newStatus == LogStatus.failed) {
        _showSnackBar('Habit marked as failed.');
      } else if (newStatus == LogStatus.neutral) {
        _showSnackBar('Habit reset to neutral.');
      }
    } catch (e) {
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
