import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../../tasks/controllers/task_controller.dart'; 
import '../../tasks/screens/edit_profile_screen.dart'; 

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TaskController _controller = TaskController();

  @override
  void initState() {
    super.initState();
    _controller.loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // Modern soft background
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              children: [
                // --- PROFILE IMAGE SECTION ---
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: _controller.userProfileBase64 != null && _controller.userProfileBase64!.isNotEmpty
                          ? ClipOval(
                              child: Image.memory(
                                base64Decode(_controller.userProfileBase64!),
                                fit: BoxFit.cover,
                                width: 110,
                                height: 110,
                              ),
                            )
                          : const Icon(Icons.person_rounded, size: 50, color: Color(0xFF2563EB)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // --- USER INFO ---
                Text(
                  user?.displayName ?? "Student User",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? "no-email@student.com",
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
                const SizedBox(height: 32),

                // --- SETTINGS GROUP ---
                _buildSettingsGroup([
                  _buildAccountTile(
                    icon: Icons.edit_rounded,
                    title: "Edit Profile",
                    subtitle: "Change your name and avatar",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                  ),
                  _buildAccountTile(
                    icon: Icons.notifications_none_rounded,
                    title: "Notifications",
                    subtitle: "Manage study reminders",
                    onTap: () {},
                  ),
                ]),

                const SizedBox(height: 20),

                // --- DANGER ZONE GROUP ---
                _buildSettingsGroup([
                  _buildAccountTile(
                    icon: Icons.logout_rounded,
                    title: "Logout",
                    subtitle: "Sign out of your account",
                    color: Colors.redAccent,
                    onTap: () => FirebaseAuth.instance.signOut(),
                    showArrow: false,
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper to build a clean card-like group
  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // Helper to build modern list tiles
  Widget _buildAccountTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = const Color(0xFF2563EB),
    bool showArrow = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E293B))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
      trailing: showArrow ? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E1)) : null,
      onTap: onTap,
    );
  }
}