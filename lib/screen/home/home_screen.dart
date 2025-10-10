import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:purewill/screen/auth/login_screen.dart';
import 'package:purewill/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final AuthService _authService = AuthService();
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FBF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PureWill',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.purple,
            ),
            onPressed: () {
              // Show user profile or logout dialog
              _showUserMenu(context, user, _authService);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message with user email
            if (user != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Hello, ${user.email?.split('@').first ?? 'User'}!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],

            // Today's Progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                    percent: 0.75,
                    progressColor: Colors.blueAccent,
                    backgroundColor: Colors.grey[200]!,
                    barRadius: const Radius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "3 of 4 habits completed",
                    style: TextStyle(color: Colors.grey),
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
              ),
            ),

            const SizedBox(height: 12),

            // Habit Cards
            HabitCard(
              icon: Icons.fitness_center,
              title: "Morning Workout",
              subtitle: "30 minutes",
              color: Colors.green,
              progress: 1.0,
              isCompleted: true,
            ),
            HabitCard(
              icon: Icons.menu_book_rounded,
              title: "Read Books",
              subtitle: "20 pages",
              color: Colors.green,
              progress: 1.0,
              isCompleted: true,
            ),
            HabitCard(
              icon: Icons.water_drop,
              title: "Drink Water",
              subtitle: "8 glasses",
              color: Colors.amber,
              progress: 0.7,
              isCompleted: false,
            ),
            HabitCard(
              icon: Icons.nightlight_round,
              title: "Sleep Early",
              subtitle: "Before 11 PM",
              color: Colors.blue,
              progress: 0.5,
              isCompleted: false,
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 0,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Konsultasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'Habits Tracker',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum_outlined),
              label: 'Forum',
            ),
          ],
        ),
      ),
    );
  }

  void _showUserMenu(BuildContext context, User? user, AuthService authService) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user != null) ...[
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.purple),
                  title: const Text('Email'),
                  subtitle: Text(user.email ?? 'No email'),
                ),
                const Divider(),
              ],
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  _logout(context, authService);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context, AuthService authService) async {
    try {
      await authService.logout();
      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class HabitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double progress;
  final Color color;
  final bool isCompleted;

  const HabitCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.progress,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
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
            isCompleted ? Icons.check_circle : Icons.add_circle_outline,
            color: isCompleted ? Colors.green : Colors.grey,
            size: 28,
          ),
        ],
      ),
    );
  }
}