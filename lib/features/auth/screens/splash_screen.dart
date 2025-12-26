import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; 
import '../../home/screens/main_screen.dart'; // Ensure this path is correct
import '../../../main.dart';

// Define constants for design elements
const Color primaryBlue = Color(0xFF1976D2);
const double iconSize = 100.0;
const int splashDurationSeconds = 3; // How long the screen is displayed

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  
  // Mixin for the FadeTransition animation controller
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // 1. Initialize Animation Controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // The duration of the fade-in animation
    );

    // 2. Define the Animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn, // Smooth slow-to-fast curve
      ),
    );

    // Start the animation
    _animationController.forward();

    // 3. Set the Timer for Navigation with Auth Check
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: splashDurationSeconds), () {
      if (mounted) {
        // FIX: Always navigate to AuthGate. 
        // Let the AuthGate decide if the user goes to Login or MainScreen.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // --- App Icon ---
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  // CHANGE 1: The box background is now BLUE to match your image
                  color: primaryBlue, 
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      // Made shadow slightly darker so the box stands out from the background
                      color: Colors.black.withOpacity(0.3), 
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 24.0),

              // --- App Name ---
              const Text(
                'Student Planner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8.0),
              
              // --- Tagline ---
              const Text(
                'Organize Your Learning Journey',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}