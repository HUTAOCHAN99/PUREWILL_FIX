import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:purewill/domain/model/habit_model.dart';
import 'package:purewill/utils/indonesia_timezone.dart';

class HabitDetailExplanationWidget extends StatelessWidget {
  final HabitModel habit;
  final Color habitColor;

  const HabitDetailExplanationWidget({
    super.key,
    required this.habit,
    required this.habitColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: habitColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: habitColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notes/Description
          if (habit.notes != null && habit.notes!.isNotEmpty) ...[
            const Text(
              "Deskripsi",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              habit.notes!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Frequency
          _buildDetailRow(
            label: "Frekuensi",
            value: _getFrequencyLabel(habit.frequency),
            color: habitColor,
          ),
          const SizedBox(height: 8),

          // Target Value and Unit
          if (habit.targetValue != null && habit.unit != null) ...[
            _buildDetailRow(
              label: "Target",
              value: "${habit.targetValue} ${habit.unit}",
              color: habitColor,
            ),
            const SizedBox(height: 8),
          ],

          // Location Information
          if (habit.isLocationLocked && habit.locationName != null) ...[
            _buildDetailRow(
              label: "Lokasi",
              value: habit.locationName!,
              color: habitColor,
              icon: Icons.location_on,
            ),
            const SizedBox(height: 8),
            if (habit.radius != null)
              _buildDetailRow(
                label: "Jangkauan",
                value: "${habit.radius} meter",
                color: habitColor,
                // icon: Icons.radius_outlined,
                icon: Icons.radar_outlined,
              ),
            const SizedBox(height: 8),
          ],

          // Start Date
          _buildDetailRow(
            label: "Dimulai",
            value: _formatDate(habit.startDate),
            color: habitColor,
            icon: Icons.calendar_today,
          ),

          // Days Running (optional)
          const SizedBox(height: 8),
          _buildDetailRow(
            label: "Durasi",
            value: _calculateDaysRunning(habit.startDate),
            color: habitColor,
            icon: Icons.schedule,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required Color color,
    IconData? icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  String _getFrequencyLabel(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 'Setiap hari';
      case 'weekly':
        return 'Setiap minggu';
      case 'monthly':
        return 'Setiap bulan';
      case 'custom':
        return 'Kustom';
      default:
        return frequency;
    }
  }

  String _formatDate(DateTime dateTime) {
    try {
      return DateFormat('dd MMMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      // Fallback to English format if locale is not initialized
      try {
        return DateFormat('dd MMMM yyyy').format(dateTime);
      } catch (e) {
        // Last resort: simple format
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    }
  }

  String _calculateDaysRunning(DateTime startDate) {
    final now = nowInIndonesia();
    final difference = now.difference(startDate).inDays + 1;
    return '$difference hari';
  }
}
