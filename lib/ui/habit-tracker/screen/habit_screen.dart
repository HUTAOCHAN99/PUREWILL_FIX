import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/domain/model/habit_log_model.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/ui/habit-tracker/screen/community_selection_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/consultation_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/home_screen.dart';
import 'package:purewill/ui/habit-tracker/view_model/habit_view_model.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_screen_card.dart';
import 'package:purewill/ui/habit-tracker/widget/clean_bottom_navigation_bar.dart';
import 'package:purewill/ui/habit-tracker/screen/habit_detail_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/add_habit_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/category_unit_management_screen.dart';
import 'package:purewill/ui/habit-tracker/screen/nofap_screen.dart';
// import 'package:purewill/utils/habit_icon_helper.dart';

class HabitScreen extends ConsumerStatefulWidget {
  const HabitScreen({super.key});
  @override
  ConsumerState<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends ConsumerState<HabitScreen> {
  final _currentIndex = 1;
  final TextEditingController _habitSearchController = TextEditingController();
  Map<int, LogStatus> _todayCompletionStatus = {};
  String _habitSearchQuery = '';

  @override
  void dispose() {
    _habitSearchController.dispose();
    super.dispose();
  }

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
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 1) {
      return;
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
    }
  }

  void _onHabitSearchChanged(String value) {
    setState(() {
      _habitSearchQuery = value.trim().toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitsState = ref.watch(habitNotifierProvider);
    final List<HabitModel> userHabits = habitsState.habits;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(176, 230, 216, 1),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        title: const Text(
          'My Habits',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black87),
            tooltip: 'Manage Category & Unit',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CategoryUnitManagementScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: _addHabit,
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset('assets/images/home/bg.png', fit: BoxFit.cover),
          ),
          // Blur effect overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),
          // Content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                print('🔄 HabitScreen: Pull to refresh triggered');
                await ref.read(habitNotifierProvider.notifier).loadUserHabits();
                await _loadTodayCompletionStatus();
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Habit Overview Card
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
                          'Habit Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              'Total Habits',
                              userHabits.length.toString(),
                              Icons.list_alt,
                              Colors.blue,
                            ),
                            _buildStatCard(
                              'Completed Today',
                              _getCompletedTodayCount().toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                            _buildStatCard(
                              'Active Habits',
                              userHabits
                                  .where((h) => h.isActive)
                                  .length
                                  .toString(),
                              Icons.play_circle,
                              Colors.orange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // All Habits Section
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
                          "All Habits",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextField(
                            controller: _habitSearchController,
                            onChanged: _onHabitSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search habit by name',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _habitSearchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _habitSearchController.clear();
                                        _onHabitSearchChanged('');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        _buildHabitsList(userHabits),
                      ],
                    ),
                  ),

                  // Bottom padding
                  const SizedBox(height: 100),
                ],
              ),
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomEmptyState() {
    return Container(
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
            Icons.psychology_outlined,
            color: Colors.grey.shade400,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start building positive habits today!\nTap the + button to add your first habit.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addHabit,
            icon: const Icon(Icons.add),
            label: const Text('Add Habit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(176, 230, 216, 1),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomErrorState(String errorMessage) {
    return Container(
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
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Failed to load habits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(habitNotifierProvider.notifier).loadUserHabits();
              await _loadTodayCompletionStatus();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCompletedTodayCount() {
    print(_todayCompletionStatus.values);
    return _todayCompletionStatus.values
        .where((status) => status == LogStatus.success)
        .length;
  }

  void _addHabit() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddHabitScreen()));
  }

  Future<void> _handleHabitTap(HabitModel habit) async {
    final shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(
          habit: habit,
          completionStatus: _todayCompletionStatus,
        ),
      ),
    );

    if (shouldRefresh == true && mounted) {
      await ref.read(habitNotifierProvider.notifier).loadUserHabits();
      await _loadTodayCompletionStatus();
    }
  }

  Widget _buildHabitsList(List<HabitModel> userHabits) {
    final habitsState = ref.watch(habitNotifierProvider);

    switch (habitsState.status) {
      case HabitStatus.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );

      case HabitStatus.failure:
        return _buildCustomErrorState(
          habitsState.errorMessage ?? 'Unknown error',
        );

      case HabitStatus.success:
        if (userHabits.isEmpty) {
          return _buildCustomEmptyState();
        }
        final userCustomHabits = userHabits.where((h) => !h.isDefault).toList();
        final filteredHabits = _habitSearchQuery.isEmpty
            ? userCustomHabits
            : userCustomHabits
                  .where(
                    (habit) =>
                        habit.name.toLowerCase().contains(_habitSearchQuery),
                  )
                  .toList();

        if (filteredHabits.isEmpty) {
          return _buildHabitSearchEmptyState();
        }

        return Column(
          children: filteredHabits.map((habit) {
            return HabitScreenCard(
              habit: habit,
              onTap: () => _handleHabitTap(habit),
            );
          }).toList(),
        );
    }
  }

  Widget _buildHabitSearchEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            'No habits found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different keyword.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // String _determineCategory(HabitModel habit) {
  //   // Prioritas 1: Jika habit punya categoryId, mapping ke nama kategori
  //   final categoryId = habit.category?.id;
  //   if (categoryId != null) {
  //     final categoryName = _mapCategoryIdToName(categoryId);
  //     return categoryName;
  //   }

  //   // Prioritas 2: Gunakan habit_icon_helper untuk menentukan kategori dari nama habit
  //   final categoryFromName = HabitIconHelper.getHabitCategory(habit.name);
  //   return categoryFromName;
  // }

  // Mapping categoryId ke nama kategori
  // String _mapCategoryIdToName(int categoryId) {
  //   switch (categoryId) {
  //     case 1:
  //       return "Health & Fitness";
  //     case 2:
  //       return "Learning & Education";
  //     case 3:
  //       return "Productivity";
  //     case 4:
  //       return "Mindfulness & Mental Health";
  //     case 5:
  //       return "Personal Care";
  //     case 6:
  //       return "Social & Relationships";
  //     case 7:
  //       return "Finance";
  //     case 8:
  //       return "Hobbies & Creativity";
  //     case 9:
  //       return "Work & Career";
  //     case 10:
  //       return "Other";
  //     default:
  //       return "Other";
  //   }
  // }

  // String _buildHabitSubtitle(HabitModel habit) {
  //   if (habit.targetValue != null) {
  //     if (habit.unit != null && habit.unit!.isNotEmpty) {
  //       return '${habit.targetValue} ${habit.unit}';
  //     }
  //     return '${habit.targetValue}';
  //   }
  //   return 'Daily habit';
  // }

  // Color? _parseCategoryColor(String? rawColor) {
  //   if (rawColor == null || rawColor.trim().isEmpty) {
  //     return null;
  //   }

  //   var hex = rawColor.trim().replaceFirst('#', '');
  //   if (hex.length == 6) {
  //     hex = 'FF$hex';
  //   }
  //   if (hex.length != 8) {
  //     return null;
  //   }

  //   final value = int.tryParse(hex, radix: 16);
  //   if (value == null) {
  //     return null;
  //   }
  //   return Color(value);
  // }
}
