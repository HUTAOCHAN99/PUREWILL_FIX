import 'package:flutter/material.dart';
import 'dart:math';

class MotivationalQuotesWidget extends StatefulWidget {
  @override
  _MotivationalQuotesWidgetState createState() =>
      _MotivationalQuotesWidgetState();
}

class _MotivationalQuotesWidgetState extends State<MotivationalQuotesWidget> {
  final List<Map<String, String>> quotes = [
    {
      "quote":
          "Success is the sum of small efforts repeated day in and day out.",
      "author": "Robert Collier",
    },
    {
      "quote": "The secret of getting ahead is getting started.",
      "author": "Mark Twain",
    },
    {
      "quote": "Don't watch the clock; do what it does. Keep going.",
      "author": "Sam Levenson",
    },
    {
      "quote": "The way to get started is to quit talking and begin doing.",
      "author": "Walt Disney",
    },
    {
      "quote": "Small daily improvements over time lead to stunning results.",
      "author": "Robin Sharma",
    },
    {
      "quote":
          "Motivation is what gets you started. Habit is what keeps you going.",
      "author": "Jim Ryun",
    },
  ];

  late Map<String, String> currentQuote;

  @override
  void initState() {
    super.initState();
    _getRandomQuote();
  }

  void _getRandomQuote() {
    final random = Random();
    currentQuote = quotes[random.nextInt(quotes.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.8),
            const Color(0xFF8B5CF6).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.format_quote,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Motivation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"${currentQuote["quote"]}"',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "— ${currentQuote["author"]}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
