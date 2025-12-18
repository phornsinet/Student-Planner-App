import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this
import '../services/auth_service.dart'; // Ensure this matches your path
import 'register_screen.dart';
import 'forgot_password_screen.dart';

// Define constants for design elements (Keeping your constants)
const Color primaryBlue = Color(0xFF1976D2);
const double cardPadding = 32.0;
const double verticalSpacing = 16.0;
const double iconSize = 80.0;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Controllers to capture input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // 2. Logic to handle the Sign In
  void _signIn() async {
    setState(() => _isLoading = true);
    
    // FIX: Change 'User?' to 'String?' to match your AuthService
    String? result = await _authService.signIn(
      _emailController.text.trim(), 
      _passwordController.text.trim()
    );

    setState(() => _isLoading = false);

    if (result == "success") {
      // Success! The StreamBuilder in main.dart handles the switch
      print("Login success");
    } else {
      // Show the actual error message from Firebase in a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? "Failed to sign in. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(cardPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // 1. The Educational Icon
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: iconSize * 0.6,
                        ),
                      ),
                      const SizedBox(height: verticalSpacing * 1.5),

                      // 2. Welcome Back Text
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Sign in to continue your learning journey',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: verticalSpacing * 2),

                      // 3. Email Input Field (Connected to controller)
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'student@example.com',
                        labelText: 'Email',
                        icon: Icons.email,
                      ),
                      const SizedBox(height: verticalSpacing),

                      // 4. Password Input Field (Connected to controller)
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Enter your password',
                        labelText: 'Password',
                        icon: Icons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: verticalSpacing * 1.5),

                      // 4a. Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: primaryBlue,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: verticalSpacing * 0.5),

                      // 5. Sign In Button (Logic added here)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn, // Disable if loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: verticalSpacing),

                      // 6. Register Link
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text(
                          "Don't have an account? Register",
                          style: TextStyle(color: primaryBlue, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for text fields (Updated to accept controller)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller, // Essential for Firebase
      obscureText: isPassword,
      keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        fillColor: Colors.grey.shade100,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryBlue, width: 2.0),
        ),
      ),
    );
  }
}