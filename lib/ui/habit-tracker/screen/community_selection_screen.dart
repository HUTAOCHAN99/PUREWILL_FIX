// lib\ui\habit-tracker\screen\community_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:purewill/ui/habit-tracker/widget/clean_bottom_navigation_bar.dart';
import 'package:purewill/ui/habit-tracker/widget/community/community_confirmation_dialog.dart';

class CommunitySelectionScreen extends StatefulWidget {
  const CommunitySelectionScreen({super.key});

  @override
  State<CommunitySelectionScreen> createState() => _CommunitySelectionScreenState();
}

class _CommunitySelectionScreenState extends State<CommunitySelectionScreen> {
  int _currentIndex = 3; // Index untuk tab komunitas
  
  final List<Community> communities = [
    Community(
      id: 1,
      name: 'Fitness & Workout',
      description: 'Komunitas untuk pecinta fitness dan workout sehari-hari',
      memberCount: 1250,
      icon: Icons.fitness_center,
      color: const Color(0xFF2196F3),
      isJoined: false,
    ),
    Community(
      id: 2,
      name: 'Mental Wellness',
      description: 'Diskusi tentang kesehatan mental dan mindfulness',
      memberCount: 890,
      icon: Icons.psychology,
      color: const Color(0xFF9C27B0),
      isJoined: true, // Contoh: user sudah join
    ),
    Community(
      id: 3,
      name: 'Healthy Eating',
      description: 'Berbagi resep sehat dan tips nutrisi',
      memberCount: 1560,
      icon: Icons.restaurant,
      color: const Color(0xFF4CAF50),
      isJoined: false,
    ),
    Community(
      id: 4,
      name: 'Morning Routine',
      description: 'Membangun rutinitas pagi yang produktif',
      memberCount: 780,
      icon: Icons.wb_sunny,
      color: const Color(0xFFFF9800),
      isJoined: false,
    ),
    Community(
      id: 5,
      name: 'Productivity',
      description: 'Tips dan trik untuk meningkatkan produktivitas',
      memberCount: 2100,
      icon: Icons.work,
      color: const Color(0xFF3F51B5),
      isJoined: false,
    ),
    Community(
      id: 6,
      name: 'Reading Habit',
      description: 'Komunitas pecinta buku dan membaca',
      memberCount: 950,
      icon: Icons.menu_book,
      color: const Color(0xFF795548),
      isJoined: true, // Contoh: user sudah join
    ),
    Community(
      id: 7,
      name: 'Meditation',
      description: 'Panduan meditasi dan relaksasi',
      memberCount: 670,
      icon: Icons.self_improvement,
      color: const Color(0xFF00BCD4),
      isJoined: false,
    ),
    Community(
      id: 8,
      name: 'Study Group',
      description: 'Belajar bersama dan diskusi pengetahuan',
      memberCount: 1850,
      icon: Icons.school,
      color: const Color(0xFFE91E63),
      isJoined: false,
    ),
  ];

  List<Community> get joinedCommunities =>
      communities.where((c) => c.isJoined).toList();

  List<Community> get availableCommunities =>
      communities.where((c) => !c.isJoined).toList();

  void _onNavBarTap(int index) {
    // Jika user menekan tab komunitas lagi, scroll ke atas
    if (index == _currentIndex) {
      // TODO: Implement scroll to top jika ada ScrollController
    } else {
      // Navigasi ke tab lain
      if (index == 0) {
        Navigator.of(context).pop(); // Kembali ke home screen
      } else if (index == 1) {
        // Navigasi ke konsultasi
        // Navigator.pushNamed(context, '/konsultasi');
        _showComingSoon('Konsultasi');
      } else if (index == 2) {
        // Navigasi ke add habit
        // Navigator.pushNamed(context, '/add-habit');
        _showComingSoon('Add Habit');
      }
    }
  }

  void _showConfirmationDialog(BuildContext context, Community community) {
    showDialog(
      context: context,
      builder: (context) => CommunityConfirmationDialog(
        community: community,
        onJoin: () => _joinCommunity(community),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _joinCommunity(Community community) {
    setState(() {
      final index = communities.indexWhere((c) => c.id == community.id);
      if (index != -1) {
        communities[index] = communities[index].copyWith(isJoined: true);
      }
    });

    Navigator.pop(context); // Tutup dialog

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil bergabung dengan ${community.name}! 🎉'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Lihat',
          textColor: Colors.white,
          onPressed: () {
            _navigateToCommunityDetail(community);
          },
        ),
      ),
    );
  }

  void _leaveCommunity(Community community) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Komunitas'),
        content: Text('Apakah Anda yakin ingin keluar dari ${community.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final index = communities.indexWhere((c) => c.id == community.id);
                if (index != -1) {
                  communities[index] = communities[index].copyWith(isJoined: false);
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Anda telah keluar dari ${community.name}'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCommunityDetail(Community community) {
    // TODO: Implementasi screen detail komunitas
    _showComingSoon('Detail Komunitas');
  }

  void _showComingSoon(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon!'),
        content: Text('Fitur $feature akan segera hadir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE8F4F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Komunitas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // TODO: Implement search functionality
                        _showComingSoon('Pencarian Komunitas');
                      },
                      icon: const Icon(Icons.search, size: 28),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Komunitas yang Diikuti
                      if (joinedCommunities.isNotEmpty) ...[
                        _buildSectionTitle(
                          'Komunitas Anda',
                          '${joinedCommunities.length} komunitas',
                        ),
                        const SizedBox(height: 12),
                        _buildJoinedCommunitiesList(),
                        const SizedBox(height: 24),
                      ],

                      // Section: Temukan Komunitas Lain
                      _buildSectionTitle(
                        'Temukan Komunitas',
                        '${availableCommunities.length} komunitas tersedia',
                      ),
                      const SizedBox(height: 12),
                      _buildAvailableCommunitiesList(),
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

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildJoinedCommunitiesList() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: joinedCommunities.length,
      itemBuilder: (context, index) {
        final community = joinedCommunities[index];
        return _buildJoinedCommunityCard(community);
      },
    );
  }

  Widget _buildJoinedCommunityCard(Community community) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToCommunityDetail(community),
        onLongPress: () => _leaveCommunity(community),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: community.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  community.icon,
                  color: community.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                community.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 12,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${community.memberCount}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Bergabung',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableCommunitiesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: availableCommunities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final community = availableCommunities[index];
        return _buildAvailableCommunityCard(community);
      },
    );
  }

  Widget _buildAvailableCommunityCard(Community community) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: () => _showConfirmationDialog(context, community),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: community.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  community.icon,
                  color: community.color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      community.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${community.memberCount} anggota',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Community {
  final int id;
  final String name;
  final String description;
  final int memberCount;
  final IconData icon;
  final Color color;
  final bool isJoined;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    required this.icon,
    required this.color,
    required this.isJoined,
  });

  Community copyWith({
    bool? isJoined,
  }) {
    return Community(
      id: id,
      name: name,
      description: description,
      memberCount: memberCount,
      icon: icon,
      color: color,
      isJoined: isJoined ?? this.isJoined,
    );
  }
}