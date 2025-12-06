// lib\ui\habit-tracker\widget\habit_detail\motivational_quotes_widget.dart
import 'package:flutter/material.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/motivational_quotes/quote_model.dart';
import 'package:purewill/ui/habit-tracker/widget/habit_detail/motivational_quotes/quote_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';


class MotivationalQuotesWidget extends StatefulWidget {
  const MotivationalQuotesWidget({super.key});

  @override
  State<MotivationalQuotesWidget> createState() => _MotivationalQuotesWidgetState();
}

class _MotivationalQuotesWidgetState extends State<MotivationalQuotesWidget> {
  late QuoteRepository _quoteRepository;
  List<Quote> _quotes = [];
  Quote? _currentQuote;
  int _currentIndex = 0;
  Timer? _timer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _fetchQuotes();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeRepository() {
    final supabase = Supabase.instance.client;
    _quoteRepository = QuoteRepository(supabase);
  }

  Future<void> _fetchQuotes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final quotes = await _quoteRepository.fetchQuotes();
      
      if (quotes.isEmpty) {
        // Fallback to default quotes if database is empty
        _quotes = _getDefaultQuotes();
      } else {
        _quotes = quotes;
      }

      // Initialize current quote
      if (_quotes.isNotEmpty) {
        _currentQuote = _quotes[_currentIndex];
        _startTimer();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _quotes = _getDefaultQuotes();
        _currentQuote = _quotes[_currentIndex];
        _startTimer();
      });
    }
  }

  List<Quote> _getDefaultQuotes() {
    return [
      Quote(
        id: '1',
        quote: "Success is the sum of small efforts, repeated day in and day out.",
        author: "Robert Collier",
        createdAt: DateTime.now(),
      ),
      Quote(
        id: '2',
        quote: "The secret of getting ahead is getting started.",
        author: "Mark Twain",
        createdAt: DateTime.now(),
      ),
      Quote(
        id: '3',
        quote: "Don't let yesterday take up too much of today.",
        author: "Will Rogers",
        createdAt: DateTime.now(),
      ),
      Quote(
        id: '4',
        quote: "It's not whether you get knocked down, it's whether you get up.",
        author: "Vince Lombardi",
        createdAt: DateTime.now(),
      ),
      Quote(
        id: '5',
        quote: "The only way to do great work is to love what you do.",
        author: "Steve Jobs",
        createdAt: DateTime.now(),
      ),
    ];
  }

  void _startTimer() {
    // Cancel existing timer
    _timer?.cancel();
    
    // Create new timer that updates every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _nextQuote();
    });
  }

  void _nextQuote() {
    if (_quotes.isEmpty) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % _quotes.length;
      _currentQuote = _quotes[_currentIndex];
    });
  }

  void _refreshQuotes() {
    _fetchQuotes();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_error != null && _currentQuote == null) {
      return _buildErrorWidget();
    }

    return _buildQuoteWidget();
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: const Row(
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey,
          ),
          SizedBox(width: 16),
          Text(
            'Loading motivational quotes...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Failed to load quotes: $_error',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _refreshQuotes,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Tap to retry',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
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

  Widget _buildQuoteWidget() {
    final quote = _currentQuote!;
    
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
          // Animated quote indicator
          _buildQuoteIndicator(),
          
          // Quote content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote text with fade animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    '"${quote.quote}"',
                    key: ValueKey(quote.id),
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Author with fade animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '— ${quote.author}',
                      key: ValueKey('${quote.id}_author'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                
                // Refresh button and timer indicator
                const SizedBox(height: 8),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteIndicator() {
    return Container(
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
          // Animated dots
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _currentIndex == 0 ? Colors.blue : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _currentIndex == 1 ? Colors.blue : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _currentIndex >= 2 ? Colors.blue : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

    );
  }
}