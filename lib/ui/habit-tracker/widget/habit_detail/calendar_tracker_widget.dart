import 'package:flutter/material.dart';

class CalendarTrackerWidget extends StatelessWidget {
  final List<DateTime> completionDates;

  CalendarTrackerWidget({
    super.key,
    required this.completionDates,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9ECEF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                _getMonthName(now.month),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildWeekDaysHeader(),
              const SizedBox(height: 8),
              
              _buildCalendarGrid(today),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(DateTime today) {
    return Column(
      children: [
        _buildWeekRow(today, -6, 0),
        const SizedBox(height: 12),
        
        _buildWeekRow(today, 1, 7),
      ],
    );
  }

  Widget _buildWeekDaysHeader() {
    return Row(
      children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
          .map((day) => Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildWeekRow(DateTime today, int startDay, int endDay) {
    return Row(
      children: List.generate(7, (index) {
        final dayOffset = startDay + index;
        final currentDate = today.add(Duration(days: dayOffset));
        final dayStatus = _getDayStatus(currentDate, today);
        
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getDayColor(dayStatus),
              shape: BoxShape.circle,
              border: dayStatus == 'today' ? Border.all(
                color: Colors.blue,
                width: 2,
              ) : null,
            ),
            child: Center(
              child: Text(
                currentDate.day.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(dayStatus),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  String _getDayStatus(DateTime date, DateTime today) {
    final isToday = date.year == today.year && 
                    date.month == today.month && 
                    date.day == today.day;
    
    if (isToday) {
      return 'today';
    }
    
    final isCompleted = completionDates.any((completedDate) =>
        completedDate.year == date.year &&
        completedDate.month == date.month &&
        completedDate.day == date.day);
    
    if (date.isBefore(today)) {
      return isCompleted ? 'completed' : 'missed';
    } else {
      return isCompleted ? 'completed' : 'pending';
    }
  }

  Color _getDayColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF4CAF50); // Green
      case 'missed':
        return const Color(0xFFF44336); // Red
      case 'today':
        return Colors.transparent;
      case 'pending':
        return Colors.grey[300]!; // Abu-abu untuk hari yang belum terlaksana
      default:
        return Colors.transparent;
    }
  }

  Color _getTextColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.white;
      case 'missed':
        return Colors.white;
      case 'today':
        return Colors.blue;
      case 'pending':
        return Colors.grey[600]!; // Teks abu-abu gelap untuk kontras
      default:
        return Colors.black87;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}