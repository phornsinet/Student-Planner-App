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
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // --- VIBRANT GRADIENT HEADER ---
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2563EB), Color.fromARGB(255, 100, 56, 223), Color.fromARGB(255, 112, 78, 225)],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      child: const Text(
                        "My Profile",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    // --- FLOATING PROFILE IMAGE ---
                    Positioned(
                      bottom: -50,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFF1F5F9),
                          child: _controller.userProfileBase64 != null && _controller.userProfileBase64!.isNotEmpty
                              ? ClipOval(
                                  child: Image.memory(
                                    base64Decode(_controller.userProfileBase64!),
                                    fit: BoxFit.cover,
                                    width: 120, height: 120,
                                  ),
                                )
                              : const Icon(Icons.person_rounded, size: 60, color: Color(0xFF2563EB)),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 60),

                // --- USER INFO ---
                Text(
                  user?.displayName ?? "Student User",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                Text(
                  user?.email ?? "no-email@student.com",
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),

                const SizedBox(height: 30),

                // --- SETTINGS SECTION ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF64748B))),
                      const SizedBox(height: 12),
                      _buildSettingsGroup([
                        _buildAccountTile(
                          icon: Icons.edit_rounded,
                          title: "Edit Profile",
                          subtitle: "Update info & photo",
                          iconBgColor: const Color(0xFFDBEAFE),
                          iconColor: const Color(0xFF2563EB),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                        ),
                        _buildAccountTile(
                          icon: Icons.notifications_active_rounded,
                          title: "Notifications",
                          subtitle: "Manage reminders",
                          iconBgColor: const Color(0xFFFEF3C7),
                          iconColor: const Color(0xFFD97706),
                          onTap: () {},
                        ),
                        _buildAccountTile(
                          icon: Icons.shield_rounded,
                          title: "Privacy",
                          subtitle: "Security settings",
                          iconBgColor: const Color(0xFFDCFCE7),
                          iconColor: const Color(0xFF16A34A),
                          onTap: () {},
                        ),
                      ]),
                      
                      const SizedBox(height: 24),
                      
                      const Text("Actions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF64748B))),
                      const SizedBox(height: 12),
                      _buildSettingsGroup([
                        _buildAccountTile(
                          icon: Icons.logout_rounded,
                          title: "Logout",
                          subtitle: "Exit your account",
                          iconBgColor: const Color(0xFFFEE2E2),
                          iconColor: Colors.redAccent,
                          showArrow: false,
                          onTap: () => FirebaseAuth.instance.signOut(),
                        ),
                      ]),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAccountTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E293B))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
      trailing: showArrow ? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E1)) : null,
      onTap: onTap,
    );
  }
}