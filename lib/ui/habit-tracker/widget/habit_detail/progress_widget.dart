// lib\ui\habit-tracker\widget\habit_details\progress_widget.dart
import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget {
  final bool isCompleted;
  final Color habitColor;
  final String habitName;
  final int completedDays;
  final int totalDays;

  const ProgressWidget({
    super.key,
    required this.isCompleted,
    required this.habitColor,
    required this.habitName,
    required this.completedDays,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    final progress = completedDays / totalDays;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly Progress dan Persentase dalam satu baris
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Weekly Progress",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                "${(progress * 100).round()}%",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress Bar
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Stack(
              children: [
                // Background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                
                // Progress Fill
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: habitColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Keterangan dan Points dalam satu baris
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Keterangan di pojok kiri
              Text(
                "$completedDays of $totalDays days completed",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              // Points di pojok kanan
              Row(
                children: List.generate(totalDays, (index) {
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index < completedDays ? habitColor : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}