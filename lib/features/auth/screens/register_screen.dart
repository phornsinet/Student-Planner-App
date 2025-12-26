import 'package:flutter/material.dart';
import 'package:student_planner_app/features/auth/services/auth_service.dart';
import 'package:student_planner_app/features/tasks/screens/task_list_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleRegister() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password != confirm) {
      _showSnackBar("Passwords do not match!");
      return;
    }

    setState(() => _isLoading = true);

    String? result = await _authService.signUp(email, password);

    if (mounted) setState(() => _isLoading = false);

    if (result == "success") {
      
      if (mounted) {
        Navigator.pop(context); 
      }
    } else {
      _showSnackBar(result ?? "An error occurred");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF1976D2);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school, size: 50, color: primaryBlue),
                  const SizedBox(height: 16),
                  const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  _buildTextField(_emailController, 'Email', Icons.email, false),
                  const SizedBox(height: 16),
                  _buildTextField(_passwordController, 'Password', Icons.lock, true),
                  const SizedBox(height: 16),
                  _buildTextField(_confirmController, 'Confirm Password', Icons.lock_outline, true),
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Register', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Already have an account? Sign In", style: TextStyle(color: primaryBlue)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isPass) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}