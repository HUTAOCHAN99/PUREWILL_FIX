import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/ui/habit-tracker/screen/community_selection_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/home_screen.dart';
import 'dart:ui';
import 'package:purewill/ui/habit-tracker/widget/clean_bottom_navigation_bar.dart';
import 'package:purewill/ui/habit-tracker/screen/habit_screen.dart';

class ConsultationScreen extends ConsumerStatefulWidget {
  const ConsultationScreen({super.key});

  @override
  ConsumerState<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends ConsumerState<ConsultationScreen> {
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDevelopmentAlert();
    });
  }

  void _showDevelopmentAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.construction, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Dalam Pengembangan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: const Text(
            'Fitur konsultasi sedang dalam tahap pengembangan dan akan segera tersedia. Terima kasih atas kesabaran Anda!',
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromRGBO(176, 230, 216, 1),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onNavBarTap(int index) {
    print('NavBar tapped: index $index');

    if (index == 0) {
       Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ), 
      );
    } else if (index == 1) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => const HabitScreen()));
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const CommunitySelectionScreen(),
        ),
      );
    } else if (index == 3) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/home/bg.png', fit: BoxFit.cover),
          ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),

          // Main Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  floating: true,
                  snap: true,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black87,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Text(
                          'Konsultasi',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.black87,
                          ),
                          onPressed: _showDevelopmentAlert,
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Coming Soon Card
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Fitur Konsultasi',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Segera Hadir!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Kami sedang mengembangkan fitur konsultasi yang akan memungkinkan Anda untuk berkonsultasi dengan ahli kesehatan mental dan coach profesional.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _showDevelopmentAlert,
                                icon: const Icon(Icons.notifications_outlined),
                                label: const Text('Beritahu Saya'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(
                                    176,
                                    230,
                                    216,
                                    1,
                                  ),
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Features Preview Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fitur Yang Akan Datang',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(
                                Icons.video_call,
                                'Video Call',
                                'Konsultasi langsung dengan ahli melalui video call',
                                Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(
                                Icons.chat,
                                'Chat Real-time',
                                'Chat langsung dengan konselor profesional',
                                Colors.green,
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(
                                Icons.schedule,
                                'Jadwal Konsultasi',
                                'Atur jadwal konsultasi sesuai kebutuhan Anda',
                                Colors.purple,
                              ),
                              const SizedBox(height: 16),
                              _buildFeatureItem(
                                Icons.psychology,
                                'Mental Health Assessment',
                                'Evaluasi kesehatan mental secara komprehensif',
                                Colors.orange,
                              ),
                            ],
                          ),
                        ),

                        // Bottom padding to prevent content from being hidden behind bottom nav
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: CleanBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
