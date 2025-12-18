import 'package:flutter/material.dart';
import 'dart:math'; // Import dart:math for random number generation

// 1. Change to StatefulWidget so the screen can update
class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  // 2. Define a list of positive quotes and authors
  final List<Map<String, String>> _quotes = [
    {"quote": "The only way to do great work is to love what you do.", "author": "Steve Jobs"},
    {"quote": "Believe you can and you're halfway there.", "author": "Theodore Roosevelt"},
    {"quote": "Your limitation—it's only your imagination.", "author": "Unknown"},
    {"quote": "Push yourself, because no one else is going to do it for you.", "author": "Unknown"},
    {"quote": "Great things never came from comfort zones.", "author": "Neil Strauss"},
    {"quote": "Dream it. Wish it. Do it.", "author": "Unknown"},
    {"quote": "Success doesn’t just find you. You have to go out and get it.", "author": "Unknown"},
    {"quote": "The harder you work for something, the greater you’ll feel when you achieve it.", "author": "Unknown"},
    {"quote": "Dream bigger. Do bigger.", "author": "Unknown"},
    {"quote": "Don’t stop when you’re tired. Stop when you’re done.", "author": "Unknown"},
    {"quote": "Wake up with determination. Go to bed with satisfaction.", "author": "Unknown"},
    {"quote": "Do something today that your future self will thank you for.", "author": "Sean Patrick Flanery"},
    {"quote": "It’s going to be hard, but hard does not mean impossible.", "author": "Unknown"},
    {"quote": "Don’t wait for opportunity. Create it.", "author": "Unknown"},
    {"quote": "The secret of getting ahead is getting started.", "author": "Mark Twain"},
  ];

  // 3. Variable to track the current index showing
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Generate a random quote right when the screen loads
    _generateRandomQuote();
  }

  // 4. Function to pick a new random index
  void _generateRandomQuote() {
    setState(() {
      _currentIndex = Random().nextInt(_quotes.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 5. Beautiful Gradient Background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 84, 76, 245), // Indigo color
              Color.fromARGB(255, 90, 85, 246), // Purple color
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            // 6. Use a Card to make the text readable against the gradient
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: Colors.white.withOpacity(0.95), // Slightly transparent white
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.format_quote_rounded, size: 50, color: Color(0xFF4F46E5)),
                    const SizedBox(height: 20),
                    
                    // Using AnimatedSwitcher for smooth transition between quotes
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Column(
                        // Key is important for AnimatedSwitcher to know content changed
                        key: ValueKey<int>(_currentIndex),
                        children: [
                          Text(
                            "\"${_quotes[_currentIndex]['quote']}\"",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF1E293B),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "- ${_quotes[_currentIndex]['author']}",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      // 7. Floating button to generate new quote
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateRandomQuote,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4F46E5),
        elevation: 4,
        icon: const Icon(Icons.autorenew_rounded),
        label: const Text("New Quote", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}