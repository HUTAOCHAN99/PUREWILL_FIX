import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/ui/habit-tracker/widget/clean_bottom_navigation_bar.dart';
import 'package:purewill/ui/habit-tracker/screen/home_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/habit_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/nofap_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/community_selection_screen.dart';

class ConsultationScreen extends ConsumerStatefulWidget {
  const ConsultationScreen({super.key});

  @override
  ConsumerState<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends ConsumerState<ConsultationScreen> {
  int _currentIndex = 4;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Semua', 'icon': Icons.all_inclusive},
    {'name': 'Dokter', 'icon': Icons.medical_services},
    {'name': 'Farmasi', 'icon': Icons.local_pharmacy},
    {'name': 'Rumah Sakit', 'icon': Icons.local_hospital},
    {'name': 'Ambulan', 'icon': Icons.emergency},
    {'name': 'Artikel', 'icon': Icons.article},
  ];

  final List<Map<String, dynamic>> _topDoctors = [
    {
      'name': 'Dr. Marcus Horiz',
      'specialization': 'Kardiologis',
      'rating': 8.9,
      'distance': '0.8 km',
      'image': 'assets/images/doctors/dr_marcus.png',
      'available': true,
    },
    {
      'name': 'Dr. Maria Elena',
      'specialization': 'Psikolog',
      'rating': 5.9,
      'distance': '1.5 km',
      'image': 'assets/images/doctors/dr_maria.png',
      'available': false,
    },
    {
      'name': 'Dr. Stevi Jess',
      'specialization': 'Ortopedis',
      'rating': 4.8,
      'distance': '2 km',
      'image': 'assets/images/doctors/dr_stevi.png',
      'available': true,
    },
  ];

  final List<Map<String, dynamic>> _psychologists = [
    {
      'name': 'Dr. Sarah Johnson',
      'specialization': 'Psikolog Klinis',
      'rating': 9.2,
      'experience': '10 tahun',
      'price': 'Rp 350.000',
      'image': 'assets/images/doctors/psychologist_1.png',
    },
    {
      'name': 'Dr. Michael Chen',
      'specialization': 'Psikoterapis',
      'rating': 8.7,
      'experience': '8 tahun',
      'price': 'Rp 300.000',
      'image': 'assets/images/doctors/psychologist_2.png',
    },
    {
      'name': 'Dr. Lisa Wang',
      'specialization': 'Psikolog Anak & Remaja',
      'rating': 9.5,
      'experience': '12 tahun',
      'price': 'Rp 400.000',
      'image': 'assets/images/doctors/psychologist_3.png',
    },
    {
      'name': 'Dr. David Lee',
      'specialization': 'Psikolog Keluarga',
      'rating': 8.9,
      'experience': '7 tahun',
      'price': 'Rp 320.000',
      'image': 'assets/images/doctors/psychologist_4.png',
    },
  ];

  final List<Map<String, dynamic>> _articles = [
    {
      'title': 'Tips Menjaga Kesehatan Mental di Era Digital',
      'category': 'Kesehatan Mental',
      'readTime': '5 min read',
      'image': 'assets/images/articles/article_1.png',
    },
    {
      'title': 'Mengatasi Anxiety dan Stress Berlebihan',
      'category': 'Psikologi',
      'readTime': '7 min read',
      'image': 'assets/images/articles/article_2.png',
    },
    {
      'title': 'Pentingnya Konsultasi Psikologi Rutin',
      'category': 'Wellness',
      'readTime': '4 min read',
      'image': 'assets/images/articles/article_3.png',
    },
  ];

  void _onNavBarTap(int index) {
    if (index == _currentIndex) return; // Already on this page

    if (index == 0) {
      // Navigate to Home Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 1) {
      // Navigate to Habit Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HabitScreen()),
      );
    } else if (index == 2) {
      // Navigate to NoFap Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NoFapScreen()),
      );
    } else if (index == 3) {
      // Navigate to Community Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const CommunitySelectionScreen(),
        ),
      );
    } else if (index == 4) {
      // Already on Consultation Screen, do nothing
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // App Bar
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
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
                      Icons.notifications_outlined,
                      color: Colors.black87,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search doctor, drugs, articles...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ),

          // Categories
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category['name'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['name'] as String;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF00BFA5)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['name'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Health Protection Banner dengan background lingkaran di belakang foto
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Stack(
              children: [
                // Container utama untuk banner
                Container(
                  height: 140, // Tinggi banner
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00BFA5), Color(0xFF00ACC1)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Early protection for\nyour family health',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Learn more',
                                  style: TextStyle(
                                    color: Color(0xFF00BFA5),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Spacer untuk gambar
                        SizedBox(
                          width: 140, // Lebar untuk gambar dan lingkaran
                        ),
                      ],
                    ),
                  ),
                ),
                // Background Lingkaran dan Gambar
                Positioned(
                  right: 0, // Nempel kanan
                  top: 0, // Nempel atas
                  bottom: 0, // Nempel bawah
                  child: SizedBox(
                    width: 140, // Lebar area untuk lingkaran dan gambar
                    child: Stack(
                      children: [
                        // Background Lingkaran Putih Transparan
                        Positioned(
                          right: 20, // Offset dari kanan
                          top: 20,
                          bottom: 20,
                          child: Container(
                            width: 100, // Diameter lingkaran
                            height: 100, // Diameter lingkaran
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.15),
                                  blurRadius: 15,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Gambar di atas lingkaran
                        Positioned(
                          right: 0, // Nempel kanan container
                          child: Container(
                            width: 120, // Lebar gambar
                            height: 140, // Tinggi gambar (sama dengan banner)
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              image: const DecorationImage(
                                image:
                                    AssetImage('assets/images/consultation/doctor.jpg'),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Doctors Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Top Doctor',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all doctors
                          },
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              color: Color(0xFF00BFA5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top Doctors Horizontal List
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      itemCount: _topDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = _topDoctors[index];
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Gambar dengan tinggi full
                              Expanded(
                                flex: 2, // 2 bagian untuk gambar
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          doctor['image'] as String,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  doctor['rating'].toString(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                              // Konten teks
                              Expanded(
                                flex: 1, // 1 bagian untuk teks
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctor['name'] as String,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        doctor['specialization'] as String,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.grey[400],
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            doctor['distance'] as String,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: doctor['available'] as bool
                                                  ? Colors.green
                                                  : Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Psychologists Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Psikolog',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all psychologists
                          },
                          child: const Text(
                            'Lihat semua',
                            style: TextStyle(
                              color: Color(0xFF00BFA5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Psychologists List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _psychologists.length,
                    itemBuilder: (context, index) {
                      final doctor = _psychologists[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Gambar psikolog dengan tinggi full
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      doctor['image'] as String,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor['name'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    doctor['specialization'] as String,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            doctor['rating'].toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.work_history,
                                            color: Colors.grey,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            doctor['experience'] as String,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    doctor['price'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF00BFA5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.message_outlined,
                                color: Color(0xFF00BFA5),
                              ),
                              onPressed: () {
                                // Start consultation
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Articles Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Artikel Terbaru',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all articles
                          },
                          child: const Text(
                            'Lihat semua',
                            style: TextStyle(
                              color: Color(0xFF00BFA5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Articles List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _articles.length,
                    itemBuilder: (context, index) {
                      final article = _articles[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Gambar artikel dengan tinggi full
                            Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                image: DecorationImage(
                                  image: AssetImage(
                                    article['image'] as String,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article['title'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          article['category'] as String,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        article['readTime'] as String,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar dengan fungsi navigasi
      bottomNavigationBar: CleanBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap, // Gunakan fungsi navigasi
      ),
    );
  }
}