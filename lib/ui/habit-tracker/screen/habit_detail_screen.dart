// lib\ui\habit-tracker\screen\habit_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/ui/habit-tracker/habit_provider.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/calendar_tracker_widget.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/habit_actions_dropdown.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/motivational_quote_widget.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/performance_chart_widget.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/progress_widget.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/weekly_streak_widget.dart';
import 'package:purewill/utils/habit_icon_helper.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final HabitModel habit;
  final Map<int, bool> completionStatus;
  const HabitDetailScreen({
    super.key,
    required this.habit,
    required this.completionStatus,
  });

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  late bool _isCompleted;
  final List<bool> _weeklyStreak = [
    true,
    false,
    true,
    true,
    false,
    true,
    false,
  ];
  final List<double> _weeklyPerformance = [80, 60, 90, 70, 50, 85, 40];
  final List<DateTime> _completionDates = [
    DateTime.now().subtract(const Duration(days: 2)),
    DateTime.now().subtract(const Duration(days: 4)),
    DateTime.now().subtract(const Duration(days: 5)),
    DateTime.now().subtract(const Duration(days: 7)),
  ];

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.completionStatus[widget.habit.id] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final iconData = HabitIconHelper.getHabitIcon(widget.habit.name);
    final iconColor = HabitIconHelper.getHabitColor(widget.habit.name);
    final category = HabitIconHelper.getHabitCategory(widget.habit.name);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color.fromRGBO(184, 230, 230, 1),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeaderBackground(iconData, iconColor, category),
              titlePadding: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
              collapseMode: CollapseMode.pin,
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Habit detail",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            // UPDATED: Gunakan component
            actions: [
              HabitActionsDropdown(
                onActionSelected: _handleMenuAction,
                habitName: widget.habit.name,
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProgressWidget(
                    isCompleted: false,
                    habitColor: Colors.blue,
                    habitName: "Exercise",
                    completedDays: 5,
                    totalDays: 7,
                  ),
                  const SizedBox(height: 24),

                  WeeklyStreakWidget(weeklyStreak: _weeklyStreak),
                  const SizedBox(height: 24),

                  PerformanceChartWidget(weeklyPerformance: _weeklyPerformance),
                  const SizedBox(height: 24),

                  CalendarTrackerWidget(completionDates: _completionDates),
                  const SizedBox(height: 16),
                  
                  MotivationalQuotesWidget(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED: Handler untuk dropdown menu actions
  void _handleMenuAction(String value) {
    HabitActionsDropdown.handleMenuAction(
      value: value,
      context: context,
      habitName: widget.habit.name,
      onEdit: _editHabit,
      onReminder: _setReminder,
      onDelete: _deleteHabit,
    );
  }

  // Opsional: Custom handlers jika perlu logic khusus
  void _editHabit() {
    // Custom edit logic bisa ditambahkan di sini
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Habit - Custom Logic')),
    );
  }

  void _setReminder() {
    // Custom reminder logic bisa ditambahkan di sini
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder Settings - Custom Logic')),
    );
  }

  void _deleteHabit() {
    // Custom delete logic bisa ditambahkan di sini
    HabitActionsDropdown.showDeleteConfirmationDialog(
      context: context,
      habitName: widget.habit.name,
      onConfirm: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${widget.habit.name}" deleted with custom logic')),
        );
        Navigator.pop(context); // Kembali ke home
      },
    );
  }

  Widget _buildHeaderBackground(
    IconData iconData,
    Color iconColor,
    String category,
  ) {
    return Container(
      color: const Color.fromRGBO(184, 230, 230, 1),
      padding: const EdgeInsets.only(
        top: kToolbarHeight + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(iconData, size: 25, color: iconColor),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.habit.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleCompletion() async {
    try {
      final viewModel = ref.read(habitNotifierProvider.notifier);
      await viewModel.toggleHabitCompletion(widget.habit);

      setState(() {
        _isCompleted = !_isCompleted;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isCompleted
                ? '${widget.habit.name} completed! ✅'
                : '${widget.habit.name} marked as not completed',
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
}