// lib\ui\habit-tracker\widget\performance_chart_widget.dart
import 'package:flutter/material.dart';

class PerformanceChartWidget extends StatelessWidget {
  final List<double> weeklyPerformance;

  const PerformanceChartWidget({
    super.key,
    required this.weeklyPerformance,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxPerformance = weeklyPerformance.reduce((a, b) => a > b ? a : b);
    
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title inside the chart
          const Text(
            "Weekly Performance",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final percentage = weeklyPerformance[index] / 100;
                return _buildBarChartItem(days[index], percentage, maxPerformance);
              }),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          _buildPerformanceLegend(),
        ],
      ),
    );
  }

  Widget _buildBarChartItem(String day, double percentage, double maxPerformance) {
    final height = percentage * 80;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: height,
          decoration: BoxDecoration(
            color: _getPerformanceColor(percentage),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(percentage * 100).toInt()}%',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal, // Tidak bold
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(const Color(0xFF4CAF50), "Excellent (80-100%)"),
        _buildLegendItem(const Color(0xFFFFC107), "Good (60-79%)"),
        _buildLegendItem(const Color(0xFFF44336), "Needs Improvement (<60%)"),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage >= 0.8) return const Color(0xFF4CAF50);
    if (percentage >= 0.6) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }
}