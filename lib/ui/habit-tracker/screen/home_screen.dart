// lib\ui\habit-tracker\screen\home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/daily_log_model.dart';
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
      
      // Test notifications setelah init
      _testNotificationsAfterInit();
    });
  }

  Future<void> _testNotificationsAfterInit() async {
    await Future.delayed(Duration(seconds: 2)); // Tunggu sedikit
    await _testSimpleNotification();
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

  // TEST FUNCTIONS
  Future<void> _testSimpleNotification() async {
    try {
      debugPrint('🎯 TEST: Simple notification from HomeScreen...');
      
      await badgeNotificationService.showFloatingBadge(
        badgeName: 'Home Screen Test',
        badgeDescription: 'This notification is triggered from Home Screen! 🎉',
        badgeId: 11111,
      );
      
      debugPrint('✅ Simple notification test completed from HomeScreen');
    } catch (e, stack) {
      debugPrint('❌ Simple notification test failed: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  Future<void> _testBadgeSystem() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        _showSnackBar('No user logged in');
        return;
      }

      debugPrint('🧪 TEST: Badge System from HomeScreen...');
      
      await badgeService.testBadgeSystem(user.id);
      
      _showSnackBar('Badge system test completed!');
    } catch (e, stack) {
      debugPrint('❌ Badge system test failed: $e');
      debugPrint('Stack trace: $stack');
      _showSnackBar('Test failed: $e');
    }
  }

  Future<void> _testMultipleNotifications() async {
    try {
      debugPrint('🎯 TEST: Multiple notifications from HomeScreen...');
      
      final testBadges = [
        {
          'id': 1001,
          'name': 'Test Badge 1 🎯',
          'description': 'First test notification from Home Screen',
        },
        {
          'id': 1002,
          'name': 'Test Badge 2 ⭐',
          'description': 'Second test notification from Home Screen',
        },
        {
          'id': 1003,
          'name': 'Test Badge 3 🏆',
          'description': 'Third test notification from Home Screen',
        },
      ];

      await badgeNotificationService.showMultipleBadges(testBadges);
      
      _showSnackBar('Multiple notifications test completed!');
    } catch (e, stack) {
      debugPrint('❌ Multiple notifications test failed: $e');
      debugPrint('Stack trace: $stack');
      _showSnackBar('Multiple notifications test failed');
    }
  }

  Future<void> _testProgressNotification() async {
    try {
      debugPrint('📊 TEST: Progress notification from HomeScreen...');
      
      await badgeNotificationService.showProgressNotification(
        badgeName: 'Master Habit Builder',
        currentProgress: 7,
        targetProgress: 10,
        progressType: 'habit_count',
      );
      
      _showSnackBar('Progress notification test completed!');
    } catch (e, stack) {
      debugPrint('❌ Progress notification test failed: $e');
      debugPrint('Stack trace: $stack');
      _showSnackBar('Progress notification test failed');
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
                      
                      // TAMBAHAN: TEST BUTTONS SECTION
                      _buildTestButtonsSection(),
                      
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
      
      // TAMBAHAN: FLOATING ACTION BUTTONS UNTUK TEST
      floatingActionButton: _buildTestFloatingButtons(),
    );
  }

  // Widget untuk section test buttons
  Widget _buildTestButtonsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🔧 Test Notifications",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Test badge notifications system:",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTestButton(
                "Simple Test",
                Icons.notifications,
                Colors.blue,
                _testSimpleNotification,
              ),
              _buildTestButton(
                "Multiple Test",
                Icons.notification_important,
                Colors.green,
                _testMultipleNotifications,
              ),
              _buildTestButton(
                "Progress Test",
                Icons.trending_up,
                Colors.orange,
                _testProgressNotification,
              ),
              _buildTestButton(
                "Full System",
                Icons.emoji_events,
                Colors.purple,
                _testBadgeSystem,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  // Widget untuk floating action buttons
  Widget _buildTestFloatingButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Test Button 1 - Simple Notification
        FloatingActionButton(
          onPressed: _testSimpleNotification,
          child: const Icon(Icons.notifications),
          backgroundColor: Colors.blue,
          mini: true,
          heroTag: "test1",
        ),
        const SizedBox(height: 10),
        // Test Button 2 - Multiple Notifications
        FloatingActionButton(
          onPressed: _testMultipleNotifications,
          child: const Icon(Icons.notification_important),
          backgroundColor: Colors.green,
          mini: true,
          heroTag: "test2",
        ),
        const SizedBox(height: 10),
        // Test Button 3 - Badge System
        FloatingActionButton(
          onPressed: _testBadgeSystem,
          child: const Icon(Icons.emoji_events),
          backgroundColor: Colors.purple,
          mini: true,
          heroTag: "test3",
        ),
        const SizedBox(height: 10),
        // Main FAB untuk Add Habit
        FloatingActionButton(
          onPressed: _addHabit,
          child: const Icon(Icons.add),
          heroTag: "main",
        ),
      ],
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