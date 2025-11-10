// lib\ui\habit-tracker\widget\habit_detail\motivational_quotes_widget.dart
import 'package:flutter/material.dart';

class MotivationalQuotesWidget extends StatelessWidget {
  // Data dummy quotes motivasi
  final List<Map<String, String>> _motivationalQuotes = [
    {
      'id': '1',
      'quote': "Success is the sum of small efforts, repeated day in and day out.",
      'author': "Robert Collier"
    },
    {
      'id': '2', 
      'quote': "The secret of getting ahead is getting started.",
      'author': "Mark Twain"
    },
    {
      'id': '3',
      'quote': "Don't let yesterday take up too much of today.",
      'author': "Will Rogers"
    },
    {
      'id': '4',
      'quote': "It's not whether you get knocked down, it's whether you get up.",
      'author': "Vince Lombardi"
    },
    {
      'id': '5',
      'quote': "The only way to do great work is to love what you do.",
      'author': "Steve Jobs"
    },
  ];

  // Remove 'const' from constructor
  MotivationalQuotesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final randomQuote = _motivationalQuotes[DateTime.now().day % _motivationalQuotes.length];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bubble text decoration
          Container(
            width: 24,
            height: 60,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE9ECEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          
          // Quote content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote text
                Text(
                  '"${randomQuote['quote']}"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Author
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '— ${randomQuote['author']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
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
}