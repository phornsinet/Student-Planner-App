import 'package:flutter/material.dart';

// Assuming your primary screens are in the same directory structure
import 'login_screen.dart'; 

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

    // 3. Set the Timer for Navigation
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: splashDurationSeconds), () {
      // Use pushReplacement to replace the splash screen on the stack
      // This prevents the user from navigating back to the splash screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
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
                  color: Colors.white, // White background for the icon container
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: const Icon(
                  Icons.school,
                  color: primaryBlue, // Blue icon on white background
                  size: iconSize * 0.7,
                ),
              ),
              const SizedBox(height: 20.0),

              // --- App Name ---
              const Text(
                'Student Planner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10.0),
              
              // --- Tagline ---
              const Text(
                'Organize Your Learning Journey',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}