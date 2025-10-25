// lib/ui/habit-tracker/screen/home_screen.dart
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

  @override
  void initState() {
    super.initState();
    // Load habits ketika screen pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(habitNotifierProvider.notifier).loadUserHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitsState = ref.watch(habitNotifierProvider);

    // Calculate progress
    final completedHabits = habitsState.habits
        .where((h) => h.status == 'completed')
        .length;
    final totalHabits = habitsState.habits.length;
    final progress = totalHabits > 0 ? completedHabits / totalHabits : 0.0;

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
              // Header dengan nama app dan icon user
              _buildHeader(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome message
                      _buildWelcomeMessage(),

                      // Today's Progress
                      Container(
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
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
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
                              "$completedHabits of $totalHabits habits completed",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Your Habits
                      const Text(
                        "Your Habits",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Habit Cards - Tampilkan data real
                      _buildHabitCards(habitsState),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation - Clean tanpa shadow
      bottomNavigationBar: _buildCleanBottomNavigationBar(),

      floatingActionButton: SpeedDial(
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
            // onTap: () => _navigateToEditHabits(),
          ),
          SpeedDialChild(
            child: const Icon(Icons.notifications, color: Colors.white),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: 'Reminder Settings',
            // onTap: () => _navigateToReminderSettings(),
          ),
        ],
      ),
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
          // Nama Aplikasi
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

          // Icon User dengan Circle Avatar
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
                onPressed: () {
                  _showUserProfileMenu();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk show user profile menu
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
              // Drag indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // User info
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

              // Menu items
              _buildMenuButton(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings
                },
              ),
              _buildMenuButton(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to help
                },
              ),
              _buildMenuButton(
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to about
                },
              ),
              const SizedBox(height: 10),

              // Logout button
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
              // Implement logout logic
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
    // ref.read(authProvider.notifier).logout();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Method untuk build bottom navigation bar yang CLEAN tanpa shadow
  Widget _buildCleanBottomNavigationBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0), width: 1.0)),
      ),
      child: ClipRect(
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
          elevation: 0, // Pastikan elevation 0
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Navigasi ke AddHabitScreen ketika Habits Tracker ditekan
            if (index == 2) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddHabitScreen()),
              );
              // Kembalikan index ke Home setelah navigasi
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
              icon: Icon(Icons.forum_outlined, size: 24),
              activeIcon: Icon(Icons.forum, size: 24),
              label: 'Forum',
            ),
          ],
        ),
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
              habitsState.errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(habitNotifierProvider.notifier).loadUserHabits();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (habitsState.habits.isEmpty) {
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
                  MaterialPageRoute(
                    builder: (context) => const AddHabitScreen(),
                  ),
                );
              },
              child: const Text('Add Habit'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: habitsState.habits.map((habit) {
        final iconData =
            DefaultHabitsService.getDefaultHabitIcons()[habit.name] ??
            Icons.assignment_outlined;
        final color =
            DefaultHabitsService.getDefaultHabitColors()[habit.name] ??
            Colors.grey;

        // Calculate progress based on habit status or target value
        final progress = _calculateHabitProgress(habit);
        final isCompleted = habit.status == 'completed';

        return HabitCard(
          icon: iconData,
          title: habit.name,
          subtitle: _buildHabitSubtitle(habit),
          color: color,
          progress: progress,
          isCompleted: isCompleted,
          isDefault: habit.isDefault,
          onTap: () {
            // Handle habit tap (mark as completed, etc.)
            _handleHabitTap(habit);
          },
        );
      }).toList(),
    );
  }

  String _buildHabitSubtitle(HabitModel habit) {
    if (habit.targetValue != null) {
      if (habit.name.toLowerCase().contains('water')) {
        return '${habit.targetValue} glasses';
      } else if (habit.name.toLowerCase().contains('read')) {
        return '${habit.targetValue} pages';
      } else if (habit.name.toLowerCase().contains('workout') ||
          habit.name.toLowerCase().contains('exercise')) {
        return '${habit.targetValue} minutes';
      } else if (habit.name.toLowerCase().contains('sleep')) {
        return 'Before ${habit.targetValue} PM';
      } else {
        return '${habit.targetValue} units';
      }
    }
    return 'Daily habit';
  }

  double _calculateHabitProgress(HabitModel habit) {
    // Logic untuk menghitung progress habit
    // Ini bisa disesuaikan dengan kebutuhan bisnis
    if (habit.status == 'completed') return 1.0;
    if (habit.status == 'in-progress') return 0.5;
    return 0.0;
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.blue;
    if (progress >= 0.3) return Colors.amber;
    return Colors.red;
  }

  void _handleHabitTap(HabitModel habit) {
    // Handle ketika habit di-tap
    // Bisa untuk menandai sebagai completed, dll.
    print('Habit tapped: ${habit.name}');

    // Jika habit default, minta user untuk menambahkannya ke habits mereka
    if (habit.isDefault) {
      _showAddDefaultHabitDialog(habit);
    } else {
      // Untuk habit yang sudah dibuat user, toggle completion status
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
              // Navigate to add habit screen dengan data pre-filled
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

  void _toggleHabitCompletion(HabitModel habit) {
    final viewModel = ref.read(habitNotifierProvider.notifier);
    final newStatus = habit.status == 'completed' ? 'neutral' : 'completed';

    // Update status habit di local state terlebih dahulu untuk feedback langsung
    final updatedHabit = HabitModel(
      id: habit.id,
      userId: habit.userId,
      name: habit.name,
      frequency: habit.frequency,
      startDate: habit.startDate,
      isActive: habit.isActive,
      categoryId: habit.categoryId,
      notes: habit.notes,
      endDate: habit.endDate,
      targetValue: habit.targetValue,
      status: newStatus,
      reminderEnabled: habit.reminderEnabled,
      reminderTime: habit.reminderTime,
    );

    // TODO: Implement update habit status di repository
    // Untuk sementara, reload habits untuk melihat perubahan
    viewModel.loadUserHabits();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == 'completed'
              ? '${habit.name} marked as completed!'
              : '${habit.name} marked as not completed',
        ),
        duration: const Duration(seconds: 2),
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
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(icon, color: color, size: 22),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 6,
                    percent: progress,
                    progressColor: color,
                    backgroundColor: Colors.grey[200]!,
                    barRadius: const Radius.circular(8),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isCompleted
                  ? Icons.check_circle
                  : isDefault
                  ? Icons.add_circle_outline
                  : Icons.circle_outlined,
              color: isCompleted
                  ? Colors.green
                  : isDefault
                  ? Colors.blue
                  : Colors.grey,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
