import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:purewill/data/services/default_habits_service.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/ui/habit-tracker/screen/add_habit_screen.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/ui/habit-tracker/view_model/habit_view_model.dart';

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
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    await ref.read(habitNotifierProvider.notifier).loadUserHabits();
    await _loadTodayCompletionStatus();
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

    // Calculate progress based on today's completion
    final completedToday = _todayCompletionStatus.values
        .where((completed) => completed)
        .length;
    final totalHabits = habitsState.habits.length;
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
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeMessage(),
                      _buildProgressCard(progress, completedToday, totalHabits),
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
                      _buildHabitCards(habitsState),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCleanBottomNavigationBar(),
      floatingActionButton: _buildSpeedDial(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(176, 230, 216, 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              SizedBox(width: 8),
              Text(
                'PureWill',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(
                  Icons.person,
                  color: Color(0xFF7C3AED),
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _showUserProfileMenu,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        'Hello, ${_getUserDisplayName()}!',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildProgressCard(double progress, int completed, int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Progress",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: progress,
            progressColor: _getProgressColor(progress),
            backgroundColor: Colors.grey[200]!,
            barRadius: const Radius.circular(8),
          ),
          const SizedBox(height: 8),
          Text(
            "$completed of $total habits completed",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCards(HabitsState habitsState) {
    if (habitsState.status == HabitStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (habitsState.status == HabitStatus.failure) {
      return _buildErrorState(habitsState.errorMessage ?? 'Unknown error');
    }

    if (habitsState.habits.isEmpty) {
      return _buildEmptyState();
    }

    final defaultHabits = habitsState.habits.where((h) => h.isDefault).toList();
    final userHabits = habitsState.habits.where((h) => !h.isDefault).toList();
    final sortedHabits = [...defaultHabits, ...userHabits];

    return Column(
      children: sortedHabits.map((habit) {
        final isCompleted = _todayCompletionStatus[habit.id] ?? false;
        final iconData =
            DefaultHabitsService.getDefaultHabitIcons()[habit.name] ??
            Icons.assignment_outlined;
        final color =
            DefaultHabitsService.getDefaultHabitColors()[habit.name] ??
            Colors.grey;

        return HabitCard(
          icon: iconData,
          title: habit.name,
          subtitle: _buildHabitSubtitle(habit),
          color: color,
          progress: isCompleted ? 1.0 : 0.0,
          isCompleted: isCompleted,
          isDefault: habit.isDefault,
          onTap: () => _handleHabitTap(habit),
        );
      }).toList(),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          const Text(
            'Failed to load habits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, color: Colors.grey, size: 48),
          const SizedBox(height: 8),
          const Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first habit to get started!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddHabitScreen()),
              );
            },
            child: const Text('Add Habit'),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1.0)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        showUnselectedLabels: true,
        elevation: 0,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddHabitScreen()),
            );
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                setState(() {
                  _currentIndex = 0;
                });
              }
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24),
            activeIcon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 24),
            activeIcon: Icon(Icons.chat_bubble, size: 24),
            label: 'Konsultasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 24),
            activeIcon: Icon(Icons.add_circle, size: 24),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined, size: 24),
            activeIcon: Icon(Icons.chat, size: 24),
            label: 'Forum',
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: const Color(0xFF7C3AED),
      foregroundColor: Colors.white,
      overlayColor: Colors.black,
      overlayOpacity: 0.4,
      spacing: 12,
      spaceBetweenChildren: 12,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          label: 'Add New Habit',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddHabitScreen()),
            );
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.edit, color: Colors.white),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          label: 'Edit Habits',
          onTap: () {
            // TODO: Implement edit habits
          },
        ),
        SpeedDialChild(
          child: const Icon(Icons.notifications, color: Colors.white),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          label: 'Reminder Settings',
          onTap: () {
            // TODO: Implement reminder settings
          },
        ),
      ],
    );
  }

  String _buildHabitSubtitle(HabitModel habit) {
    if (habit.targetValue != null && habit.unit != null) {
      return '${habit.targetValue} ${habit.unit}';
    }
    return 'Daily habit';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.blue;
    if (progress >= 0.3) return Colors.amber;
    return Colors.red;
  }

  void _handleHabitTap(HabitModel habit) {
    if (habit.isDefault) {
      _showAddDefaultHabitDialog(habit);
    } else {
      _toggleHabitCompletion(habit);
    }
  }

  void _showAddDefaultHabitDialog(HabitModel habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Habit'),
        content: Text('Would you like to add "${habit.name}" to your habits?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddHabitScreen.withDefault(habit),
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleHabitCompletion(HabitModel habit) async {
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
  void _showUserProfileMenu() {
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
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

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

  void _performLogout() {
    // TODO: Implement logout logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class HabitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double progress;
  final Color color;
  final bool isCompleted;
  final bool isDefault;
  final VoidCallback? onTap;

  const HabitCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.progress,
    required this.isCompleted,
    this.isDefault = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          border: isDefault ? Border.all(color: color.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isCompleted
                      ? color.withOpacity(0.2)
                      : color.withOpacity(0.1),
                  child: Icon(
                    icon,
                    color: isCompleted ? color : color.withOpacity(0.7),
                    size: 22,
                  ),
                ),
                if (isDefault)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                if (isCompleted)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: isCompleted ? Colors.grey : Colors.black,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.blue, size: 12),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isCompleted ? Colors.green : Colors.grey,
                      fontWeight: isCompleted
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 6,
                    percent: progress,
                    progressColor: isCompleted ? Colors.green : color,
                    backgroundColor: Colors.grey[200]!,
                    barRadius: const Radius.circular(8),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? Colors.green : Colors.grey,
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle_outlined,
                color: isCompleted ? Colors.white : Colors.grey,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
